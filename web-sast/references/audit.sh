#!/bin/bash
# web-sast.sh — Automated front-end security scanner
# Usage: ./audit.sh <URL>
# Example: ./audit.sh https://example.com/login
#
# 依赖: curl, openssl, grep, sed (均为系统自带工具)
# 输出: audit_<domain>_<timestamp>/ 目录，含 headers/ssl/html/js 及扫描日志

set -uo pipefail  # 注意：不用 -e（允许某些步骤失败后降级继续）

URL="${1:-}"
if [ -z "$URL" ]; then
  echo "Usage: $0 <URL>"
  echo "Example: $0 https://example.com/login"
  exit 1
fi

# 验证 URL 格式
if ! echo "$URL" | grep -qE '^https?://'; then
  echo "ERROR: URL must start with http:// or https://"
  exit 1
fi

# Extract domain for SSL check
DOMAIN=$(echo "$URL" | sed -E 's|https?://([^/]+).*|\1|')
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTDIR="audit_${DOMAIN//./_}_${TIMESTAMP}"
mkdir -p "$OUTDIR/js"

echo "============================================"
echo " Web SAST Scanner v2.0"
echo " Target : $URL"
echo " Domain : $DOMAIN"
echo " Output : $OUTDIR/"
echo "============================================"
echo ""

# ==========================================
# Phase 1: HTTP Headers & SSL
# ==========================================
echo "[Phase 1] HTTP headers & SSL check..."

# 尝试多种方式获取响应头（带浏览器UA绕过基础WAF）
BROWSER_UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"

HTTP_CODE=$(curl -sI -L -A "$BROWSER_UA" --connect-timeout 10 --max-time 30 "$URL" \
  -o "$OUTDIR/headers.txt" -w "%{http_code}" 2>/dev/null || echo "000")

case "$HTTP_CODE" in
  000)
    echo "  [FAIL] 无法连接到目标 ($DOMAIN)。请检查："
    echo "        1. 域名是否正确 / DNS是否解析"
    echo "        2. 是否需要代理或VPN"
    echo "        3. 目标站点是否在线"
    echo "  [INFO] 跳过 Phase 1，尝试 Phase 2..."
    ;;
  403|429)
    echo "  [WARN] HTTP $HTTP_CODE — 可能被 WAF/防火墙拦截"
    echo "        已使用浏览器 UA 重试。如果仍被拦，目标有严格的反爬措施"
    echo "        建议手动在浏览器中确认页面可正常访问"
    ;;
  200|301|302|304|307)
    echo "  [OK]   HTTP $HTTP_CODE — 页面可访问"
    ;;
  *)
    echo "  [WARN] HTTP $HTTP_CODE — 非预期状态码"
    ;;
esac

# SSL 检查（仅 HTTPS）
if [[ "$URL" == https://* ]]; then
  echo | openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null | \
    openssl x509 -noout -dates -subject -issuer 2>/dev/null > "$OUTDIR/ssl_cert.txt" || {
      echo "  [WARN] SSL 证书检查失败（可能不是标准HTTPS或证书链有问题）"
      echo "--- SSL Check Failed ---" > "$OUTDIR/ssl_cert.txt"
    }
else
  echo "  [INFO] 目标为 HTTP（非 HTTPS），跳过SSL检查"
  echo "HTTP target — skipped SSL check" > "$OUTDIR/ssl_cert.txt"
fi

# Security header analysis（仅在成功获取到 headers 时执行）
echo ""
echo "--- Security Headers ---"
if [ -f "$OUTDIR/headers.txt" ] && [ -s "$OUTDIR/headers.txt" ]; then
  for header in "Content-Security-Policy" "Strict-Transport-Security" "X-Frame-Options" "X-Content-Type-Options" "X-XSS-Protection"; do
    if grep -qi "^${header}:" "$OUTDIR/headers.txt" 2>/dev/null; then
      VALUE=$(grep -i "^${header}:" "$OUTDIR/headers.txt" | head -1 | cut -d: -f2- | cut -c1-60)
      echo "  [OK]   $header: ${VALUE}"
    else
      echo "  [FAIL] $header: MISSING"
    fi
  done

  # Server header leak
  if grep -qi "^Server:" "$OUTDIR/headers.txt" 2>/dev/null; then
    SERVER=$(grep -i "^Server:" "$OUTDIR/headers.txt" | head -1 | sed 's/^Server:\s*//I' | cut -c1-50)
    echo "  [WARN] Server header exposed: $SERVER"
  fi

  # Cookie 安全检查
  if grep -qi "^Set-Cookie:" "$OUTDIR/headers.txt" 2>/dev/null; then
    while IFS= read -r cookie_line; do
      COOKIE_NAME=$(echo "$cookie_line" | cut -d= -f1 | sed 's/Set-Cookie: //I')
      HAS_HTTPONLY=$(echo "$cookie_line" | grep -qi "HttpOnly" && echo "YES" || echo "NO")
      HAS_SECURE=$(echo "$cookie_line" | grep -qi "Secure" && echo "YES" || echo "NO")
      HAS_SAMESITE=$(echo "$cookie_line" | grep -qi "SameSite" && echo "YES" || echo "NO")
      if [ "$HAS_HTTPONLY" = "NO" ] || [ "$HAS_SECURE" = "NO" ]; then
        echo "  [WARN] Cookie '$COOKIE_NAME': HttpOnly=$HAS_HTTPONLY Secure=$HAS_SECURE SameSite=$HAS_SAMESITE"
      fi
    done < <(grep -i "^Set-Cookie:" "$OUTDIR/headers.txt")
  fi
else
  echo "  [SKIP] 未获取到响应头（Phase 1 失败），跳过安全头分析"
fi

# ==========================================
# Phase 2: Download source & extract JS
# ==========================================
echo ""
echo "[Phase 2] Downloading page & extracting JS resources..."

HTML_SIZE=$(curl -sL -A "$BROWSER_UA" --connect-timeout 10 --max-time 30 "$URL" \
  -o "$OUTDIR/page.html" -w "%{size_download}" 2>/dev/null || echo "0")

if [ "$HTML_SIZE" = "0" ]; then
  echo "  [WARN] HTML 下载失败或内容为空"
  echo "  [INFO] 后续扫描将基于空文件进行（结果有限）"
elif [ "$HTML_SIZE" -lt 100 ]; then
  echo "  [WARN] HTML 内容异常短 (${HTML_SIZE} bytes)，可能是重定向页或错误页"
  echo "  [INFO] 继续分析但结果可信度较低"
else
  echo "  [OK]   HTML 下载完成 (${HTML_SIZE} bytes)"
fi

# Extract external JS URLs (with error tolerance)
JS_URL_COUNT=$(grep -oE 'src="([^"]+\.js[^"]*)"' "$OUTDIR/page.html" 2>/dev/null | \
  sed 's/src="//;s/"$//' > "$OUTDIR/js_urls.txt" && wc -l < "$OUTDIR/js_urls.txt" || echo "0")

echo "  Found $JS_URL_COUNT external JS references"

# Extract external CSS URLs
grep -oE 'href="([^"]+\.css[^"]*)"' "$OUTDIR/page.html" 2>/dev/null | \
  sed 's/href="//;s/"$//' > "$OUTDIR/css_urls.txt" 2>/dev/null || true

# Download each JS file with error handling
JS_SUCCESS=0
JS_FAILED=0
while IFS= read -r js_path; do
  [ -z "$js_path" ] && continue
  if [[ "$js_path" == http* ]]; then
    js_url="$js_path"
  else
    BASE=$(echo "$URL" | sed -E 's|(https?://[^/]+).*|\1|')
    if [[ "$js_path" == /* ]]; then
      js_url="${BASE}${js_path}"
    else
      DIR=$(dirname "$URL" | sed 's|/$||')
      js_url="${DIR}/${js_path}"
    fi
  fi
  js_file=$(basename "$js_path" | sed 's/[?#].*//')
  HTTP_CODE_JS=$(curl -sL -A "$BROWSER_UA" --connect-timeout 8 --max-time 20 "$js_url" \
    -o "$OUTDIR/js/${js_file}" -w "%{http_code}" 2>/dev/null || echo "000")
  case "$HTTP_CODE_JS" in
    200) echo "  [OK]   $js_file"; JS_SUCCESS=$((JS_SUCCESS + 1)) ;;
    403) echo "  [BLOCKED] $js_file (403 — WAF/权限限制)"; JS_FAILED=$((JS_FAILED + 1)) ;;
    404) echo "  [MISSING] $js_file (404 — 文件不存在)"; JS_FAILED=$((JS_FAILED + 1)) ;;
    *)   echo "  [FAILED] $js_file (HTTP $HTTP_CODE_JS)"; JS_FAILED=$((JS_FAILED + 1)) ;;
  esac
done < "$OUTDIR/js_urls.txt"

echo "  JS download: $JS_SUCCESS success, $JS_FAILED failed"

# Save inline scripts reference
grep -n '<script[^>]*>' "$OUTDIR/page.html" 2>/dev/null | head -20 > "$OUTDIR/inline_scripts.txt" || true

# ==========================================
# Phase 3: Deep scan (pattern matching)
# ==========================================
echo ""
echo "[Phase 3] Deep vulnerability scan..."

SCAN_TARGETS=$(find "$OUTDIR/js" -name "*.js" -type f 2>/dev/null)
if [ -z "$SCAN_TARGETS" ]; then
  SCAN_TARGETS="$OUTDIR/page.html"
  echo "  [INFO] 无外部JS文件可用，对 HTML 内联脚本进行扫描"
else
  FILE_COUNT=$(echo "$SCAN_TARGETS" | wc -l | tr -d ' ')
  echo "  Scanning $FILE_COUNT JS file(s)..."
fi

MATCH() {
  local desc="$1"
  local pattern="$2"
  local sev="$3"
  local hit
  hit=$(grep -nE "$pattern" $SCAN_TARGETS 2>/dev/null || true)
  if [ -n "$hit" ]; then
    LINE_COUNT=$(echo "$hit" | wc -l | tr -d ' ')
    echo "  [$sev] $desc ($LINE_COUNT matches)"
    echo "$hit" | head -10 | while IFS= read -r line; do echo "       $line"; done
    if [ "$LINE_COUNT" -gt 10 ]; then
      echo "       ... ($((LINE_COUNT - 10)) more matches, see full output)"
    fi
  fi
}

echo ""
echo "--- Critical Severity ---"
MATCH "Hardcoded secrets / API keys" 'password|api[_-]?key|secret[_-]?key|access[_-]?token[[:space:]]*[=:][[:space:]]*["'"'"'][A-Za-z0-9]' "CRIT"
MATCH "Numeric backdoor codes (6666/8888/0000)" '\b6666\b|\b8888\b|\b0000\b' "CRIT"
MATCH "Math.random() used in security context" 'Math\.random\(\)' "CRIT"
MATCH "PII in URL parameters or query strings" '(phone|mobile|idcard|IDCard|id_card|userName)\s*[=+:]' "CRIT"

echo ""
echo "--- High Severity ---"
MATCH "console.log with sensitive data" 'console\.(log|debug|info)[^)]*(code|num|token|password|phone|mobile|idcard|secret|verify)' "HIGH"
MATCH "eval() dynamic code execution" '\beval\s*\(' "HIGH"
MATCH "new Function() constructor" 'new\s+Function\s*\(' "HIGH"
MATCH "innerHTML XSS sink" '\.innerHTML\s*=' "HIGH"
MATCH "outerHTML XSS sink" '\.outerHTML\s*=' "HIGH"
MATCH "insertAdjacentHTML XSS sink" 'insertAdjacentHTML\s*\(' "HIGH"

echo ""
echo "--- Medium Severity ---"
MATCH "document.write() usage" 'document\.write\s*\(' "MED"
MATCH "Hardcoded debug/development flags" 'debug\s*[=:]\s*true|DEVELOPMENT\s*[=:]\s*true' "MED"

echo ""
echo "--- Low Severity ---"
MATCH "TODO/FIXME with sensitive context" '(TODO|FIXME|HACK|XXX).*(password|secret|auth|login|token)' "LOW"

# CSRF token check
echo ""
echo "--- CSRF Protection ---"
FORM_COUNT=$(grep -ci '<form' "$OUTDIR/page.html" 2>/dev/null || echo "0")
if [ "$FORM_COUNT" -gt 0 ]; then
  echo "  Found $FORM_COUNT form(s)"
  if grep -qiE 'csrf|_token|authenticity_token|x-csrf' "$OUTDIR/page.html" 2>/dev/null; then
    echo "  [OK]   CSRF token detected in page"
  else
    echo "  [FAIL] Form(s) found but NO csrf token detected"
  fi
else
  echo "  [INFO] No <form> tags found (may be SPA with AJAX submission)"
fi

# ==========================================
# Phase 4: Summary
# ==========================================
echo ""
echo "============================================"
echo " Scan Complete"
echo " Output directory: $OUTDIR/"
echo "============================================"
echo ""
echo "Key files:"
[ -f "$OUTDIR/headers.txt" ]     && echo "  $OUTDIR/headers.txt       — HTTP response headers"
[ -f "$OUTDIR/ssl_cert.txt" ]    && echo "  $OUTDIR/ssl_cert.txt      — SSL certificate info"
[ -f "$OUTDIR/page.html" ]       && echo "  $OUTDIR/page.html         — Full page source"
[ ! -z "$(ls $OUTDIR/js/*.js 2>/dev/null)" ] && echo "  $OUTDIR/js/               — Downloaded JS files"
[ -f "$OUTDIR/js_urls.txt" ]     && echo "  $OUTDIR/js_urls.txt       — JS resource URLs"
echo ""
echo "To manually re-scan:"
echo "  grep -rnE 'Math\.random|eval\(|innerHTML\s*=' $OUTDIR/js/"
