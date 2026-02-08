# Make Webpage — Build a Webpage from Context

Create a polished, responsive webpage from whatever context is available — a description, a document, data, conversation history, or an existing file. Uses HTML, CSS (Tailwind), and JavaScript/TypeScript as needed.

## Arguments

`<description or source>` — What the webpage should be or where to pull content from.

Examples:
- `/makewebpage a personal portfolio site for a physicist`
- `/makewebpage landing page for an AI tutoring startup`
- `/makewebpage convert ~/lit-reviews/crispr-delivery/summary.md into a webpage`
- `/makewebpage interactive dashboard showing market sizing data from ~/market-research/ev-charging/analysis/market-sizing.md`
- `/makewebpage` — no args, pull from conversation context and ask

If no arguments, look at the current conversation for relevant context (recent research, data, topics) and propose a webpage. If nothing obvious, ask the user what they want.

## Pre-flight Check

1. Check if `node` is installed (`node --version`). If not, warn the user — live preview won't work.
2. Check the working directory. Ask the user where to save the output if unclear.

---

## Phase 1: Understand the Page

Before writing code, clarify:

1. **Purpose** — What is this page for? (portfolio, landing page, dashboard, documentation, blog post, data visualization, interactive tool)
2. **Content source** — Where does the content come from?
   - Conversation context (recent discussion, research results)
   - A local file (markdown, JSON, CSV, PPTX)
   - User's description
   - A combination
3. **Audience** — Who will see this? (public, personal, investors, academic)
4. **Style** — Any preferences? (minimal, bold, corporate, playful, dark mode)
5. **Interactivity** — Static content or interactive elements? (forms, filters, animations, charts)
6. **Single page or multi-page?** — Most cases: single page. Only multi-page if the user asks.

If the user gave a clear description, skip straight to building. Don't over-ask.

---

## Phase 2: Design Decisions

Based on the purpose, choose the right approach:

### Tech Stack

**Always use:**
- HTML5 with semantic elements
- Tailwind CSS via CDN (`<script src="https://cdn.tailwindcss.com"></script>`)
- Clean, modern typography (Inter or system fonts via Tailwind)

**Add when needed:**
- **JavaScript** — for interactivity, DOM manipulation, animations
- **Chart.js** (via CDN) — for data visualization, charts, graphs
- **Alpine.js** (via CDN) — for lightweight reactivity (toggles, tabs, filters)
- **Marked.js** (via CDN) — if rendering markdown content
- **Prism.js** (via CDN) — if displaying code with syntax highlighting
- **TypeScript** — only if the project already uses it or user specifically requests it

**Prefer CDN over npm installs** for single-page sites. Keep it self-contained.

### Design Principles

- **Mobile-first** — design for phone, scale up to desktop
- **Whitespace** — generous padding and margins, don't cram
- **Typography hierarchy** — clear distinction between headings, subheadings, body
- **Color** — use a cohesive palette, not random colors. Tailwind's built-in palettes are fine. Limit to 2-3 colors plus neutrals.
- **Contrast** — meet WCAG AA accessibility standards
- **Subtle animations** — fade-ins, smooth scrolls, hover effects. Nothing flashy.
- **No stock photos** — use gradients, patterns, icons, or abstract shapes instead of placeholder images

---

## Phase 3: Build the Page

### File Structure

For a single-page site, create one self-contained HTML file:

```
<output-directory>/
└── index.html        ← everything in one file (HTML + Tailwind + JS)
```

For more complex pages, split if needed:

```
<output-directory>/
├── index.html
├── style.css         ← only if custom CSS beyond Tailwind is needed
├── app.js            ← only if JS is substantial (50+ lines)
└── assets/           ← only if there are local images/data files
    └── data.json
```

**Default to single-file.** Only split when the file would exceed ~500 lines.

### Content Integration

Depending on the source:

**From markdown files:**
- Read the file, parse the structure
- Convert headings → sections, lists → styled lists, etc.
- Don't just dump raw markdown — redesign it as a proper webpage

**From data/JSON/CSV:**
- Create appropriate visualizations (tables, charts, cards)
- Add sorting/filtering if there are many items

**From conversation context:**
- Extract key information discussed in the session
- Organize into logical sections
- Write clean copy — don't just paste chat messages

**From user description:**
- Generate appropriate placeholder content that feels real
- Use realistic text, not "Lorem ipsum"
- Make it clear where the user should replace placeholder content with comments like `<!-- Replace with your actual bio -->`

### Code Quality

- **Semantic HTML** — use `<header>`, `<main>`, `<section>`, `<article>`, `<footer>`, not just `<div>` soup
- **Tailwind classes** — use utility classes directly, avoid `@apply` unless truly needed
- **Readable code** — indent properly, group related elements, comment sections
- **Responsive** — use Tailwind responsive prefixes (`sm:`, `md:`, `lg:`) throughout
- **Accessible** — alt text on images, proper heading hierarchy, keyboard navigable, aria labels on interactive elements
- **Fast** — no unnecessary libraries, optimize for quick load

---

## Phase 4: Preview

After building the page:

1. Open it in Chrome using the browser automation tools:
   - `mcp__claude-in-chrome__tabs_create_mcp` for a new tab
   - `mcp__claude-in-chrome__navigate` to `file://<absolute-path>/index.html`
2. Take a screenshot to show the user what it looks like
3. Check for obvious issues:
   - Does the layout look right?
   - Is text readable?
   - Do responsive breakpoints work? (resize the window to check mobile)
4. If something looks off, fix it and re-preview

---

## Phase 5: Iterate

Show the user the screenshot and ask:

```
Here's your page. What would you like to change?
- Layout / structure
- Colors / styling
- Content / copy
- Add interactivity
- Looks good, ship it
```

Make requested changes and re-preview. Repeat until the user is happy.

---

## Page Type Templates

Use these as starting structures depending on the purpose:

### Landing Page
- Hero section with headline + CTA
- Features / benefits grid (3-4 items)
- Social proof / testimonials
- Pricing or details section
- Footer with links

### Portfolio
- Hero with name + tagline
- About section
- Projects grid with cards
- Skills / tech stack
- Contact section

### Dashboard / Data Page
- Header with title + filters
- Key metrics row (big numbers)
- Charts section
- Data table with sorting
- Footer

### Documentation / Article
- Sticky sidebar navigation
- Main content area with sections
- Code blocks if technical
- Table of contents
- Back to top button

### Interactive Tool
- Input area (forms, uploads, text areas)
- Output / results area
- Controls (sliders, toggles, dropdowns)
- Clear / reset functionality

---

## Rules

1. **Self-contained by default.** Use CDN links, not npm installs. The page should work by just opening the HTML file.
2. **Tailwind always.** Don't write raw CSS unless there's something Tailwind genuinely can't do (rare).
3. **No frameworks unless asked.** Don't scaffold a React/Vue/Svelte app. Use vanilla HTML + JS. If the user wants a framework, they'll say so.
4. **Real content over lorem ipsum.** Generate realistic placeholder text that matches the page's purpose.
5. **Preview in Chrome.** Always show the user what it looks like before declaring it done.
6. **Responsive is non-negotiable.** Every page must work on mobile, tablet, and desktop.
7. **Don't overdesign.** Clean and functional beats flashy and complex. Ship something good, iterate from there.
8. **Comment the sections.** Use HTML comments to label major sections so the user can find and edit them later.
