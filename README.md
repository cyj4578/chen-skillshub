# 🛠️ Chen Skills Hub

> 陈氏 Skills 工具箱 —— 个人 AI 技能合集 / Personal AI Skill Collection

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 📦 技能列表 / Skill List

| Skill | 简介 / Description |
|-------|---------------------|
| 🐍 [chen-python-skills](./chen-python-skills/) | Python 基础语法库，覆盖 30+ 核心主题 |
| 🕸️ [chen-knowledge-web](./chen-knowledge-web/) | 知识组网扩展器，5 维网状展开 |
| 📋 [chen-prd-skills](./chen-prd-skills/) | PRD 书写规范，10 章标准结构 + 标识体系 + 模板 |
| 🧪 [prd-test-skills](./prd-test-skills/) | PRD 测试工程，逻辑审查 + 场景穷举 + 漏洞检测 |

---

## 🔗 独立仓库 / Standalone Repos

| 项目 / Project | 仓库 / Repo | 简介 / Description |
|------|------|------|
| 🎯 **pm-agent** | [cyj4578/pm-agent](https://github.com/cyj4578/pm-agent) | 通用 PM 流程编排引擎 — 8 模块 DAG 工作流 |

---

## 📋 各 Skill 详情 / Skill Details

### 🐍 chen-python-skills — Python 基础语法库 / Python Fundamentals

| 类别 / Category | 覆盖主题 / Topics |
|------|----------|
| 基础 / Basics | 数据类型、字符串操作、运算符 |
| 容器 / Containers | 列表、元组、字典、集合 |
| 控制 / Control | 条件语句（if/elif/else）、循环（for/while） |
| 函数 / Functions | 定义、参数、返回值、作用域、lambda/map/filter/reduce |
| 进阶 / Advanced | 装饰器、生成器与迭代器、推导式 |
| 面向对象 / OOP | 类、实例、继承、多态、封装、魔术方法 |
| 工程 / Engineering | 模块与包、文件 IO、异常处理、类型提示、标准库 |

### 🕸️ chen-knowledge-web — 知识组网扩展器 / Knowledge Web Expander

| 能力 / Capability | 说明 / Description |
|------|------|
| 5 维展开 / 5-Dimension | 横向扩展 / 纵向深挖（至少 3 层）/ 背景来源 / 典故出处 / 产生影响 |
| 同名消歧 / Disambiguation | 自动识别同名实体，逐一独立展开 |
| 时间线补充 / Timeline | 历史类知识点自动补充同期全球大事件（金融 / 技术 / 政治 / 文化） |
| 递归深挖 / Recursive | 每个子节点可继续展开，知识量指数增长 |
| 扩展能力 / Extras | 同功效替代品对比、副作用/风险分析、产业链上下游扩展 |

### 📋 chen-prd-skills — PRD 书写规范 / PRD Writing Spec

| 能力 / Capability | 说明 / Description |
|------|------|
| 10 章标准结构 / Structure | 问题陈述 → 目标 → 非目标 → 用户故事 → 需求详情 → 成功指标 → 开放问题 → 时间计划 → 依赖与风险 → 附录 |
| 标识规范 / IDs | US-XX（用户故事）/ FR-XX（功能）/ NFR-XX（非功能）/ G-XX（目标）/ Q-XX（问题） |
| 4 级优先级 / Priority | P0 必须有 → P1 应该有 → P2 可以有 → P3 未来考虑 |
| 10 项评审清单 / Checklist | 结构完整性、可测试性、风险覆盖等提交前自查 |
| 配套资源 / Resources | 空白 PRD 模板 + 书写指南 + 完整规范说明（含示例） |
| 联动 / Integration | 可与 `prd-test-skills` 联动：书写 → 自检 → 评审 |

### 🧪 prd-test-skills — PRD 测试工程 / PRD Test Engineering

| 能力 / Capability | 说明 / Description |
|------|------|
| 审查维度 / Review | 结构完整性 + 业务真实性 + 逻辑一致性 + 场景完整性 + 数据与权限 + 可测试性，共 ~55 个检查点 |
| 场景穷举 / Scenarios | 正常 / 边界 / 异常 / 并发 / 状态转换 5 类场景全覆盖 |
| 漏洞检测 / Gap Detection | 常见 PRD 漏洞模式（条件缺失、状态遗漏、并发冲突等） |
| 输出报告 / Output | 分级报告（Critical / Major / Minor）+ 逐项修复建议 + 可复用的审查报告模板 |

---

## ⚡ 快速开始 / Quick Start

```bash
# 克隆全部技能 / Clone all skills
git clone https://github.com/cyj4578/chen-skillshub.git

# SSH（推荐国内用户）/ SSH (recommended for users in China)
git clone git@github.com:cyj4578/chen-skillshub.git
```

将目标 Skill 的 `SKILL.md` 加载到任意兼容 OpenClaw 的 AI 工具中即可使用（WorkBuddy、Cursor、Codex、Claude Code 等）。

Load any skill's `SKILL.md` into an OpenClaw-compatible AI tool (WorkBuddy, Cursor, Codex, Claude Code, etc.).

---

## 📄 许可证 / License

[MIT License](LICENSE)

---

## 📮 联系方式 / Contact

- **GitHub**：[cyj4578](https://github.com/cyj4578)
- **pm-agent**：[cyj4578/pm-agent](https://github.com/cyj4578/pm-agent)
