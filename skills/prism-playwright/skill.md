# Prism LaTeX Writer (Playwright for VM)

Open OpenAI's Prism LaTeX editor via Playwright and collaboratively write a mathematical/scientific document. **VM-compatible** - uses Playwright MCP instead of Chrome extension.

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

### Step 4: Write the LaTeX Document

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

### Step 5: Compile the Document

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

### Step 6: Verify with Code (if requested)

If the user wants code verification:

1. Switch to the terminal (Bash tool)
2. Write a Python verification script using NumPy/SciPy/SymPy as appropriate
3. Run the script and confirm results match the document's claims
4. Optionally, add the verification code as a `\begin{verbatim}` listing in the LaTeX document
5. Recompile to include the code listing

### Step 7: Download the PDF

**CRITICAL:** The final output MUST be a PDF file, not just .tex.

1. Take a snapshot to locate the download button in the PDF preview toolbar
2. Look for the download button (it's near the "Compile" button in the top toolbar)
   - The button typically appears as a download icon (downward arrow)
   - Use `browser_snapshot` to find the exact ref
3. Click the download button using `mcp__playwright__browser_click`
4. Wait 2-3 seconds for download to complete
5. The PDF will be downloaded to `.playwright-mcp/main.pdf`

### Step 8: Save Files Locally

1. Use `mcp__playwright__browser_evaluate` to extract the final LaTeX source:
   ```javascript
   window.monaco.editor.getEditors()[0].getModel().getValue()
   ```
2. Save the .tex file to a local location (e.g., `/tmp/<topic-name>.tex`)
3. Copy the downloaded PDF from `.playwright-mcp/main.pdf` to a meaningful location (e.g., `/tmp/<topic-name>.pdf`)
4. Verify both files with `ls -lh` and `file` commands
5. Tell the user where both the `.tex` and `.pdf` files are saved

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
| Cannot operate file dialogs | Save .tex locally via Write tool; user views PDF in Prism |
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
