# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A parametric LaTeX resume: one `.tex` file (`resume_flex.tex`) that produces
different PDFs based on variables injected at compile time. Ships with a
fictional example persona (Alex Rivera, software engineer). Full architecture
and extension checklists live in `docs/EXTENDING.md` — read it before making
structural changes.

## Building

```bash
./build.sh                 # all 4 named variants: general systems product research
./build.sh systems         # one variant
./compile.sh               # interactive, prompts for every option; logs to applications.log
open configurator.html     # web UI: live preview + compile-command generator

# Ad hoc:
pdflatex -interaction=nonstopmode -jobname="Out" "\def\biover{systems}\def\layout{portfolio}\input{resume_flex}"
```

`pdflatex` must run **twice** to resolve references (the scripts do this).
Clean up `.aux/.log/.out` after building. Every variant must stay a
**one-page PDF** — check the "Output written on … (1 page" line.

## Files

- `resume_flex.tex` — the entire resume; all content, variables, and layout logic
- `resume.cls` — Trey Hunner's resume class; **do not modify**
- `build.sh` / `compile.sh` — named-variant and interactive builders
- `configurator.html` — single-file web UI; duplicates bullet text in JS and must stay in sync with the `.tex`

## Critical TeX rules (violating these breaks the document silently)

1. **Bullet conditionals use the `\ifx` + value-anchor pattern**
   (`\ifx\jaone\Vstreaming\item ...\fi`). Never switch them to
   `\ifdefstring` — its false branch emits an empty `{}` group that breaks
   list environments. `\ifx` emits zero tokens when false.
2. **The Bio section is the one exception**: it intentionally uses
   `\ifdefstring` (paragraph mode tolerates the `{}`). Do not convert it.
3. **No digits in variable or anchor names** — TeX parses `\def\jab1{x}` as a
   delimited macro, not a value. Letters only for names; values may contain
   digits.
4. Role content is defined once in role-block macros (`\NorthwindBlock` etc.);
   the `\ifx\layout` chain assembles them. Add content inside the macros, not
   inside the layout branches.
5. A slot value of `hide` needs no TeX support — it just matches no `\ifx`.
6. **No `\href` inside `\name`/`\address`** — the class prints the header
   before hyperref initializes (`\AtBeginDocument` ordering) and the build
   errors. Header contact info stays plain text; `\href` in the body is fine.
7. `resume.cls` is Trey Hunner's original, unmodified — `enumitem` and the
   `\sectionskip` override live in `resume_flex.tex`, not the class.
8. **If a variant runs to two pages**, don't force breaks with `\newpage` —
   use `\needspace{N\baselineskip}` before a role header so it only breaks
   when the header would otherwise strand alone with its bullets pushed to
   the next page. See "Avoiding orphaned role headers" in `docs/EXTENDING.md`.

## Multi-file sync

Any change to variables or bullet text touches up to five files:
`resume_flex.tex` (content + header comment table), `compile.sh`, `build.sh`,
`configurator.html` (both the `*_SLOT_DEFS` opts **and** the index-aligned
`SLOT_LATEX` vals), and the `README.md` parameters table. Use the checklists in
`docs/EXTENDING.md` — or the `/add-bullet-variant` and `/add-skill-group`
skills, which encode them.

## Verifying a compiled PDF

**Always inspect the rendered page visually** — text probes miss layout bugs
(stray vertical space, paragraphs running together). On macOS:
`sips -s format png --resampleWidth 900 Out.pdf --out preview.png`, then look
at the image.

For text checks, prefer `pdftotext` if installed. Otherwise use the
stdlib-only probe snippet in `docs/EXTENDING.md` ("Verifying a compiled PDF
without extra tools"): probes are expected text with spaces removed and no
parentheses; the name header renders uppercase. Delete test artifacts
afterwards.
