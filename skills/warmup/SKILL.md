---
name: warmup
description: Start-of-session warmup that reads all existing project artifacts — presentations, PDFs, summaries, roadmap, project status, and CLAUDE.md — to build full context before beginning work.
---

# Warmup — Load Project Context

Read all existing project artifacts to get up to speed on the project before starting any work. This is the counterpart to `/cooldown`.

## Execution

Search for and read the following artifacts **in this order**. For each one, announce whether it was found or not.

### Step 1 of 6: CLAUDE.md
Look for `CLAUDE.md` in the project root and any parent directories. Read it if found — this contains project-specific instructions and conventions.

### Step 2 of 6: Latest Presentation
Look for the most recently modified `.pptx` file in the project. If found, use `python -m markitdown <file>.pptx` to extract and read its text content. Note the filename and modification date.

### Step 3 of 6: Latest PDF Notes
Look for the most recently modified `.pdf` file in the project (check project root and common locations). If found, use `pdftotext` or `pdfplumber` to extract and read its text content. Note the filename and modification date.

### Step 4 of 6: Latest Summary
Search for markdown summary files:
- `summaries/*.md` in the project root
- `~/summaries/*.md` as fallback
Read the most recent one if found.

### Step 5 of 6: Roadmap
Look for:
- `ROADMAP.md` in the project root
- `~/roadmaps/*.md` as fallback
Read it if found.

### Step 6 of 6: Latest Project Status
Search for status report files:
- `status-reports/*.md` in the project root
- `~/status-reports/*.md` as fallback
Read the most recent one if found.

## After All Steps

Print a context summary:

```
Warmup complete! Here's what I found:

| Artifact        | Status | File                  |
|-----------------|--------|-----------------------|
| CLAUDE.md       | Found / Not found | path or — |
| Presentation    | Found / Not found | path or — |
| PDF Notes       | Found / Not found | path or — |
| Summary         | Found / Not found | path or — |
| Roadmap         | Found / Not found | path or — |
| Project Status  | Found / Not found | path or — |
```

Then provide a **brief digest** (5-10 bullet points) of the key context you picked up from the artifacts you read:
- What the project is about
- Current state and health
- Recent decisions and changes
- Outstanding action items and blockers
- Key conventions from CLAUDE.md

End with: **"Ready to go. What are we working on today?"**

## Rules

1. **Read everything you can.** The goal is maximum context loading. Use `markitdown` for .pptx files and `pdftotext`/`pdfplumber` for PDFs to extract actual content.
2. **Don't modify anything.** This is a read-only operation.
3. **Be fast.** Use parallel reads where possible (e.g., glob for all artifact directories at once, then read the results).
4. **Handle missing artifacts gracefully.** Not every project will have all artifacts. Just mark them "Not found" and move on.
5. **Prefer the most recent file** when multiple exist in a directory (sort by modification date).
6. **Keep the digest concise.** Don't regurgitate entire documents — extract the key points that will help you be effective in this session.
