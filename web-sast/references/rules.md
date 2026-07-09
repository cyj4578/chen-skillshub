# Vulnerability Detection Rules

## Critical Severity

### CRIT-01: Hardcoded secrets / backdoor passwords
```bash
grep -nE '(password|passwd|api.?key|secret|token)\s*[=:]\s*["'"'"'][a-zA-Z0-9_\-!@#$%^&*]{4,}["'"'"']' *.js
```
Also check for numeric hardcoded bypasses:
```bash
grep -nE '==\s*[0-9]{4,}\s*\)|\b6666\b|\b8888\b|\b0000\b' *.js
```

### CRIT-02: Client-side authentication / crypto
```bash
grep -nE 'Math\.random\(\)' *.js
grep -nE 'new\s+Date\(\)\.getTime\(\)' *.js
```
If found: verify the resulting value is NOT used for tokens, verification codes, session IDs, or any security purpose.

### CRIT-03: Verification code client-side generation
```bash
grep -nE '(验证码|verify|verification|sms.*code).*Math\.random|Math\.random.*(验证码|verify|verification|sms.*code)' *.js
```

### CRIT-04: PII in URL query parameters
```bash
grep -nE '(phone|mobile|idcard|id_card|IDCard|realname|userName|passport)\s*[=+:]' *.html *.js
```

### CRIT-05: Missing all security headers
Check via `curl -sI`:
- No `Content-Security-Policy`
- No `Strict-Transport-Security`
- No `X-Frame-Options`
- No `X-Content-Type-Options`

If all four are absent → CRITICAL.

---

## High Severity

### HIGH-01: `eval()` or `new Function()` with dynamic input
```bash
grep -nE '\beval\s*\(|\bnew\s+Function\s*\(' *.js
```

### HIGH-02: `innerHTML` assignment (XSS sink)
```bash
grep -nE '\.innerHTML\s*=' *.js
grep -nE '\.outerHTML\s*=' *.js
grep -nE 'insertAdjacentHTML\s*\(' *.js
```

### HIGH-03: Missing CSRF token in forms
```bash
grep -nE '<form\b' *.html | while read line; do
  # Check if the form or its parent context has a csrf input
  grep -c 'csrf|_token|authenticity_token' *.html
done
```

### HIGH-04: `console.log` printing sensitive data
```bash
grep -nE 'console\.(log|debug|info|warn)\s*\([^)]*(password|token|key|phone|mobile|idcard|num|code|secret)' *.js
```

### HIGH-05: Server version exposed in response headers
Check `curl -sI` output for `Server:` header revealing Apache/IIS/Nginx version + modules + OS.

### HIGH-06: Third-party trackers on sensitive pages
```bash
grep -nE '(hm\.baidu|google-analytics|facebook|mixpanel|sentry).*\.js' *.html *.js
```
If the page collects PII (ID, phone, etc.) → HIGH.

---

## Medium Severity

### MED-01: `document.write()` usage
```bash
grep -nE 'document\.write\s*\(' *.js
```

### MED-02: Missing individual security header
Check headers one by one.

### MED-03: No input validation on form fields
```bash
grep -nE '<input\b[^>]*(type=["'"'"'](text|number|tel)["'"'"'])[^>]*>' *.html | while read line; do
  if ! echo "$line" | grep -qE 'pattern=|maxlength=|data-validate'; then
    echo "  WARNING: Input without validation: $line"
  fi
done
```

### MED-04: Cacheable sensitive pages
Check `curl -sI` for `Cache-Control: no-store` absence on pages with forms.

---

## Low Severity

### LOW-01: Outdated library versions
Check loaded JS libs against known CVE databases.

### LOW-02: Comments containing TODO/FIXME with sensitive context
```bash
grep -nE '(TODO|FIXME|HACK|XXX).*(password|secret|auth|login)' *.js
```
