# Napkin Polish PPT — Turn Slide Text into Visuals

Take an existing PowerPoint file and use Napkin AI to generate polished visuals for text-heavy slides, replacing walls of text with infographics, diagrams, and charts.

## Arguments

`<path to .pptx file>` — The presentation to polish.

Examples:
- `/napkinpolishppt ~/presentations/quarterly-report.pptx`
- `/napkinpolishppt ./my-deck.pptx`

If no arguments, ask the user for the file path.

## Pre-flight Check

1. Call `mcp__claude-in-chrome__tabs_context_mcp` to verify Chrome MCP is connected. If not, stop and tell the user to connect it.
2. Confirm the .pptx file exists and is readable. If not, stop.
3. Use the `/pptx` skill to read and extract the text content from every slide.

---

## Phase 1: Analyze the Deck

Read through all slides and classify each one:

- **Visual candidate** — text-heavy slide that would benefit from a Napkin visual (bullet lists, comparisons, processes, timelines, data points, SWOT, matrices)
- **Already visual** — slide that's mostly images/charts, skip it
- **Title / section divider** — skip it
- **Bibliography / references** — skip it

Present the analysis to the user:

```
Slide Analysis
═══════════════════════════════════
Total slides:        N
Visual candidates:   N
Already visual:      N
Skipping:            N

Candidates:
  Slide 3  — "Market Overview" — bullet list with 6 data points
  Slide 5  — "Competitive Landscape" — comparison of 4 companies
  Slide 7  — "Process Flow" — 5-step workflow described in text
  Slide 9  — "SWOT Analysis" — 4-quadrant text block
  ...
═══════════════════════════════════

Proceed with all candidates, or select specific slides?
```

Wait for user confirmation.

---

## Phase 2: Generate Visuals with Napkin AI

For each selected slide:

### Step 1: Prepare the Text

Extract the slide's text content. Clean it up for Napkin:
- Remove slide numbers and headers if redundant
- Keep the core content — bullets, data points, comparisons
- If the text is very long, break it into logical chunks that Napkin can digest

### Step 2: Navigate to Napkin AI

1. Open a new Chrome tab: `mcp__claude-in-chrome__tabs_create_mcp`
2. Navigate to `https://app.napkin.ai/page/create`
3. Wait for the page to load fully

### Step 3: Input Text

1. Find the text input area on the Napkin page
2. Take a snapshot to understand the current UI layout
3. Paste the slide's text content into the input area
4. Submit / trigger Napkin to generate visuals

### Step 4: Capture the Output

1. Wait for Napkin to generate the visual
2. Take a screenshot of the generated visual: `mcp__claude-in-chrome__browser_take_screenshot` or use the claude-in-chrome screenshot tool
3. Save the screenshot with a descriptive filename:
   - `slide-03-market-overview.png`
   - `slide-05-competitive-landscape.png`
   - etc.
4. Save to a `napkin-visuals/` directory next to the original PPTX file

### Step 5: Try Variations (if Napkin offers them)

If Napkin generates multiple visual options:
- Capture the best 2-3 variations
- Name them: `slide-03-market-overview-v1.png`, `slide-03-market-overview-v2.png`

### Step 6: Repeat

Clear Napkin's input and move to the next slide. Reuse the same tab — no need to open a new one for each slide.

---

## Phase 3: Organize and Report

### Save Structure

Create the visuals directory next to the original PPTX:

```
<same-directory-as-pptx>/
├── original-deck.pptx
└── napkin-visuals/
    ├── slide-03-market-overview.png
    ├── slide-05-competitive-landscape.png
    ├── slide-05-competitive-landscape-v2.png
    ├── slide-07-process-flow.png
    └── slide-09-swot-analysis.png
```

### Final Report

```
Napkin Polish Complete
═══════════════════════════════════════════
Source:              <pptx filename>
Slides processed:    N / N candidates
Visuals generated:   N images

Visuals saved to:    <path>/napkin-visuals/

Slide  Visual File                              Status
─────  ──────────────────────────────────────  ──────
  3    slide-03-market-overview.png            Done
  5    slide-05-competitive-landscape.png      Done (2 variants)
  7    slide-07-process-flow.png               Done
  9    slide-09-swot-analysis.png              Done
 11    slide-11-timeline.png                   Skipped — Napkin couldn't parse

To insert: open the PPTX, go to each slide, and replace
the text with the corresponding Napkin visual.
═══════════════════════════════════════════
```

---

## What Works Best with Napkin

Guide for selecting which slides to process:

**Great candidates:**
- Bullet point lists (especially 3-7 items)
- Comparisons (this vs. that, competitor matrices)
- Process flows / step-by-step workflows
- Timelines / chronological sequences
- SWOT, pros/cons, feature matrices
- Statistics / key metrics with context
- Hierarchies / org structures

**Poor candidates:**
- Dense paragraphs of narrative text (too much for a single visual)
- Tables with many rows of raw data (Napkin prefers conceptual content)
- Code snippets or technical specifications
- Slides that are already mostly visual

---

## Rules

1. **Never modify the original PPTX.** Generate visuals as separate image files. The user inserts them manually.
2. **Ask before processing.** Show the candidate list and get approval.
3. **One tab is enough.** Reuse the same Napkin tab for all slides — just clear and re-enter.
4. **Handle Napkin failures gracefully.** If Napkin can't generate a good visual for a slide, skip it and note it in the report. Don't retry more than twice.
5. **Descriptive filenames.** Every image file should make it obvious which slide it belongs to.
6. **Stay focused.** Don't explore other Napkin features. Input text, capture visual, move on.
