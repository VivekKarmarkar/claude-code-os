---
name: projectstatus
description: Generate a project status report. Use when the user wants a status update, progress report, standup summary, or weekly/sprint report — based on the current project's codebase, git history, and conversation context.
argument-hint: [time period or focus area]
---

# Project Status Report Generator

Create a concise, stakeholder-ready project status report as a markdown file by analyzing the codebase, git history, and conversation context.

## Modes

**Auto mode** — If no arguments (e.g., `/projectstatus`), analyze recent git activity and conversation to produce a status report covering the last week of work.

**Time-scoped mode** — If `$ARGUMENTS` specifies a period (e.g., `/projectstatus last 3 days`, `/projectstatus sprint 14`, `/projectstatus January`), scope the report to that window.

**Focused mode** — If `$ARGUMENTS` targets a specific area (e.g., `/projectstatus backend API`), scope the report to that part of the project.

## Research Steps (before writing)

Gather context from the project before writing anything:

1. **Git log** — Run `git log --oneline --since="1 week ago"` (adjust to match the requested time period) to see recent commits.
2. **Git diff stat** — Run `git diff --stat HEAD~20` (or appropriate range) to see what files changed and how much.
3. **Branch activity** — Run `git branch -a --sort=-committerdate | head -10` to see active branches.
4. **Open work** — Search for `TODO`, `FIXME`, `HACK`, `XXX` in the codebase to find outstanding items.
5. **Project files** — Read `README.md`, `CHANGELOG.md`, `ROADMAP.md`, or similar if they exist.
6. **Conversation context** — Review what was discussed, built, fixed, or decided in this session.
7. **Test status** — If a test command is obvious (e.g., `package.json` scripts, `pytest`, `cargo test`), note whether tests are referenced but do NOT run them unless the user asks.

## Report Structure

```markdown
# Project Status Report

> **Project:** <project name>
> **Period:** YYYY-MM-DD to YYYY-MM-DD
> **Author:** <from git config or leave blank>
> **Date:** YYYY-MM-DD

## TL;DR
Two to three sentences capturing the overall status. Lead with the most important thing.

## Overall Health

| Area | Status | Notes |
|------|--------|-------|
| Development | 🟢 On Track / 🟡 At Risk / 🔴 Blocked | Brief note |
| Code Quality | 🟢 / 🟡 / 🔴 | Brief note |
| Technical Debt | 🟢 / 🟡 / 🔴 | Brief note |
| Documentation | 🟢 / 🟡 / 🔴 | Brief note |

## What Got Done
Completed work during this period, grouped logically.

### <Category 1> (e.g., Features, Bug Fixes, Infrastructure)
- **<Item>** — Brief description of what was done and why it matters.
  - Files: `path/to/file`, `path/to/other`
  - Commit: `abc1234`
- **<Item>** — Brief description.

### <Category 2>
- **<Item>** — Brief description.

## In Progress
Work that's started but not yet complete.

| Item | Status | Owner | Blocker |
|------|--------|-------|---------|
| Description | X% / status note | Who's on it | What's blocking, if anything |

## Key Metrics

| Metric | Value | Trend |
|--------|-------|-------|
| Commits this period | N | ↑ / ↓ / → |
| Files changed | N | ↑ / ↓ / → |
| Lines added / removed | +N / -N | — |
| Open TODOs/FIXMEs | N | ↑ / ↓ / → |
| Active branches | N | — |

## Blockers & Risks

| Issue | Impact | Status | Action Needed |
|-------|--------|--------|--------------|
| Description | High/Med/Low | New / Known / Resolving | What needs to happen |

## Decisions Made
- **Decision** — Context and rationale. (Date or commit ref if known)

## Next Steps
- [ ] Highest priority action item
- [ ] Second priority
- [ ] Third priority

## Notes
Any additional context, shout-outs, or observations worth capturing.
```

## Implementation Rules

1. **Ground everything in data.** Every claim in the report should be traceable to a commit, file, or conversation point. Don't invent progress.
2. **Use the health table honestly.** 🟢 means no concerns. 🟡 means watch closely. 🔴 means needs immediate attention. Don't default to all green.
3. **Quantify where possible.** "Fixed 3 bugs" is better than "Fixed bugs." Include commit counts, file counts, line changes.
4. **Group completed work by category** (features, fixes, refactoring, docs, infra) — not by date or commit order.
5. **Include file paths and commit hashes** so readers can drill into details.
6. **Keep it skimmable.** Stakeholders read the TL;DR and health table first. Details are for those who want them.
7. **Save location:**
   - If inside a git project, save to `status-reports/YYYY-MM-DD-status.md` in the project root (create directory if needed).
   - If no project context, save to `~/status-reports/YYYY-MM-DD-status.md`.
   - If a file with that name exists, append a counter (`-2`, `-3`).
8. **Tell the user** the output path when done.
9. **Write the file directly** using the Write tool — no external libraries needed.
10. **Do NOT run tests or builds** unless the user explicitly asks. Only report what you can observe from git history, code, and conversation.
