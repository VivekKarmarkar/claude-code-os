# Prism LaTeX Writer (Playwright for VM)

Open OpenAI's Prism LaTeX editor via Playwright and collaboratively write a mathematical/scientific document. **VM-compatible** - uses Playwright MCP instead of Chrome extension.

**Key Features:**
- AI-powered LaTeX editor with real-time PDF preview
- Integrated ChatGPT for LaTeX assistance (can help with formatting, equations, citations)
- Final output is a compiled PDF (not just .tex source)

## Arguments

`<topic or instructions>` — What the LaTeX document should be about. Can be a math topic, a paper outline, or detailed instructions.

If no arguments are provided, ask the user what they'd like to write about before opening Prism.

## Pre-flight Check

**CRITICAL: Do this FIRST before anything else.**

1. Verify Playwright browser is available by taking a snapshot
2. If the browser isn't running or fails to respond, start it with `mcp__playwright__browser_navigate` to `about:blank`
3. If that fails, tell the user the Playwright browser isn't available

## Workflow

### Step 1: Discuss the Document

Before touching the browser, have a conversation with the user about what they want:

- **Topic** — What is the mathematical/scientific topic?
- **Depth** — Introductory, intermediate, or rigorous?
- **Sections** — What should the document cover? (definitions, theorems, proofs, examples, code listings?)
- **Verification** — Should we write a Python/code verification script alongside the math?
- **Special requests** — Any packages, formatting preferences, or specific content?

Use `AskUserQuestion` to gather this if the user hasn't provided enough detail. Offer sensible defaults.

### Step 2: Open Prism

1. Navigate to Prism: `mcp__playwright__browser_navigate` with URL `https://prism.openai.com`
2. Wait 3 seconds: `mcp__playwright__browser_wait_for` with time: 3
3. Take a snapshot to verify Prism loaded: `mcp__playwright__browser_snapshot`

If Prism asks for login or shows an error, tell the user and stop.

### Step 3: Create a New Project

1. Take a snapshot to see the current state (might be dashboard or existing project)
2. Look for a "New Project" or "+" button and click it using `mcp__playwright__browser_click`
3. If already on a fresh editor (blank `main.tex`), proceed directly
4. Wait for the Monaco editor to be ready (use `browser_wait_for` with time: 2)
5. Take a snapshot to confirm the editor is loaded

### Step 4: Create Bibliography File (if needed)

**For professional documents with references, create the `.bib` file FIRST:**

1. Click "Add file or folder" button in the file panel
2. Select "Add File"
3. Name it `references.bib`
4. Use Monaco API to populate with professional BibTeX entries:
   ```javascript
   const editor = window.monaco?.editor?.getEditors?.()?.[0];
   if (!editor) throw new Error('Monaco editor not found');
   editor.getModel().setValue(`@book{key1,...}\n@article{key2,...}`);
   ```
5. Click on `main.tex` in the file tree to switch back to the main document

**Skip this step** if using simple embedded bibliography (`\begin{thebibliography}`).

### Step 5: Write the LaTeX Document

Write the document in the Monaco editor using Playwright tools. Follow these guidelines:

**Document structure:**
```latex
\documentclass[11pt]{article}
\usepackage{amsmath, amssymb, amsthm}
\usepackage[margin=1in]{geometry}
\usepackage{verbatim}

\title{...}
\author{...}
\date{\today}

\begin{document}
\maketitle

% Content sections...

\end{document}
```

**Typing strategy:**

**OPTION 1 - Use Monaco API (Recommended):**
Use `mcp__playwright__browser_evaluate` to set editor content directly:

```javascript
const editor = window.monaco?.editor?.getEditors?.()?.[0];
if (!editor) throw new Error('Monaco editor not found');
const model = editor.getModel();
model.setValue(`YOUR_LATEX_CONTENT_HERE`);
```

This is faster and avoids auto-indent issues.

**OPTION 2 - Type incrementally:**
- Click into the editor first
- Use `mcp__playwright__browser_type` for content
- Type in logical chunks (preamble, then each section)
- After typing each major section, take a snapshot to verify

**IMPORTANT — Monaco quirks:**
- Monaco auto-indents inside environments. For `\begin{verbatim}` blocks, this adds unwanted leading spaces.
- **Fix:** Use the Monaco API approach (Option 1) to avoid this entirely.
- Or use JavaScript to clean after typing:
  ```javascript
  const editor = window.monaco.editor.getEditors()[0];
  const model = editor.getModel();
  let text = model.getValue();
  // Fix verbatim indentation
  text = text.replace(/^( {4,})/gm, '');
  model.setValue(text);
  ```

**Citations and Bibliography:**

Prism supports **BOTH** simple and professional bibliography workflows. Choose based on your needs:

**OPTION A — Simple Embedded Bibliography (Quick documents, 1-5 references)**

Use for: Short documents, quick demos, simple reports

```latex
% In text:
Discovered by Euler \cite{euler1748}, this formula...

% At end of document:
\begin{thebibliography}{9}
\bibitem{euler1748}
L. Euler. \textit{Introductio in analysin infinitorum}. Lausanne, 1748.
\end{thebibliography}
```

✅ No external files needed
✅ Single-pass compilation
❌ Manual formatting, not reusable

**OPTION B — Professional BibLaTeX (RECOMMENDED for serious work)**

Use for: Academic papers, publications, reusable bibliographies, 10+ references

**Setup:**

1. **Create `references.bib` file** in Prism:
   - Click "Add file or folder" button
   - Select "Add File"
   - Name it `references.bib`
   - Populate with professional BibTeX entries (see format below)

2. **In main.tex preamble:**
   ```latex
   \usepackage[style=numeric,sorting=nyt]{biblatex}
   \addbibresource{references.bib}
   ```

3. **In text:**
   ```latex
   According to Knuth \cite{knuth1997art}, algorithms...
   ```

4. **At end of document (instead of `\end{document}`):**
   ```latex
   \printbibliography

   \end{document}
   ```

**Professional BibTeX Entry Format:**

```bibtex
@book{knuth1997art,
  author    = {Donald E. Knuth},
  title     = {The Art of Computer Programming, Volume 1: Fundamental Algorithms},
  publisher = {Addison-Wesley},
  year      = {1997},
  edition   = {3rd},
  isbn      = {0-201-89683-4}
}

@article{dijkstra1968letters,
  author  = {Edsger W. Dijkstra},
  title   = {Letters to the editor: go to statement considered harmful},
  journal = {Communications of the ACM},
  volume  = {11},
  number  = {3},
  pages   = {147--148},
  year    = {1968},
  doi     = {10.1145/362929.362947}
}

@inproceedings{lamport1978time,
  author    = {Leslie Lamport},
  title     = {Time, Clocks, and the Ordering of Events in a Distributed System},
  booktitle = {Communications of the ACM},
  volume    = {21},
  number    = {7},
  pages     = {558--565},
  year      = {1978},
  doi       = {10.1145/359545.359563}
}
```

✅ **TESTED AND CONFIRMED WORKING** in Prism
✅ Professional formatting with DOIs, ISBNs, volume numbers
✅ Reusable across projects
✅ Single-pass compilation (Prism handles biber automatically)
✅ Industry standard for academic/professional publications

**When to use Professional BibLaTeX:**
- Academic papers and publications
- Documents with 10+ references
- Collaborative work (shared `.bib` databases)
- When you need DOI/ISBN/volume number formatting
- When bibliography will be reused across projects
- **Any serious professional work**

### Step 6: Compile the Document

1. Take a snapshot to locate the Compile button
2. Click the Compile button using `mcp__playwright__browser_click` with the button's ref
3. Wait 3-5 seconds for compilation: `mcp__playwright__browser_wait_for` with time: 5
4. Take a snapshot to check for errors
5. If there are LaTeX errors:
   - Read the error messages from the snapshot
   - Use Monaco API to get current content: `browser_evaluate` with `window.monaco.editor.getEditors()[0].getModel().getValue()`
   - Fix the errors
   - Use Monaco API to update content
   - Recompile
6. If successful, the PDF preview should appear on the right side

### Step 7: Verify with Code (if requested)

If the user wants code verification:

1. Switch to the terminal (Bash tool)
2. Write a Python verification script using NumPy/SciPy/SymPy as appropriate
3. Run the script and confirm results match the document's claims
4. Optionally, add the verification code as a `\begin{verbatim}` listing in the LaTeX document
5. Recompile to include the code listing

### Step 8: Download the PDF

**CRITICAL:** You MUST download the PDF. This is NOT optional.

1. Take a snapshot to locate the download button in the PDF preview toolbar
2. The download button is in the toolbar next to the "Compile" button
   - Use `browser_snapshot` to find the exact ref
3. Click the download button using `mcp__playwright__browser_click`
4. Wait 2-3 seconds for download to complete
5. The PDF will be downloaded to `.playwright-mcp/main.pdf`
6. **Immediately** move it to the LaTeX project folder with a meaningful name:
   ```bash
   mv .playwright-mcp/main.pdf ~/Python\ Files/give-claude-a-computer/LaTeX\ project/<topic-name>.pdf
   ```

### Step 9: Save Files Locally

1. **Extract and save main.tex**:
   - Click on `main.tex` in the file tree
   - Use `mcp__playwright__browser_evaluate` to extract content:
     ```javascript
     window.monaco.editor.getEditors()[0].getModel().getValue()
     ```
   - Save to local location (e.g., `~/Python Files/give-claude-a-computer/LaTeX project/<topic-name>.tex`)

2. **Extract and save references.bib** (if using professional BibLaTeX):
   - Click on `references.bib` in the file tree
   - Use `mcp__playwright__browser_evaluate` to extract content:
     ```javascript
     window.monaco.editor.getEditors()[0].getModel().getValue()
     ```
   - Save to same location (e.g., `~/Python Files/give-claude-a-computer/LaTeX project/<topic-name>-references.bib`)

3. **Verify all files**:
   ```bash
   ls -lh ~/Python\ Files/give-claude-a-computer/LaTeX\ project/ | grep <topic-name>
   ```

4. **Report to user**:
   - Location of .tex file
   - Location of .bib file (if applicable)
   - Location of .pdf file
   - File sizes and compilation results (pages, citations rendered)

## Playwright-Specific Patterns

### Getting Monaco editor content:
```javascript
const editor = window.monaco?.editor?.getEditors?.()?.[0];
if (!editor) return 'Editor not found';
return editor.getModel().getValue();
```

### Setting Monaco editor content:
```javascript
const editor = window.monaco?.editor?.getEditors?.()?.[0];
if (!editor) throw new Error('Editor not found');
editor.getModel().setValue(`...new content...`);
```

### Checking if editor is ready:
```javascript
window.monaco?.editor?.getEditors?.()?.length > 0
```

### Scrolling to bottom of editor:
```javascript
const editor = window.monaco.editor.getEditors()[0];
const lineCount = editor.getModel().getLineCount();
editor.setPosition({ lineNumber: lineCount, column: 1 });
editor.revealLine(lineCount);
```

## Known Issues & Workarounds

| Issue | Workaround |
|-------|-----------|
| Monaco auto-indent in verbatim | Use Monaco API to set content directly (Option 1) |
| Compile button location may shift | Always take snapshot first to find ref |
| Long documents may need scrolling | Use Monaco API to navigate, or scroll with `browser_evaluate` |
| Prism login required | User must be logged in to OpenAI account |

## Rules

1. **Always discuss the document plan with the user first** before opening Prism. Don't assume what they want.
2. **Take snapshots frequently** — after opening Prism, after creating a project, after major edits, after compiling.
3. **Prefer Monaco API over typing** — Use `browser_evaluate` to set content directly when possible. Faster and cleaner.
4. **Compile and verify** — Always compile the document and check for errors before declaring it done.
5. **If something breaks** (editor not responding, compilation fails repeatedly), take a snapshot, show the user, and ask how to proceed. Don't retry more than 3 times.
6. **Math rigor** — When writing math, be precise. Define notation, state assumptions, show derivations. Don't hand-wave.
7. **Code verification** — If the document makes numerical claims, offer to verify them with Python.
8. **Save the .tex file** — Always save the final LaTeX source to a local file using Write tool so the user has it.
