# Prism LaTeX Writer

Open OpenAI's Prism LaTeX editor in Chrome and collaboratively write a mathematical/scientific document.

## Arguments

`<topic or instructions>` — What the LaTeX document should be about. Can be a math topic, a paper outline, or detailed instructions.

If no arguments are provided, ask the user what they'd like to write about before opening Prism.

## Pre-flight Check

**CRITICAL: Do this FIRST before anything else.**

1. Call `mcp__claude-in-chrome__tabs_context_mcp` to verify the Chrome MCP extension is connected.
2. If the call **fails or returns an error**, STOP immediately and tell the user:
   ```
   Chrome MCP extension is not connected. Please:
   1. Open Chrome
   2. Click the Claude-in-Chrome extension icon
   3. Make sure it shows "Connected"
   4. Try /prism again
   ```
3. If the call **succeeds**, proceed to the next step.

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

1. Create a new tab: `mcp__claude-in-chrome__tabs_create_mcp`
2. Navigate to: `mcp__claude-in-chrome__navigate` with URL `https://prism.openai.com`
3. Wait 3 seconds for the page to load
4. Take a screenshot to verify Prism loaded

If Prism asks for login or shows an error, tell the user and stop.

### Step 3: Create a New Project

1. Take a screenshot to see the current state (might be dashboard or existing project)
2. Look for a "New Project" or "+" button and click it
3. If already on a fresh editor (blank `main.tex`), proceed directly
4. Wait for the Monaco editor to be ready
5. Take a screenshot to confirm the editor is loaded

### Step 4: Write the LaTeX Document

Write the document in the Monaco editor by typing LaTeX code. Follow these guidelines:

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
- Type in logical chunks (preamble, then each section)
- Use `type` action for content — Monaco will handle syntax highlighting
- Press Enter for new lines within the editor
- After typing each major section, take a screenshot to verify

**IMPORTANT — Monaco quirks:**
- Monaco auto-indents inside environments. For `\begin{verbatim}` blocks, this adds ~40 unwanted leading spaces.
- **Fix:** After typing verbatim content, use JavaScript to clean it:
  ```
  mcp__claude-in-chrome__javascript_tool:
  const editor = window.monaco.editor.getEditors()[0];
  const model = editor.getModel();
  let text = model.getValue();
  // Fix verbatim indentation
  text = text.replace(/^( {4,})/gm, (match, spaces) => {
    // Only strip excess indent inside verbatim blocks
    return '';
  });
  model.setValue(text);
  ```
- Better approach: Use Monaco API to set content for verbatim blocks rather than typing them character by character.

### Step 5: Compile the Document

1. Click the Compile button (approximately at coordinates (611, 40) in the Prism UI — verify with a screenshot first)
2. Wait 3-5 seconds for compilation
3. Take a screenshot to check for errors
4. If there are LaTeX errors, read them, fix the source, and recompile
5. If successful, the PDF preview should appear on the right side

### Step 6: Verify with Code (if requested)

If the user wants code verification:

1. Switch to the terminal (Bash tool)
2. Write a Python verification script using NumPy/SciPy/SymPy as appropriate
3. Run the script and confirm results match the document's claims
4. Optionally, add the verification code as a `\begin{verbatim}` listing in the LaTeX document
5. Recompile to include the code listing

### Step 7: Download the PDF

1. Tell the user: "The document is ready in Prism. You can download the PDF using the download button in Prism's toolbar."
2. Note: Chrome MCP cannot operate native file dialogs, so the user must handle the download.
3. Alternatively, if the PDF is viewable, serve it locally:
   ```bash
   python3 -m http.server 8765 --directory ~/Downloads
   ```
   Then navigate to `http://localhost:8765/main.pdf` in a new tab for viewing.

## Known Issues & Workarounds

| Issue | Workaround |
|-------|-----------|
| Monaco auto-indent in verbatim | Use Monaco JS API to strip leading spaces after typing |
| Cannot screenshot file:// URLs | Serve PDF via `python3 -m http.server PORT` |
| Cannot operate file dialogs | User must handle downloads/uploads manually |
| Compile button location may shift | Always take a screenshot first to locate it |
| Long documents may need scrolling | Use Monaco API or Page Down to navigate |

## Monaco API Reference

Useful JavaScript snippets for interacting with the editor:

```javascript
// Get editor instance
const editor = window.monaco.editor.getEditors()[0];
const model = editor.getModel();

// Read content
const content = model.getValue();

// Set content (replaces everything)
model.setValue(newContent);

// Get line count
const lines = model.getLineCount();

// Go to end of document
editor.setPosition({ lineNumber: lines, column: 1 });
editor.revealLine(lines);

// Insert text at cursor
editor.trigger('keyboard', 'type', { text: 'inserted text' });
```

## Rules

1. **Always discuss the document plan with the user first** before opening Prism. Don't assume what they want.
2. **Take screenshots frequently** — after opening Prism, after creating a project, after typing each section, after compiling.
3. **Fix verbatim blocks** — Always check and fix auto-indent issues in verbatim environments before compiling.
4. **Compile and verify** — Always compile the document and check for errors before declaring it done.
5. **If something breaks** (editor not responding, compilation fails repeatedly), take a screenshot, show the user, and ask how to proceed. Don't retry more than 3 times.
6. **Math rigor** — When writing math, be precise. Define notation, state assumptions, show derivations. Don't hand-wave.
7. **Code verification** — If the document makes numerical claims, offer to verify them with Python.
