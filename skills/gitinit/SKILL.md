# Git Init — Initialize a Private Git Repo

Set up a private GitHub repo for the current project in one step.

## Arguments

`<project name>` — Optional. Used as the GitHub repo name. If not provided, use the current directory name.

Examples:
- `/gitinit` — uses current folder name
- `/gitinit my-cool-app` — creates repo named "my-cool-app"

## Workflow

### Step 1: Pre-flight Checks

1. Check if the current directory already has a git repo (`git rev-parse --git-dir`).
   - If yes, tell the user: "This directory is already a git repo." Then check if it has a GitHub remote — if not, offer to create one. If it does, stop.
2. Check that `gh` CLI is installed and authenticated (`gh auth status`).
   - If not, tell the user to run `gh auth login` first.

### Step 2: Initialize

1. Run `git init`
2. Create a `.gitignore` appropriate for the project. Scan the directory for clues:
   - If `package.json` exists → Node.js gitignore (node_modules, dist, .env, etc.)
   - If `requirements.txt` or `pyproject.toml` exists → Python gitignore (__pycache__, venv, .env, etc.)
   - If `Cargo.toml` exists → Rust gitignore (target/, etc.)
   - If `go.mod` exists → Go gitignore
   - If none of the above, use a minimal universal gitignore (.env, .DS_Store, *.log, tmp/)
   - Always include: `.env`, `.env.local`, `.DS_Store`, `*.log`
3. Stage everything: `git add -A`
4. Create initial commit: `git commit -m "Initial commit"`

### Step 3: Create Private GitHub Repo

1. Determine the repo name:
   - Use the argument if provided
   - Otherwise use the current directory name (`basename "$PWD"`)
2. Run: `gh repo create <repo-name> --private --source=. --push`
3. Confirm to the user:
   ```
   Repo created: https://github.com/<username>/<repo-name> (private)
   ```

## Rules

- **Always private.** Never create a public repo. The user can change visibility later on GitHub if they want.
- **Never overwrite an existing .gitignore.** If one already exists, leave it alone.
- **Don't commit secrets.** If you spot `.env` files, credentials, or API keys in the directory, make sure they're in `.gitignore` before the initial commit.
- **Keep it simple.** No branches, no worktrees, no CI setup. Just init, commit, push. Done.
