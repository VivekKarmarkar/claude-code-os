# Swarm — Spin Up an Autonomous Agent Team

Create an agentic swarm that breaks down a project into tasks and executes them autonomously with bypassed permissions. You act as the team lead, agents do the work without stopping to ask for permission on every file write or bash command.

## Arguments

`<project description or task list>` — What the swarm should build, fix, or accomplish. Can be a high-level goal ("build a REST API with auth and tests") or a specific task list.

If no arguments are provided, ask the user what they want the swarm to work on.

## Workflow

### Step 1: Understand the Project

Before spinning up any agents, discuss with the user:

1. **What's the goal?** — What should the swarm produce?
2. **Scope check** — Is this a new project from scratch, or modifications to an existing codebase?
3. **Constraints** — Any tech stack preferences, patterns to follow, files not to touch?
4. **Working directory** — Where should the work happen?

If the user has already provided enough detail in the arguments, skip straight to planning.

### Step 2: Break Down into Tasks

Create a task breakdown with clear, independent units of work. Each task should be:

- **Self-contained** — An agent can complete it without needing output from another task (unless explicitly marked as dependent)
- **Specific** — Clear acceptance criteria, not vague goals
- **Scoped** — One agent, one task, one clear deliverable

Use `TaskCreate` to create each task with:
- `subject`: Short imperative title (e.g., "Implement user authentication endpoint")
- `description`: Detailed instructions including file paths, expected behavior, and acceptance criteria
- `activeForm`: Present continuous form for the spinner (e.g., "Implementing auth endpoint")

Set up dependencies with `TaskUpdate` using `addBlockedBy` where tasks must execute in order.

### Step 3: Create the Team

Use `TeamCreate` to set up the team:

```
TeamCreate:
  team_name: "<project-slug>"
  description: "<project description>"
```

### Step 4: Spawn Agents with Bypassed Permissions

For each task (or group of related tasks), spawn a worker agent using the `Task` tool with:

- `subagent_type`: "general-purpose" (for implementation tasks) or "Explore" (for research tasks)
- `mode`: "bypassPermissions" — **THIS IS THE KEY**. Workers execute freely without permission prompts.
- `team_name`: The team name from Step 3
- `name`: Descriptive name (e.g., "auth-worker", "test-writer", "api-builder")

**Spawn independent agents in parallel** for maximum speed. Only serialize agents that have task dependencies.

Example:
```
Task:
  subagent_type: general-purpose
  mode: bypassPermissions
  team_name: my-project
  name: auth-worker
  prompt: "You are a teammate on the 'my-project' team. Your task is to implement user authentication..."
```

### Step 5: Monitor and Coordinate

As the team lead:

1. **Watch for messages** — Agents will message you when they complete tasks or hit blockers
2. **Check task list** — Use `TaskList` periodically to see progress
3. **Unblock agents** — If an agent is stuck, send guidance via `SendMessage`
4. **Reassign work** — If one agent finishes early, assign them another task
5. **Quality check** — Read key files after agents complete their tasks to verify quality

### Step 6: Wrap Up

When all tasks are complete:

1. Run tests if applicable: `npm test`, `pytest`, `cargo test`, etc.
2. Review the work with the user — summarize what was built
3. Send shutdown requests to all agents
4. Clean up the team with `TeamDelete`
5. Report final status to the user

## Agent Prompt Template

When spawning worker agents, include this context in their prompt:

```
You are a teammate on the '{team_name}' team. You have full permissions to read, write, and execute files.

Your assigned task: {task_description}

Working directory: {working_directory}

Guidelines:
- Complete your task fully before reporting back
- If you hit a blocker, message the team lead immediately
- Mark your task as completed when done using TaskUpdate
- Write clean, working code — no placeholders or TODOs
- Run relevant tests after making changes
- Follow existing code patterns in the project
```

## Rules

1. **Always discuss the project with the user first** before spawning agents. Don't assume scope.
2. **bypassPermissions is the default for all worker agents.** That's the whole point of /swarm — autonomous execution.
3. **The team lead (you) keeps normal permissions.** Only workers bypass.
4. **Spawn agents in parallel** when tasks are independent. Don't serialize unnecessarily.
5. **Monitor actively.** Check in on agents, read their outputs, verify quality.
6. **Clean up when done.** Shut down agents and delete the team.
7. **If an agent produces bad code**, fix it yourself or respawn the agent with better instructions. Don't let bad work persist.
8. **Report progress to the user** at key milestones — not just at the end.
9. **Maximum 5 concurrent agents** to avoid overwhelming the system. Queue additional tasks.
10. **Always run tests** at the end if the project has a test suite.
