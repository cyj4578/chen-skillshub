---
name: chen-pmo
description: 陈氏PM Skill 编排引擎。将 8 个技能（6 PM + PRD 生成 + TE 逻辑审查）按声明式 DAG 流水线串联执行。加载后自动按 市场调研→竞品分析→功能清单→PRD生成→TE逻辑审查→系统架构→UI原型→技术实现 的固定流程编排，TE 审查作为强制质量关卡反问逻辑漏洞，确保全部需求自洽。任何产品需求分析场景适用。
trigger_keywords: PM编排, 产品经理, skill编排, 需求分析, 产品方案, 功能设计, 系统设计, @skill:chen-pmo
pipeline:
  version: "3.0"
  name: "chen-pmo"
  type: "skill-orchestration"
  steps:
    - id: market-research
      skill: chen-pm-market-research
      depends_on: []
      description: "市场调研"
      on_failure: skip
    - id: competitive-analysis
      skill: chen-pm-competitive-analysis
      depends_on: [market-research]
      description: "竞品分析"
      on_failure: skip
    - id: feature-checklist
      skill: chen-pm-feature-checklist
      depends_on: [market-research, competitive-analysis]
      description: "功能清单"
      on_failure: stop
    - id: prd-document
      skill: chen-prd-skills
      depends_on: [feature-checklist]
      description: "PRD 文档生成（基于功能清单产出标准10章 PRD）"
      on_failure: skip
    - id: te-review
      skill: chen-te-skills
      depends_on: [prd-document]
      description: "TE 逻辑审查（反问逻辑漏洞，确保全部需求自洽）"
      on_failure: ask
    - id: system-architecture
      skill: chen-pm-system-architecture
      depends_on: [feature-checklist, prd-document, te-review]
      description: "系统架构"
      on_failure: stop
    - id: ui-prototype
      skill: chen-pm-ui-prototype
      depends_on: [feature-checklist, prd-document, te-review, system-architecture]
      description: "UI原型"
      on_failure: skip
    - id: tech-implementation
      skill: chen-pm-tech-implementation
      depends_on: [system-architecture, ui-prototype]
      description: "技术实现"
      on_failure: skip
---

# chen-pmo — 陈氏 PM Skill 编排引擎

## 这是什么

`chen-pmo` 是一个 **Skill Orchestration（技能编排引擎）**。

和普通 Skill 不同——它不是一份"参考资料"，而是一个**执行引擎**。加载后，它会：
1. 解析用户需求输入
2. 按固定的 6 步 Pipeline 依次加载并执行子 Skills
3. 在步骤间传递上下文数据
4. 最终生成可交互的 HTML 预览工作台

**一句话：`chen-pmo` = 8 个 Skill 封装成的编排引擎（6 PM + PRD + TE 审查）。**

---

## 固定 Pipeline（声明式 DAG）

```
                    需求输入
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              │
   Step 1           Step 2           │
   市场调研          竞品分析          │
   (可跳过)         (可跳过)          │
        │              │              │
        └──────┬───────┘              │
               ▼                      │
          Step 3                      │
          功能清单                     │
          (不能跳过)                   │
               │                      │
               ▼                      │
       Step 3-PRD                     │
       （内嵌 chen-prd-skills）        │
       PRD 文档生成（可跳过）           │
               │                      │
               ▼                      │
       Step 3-TE 🆕                   │
       （内嵌 chen-te-skills）         │
       TE 逻辑审查（询问用户）          │
       5 大维度 33 项检查              │
       反问逻辑漏洞 · 确保需求自洽     │
               │                      │
        ┌──────┴──────┐              │
        ▼              ▼              │
   Step 4           Step 5           │
   系统架构          UI 原型          │
   (不能跳过)       (可跳过)          │
        │              │              │
        └──────┬───────┘              │
               ▼                      │
          Step 6                      │
          技术实现                     │
          (可跳过)                     │
               │                      │
               ▼                      │
       HTML 预览工作台                 │
```

**依赖规则**：
- Step 1 和 Step 2 无依赖，**可并行执行**
- Step 3 依赖 Step 1 + Step 2 都完成
- Step 3-PRD（chen-prd-skills）依赖 Step 3 完成，在 Step 3 内部串联执行
- Step 3-TE 🆕（chen-te-skills）依赖 Step 3-PRD 完成，**强制质量关卡**：执行 5 大维度 33 项系统性检查，反问逻辑漏洞，确保全部需求自洽
- Step 4 和 Step 5 同依赖 Step 3 + Step 3-PRD + Step 3-TE，**可并行执行**
- Step 6 依赖 Step 4 + Step 5 都完成

**失败策略**：
- `stop`：该步骤失败则**终止整个 Pipeline**（功能清单、系统架构不可跳过）
- `ask`：该步骤失败则**询问用户**是否继续（TE 逻辑审查——发现 P0 漏洞时暂停，用户决定是否修复后重试）
- `skip`：该步骤失败则**跳过继续**（市场调研、竞品分析、PRD 生成、UI原型、技术实现可跳过）

---

## 组合的 8 个 Skill

| # | Skill | 职责 | 输入要求 | 输出 |
|---|-------|------|---------|------|
| 1 | `chen-pm-market-research` | 市场调研 | 需求背景 + 行业 | 市场规模、类型分类、功能全景、典型案例、技术对比 |
| 2 | `chen-pm-competitive-analysis` | 竞品分析 | 需求背景 + 行业 | 竞品矩阵、全流程对比、合规分析、差异化策略 |
| 3 | `chen-pm-feature-checklist` | 功能清单 | 需求描述 + 限制条件 + Step1/2输出 | P0-P3 分级功能清单、明确不做项 |
| 🆕 | `chen-prd-skills` | PRD 文档（Step 3 内嵌） | 功能清单输出 | 标准 10 章 PRD（问题陈述/目标/用户故事/FR/NFR/成功指标/风险等） |
| 🆕 | `chen-te-skills` | **TE 逻辑审查（Step 3 内嵌）** | PRD 文档全文 | 5 大维度 33 项检查报告（P0🔴/P1🟠/P2🟡/P3🔵），反问逻辑漏洞，确保全部需求自洽 |
| 4 | `chen-pm-system-architecture` | 系统架构 | 功能清单 + PRD + TE 审查 + 需求背景 | 分层架构、数据流图、DDL、API、状态机 |
| 5 | `chen-pm-ui-prototype` | UI 原型 | 功能清单 + PRD + TE 审查 + 架构设计 | 页面清单、页面结构、交互规范（Ant Design 3） |
| 6 | `chen-pm-tech-implementation` | 技术实现 | 架构设计 + UI 原型 | 技术选型、核心代码、部署方案、成本估算 |

---

## 编排执行流程

### Phase 1：解析需求

从用户输入中提取结构化上下文：

```yaml
context:
  background: "<需求背景>"
  pain_points: "<业务痛点>"
  constraints: "<功能限制>"
  industry: "<目标行业>"
  target_users: "<目标用户>"
  platform: "<目标平台：小程序/Web/App>"
```

### Phase 2：确认 Pipeline

向用户展示 Pipeline 执行计划，格式如下：

```
## chen-pmo 执行计划

| Step | Skill | 状态 | 说明 |
|------|-------|------|------|
| 1 | chen-pm-market-research | ⏳ 待执行 | 调研 [行业] 的市场现状和典型方案 |
| 2 | chen-pm-competitive-analysis | ⏳ 待执行 | 分析 [行业] 的竞品模式和合规要求 |
| 3 | chen-pm-feature-checklist → chen-prd-skills → chen-te-skills | ⏳ 待执行 | 输出功能清单（P0-P3）→ 生成标准 PRD → TE 逻辑审查（5维33项） |
| 4 | chen-pm-system-architecture | ⏳ 待执行 | 设计系统架构和数据流转 |
| 5 | chen-pm-ui-prototype | ⏳ 待执行 | 设计 UI 原型（Ant Design 3） |
| 6 | chen-pm-tech-implementation | ⏳ 待执行 | 输出技术实现方案 |

依赖关系：1+2→3→3-PRD→3-TE→4+5→6
预计输出：HTML 预览工作台 + 各步骤产物文件 + TE 审查报告

确认执行？(Y/n/跳过某步骤)
```

### Phase 3：执行 Pipeline

按 DAG 逐步执行，**使用 Task 工具追踪进度**：

**并行批次 1**：Step 1 + Step 2 并行
```
TaskCreate: "Step 1: 市场调研" + "Step 2: 竞品分析"
→ 并行加载 chen-pm-market-research + chen-pm-competitive-analysis
→ 各自完成任务后 TaskUpdate status=completed
```

**Step 3**：功能清单 + PRD 文档 + TE 逻辑审查（等待 Step 1+2）
```
TaskCreate: "Step 3: 功能清单" + "Step 3-PRD: PRD 文档" + "Step 3-TE: TE 逻辑审查"
→ 先加载 chen-pm-feature-checklist，传入 Step1/2 输出作为上下文
→ TaskUpdate status=completed
→ 再加载 chen-prd-skills，传入功能清单输出，生成标准 10 章 PRD
→ PRD 产物融入 HTML 工作台 Step 3 的模板内容
→ TaskUpdate status=completed
→ 再加载 chen-te-skills，传入 PRD 文档全文
→ 执行 5 大维度 33 项系统性检查（结构完整性/逻辑一致性/需求完整性/可测试性/风险完整性）
→ 输出结构化审查报告（P0🔴/P1🟠/P2🟡/P3🔵），反问逻辑漏洞
→ 若 P0 问题 > 0，按 on_failure: ask 暂停并询问用户处理方式
→ TaskUpdate status=completed
```

**并行批次 2**：Step 4 + Step 5 并行（等待 Step 3-TE）
```
TaskCreate: "Step 4: 系统架构" + "Step 5: UI原型"
→ 并行加载 chen-pm-system-architecture + chen-pm-ui-prototype
→ 各自完成任务后 TaskUpdate status=completed
```

**Step 6**：技术实现（等待 Step 4+5）
```
TaskCreate: "Step 6: 技术实现"
→ 加载 chen-pm-tech-implementation，传入 Step3/4/5 输出
→ TaskUpdate status=completed
```

**关键规则**：
- 每步通过 `Skill` 工具加载对应子 Skill，并传入需求上下文 + 上游步骤产物摘要
- 子 Skill 负责产出具体内容（文本/图表/代码）
- 编排引擎负责调度、状态追踪、数据传递
- 某步骤失败时按 `on_failure` 策略处理（stop=终止 / skip=跳过继续）

### Phase 4：汇总输出

所有步骤完成后，**必须使用统一 HTML 模板**输出。

#### ⚠ 强制规则：必须使用 `html-template.html`

引擎目录下的 `html-template.html` 是**唯一合法的 HTML 输出模板**。每次执行时：

1. **读取模板**：`Read` `.workbuddy/skills/chen-pmo/html-template.html`
2. **替换变量**：将模板中的 `{{变量}}` 替换为本次案例的实际内容
3. **写入产物**：输出为 `chen-pmo-output-<简短英文名>-<YYYYMMDD>.html`

**模板变量替换表**：

| 变量 | 含义 | 示例 |
|------|------|------|
| `{{CASE_NAME}}` | 案例完整名称 | 员工报餐系统 |
| `{{CASE_SHORT_NAME}}` | 侧边栏简称 | 员工报餐 |
| `{{CASE_SHORT_NAME_EN}}` | 文件名用英文简称 | meal |
| `{{CASE_NUM}}` | 案例编号 | 5 |
| `{{DATE}}` | 执行日期 | 2026-06-02 |
| `{{PROGRESS_PCT}}` | 进度条百分比 | 100% |
| `{{DONE_COUNT}}` | 完成步骤数 | 7 |
| `{{PIPELINE_STEPS}}` | Pipeline 步骤状态 HTML | 见下方格式 |
| `{{STEP1_TITLE}}` ~ `{{STEP6_TITLE}}` | 各步骤副标题 | 企业报餐/智能表单系统 |
| `{{STEP1_CONTENT}}` ~ `{{STEP6_CONTENT}}` | 各步骤内容 HTML | (完整 HTML 片段)。注意：`{{STEP3_CONTENT}}` 需包含「功能清单」+「PRD 文档」+「TE 审查报告」三个子模块 |

**Pipeline 步骤状态格式**（`{{PIPELINE_STEPS}}`）：

```html
<span class="pipeline-step done">1. 市场调研 ✅</span>
<span class="pipeline-arrow">→</span>
<span class="pipeline-step done">2. 竞品分析 ✅</span>
...
```

状态 class：`done`（完成）、`skip`（跳过）、`fail`（失败）。

**模板不可修改项**（保证 UI 一致性）：
- 所有 CSS 样式（`:root` 变量、颜色、字体、边距、阴影等）
- 侧边栏结构（深色 #001529 + 滚动联动高亮）
- 进度条样式（渐变蓝色条）
- Pipeline 概览卡片（深蓝渐变背景）
- 各 Section 折叠/展开交互
- 编辑功能（✏ 按钮 → textarea）
- 导出 Markdown 按钮（右下角悬浮蓝色圆角按钮）
- Toast 提示
- 响应式断点（768px）

**仅允许替换的内容**：
- HTML `<title>` 标签
- 侧边栏底部的案例信息
- Pipeline 卡片中的需求描述、日期、步骤状态
- 6 个 Section 的标题和 body 内容

#### 交付步骤

1. `preview_url` 预览 HTML 产物
2. `deliver_attachments` 交付 HTML 文件
3. 在对话中输出执行报告摘要

**执行报告摘要格式**（对话中展示，不写入文件）：

```
## chen-pmo 执行报告

| # | 步骤 | 状态 | 产物摘要 |
|---|------|------|---------|
| 1 | 市场调研 | ✅ | X类系统 + Y家案例 |
| 2 | 竞品分析 | ✅ | Z方案对比 + 合规矩阵 |
| 3 | 功能清单 | ✅ | N项 P0/P1/P2 |
| 3-PRD | PRD 文档 | ✅ | 10 章标准 PRD |
| 3-TE 🆕 | TE 逻辑审查 | ✅/⚠ | P0:N P1:N P2:N（审查通过/有待修复项） |
| 4 | 系统架构 | ✅ | X图 + Y表 + Z API |
| 5 | UI原型 | ✅ | N页面 + 交互规范 |
| 6 | 技术实现 | ✅ | 技术栈 + 代码 + 部署 |
```

---

## 使用方式

### 方式一：一键执行（推荐）

直接输入需求，引擎自动执行全流程：

```
@skill:chen-pmo

需求背景：原有商城小程序需要做一个签到功能
业务痛点：XX
功能限制：XX
```

### 方式二：跳过某步骤

```
@skill:chen-pmo

需求背景：XXX
跳过：市场调研, 竞品分析
```

### 方式三：只执行部分步骤

```
@skill:chen-pmo

需求背景：XXX
仅执行：功能清单, 系统架构
```

---

## 与普通 Skill 的本质区别

| 维度 | 普通 Skill | chen-pmo（Skill Orchestration） |
|------|-----------|-------------------------------|
| 性质 | 参考资料/指令集 | 执行引擎 |
| 加载后 | AI 在对话中使用其知识 | AI 开始按 Pipeline 逐步编排 |
| 产出 | 通常为单份文档/分析 | 6+2步骤产物 + PRD + TE 审查报告 + HTML 工作台 |
| 可组合 | 否 | 是——封装了 8 个 Skill |
| 状态追踪 | 无 | Task 工具追踪每步进度 |
| 失败处理 | 无 | stop/skip/ask 三级策略 |

---

## 基线约定（无行业/领域硬编码）

所有 6 个子 Skill 是通用的，不包含任何特定行业/领域的内容：

| 约定项 | 默认值 | 说明 |
|-------|--------|------|
| UI 设计基线 | Ant Design 3 风格 | 可被用户覆盖 |
| 技术栈基线 | Node.js + MySQL + Redis + Docker | 可被用户覆盖 |
| 引用时限 | 市场调研标注来源；竞品分析仅近 2 年 | 自动执行 |
| 功能分级 | P0/P1/P2/P3 | 统一标准 |
| PRD 规范 | chen-prd-skills 10章标准 | Step 3 内嵌自动生成 |
| 输出格式 | 中文 + 结构化（表格/列表/缩进） | 用户偏好 |
| 平台默认 | 小程序 | 可从需求中自动识别 |

---

## 已验证案例

本引擎已通过 4 个不同领域的实战验证：

| # | 案例 | 行业 | 特色 |
|---|------|------|------|
| 1 | 视频号直播系统 | 电商直播 | 多店铺同时开播、视频号 API |
| 2 | 签到+抽奖功能 | 电商留存 | Redis Bitmap、加权随机抽奖 |
| 3 | 账号注销功能 | 医疗健康 | 个保法合规、多端同步、冷静期 |
| 4 | 山姆代购小程序 | O2O 代购 | 单小程序双角色、无库存极简设计 |

---

## 可扩展节点（可选串联，Step 3-PRD 和 Step 3-TE 已内置）

引擎在 6+2 步基础上支持串联其他 Skills：

```yaml
# 知识库归档（可选）
- id: archive
  skill: ima-skills
  depends_on: [prd-document, te-review, tech-implementation]
  description: "归档到 IMA 笔记"
```

完整链路 === chen-pmo（6+2步：含 PRD 生成 + TE 审查）→ ima-skills

> **注意**：`chen-prd-skills` 和 `chen-te-skills` 已内置在 Step 3 中（功能清单 → PRD 生成 → TE 逻辑审查），不需要再作为扩展节点添加。

---

## 前置依赖

确保以下 8 个 Skills 已安装（其中 chen-prd-skills 和 chen-te-skills 在 Step 3 内串联）：

```
~/.workbuddy/skills/chen-pm-market-research/
~/.workbuddy/skills/chen-pm-competitive-analysis/
~/.workbuddy/skills/chen-pm-feature-checklist/
~/.workbuddy/skills/chen-prd-skills/            ← Step 3 内嵌 PRD 生成
~/.workbuddy/skills/chen-te-skills/             ← Step 3 内嵌 TE 逻辑审查（强制质量关卡）
~/.workbuddy/skills/chen-pm-system-architecture/
~/.workbuddy/skills/chen-pm-ui-prototype/
~/.workbuddy/skills/chen-pm-tech-implementation/
```
