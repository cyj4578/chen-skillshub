# chen-pmo — 陈氏 PM Skill 编排引擎 v3.0

> 将 8 个产品经理 Skill 按声明式 DAG 流水线串联执行的 Skill Orchestration 引擎。
> 输入一句需求描述，输出完整的产品方案 HTML 工作台。

[![Version](https://img.shields.io/badge/version-3.0-blue)](./SKILL.md)
[![Type](https://img.shields.io/badge/type-skill--orchestration-purple)](./SKILL.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

---

## 一句话

`chen-pmo` = **8 个 Skill 封装成的编排引擎**（6 PM + PRD 生成 + TE 逻辑审查）。

加载后自动执行：**市场调研 → 竞品分析 → 功能清单 → PRD 生成 → TE 逻辑审查 → 系统架构 → UI 原型 → 技术实现**。

---

## DAG 执行流程

```
                   需求输入
                      │
       ┌──────────────┼──────────────┐
       ▼              ▼              │
  Step 1           Step 2           │
  市场调研          竞品分析          │  ← 可并行
  (可跳过)         (可跳过)          │
       │              │              │
       └──────┬───────┘              │
              ▼                      │
         Step 3                      │
         功能清单                     │  ← 不可跳过
         (P0-P3 分级)                │
              │                      │
              ▼                      │
      Step 3-PRD                     │
      chen-prd-skills                │  ← 可跳过
      标准 10 章 PRD                  │
              │                      │
              ▼                      │
      Step 3-TE                      │
      chen-te-skills                 │  ← 强制质量关卡
      5 维 33 项逻辑审查              │     on_failure: ask
      反问逻辑漏洞 · 确保需求自洽      │
              │                      │
       ┌──────┴──────┐              │
       ▼              ▼              │
  Step 4           Step 5           │  ← 可并行
  系统架构          UI 原型          │
  (不可跳过)       (可跳过)          │
       │              │              │
       └──────┬───────┘              │
              ▼                      │
         Step 6                      │
         技术实现                     │  ← 可跳过
              │                      │
              ▼                      │
      HTML 预览工作台                 │
```

---

## 组合的 8 个 Skill

| # | Skill | 职责 | 失败策略 |
|---|-------|------|---------|
| 1 | `chen-pm-market-research` | 市场调研：规模/类型/功能全景/典型案例/技术对比 | skip |
| 2 | `chen-pm-competitive-analysis` | 竞品分析：矩阵/全流程对比/合规分析/差异化策略 | skip |
| 3 | `chen-pm-feature-checklist` | 功能清单：P0-P3 分级 + 明确不做项 | **stop** |
| 3-PRD | `chen-prd-skills` | PRD 文档：标准 10 章（问题/目标/用户故事/FR/NFR/指标/风险等） | skip |
| 3-TE | `chen-te-skills` | **TE 逻辑审查**：5 大维度 33 项检查，反问逻辑漏洞 | **ask** |
| 4 | `chen-pm-system-architecture` | 系统架构：分层架构/数据流图/DDL/API/状态机 | **stop** |
| 5 | `chen-pm-ui-prototype` | UI 原型：页面清单/页面结构/交互规范（Ant Design 3） | skip |
| 6 | `chen-pm-tech-implementation` | 技术实现：技术选型/核心代码/部署方案/成本估算 | skip |

---

## 前置依赖

**必须全部安装，缺一不可。**

```bash
clawhub install chen-pmo              # 引擎（含 html-template.html）
clawhub install chen-pm-market-research
clawhub install chen-pm-competitive-analysis
clawhub install chen-pm-feature-checklist
clawhub install chen-prd-skills        # Step 3 内嵌 PRD 生成
clawhub install chen-te-skills         # Step 3 内嵌 TE 逻辑审查（强制质量关卡）
clawhub install chen-pm-system-architecture
clawhub install chen-pm-ui-prototype
clawhub install chen-pm-tech-implementation
```

或者**一键安装全部**：

```bash
# 克隆整个仓库
git clone https://github.com/cyj4578/chen-skillshub.git
# 将 chen-pm-* 和 chen-prd-skills + chen-te-skills 目录复制到
# ~/.workbuddy/skills/ 或项目 .workbuddy/skills/
```

---

## 使用方式

```
@skill:chen-pmo

需求背景：公司需要一个 XXX 系统，用于解决 YYY 问题。
目标用户：AAA 角色的员工
限制条件：使用公司现有技术栈（MySQL + Redis），需支持移动端
```

引擎将自动：
1. 确认 Pipeline 执行计划（Phase 2）
2. 按 DAG 依次执行 8 个 Skill（Phase 3）
3. 生成 HTML 预览工作台 + 各步骤产物（Phase 4）

---

## 失败策略

| 级别 | 符号 | 行为 | 适用步骤 |
|------|------|------|---------|
| **stop** | 🛑 | 终止整个 Pipeline | 功能清单、系统架构 |
| **ask** | ⚠️ | 暂停询问用户 | TE 逻辑审查 |
| **skip** | ⏭ | 跳过继续执行 | 市场调研、竞品分析、PRD、UI 原型、技术实现 |

---

## 技术栈基线

默认技术选型（可在需求中覆盖）：

| 层次 | 技术 |
|------|------|
| 后端 | Node.js (Express/Koa) |
| 数据库 | MySQL 8.0 + Redis 7 |
| 前端 | Ant Design 3 / React |
| 部署 | Docker + Docker Compose |
| 小程序 | 微信小程序原生 / Taro |

---

## 可扩展节点

```yaml
# 知识库归档（可选）
- id: archive
  skill: ima-skills
  depends_on: [prd-document, te-review, tech-implementation]
  description: "归档到 IMA 笔记"
```

完整链路：`chen-pmo（6+2 步） → ima-skills`

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0 | 2026-06 | 初始版本：6 PM Skill + 编排引擎 |
| v2.0 | 2026-06 | 集成 chen-prd-skills（Step 3-PRD），固化 HTML 模板 |
| v3.0 | 2026-06 | 集成 chen-te-skills（Step 3-TE）作为强制质量关卡，TE 审查 5 维 33 项检查 |

---

## 许可证

[MIT License](../LICENSE)

---

## 联系方式

- **GitHub**：[cyj4578/chen-skillshub](https://github.com/cyj4578/chen-skillshub)
- **问题反馈**：[GitHub Issues](https://github.com/cyj4578/chen-skillshub/issues)
