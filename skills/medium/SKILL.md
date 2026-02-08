# Medium Article Writer

Write a full article draft on Medium via browser automation.

## Arguments

`<topic or instructions>` — What the article should be about. Can be a topic, a title, or detailed instructions including sections and tone.

If no arguments are provided, derive the topic from the current conversation context.

## Pre-flight Check

**CRITICAL: Do this FIRST before anything else.**

1. Call `mcp__claude-in-chrome__tabs_context_mcp` to verify the Chrome MCP extension is connected.
2. If the call **fails or returns an error**, STOP immediately and tell the user:
   ```
   Chrome MCP extension is not connected. Please:
   1. Open Chrome
   2. Click the Claude-in-Chrome extension icon
   3. Make sure it shows "Connected"
   4. Try /medium again
   ```
3. If the call **succeeds**, proceed to the next step.

## Workflow

### Step 1: Plan the Article

Before touching the browser, plan the full article in your head:

- **Title** — Include an emoji at the start. Make it compelling and specific.
- **Subtitle** — One-sentence hook that captures the essence.
- **Sections** — 4-7 sections with emoji headers (e.g., "🧪 The Experiment"). Use plain text, not formatted headings — Medium's editor handles formatting poorly with automation.
- **Sign-off** — End with `— Claude Code (Opus 4.6) and Vivek` unless the user specifies otherwise.

### Step 2: Open Medium

1. Create a new tab: `mcp__claude-in-chrome__tabs_create_mcp`
2. Navigate to: `mcp__claude-in-chrome__navigate` with URL `https://medium.com/new-story`
3. Wait 3 seconds for the page to load: `mcp__claude-in-chrome__computer` with action `wait`
4. Take a screenshot to verify the editor loaded (you should see "Title" placeholder and "Tell your story...")

If Medium asks for login or shows an error, tell the user and stop.

### Step 3: Write the Title

1. Click on the "Title" placeholder area (approximately center of the title area)
2. Type the title (with emoji)
3. Take a screenshot to verify

### Step 4: Write the Subtitle and Body

1. Click on the "Tell your story..." area below the title
2. Type the subtitle text
3. Press Enter twice to create a new paragraph
4. If the user wants an image uploaded, tell them: "Click the + button on the empty line, select the image icon, and upload your image. Let me know when done and I'll continue writing below it."
5. After image (or if no image needed), continue typing the full article body

### Step 5: Write the Article Body

Type the article content section by section:

1. Type each section's emoji header + title on its own line, press Enter twice
2. Type the section body paragraphs, pressing Enter twice between paragraphs
3. For bullet lists, type each item starting with `- ` on a new line
4. Continue until all sections are written
5. End with the sign-off line

**IMPORTANT — Speed tips:**
- Do NOT try to format text as headings (selecting text, clicking toolbar buttons). Just type plain emoji headers — they look great on Medium without extra formatting.
- Do NOT try to apply italic/bold via toolbar — use the text naturally.
- Type full paragraphs in single `type` actions — don't break sentences across multiple calls.
- Press `Return Return` (two enters) between paragraphs to create proper spacing.
- Do NOT upload images yourself — you cannot operate file dialogs. Ask the user to do it.

### Step 6: Verify

1. Press `Ctrl+Home` to scroll to the top
2. Take a screenshot to show the user the final result
3. Tell the user the draft is ready and they can review/edit before publishing

## Rules

1. **Never click Publish.** Only write the draft. Publishing requires explicit user action.
2. **Never enter sensitive data.** No passwords, tokens, or personal information.
3. **If something goes wrong** (page not loading, editor not responding, text not appearing), take a screenshot, show the user, and ask how to proceed. Do not retry more than twice.
4. **Keep it fast.** Don't waste time on formatting — Medium's editor is finicky with automation. Plain text with emoji section headers looks professional enough.
5. **Article length:** Aim for 800-1500 words unless the user specifies otherwise.
6. **Tone:** Conversational, first-person, engaging. Match the user's voice from the conversation context.
