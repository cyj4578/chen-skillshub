---
name: web-sast
description: Use when user provides a URL and asks about web security, vulnerabilities, penetration testing, code audit, XSS, CSRF, security headers, SSL/TLS configuration, hardcoded secrets, or front-end security scanning. Also use when user asks to check whether a website/page is safe, has backdoors, leaks user data, or can be attacked.
---

# Web SAST

Web 前端静态安全扫描。输入一个 URL，自动执行 4 阶段扫描（HTTP头/SSL → 源码提取 → 漏洞模式匹配 → 分级报告），输出含修复建议的结构化安全审计报告（**HTML 格式，浏览器打印即可导出 PDF**）。

## 核心能力

```
用户给 URL → 我来扫 → 出报告（Critical / High / Medium / Low）
```

**能做什么：**
- 扫描任何可通过 HTTP 访问的 Web 页面（H5、SPA、传统站点）
- 检测前端 JS 源码中的安全漏洞模式
- 分析 HTTP 安全响应头和 SSL/TLS 配置
- 识别硬编码密钥、客户端验证码生成、PII 泄露等常见问题
- 输出分级报告 + 每个漏洞的修复代码示例

**不能做什么：**
- ❌ 不做后端渗透测试（SQL注入需交互式探测，静态扫描无法完成）
- ❌ 不做 DDoS / 网络层测试
- ❌ 不扫描需要登录才能访问的页面（除非用户提供认证信息）
- ❌ 不替代 OWASP ZAP / Burp Suite 等专业安全工具
- ❌ 不对目标发起任何攻击性行为（只读分析，零副作用）

## 触发条件

以下任一场景触发本 Skill：

| 用户说的话 | 触发 |
|-----------|------|
| "这个页面安全吗" / "有漏洞吗" | ✅ |
| "帮我审计/扫描一下这个网站" | ✅ |
| "检查 XSS / CSRF / 安全头" | ✅ |
| "有没有后门 / 密钥泄露" | ✅ |
| "等保测评 / 安全合规检查" | ✅ |
| "帮我写一个安全检测报告" | ✅ |
| "这个 URL 能打开，看看代码" | ✅ |

**不触发的场景：**
- 用户只问概念性问题（"什么是XSS"）→ 用解释/教学方式回答即可，不需要加载本 Skill
- 用户要求修改/修复代码 → 本 Skill 只负责发现，修复用其他 Skill 或直接编码
- 用户提供的不是 URL（如本地文件路径）→ 需要调整策略

## 工作流程

### Phase 1: 表面扫描（约 10 秒）

抓取 HTTP 响应头和 SSL 证书信息。

```bash
# 获取响应头
curl -sI -L -A "Mozilla/5.0" "$URL"

# 检查 SSL 证书
echo | openssl s_client -connect $DOMAIN:443 -servername $DOMAIN 2>/dev/null | openssl x509 -noout -dates -subject -issuer
```

**检查项清单：**

| 安全头 | 期望值 | 缺失时严重度 |
|--------|--------|-------------|
| Content-Security-Policy | 存在且非空 | Medium |
| Strict-Transport-Security | max-age ≥ 31536000 | Medium |
| X-Frame-Options | DENY / SAMEORIGIN | Low |
| X-Content-Type-Options | nosniff | Low |
| Referrer-Policy | 存在 | Low |
| Set-Cookie 的 HttpOnly/Secure/SameSite | 全部具备 | High |

**SSL 证书检查：**
- 是否过期？（当前日期 vs notAfter）
- 颁发机构是否为知名 CA？
- SAN 是否包含目标域名？

### Phase 2: 源码提取（约 15 秒）

下载 HTML 页面并提取所有外部 JS/CSS 资源。

```bash
# 下载完整 HTML
curl -sL -A "Mozilla/5.0" "$URL" > page.html

# 提取所有 JS 引用
grep -oE 'src="([^"]+\.js[^"]*)"' page.html | sed 's/src="//;s/"$//' > js_urls.txt

# 提取所有 CSS 引用
grep -oE 'href="([^"]+\.css[^"]*)"' page.html | sed 's/href="//;s/"$//' > css_urls.txt

# 下载每个 JS 文件到 js/ 目录
while read js_path; do
  # 处理相对路径/绝对路径/完整URL
  curl -sL "$full_url" -o "js/$(basename $js_path)"
done < js_urls.txt
```

### Phase 3: 深度扫描（核心）

使用 `references/rules.md` 中的检测规则对所有 JS 文件进行模式匹配。

**扫描矩阵：**

| 编号 | 检测项 | 严重度 | grep 模式 |
|------|--------|--------|-----------|
| CRIT-01 | 硬编码密钥/万能密码 | Critical | password/api_key/secret/token = "..." |
| CRIT-02 | Math.random 用于安全场景 | Critical | Math.random() |
| CRIT-03 | 客户端验证码生成 | Critical | 验证码 + Math.random |
| CRIT-04 | PII 在 URL 参数中传输 | Critical | phone/idcard/userName in URL |
| CRIT-05 | 所有安全头缺失 | Critical | headers 全空 |
| HIGH-01 | eval() / new Function() | High | eval(/new Function |
| HIGH-02 | innerHTML 赋值 | High | innerHTML = |
| HIGH-03 | 表单无 CSRF Token | High | form 无 csrf |
| HIGH-04 | console.log 敏感数据 | High | console.log(token/phone...) |
| HIGH-05 | Server 版本暴露 | High | Server: Apache/xxx |
| HIGH-06 | 敏感页面的第三方追踪器 | High | 百度统计/GA on PII pages |
| MED-01 | document.write() | Medium | document.write( |
| MED-02 | 缺失单个安全头 | Medium | 单个 header 缺失 |
| MED-03 | 表单字段无校验属性 | Medium | input 无 pattern/maxlength |
| MED-04 | 敏感页面可缓存 | Medium | form 页无 Cache-Control: no-store |
| LOW-01 | 过期库版本 | Low | jQuery < 3.x 等 |
| LOW-02 | 含敏感信息的注释 | Low | TODO/FIXME + password |

### Phase 4: 报告生成（HTML → 浏览器打印导出 PDF）

扫描完成后，生成一份**结构化 HTML 安全审计报告**。报告使用 print-friendly CSS（`@page { size: A4; }` + `@media print`），用户可通过浏览器 `Ctrl+P / Cmd+P` →「另存为 PDF」一键导出为 PDF 文件。

**报告固定包含九大章节（按顺序）：**

| 章节 | 标题 | 内容 |
|------|------|------|
| 一 | 执行摘要 | 四色统计卡片（Critical/High/Medium/Low 数量）+ 总体评级 |
| 二 | 目标信息 | URL、扫描时间、页面功能、技术栈、服务器信息 |
| 三 | 扫描流程回顾 | Phase 1→4 每步通过/受限状态 + 简要说明 |
| 四 | HTTP 安全头与 SSL | 安全头状态表（含当前值/建议）+ SSL 证书信息 |
| 五 | 漏洞详细分析 | 按严重度分组（CRIT→HIGH→MED→LOW），每条含代码片段+风险说明+修复方案 |
| 六 | 修复优先级与等保影响 | 优先级排序表（P0/P1/P2）+ 预计工时 + 等保维度映射 |
| 七 | 与专业工具对比 | Web SAST vs OWASP ZAP vs Burp Suite 对比表 |
| 八 | 建议与后续行动 | 编号建议表，每条带优先级标签 |
| 九 | 审计局限性声明 | 声明基于的方法、不覆盖的范围、误报可能性 |

**报告 HTML 必须包含以下 CSS 打印样式：**
```css
@page { size: A4; margin: 20mm; }
@media print { body { padding: 20px; } }
```

**交付物**：`.html` 文件保存到 artifacts 目录，文件名格式：`web-sast-report-{sanitized_url}.html`。用户可通过浏览器打开后打印为 PDF。

**报告示例参考**：见 mini-program-sast 的报告模板 — 相同的十大章节结构、统计卡片、风险评级表、发现标注（正面/信息/警告）、对比分析和建议表。后续所有报告以此为模板。Web SAST 删除小程序特有的包体分析章节，增加 HTTP 安全头与 SSL 独立章节。

> ⚠️ **重要**：报告中不得包含任何真实网站的域名、API 端点、密钥等可追溯到具体业务的数据。所有示例信息必须脱敏。

## 报告 HTML 模板

以下为生成报告时的 HTML 骨架。每份报告按此模板填入实际数据：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<title>Web 安全审计报告 — {TARGET_HOST}</title>
<style>
  @page { size: A4; margin: 20mm; }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: -apple-system, "PingFang SC", "Microsoft YaHei", sans-serif; color: #1a1a2e; line-height: 1.7; padding: 40px 50px; max-width: 800px; margin: 0 auto; font-size: 13px; }
  .cover { text-align: center; padding: 60px 0; border-bottom: 3px solid #2563eb; margin-bottom: 40px; }
  .cover h1 { font-size: 28px; color: #1e3a5f; margin-bottom: 8px; }
  .cover .subtitle { font-size: 16px; color: #64748b; margin-bottom: 30px; }
  .cover .meta { font-size: 12px; color: #94a3b8; }
  .cover .badge { display: inline-block; padding: 6px 24px; border-radius: 20px; font-weight: 700; font-size: 14px; margin-top: 20px; }
  .badge-critical { background: #fee2e2; color: #991b1b; border: 2px solid #ef4444; }
  .badge-clean { background: #dcfce7; color: #166534; border: 2px solid #16a34a; }
  .badge-limited { background: #fef3c7; color: #92400e; border: 2px solid #f59e0b; }
  
  h2 { font-size: 18px; color: #1e3a5f; border-bottom: 2px solid #e2e8f0; padding-bottom: 6px; margin: 30px 0 16px; }
  h3 { font-size: 14px; color: #334155; margin: 20px 0 10px; }
  
  .summary-grid { display: flex; gap: 20px; margin: 20px 0; }
  .summary-card { flex: 1; background: #f8fafc; border-radius: 10px; padding: 16px; border: 1px solid #e2e8f0; text-align: center; }
  .summary-card .num { font-size: 32px; font-weight: 800; }
  .summary-card .label { font-size: 11px; color: #64748b; margin-top: 4px; }
  
  table { width: 100%; border-collapse: collapse; margin: 14px 0; font-size: 12px; }
  th { background: #1e3a5f; color: #fff; padding: 10px 12px; text-align: left; }
  td { padding: 8px 12px; border-bottom: 1px solid #e2e8f0; }
  tr:nth-child(even) td { background: #f8fafc; }
  
  .finding { margin: 16px 0; padding: 16px; border-left: 4px solid; border-radius: 0 8px 8px 0; background: #f8fafc; }
  .finding-critical { border-color: #ef4444; }
  .finding-high { border-color: #f97316; }
  .finding-medium { border-color: #eab308; }
  .finding-low { border-color: #2563eb; }
  .finding-positive { border-color: #16a34a; }
  
  .tag { display: inline-block; padding: 2px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; }
  .tag-red { background: #fee2e2; color: #991b1b; }
  .tag-orange { background: #fff7ed; color: #9a3412; }
  .tag-yellow { background: #fef3c7; color: #92400e; }
  .tag-blue { background: #dbeafe; color: #1e40af; }
  .tag-green { background: #dcfce7; color: #166534; }
  
  .phase { margin: 10px 0; padding: 10px 16px; background: #f0f9ff; border-radius: 8px; border: 1px solid #bfdbfe; }
  .phase .phase-title { font-weight: 700; color: #1e40af; }
  
  pre { background: #1e293b; color: #e2e8f0; padding: 14px; border-radius: 8px; overflow-x: auto; font-size: 11px; margin: 8px 0; }
  code { font-family: "SF Mono", "Fira Code", monospace; }
  
  .footer { margin-top: 50px; padding-top: 20px; border-top: 1px solid #e2e8f0; font-size: 11px; color: #94a3b8; text-align: center; }
  
  @media print { body { padding: 20px; } }
</style>
</head>
<body>

<div class="cover">
  <h1>🛡️ Web 安全审计报告</h1>
  <div class="subtitle">Web Front-End Static Security Audit (SAST)</div>
  <div class="meta">审计日期：{scan_time}<br>审计工具：web-sast v1.0</div>
  <div class="badge badge-{overall_level}">{overall_badge_text}</div>
</div>

<!-- 章节一：执行摘要 -->
<h2>一、执行摘要</h2>
<div class="summary-grid">...</div>

<!-- 章节二：目标信息 -->
<h2>二、目标信息</h2>
<table>...</table>

<!-- 章节三：扫描流程回顾 -->
<h2>三、扫描流程回顾</h2>
<div class="phase">...</div>

<!-- 章节四：HTTP 安全头与 SSL -->
<h2>四、HTTP 安全头与 SSL</h2>
<table>...</table>

<!-- 章节五：漏洞详细分析 -->
<h2>五、漏洞详细分析</h2>
<div class="finding finding-critical">...</div>

<!-- 章节六：修复优先级与等保影响 -->
<h2>六、修复优先级与等保影响</h2>
<table>...</table>

<!-- 章节七：与专业工具对比 -->
<h2>七、与专业工具对比</h2>
<table>...</table>

<!-- 章节八：建议与后续行动 -->
<h2>八、建议与后续行动</h2>
<table>...</table>

<!-- 章节九：审计局限性声明 -->
<h2>九、审计局限性声明</h2>
<p>...</p>

<div class="footer">
  <p>web-sast v1.0 · Web 前端静态安全扫描</p>
  <p>报告生成时间：{scan_time} · 审计对象：{target_url}</p>
  <p style="color:#94a3b8;">本报告不含任何真实案例数据，所有示例信息均已脱敏处理</p>
</div>

</body>
</html>
```

## 异常处理指南

扫描过程中可能遇到的问题及解决方案：

### 常见异常

| 错误现象 | 原因 | 解决方法 |
|----------|------|----------|
| curl 返回 `403 Forbidden` / WAF 拦截 | 目标站有防火墙，识别到了自动化请求 | 添加 `-A "Mozilla/5.0 ..."` 浏览器 UA 重试；如果仍失败，告知用户这是 WAF 保护正常行为 |
| curl 返回 `429 Too Many Requests` | 触发了速率限制 | 等待 60 秒后重试；降低请求频率；先只下载 HTML 不下载子资源 |
| curl 连接超时 | DNS 解析失败或目标不可达 | 先 `ping` 域名确认可达性；检查是否需要 VPN/代理 |
| HTML 是 SPA 但 JS Bundle 加载失败 | JS 文件名带 hash 且 HTML 动态渲染 | 尝试用浏览器 UA 获取；提取 `<script src>` 中的实际 URL；必要时告知用户该 SPA 需要运行时渲染，静态扫描有限制 |
| openssl 报错 | 目标不支持 HTTPS 或证书链有问题 | 检查是否为 HTTP（非 HTTPS）；记录证书错误信息作为发现点 |
| JS 文件过大（>2MB）导致 grep 慢 | 单文件打包了所有依赖 | 使用 `strings` 命令提取可读部分；限制搜索范围；告知用户大型 SPA 的扫描耗时较长 |
| 目标需要登录才能看到内容 | 页面重定向到登录页 | 告知用户当前只能扫描公开页面；如果需要扫描登录后页面，请提供 Cookie 或 Token |
| 检测结果全为"未发现问题" | 可能是：①目标确实很安全；②JS 是混淆/压缩过的，模式没匹配上 | 明确告知用户两种可能性，建议结合专业工具（OWASP ZAP/Burp Suite）二次验证 |

### 降级策略

当某个阶段无法完成时的降级方案：

1. **Phase 1 无法获取响应头**（WAF 完全拦截）→ 跳过头部分析，直接进入 Phase 2（如果能拿到 HTML）或提示用户提供页面源码
2. **Phase 2 无法下载子资源**（JS 文件 403）→ 仅对 HTML 内联脚本进行分析，标注「外部 JS 未下载，分析范围受限」
3. **Phase 3 匹配结果为零**→ 不要说「没有漏洞」，要说「基于静态规则未发现已知模式，但不代表绝对安全」，并列出扫描了哪些规则

## 与专业工具对比

| 维度 | Web SAST（本Skill） | OWASP ZAP | Burp Suite Professional |
|------|--------------------|-----------|------------------------|
| **类型** | AI驱动的静态分析 | 自动化DAST+代理 | 交互式DAST+代理 |
| **速度** | 30秒~2分钟 | 5-30分钟 | 手动操作，无上限 |
| **需要安装** | 不需要（curl + grep） | 需要Java环境 | 需要Java环境+付费许可证 |
| **检测深度** | 源码模式匹配 | 主动探测+被动爬取 | 完整渗透测试套件 |
| **擅长领域** | 快速初筛、代码级问题发现 | 自动化漏洞扫描 | 专业安全审计 |
| **误报率** | 中（纯模式匹配） | 低（有状态验证） | 很低（人工判断） |
| **适用场景** | 开发阶段自查、快速评估 | CI/CD集成安全门禁 | 合规测评、红队演练 |

**推荐组合使用**：先用 Web SAST 做 2 分钟快速初筛 → 发现问题后再用 ZAP 做深度验证 → 最终由安全专家用 Burp 做手工复核。

## FAQ

**Q: 扫描结果准确吗？会不会有误报？**  
A: 本 Skill 基于模式匹配（grep），存在一定的误报率。例如 `innerHTML` 在 React/Vue 的虚拟DOM中可能是安全的用法。每条发现我都会标注上下文，你需要结合业务逻辑判断是否真的构成风险。

**Q: 能扫描小程序吗？**  
A: 不能直接通过 URL 扫描小程序页面。但如果你有 `.wxapkg` 包文件或解包后的源码，可以对本地文件执行相同的模式匹配规则。参见「能力边界」中的说明。

**Q: 扫描会对目标网站造成影响吗？**  
A: 不会。本 Skill 只执行 `curl` GET 请求读取公开页面，等同于你在浏览器中访问该页面。不会提交任何表单、不会发送任何数据、不会触发任何写入操作。

**Q: 为什么有些大厂网站（如DeepSeek Chat）扫描结果很少？**  
A: 大型产品通常有完善的安全工程实践：代码混淆压缩（让模式匹配失效）、WAF防护（拦截自动化请求）、CSRFFull架构（无传统XSS面）、CSP严格配置等。扫描结果少不代表绝对安全，只是表面防御做得好。

**Q: 发现漏洞后怎么修？**  
A: 每条漏洞发现都会附带具体的修复代码示例（前后端都有）。如果需要完整的整改方案或等保合规咨询，可以基于扫描结果进一步讨论。

## 文件结构

```
web-sast/
├── SKILL.md                          ← 你正在读的主文档（流程+示例+FAQ）
├── references/
│   ├── rules.md                      ← 15条检测规则的完整 grep 模式库
│   ├── audit.sh                      ← 一键运行的 bash 自动化脚本
│   └── international-standards.md    ← agentSkills.io 国际规范论述
```

**首次使用**：读 SKILL.md 了解流程 → 给我一个 URL → 我按 4 个阶段执行扫描 → 输出 HTML 格式安全审计报告（浏览器打印即可导出 PDF）  
**日常使用**：直接给我 URL + 说一句"扫描一下"，我会自动加载本 Skill 并执行  
**进阶使用**：运行 `bash references/audit.sh <URL>` 在本地终端执行自动化扫描（输出原始日志到 audit_目录）
