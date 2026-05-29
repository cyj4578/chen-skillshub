# Chen Skills Hub

> AI Skills Toolkit — Product Thinking × Engineering × Knowledge Networking

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Skills

| Skill | Version | Type | Overview |
|-------|---------|------|----------|
| [chen-prd-skills](./chen-prd-skills/) | `1.0.0` | Product Docs | Standardized PRD writing spec (10-chapter structure + templates + priority + checklist) |
| [chen-te-skills](./chen-te-skills/) | `1.0.0` | QA Review | PRD test review (5 dimensions + 33 checks + structured reports) |
| [chen-python-skills](./chen-python-skills/) | `1.0.0` | Programming | Python fundamentals library (30+ core topics + complete reference) |
| [chen-knowledge-web](./chen-knowledge-web/) | `1.0.0` | Knowledge Tool | Knowledge web expander (5-axis expansion + disambiguation + timeline + supply chain) |

---

## Quick Start

### Option 1: Git Clone (all skills)

```bash
git clone https://github.com/cyj4578/chen-skillshub.git
```

### Option 2: ClawHub Install (per skill)

```bash
clawhub install chen-prd-skills
clawhub install chen-te-skills
clawhub install chen-python-skills
clawhub install chen-knowledge-web
```

### Option 3: Manual Install

Download the skill directory to your local skills folder `<skill-name>/`

---

## Skill Pipeline

### PRD Full Workflow

```
┌─────────────────────┐
│  chen-prd-skills    │  ← Write: get template + follow spec
│  (PRD Writing Spec) │
└────────┬────────────┘
         ↓
┌─────────────────────┐
│  chen-te-skills     │  ← Review: 33 systematic checks + gap detection
│  (PRD QA Review)    │
└────────┬────────────┘
         ↓
┌─────────────────────┐
│  Fix → Re-review    │  ← Close the loop: iterate based on review report
└─────────────────────┘
```

---

## Skill Details

### 1. chen-prd-skills — PRD Writing Specification

**Triggers**: `PRD`, `product requirements`, `requirements doc`, `user story`, `functional requirements`

| Capability | Description |
|------------|-------------|
| 10-chapter structure | Problem Statement → Goals → Non-Goals → User Stories → Requirements → Success Metrics → Open Questions → Timeline → Dependencies & Risks → Appendix |
| Requirement IDs | US-XX / FR-XX / NFR-XX / G-XX / Q-XX |
| 4 priority levels | P0 (must deliver) → P1 (this iteration) → P2 (resource-dependent) → P3 (future) |
| 10-item checklist | Pre-submission self-review to ensure document quality |
| 3 reference docs | Spec guide + writing guide + blank template |

### 2. chen-te-skills — PRD Test Review

**Triggers**: `review PRD`, `PRD audit`, `gap detection`, `test PRD`, `requirements review`, `PRD quality check`

| Capability | Description |
|------------|-------------|
| 5 review dimensions | Structural completeness / Logical consistency / Requirement completeness / Testability / Risk completeness |
| 33 systematic checks | Covers all gap categories |
| 4 severity levels | P0 Critical / P1 Major / P2 Minor / P3 Info |
| Structured report | Overview → Issue list → Fix suggestions → Improvement priorities |
| 3 reference docs | Review checklist + common gap types + report template |

### 3. chen-python-skills — Python Fundamentals Library

**Triggers**: `Python syntax`, `list`, `dict`, `function`, `class`, `inheritance`, `decorator`, `generator`, `lambda`, `list comprehension`, `exception handling`, `file I/O`

| Category | Topics Covered |
|----------|---------------|
| Basics | Data types, string operations, operators |
| Containers | List, tuple, dict, set |
| Control Flow | Conditionals (if/elif/else), loops (for/while) |
| Functions | Definition, parameters, return values, scope, lambda/map/filter/reduce |
| Advanced | Decorators, generators & iterators, comprehensions |
| OOP | Classes, instances, inheritance, polymorphism, encapsulation, magic methods |
| Engineering | Modules & packages, file I/O, exception handling |
| Utilities | Common built-in functions, standard library (os/sys/json/datetime/collections), type hints |

### 4. chen-knowledge-web — Knowledge Web Expander

**Triggers**: `knowledge web`, `expand`, `drill down`, `lateral comparison`, `timeline`, `disambiguation`, `look up this person`, `map out`, `knowledge graph`

| Capability | Description |
|------------|-------------|
| 5-axis expansion | Lateral / Vertical / Background / References / Impact |
| Disambiguation | Auto-detect homonyms and expand each independently (e.g. "Zhang" → 5 entrepreneurs each expanded) |
| Timeline supplement | Auto-add concurrent global events for historical topics (finance/tech/politics/culture) |
| Risk analysis | Auto-add side effects, counter-effects, and risk lists for product/tech topics |
| Supply chain | Auto-add upstream/downstream links for industrial/agricultural topics |
| Recursive drill-down | Each sub-node can be further expanded, enabling exponential knowledge growth |

### Knowledge Web Workflow

```
┌─────────────────────┐
│  Input Knowledge     │  ← concept / term / phenomenon / person
└────────┬────────────┘
         ↓
┌─────────────────────┐
│  Disambiguation      │  ← if multiple homonyms, expand each independently
└────────┬────────────┘
         ↓
┌─────────────────────┐
│  5-Axis Expansion    │  ← lateral + vertical + background + references + impact
└────────┬────────────┘
         ↓
┌─────────────────────┐
│  Specialized Add-ons │  ← timeline / side effects / supply chain (on demand)
└────────┬────────────┘
         ↓
┌─────────────────────┐
│  Recursive (optional)│  ← select sub-nodes to continue expanding
└─────────────────────┘
```

---

## Multi-Tool Compatibility

All skills follow the standard SKILL.md format and are compatible with any AI tool that supports OpenClaw skill loading, including:

**WorkBuddy · Codex · Cursor · Claude Code · and more**

---

## Publish to ClawHub

All skills in this repo comply with the [ClawHub Publishing Spec](https://docs.openclaw.ai/clawhub/skill-format).

### Publish commands

```bash
# Install ClawHub CLI
npm install -g clawhub

# Login (requires GitHub account)
clawhub login

# Publish each skill
clawhub skill publish ./chen-prd-skills \
  --slug chen-prd-skills \
  --name "PRD Writing Specification" \
  --version 1.0.0 \
  --tags "product,prd,documentation,requirements"

clawhub skill publish ./chen-te-skills \
  --slug chen-te-skills \
  --name "PRD Test Review" \
  --version 1.0.0 \
  --tags "testing,prd,review,qa"

clawhub skill publish ./chen-python-skills \
  --slug chen-python-skills \
  --name "Python Fundamentals Library" \
  --version 1.0.0 \
  --tags "python,programming,syntax,development"

clawhub skill publish ./chen-knowledge-web \
  --slug chen-knowledge-web \
  --name "Knowledge Web Expander" \
  --version 1.0.0 \
  --tags "knowledge-graph,deep-learning,interdisciplinary,encyclopedia,education"
```

---

## License

[MIT License](LICENSE)

---

## Contact

- **GitHub**: [cyj4578/chen-skillshub](https://github.com/cyj4578/chen-skillshub)
- **Issues**: [GitHub Issues](https://github.com/cyj4578/chen-skillshub/issues)
