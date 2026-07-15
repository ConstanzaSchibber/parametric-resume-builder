# How it works & how to extend it

This document explains the machinery inside `resume_flex.tex` and the exact
steps (and traps) for extending it. Everything here was learned the hard way.

## Architecture

### Variable injection

Variables are `\def`-injected on the command line **before** `\input{...}`:

```bash
pdflatex -jobname="Out" "\def\biover{systems}\def\layout{portfolio}\input{resume_flex}"
```

The `.tex` file sets defaults at the top with the pattern

```latex
\ifx\biover\undefined\def\biover{general}\fi
```

so the file also compiles standalone (all defaults apply).

### Value anchors and `\ifx`

All bullet/section conditionals use the TeX primitive `\ifx`:

```latex
\ifx\jaone\Vstreaming\item Redesigned the ingestion service ...\fi
```

`\Vstreaming` is a **value anchor** defined in the preamble
(`\def\Vstreaming{streaming}`). `\ifx` compares the *full meanings* of two
macros: when both expand to the same string, the condition is true.

**Why `\ifx` and not `\ifdefstring` (etoolbox)?**

- `\ifx...\fi` produces **zero tokens** when false — safe inside list
  environments.
- `\ifdefstring{cmd}{val}{true}{}` emits an empty `{}` group in the false
  branch, which breaks bullet lists (spurious blank items / spacing).

**The one exception:** the Bio section uses `\ifdefstring`. Bio text lives in
paragraph mode, where the empty `{}` group is harmless. Don't "fix" it to
`\ifx`, and don't switch bullets to `\ifdefstring`.

### The `hide` value

A slot value of `hide` needs no TeX support at all: it simply matches none of
the `\ifx` conditions, so no bullet is emitted. Any slot can support `hide` by
just documenting it.

### ⚠ No digits in variable names

TeX digits have catcode 12 (not "letter"), so `\jab1` parses as the control
word `\jab` followed by the character `1` — `\def\jab1{x}` silently defines a
*delimited* macro, not a value. **All variable and anchor names must be
letters only.** Values may contain digits (`cut308`, `scaled30x`) — only the
macro *names* are restricted.

### Role-block macros and the layout switch

Each role is defined **once** as a macro in the preamble
(`\NorthwindBlock`, `\LakeshoreBlock`, `\InternBlock`, `\ResearchBlock`,
`\ProjectSection`, `\EducationSection`). The layout switch then assembles
them:

```latex
\ifx\layout\Vresearch
  ...research ordering...
\else\ifx\layout\Vportfolio
  ...portfolio ordering...
\else
  ...threeroles (default)...
\fi\fi
```

Bullet conditionals inside a macro body expand when the macro is *used*, so
`\ifx` slots work normally inside blocks. This means bullet text exists in
exactly one place regardless of how many layouts use it.

**Every role block must end with `\par\smallskip`** (after its Tech Stack
line). Without the `\par`, an adjacent block in the same section continues the
same paragraph and its heading gets typeset mid-line, overlapping the previous
role's Tech Stack text.

The Skills and Certifications sections appear once, **after** the layout
switch — no duplication there either.

### Class file notes (`resume.cls`)

The class is Trey Hunner's original, unmodified. Three things the `.tex`
handles that you might otherwise be tempted to patch into the class:

- **`enumitem` is loaded by `resume_flex.tex`**, not the class. The bullet
  lists rely on it (`[leftmargin=...]` options).
- **No `\href` in the `\name`/`\address` header.** The class typesets the
  header in an `\AtBeginDocument` hook that runs *before* hyperref finishes
  initializing, so link commands there fail with
  `Undefined control sequence \Hy@colorlink`. Header contact info must be
  plain text; `\href` anywhere in the document body is fine.
- **Section spacing is overridden in the `.tex`**
  (`\renewcommand{\sectionskip}{\smallskip}`, default is `\bigskip`) to keep
  every variant on one page. Remove it if you prefer the roomier default.

### Compile twice

Run `pdflatex` twice to resolve hyperlinks/references. `build.sh`,
`compile.sh`, and the configurator command all do this.

## Checklists

### Adding a new bullet variant (a new phrasing for an existing slot)

1. `resume_flex.tex` — add a value anchor in the preamble:
   `\def\Vnewvalue{newvalue}` (anchor name letters-only).
2. `resume_flex.tex` — add `\ifx\SLOTVAR\Vnewvalue\item New text.\fi` inside
   the role-block macro, next to the slot's other options.
3. `resume_flex.tex` — update the variable table in the header comment.
4. `compile.sh` — add the value to the slot's prompt text.
5. `build.sh` — update the comment (and any variant that should use it).
6. `configurator.html` — two spots: add `{ tag:'...', text:'...' }` to the
   slot's `opts` in its `*_SLOT_DEFS` entry, **and** append the value to the
   index-aligned `vals` array in `SLOT_LATEX`. The `opts` index must line up
   with the `vals` index.
7. `README.md` — update the parameters table.

### Adding a new bullet slot (a new toggleable bullet position)

Same as above, plus: default it in the defaults block
(`\ifx\SLOTVAR\undefined\def\SLOTVAR{...}\fi`), add a full `SLOT_DEFS` entry
and a `SLOT_LATEX` entry in the configurator, and add the `\def` to the
`defs` strings in `compile.sh` and `renderCmd()`.

### Adding a new skill group (show/hide toggle)

1. `resume_flex.tex` — header comment; default
   (`\ifx\showNAME\undefined\def\showNAME{true}\fi`); and in the Skills
   section a block:

   ```latex
   \ifx\showNAME\Vtrue
   \textbf{Group Name}: Thing; Thing; Thing\vspace{-0.05in}

   \fi
   ```

   (The blank line before `\fi` matters; the last group in the section omits
   the `\vspace`.)
2. `compile.sh` — an `ask` prompt + `\def\showNAME{${showNAME}}` in `defs`.
3. `configurator.html` — four spots: a toggle-row in the Skills HTML
   (ids `sk-KEY-show` / `sk-KEY-hide`), the default in the `S` state object,
   a `parts.push(...)` line in `skillsSection()`, the `\def` in `renderCmd()`,
   and `KEY` added to the `['sys','web','comm','prog']` sync array in
   `render()` (KEY must match the HTML ids).
4. `README.md` — parameters table.

### Adding a new layout

1. `resume_flex.tex` — anchor (`\def\Vnewlayout{newlayout}`), a new branch in
   the `\ifx\layout...` chain assembling the role-block macros in the order
   you want.
2. `configurator.html` — a layout button (`id="lay-newlayout"`), a branch in
   `renderDoc()`, and the button id added to the layout array in `render()`.
3. `build.sh` / `compile.sh` / `README.md` — mention the new value.

## Keeping the configurator in sync

The configurator duplicates the bullet text in JavaScript — this is the one
place content exists twice. It's a deliberate trade-off (the page stays a
dependency-free single file), but it means: **any text change in
`resume_flex.tex` must be mirrored in `configurator.html`**, and vice versa.
The checklists above call out every sync point. A future improvement would be
generating the JS data block from the `.tex` — PRs welcome.

## Verifying a compiled PDF without extra tools

**Always look at the rendered page, not just the extracted text.** Text probes
can't see layout bugs (a stray `\vspace` opening a huge gap, two role blocks
running together as one paragraph). On macOS, rasterize page 1 with the
built-in `sips` and inspect the image:

```bash
sips -s format png --resampleWidth 900 Out.pdf --out preview.png
```

If `pdftotext` isn't installed, this stdlib-only Python snippet checks that
expected text made it into the PDF:

```bash
python3 -c "
import zlib, re
d=open('TEST.pdf','rb').read()
out=b''
for m in re.finditer(rb'stream\r?\n(.*?)endstream', d, re.S):
    try: out+=zlib.decompress(m.group(1))
    except: pass
t=b''.join(re.findall(rb'\((.*?)\)', out)).replace(b' ',b'')
print(b'PROBEWITHOUTSPACES' in t)
"
```

Probes are the expected text **with all spaces removed** and must contain no
parentheses (the literal-extraction regex breaks on them). Note the name
header renders in uppercase.
