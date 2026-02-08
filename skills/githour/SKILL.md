# Git Hour — Refactor, Init, Commit, Publish

Take a project from messy code to a clean public GitHub repo in one sequence. Runs four skills in order, stopping if any step fails.

## Arguments

`<project name>` — Optional. Used as the GitHub repo name. If not provided, uses the current directory name.

## Sequence

Execute these skills in this exact order. Complete each one fully before moving to the next. If any step fails, stop and report which step failed and why.

### Step 1: `/refactor`

Run the full refactor skill on the codebase:
- Audit every file
- Build and present the refactoring plan
- Get user approval
- Execute the refactoring
- Verify tests still pass
- Show the refactoring report

**Gate:** Do not proceed to Step 2 until the user confirms they're happy with the refactored code.

### Step 2: `/gitinit`

Initialize a private git repo:
- Check if a git repo already exists (if yes, skip this step)
- `git init`
- Create appropriate `.gitignore`
- Initial commit
- `gh repo create --private --push`

**Gate:** Repo must be created successfully before proceeding.

### Step 3: `/gitcommit`

Commit and push the refactored code:
- If Step 2 already committed everything and there are no new changes, skip this step
- Otherwise, stage, commit with a message like "Refactored codebase", and push

**Gate:** Push must succeed before proceeding.

### Step 4: `/gitpublic`

Make the repo public:
- Show the repo name and warn about visibility change
- Get explicit user confirmation
- `gh repo edit --visibility public`

**Gate:** User must explicitly confirm before making public.

## After Completion

Show a final summary:

```
Git Hour Complete
═══════════════════════════════════
Refactored:  N files modified
Repo:        https://github.com/<user>/<repo>
Visibility:  public
Status:      all changes committed and pushed
═══════════════════════════════════
```

## Rules

1. **Sequential, not parallel.** Each step must fully complete before the next begins.
2. **User gates matter.** Steps 1 and 4 require explicit user approval before proceeding. Don't rush past them.
3. **Skip intelligently.** If a git repo already exists, skip Step 2. If there are no uncommitted changes, skip Step 3.
4. **Stop on failure.** If any step fails, stop and tell the user what went wrong. Don't try to continue.
5. **Follow each skill's rules.** Each step follows its own SKILL.md — don't cut corners (e.g., the refactor still needs a plan, gitpublic still needs confirmation).
