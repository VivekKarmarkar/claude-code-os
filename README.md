# Claude Code Skills & Plugins

Backup of my [Claude Code](https://claude.ai/claude-code) skills and plugins. Auto-synced via a PostToolUse hook whenever a skill or plugin is added or edited.

## Skills (18)

| Skill | Description |
|-------|-------------|
| `cooldown` | End-of-session artifact generation (slides, PDF, summary, roadmap, status) |
| `makesong` | Create songs via Suno |
| `makevideo` | Create videos with Manim |
| `manim-composer` | Plan scene-by-scene Manim video sequences from vague ideas |
| `manimce-best-practices` | Best practices for Manim Community Edition |
| `manimgl-best-practices` | Best practices for ManimGL (3Blue1Brown version) |
| `medium` | Write and publish to Medium |
| `pdf` | Read, create, merge, split, fill, and manipulate PDFs |
| `playground` | Create interactive single-file HTML playgrounds |
| `pptx` | Create and edit PowerPoint presentations |
| `prism` | Work with Prism (OpenAI LaTeX editor) |
| `projectstatus` | Generate project status reports |
| `remember` | Save facts and preferences to persistent memory |
| `remotion-best-practices` | Best practices for Remotion (React video) |
| `roadmap` | Create project roadmaps and milestone plans |
| `summary` | Summarize chat sessions to markdown |
| `swarm` | Multi-agent swarm coordination |
| `tweet` | Compose tweets |
| `warmup` | Start-of-session context loading |

## Plugins (28)

| Plugin | Description |
|--------|-------------|
| `agent-sdk-dev` | Agent SDK development helpers |
| `clangd-lsp` | C/C++ language server |
| `claude-code-setup` | Claude Code automation recommender |
| `claude-md-management` | Audit and improve CLAUDE.md files |
| `code-review` | Code review for pull requests |
| `code-simplifier` | Simplify complex code |
| `commit-commands` | Git commit, push, PR, and branch cleanup |
| `csharp-lsp` | C# language server |
| `example-plugin` | Reference plugin template |
| `explanatory-output-style` | Explanatory output formatting |
| `feature-dev` | Guided feature development |
| `frontend-design` | Production-grade frontend UI design |
| `gopls-lsp` | Go language server |
| `hookify` | Create and manage hook rules |
| `jdtls-lsp` | Java language server |
| `kotlin-lsp` | Kotlin language server |
| `learning-output-style` | Learning-oriented output formatting |
| `lua-lsp` | Lua language server |
| `php-lsp` | PHP language server |
| `playground` | Interactive HTML playground creator |
| `plugin-dev` | Plugin, skill, hook, and command development |
| `pr-review-toolkit` | Comprehensive PR review with specialized agents |
| `pyright-lsp` | Python language server |
| `ralph-loop` | Autonomous Ralph Loop |
| `rust-analyzer-lsp` | Rust language server |
| `security-guidance` | Security reminders and guidance |
| `swift-lsp` | Swift language server |
| `typescript-lsp` | TypeScript language server |

## Auto-Backup

A PostToolUse hook watches for writes to `~/.claude/skills/` and `~/.claude/plugins/`. On any change it:

1. Syncs to a local backup at `~/skills-backup/`
2. Commits and pushes to this repo
