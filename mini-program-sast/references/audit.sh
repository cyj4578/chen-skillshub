#!/bin/bash
# mini-program-sast.sh — Automated Mini Program security scanner
# Usage: ./audit.sh <AppID>
# Example: ./audit.sh wx1234567890abcdef
#
# 前置条件：
#   1. 在电脑微信中打开过该小程序（Mac/Windows）
#   2. 系统已安装 strings 命令（Mac 自带，Linux 自带）
#   3. 微信缓存未被清理
#
# 依赖: strings, grep, find, wc, head, sort (均为系统自带工具)
# 输出: audit_<AppID>_<timestamp>/ 目录，含报告和提取的源码字符串

set -uo pipefail  # 不用 -e（允许部分步骤失败后降级继续）

APPID="${1:-}"
if [ -z "$APPID" ]; then
  echo "Usage: $0 <AppID>"
  echo "Example: $0 wx1234567890abcdef"
  echo ""
  echo "前置条件："
  echo "  1. 在电脑微信中打开过该小程序"
  echo "  2. 微信缓存未被清理"
  exit 1
fi

# 验证 AppID 格式（wx 开头，16 位字符）
if ! echo "$APPID" | grep -qE '^wx[a-zA-Z0-9]{14,}$'; then
  echo "WARN: AppID 格式不标准（通常为 wx 开头的 16 位字符串）"
  echo "     当前输入: $APPID"
  echo "     将继续尝试，但可能找不到缓存文件。"
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTDIR="audit_${APPID}_${TIMESTAMP}"
mkdir -p "$OUTDIR"

echo "============================================"
echo " Mini Program SAST Scanner v1.0"
echo " Target AppID : $APPID"
echo " Output       : $OUTDIR/"
echo "============================================"
echo ""

# ==========================================
# Phase 0: 前置条件检查（缓存目录定位）
# ==========================================
echo "[Phase 0] Locating wxapkg cache..."

# macOS 微信缓存路径（优先）
WX_CACHE_MAC="$HOME/Library/Containers/com.tencent.xinWeChat/Data/.wxapplet/packages/${APPID}"

# macOS App Store 版微信缓存路径（备选 — radium 路径）
# AppStore 沙盒版使用 Data/Documents/app_data/radium/ 子路径
WX_CACHE_MAC_APPSTORE="$HOME/Library/Containers/com.tencent.xinWeChat/Data/Documents/app_data/radium"

# 通用搜索策略（find，兜底）
WX_CACHE_FOUND=""

# 策略1: 直接路径检测（官网版微信，最快）
if [ -d "$WX_CACHE_MAC" ]; then
  WX_CACHE_FOUND="$WX_CACHE_MAC"
  echo "  [OK]   找到缓存目录（官网版微信）"
else
  # 策略2: AppStore 版微信（radium 路径，需广播搜索）
  if [ -d "$WX_CACHE_MAC_APPSTORE" ]; then
    echo "  [INFO] 检测到 AppStore 版微信，广播搜索 radium 路径..."
    WX_CACHE_FOUND=$(find "$WX_CACHE_MAC_APPSTORE" -type d -name "$APPID" 2>/dev/null | head -1)
    if [ -n "$WX_CACHE_FOUND" ]; then
      echo "  [OK]   AppStore 版找到缓存: $WX_CACHE_FOUND"
    fi
  fi

  # 策略3: 全盘广播搜索（兜底）
  if [ -z "$WX_CACHE_FOUND" ]; then
    echo "  [INFO] 全盘广播搜索..."
    WX_CACHE_FOUND=$(find "$HOME/Library/Containers/com.tencent.xinWeChat" -type d -name "$APPID" 2>/dev/null | head -1)
    if [ -n "$WX_CACHE_FOUND" ]; then
      echo "  [OK]   全盘搜索找到缓存: $WX_CACHE_FOUND"
    fi
  fi
fi

# 策略3: Windows (WSL/Git Bash) 路径（非 macOS 时尝试）
if [ -z "$WX_CACHE_FOUND" ] && [ "$(uname -s 2>/dev/null)" != "Darwin" ]; then
  WX_CACHE_WIN="$HOME/Documents/WeChat Files/Applet/${APPID}"
  WX_CACHE_WIN2="/mnt/c/Users/$USER/Documents/WeChat Files/Applet/${APPID}"
  if [ -d "$WX_CACHE_WIN" ]; then
    WX_CACHE_FOUND="$WX_CACHE_WIN"
    echo "  [OK]   找到缓存目录（Windows 微信）"
  elif [ -d "$WX_CACHE_WIN2" ]; then
    WX_CACHE_FOUND="$WX_CACHE_WIN2"
    echo "  [OK]   找到缓存目录（WSL 挂载的 Windows 微信）"
  fi
fi

if [ -z "$WX_CACHE_FOUND" ]; then
  echo ""
  echo "============================================"
  echo " FAIL: 找不到小程序缓存目录"
  echo "============================================"
  echo ""
  echo "可能的原因："
  echo "  1. 未在电脑微信中打开过该小程序 → 请先在微信中打开小程序"
  echo "  2. AppID 不正确 → 请在微信公众平台后台确认 AppID"
  echo "  3. 微信缓存被清理过 → 重新在微信中打开小程序后再运行本脚本"
  echo "  4. 微信版本差异 → 尝试更新微信到最新版"
  echo ""
  echo "操作步骤："
  echo "  ① 打开电脑版微信"
  echo "  ② 搜索并进入目标小程序"
  echo "  ③ 浏览几个页面后退出小程序"
  echo "  ④ 重新运行: $0 $APPID"
  echo ""
  exit 1
fi

echo "  Cache path: $WX_CACHE_FOUND"

# ==========================================
# Phase 1: 定位 wxapkg 并提取字符串
# ==========================================
echo ""
echo "[Phase 1] Finding wxapkg files & extracting strings..."

# 找到所有 wxapkg 文件
ALL_PKGS=$(find "$WX_CACHE_FOUND" -name "*.wxapkg" -type f 2>/dev/null | sort)
PKG_COUNT=$(echo "$ALL_PKGS" | grep -c "wxapkg" || echo "0")

if [ "$PKG_COUNT" -eq 0 ]; then
  echo "  [FAIL] 目录存在但无线程包文件（*.wxapkg）"
  echo "         可能原因：微信版本差异、小程序未完整下载"
  echo "         尝试扩大搜索范围..."
  ALL_PKGS=$(find "$HOME/Library/Containers/com.tencent.xinWeChat" -name "*.wxapkg" -path "*${APPID}*" -type f 2>/dev/null | head -20)
  PKG_COUNT=$(echo "$ALL_PKGS" | grep -c "wxapkg" || echo "0")
  if [ "$PKG_COUNT" -eq 0 ]; then
    echo "  [FAIL] 扩大搜索也未找到。请确保在微信中打开过小程序。"
    exit 1
  fi
fi

echo "  Found $PKG_COUNT wxapkg file(s):"
echo "$ALL_PKGS" | while IFS= read -r pkg; do
  SIZE=$(ls -lh "$pkg" 2>/dev/null | awk '{print $5}')
  NAME=$(basename "$pkg")
  echo "    $NAME ($SIZE)"
done

# 提取每个包的字符串
STRINGS_DIR="$OUTDIR/extracted"
mkdir -p "$STRINGS_DIR"
TOTAL_LINES=0

echo "$ALL_PKGS" | while IFS= read -r pkg; do
  [ -z "$pkg" ] && continue
  PKG_NAME=$(basename "$pkg" .wxapkg)
  OUTPUT_FILE="$STRINGS_DIR/${PKG_NAME}.txt"

  # 提取可打印字符串（最小长度4，使用系统 strings 命令）
  # - 限制 200,000 行防止内存溢出
  # - 跳过纯二进制噪声（-n 4 表示最小连续 4 个可打印字符）
  if strings -n 4 "$pkg" 2>/dev/null | head -200000 > "$OUTPUT_FILE"; then
    LINES=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
    echo "  [OK]   $PKG_NAME → ${LINES} lines extracted"
  else
    echo "  [WARN] $PKG_NAME → strings extraction failed (possibly encrypted)"
    echo "# Extraction failed — package may be encrypted" > "$OUTPUT_FILE"
  fi
done

# 汇总所有提取内容
COMBINED="$OUTDIR/all_strings.txt"
cat "$STRINGS_DIR"/*.txt 2>/dev/null > "$COMBINED"
TOTAL_LINES=$(wc -l < "$COMBINED" | tr -d ' ')
echo "  Total: $TOTAL_LINES lines from all packages"

# 提取 API 端点清单（供后续人工审查）
grep -oE 'https?://[a-zA-Z0-9.-]+(:[0-9]+)?/[a-zA-Z0-9/._-]*' "$COMBINED" 2>/dev/null | sort -u > "$OUTDIR/api_endpoints.txt"
ENDPOINT_COUNT=$(wc -l < "$OUTDIR/api_endpoints.txt" | tr -d ' ')
echo "  Extracted $ENDPOINT_COUNT unique API endpoints"

# ==========================================
# Phase 2: 深度扫描
# ==========================================
echo ""
echo "[Phase 2] Deep vulnerability scan..."
echo ""

# 辅助函数：执行模式匹配并输出结果
# 参数: $1=描述, $2=grep模式, $3=严重级别(CRIT/HIGH/MED/LOW)
MATCH() {
  local desc="$1"
  local pattern="$2"
  local sev="$3"
  local hit

  hit=$(grep -nE "$pattern" "$COMBINED" 2>/dev/null || true)
  if [ -n "$hit" ]; then
    local line_count
    line_count=$(echo "$hit" | wc -l | tr -d ' ')
    echo "  [$sev] $desc ($line_count matches)"

    # 显示前 8 条匹配（含上下文）
    echo "$hit" | head -8 | while IFS= read -r hline; do
      # 截断到 100 字符，防止单行过长
      if [ ${#hline} -gt 100 ]; then
        echo "       ${hline:0:100}..."
      else
        echo "       $hline"
      fi
    done
    if [ "$line_count" -gt 8 ]; then
      echo "       ... ($((line_count - 8)) more matches)"
    fi
  fi
}

# === Critical Severity ===
echo "--- Critical Severity ---"
MATCH "Token/密码明文存储 (setStorageSync)" \
  'setStorageSync\("token"|setStorageSync\("session"|setStorageSync\("password"|setStorageSync\("secret"' \
  "CRIT"

MATCH "wx.login code 持久化存储" \
  'setStorageSync\("code"|setStorageSync\(.*login.*code' \
  "CRIT"

MATCH "openId通过URL参数传递 (navigateTo/redirectTo)" \
  'navigateTo.*openId|redirectTo.*openId|navigateTo.*unionId' \
  "CRIT"

MATCH "AppSecret / 支付密钥硬编码" \
  'appsecret|AppSecret|mch_key|pay_secret|secret.*[0-9a-fA-F]{16,}' \
  "CRIT"

MATCH "Mock模式在生产环境启用" \
  'useMock.*true|mockEnabled.*true|isMock.*true|enableMock' \
  "CRIT"

# === High Severity ===
echo ""
echo "--- High Severity ---"
MATCH "console.log输出敏感数据" \
  'console\.(log|debug|info).*(token|code|openId|phone|password|session|certificate|verify)' \
  "HIGH"

MATCH "API请求参数含明文件份证/手机号" \
  'idCard|IDCard|id_card.*request|phone.*request.*data' \
  "HIGH"

MATCH "支付签名使用MD5" \
  'signType.*MD5|sign_type.*MD5' \
  "HIGH"

MATCH "非HTTPS的API请求" \
  'request.*url.*http://|uploadFile.*url.*http://|downloadFile.*url.*http://' \
  "HIGH"

MATCH "硬编码corpId / 企业微信凭证" \
  'corpId.*"ww|corpid.*"ww' \
  "HIGH"

MATCH "硬编码第三方appId" \
  'appId.*"[0-9]{16,}"' \
  "HIGH"

# === Medium Severity ===
echo ""
echo "--- Medium Severity ---"
MATCH "wx.getUserInfo未检查授权状态" \
  'wx\.getUserInfo' \
  "MED"

MATCH "表单input无校验属性" \
  '<input.*type="text"[^>]*>' \
  "MED"

MATCH "WebView组件无URL白名单" \
  '<web-view' \
  "MED"

# === Low Severity ===
echo ""
echo "--- Low Severity ---"
MATCH "debugger语句残留" \
  'debugger' \
  "LOW"

MATCH "setEnableDebug在生产中启用" \
  'setEnableDebug.*true|enableDebug.*true' \
  "LOW"

MATCH "TODO/FIXME含安全关键词" \
  '(TODO|FIXME).*(auth|login|token|password|encrypt|security)' \
  "LOW"

# ==========================================
# 额外检查：wxapkg 格式识别
# ==========================================
echo ""
echo "--- Package Format Detection ---"
MAIN_PKG=$(echo "$ALL_PKGS" | head -1)
if [ -n "$MAIN_PKG" ] && [ -f "$MAIN_PKG" ]; then
  HEADER=$(head -c 8 "$MAIN_PKG" 2>/dev/null | xxd -p | tr -d '\n' 2>/dev/null || echo "UNKNOWN")
  if echo "$HEADER" | grep -qi "56314d4d5758"; then  # "V1MMWX" in hex
    echo "  [INFO] 标准 wxapkg 格式 (V1MMWX header) — unveilr 可完整解包"
  elif file "$MAIN_PKG" 2>/dev/null | grep -qi "data"; then
    echo "  [INFO] 疑似 WMPF 格式（微信小程序框架二进制）— strings 提取有效但碎片化"
  else
    echo "  [INFO] 格式未识别 — 仍可通过 strings 扫描"
  fi
fi

# ==========================================
# Phase 3: 报告汇总
# ==========================================
echo ""
echo "============================================"
echo " Scan Complete"
echo "============================================"
echo " Output directory : $OUTDIR/"
echo " Extracted strings: $COMBINED ($TOTAL_LINES lines)"
echo " API endpoints    : $OUTDIR/api_endpoints.txt ($ENDPOINT_COUNT endpoints)"
echo ""
echo "Key findings are printed above. For full extracted content:"
echo "  cat $COMBINED"
echo "  cat $OUTDIR/api_endpoints.txt"
echo ""
echo "To manually re-scan specific patterns:"
echo "  grep -rnE '<pattern>' $COMBINED"
echo ""
