---
name: chen-pmo
description: 陈氏PM Skill 编排包。封装 8 个产品管理子模块（市场调研/竞品分析/功能清单/PRD生成/TE审查/系统架构/UI原型/技术实现），可单独调用任一模块，也可一键执行全流程 DAG 编排。安装一个 Skill 即可获得全部 PM 能力。适用于任何产品需求分析场景。
trigger_keywords: PM编排, 产品经理, 需求分析, 产品方案, 功能设计, 系统设计, 市场调研, 竞品分析, 功能清单, 写PRD, 审查PRD, TE审查, 系统架构, UI原型, 技术方案, @skill:chen-pmo
version: "4.0"
type: "skill-package"
agent_created: true
---

# chen-pmo — 陈氏 PM Skill 编排包 v4.0

## 这是什么

`chen-pmo` 是一个 **Skill Package（技能编排包）**。与普通 Skill 不同：

- 不是一份参考资料，而是一个**包含 8 个子模块的执行引擎**
- **安装一个 = 获得全部**：市场调研、竞品分析、功能清单、PRD生成、TE审查、系统架构、UI原型、技术实现
- **可以单独调**：选择一个模块独立执行
- **可以组合跑**：一键执行全部 6+2 步 DAG 编排
- **可以更新**：随时修改任一模块的指令和模板
- **分享简单**：只需要安装 `chen-pmo` 一个 Skill

---

## 第一步：意图识别（必须执行）

加载后，**先判断用户意图**，再决定走哪条路径。

### 意图 A：全量编排

触发条件：用户输入包含"完整方案""全流程""产品方案""设计一个XX系统""需求分析""出方案""做一个XX"等，且**没有指定具体单一模块名**。

→ 执行 [全量编排模式](#全量编排模式-dag-流水线)

### 意图 B：单模块调用

触发条件：用户输入明确指向某个模块。

| 用户关键词 | 对应模块文件 |
|-----------|------------|
| 市场调研 / 行业调研 / 调研 / market research | `references/modules/market-research.md` |
| 竞品分析 / 竞争对手 / 竞品对比 / competitive analysis | `references/modules/competitive-analysis.md` |
| 功能清单 / 需求清单 / 功能列表 / feature list | `references/modules/feature-checklist.md` |
| 写PRD / PRD文档 / 需求文档 / 产品需求文档 | `references/modules/prd-document.md` |
| 审查PRD / TE审查 / 逻辑审查 / 评审PRD / 检测漏洞 | `references/modules/te-review.md` |
| 系统架构 / 数据流转 / 数据库设计 / API设计 / architecture | `references/modules/system-architecture.md` |
| UI原型 / 原型图 / 页面设计 / 交互设计 / prototype | `references/modules/ui-prototype.md` |
| 技术方案 / 技术选型 / 部署方案 / 成本估算 / implementation | `references/modules/tech-implementation.md` |

→ 执行 [单模块调用模式](#单模块调用模式)

### 意图 C：模块更新

触发条件：用户说"更新XX模块""修改XX模块""XX模块加一个XX要求"。

→ 执行 [模块更新模式](#模块更新模式)

### 意图 D：查看模块列表

触发条件：用户说"有哪些模块""模块列表""chen-pmo能做什么"。

→ 输出下方模块清单表格，不执行任何模块。

---

## 模块清单（8 个）

| # | 模块 | 文件 | 职责 | DAG位置 |
|---|------|------|------|---------|
| 1 | 市场调研 | `references/modules/market-research.md` | 市场规模、类型分类、功能全景、典型案例、技术对比 | Step 1（可跳过） |
| 2 | 竞品分析 | `references/modules/competitive-analysis.md` | 竞品矩阵、全流程对比、合规分析、差异化策略 | Step 2（可跳过） |
| 3 | 功能清单 | `references/modules/feature-checklist.md` | P0-P3 分级功能清单、明确不做项 | Step 3（不可跳过） |
| 4 | PRD 生成 | `references/modules/prd-document.md` | 标准 10 章 PRD | Step 3-PRD（可跳过） |
| 5 | TE 审查 | `references/modules/te-review.md` | 5 大维度 33 项逻辑漏洞审查 | Step 3-TE（强制质量关卡） |
| 6 | 系统架构 | `references/modules/system-architecture.md` | 分层架构、数据流图、DDL、API、状态机 | Step 4（不可跳过） |
| 7 | UI 原型 | `references/modules/ui-prototype.md` | 页面清单、页面结构、交互规范（Ant Design 3） | Step 5（可跳过） |
| 8 | 技术实现 | `references/modules/tech-implementation.md` | 技术选型、核心代码、部署方案、成本估算 | Step 6（可跳过） |

**模板库**：
- PRD 模板 → `references/prd-templates/`
- TE 审查模板 → `references/te-templates/`

---

## 单模块调用模式

当识别为意图 B 时，按以下流程执行：

```
1. TaskCreate: "[模块名] 单模块执行"
2. Read references/modules/[模块名].md — 获取模块的完整执行指令
3. 按模块指令的"执行步骤"逐步执行
   - 若涉及 WebSearch/WebFetch，正常搜索和引用
   - 若涉及模板参考，Read references/prd-templates/ 或 te-templates/ 中的文件
4. 输出结果（文本/表格/代码）
5. TaskUpdate status=completed
```

**示例对话**：
- 用户："@skill:chen-pmo 帮我做市场调研，医美直播行业"
- 引擎：识别意图 B → Read `references/modules/market-research.md` → 根据模块的 5 模块结构输出市场调研报告

---

## 模块更新模式

当识别为意图 C 时：

```
1. Read references/modules/[模块名].md — 获取当前模块内容
2. 根据用户指令，用 Edit 工具修改模块文件
   - 追加指令规则
   - 修改输出结构
   - 更新引用规范
3. 确认修改内容并告知用户
```

**示例对话**：
- 用户："@skill:chen-pmo 更新市场调研模块，增加要求必须引用艾瑞咨询报告"
- 引擎：Read → Edit 在引用规范中追加规则 → 确认

---

## 全量编排模式（DAG 流水线）

当识别为意图 A 时，按以下 DAG 执行全部 6+2 步。

### DAG 声明

```yaml
pipeline:
  steps:
    - id: market-research
      module: references/modules/market-research.md
      depends_on: []
      on_failure: skip
    - id: competitive-analysis
      module: references/modules/competitive-analysis.md
      depends_on: [market-research]
      on_failure: skip
    - id: feature-checklist
      module: references/modules/feature-checklist.md
      depends_on: [market-research, competitive-analysis]
      on_failure: stop
    - id: prd-document
      module: references/modules/prd-document.md
      depends_on: [feature-checklist]
      on_failure: skip
    - id: te-review
      module: references/modules/te-review.md
      depends_on: [prd-document]
      on_failure: ask
    - id: system-architecture
      module: references/modules/system-architecture.md
      depends_on: [feature-checklist, prd-document, te-review]
      on_failure: stop
    - id: ui-prototype
      module: references/modules/ui-prototype.md
      depends_on: [feature-checklist, prd-document, te-review, system-architecture]
      on_failure: skip
    - id: tech-implementation
      module: references/modules/tech-implementation.md
      depends_on: [system-architecture, ui-prototype]
      on_failure: skip
```

### Phase 1：解析需求

从用户输入提取结构化上下文：

```yaml
context:
  background: "<需求背景>"
  pain_points: "<业务痛点>"
  constraints: "<功能限制>"
  industry: "<目标行业>"
  target_users: "<目标用户>"
  platform: "<目标平台：小程序/Web/App>"
```

### Phase 2：确认计划

向用户展示执行计划，等待确认：

```
## chen-pmo 执行计划

| Step | 模块 | 状态 | 说明 |
|------|------|------|------|
| 1 | 市场调研 | ⏳ | 调研 [行业] 市场现状 |
| 2 | 竞品分析 | ⏳ | 分析竞品模式和合规 |
| 3 | 功能清单 → PRD → TE审查 | ⏳ | P0-P3 清单 → 10章PRD → 33项审查 |
| 4 | 系统架构 | ⏳ | 分层架构 + 数据表 + API |
| 5 | UI 原型 | ⏳ | 页面清单 + 交互规范 |
| 6 | 技术实现 | ⏳ | 技术选型 + 代码 + 部署 |

依赖关系：1+2→3→3-PRD→3-TE→4+5→6

确认执行？(Y/n/跳过某步骤)
```

### Phase 3：执行 Pipeline

使用 Task 工具追踪进度。关键规则：
- 每个模块：先 `Read` 对应 `references/modules/` 文件获取执行指令，再按指令执行
- 模块之间通过上下文传递数据（上游产出摘要传给下游）
- 并行批次同时启动
- 失败时按 `on_failure` 策略处理

**并行批次 1**：Step 1 + Step 2 并行

```
TaskCreate: "Step 1: 市场调研" + "Step 2: 竞品分析"
→ Read references/modules/market-research.md → 执行市场调研
→ Read references/modules/competitive-analysis.md → 执行竞品分析
→ 各自完成后 TaskUpdate status=completed
```

**Step 3**：功能清单 + PRD + TE 审查（等待 Step 1+2）

```
TaskCreate: "Step 3: 功能清单" + "Step 3-PRD: PRD 文档" + "Step 3-TE: TE 审查"
→ Read references/modules/feature-checklist.md，传入 Step1/2 输出 → TaskUpdate completed
→ Read references/modules/prd-document.md，传入功能清单输出 → TaskUpdate completed
  （如需模板，Read references/prd-templates/ 中的文件）
→ Read references/modules/te-review.md，传入 PRD 全文
  （如需审查清单，Read references/te-templates/PRD审查清单.md）
→ 输出审查报告，若 P0>0 则 on_failure: ask 暂停 → TaskUpdate completed
```

**并行批次 2**：Step 4 + Step 5 并行（等待 Step 3-TE）

```
TaskCreate: "Step 4: 系统架构" + "Step 5: UI原型"
→ Read references/modules/system-architecture.md → 执行
→ Read references/modules/ui-prototype.md → 执行
→ 各自完成后 TaskUpdate status=completed
```

**Step 6**：技术实现（等待 Step 4+5）

```
TaskCreate: "Step 6: 技术实现"
→ Read references/modules/tech-implementation.md → 执行
→ TaskUpdate status=completed
```

### Phase 4：汇总输出

所有步骤完成后，使用统一 HTML 模板输出。

1. **Read** `html-template.html`
2. **替换** 以下模板变量：

| 变量 | 含义 | 示例 |
|------|------|------|
| `{{CASE_NAME}}` | 案例完整名称 | 员工报餐系统 |
| `{{CASE_SHORT_NAME}}` | 侧边栏简称 | 员工报餐 |
| `{{CASE_SHORT_NAME_EN}}` | 文件名用英文简称 | meal |
| `{{CASE_NUM}}` | 案例编号 | 6 |
| `{{DATE}}` | 执行日期 | 2026-06-02 |
| `{{PROGRESS_PCT}}` | 进度条百分比 | 100% |
| `{{DONE_COUNT}}` | 完成步骤数 | 7 |
| `{{PIPELINE_STEPS}}` | Pipeline 步骤状态 HTML | 见模板格式 |
| `{{STEP1_TITLE}}` ~ `{{STEP6_TITLE}}` | 各步骤副标题 | |
| `{{STEP1_CONTENT}}` ~ `{{STEP6_CONTENT}}` | 各步骤内容 HTML | STEP3_CONTENT 含功能清单+PRD+TE审查三个子模块 |

3. **Write** 产物为 `chen-pmo-output-<英文简称>-<YYYYMMDD>.html`
4. **preview_url** + **deliver_attachments** 交付

**执行报告摘要**（对话中展示）：

```
## chen-pmo 执行报告

| # | 步骤 | 状态 | 产物摘要 |
|---|------|------|---------|
| 1 | 市场调研 | ✅ | X类系统 + Y家案例 |
| 2 | 竞品分析 | ✅ | Z方案对比 + 合规矩阵 |
| 3 | 功能清单 | ✅ | N项 P0/P1/P2 |
| 3-PRD | PRD 文档 | ✅ | 10 章标准 PRD |
| 3-TE | TE 逻辑审查 | ✅/⚠ | P0:N P1:N P2:N |
| 4 | 系统架构 | ✅ | X图 + Y表 + Z API |
| 5 | UI原型 | ✅ | N页面 + 交互规范 |
| 6 | 技术实现 | ✅ | 技术栈 + 代码 + 部署 |
```

---

## 失败策略

| 策略 | 含义 | 适用模块 |
|------|------|---------|
| `stop` | 该步失败则**终止 Pipeline** | 功能清单、系统架构（不可跳过） |
| `ask` | 该步失败则**询问用户**是否继续 | TE 审查（P0 漏洞时暂停） |
| `skip` | 该步失败则**跳过继续** | 市场调研、竞品分析、PRD、UI原型、技术实现（可跳过） |

---

## 基线约定

| 约定项 | 默认值 | 说明 |
|-------|--------|------|
| UI 设计基线 | Ant Design 3 风格 | 可被用户覆盖 |
| 技术栈基线 | Node.js + MySQL + Redis + Docker | 可被用户覆盖 |
| 引用时限 | 市场调研标注来源；竞品分析仅近 2 年 | 自动执行 |
| 功能分级 | P0/P1/P2/P3 | 统一标准 |
| PRD 规范 | 10 章标准 + PRD 模板库 | references/prd-templates/ |
| TE 审查 | 5 大维度 33 项 + 审查模板库 | references/te-templates/ |
| 输出格式 | 中文 + 结构化（表格/列表/缩进） | 用户偏好 |
| 平台默认 | 小程序 | 可从需求中自动识别 |

---

## 已验证案例

| # | 案例 | 行业 | 特色 |
|---|------|------|------|
| 1 | 视频号直播系统 | 电商直播 | 多店铺同时开播、视频号 API |
| 2 | 签到+抽奖功能 | 电商留存 | Redis Bitmap、加权随机抽奖 |
| 3 | 账号注销功能 | 医疗健康 | 个保法合规、多端同步、冷静期 |
| 4 | 山姆代购小程序 | O2O 代购 | 单小程序双角色、无库存设计 |
| 5 | 员工报餐系统 | 企业服务 | 表单收集、Excel 统计、定时提醒 |

---

## 分享与安装

**只需安装这一个 Skill**：

```
clawhub install chen-pmo
```

所有子模块、PRD 模板、TE 审查模板全部包含在内。无需安装任何其他 Skill。

---

## 与 v3.0 的本质变化

| 维度 | v3.0（旧） | v4.0（新） |
|------|-----------|-----------|
| 安装 | 需 9 个独立 Skill | 只需 1 个 chen-pmo |
| 子模块 | 8 个独立 Skill（`Skill` 工具动态加载） | 8 个 references 模块（`Read` 工具读取） |
| 单模块调用 | 不支持（必须先装子 Skill 才能单独调） | 支持——引擎识别意图后 Read 对应模块 |
| 模块更新 | 需分别编辑子 Skill 文件 | 在引擎内统一管理（Read→Edit references） |
| 分享 | 需说明"请安装全部 9 个" | "安装这一个就行" |
| 类型 | `skill-orchestration` | `skill-package` |
