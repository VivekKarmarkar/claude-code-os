# MathPaper — From Proof Sketch to Formatted Paper

Full pipeline: sketch the derivation, validate it numerically, gather supporting literature, then typeset the whole thing as a beautifully formatted LaTeX document in Prism.

## Arguments

`<mathematical result or topic>` — What the paper is about.

Examples:
- `/mathpaper the spectral theorem for symmetric matrices`
- `/mathpaper convergence of gradient descent for convex functions`
- `/mathpaper the CLT via characteristic functions`
- `/mathpaper closed-form solution for the Kalman filter`
- `/mathpaper Noether's theorem connecting symmetries and conservation laws`

If no arguments, ask the user what mathematical result they want to write up.

---

## Pipeline

Four steps in sequence. Each feeds the next.

### Step 1: Proof Sketch (`/mathder`)

Run the `/mathder` skill with the user's topic.

This produces `~/mathder/<slug>.md` — a clean, step-by-step derivation with:
- Precise statement
- Setup and notation
- Step-by-step derivation with LaTeX
- Key insights

This is the **backbone** of the paper. Everything else supports it.

**Gate:** Wait for `/mathder` to complete. Confirm with the user:

> "Proof sketch complete at `~/mathder/<slug>.md`. Review it — this becomes the core of the paper. Ready to validate numerically?"

Proceed only after user confirmation.

### Step 2: Numerical Validation (`/compval`)

Run the `/compval` skill to computationally validate the result from Step 1.

Feed it the precise mathematical statement from the proof sketch. The validation script and figures will live at `~/compval/<slug>/`.

Key outputs needed for the paper:
- `validate_<slug>.py` — the validation code (will be included verbatim in the paper)
- `validation_<slug>.png` / `.pdf` — the matplotlib figure
- The PASS/FAIL verdict and error metrics

**Gate:** Wait for `/compval` to complete. Confirm with the user:

> "Numerical validation complete — <PASS/FAIL> with error <value>. Figure and code ready. Ready to search for supporting literature?"

Proceed only after user confirmation.

### Step 3: Literature Review (`/litreview`)

Run the `/litreview` skill to find supporting references for the result.

Scope the search to:
- **The original result** — who proved it first? What's the canonical reference?
- **Related work** — papers that use, extend, or generalize this result
- **Numerical methods** — papers on computational approaches to validating this type of result
- **Depth:** quick landscape (5-10 key references), not a deep dive

Key outputs needed for the paper:
- `~/lit-reviews/<slug>/sources.md` — the bibliography
- Key citations to reference in the proof and discussion

**Gate:** Wait for `/litreview` to complete. Confirm with the user:

> "Literature review complete. N key references found. Ready to typeset the paper in Prism?"

Proceed only after user confirmation.

### Step 4: Typeset in Prism (Chrome)

This is the main event. Open Prism (OpenAI's LaTeX editor) in Chrome and write the full paper.

#### 4a. Set Up Chrome

1. Call `mcp__claude-in-chrome__tabs_context_mcp` to verify Chrome MCP is connected
2. Create a new tab: `mcp__claude-in-chrome__tabs_create_mcp`
3. Navigate to `https://prism.chatgpt.com`
4. Wait for the Monaco editor to load

#### 4b. Paper Structure

Write the following LaTeX document in Prism's editor:

```latex
\documentclass[11pt]{article}

% ─── Packages ────────────────────────────────
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{amsmath, amssymb, amsthm}
\usepackage{mathtools}
\usepackage{geometry}
\usepackage{hyperref}
\usepackage{cleveref}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{enumitem}
\usepackage{natbib}

\geometry{margin=1in}

% ─── Theorem Environments ────────────────────
\newtheorem{theorem}{Theorem}
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{corollary}[theorem]{Corollary}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{definition}[theorem]{Definition}
\newtheorem{remark}{Remark}

% ─── Title ───────────────────────────────────
\title{<Paper Title>}
\author{<Author Name>}
\date{\today}

\begin{document}
\maketitle

% ─── Abstract ────────────────────────────────
\begin{abstract}
<2-3 sentences: what we prove, how we validate it, what references support it>
\end{abstract}

% ─── 1. Introduction ────────────────────────
\section{Introduction}
<Context, motivation, historical background. Cite the original result and key references from the lit review.>

% ─── 2. Preliminaries ──────────────────────
\section{Preliminaries}
<Definitions, notation, prerequisite results. Pulled from the Setup section of the proof sketch.>

% ─── 3. Main Result ─────────────────────────
\section{Main Result}

\begin{theorem}
<Precise statement from the proof sketch>
\end{theorem}

\begin{proof}
<Full derivation from the proof sketch, now in proper LaTeX proof environment.
 Each step from /mathder becomes a paragraph with equations.
 Use \begin{aligned} for multi-step manipulations.
 Reference lemmas/definitions from Preliminaries.
 Cite supporting results from the lit review where relevant.>
\end{proof}

% ─── 4. Computational Validation ────────────
\section{Computational Validation}

<Brief description of the numerical validation approach.>

\subsection{Method}
<What the simulation does, parameters, tolerances.>

\subsection{Implementation}

The validation was implemented in Python using NumPy and SciPy:

\begin{verbatim}
<VALIDATION CODE HERE — SEE CRITICAL WARNING BELOW>
\end{verbatim}

\subsection{Results}

<Report the PASS/FAIL verdict, error metrics, convergence behavior.>

% Include the matplotlib figure
% \includegraphics[width=\textwidth]{validation_<slug>.pdf}

<Since Prism can't include local images, describe the figure and note it's available at the file path. Or reference Figure 1 and instruct the user to add it when compiling locally.>

% ─── 5. Discussion ──────────────────────────
\section{Discussion}
<Key insights from the proof sketch's "Key Insights" section.
 How the numerical results support the theoretical result.
 Connections to the literature found in the lit review.
 Limitations, generalizations, open questions.>

% ─── 6. Conclusion ──────────────────────────
\section{Conclusion}
<Summary: what was proved, validated, and contextualized.>

% ─── Bibliography ────────────────────────────
\begin{thebibliography}{99}
<References from the lit review, formatted as \bibitem entries.>
\end{thebibliography}

\end{document}
```

#### 4c. CRITICAL: Handling Verbatim Code in Prism

**This is the known Prism/Monaco auto-indent issue. Follow these steps exactly.**

Prism uses Monaco editor. When you type inside `\begin{verbatim}`, Monaco auto-indents every new line with ~40 spaces. Since `verbatim` preserves ALL whitespace, this pushes the code massively to the right in the PDF.

**The fix — use Monaco API to clean up after typing:**

1. Type the full document including the verbatim code block
2. After ALL typing is done, run JavaScript via the Chrome MCP to fix the indentation:

```javascript
// Get the current editor content
const editor = window.monaco.editor.getEditors()[0];
const model = editor.getModel();
let content = model.getValue();

// Find verbatim blocks and strip leading spaces from lines inside them
content = content.replace(
  /\\begin\{verbatim\}([\s\S]*?)\\end\{verbatim\}/g,
  (match, inner) => {
    const fixedInner = inner.split('\n').map(line => line.trimStart()).join('\n');
    return '\\begin{verbatim}' + fixedInner + '\\end{verbatim}';
  }
);

// Set the cleaned content back
model.setValue(content);
```

3. **Verify** by taking a screenshot after the fix to confirm the code block looks correct in the editor
4. Only then compile the PDF

**Alternative approach:** If the verbatim block is short, you can also type it character-by-character using the Monaco API `setValue()` for just that section, bypassing the auto-indent entirely.

#### 4d. Compile and Verify

1. Click the Compile button (approximately at coordinates (611, 40) in the Prism UI)
2. Wait for compilation to complete
3. Take a screenshot of the PDF output
4. Check specifically:
   - Does the proof render correctly? (no broken LaTeX)
   - Is the verbatim code block properly aligned? (not pushed right)
   - Are the bibliography entries formatted correctly?
   - Do theorem environments render properly?
5. If issues, fix and recompile

#### 4e. Iterate with User

Show the user the compiled PDF screenshot:

> "Here's the paper. Check the proof, code block, and references. Want me to change anything?"

---

## Output Organization

```
~/mathpaper/<slug>/
├── proof-sketch/
│   └── <slug>.md                    ← symlink or copy from ~/mathder/<slug>.md
├── validation/
│   ├── validate_<slug>.py           ← symlink or copy from ~/compval/<slug>/
│   ├── validation_<slug>.png
│   └── validation_<slug>.pdf
├── literature/
│   └── sources.md                   ← symlink or copy from ~/lit-reviews/<slug>/sources.md
└── paper/
    └── <slug>.tex                   ← the LaTeX source (copy from Prism if possible)
```

Also create this directory structure and copy/symlink the artifacts so everything for the paper is in one place.

---

## Final Report

```
Math Paper Complete
═══════════════════════════════════════════
Result:             <mathematical statement>

Step 1 — Proof Sketch:
  File:             ~/mathder/<slug>.md
  Steps:            N major steps

Step 2 — Numerical Validation:
  Verdict:          ✓ PASS (error: <value>)
  Script:           ~/compval/<slug>/validate_<slug>.py
  Figure:           ~/compval/<slug>/validation_<slug>.pdf

Step 3 — Literature Review:
  References:       N sources
  Key citation:     <canonical reference for the result>

Step 4 — Prism Typesetting:
  Compiled:         Yes / No
  Sections:         Abstract, Intro, Preliminaries, Main Result,
                    Validation, Discussion, Conclusion, Bibliography
  Verbatim fix:     Applied (Monaco API)

Paper assembled at: ~/mathpaper/<slug>/
Prism document:     Open in browser

Pipeline: sketch → validate → cite → typeset
═══════════════════════════════════════════
```

---

## Rules

1. **Sequential, not parallel.** Each step depends on the previous one. The proof sketch drives everything.
2. **Gate between steps.** Always confirm before moving on. The user may want to refine the proof before validating it.
3. **The proof sketch is the source of truth.** The Prism document is a formatted version of it, not a rewrite. Don't change the math when typesetting.
4. **Fix verbatim blocks EVERY TIME.** The Monaco auto-indent issue is a known bug. Always run the JavaScript fix after typing code in verbatim environments. Never skip this step.
5. **Verify after compile.** Always screenshot the PDF and check that verbatim code is left-aligned, equations render, and bibliography is present.
6. **Bibliography goes last in the document, first in the workflow.** When writing in Prism, add the `\bibitem` entries early so you can `\cite{}` them throughout. The lit review from Step 3 provides these.
7. **Don't over-cite.** This is a math paper, not a survey. 5-10 well-chosen references beat 30 tangential ones.
8. **One theorem, one paper.** Keep focused on the single result. Discussion can mention generalizations but the paper proves one thing.
9. **Respect all child skill rules.** Each delegated skill has its own rules — follow them.
10. **The PDF is the deliverable.** Everything else is intermediate. The compiled Prism output is what matters.
