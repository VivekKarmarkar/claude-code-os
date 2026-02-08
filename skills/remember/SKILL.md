---
name: remember
description: Commit important information to the persistent memory graph. Use when the user wants to save facts, preferences, decisions, project context, or lessons learned so they persist across conversations.
argument-hint: [what to remember]
---

# Remember — Commit to Memory Graph

Save information to the persistent knowledge graph using the MCP memory tools so it survives across conversations.

## Modes

**Explicit mode** — If `$ARGUMENTS` is provided (e.g., `/remember prefers dark theme for all slides`), store exactly that information.

**Session scan mode** — If no arguments, scan the current conversation and extract everything worth remembering:
- User preferences and conventions
- Decisions made and their rationale
- Project architecture and patterns discovered
- Tool configurations and setups
- Bugs encountered and how they were fixed
- Key relationships between systems/components
- Lessons learned

## How to Store

Use the MCP memory tools to structure information properly:

### 1. Create Entities
For each distinct concept, person, project, tool, or preference, create an entity:

```
mcp__memory__create_entities:
  - name: "ProjectName"
    entityType: "project"
    observations: ["Uses React + TypeScript", "Deployed on Vercel"]
```

**Entity types to use:**
- `person` — the user, collaborators, stakeholders
- `project` — repos, apps, services
- `preference` — user preferences, conventions, style choices
- `decision` — architectural or design decisions with rationale
- `tool` — tools, libraries, frameworks with config details
- `pattern` — code patterns, workflows, recurring approaches
- `issue` — bugs, problems, gotchas encountered
- `concept` — domain concepts, technical terms with definitions
- `environment` — system setup, paths, installed software

### 2. Add Observations
For existing entities that need new facts:

```
mcp__memory__add_observations:
  - entityName: "ProjectName"
    contents: ["Added authentication via Auth0 on 2026-02-05"]
```

### 3. Create Relations
Link entities together:

```
mcp__memory__create_relations:
  - from: "User"
    to: "DarkTheme"
    relationType: "prefers"
```

**Common relation types:**
- `prefers`, `uses`, `owns`, `maintains`
- `depends_on`, `integrates_with`, `deployed_on`
- `decided_on`, `blocked_by`, `resolved_by`
- `part_of`, `related_to`, `replaced_by`

## Workflow

1. **Check existing memory first** — Use `mcp__memory__search_nodes` to see if entities already exist. Update them with `add_observations` rather than creating duplicates.
2. **Structure the information** — Break it into entities, observations, and relations.
3. **Store it** — Create entities, add observations, create relations.
4. **Confirm to the user** — Print a summary of what was stored:

```
Remembered:

Entities created:
  - [project] MyApp — "React + TypeScript app, deployed on Vercel"
  - [decision] UseAuth0 — "Chose Auth0 over Clerk for SSO support"

Observations added:
  - MyApp: "Added rate limiting to API endpoints"

Relations created:
  - MyApp → uses → Auth0
  - User → prefers → DarkTheme
```

## Rules

1. **Search before creating.** Always check if an entity exists before creating a new one. Use `search_nodes` first.
2. **Be specific in observations.** "Uses React" is fine. "Uses React 18 with Next.js 14 App Router" is better.
3. **Include dates** when the information is time-sensitive (decisions, changes, events).
4. **Don't store trivial information.** Skip things like "user said hello" or single-use debugging steps.
5. **Use consistent entity names.** PascalCase for entities (e.g., `MyProject`, `DarkThemePreference`). Check existing names to stay consistent.
6. **Store the "why" not just the "what".** For decisions, include the reasoning: "Chose PostgreSQL over MongoDB because of relational data needs and ACID compliance."
7. **Keep observations atomic.** One fact per observation string. Don't cram multiple unrelated facts into one observation.
