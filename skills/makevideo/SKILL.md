# Make Video — Screen Record, Edit & Produce

Record the user's screen, download background music, and iteratively edit a polished video using ffmpeg — all from the terminal.

## Arguments

`<description or instructions>` — What the video is about, desired length, style notes, etc.

If no arguments are provided, ask the user what they'd like to record and produce.

## Workflow Overview

```
Record Screen → Analyze Frames → Discuss Edit Plan → Download Music → Edit (iterate) → Final Cut
```

---

## Phase 1: Plan the Recording

Before recording, discuss with the user:

1. **What are we recording?** (a workflow, a demo, a tutorial, a presentation?)
2. **Estimated duration?** (how long will the raw recording be?)
3. **Screen resolution?** Detect with:
   ```bash
   xdpyinfo | grep dimensions
   ```
   Common: 1920x1080, 1920x1200, 2560x1440
4. **Audio?** Usually no mic audio for this type of video — we add music in post.

## Phase 2: Record the Screen

Start recording with ffmpeg using x11grab:

```bash
ffmpeg -y -f x11grab -framerate 30 -video_size {WIDTH}x{HEIGHT} -i :0.0 \
  -c:v libx264 -preset ultrafast -crf 18 \
  ~/screen_recording_raw.mp4
```

**IMPORTANT:**
- Run this command in the **background** using `run_in_background: true` so the user can perform their workflow while recording.
- Tell the user: "Recording started. Do your thing — when you're done, tell me and I'll stop the recording."
- When the user says they're done, stop the recording by finding and killing the ffmpeg process:
  ```bash
  pkill -INT ffmpeg
  ```
  Using `-INT` (SIGINT) ensures ffmpeg finishes writing the file cleanly.

After stopping, verify the recording:
```bash
ffprobe -v quiet -show_entries format=duration,size -of csv=p=0 ~/screen_recording_raw.mp4
```

## Phase 3: Analyze the Raw Recording

Extract frames at regular intervals to understand the content:

```bash
# Extract one frame every 15 seconds
ffmpeg -i ~/screen_recording_raw.mp4 -vf "fps=1/15" -q:v 2 /tmp/frame_%03d.jpg
```

Read each frame image to map out what's happening at each timestamp. Build a timeline:

```
0:00-0:30  — Setup / opening the app
0:30-1:30  — Writing code
1:30-2:00  — Compiling / running
...
```

Share this timeline with the user and ask:
- Which sections should be **sped up**? (setup, typing → 2x-4x)
- Which sections should be kept at **normal speed** or **slowed down**? (key moments, results)
- Anything to **trim/remove**? (dead air, mistakes, waiting)
- What **labels or title cards** should appear?

## Phase 4: Download Background Music

Search for and download a royalty-free lofi track from Pixabay:

```bash
# Search Pixabay for lofi background music
# The user may already have a track — ask first
```

**Ask the user:** "Do you have a music track you'd like to use, or should I find a royalty-free lofi track?"

If downloading, use a known working approach:
1. Search Pixabay Music (https://pixabay.com/music/search/lofi/) via WebFetch or WebSearch
2. Find a suitable track (lofi, chill, background, 2-4 minutes)
3. Download with curl/wget to `~/Downloads/`
4. Verify the download:
   ```bash
   ffprobe -v quiet -show_entries format=duration -of csv=p=0 ~/Downloads/music.mp3
   ```

If the user already has a track (e.g., from a previous session), use that instead. Check:
```bash
ls ~/Downloads/*.mp3 2>/dev/null
```

The user previously used: `~/Downloads/vibehorn-lofi-background-music-479217.mp3` — suggest reusing it if it exists.

## Phase 5: Edit the Video — Iterative Process

This is the core creative phase. Build the ffmpeg command iteratively based on the user's feedback.

### Edit 1: Speed Ramps + Music

Based on the timeline analysis, create the first edit with speed ramps and music:

```bash
ffmpeg -y -i ~/screen_recording_raw.mp4 -i "$MUSIC" \
  -filter_complex "
    [0:v]split=N[v1]...[vN];

    [v1]trim=START:END,setpts=(PTS-STARTPTS)/SPEED[s1];
    [v2]trim=START:END,setpts=(PTS-STARTPTS)/SPEED[s2];
    ...

    [s1]...[sN]concat=n=N:v=1:a=0[vout];

    [1:a]aloop=loop=-1:size=SAMPLECOUNT,atrim=duration=DURATION,
      afade=t=in:st=0:d=2,afade=t=out:st=FADESTART:d=FADELEN,
      volume=0.35[aout]
  " \
  -map "[vout]" -map "[aout]" \
  -c:v libx264 -preset medium -crf 20 \
  -c:a aac -b:a 128k \
  -shortest \
  ~/video_edit_v1.mp4
```

**Audio loop size:** Get the sample count for aloop:
```bash
ffprobe -v quiet -show_entries stream=sample_rate,duration -of csv=p=0 -select_streams a "$MUSIC"
# size = sample_rate * duration (approximate)
```

After rendering, report duration and file size. Ask the user to review.

### Edit 2+: Iterate Based on Feedback

Common user requests and how to handle them:

| Request | ffmpeg Technique |
|---------|-----------------|
| "Add a title card" | `color=c=black:s=WxH:d=4:r=30` + `drawtext` as first concat segment |
| "Add step labels" | `drawtext=text='Step N':enable='between(t,START,END)'` overlay |
| "Add end card" | `color=c=black` + multiple `drawtext` with `textfile=/tmp/endcard.txt` |
| "Fade between sections" | `fade=t=out:st=X:d=0.3` on outgoing + `fade=t=in:st=0:d=0.3` on incoming |
| "Trim this section" | Adjust trim points, remove segment from concat |
| "Speed up X to Y" | Change `setpts` divisor for that segment |
| "Insert PDF/image scroll" | Record or create separate clip, concat into main video |
| "Fix black gap between segments" | Use shorter fades (0.3s instead of 0.5s), cut slightly before fade-out region |

**IMPORTANT — Shell quoting with drawtext:**
- Apostrophes in `text='...'` break shell parsing
- **Fix:** Write text to `/tmp/textfile.txt` and use `textfile=/tmp/textfile.txt` instead of inline `text=`
- This is critical for end cards with text like "Anthropic's Claude Code"

**IMPORTANT — Fade gap prevention:**
- When concatenating segments with fade-out + fade-in, both fades produce near-black frames
- If fades overlap temporally (0.5s + 0.5s = 1s of near-black), it looks like a jarring black flash
- **Fix:** Use short fades (0.3s) and cut the outgoing segment slightly before its natural fade-out

### After Each Edit

Always report:
```bash
echo "Duration:"
ffprobe -v quiet -show_entries format=duration -of csv=p=0 ~/video_edit_vN.mp4
echo "Size:"
ls -lh ~/video_edit_vN.mp4 | awk '{print $5}'
```

Ask the user: "Here's v{N} — {duration}s, {size}. Want any changes?"

## Phase 6: Final Output

When the user is happy:

1. Rename to a meaningful filename:
   ```bash
   cp ~/video_edit_vN.mp4 ~/final_video_name.mp4
   ```
2. Report final stats (duration, resolution, file size)
3. Ask if they want to upload to YouTube or continue to `/medium` for an article

## ffmpeg Quick Reference

### Speed Control
```
setpts=(PTS-STARTPTS)/2    # 2x speed
setpts=(PTS-STARTPTS)/4    # 4x speed
setpts=(PTS-STARTPTS)*2    # 0.5x (slow motion)
```

### Segment Extraction
```
[0:v]split=3[v1][v2][v3];
[v1]trim=0:30,setpts=PTS-STARTPTS[s1];
[v2]trim=30:60,setpts=PTS-STARTPTS[s2];
[v3]trim=60:90,setpts=PTS-STARTPTS[s3];
[s1][s2][s3]concat=n=3:v=1:a=0[vout];
```

### Text Overlays
```
drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:
  text='Title':fontcolor=white:fontsize=48:
  x=(w-text_w)/2:y=(h-text_h)/2
```

### Title/End Cards (from solid color)
```
-f lavfi -i "color=c=black:s=1920x1200:d=6:r=30"
```

### Audio
```
aloop=loop=-1:size=SAMPLES    # Loop short track
atrim=duration=120             # Trim to length
afade=t=in:st=0:d=2           # Fade in 2s
afade=t=out:st=110:d=10       # Fade out last 10s
volume=0.35                    # 35% volume (background level)
```

### Common Fonts
```
/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
```

## Rules

1. **Always record in background** so the user can perform their workflow.
2. **Stop recording cleanly** with `pkill -INT ffmpeg` (SIGINT, not SIGKILL).
3. **Analyze frames before editing** — understand the content before proposing speed ramps.
4. **Iterate with the user** — never assume the first edit is final. Ask for feedback after every version.
5. **Use textfile= for drawtext** when text contains apostrophes or special characters.
6. **Short fades (0.3s)** to prevent black gaps between concatenated segments.
7. **Check duration and size** after every render and report to the user.
8. **Name versions sequentially** (v1, v2, v3...) so nothing gets overwritten accidentally.
9. **Music at 35% volume** — background level, not overpowering.
10. **Audio fade-out should start 5-7 seconds before video ends** for a smooth finish.
