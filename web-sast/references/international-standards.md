# 国际 Skill 编写规范论述文档

## 摘要

本文档论述如何按照 agentSkills.io 国际规范编写可移植、可复用的 AI Agent Skill，并以 `web-sast` skill 为例说明实践方法。

---

## 1. agentSkills.io 规范概述

agentSkills.io 是一个开放标准，用于定义 AI Agent 可调用的技能（Skill）的元数据格式和发现机制。其目标是实现跨平台、跨模型的技能共享与互操作。

### 1.1 核心原则

1. **可发现性（Discoverability）**：Skill 必须能被 Agent 通过语义搜索准确找到
2. **可移植性（Portability）**：Skill 应不依赖特定平台或模型
3. **最小意外原则（Principle of Least Surprise）**：Skill 的行为应符合用户和 Agent 的预期
4. **单一职责（Single Responsibility）**：每个 Skill 应专注于一个明确的功能领域

---

## 2. SKILL.md 结构规范

### 2.1 Frontmatter（前置元数据）

必须包含以下字段：

```yaml
---
name: skill-name-in-kebab-case
description: Use when [具体的触发条件描述，用第三人称]
---
```

#### name 字段规范
- 只允许：字母（a-z）、数字（0-9）、连字符（-）
- 不允许：空格、下划线、括号、特殊字符
- 格式：kebab-case（小写，单词间用连字符连接）
- 示例：`web-sast`、`test-driven-development`、`security-scan`

#### description 字段规范（**最关键**）
- **必须用第三人称描述**
- **必须以 "Use when..." 开头**
- **只能描述触发条件，不能描述工作流程**
- **不能总结 Skill 的功能或执行步骤**
- 长度：尽量控制在 500 字符以内，最多不超过 1024 字符
- 目的：让 Agent 判断"现在应该加载这个 Skill 吗？"

**❌ 错误示例**（描述了工作流程）：
```yaml
description: Use when auditing web security - fetches page source, extracts JS, scans for vulnerabilities, and generates report
```

**✅ 正确示例**（只描述触发条件）：
```yaml
description: Use when user provides a URL and asks about web security, vulnerabilities, penetration testing, code audit, XSS, CSRF, security headers, SSL/TLS configuration, hardcoded secrets, or front-end security scanning.
```

#### 为什么 description 不能描述工作流程？
测试表明：当 description 总结了工作流程时，Agent 可能会**直接按照 description 执行**，而不去读取 SKILL.md 的完整内容。这导致：
- Agent 跳过重要的细节和边缘情况处理
- Agent 按照不完整的信息执行任务
- Skill 的完整逻辑被忽略

---

### 2.2 正文结构规范

```
SKILL.md
├── 概述（1-2句话，说明这个 Skill 是什么）
├── 触发条件（何时使用这个 Skill）
├── 核心模式（技术细节、代码示例）
├── 快速参考（表格或列表，便于扫描）
├── 实现细节（如有必要）
├── 常见错误（坑和解决方案）
└── 实际影响（可选，展示效果）
```

#### 2.2.1 概述
- 用 1-2 句话说明 Skill 的用途
- 不要用"我可以帮助你..."这样的第一人称
- 示例：`Static Application Security Testing for web frontends.`

#### 2.2.2 触发条件
- 用项目符号列出所有触发场景
- 包括：用户可能说的关键词、症状描述、使用场景
- 也可以包括"何时**不**使用"（边界情况）

#### 2.2.3 核心模式
- 展示 before/after 代码对比
- 只展示最关键的模式，不要面面俱到
- 代码例子要**完整可运行**，不要模板化的伪代码

#### 2.2.4 快速参考
- 用表格或列表展示常用操作
- 便于 Agent 快速查找信息
- 不要重复核心模式中的内容

#### 2.2.5 常见错误
- 列出常见的误用方式和解决方案
- 用实际例子说明

---

## 3. Token 效率规范（关键）

Skill 的 SKILL.md 会被注入到 Agent 的上下文中。Token 数量直接影响：
- Agent 的响应速度
- 其他信息的可用上下文空间
- API 调用成本

### 3.1 Token 预算

| Skill 类型 | 目标 Token 数 |
|------------|----------------|
| 高频加载的 Skill（如 getting-started 流程） | < 150 词 |
| 常用 Skill | < 200 词 |
| 其他 Skill | < 500 词 |

### 3.2 Token 优化技巧

#### 3.2.1 移动到工具帮助文档
```markdown
❌ 错误：在 SKILL.md 中列出所有命令行参数
search-conversations supports --text, --both, --after DATE, --before DATE, --limit N

✅ 正确：引用 --help
search-conversations supports multiple modes and filters. Run --help for details.
```

#### 3.2.2 使用交叉引用
```markdown
❌ 错误：重复另一个 Skill 的工作流程细节
When searching, dispatch subagent with template...
[20 行重复的指导]

✅ 正确：引用其他 Skill
Always use subagents (50-100x context savings). REQUIRED: Use [other-skill-name] for workflow.
```

#### 3.2.3 压缩示例
```markdown
❌ 错误： verbose 示例（42 词）
your human partner: "How did we handle authentication errors in React Router before?"
You: I'll search past conversations for React Router authentication patterns.
[Dispatch subagent with search query: "React Router authentication error handling 401"]

✅ 正确：最小示例（20 词）
Partner: "How did we handle auth errors in React Router?"
You: Searching...
[Dispatch subagent → synthesis]
```

#### 3.2.4 消除冗余
- 不要重复官方文档中已有的内容
- 不要为同一模式提供多个几乎相同的示例
- 不要包含"如何打开文件"这类基础操作的说明

---

## 4. 关键词优化（CSO - Claude Search Optimization）

Agent 通过语义搜索找到相关的 Skill。为了让你的 Skill 被正确发现，需要在 description 和正文中合理使用关键词。

### 4.1 关键词类型

| 类型 | 示例 |
|------|------|
| 错误消息 | "Hook timed out", "ENOTEMPTY", "race condition" |
| 症状描述 | "flaky", "hanging", "zombie", "pollution" |
| 同义词 | "timeout/hang/freeze", "cleanup/teardown/afterEach" |
| 工具名称 | 实际的命令、库名、文件名 |

### 4.2 描述性命名

使用**主动语态、动词优先**的名称：
- ✅ `creating-skills`（创建技能）
- ✅ `condition-based-waiting`（基于条件的等待）
- ✅ `root-cause-tracing`（根因追踪）
- ❌ `skill-creation`（技能创建，名词化）
- ❌ `async-test-helpers`（异步测试助手，描述模糊）

对于流程类 Skill，使用 **-ing 形式**：
- `creating-skills`, `testing-skills`, `debugging-with-logs`

---

## 5. web-sast Skill 规范符合性分析

### 5.1 name 字段
```yaml
name: web-sast
```
- ✅ 符合规范：只含字母和连字符
- ✅ 格式正确：kebab-case
- ✅ 语义清晰：web（应用领域）+ sast（技术缩写）

### 5.2 description 字段
```yaml
description: Use when user provides a URL and asks about web security, vulnerabilities, penetration testing, code audit, XSS, CSRF, security headers, SSL/TLS configuration, hardcoded secrets, or front-end security scanning.
```
- ✅ 以 "Use when..." 开头
- ✅ 只描述触发条件，不描述工作流程
- ✅ 使用了第三人称
- ✅ 包含了丰富的关键词（XSS, CSRF, SSL/TLS 等）
- ✅ 长度适中（约 300 字符）

### 5.3 正文结构
- ✅ 有概述（1 句话）
- ✅ 有触发条件列表
- ✅ 有工作流程说明（Phase 1-4）
- ✅ 有输出格式说明
- ✅ 有自动化脚本引用

### 5.4 Token 效率
- ✅ 正文约 400 词，符合 < 500 词的目标
- ✅ 检测规则移到 `references/rules.md`，不重复
- ✅ 脚本引用 `references/audit.sh`，不内联代码

---

## 6. 跨平台可移植性

为了让 Skill 可以被其他工具使用，需要遵循：

### 6.1 路径规范
- ✅ 使用相对路径引用同级文件：`references/rules.md`
- ✅ 不使用绝对路径：`/Users/ms.chen/...`
- ✅ 不使用平台特定路径：`C:\Users\...`

### 6.2 工具依赖规范
- ✅ 只依赖常见命令行工具：`curl`, `openssl`, `grep`, `bash`
- ✅ 在 SKILL.md 中说明依赖
- ✅ 提供备选方案或安装指南

### 6.3 编码规范
- ✅ 使用 UTF-8 编码
- ✅ 使用 Unix 风格换行符（LF）
- ✅ 不使用 BOM

---

## 7. 质量检查清单

在完成 Skill 编写后，使用以下清单进行自查：

### 7.1 Frontmatter 检查
- [ ] name 只包含字母、数字、连字符
- [ ] description 以 "Use when..." 开头
- [ ] description 只描述触发条件，不描述工作流程
- [ ] description 使用了第三人称
- [ ] description 长度 < 1024 字符

### 7.2 内容检查
- [ ] 有清晰的概述（1-2 句话）
- [ ] 有触发条件列表
- [ ] 代码示例完整可运行
- [ ] 没有冗余内容
- [ ] 正确使用了交叉引用

### 7.3 Token 效率检查
- [ ] 正文词数 < 500（或符合对应类型的预算）
- [ ] 大段参考材料已移到单独文件
- [ ] 没有多个几乎相同的示例

### 7.4 可移植性检查
- [ ] 只使用相对路径
- [ ] 只依赖常见工具
- [ ] 使用 UTF-8 编码

---

## 8. 测试规范（TDD for Skills）

根据 `writing-skills` Skill 的规范，编写 Skill 必须遵循 **RED-GREEN-REFACTOR** 循环：

### 8.1 RED 阶段：编写失败的测试
1. 在不加载 Skill 的情况下，用压力场景测试 Agent
2. 记录 Agent 的准确行为（逐字记录）
3. 识别 Agent 使用的合理化借口（rationalizations）

### 8.2 GREEN 阶段：编写最小化的 Skill
1. 编写能解决 RED 阶段发现问题的 Skill
2. 不要添加假设性的内容
3. 用相同的场景测试，Agent 应该现在能正确遵循 Skill

### 8.3 REFACTOR 阶段：关闭漏洞
1. 在测试中发现新的合理化借口
2. 在 Skill 中添加明确的反驳
3. 重新测试直到完全合规

### 8.4 禁忌
- ❌ 不允许"先写 Skill，后测试"
- ❌ 不允许"这很明显不需要测试"
- ❌ 不允许"我是高级开发人员，我知道怎么做"

---

## 9. 总结

遵循 agentSkills.io 国际规范编写的 Skill 具有：
1. **高可发现性**：Agent 能准确判断何时加载
2. **高可移植性**：不依赖特定平台或模型
3. **高 Token 效率**：节省上下文空间
4. **高可维护性**：结构清晰，易于更新

`web-sast` Skill 作为示例，展示了如何实践这些规范。通过持续遵循这些原则，可以建立起高质量的 Skill 生态系统。

---

## 附录：参考资料

1. [agentSkills.io Specification](https://agentskills.io/specification)
2. Anthropic Best Practices for Skill Authoring
3. Test-Driven Development Applied to Process Documentation (writing-skills Skill)
4. [graphviz-conventions.dot](跨引用) - Graphviz 图表样式规则
5. [testing-skills-with-subagents.md](跨引用) - 使用子 Agent 测试 Skill 的完整方法
