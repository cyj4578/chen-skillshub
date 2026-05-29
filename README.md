# 🛠️ Chen Skills Hub

> 陈氏 Skills 工具箱 —— 产品思维 × 技术实现 × 知识组网

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## 📦 技能列表

| Skill | 版本 | 类型 | 简介 |
|-------|------|------|------|
| 📋 [chen-prd-skills](./chen-prd-skills/) | `1.0.0` | 产品文档 | 标准化 PRD 书写规范（10 章结构 + 模板 + 优先级 + Checklist） |
| 🔍 [chen-te-skills](./chen-te-skills/) | `1.0.0` | 质量评审 | PRD 测试评审（5 大维度 + 33 项检查 + 结构化报告） |
| 🐍 [chen-python-skills](./chen-python-skills/) | `1.0.0` | 编程参考 | Python 基础语法库（30+ 核心主题 + 完整手册） |
| 🕸️ [chen-knowledge-web](./chen-knowledge-web/) | `1.0.0` | 知识工具 | 知识组网扩展器（5 维展开 + 同名消歧 + 时间线 + 产业链） |

---

## ⚡ 快速开始

### 方式一：Git Clone（安装全部）

```bash
git clone https://github.com/cyj4578/chen-skillshub.git
```

### 方式二：ClawHub 安装（单个）

```bash
clawhub install chen-prd-skills
clawhub install chen-te-skills
clawhub install chen-python-skills
clawhub install chen-knowledge-web
```

### 方式三：手动安装

下载对应目录到本地 skills 目录 `<skill-name>/`

---

## 🔗 Skill 联动工作流

### PRD 全流程

```
┌─────────────────────┐
│  chen-prd-skills    │  ← 书写：获取模板 + 按规范编写
│  (PRD 书写规范)      │
└────────┬────────────┘
         ↓
┌─────────────────────┐
│  chen-te-skills     │  ← 审查：33 项系统检查 + 漏洞检测
│  (PRD 测试评审)      │
└────────┬────────────┘
         ↓
┌─────────────────────┐
│  修复问题 → 提交评审  │  ← 闭环：基于审查报告迭代修复
└─────────────────────┘
```

---

## 📋 各 Skill 详情

### 1. chen-prd-skills — 产品需求文档书写规范

**触发词**：`PRD`、`产品需求`、`需求文档`、`写需求`、`用户故事`、`功能需求`

| 能力 | 说明 |
|------|------|
| 10 章标准结构 | 问题陈述 → 目标 → 非目标 → 用户故事 → 需求详情 → 成功指标 → 开放问题 → 时间计划 → 依赖与风险 → 附录 |
| 需求标识规范 | US-XX / FR-XX / NFR-XX / G-XX / Q-XX |
| 4 级优先级 | P0（核心必交付）→ P1（本期计划）→ P2（按资源决定）→ P3（未来考虑）|
| 10 项评审 Checklist | 提交前自检清单，确保文档质量 |
| 3 份参考文档 | 规范说明 + 书写指南 + 空白模板 |

### 2. chen-te-skills — PRD 测试评审技能

**触发词**：`审查PRD`、`评审PRD`、`检测漏洞`、`测试PRD`、`需求评审`、`PRD质量检查`

| 能力 | 说明 |
|------|------|
| 5 大审查维度 | 结构完整性 / 逻辑一致性 / 需求完整性 / 可测试性 / 风险完整性 |
| 33 项系统检查 | 逐一覆盖所有漏洞类型 |
| 4 级漏洞等级 | 🔴 P0 严重 / 🟠 P1 重要 / 🟡 P2 一般 / 🔵 P3 提示 |
| 结构化报告 | 概览 → 问题清单 → 修复建议 → 改进优先级 |
| 3 份参考文档 | 审查清单 + 常见漏洞类型 + 报告模板 |

### 3. chen-python-skills — Python 基础语法库

**触发词**：`Python语法`、`列表`、`字典`、`函数`、`类`、`继承`、`装饰器`、`生成器`、`lambda`、`列表推导式`、`异常处理`、`文件读写`

| 类别 | 覆盖主题 |
|------|----------|
| 基础 | 数据类型、字符串操作、运算符 |
| 容器 | 列表、元组、字典、集合 |
| 控制 | 条件语句（if/elif/else）、循环（for/while） |
| 函数 | 定义、参数、返回值、作用域、lambda/map/filter/reduce |
| 进阶 | 装饰器、生成器与迭代器、推导式 |
| 面向对象 | 类、实例、继承、多态、封装、魔术方法 |
| 工程 | 模块与包、文件 IO、异常处理 |
| 工具 | 常用内置函数、标准库（os/sys/json/datetime/collections）、类型提示 |

### 4. chen-knowledge-web — 知识组网扩展器（陈氏知识网）

**触发词**：`组网`、`扩散`、`知识点扩展`、`知识网络`、`知识图谱`、`展开讲讲`、`深挖`、`横向对比`、`同一时间线`、`同名`、`多义`、`查一下这个人`、`帮我理一下`、`梳理知识`

| 能力 | 说明 |
|------|------|
| 5 维展开 | 横向扩展 / 纵向深挖 / 背景来源 / 典故出处 / 产生影响 |
| 同名消歧 | 自动识别同名实体，逐一独立展开（如"张总"→5 位企业家分别组网） |
| 时间线补充 | 历史类知识点自动补充同期全球大事件（金融/技术/政治/文化） |
| 风险分析 | 产品/技术类自动补充副作用、反作用、风险清单 |
| 产业链扩展 | 工业/农业类自动补充上下游关联 |
| 递归深挖 | 每个子节点可继续展开，知识量指数增长 |

### 🔗 知识组网工作流

```
┌─────────────────────┐
│  输入知识点           │  ← 概念/术语/现象/人名
└────────┬────────────┘
         ↓
┌─────────────────────┐
│  同名多义判断         │  ← 如有多个同名实体则逐一展开
└────────┬────────────┘
         ↓
┌─────────────────────┐
│  5 维网状展开         │  ← 横向 + 纵向 + 背景 + 典故 + 影响
└────────┬────────────┘
         ↓
┌─────────────────────┐
│  专项补充             │  ← 时间线 / 副作用 / 产业链（按需）
└────────┬────────────┘
         ↓
┌─────────────────────┐
│  递归深挖（可选）      │  ← 选择子节点继续展开
└─────────────────────┘
```

---

## 🚀 发布到 ClawHub

本仓库内的 Skill 均符合 [ClawHub 发布规范](https://docs.openclaw.ai/clawhub/skill-format)。

### 发布命令

```bash
# 安装 ClawHub CLI
npm install -g clawhub

# 登录（需 GitHub 账号）
clawhub login

# 逐个发布
clawhub skill publish ./chen-prd-skills \
  --slug chen-prd-skills \
  --name "PRD书写规范技能" \
  --version 1.0.0 \
  --tags "product,prd,文档,需求"

clawhub skill publish ./chen-te-skills \
  --slug chen-te-skills \
  --name "PRD测试评审技能" \
  --version 1.0.0 \
  --tags "testing,prd,审查,质量"

clawhub skill publish ./chen-python-skills \
  --slug chen-python-skills \
  --name "Python基础语法库" \
  --version 1.0.0 \
  --tags "python,编程,语法,开发"

clawhub skill publish ./chen-knowledge-web \
  --slug chen-knowledge-web \
  --name "知识组网扩展器" \
  --version 1.0.0 \
  --tags "知识图谱,深度学习,跨学科,百科,教育"
```

---

## 📄 许可证

[MIT License](LICENSE)

---

## 📮 联系方式

- **GitHub**：[cyj4578/chen-skillshub](https://github.com/cyj4578/chen-skillshub)
- **问题反馈**：[GitHub Issues](https://github.com/cyj4578/chen-skillshub/issues)
