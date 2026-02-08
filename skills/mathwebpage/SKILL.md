# MathWebpage — Math Paper + Manim Video + Interactive Webpage

Full pipeline: write a math paper (proof sketch → validation → lit review → Prism typesetting), create an animated Manim explainer video of the result, then assemble everything into a polished interactive webpage.

## Arguments

`<mathematical result or topic>` — What to build the page around.

Examples:
- `/mathwebpage the spectral theorem for symmetric matrices`
- `/mathwebpage convergence of gradient descent for convex functions`
- `/mathwebpage the Central Limit Theorem`
- `/mathwebpage Noether's theorem connecting symmetries and conservation laws`

If no arguments, ask the user what mathematical result they want to present.

---

## Pipeline

Three major steps in sequence. Each feeds the next.

### Step 1: Math Paper (`/mathpaper`)

Run the `/mathpaper` skill with the user's topic.

This runs its own internal pipeline:
- `/mathder` → proof sketch
- `/compval` → numerical validation with code + matplotlib figure
- `/litreview` → supporting references
- Prism → typeset LaTeX paper

Outputs at `~/mathpaper/<slug>/` with:
- `proof-sketch/<slug>.md` — the derivation
- `validation/validate_<slug>.py` — the code
- `validation/validation_<slug>.png` and `.pdf` — the figure
- `literature/sources.md` — the bibliography
- The compiled PDF in Prism (browser)

**Gate:** Wait for `/mathpaper` to complete fully (all 4 internal steps). Confirm with the user:

> "Math paper complete — proof, validation, references, and typeset PDF all done. Ready to create the Manim animation?"

Proceed only after user confirmation.

### Step 2: Manim Video (`/manim-composer` + ManimCE/ManimGL)

Use the Manim skills to create an animated explainer video of the mathematical result.

#### 2a. Plan with `/manim-composer`

Run the `/manim-composer` skill to plan the video. Feed it all the context from Step 1:

- The proof sketch markdown (the narrative backbone)
- The key equations and steps from the derivation
- The validation results and figure (can be animated)
- The key insights section

Tell `/manim-composer`:
- **Topic:** the mathematical result from Step 1
- **Style:** 3Blue1Brown-style — clean, visual, builds intuition before formalism
- **Duration:** 2-5 minutes (short explainer, not a lecture)
- **Audience:** someone who knows the prerequisites but hasn't seen this result
- **Structure suggestion:**
  1. **Hook (15-30s)** — pose the question or show the surprising result
  2. **Setup (30-60s)** — visual introduction of the key objects (vectors, matrices, functions, spaces)
  3. **Core argument (60-120s)** — animate the proof step by step, building each equation visually
  4. **Validation (15-30s)** — show the numerical validation — animate convergence, error shrinking
  5. **Punchline (15-30s)** — restate the result with full visual context, "and that's why..."

Wait for the scene plan (`scenes.md`) to be created.

#### 2b. Implement with ManimCE

Use the `manimce-best-practices` skill to implement the scenes from the plan.

Key implementation notes:
- Use `MathTex` for all equations (pull LaTeX directly from the proof sketch)
- Animate equation transformations with `TransformMatchingTex`
- Use color coding to track terms through manipulations
- Create custom objects for the mathematical structures involved
- Include the matplotlib validation plot as an `ImageMobject` or recreate it in Manim

Render the video:
```bash
manim -qh <scene_file>.py <SceneName>
```

Output: `media/videos/<scene_file>/1080p60/<SceneName>.mp4`

**Gate:** Wait for the video to render. Confirm with the user:

> "Manim video rendered (<duration>). Preview it and let me know if you want changes before building the webpage."

Proceed only after user confirmation.

### Step 3: Webpage (`/makewebpage`)

Run the `/makewebpage` skill to assemble everything into an interactive webpage.

Feed it all the artifacts from Steps 1 and 2:
- The proof sketch markdown
- The validation code and results
- The bibliography
- The Manim video file
- The matplotlib figure

Tell `/makewebpage`:
- **Source:** all artifacts from `~/mathpaper/<slug>/` and the Manim video
- **Type:** mathematical article with embedded video — a "visual proof" page
- **Style:** clean, academic but modern — dark/light mode, generous whitespace, beautiful math rendering
- **Features to include:**

  **Header Section:**
  - Title of the result
  - Author, date
  - Abstract / one-paragraph summary

  **Video Section:**
  - Embedded Manim video with HTML5 `<video>` player
  - Play/pause, fullscreen controls
  - Caption: "Visual proof walkthrough"

  **Proof Section:**
  - Full derivation rendered with KaTeX or MathJax (convert the proof sketch LaTeX)
  - Collapsible steps — each major step is expandable so the reader can go at their own pace
  - Step numbers matching the video timestamps (if feasible)

  **Validation Section:**
  - The matplotlib figure embedded as an image
  - Validation verdict (PASS/FAIL with metrics)
  - Collapsible code block showing the Python validation script
  - Syntax-highlighted with Prism.js (the syntax highlighter, not the LaTeX editor)

  **References Section:**
  - Bibliography from the lit review
  - Linked to DOIs / URLs where available

  **Navigation:**
  - Sticky sidebar: Video | Proof | Validation | References
  - Back-to-top button
  - Dark mode toggle

  **Math Rendering:**
  - Use KaTeX via CDN (faster than MathJax) for all inline and display math
  - `$...$` for inline, `$$...$$` for display
  - Proper theorem/proof styling with CSS (indented, italic statement, tombstone symbol)

  **Responsive:**
  - Video scales on mobile
  - Math equations scroll horizontally if too wide on small screens
  - Sidebar collapses to hamburger menu on mobile

---

## Output Organization

```
~/mathwebpage/<slug>/
├── paper/
│   ├── proof-sketch.md              ← from /mathder
│   ├── validate_<slug>.py           ← from /compval
│   ├── validation_<slug>.png        ← matplotlib figure
│   ├── validation_<slug>.pdf
│   ├── sources.md                   ← from /litreview
│   └── (Prism PDF in browser)
├── video/
│   ├── scenes.md                    ← from /manim-composer
│   ├── <scene_file>.py              ← Manim source
│   └── <SceneName>.mp4              ← rendered video
├── webpage/
│   ├── index.html                   ← THE DELIVERABLE
│   ├── video/
│   │   └── walkthrough.mp4          ← copy of Manim video
│   └── images/
│       └── validation.png           ← copy of matplotlib figure
└── README.md
```

---

## Final Report

```
Math Webpage Complete
═══════════════════════════════════════════
Result:             <mathematical statement>

Step 1 — Math Paper (/mathpaper):
  Proof sketch:     ~/mathpaper/<slug>/proof-sketch/
  Validation:       ✓ PASS (error: <value>)
  References:       N sources
  Prism PDF:        Compiled in browser

Step 2 — Manim Video:
  Duration:         <X>m <Y>s
  Resolution:       1080p60
  Scenes:           N
  File:             <path>.mp4

Step 3 — Webpage:
  File:             ~/mathwebpage/<slug>/webpage/index.html
  Features:         Video player, KaTeX proof, validation,
                    collapsible steps, dark mode, responsive

Pipeline: paper → animate → publish
═══════════════════════════════════════════
```

---

## Rules

1. **Sequential, not parallel.** The paper provides content for the video, and both provide content for the webpage.
2. **Gate between steps.** Always confirm before moving on. The user may want to refine the proof, re-record the video, or adjust the layout.
3. **The math paper is the source of truth.** The video visualizes it, the webpage presents it. Don't introduce new math in later steps.
4. **Video matches the proof.** The Manim animation should follow the same logical steps as the derivation, in the same order. Don't rearrange the argument for the video.
5. **KaTeX over MathJax.** KaTeX is faster and sufficient for most math. Only fall back to MathJax if KaTeX can't render something specific.
6. **Collapsible proof steps.** The derivation can be long. Make each major step collapsible so the page doesn't feel overwhelming. Default: first step expanded, rest collapsed.
7. **Video is the hero.** The video should be prominently placed — it's what makes this page different from a static paper. Put it near the top, large.
8. **Don't re-ask what's been answered.** Context flows forward through all steps. The user scopes the result once.
9. **Respect all child skill rules.** Each delegated skill has its own rules — follow them.
10. **The webpage is the deliverable.** Paper and video are intermediate steps (though valuable on their own). Focus polish effort on the final page.
