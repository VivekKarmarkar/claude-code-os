# Tweet — Draft and Post on X

Open X (Twitter) in Chrome and draft a tweet based on the current conversation context or user instructions.

## Arguments

`<topic, instructions, or context>` — What the tweet should be about, who to tag, what tone to use, etc.

If no arguments are provided, derive the tweet content from the current conversation context — what was built, discussed, or accomplished.

## Pre-flight Check

**CRITICAL: Do this FIRST before anything else.**

1. Call `mcp__claude-in-chrome__tabs_context_mcp` to verify the Chrome MCP extension is connected.
2. If the call **fails or returns an error**, STOP immediately and tell the user:
   ```
   Chrome MCP extension is not connected. Please:
   1. Open Chrome
   2. Click the Claude-in-Chrome extension icon
   3. Make sure it shows "Connected"
   4. Try /tweet again
   ```
3. If the call **succeeds**, proceed to the next step.

## Workflow

### Step 1: Plan the Tweet

Before touching the browser, plan the tweet content:

- **Core message** — What's the main point? Keep it punchy.
- **Tags** — Who should be tagged? (@handles)
- **Links** — Any URLs to include? (GitHub issues, articles, videos)
- **Tone** — Casual, professional, excited, reflective?
- **Length** — Under 280 chars for full timeline visibility, or longer (X Premium shows "Show more" for posts over 280 chars).

If the user wants Claude to tweet as itself, always start with:
`This is Claude Code (Opus 4.6) posting from @vivek_karmarkar's account.`

### Step 2: Open X Compose

1. Create a new tab: `mcp__claude-in-chrome__tabs_create_mcp`
2. Navigate to: `mcp__claude-in-chrome__navigate` with URL `https://x.com/compose/post`
3. Wait 3 seconds for the page to load: `mcp__claude-in-chrome__computer` with action `wait`
4. Take a screenshot to verify the compose window loaded (you should see "What's happening?" placeholder)

If X asks for login or shows an error, tell the user and stop.

### Step 3: Write the Tweet

1. Click on the "What's happening?" text area (approximately center of the compose box)
2. Type the tweet content
3. Take a screenshot to verify the text appears correctly
4. Check if X shows any warnings (character limit, etc.)

### Step 4: Review with User

1. Tell the user: "Here's the draft tweet. Want me to post it, or would you like changes?"
2. Show them a summary of what was written
3. If the user says to post, click the **Post** button
4. If the user wants changes, clear and retype, or edit as needed

### Step 5: Confirm

1. Wait 2-3 seconds after clicking Post
2. Take a screenshot to verify the "posted" confirmation toast appeared
3. Tell the user the tweet is live

## Rules

1. **Always identify as Claude Code** when tweeting as the AI (not as Vivek). First line should make it clear who is writing.
2. **Never post without user confirmation** unless the user explicitly says "just post it" or "go ahead."
3. **Never enter sensitive data.** No passwords, tokens, or personal information.
4. **If something goes wrong** (page not loading, compose not appearing, text not typing), take a screenshot, show the user, and ask how to proceed. Do not retry more than twice.
5. **Keep tweets concise.** Default to under 280 characters unless the user wants a longer post. If going long, warn that only the first 280 chars show on the timeline.
6. **Tag people accurately.** Double-check @handles before posting. If unsure of someone's handle, search for it first.
7. **Include links when relevant.** GitHub issues, articles, videos — these add context.
8. **Tone matching.** Match the user's energy and the topic. Technical announcements should feel different from casual updates.

## Known Handles

| Person | Handle | Context |
|--------|--------|---------|
| Vivek Karmarkar | @vivek_karmarkar | Account owner |
| Boris Cherny | @bcherny | Creator of Claude Code at Anthropic |
| Thariq | @trq212 | Claude Code team |
| OpenAI | @OpenAI | For Prism/ChatGPT references |
