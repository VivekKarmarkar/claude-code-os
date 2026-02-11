# Improve — Autonomous Agent Improvement Game

Engineer "computational addiction" for agents improving codebases. Agents work on git branches, get immediate quantitative feedback from score functions, and iterate until targets are hit — no human in the loop during work cycles.

**Project-agnostic** — works on any repo with a `game.toml` config.

## Arguments

- `/improve` — Show scoreboard, suggest next issue
- `/improve init` — Auto-detect stack, generate `game.toml`, establish baselines
- `/improve status` — Scoreboard + active branches + composite score
- `/improve run <issue-id>` — Start the tight work+score loop on a branch
- `/improve score` — Quick: run all score functions, show results
- `/improve backlog` — Show issues ranked by impact

---

## Command: `/improve init`

### Step 1: Detect Stack

Scan the project root for indicators:

| File | Stack Signal |
|------|-------------|
| `package.json` | Node/JS/TS |
| `requirements.txt` / `pyproject.toml` | Python |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `Gemfile` | Ruby |
| `pom.xml` / `build.gradle` | Java/Kotlin |
| `Makefile` | C/C++ |

Also detect: test frameworks (pytest, jest, vitest, cargo test), linters (eslint, ruff, clippy), build tools (vite, webpack, cargo).

### Step 2: Generate `game.toml`

Create `game.toml` at project root with auto-detected score functions and canaries. Present the generated config to the user for review before writing.

The config schema:

```toml
[project]
name = "project-name"          # From directory or package.json/pyproject.toml
main_branch = "main"           # Auto-detect from git
branch_prefix = "improve/"     # Branch naming convention

[safety]
protected_paths = [".env", "secrets/", "*.key"]
max_files_changed_per_issue = 50
required_tests_passing = true

# Score functions: shell command that outputs a single number on its last line
[[scores]]
name = "score_name"
command = "shell command"       # Must output a single number on last line
type = "numeric"               # "numeric", "pass_rate", or "boolean"
weight = 1.0                   # Importance multiplier for composite score
direction = "up"               # "up" = higher is better, "down" = lower is better
baseline = 0.0                 # Current value (set during init)
floor = 0.0                    # Hard limit — never regress below (for "up")
ceiling = 0.0                  # Aspirational best (for "down" metrics)
deterministic = true           # If false, run 3x and take median

# Issues: what agents work on
[[issues]]
id = "issue-id"
title = "Human-readable description"
target_scores = { score_name = 10.0 }   # When is this issue "done"?
difficulty = "easy"            # "easy", "medium", "hard"
tags = ["performance"]
paths = ["src/"]               # Paths this issue touches (for conflict detection)

# Canary tests: MUST pass after every single change
[[canaries]]
name = "canary_name"
command = "shell command"      # Exit code 0 = pass, non-zero = fail
```

### Step 3: Establish Baselines

Run every `[[scores]]` command and record the current value as `baseline`. For non-deterministic scores (`deterministic = false`), run 3x and take the median.

### Step 4: Create State Directory

```bash
mkdir -p .game/history .game/runs
echo ".game/" >> .gitignore   # If not already there
```

Write `.game/scoreboard.json`:

```json
{
  "project": "project-name",
  "last_updated": "ISO-timestamp",
  "scores": {
    "score_name": {
      "current": 16.0,
      "baseline": 16.0,
      "best": 16.0,
      "direction": "down",
      "weight": 2.0
    }
  },
  "composite": 50.0,
  "total_improvements": 0,
  "total_cycles": 0,
  "completed_issues": []
}
```

### Step 5: Display Initial Scoreboard

Show the scoreboard (see Display Formats below) and confirm initialization is complete.

---

## Command: `/improve` or `/improve status`

### Step 1: Load State

Read `game.toml` and `.game/scoreboard.json`. If either is missing, prompt the user to run `/improve init`.

### Step 2: Run All Scores (Live)

Execute every `[[scores]]` command and capture current values.

### Step 3: Display Scoreboard

Use the scoreboard format (see Display Formats).

### Step 4: Show Active Branches

```bash
git branch --list 'improve/*'
```

For each active branch, show: branch name, commit count ahead of main, time since last commit.

### Step 5: Suggest Next Issue

From `[[issues]]` in `game.toml`, find the uncompleted issue with the lowest difficulty that has no path conflicts with active branches. Suggest it.

---

## Command: `/improve score`

Quick mode — just run all score functions and display results. No state changes, no suggestions.

1. Read `game.toml`
2. Execute each `[[scores]]` command
3. Parse output (last line → number)
4. Display scoreboard with current vs baseline vs best
5. Calculate and show composite score

---

## Command: `/improve backlog`

Show all `[[issues]]` from `game.toml`, ranked by:
1. Completed issues at the bottom (grayed out)
2. Then by difficulty: easy → medium → hard
3. Show target scores for each issue
4. Flag path conflicts with active branches

---

## Command: `/improve run <issue-id>`

This is the core game engine — the tight feedback loop.

### Pre-Flight

1. Read `game.toml` and find the issue by `id`. Error if not found.
2. Read `.game/scoreboard.json` for current bests.
3. Run all canaries. If any fail, STOP — project must be in a clean state to start.
4. Run all score functions to get "before" snapshot.
5. Save before snapshot to `.game/history/<issue-id>_before_<timestamp>.json`.
6. Create and checkout a new branch:
   ```bash
   git checkout -b improve/<issue-id>
   ```

### The Work+Score Loop

This is the addictive core. Run up to **15 cycles** (hard limit):

```
CYCLE N of 15:

  [WORK]    Make a focused change (1-3 files max).
            The change should directly target the issue's target_scores.
            Think carefully about WHAT to change before changing it.
            Read relevant code first. Understand before modifying.

  [SCORE]   Run the issue's target score function(s).
            Parse the number from the last line of output.
            For non-deterministic scores, run 3x and take median.

  [DECIDE]  Compare to previous cycle's score:
            - IMPROVED or EQUAL → proceed to canary check
            - REGRESSED → revert ALL changes from this cycle:
              git checkout -- .
              Log: "Cycle N: REVERTED — score went from X to Y"
              Continue to next cycle (try a different approach)

  [CANARY]  Run ALL canary tests.
            - ALL PASS → proceed to commit
            - ANY FAIL → revert ALL changes:
              git checkout -- .
              Log: "Cycle N: REVERTED — canary 'name' failed"
              Continue to next cycle

  [FLOOR]   Run ALL score functions (not just target).
            - ANY score below its floor → revert:
              git checkout -- .
              Log: "Cycle N: REVERTED — 'metric' below floor (X < Y)"
              Continue to next cycle

  [COMMIT]  Stage and commit with structured message:
            git add <specific files>
            git commit -m "<issue-id>: <description> (<metric>: <before> → <after>)"
            Example: "speed-01: parallelize API calls (pipeline_speed: 14.2s → 13.1s)"

  [LOG]     Record cycle result:
            Cycle N: <description> — <metric>: <before> → <after> [COMMITTED/REVERTED]

  [CHECK]   Has the target been hit?
            Compare current scores to issue's target_scores.
            ALL targets met → VICTORY! Break out of loop.
```

### File Limit Check

Before committing, count files changed in this cycle. If more than `max_files_changed_per_issue` total files changed on the branch, STOP and warn.

### Post-Run

After the loop ends (target hit, 15 cycles, or manual stop):

1. Run all score functions one final time.
2. Save after snapshot to `.game/history/<issue-id>_after_<timestamp>.json`.
3. Update `.game/scoreboard.json` with new bests.
4. Save run log to `.game/runs/<issue-id>_complete.json`:
   ```json
   {
     "issue_id": "speed-01",
     "branch": "improve/speed-01",
     "started": "ISO-timestamp",
     "completed": "ISO-timestamp",
     "cycles": 7,
     "cycles_committed": 5,
     "cycles_reverted": 2,
     "before_scores": { "pipeline_speed": 16.0 },
     "after_scores": { "pipeline_speed": 11.8 },
     "target_scores": { "pipeline_speed": 12.0 },
     "target_hit": true,
     "files_changed": ["backend/app/services/pipeline.py", "..."],
     "commit_log": [
       "speed-01: parallelize API calls (pipeline_speed: 16.0 → 14.2)",
       "..."
     ]
   }
   ```

5. Display victory banner if target hit, or progress report if not.

### Victory Banner

```
================================================================
  TARGET ACHIEVED — speed-01
================================================================

  "Reduce pipeline latency to under 12s"

  pipeline_speed:  16.0s  →  11.8s   (26% improvement)

  Cycles: 7 total (5 committed, 2 reverted)
  Branch: improve/speed-01
  Files changed: 3

  COMPOSITE SCORE:  72.4 → 81.2  (+8.8 POINTS)

  Ready to merge: git checkout main && git merge improve/speed-01
================================================================
```

### Progress Report (target not hit)

```
================================================================
  PROGRESS REPORT — speed-01  (target not yet hit)
================================================================

  pipeline_speed:  16.0s  →  13.4s   (16% improvement, target: 12.0s)

  Cycles: 15 total (11 committed, 4 reverted)
  Branch: improve/speed-01
  Remaining gap: 1.4s

  Run `/improve run speed-01` again to continue.
================================================================
```

---

## Scoreboard Display Format

```
IMPROVEMENT GAME — <project-name>
================================================================

SCOREBOARD                          Current    Baseline    Delta
----------------------------------------------------------------
<score_name> (x<weight>)            <current>  <baseline>  <delta>  [IMPROVED]
<score_name> (x<weight>)            <current>  <baseline>  <delta>
...

COMPOSITE SCORE:  <score> / 100   (was <baseline>)  +<delta> POINTS

ACTIVE BRANCHES
  improve/<id>   — <N> commits — last: <time ago>
  ...

COMPLETED ISSUES
  [x] <id>: <title>  — <improvement summary>
  ...

NEXT SUGGESTED: <id> "<title>"
================================================================
```

Delta formatting:
- direction="up": positive delta = green/IMPROVED, negative = red
- direction="down": negative delta = green/IMPROVED (lower is better), positive = red
- For "pass_rate" type, display as percentage (e.g., "100.0%")
- For "boolean" type, display as PASS/FAIL
- For "numeric" type, display raw number with unit if obvious (e.g., "s" for seconds)

---

## Composite Score Formula

For each metric, calculate progress toward its target/ideal:

**direction="up"** (higher is better):
```
progress = (current - floor) / (ceiling - floor)
```
where ceiling = best theoretical value (default: baseline * 1.5 if not set)

**direction="down"** (lower is better):
```
progress = (baseline - current) / (baseline - ceiling)
```
where ceiling = aspirational best

Clamp each progress to [0.0, 1.0], multiply by weight:
```
composite = sum(progress_i * weight_i) / sum(weight_i) * 100
```

---

## Score Function Protocol

### Output Parsing

Score commands MUST output a parseable number on their **last line** of stdout.

Parsing rules:
1. Take the last non-empty line of stdout
2. Extract the first number found (int or float, may include decimals)
3. For pass_rate: look for patterns like "X passed" or "X/Y" or "X%"
4. For boolean: exit code 0 = 1.0 (pass), non-zero = 0.0 (fail)

### Variance Handling

For scores with `deterministic = false`:
1. Run the command 3 times
2. Take the median value
3. Log all 3 values for transparency

### Timeout

Score commands have a **120-second timeout**. If a command exceeds this, treat it as a failure and log a warning.

---

## Multi-Branch / Swarm Mode

When multiple issues need work simultaneously, compose with the TeamCreate tools:

### Coordination Rules

1. **One agent per issue, one branch per issue.** Never share branches.
2. **Path conflict detection**: Issues with overlapping `paths` arrays are serialized. If Agent A is working on `backend/services/`, Agent B cannot start an issue that also touches `backend/services/`.
3. **Max 5 concurrent agents.**
4. **Each agent gets**: issue details, exact score commands, canary commands, commit format, 15-cycle limit.
5. **After any branch merges to main**, remaining branches should rebase:
   ```bash
   git checkout improve/<id> && git rebase main
   ```

### Agent Prompt Template

When spawning an improvement agent via Task tool, use this prompt structure:

```
You are an improvement agent working on issue "<issue-id>": "<title>"

BRANCH: improve/<issue-id>
TARGET: <metric> must reach <target-value> (currently <current-value>)

SCORE COMMAND:
  <command>
  Parse: last line of stdout → number
  Direction: <up/down> (lower/higher is better)

CANARY COMMANDS (must ALL pass after every change):
  <canary-1-name>: <command>
  <canary-2-name>: <command>

RULES:
1. Make focused changes — 1-3 files per cycle, max 15 cycles.
2. Run score after EVERY change.
3. NEVER commit a regression. If score worsens: git checkout -- .
4. NEVER commit if canaries fail. Revert and try differently.
5. Commit message format: "<issue-id>: <what you did> (<metric>: <before> → <after>)"
6. Read code before modifying. Understand before changing.
7. Each cycle should try ONE approach. Don't make multiple unrelated changes.
8. If stuck after 3 reverts in a row, try a fundamentally different strategy.
9. Log every cycle result clearly.
10. Stop when target is hit or 15 cycles exhausted.

WORK DIRECTORY: <project root>
```

---

## 10 Rules for Improvement Agents

1. **Score after every change.** Not after batches. Every. Single. Change.
2. **Never commit regressions.** If the number goes the wrong way, revert immediately.
3. **Canaries are sacred.** If the app doesn't start or tests don't pass, nothing else matters.
4. **Floor is a hard limit.** Even if your target metric improves, you CANNOT regress any other metric below its floor.
5. **One approach per cycle.** Make a focused change, measure, decide. Don't mix experiments.
6. **Read before you write.** Understand the code you're changing. No blind edits.
7. **Small commits.** Each commit should be reviewable in under 2 minutes.
8. **Log everything.** Every cycle gets a one-line summary: what you did, what happened.
9. **Know when to pivot.** Three consecutive reverts = your strategy isn't working. Try something fundamentally different.
10. **Celebrate wins.** When a target is hit, show the victory banner. The numbers matter.

---

## State Files

### `.game/scoreboard.json`

Persists across runs. Updated after every completed `/improve run`:

```json
{
  "project": "project-name",
  "last_updated": "2026-02-11T10:30:00Z",
  "scores": {
    "metric_name": {
      "current": 14.2,
      "baseline": 16.0,
      "best": 14.2,
      "direction": "down",
      "weight": 2.0
    }
  },
  "composite": 72.4,
  "total_improvements": 5,
  "total_cycles": 12,
  "completed_issues": ["speed-01"]
}
```

### `.game/history/<issue-id>_<before|after>_<timestamp>.json`

Snapshots of all scores before and after a run.

### `.game/runs/<issue-id>_complete.json`

Full run log including cycle-by-cycle results.

---

## Error Handling

- **`game.toml` not found**: Prompt user to run `/improve init`
- **`.game/` not found**: Prompt user to run `/improve init`
- **Score command fails** (non-zero exit, no parseable output): Log warning, skip that metric for this cycle. If it's the TARGET metric, abort the cycle (don't commit without knowing the score).
- **Canary command fails**: Always revert. No exceptions.
- **Git conflicts on branch**: Stop and inform the user. Don't auto-resolve.
- **Branch already exists**: If `improve/<issue-id>` exists, ask: resume (checkout existing) or restart (delete and recreate)?

---

## Gitignore

The init command adds `.game/` to `.gitignore` if not present. Score state is local — never committed.

---

## Examples

### Example: Speed Optimization

```
$ /improve run speed-01

PRE-FLIGHT
  Branch: improve/speed-01 (created)
  Target: pipeline_speed ≤ 12.0s (currently 16.0s)
  Canaries: app_starts ✓, tests_pass ✓

CYCLE 1 of 15:
  [WORK]   Parallelized GPT + segmentation calls in pipeline.py
  [SCORE]  pipeline_speed: 16.0s → 13.4s
  [CANARY] app_starts ✓  tests_pass ✓
  [FLOOR]  tests_passing: 100% (floor: 95%) ✓
  [COMMIT] speed-01: parallelize GPT and segmentation (pipeline_speed: 16.0s → 13.4s)

CYCLE 2 of 15:
  [WORK]   Added connection pooling for Replicate API
  [SCORE]  pipeline_speed: 13.4s → 13.6s
  [DECIDE] REGRESSED (13.4s → 13.6s) — REVERTING
  Reverted. Trying different approach.

CYCLE 3 of 15:
  [WORK]   Cached GPT system prompt to avoid re-tokenization
  [SCORE]  pipeline_speed: 13.4s → 12.1s
  [CANARY] app_starts ✓  tests_pass ✓
  [FLOOR]  tests_passing: 100% (floor: 95%) ✓
  [COMMIT] speed-01: cache GPT system prompt (pipeline_speed: 13.4s → 12.1s)

CYCLE 4 of 15:
  [WORK]   Reduced image preprocessing resolution
  [SCORE]  pipeline_speed: 12.1s → 11.8s
  [CANARY] app_starts ✓  tests_pass ✓
  [FLOOR]  tests_passing: 100% (floor: 95%) ✓
  [COMMIT] speed-01: reduce preprocessing resolution (pipeline_speed: 12.1s → 11.8s)

  TARGET ACHIEVED ✓  pipeline_speed: 11.8s ≤ 12.0s

================================================================
  TARGET ACHIEVED — speed-01
================================================================
  pipeline_speed:  16.0s  →  11.8s   (26% improvement)
  Cycles: 4 total (3 committed, 1 reverted)
  Branch: improve/speed-01
================================================================
```

### Example: Lint Cleanup

```
$ /improve run lint-01

CYCLE 1 of 15:
  [WORK]   Fixed 8 unused import warnings in routers/
  [SCORE]  lint_errors: 23 → 15
  [CANARY] app_starts ✓
  [COMMIT] lint-01: remove unused imports in routers (lint_errors: 23 → 15)
```
