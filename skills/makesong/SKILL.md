# Make Song — Generate & Download Music with Suno

Use Suno AI (suno.com) via Chrome browser automation to generate songs from a text description and download the MP3.

## Arguments

`<song description, style, mood, or topic>` — What the song should sound like or be about.

Examples:
- `/makesong A chill lofi hip hop track about coding at 3am`
- `/makesong upbeat Bollywood dance track in Hindi about summer nights`
- `/makesong instrumental jazz piano, relaxed cafe vibes`

If no arguments are provided, ask the user what kind of song they want.

## Pre-flight Check

**CRITICAL: Do this FIRST before anything else.**

1. Call `mcp__claude-in-chrome__tabs_context_mcp` to verify the Chrome MCP extension is connected.
2. If the call **fails or returns an error**, STOP immediately and tell the user:
   ```
   Chrome MCP extension is not connected. Please:
   1. Open Chrome
   2. Click the Claude-in-Chrome extension icon
   3. Make sure it shows "Connected"
   4. Try /makesong again
   ```
3. If the call **succeeds**, proceed to the next step.

## Account Info

- **Platform:** suno.com
- **Account:** vivek-karmarkar (signed in via Google SSO — Physics Animated account)
- **Plan:** Free tier (50 credits on signup)
- **Cost:** 10 credits per generation (produces 2 song variations)
- **Model:** v4.5-all (default)

## Workflow

### Step 1: Plan the Song

Before touching the browser, plan what to enter:

- **Description** — The main prompt for Suno. Can include genre, mood, instruments, topic, and style. Keep it under ~200 characters for best results.
- **Mode** — Simple (just a description) or Custom (description + separate lyrics). Default to Simple unless the user provides specific lyrics.
- **Instrumental** — Toggle on if the user wants no vocals.

### Step 2: Navigate to Suno Create

1. Create a new tab: `mcp__claude-in-chrome__tabs_create_mcp`
2. Navigate to: `https://suno.com/create`
3. Wait 3 seconds for the page to load
4. Take a screenshot to verify the create page loaded (look for "Song Description" textarea)

If Suno asks for login or shows an error, tell the user and stop.

### Step 3: Enter the Song Description

1. Click on the "Song Description" text area
2. Triple-click to select any existing text, then type the new description
3. If the user wants instrumental only, click the "Instrumental" toggle button
4. If the user wants Custom mode (with specific lyrics), click "Custom" at the top, then use the Lyrics textarea
5. Take a screenshot to verify the text appears correctly

### Step 4: Create the Song

1. Click the **Create** button (orange gradient button at the bottom of the create panel)
2. Wait 5-10 seconds for generation to start
3. Take a screenshot — verify that:
   - Credits decreased (10 credits used per generation)
   - Two new songs appeared in the right-side workspace panel
4. Note the song titles that Suno generated

### Step 5: Open Song Detail Page

1. Click on the first generated song in the workspace sidebar (the topmost new entry)
2. This should navigate to the song's detail page at `suno.com/song/{id}`
3. Wait 2 seconds for the page to load
4. Take a screenshot — verify you see the song title, cover art, lyrics, and action buttons

### Step 6: Download the Song

1. Click the **"..."** (more options) button in the action bar below the cover art
2. A dropdown menu appears with many options
3. Hover over **"Download"** to expand the submenu
4. The submenu shows:
   - **MP3 Audio** (free)
   - **WAV Audio** (Pro only)
   - **Video** (Pro only)
5. Click **"MP3 Audio"**
6. A "Need commercial rights?" dialog appears — click **"Download Anyway"**
   - Use `find` tool to locate the "Download Anyway" button if coordinate clicking fails
7. Wait 3-4 seconds for the download to complete

### Step 7: Verify the Download

Run ffprobe to confirm the file downloaded correctly:

```bash
ls -lt ~/Downloads/ | head -3
ffprobe -v quiet -show_entries format=duration,size -show_entries stream=codec_name,sample_rate,channels -of csv=p=0 ~/Downloads/"<song_title>.mp3"
```

Report to the user:
- Song title
- Duration
- File size
- File path (`~/Downloads/<song_title>.mp3`)

### Step 8: Offer Next Steps

Ask the user:
- "Want me to download the second variation too?"
- "Want to create another song?"
- "Want to use this track in a video?" (connects to /makevideo skill)

## UI Reference

### Create Page Layout (`suno.com/create`)
```
Top bar:     [credits] [Simple | Custom] [v4.5-all dropdown]
Left panel:  Song Description textarea
             [+ Audio] [+ Lyrics] [Instrumental toggle]
             Inspiration tags (scrollable)
             [trash icon] [Create button - orange gradient]
Right panel: Workspaces > My Workspace
             [Search]
             [Song list with thumbnails, titles, durations]
Bottom:      Player bar (when a song is selected)
```

### Song Detail Page Layout (`suno.com/song/{id}`)
```
Cover art (left)     Title (large)
  [Animate]          Artist: vivek-karmarkar
                     Description/style tags
                     Date + model version
                     [Play] [Comment] [Thumbs up] [Thumbs down] [...more]
                     [+] [Share arrow] [Play in queue]

[Lyrics | Comments] tabs
Lyrics content below

Bottom: Player bar with controls
```

### Key Coordinates (approximate, may shift)
- Song Description textarea: center of left panel (~400, 170)
- Create button: bottom of left panel (~467, 905)
- "..." more options: in action bar on song detail page (~649, 324)
- Download submenu appears to the right of the dropdown

### Custom Combobox Interaction Pattern
Suno uses custom combobox components (not native selects). For reliable interaction:
1. Click the combobox to focus it
2. Type the value to filter the dropdown
3. Click the filtered option
Note: `form_input` may work inconsistently on these components.

## Rules

1. **Always check the create page loaded** before typing. If not logged in, stop and tell the user.
2. **Default to Simple mode** unless the user provides specific lyrics for Custom mode.
3. **10 credits per creation** — warn the user if they're running low. Check the credit count in the top-left.
4. **Two songs per generation** — Suno always produces 2 variations. Let the user know both are available.
5. **MP3 is the free download format.** WAV and Video require Pro. Always use MP3 unless the user has Pro.
6. **The "Download Anyway" dialog always appears** on free tier. Always click it to proceed.
7. **Verify the download** with ffprobe before reporting success.
8. **Song titles are AI-generated** by Suno based on the description — the user doesn't control the title.
9. **If something goes wrong** (page not loading, generation failing, download not starting), take a screenshot, show the user, and ask how to proceed. Do not retry more than twice.
10. **Don't play audio** — clicking the play button will start audio playback which can't be controlled well via automation. Focus on creating and downloading.
