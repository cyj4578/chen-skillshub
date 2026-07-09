---
name: mini-program-sast
description: Use when user provides a WeChat Mini Program AppID and asks about mini program security, vulnerabilities, source code audit, data leakage risks, wxapkg analysis, or whether a mini program stores sensitive data in plaintext. Also use when user wants to check a mini program for hardcoded keys, client-side logic bypass, storage security, or API endpoint exposure.
---

# Mini Program SAST

微信小程序前端静态安全扫描。用户提供 AppID → 自动定位本地缓存中的 `.wxapkg` 包 → 提取可读代码 → 模式匹配漏洞扫描 → 输出分级安全审计报告（**HTML 格式，浏览器打印即可导出 PDF**）。

## 核心能力

```
用户给 AppID → 我找缓存包 → 提取代码 → 出报告（Critical / High / Medium / Low）
```

**能做什么：**
- 扫描本地微信缓存中的小程序 `.wxapkg` 包
- 从二进制包中提取可读字符串进行模式匹配
- 检测小程序特有漏洞：`wx.setStorageSync` 明文存储、`wx.login` code 泄露、openId URL参数传递、硬编码凭证、Mock模式残留等
- 分析 API 端点、第三方SDK、支付安全配置
- 输出分级报告 + 每个漏洞的修复代码示例

**不能做什么：**
- ❌ 不扫描未在本地打开过的小程序（缓存中无 `.wxapkg` 文件）
- ❌ 不穿透小程序后端服务做渗透测试
- ❌ 不绕过微信加密传输层抓包
- ❌ 不解密经过自定义加密的 `.wxapkg` 包（部分分包使用了非标准加密）
- ❌ 不替代微信官方「小程序安全扫描」服务（`miniprogram-ci` 的 `analyse` 命令）

## 前置条件（⚠️ 用户必须满足）

**在使用本 Skill 之前，用户必须确保以下条件全部满足：**

| 条件 | 说明 | 如何验证 |
|------|------|----------|
| **① 小程序已在本地打开过** | 在 Mac/Windows 微信客户端中至少打开过一次该小程序 | 打开微信 → 搜索小程序 → 进入任意页面即可 |
| **② 本地缓存未被清理** | 微信缓存目录中存在该小程序的 `.wxapkg` 文件 | Skill 会自动检测路径是否存在 |
| **③ 提供正确的 AppID** | 小程序的唯一标识，通常为 `wx` 开头的 16 位字符串 | 两种获取方式见下方 |
| **④ Mac / Windows 电脑** | 需要访问本地文件系统，手机端无法使用本 Skill | — |

### AppID 获取方式

**方式一（后台查看）：** 登录微信公众平台 → 开发管理 → 开发设置 → AppID（需为小程序管理员或开发者）

**方式二（微信内查看）：** 点击小程序 → 点击右上角 `···` → 点击「小程序主页」/「简介」→ 在简介页面可看到 AppID（适用于任意小程序，无需管理员权限）

**缓存文件位置：**

| 操作系统 | 缓存路径 |
|---------|---------|
| **macOS（官网版微信）** | `~/Library/Containers/com.tencent.xinWeChat/Data/.wxapplet/packages/{AppID}/` |
| **macOS（AppStore 版微信）** | `~/Library/Containers/com.tencent.xinWeChat/Data/Documents/app_data/radium/users/*/applet/packages/{AppID}/` |
| **Windows** | `%USERPROFILE%\Documents\WeChat Files\Applet\{AppID}\` |

> ⚠️ **AppStore 版微信路径差异**：AppStore 沙盒版微信的缓存位于 `Data/Documents/app_data/radium/` 子路径下，且包含随机用户 ID 目录，需要用 `find` 命令广播搜索。Skill 会自动按顺序尝试：官网版路径 → AppStore 路径 → 全盘广播搜索。

每个 AppID 目录下有多个版本子目录（如 `/0/`、`/31/`、`/40/`、`/1835/`），每个子目录中包含 `__APP__.wxapkg`（主包）和可能存在的 `_pagesA_.wxapkg`、`_package_c_.wxapkg` 等分包。

## 触发条件

以下任一场景触发本 Skill：

| 用户说的话 | 触发 |
|-----------|------|
| "帮我扫描/审计一下这个小程序" | ✅ |
| "这个 AppID `wx...` 有没有安全漏洞" | ✅ |
| "检测小程序有没有密钥泄露" | ✅ |
| "小程序源码安全审计" | ✅ |
| "小程序等保 / 安全合规检查" | ✅ |
| "帮我看看这个小程序的代码" | ✅ |

**不触发的场景：**
- 用户只问概念性问题（"小程序有哪些安全风险"）→ 用解释/教学方式回答，不需要加载本 Skill
- 用户提供的不是 AppID（如 URL）→ 应使用 `web-sast` Skill
- 用户要求修改/修复小程序代码 → 本 Skill 只负责发现，修复用其他编码方式

## 工作流程

### Phase 0: 前置条件检查（约 5 秒）

确认用户电脑上存在目标小程序的缓存包。

```bash
# macOS 官网版检查
ls ~/Library/Containers/com.tencent.xinWeChat/Data/.wxapplet/packages/{AppID}/

# macOS AppStore 版检查（广播搜索）
find ~/Library/Containers/com.tencent.xinWeChat/Data/Documents/app_data/radium -name "*.wxapkg" -path "*{AppID}*"

# Windows 检查（PowerShell）
ls "$env:USERPROFILE\Documents\WeChat Files\Applet\{AppID}\"
```

**如果目录不存在** → 告知用户：
- 可能的原因：①未在电脑微信中打开过该小程序；②微信缓存被清理过；③ AppID 不正确
- 如果 AppStore 路径也未找到，执行全盘广播搜索：`find ~/Library/Containers/com.tencent.xinWeChat -name "*.wxapkg" -path "*{AppID}*"`
- 解决步骤：打开电脑微信 → 搜索小程序 → 进入小程序 → 任意浏览几个页面 → 退出小程序 → 回到本 Skill 重试

**如果目录存在但为空** → 告知用户：目录存在但无线程包文件，可能是微信版本差异，尝试更新微信到最新版。

### Phase 1: wxapkg 定位与提取（约 10 秒）

找到最新的 `.wxapkg` 包文件，从二进制中提取可读字符串。

```bash
# 1. 找到所有 wxapkg 文件
find ~/Library/Containers/com.tencent.xinWeChat/Data/.wxapplet/packages/{AppID}/ -name "*.wxapkg" -type f

# 2. 提取可读字符串（核心步骤）
# strings 命令从二进制文件中提取连续4个以上的可打印字符
# 行数上限 200,000 行，防止大文件占用过多内存
strings __APP__.wxapkg | head -200000 > extracted_strings.txt
```

**wxapkg 格式说明：**
- 标准格式：文件头 `V1MMWX`，支持用 `unveilr` 工具完整解包
- WMPF 格式：微信小程序框架的专用二进制格式（较新的小程序多用此格式），`strings` 仍可提取大部分可读内容
- 主包：`__APP__.wxapkg`（通常 2-6 MB）
- 分包：`_pagesA_.wxapkg`、`_pagesB_.wxapkg` 等（可选）

**关于 unveilr（可选增强）：**
如果需要完整解包获得独立 JS 文件（而非 strings 提取的碎片化文本），可安装 `unveilr`：
```bash
npm install -g unveilr
unveilr unpack __APP__.wxapkg -o unpacked/
```
注意：本 Skill 的默认流程使用 `strings`（系统自带，零安装），足以覆盖 90% 以上的漏洞检测需求。

### Phase 2: 深度扫描（核心）

使用 `references/rules.md` 中的小程序专用检测规则对所有提取的字符串进行模式匹配。

**小程序特有扫描矩阵：**

| 编号 | 检测项 | 严重度 | 说明 |
|------|--------|--------|------|
| CRIT-01 | wx.setStorageSync 明文存储凭证 | Critical | token/密码明文落在本地存储 |
| CRIT-02 | wx.login code 被持久化存储 | Critical | 一次性 code 被 setStorageSync 保存 |
| CRIT-03 | openId / unionId 通过 URL 参数传递 | Critical | 页面跳转/navigateTo 的 query 参数含 openId |
| CRIT-04 | AppSecret / 支付密钥硬编码 | Critical | 前端代码中出现服务端密钥 |
| CRIT-05 | Mock 模式在生产环境残留 | Critical | useMock / mockEnabled 被设为 true |
| HIGH-01 | console.log 打印敏感数据 | High | token/code/openId/phone 被输出到控制台 |
| HIGH-02 | API 请求参数含明文敏感信息 | High | wx.request 的 data 中直接传身份证/密码 |
| HIGH-03 | 支付签名使用 MD5 | High | signType: "MD5"（应使用 HMAC-SHA256） |
| HIGH-04 | 非 HTTPS 的 API 请求 | High | wx.request 的 URL 使用 http:// |
| HIGH-05 | 不安全的页面跳转 | High | navigateTo 的目标 URL 来自用户输入 |
| MED-01 | wx.getUserInfo 直接获取用户信息 | Medium | 未先判断授权状态 |
| MED-02 | 表单输入无长度/格式校验 | Medium | input 无 maxlength/pattern 属性 |
| MED-03 | setStorageSync 无容量检查 | Medium | 大量数据写入可能超出 10MB 限制 |
| LOW-01 | 低版本基础库依赖 | Low | libVersion 低于 2.0.0 |
| LOW-02 | 调试代码残留 | Low | debugger; / wx.setEnableDebug 在生产中启用 |

### Phase 3: 报告生成（HTML → 浏览器打印导出 PDF）

扫描完成后，生成一份**结构化 HTML 安全审计报告**。报告使用 print-friendly CSS（`@page { size: A4; }` + `@media print`），用户可通过浏览器 `Ctrl+P / Cmd+P` →「另存为 PDF」一键导出为 PDF 文件。

**报告固定包含十大章节（按顺序）：**

| 章节 | 标题 | 内容 |
|------|------|------|
| 一 | 执行摘要 | 四色统计卡片（严重/高危/中危/安全正项数量）+ 加密/受限提示 |
| 二 | 目标信息 | AppID、扫描时间、缓存路径、分包数量、包体大小、代码可读性 |
| 三 | 扫描流程回顾 | Phase 0→3 每步通过/受限状态 + 简要说明 |
| 四 | 包体详细分析 | 文件名、大小、魔数、版本号、熵值、加密状态表格 |
| 五 | 安全检测覆盖 | 每项检测规则 × 每个包的命中数矩阵表格 |
| 六 | 发现与评估 | 逐条 finding（正面/信息/警告），每条带 tag 标签 + 详细说明 |
| 七 | 风险评级 | 四色风险统计表 + 总体风险评级 + 加密受限声明 |
| 八 | 与其他已审计小程序的对比 | 特征对比表（加密状态/熵值/版本号/源码泄露风险） |
| 九 | 建议与后续行动 | 编号建议表，每条带优先级标签 |
| 十 | 审计局限性声明 | 声明基于的方法、不覆盖的范围、加密不是绝对安全 |

**报告 HTML 必须包含以下 CSS 打印样式：**
```css
@page { size: A4; margin: 20mm; }
@media print { body { padding: 20px; } }
```

**交付物**：`.html` 文件保存到 artifacts 目录，文件名格式：`mini-program-sast-report-{AppID}.html`。用户可通过浏览器打开后打印为 PDF。

**报告示例参考**：见示例 AppID（`wx00000000000000`，已脱敏）的审计报告 — 该报告完整展示了加密场景下的十大章节结构、包体分析表、熵值检测、受限声明、对比分析和建议表。后续所有报告以此为模板。

> ⚠️ **重要**：报告中不得包含任何真实小程序的 AppID、域名、OpenID、API 端点等可追溯到具体业务的数据。所有示例信息必须脱敏。

## 异常处理指南

扫描过程中可能遇到的问题及解决方案：

### 常见异常

| 错误现象 | 原因 | 解决方法 |
|----------|------|----------|
| 缓存目录不存在 | 未在电脑微信中打开过该小程序，或 AppID 不正确 | ① 确认 AppID 正确（微信公众平台后台查看）；② 打开电脑微信 → 搜索小程序 → 进入并浏览几个页面 → 退出后重试 |
| 目录存在但无 `.wxapkg` 文件 | 微信版本差异导致缓存位置不同，或缓存已被清理 | ① 更新微信到最新版；② 尝试 `find ~/Library -name "*.wxapkg" -path "*AppID*"` 扩大搜索范围 |
| `strings` 提取不到有效内容 | `.wxapkg` 启用了微信「代码保护」加密（熵值 > 95%，版本号 ≥ 29），strings 输出仅有二进制噪声 | 确认加密状态（检查熵值 + 版本号），告知用户：① 这是微信官方安全特性，能有效防源码泄露；② 静态字符串扫描无法穿透加密；③ 建议通过微信官方「小程序安全扫描」工具做补充审计（该工具在服务端有解密能力） |
| 提取的字符串碎片化严重 | WMPF 格式下 JS 代码被拆分为短片段 | 仍可进行模式匹配，但告知用户匹配结果可能不完整；建议安装 `unveilr` 做完整解包 |
| `strings` 输出超过 200,000 行 | 主包较大（>8 MB）或包含了大量第三方库 | 用 `head` 截断到 200,000 行（通常足够覆盖所有自定义代码）；告知用户大包可能无法扫描所有第三方库代码 |
| 发现 `.wxapkg` 文件头不是 `V1MMWX` | 使用 WMPF（微信小程序框架）格式 | 使用 `strings` 命令提取（不依赖文件头格式）；告知用户 WMPF 格式下提取效率可能略低于标准格式 |
| 分包 `_pagesA_.wxapkg` 内容无法提取 | 分包使用了独立加密或压缩 | 告知用户分包分析受限，但主包的扫描结果通常已覆盖大部分安全风险 |
| 扫描结果全为"未发现问题" | ① 小程序安全实践较好；② `strings` 提取范围不完整；③ 代码做了混淆压缩 | 明确告知三种可能性，建议安装 `unveilr` 做完整解包后再次扫描 |

### 降级策略

当某个阶段无法完成时的降级方案：

1. **Phase 0 找不到缓存** → 给出详细的操作步骤引导用户在电脑微信中打开小程序；如果用户坚持继续，询问是否愿意提供 `.wxapkg` 文件路径或解包后的源码目录
2. **Phase 1 提取字符数 < 5000 行** → 告知用户提取的内容偏少（可能包很小或有加密），扫描结果将标注「低置信度」
3. **Phase 2 匹配结果为零**→ 不要说「没有漏洞」，要说「基于静态字符串匹配未发现已知模式，但不代表绝对安全。建议：① 安装 unveilr 完整解包；② 使用微信官方安全扫描工具；③ 进行后端渗透测试」
4. **分包未提取** → 在主包扫描完成后，明确标注「本次仅扫描了主包，分包 `_pagesA_.wxapkg` 未分析」

## 与微信官方工具对比

| 维度 | Mini Program SAST（本Skill） | 微信官方安全扫描 |
|------|---------------------------|----------------|
| **类型** | AI驱动的静态字符串分析 | 自动化扫描服务 |
| **速度** | 1~3 分钟 | 5~30 分钟 |
| **需要上传源码** | 不需要（使用本地缓存包） | 需要（通过 miniprogram-ci 或开发者工具上传） |
| **检测深度** | 字符串模式匹配 + AI 语义理解 | API 调用链分析、数据流追踪 |
| **依赖** | 系统 `strings` 命令 + grep | 微信开发者工具 / `miniprogram-ci` |
| **适用场景** | 快速初筛、第三方代码审计、应急排查 | 正式发版前的安全门禁、合规检查 |
| **覆盖范围** | 所有本地缓存过的任意小程序 | 仅限自己有上传权限的小程序 |

**推荐组合使用**：先用本 Skill 做 2 分钟快速初筛 → 发现问题后在开发者工具中用官方扫描做深度验证 → 修复后走 CI/CD 集成安全门禁。

## FAQ

**Q: 为什么需要「在电脑上打开过」这个前置条件？**  
A: 小程序包（`.wxapkg`）是由微信客户端在用户首次打开小程序时下载并缓存到本地的。本 Skill 不通过微信服务器直接下载包文件（技术上不可行，微信对包下载做了签名验证），所以需要利用电脑微信客户端的本地缓存。这也意味着：你只能扫描自己使用过的小程序。

**Q: 扫出漏洞后怎么修？小程序包是加密的吗？能直接改吗？**  
A: `.wxapkg` 是小程序开发者上传到微信后台的编译产物。你不能直接修改本地的 `.wxapkg` 文件——它只是缓存副本。修复需要在**源码层面**进行，在微信开发者工具中修改 `.js` / `.wxml` / `.wxss` 源码后重新上传。本 Skill 提供的修复代码示例都是源码层面的，可以直接拷贝到你的开发者工具中使用。

**Q: `strings` 提取的文本看起来很乱，是不是没提取到关键代码？**  
A: 正常现象。`.wxapkg` 是二进制包，`strings` 会提取所有连续的可打印字符串——包括 JS 代码、WXML 模板、CSS 样式、配置 JSON、API 端点、第三方库名等。虽然碎片化，但模式匹配针对的就是关键字符串（如 `setStorageSync`、`console.log`、URL 模式等），碎片化不影响检测效果。

**Q: 这个扫描会给小程序开发者发送请求吗？会被发现吗？**  
A: 不会。本 Skill 的扫描过程完全离线——只读取本地缓存文件，不向微信服务器或小程序后端发送任何网络请求。扫描行为不会被开发者或微信平台感知。

**Q: 能分析小程序的云开发（CloudBase）配置吗？**  
A: 如果云开发的初始化代码（`wx.cloud.init`）和环境 ID 出现在主包中，可以通过 `strings` 提取到。但云函数的源码存储在云端，不在 `.wxapkg` 中，无法通过本 Skill 分析。

**Q: 第三方小程序（不是我开发的）可以扫描吗？**  
A: 技术上可以，只要你在电脑微信中打开过它。但请注意：① 扫描结果用于安全研究和自查目的；② 不应利用发现的安全漏洞攻击第三方服务；③ 如发现严重漏洞，建议通过微信安全应急响应中心（WSRC）报告。

## 文件结构

```
mini-program-sast/
├── SKILL.md                          ← 你正在读的主文档（流程+示例+FAQ）
├── references/
│   ├── rules.md                      ← 小程序专用检测规则（grep 模式库）
│   └── audit.sh                      ← 一键运行的 bash 自动化脚本
```

**首次使用**：读 SKILL.md 了解前置条件和流程 → 确认已在电脑微信中打开过目标小程序 → 给我 AppID → 我按 4 个阶段执行扫描 → 输出 HTML 格式安全审计报告（浏览器打印即可导出 PDF）  
**日常使用**：直接给我 AppID + 说一句"扫描一下"，我会自动加载本 Skill 并执行  
**进阶使用**：运行 `bash references/audit.sh <AppID>` 在本地终端执行自动化扫描（仅支持 macOS）
