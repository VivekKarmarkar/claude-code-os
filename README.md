# Claude Code OS for VivekKmk

My personalized operating system for Claude Code — skills, plugins, and hooks that extend what Claude can do. Auto-synced whenever anything is added or edited.

## Skills (34)

| Skill | Description |
|-------|-------------|
| `architectural-walkthrough-video` | Architectural Walkthrough Video: From System Design to Polished Video |
| `cooldown` | End-of-session cooldown that generates all project artifacts in sequence —… |
| `gitcommit` | Git Commit: Commit and Push |
| `githour` | Git Hour: Refactor, Init, Commit, Publish |
| `gitinit` | Git Init: Initialize a Private Git Repo |
| `gitpublic` | Git Public: Make a Private Repo Public |
| `litreview` | Literature Review: Research, Organize, Present |
| `litwebpage` | Lit Webpage: Literature Review to Polished Webpage |
| `makesong` | Make Song: Generate & Download Music with Suno |
| `makevideo` | Make Video: Screen Record, Edit & Produce |
| `makewebpage` | Make Webpage: Build a Webpage from Context |
| `manimce-best-practices` | Trigger when: (1) User mentions "manim" or "Manim Community" or "ManimCE", (2)… |
| `manim-composer` | Trigger when: (1) User wants to create an educational/explainer video, (2) User… |
| `manimgl-best-practices` | Trigger when: (1) User mentions "manimgl" or "ManimGL" or "3b1b manim", (2)… |
| `marketresearch` | Market Research: Research, Organize, Present |
| `marketwebpage` | Market Webpage: Market Research to Polished Webpage |
| `medium` | Medium Article Writer |
| `napkinpolishppt` | Napkin Polish PPT: Turn Slide Text into Visuals |
| `pdf` | Create, merge, split, fill, and manipulate PDF files |
| `pptx` | Use this skill any time a .pptx file is involved in any way — as input, output,… |
| `prism` | Write and compile LaTeX in OpenAI's Prism editor via browser automation |
| `projectstatus` | Generate a project status report. Use when the user wants a status update,… |
| `refactor` | Refactor: Deep Codebase Cleanup |
| `remember` | Commit important information to the persistent memory graph. Use when the user… |
| `remotion-best-practices` | Best practices for Remotion - Video creation in React |
| `review` | Spaced Repetition Review: `/review` |
| `roadmap` | Create a project roadmap document. Use when the user wants to plan milestones,… |
| `summary` | Summarize the current chat session into a well-structured markdown file. Use… |
| `swarm` | Spin up autonomous agent teams with bypassed permissions |
| `synthesize` | Synthesize: Smart Router for Merging Multiple Files |
| `synthesizepdf` | Synthesize PDF: Merge Multiple PDFs into One Coherent Document |
| `synthesizeppt` | Synthesize PPT: Merge Multiple Decks into One Coherent Presentation |
| `tweet` | Tweet: Draft and Post on X |
| `warmup` | Start-of-session warmup that reads all existing project artifacts —… |

## Plugins (20)

| Plugin | Description |
|--------|-------------|
| `claude-md-management` | Tools to maintain and improve CLAUDE.md files - audit quality, capture session… |
| `code-review` | Automated code review for pull requests using multiple specialized agents with… |
| `code-simplifier` | Agent that simplifies and refines code for clarity, consistency, and… |
| `commit-commands` | Streamline your git workflow with simple commands for committing, pushing, and… |
| `explanatory-output-style` | Adds educational insights about implementation choices and codebase patterns… |
| `feature-dev` | Comprehensive feature development workflow with specialized agents for codebase… |
| `frontend-design` | Frontend design skill for UI/UX implementation |
| `github` | Official GitHub MCP server for repository management. Create issues, manage… |
| `hookify` | Easily create hooks to prevent unwanted behaviors by analyzing conversation… |
| `huggingface-skills` | Agent Skills for AI/ML tasks including dataset creation, model training,… |
| `learning-output-style` | Interactive learning mode that requests meaningful code contributions at… |
| `playground` | Creates interactive HTML playgrounds — self-contained single-file explorers… |
| `playwright` | Browser automation and end-to-end testing MCP server by Microsoft. Enables… |
| `pr-review-toolkit` | Comprehensive PR review agents specializing in comments, tests, error handling,… |
| `ralph-loop` | Continuous self-referential AI loops for interactive iterative development,… |
| `slack` | Slack workspace integration. Search messages, access channels, read threads,… |
| `supabase` | Supabase MCP integration for database operations, authentication, storage, and… |
| `superpowers` | Core skills library for Claude Code: TDD, debugging, collaboration patterns,… |
| `typescript-lsp` | typescript-lsp |
| `vercel` | Deploy applications to Vercel with deployment monitoring, log analysis, and… |

## Hooks (5)

| Hook | Description |
|------|-------------|
| `backup-skills.sh` | Hook: Backup skills and plugins after any file write to ~/.claude/skills/ or… |
| `error-search.sh` | Classify errors as regular coding vs Claude Code specific and suggest targeted… |
| `generate-readme.sh` | Generates README.md for the claude-skills repo from current skills and plugins |
| `sync-mcp.sh` | Export MCP server configs (with secrets redacted) to the repo |
| `sync-plugins.sh` | Hook: Sync INSTALLED plugins (not entire marketplace) to GitHub repo |

## MCP Servers (3)

| Server | Command | Description |
|--------|---------|-------------|
| `claude-in-chrome` | `chrome-extension` | Browser automation via Chrome extension (screenshots, clicks, navigation, forms) |
| `memory` | `npx` | Persistent knowledge graph across conversations |
| `voicemode` | `uvx` | Voice conversation with STT/TTS via ElevenLabs + Kokoro + OpenAI |

## Auto-Backup

Hooks watch for changes to `~/.claude/skills/`, `~/.claude/plugins/`, `~/.claude/hooks/`, and MCP configs. On any change:

1. Syncs to a local backup at `~/skills-backup/`
2. Regenerates this README
3. Commits and pushes to this repo
