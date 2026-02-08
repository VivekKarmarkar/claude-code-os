# Literature Review — Research, Organize, Present

Conduct a thorough academic literature review: find papers, map connections, read and summarize them, organize everything locally, and produce a polished presentation.

## Arguments

`<research topic or question>` — What the literature review is about.

Examples:
- `/litreview CRISPR delivery mechanisms for in vivo gene therapy`
- `/litreview transformer architectures for time series forecasting`
- `/litreview effects of microplastics on marine biodiversity`

If no arguments, ask the user for their research topic, scope, and any constraints (date range, specific journals, key authors to include).

## Pre-flight Check

1. Call `mcp__claude-in-chrome__tabs_context_mcp` to verify Chrome MCP is connected. If not, stop and tell the user to connect it — Chrome is needed for Connected Papers and Napkin AI.
2. Confirm the user's home directory is accessible for saving files.

---

## Phase 1: Scope the Review

Before searching, clarify with the user:

1. **Topic focus** — What specific question or area?
2. **Depth** — Quick survey (5-10 papers) or deep dive (20-30 papers)?
3. **Date range** — Recent only (last 5 years)? Or historical too?
4. **Key papers** — Any seed papers the user already knows about?
5. **Audience** — Who is the presentation for? (determines technical depth)

Use answers to guide search strategy.

---

## Phase 2: Search for Papers

Use multiple sources in parallel to build a comprehensive paper list.

### Source 1: Web Search (Google Scholar)

Use `WebSearch` with targeted queries:
- `"<topic>" site:scholar.google.com`
- `"<topic>" review OR survey OR meta-analysis`
- `"<topic>" <key author names>`
- Vary queries to cover different angles of the topic.

Extract: title, authors, year, citation count, DOI/URL.

### Source 2: PubMed (for biomedical/life sciences topics)

If the topic is biomedical, use the PubMed MCP tools:
- `mcp__claude_ai_PubMed__search_articles` with relevant queries
- `mcp__claude_ai_PubMed__get_article_metadata` for detailed info
- `mcp__claude_ai_PubMed__find_related_articles` to expand from key papers
- `mcp__claude_ai_PubMed__get_full_text_article` for open-access full text

### Source 3: Connected Papers (Citation Graph)

For the top 3-5 most relevant papers found so far:

1. Open a new Chrome tab: `mcp__claude-in-chrome__tabs_create_mcp`
2. Navigate to `https://www.connectedpapers.com/`
3. Search for the paper by title or DOI
4. Once the graph loads, take a snapshot to read the connected papers
5. Identify:
   - **Prior work** — foundational papers this paper builds on
   - **Derivative work** — papers that cite this one
   - **Clusters** — groups of related papers that form sub-topics
6. Add newly discovered important papers to the list

### Source 4: arXiv (for CS, physics, math topics)

If the topic is in CS/physics/math, use `WebSearch` with:
- `site:arxiv.org "<topic>"`
- Check for recent preprints not yet in other databases

### Compile the Master List

Create a deduplicated list of all found papers, ranked by:
1. Relevance to the research question
2. Citation count (influence)
3. Recency
4. Whether it's a review/survey paper (prioritize these)

Present the list to the user:
```
Found N papers. Top candidates:

 #  Year  Citations  Title                                    Authors
 1  2024  342        <title>                                  <first author et al.>
 2  2023  891        <title>                                  <first author et al.>
 ...
```

Ask: "Which papers should I include? All of them, or a subset?"

---

## Phase 3: Read and Analyze Papers

For each selected paper:

### 3a. Get the Full Text

Try in this order:
1. PubMed Central full text (`mcp__claude_ai_PubMed__get_full_text_article`) if available
2. Open-access PDF via DOI link (use Chrome to navigate and check)
3. arXiv PDF if available
4. Fall back to abstract only if full text isn't freely available

### 3b. Read and Extract

For each paper, extract:
- **Core claim / thesis** — What is this paper arguing or demonstrating?
- **Methods** — What approach did they use?
- **Key findings** — What are the main results?
- **Limitations** — What do the authors acknowledge as limitations?
- **Relevance** — How does this connect to the research question?
- **Key figures/tables** — Note which figures are most important
- **Key quotes** — 1-2 short quotes that capture the paper's essence

### 3c. Map Relationships

As you read, build a mental model of how papers relate:
- Which papers agree/disagree?
- What's the chronological progression of ideas?
- Are there competing schools of thought?
- What gaps exist in the literature?

---

## Phase 4: Create Folder Structure

Create an organized directory structure on the user's computer:

```
~/lit-reviews/<topic-slug>/
├── papers/
│   ├── AuthorYear_ShortTitle.pdf
│   ├── AuthorYear_ShortTitle.pdf
│   └── ...
├── notes/
│   ├── AuthorYear_ShortTitle.md
│   └── ...
├── presentation/
│   └── lit-review-<topic-slug>.pptx
├── summary.md
└── bibliography.md
```

### Naming Convention

- **Folder name:** lowercase, hyphen-separated topic slug (e.g., `crispr-delivery-mechanisms`)
- **Paper PDFs:** `LastnameYear_TwoOrThreeWordTitle.pdf` (e.g., `Chen2024_CRISPRDelivery.pdf`)
- **Note files:** Same as PDF but `.md` extension
- **No spaces in filenames.** Use CamelCase or hyphens.

### Download Papers

For each paper with a freely available PDF:
1. Navigate to the PDF URL in Chrome
2. Ask the user for permission to download
3. Save to the `papers/` directory with proper naming

**Important:** Only download open-access papers. Do not attempt to bypass paywalls. If a paper is behind a paywall, note it in `bibliography.md` with access instructions.

### Create Note Files

For each paper, create a markdown note in `notes/`:

```markdown
# <Full Paper Title>

**Authors:** <full author list>
**Year:** <year>
**Journal:** <journal name>
**DOI:** <doi>
**Citations:** <count>

## Summary
<2-3 paragraph summary>

## Key Findings
- <finding 1>
- <finding 2>
- <finding 3>

## Methods
<brief methods description>

## Relevance to Review
<how this connects to the research question>

## Limitations
<noted limitations>

## Key Quotes
> "<quote 1>"
> "<quote 2>"
```

### Create bibliography.md

A complete bibliography in a consistent citation format (APA by default):

```markdown
# Bibliography

1. Author, A. B., & Author, C. D. (Year). Title. *Journal*, volume(issue), pages. https://doi.org/xxx
2. ...
```

### Create summary.md

A narrative literature review document:

```markdown
# Literature Review: <Topic>

**Date:** <today>
**Papers reviewed:** N

## Overview
<1-2 paragraph overview of the field>

## Themes
### <Theme 1>
<discussion with citations>

### <Theme 2>
<discussion with citations>

## Gaps in the Literature
<what's missing, what needs more research>

## Conclusions
<synthesis of findings>

## Bibliography
<reference to bibliography.md>
```

---

## Phase 5: Create Presentation

Use the `/pptx` skill to create a literature review presentation.

The presentation should follow this structure:

1. **Title slide** — Topic, your name (ask user), date
2. **Research Question** — What this review investigates
3. **Search Methodology** — Where you searched, how many papers found/selected
4. **Timeline / Field Overview** — How the field has evolved
5. **Theme slides** (2-4 slides per theme) — Key findings organized by theme, with citations
6. **Comparison / Debate** — Where papers agree/disagree
7. **Gaps & Future Directions** — What's missing in the literature
8. **Conclusions** — Key takeaways
9. **Bibliography** — Full reference list (can be multiple slides)

Save to `presentation/lit-review-<topic-slug>.pptx`.

---

## Phase 6: Polish with Napkin AI

Use Chrome to polish the presentation slides:

1. Open a new Chrome tab
2. Navigate to `https://app.napkin.ai/page/create`
3. For each key content slide (skip title and bibliography):
   - Paste the slide's text content into Napkin AI
   - Let Napkin generate visual representations (diagrams, infographics)
   - Take a screenshot of the generated visual
   - Save the visual to `presentation/napkin-visuals/`
4. Report to the user which slides have Napkin visuals available, so they can manually insert their favorites into the PPTX.

**Note:** Napkin AI generates visuals from text — it works best for conceptual content, comparisons, timelines, and process flows. Not every slide will benefit.

---

## Final Report

```
Literature Review Complete
═══════════════════════════════════════════
Topic:           <topic>
Papers found:    N (searched)
Papers reviewed: N (selected)
Papers downloaded: N (open access)

Created:
  ~/lit-reviews/<topic-slug>/
  ├── papers/          N PDFs
  ├── notes/           N markdown summaries
  ├── presentation/    1 PPTX + N Napkin visuals
  ├── summary.md       Narrative review
  └── bibliography.md  Full reference list

Presentation:    <path to pptx>
═══════════════════════════════════════════
```

---

## Rules

1. **Only download open-access papers.** Never bypass paywalls, use sci-hub, or access papers illegally.
2. **Ask before every download.** Each PDF download needs explicit user permission.
3. **Cite everything.** Every claim in the summary and presentation must reference a specific paper.
4. **Be honest about access.** If you can only read an abstract, say so — don't pretend you read the full paper.
5. **PubMed attribution.** When using PubMed data, always cite PubMed and include DOIs as required by the MCP tool.
6. **Respect copyright.** Never reproduce large portions of papers. Summarize in your own words, use short quotes only.
7. **Let the user steer.** Present paper lists and theme choices for approval — don't assume what's relevant.
8. **Save as you go.** Don't wait until the end to create files. Build the folder structure early and populate incrementally.
