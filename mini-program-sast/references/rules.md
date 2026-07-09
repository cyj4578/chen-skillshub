# Mini Program Vulnerability Detection Rules

All rules are designed for `strings`-extracted text from `.wxapkg` files.
Run from the extracted strings file: `grep -nE "<pattern>" extracted_strings.txt`

---

## Critical Severity

### CRIT-01: Token / credentials / passwords in wx.setStorageSync
```bash
grep -nE 'setStorageSync\("token"|setStorageSync\("session"|setStorageSync\("password"|setStorageSync\("secret"' extracted_strings.txt
grep -nE 'setStorageSync\("[^"]*(token|session|access|auth|password|credential|secret)' extracted_strings.txt
```
Also check for synchronous variant:
```bash
grep -nE 'setStorage\s*\(\s*\{[^}]*key\s*:\s*"(token|session|password)' extracted_strings.txt
```

### CRIT-02: wx.login code stored persistently
```bash
grep -nE 'setStorageSync\("code"|setStorageSync\(\s*["'\''](login)?code' extracted_strings.txt
grep -nE 'wx\.login.*setStorage.*code|setStorage.*code.*wx\.login' extracted_strings.txt
```
Context: wx.login code is one-time-use, valid for 5 min. Storing it is semantically wrong and creates a vulnerability window.

### CRIT-03: openId / unionId in URL query parameters
```bash
grep -nE 'navigateTo.*openId|navigateTo.*unionId|redirectTo.*openId|redirectTo.*unionId' extracted_strings.txt
grep -nE '(openId|unionId)\s*\+\s*["'\'';]|\?\w*=\w*\+\s*(openId|unionId)' extracted_strings.txt
grep -nE 'reLaunch.*openId|switchTab.*openId' extracted_strings.txt
```

### CRIT-04: AppSecret / payment key / sensitive server-side keys in frontend code
```bash
grep -nE 'appsecret|AppSecret|mch.*[Kk]ey|pay.*[Ss]ecret|app.*secret' extracted_strings.txt
grep -nE '"secret"\s*:\s*"[a-zA-Z0-9]{20,}"' extracted_strings.txt
```
Also check for hardcoded symmetric encryption keys:
```bash
grep -nE '(AES|DES|RC4|encrypt)_?key|encryptKey|decryptKey' extracted_strings.txt
```

### CRIT-05: Mock mode enabled in production build
```bash
grep -nE 'useMock\s*:\s*true|mockEnabled\s*:\s*true|isMock\s*:\s*true|mockMode\s*:\s*true' extracted_strings.txt
grep -nE 'enableMock\s*:\s*!0|mockData\s*:\s*!0' extracted_strings.txt
```
Context: Mock mode with hardcoded fake API responses remaining in production means the app bypasses real authentication and data validation.

---

## High Severity

### HIGH-01: console.log with sensitive data
```bash
grep -nE 'console\.log[^)]*(token|code|openId|unionId|phone|mobile|idCard|password|session_key|encryptedData|iv)' extracted_strings.txt
grep -nE 'console\.(debug|info|warn)[^)]*(token|code|password|session)' extracted_strings.txt
```

### HIGH-02: API requests passing PII in plaintext in data/params
```bash
grep -nE 'wx\.request.*(idCard|IDCard|id_card|realName|userName|identity|passport)' extracted_strings.txt
grep -nE 'wx\.request.*(bankCard|bank_account|creditCard|socialSecurity)' extracted_strings.txt
```

### HIGH-03: Payment signType using MD5
```bash
grep -nE 'signType\s*:\s*"MD5"|signType\s*:\s*['\''"]MD5' extracted_strings.txt
grep -nE 'sign_type\s*=\s*MD5|signType.*MD5' extracted_strings.txt
```
Context: WeChat Pay recommends HMAC-SHA256. MD5 has known collision attacks.

### HIGH-04: HTTP (non-HTTPS) API endpoints
```bash
grep -nE 'wx\.request\s*\(\s*\{[^}]*url\s*:\s*"http://' extracted_strings.txt
grep -nE 'uploadFile\s*\([^)]*url\s*:\s*"http://' extracted_strings.txt
grep -nE 'downloadFile\s*\([^)]*url\s*:\s*"http://' extracted_strings.txt
```
Context: WeChat enforces HTTPS for production mini programs, but HTTP calls in development may accidentally leak to production.

### HIGH-05: Unsafe page navigation with user-controlled URLs
```bash
grep -nE 'navigateTo\s*\(\s*\{?\s*url\s*:\s*\w+' extracted_strings.txt
```
If the navigated URL contains variables from user input or API response without validation → HIGH.

### HIGH-06: Hardcoded 3rd-party appId / corpId / plugin keys
```bash
grep -nE 'corpId\s*:\s*"ww|corpid\s*=\s*"ww' extracted_strings.txt
grep -nE 'appId\s*:\s*"[0-9]{16,20}"' extracted_strings.txt
grep -nE 'pluginKey|pluginSecret|component_appid' extracted_strings.txt
```

---

## Medium Severity

### MED-01: wx.getUserInfo called without checking auth setting first
```bash
grep -nE 'wx\.getUserInfo\s*\(' extracted_strings.txt
```
Then check if `wx.getSetting` appears anywhere (to verify auth state check exists). If not → MED.

### MED-02: No input validation attributes on form fields
```bash
grep -nE '<input\b[^>]*(type=["'\''"]text|type=["'\''"]number)[^>]*>' extracted_strings.txt
```
Check extracted input tags for presence of `maxlength`, `pattern`, or `bindblur` validation. Absence → MED.

### MED-03: setStorageSync without capacity awareness
```bash
grep -nE 'setStorageSync\s*\([^)]{200,}' extracted_strings.txt
```
If large data blobs are written to storage without checking available space → MED. WeChat limits total storage to 10MB per app.

### MED-04: WebView / web-view component without URL validation
```bash
grep -nE '<web-view.*src' extracted_strings.txt
```
If the web-view `src` attribute uses a variable from API response or user input → MED.

---

## Low Severity

### LOW-01: Outdated base library version
```bash
grep -nE '"libVersion"\s*:\s*"[0-2]\.' extracted_strings.txt
grep -nE 'SDKVersion.*[0-2]\.\d+\.\d+' extracted_strings.txt
```

### LOW-02: debug statements in production code
```bash
grep -nE '\bdebugger\b' extracted_strings.txt
grep -nE 'setEnableDebug\s*\(\s*\{?\s*enableDebug\s*:\s*true' extracted_strings.txt
grep -nE 'wx\.setEnableDebug' extracted_strings.txt
```

### LOW-03: TODO/FIXME with security implications
```bash
grep -nE '(TODO|FIXME|HACK|XXX).*(auth|login|token|password|encrypt|security|verify)' extracted_strings.txt
```

### LOW-04: Outdated third-party SDK references
```bash
grep -nE 'sdk.*version.*["\''"][0-9]+\.' extracted_strings.txt
```

---

## Contextual Checks (manual review needed)

These require human/AI judgment — no clean grep pattern:

### CC-01: API endpoint inventory
```bash
grep -oE 'https?://[a-zA-Z0-9.-]+(:[0-9]+)?/[a-zA-Z0-9/._-]*' extracted_strings.txt | sort -u > api_endpoints.txt
```
Review the list: are there any internal/test/staging endpoints in production code? Any IP-based URLs?

### CC-02: Third-party SDK inventory
```bash
grep -nE 'requirePlugin|require\(["'\''"]plugin|plugin-private' extracted_strings.txt
```
List all plugins: are they all still actively maintained?

### CC-03: Custom encryption/encoding functions
```bash
grep -nE 'function\s+(encrypt|decrypt|encode|decode|btoa|atob|AES|DES|RSA)' extracted_strings.txt
```
If custom crypto functions exist → flag for manual review (likely homebrew and insecure).
