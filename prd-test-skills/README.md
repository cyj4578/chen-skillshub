# prd-test-skills

> PRD test skill — scenario enumeration, logic-chain validation, risk grading, test-case derivation, and structured audit reports.

## Core Capabilities

| Capability | Description |
|------------|-------------|
| Expanded review dimensions | Structure / business truth / logic / scenarios / data & permissions / testability / launch risk |
| Scenario enumeration | Covers normal, exception, boundary, concurrency, interruption, role, permission, and cross-system paths |
| Specialized checklists | Transaction, livestream, content, backend, data dashboard, and AI/automation PRDs |
| Test-case derivation | Converts high-risk gaps into failing acceptance or test cases |
| 4 severity levels | P0 Critical / P1 Major / P2 Minor / P3 Info |
| Structured report | Overview → Issue list → Fix suggestions → Improvement priorities |
| Reference docs | Review checklist + scenario checklist + common gap types + report template |

## Universal Usage

This is a portable skill package. Copy the whole `prd-test-skills/` folder into any IDE or agent tool that supports skill-style folders with a `SKILL.md` entry file.

Required structure:

```text
prd-test-skills/
  SKILL.md
  references/
    prd-review-checklist.md
    scenario-checklists.md
    common-prd-gaps.md
    review-report-template.md
```

## Optional Pipeline

Can pair with `chen-prd-skills` if that skill is installed separately:

```
chen-prd-skills (Write) → prd-test-skills (Review) → Fix & Re-review
```

## Triggers

`review PRD`, `PRD audit`, `gap detection`, `test PRD`, `requirements review`, `PRD quality check`

## Quick Start

```bash
git clone https://github.com/cyj4578/chen-skillshub.git
```

Load `SKILL.md` with any skill-compatible IDE or agent tool, including Codex, Cursor-like agents, Claude-compatible agents, OpenClaw-compatible tools, and other tools that read Markdown skills with YAML frontmatter.

## License

MIT — see [LICENSE](../LICENSE)
