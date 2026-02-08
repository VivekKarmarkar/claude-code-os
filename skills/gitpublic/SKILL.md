# Git Public — Make a Private Repo Public

Change the current project's GitHub repo from private to public.

## Arguments

None. Operates on the current directory's repo.

## Workflow

### Step 1: Pre-flight Checks

1. Confirm the current directory is a git repo (`git rev-parse --git-dir`). If not, stop.
2. Check that a GitHub remote exists (`gh repo view --json visibility,nameWithOwner`). If not, stop.
3. Read the current visibility. If already public, tell the user and stop.

### Step 2: Confirm with the User

Show the repo name and warn:

```
Repo: <owner>/<repo-name>
Status: private → public

This will make the repo visible to everyone on the internet.
Are you sure?
```

Wait for explicit confirmation. Do NOT proceed without it.

### Step 3: Make Public

1. Run: `gh repo edit --visibility public`
2. Confirm: "Done. <owner>/<repo-name> is now public."

## Rules

- **Always ask for confirmation.** This is irreversible in practice — making a repo public exposes its entire history.
- **Never make a repo public without the user explicitly saying yes.**
- **Warn about secrets.** Before confirming, run a quick check: `git log --all --oneline | head -20` and remind the user: "Make sure there are no secrets or credentials in the commit history."
