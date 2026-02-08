# Refactor — Deep Codebase Cleanup

Perform a meticulous, thorough refactoring of the codebase. The goal is pristine, readable, efficient code — not feature changes. Behavior stays the same, quality goes way up.

## Arguments

`<scope>` — Optional. What to refactor.

Examples:
- `/refactor` — refactor the entire project
- `/refactor src/auth/` — refactor only the auth module
- `/refactor utils.py` — refactor a single file

If no arguments, refactor the whole project.

## Philosophy

- **Preserve behavior exactly.** Refactoring means the code does the same thing, but better. No feature additions, no behavior changes, no "while we're here" improvements.
- **Readability is king.** Code is read 10x more than it's written. Optimize for the next person reading it.
- **Every file should tell a story.** A reader should understand what a file does from its name, its opening comment, and its structure — without reading every line.

## Workflow

### Step 1: Audit the Codebase

Before changing anything, understand everything.

1. Map the full project structure — every directory, every file.
2. Read every file. No skimming. Understand what each file does, what it exports, who calls it.
3. Identify the dependency graph — which files import from which.
4. Note the tech stack, frameworks, and patterns already in use.
5. Run existing tests if they exist (`npm test`, `pytest`, `cargo test`, etc.) and record the results. This is your baseline — tests must still pass after refactoring.

### Step 2: Build the Refactoring Plan

Create a detailed plan covering these categories. Present it to the user for approval before making any changes.

**A. File & Directory Structure**
- Are files in logical directories? (e.g., routes with routes, models with models)
- Are there files doing too many things that should be split?
- Are there tiny files that should be merged?
- Do filenames clearly describe their contents?
- Proposed renames and moves.

**B. Naming**
- Variables: descriptive, no abbreviations unless universally understood (`i`, `err`, `ctx` are fine; `usr`, `tmp`, `mgr` are not)
- Functions: verb-first, clear about what they do (`getUserById`, not `fetch` or `getData`)
- Classes/types: noun-based, specific (`PaymentProcessor`, not `Handler`)
- Constants: SCREAMING_SNAKE_CASE with meaningful names
- Files: kebab-case or snake_case consistently, matching the project's convention
- Flag any single-letter variables (except loop counters), unclear abbreviations, or misleading names.

**C. Code Comments**
- Every file gets a top-level docstring/comment explaining:
  - What this file is responsible for
  - Key exports or entry points
  - Any non-obvious context (e.g., "This runs as a cron job every 5 minutes")
- Functions get a brief comment if their name alone doesn't fully explain:
  - What they do
  - Any non-obvious parameters or return values
  - Side effects
- Remove stale comments that describe code that no longer exists.
- Remove obvious comments ("increment counter", "return the value").
- Add comments where the WHY is not obvious — tricky logic, workarounds, performance choices.

**D. Code Quality**
- Dead code: remove unused functions, imports, variables, commented-out blocks.
- Duplication: extract repeated logic into shared utilities.
- Long functions: break into smaller, focused functions (aim for functions that do one thing).
- Deep nesting: flatten with early returns, guard clauses.
- Magic numbers/strings: extract to named constants.
- Error handling: consistent patterns, no swallowed errors, clear error messages.
- Type safety: add types/annotations where the language supports them and the project uses them.

**E. Import/Dependency Hygiene**
- Remove unused imports.
- Group and sort imports consistently (stdlib → third-party → local).
- Eliminate circular dependencies.

### Step 3: Execute the Refactoring

Work file by file, methodically:

1. Start with the lowest-level utilities and work up to the entry points.
2. After refactoring each file, verify it still works (run tests if available, check for import errors).
3. Keep a running log of every change made:
   ```
   [file] what changed and why
   ```

### Step 4: Verify

1. Run the full test suite. Compare against the baseline from Step 1. Every test that passed before must pass now.
2. If there are no tests, do a manual sanity check — run the app, hit key endpoints, verify core functionality.
3. Check for regressions: `git diff` the full changeset and review it yourself before presenting to the user.

### Step 5: Report

Show the user a summary:

```
Refactoring Complete
═══════════════════════════════════
Files modified:  N
Files renamed:   N
Files moved:     N
Files deleted:   N (dead code)

Key changes:
  - <brief description of each major change>

Tests: all passing (N/N)
═══════════════════════════════════
```

## Rules

1. **Never change behavior.** If you're tempted to "fix" something that works but looks wrong, flag it to the user instead of changing it.
2. **Run tests before and after.** If tests break, undo and try again.
3. **Present the plan first.** Don't start refactoring without the user approving the plan from Step 2.
4. **Respect existing conventions.** If the project uses tabs, use tabs. If it uses camelCase, use camelCase. Don't impose your preferences.
5. **Don't refactor config files** (.env, package.json, Cargo.toml, etc.) unless they have clear issues like unused dependencies.
6. **Commit-ready output.** When you're done, the code should be ready to commit — no TODOs, no half-finished renames, no broken imports.
