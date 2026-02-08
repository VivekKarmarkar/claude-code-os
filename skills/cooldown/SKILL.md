---
name: cooldown
description: End-of-session cooldown that generates all project artifacts in sequence — presentation, PDF notes, summary, roadmap, and project status report. Use when the user wants to wrap up a session and produce a complete set of deliverables.
argument-hint: [topic or focus area]
---

# Cooldown — Full Artifact Generation

Run all five artifact generators in sequence, producing a complete set of deliverables from the current session and project context.

If `$ARGUMENTS` is provided, use it as the shared topic/focus for all artifacts. Otherwise, derive the topic from the conversation and project context.

## Execution Order

You MUST execute these **one at a time, in this exact order**, completing each fully before starting the next. Announce each step as you begin it.

### Step 1 of 5: Presentation
Invoke the `/pptx` skill. Create a presentation summarizing the key topics from this session or the provided topic. Follow all instructions from the `pptx` skill. Announce the output path when done.

### Step 2 of 5: PDF Notes
Invoke the `/pdf` skill. Create a PDF with detailed reference notes covering the same material. Follow all instructions from the `pdf` skill. Announce the output path when done.

### Step 3 of 5: Summary
Invoke the `/summary` skill. Create a markdown summary of the chat session — discussions, decisions, changes, and next steps. Follow all instructions from the `summary` skill. Announce the output path when done.

### Step 4 of 5: Roadmap
Invoke the `/roadmap` skill. Create or update the project roadmap based on what was discussed and the current state of the codebase. Follow all instructions from the `roadmap` skill. Announce the output path when done.

### Step 5 of 5: Project Status
Invoke the `/projectstatus` skill. Generate a status report based on recent git activity and session context. Follow all instructions from the `projectstatus` skill. Announce the output path when done.

## After All Steps

Print a final summary listing all generated files:

```
Cooldown complete! Generated artifacts:

1. Presentation:    <path>
2. PDF Notes:       <path>
3. Summary:         <path>
4. Roadmap:         <path>
5. Project Status:  <path>
```

## Rules

1. **Sequential execution.** Complete each artifact fully before starting the next.
2. **Announce progress.** Print a header like `--- Step 2 of 5: PDF Notes ---` before each step.
3. **Consistent topic.** If the user provided a topic, thread it through all five artifacts so they form a coherent set.
4. **Don't skip steps.** All five artifacts must be generated. If one fails, note the error and continue to the next.
5. **Don't ask questions.** This is a batch operation. Use your best judgment for each artifact based on the conversation and project context. If context is thin for a particular artifact, produce a reasonable default rather than stopping to ask.
