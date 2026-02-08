---
name: summary
description: Summarize the current chat session into a well-structured markdown file. Use when the user wants to capture what was discussed, decisions made, code changes, and next steps from the conversation.
argument-hint: [filename or focus area]
---

# Chat Summary Generator

Create a concise, well-structured markdown summary of the current conversation and save it as a `.md` file.

## Modes

**Default** — If no arguments, summarize the entire conversation so far.

**Focused** — If `$ARGUMENTS` specifies a focus area (e.g., `/summary auth changes`), filter the summary to only cover that topic from the conversation.

**Custom filename** — If `$ARGUMENTS` looks like a filename (e.g., `/summary sprint-recap.md`), use that as the output filename.

## Summary Structure

Write the markdown file with the following sections. Omit any section that has no relevant content from the conversation.

```markdown
# Chat Summary

> **Date:** YYYY-MM-DD
> **Project:** <project name from cwd or git remote>

## Overview
One or two sentences describing what this session was about.

## Key Discussions
- Bullet points of the main topics discussed
- Each point should be a concise, self-contained takeaway

## Decisions Made
- Concrete decisions that were agreed upon
- Include the reasoning if it was discussed

## Changes Made
List files that were created, modified, or deleted during the session.

| File | Action | What Changed |
|------|--------|-------------|
| `path/to/file` | Modified | Brief description |

## Code Snippets
Include any important code patterns, commands, or configurations that came up.
Only include snippets that would be useful for future reference.

## Open Questions / Blockers
- Anything left unresolved
- Issues that need follow-up

## Next Steps
- [ ] Actionable items that came out of this session
- [ ] Prioritized by importance
```

## Implementation Rules

1. **Read the conversation context carefully.** Scan everything discussed — file edits, tool calls, user questions, decisions, code written.
2. **Be concise.** Summaries should be skimmable. Use bullets, not paragraphs.
3. **Be accurate.** Only include things that were actually discussed. Do not fabricate or speculate.
4. **Include file paths** for any code changes so the reader can navigate to them.
5. **Use checkboxes** (`- [ ]`) for next steps so they're actionable.
6. **Save location:**
   - If inside a git project, save to the project root as `summaries/YYYY-MM-DD-summary.md` (create the `summaries/` directory if needed).
   - If no project context, save to `~/summaries/YYYY-MM-DD-summary.md`.
   - If the user provides a custom filename, use that instead.
   - If a file with that name already exists, append a counter (e.g., `-2`, `-3`).
7. **Tell the user** the output path when done.
8. **Do NOT use any external tools or libraries** — just write the markdown string directly to a file using the Write tool.
