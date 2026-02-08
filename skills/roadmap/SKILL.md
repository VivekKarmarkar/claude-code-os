---
name: roadmap
description: Create a project roadmap document. Use when the user wants to plan milestones, phases, deliverables, timelines, or a project plan — either for the current project based on its codebase or for a new idea/topic.
argument-hint: [project name or goal]
---

# Project Roadmap Generator

Create a structured project roadmap as a markdown file. The roadmap should be practical, actionable, and easy to share with a team.

## Modes

**Project mode** — If invoked inside a git project with no arguments or with project-related arguments (e.g., `/roadmap`), analyze the codebase — look at the repo structure, README, open TODOs, issues, recent commits, and conversation context — to generate a roadmap for the project's next steps.

**Topic mode** — If `$ARGUMENTS` describes a new project or goal (e.g., `/roadmap SaaS billing system`), create a roadmap from scratch based on that idea.

**Focused mode** — If `$ARGUMENTS` targets a specific area (e.g., `/roadmap API v2 migration`), scope the roadmap to just that initiative.

## Research Steps (before writing)

When in project mode, gather context first:
1. Read `README.md`, `CLAUDE.md`, `package.json`, `pyproject.toml`, or similar project files for scope.
2. Search for `TODO`, `FIXME`, `HACK` comments in the codebase.
3. Check `git log --oneline -20` for recent activity and direction.
4. Check for any issues or PR templates that hint at planned work.
5. Review the current conversation for discussed plans or pain points.

## Roadmap Structure

```markdown
# Project Roadmap: <Project Name>

> **Created:** YYYY-MM-DD
> **Status:** Draft
> **Owner:** <from git config or leave blank>

## Vision
One or two sentences on what this project aims to achieve and where it's headed.

## Current State
Brief assessment of where things stand today.
- What's working
- What's not
- Key metrics or facts

---

## Phase 1: <Name> — Foundation
**Goal:** What this phase achieves
**Status:** Not Started | In Progress | Complete

| Priority | Task | Description | Dependencies |
|----------|------|-------------|-------------|
| P0 | Task name | What needs to happen | Blocked by X |
| P1 | Task name | What needs to happen | — |
| P2 | Task name | What needs to happen | Requires task above |

**Exit criteria:**
- [ ] Criteria that must be true to move to Phase 2

---

## Phase 2: <Name> — Build Out
**Goal:** What this phase achieves
**Status:** Not Started

| Priority | Task | Description | Dependencies |
|----------|------|-------------|-------------|
| P0 | Task name | What needs to happen | — |
| P1 | Task name | What needs to happen | — |

**Exit criteria:**
- [ ] Criteria that must be true to move to Phase 3

---

## Phase 3: <Name> — Polish & Scale
**Goal:** What this phase achieves
**Status:** Not Started

| Priority | Task | Description | Dependencies |
|----------|------|-------------|-------------|
| P0 | Task name | What needs to happen | — |
| P1 | Task name | What needs to happen | — |

**Exit criteria:**
- [ ] Criteria for this phase being done

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|-----------|
| Risk description | High/Med/Low | High/Med/Low | How to handle it |

## Open Questions
- Decisions that need to be made before or during execution
- Technical or product unknowns

## Out of Scope
- Things explicitly NOT part of this roadmap
- Helps prevent scope creep
```

## Implementation Rules

1. **Use 3-5 phases.** Each phase should be a meaningful chunk of work with clear exit criteria.
2. **Prioritize tasks** using P0 (must-have), P1 (should-have), P2 (nice-to-have).
3. **Be specific.** "Improve performance" is bad. "Add Redis caching to /api/users endpoint" is good.
4. **Include dependencies** so the reader understands ordering constraints.
5. **Exit criteria as checkboxes** — these are the "definition of done" for each phase.
6. **Risks table** — always include at least 2-3 realistic risks.
7. **Out of Scope** — always include this section to set boundaries.
8. **Save location:**
   - If inside a git project, save to the project root as `ROADMAP.md`.
   - If no project context, save to `~/roadmaps/YYYY-MM-DD-<slugified-name>.md` (create directory if needed).
   - If a file with that name already exists, ask the user whether to overwrite or create a new versioned file.
9. **Tell the user** the output path when done.
10. **Write the file directly** using the Write tool — no external libraries needed.
11. For project mode, **ground everything in the actual codebase** — don't invent features or tasks that have no basis in the code or conversation.
