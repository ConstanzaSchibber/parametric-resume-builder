---
name: add-bullet-variant
description: Add a new phrasing variant (or a whole new slot) for a resume bullet, keeping resume_flex.tex, the build scripts, the configurator, and the README in sync.
---

# Add a bullet variant

The user wants a new alternate phrasing for a resume bullet slot (or a new
slot entirely). Bullet slots are `\ifx`-controlled variables in
`resume_flex.tex`; every slot value must be mirrored across up to five files.

## Rules (from CLAUDE.md — non-negotiable)

- Variable and anchor names: **letters only, no digits**.
- Bullet conditionals use `\ifx\VAR\Vvalue\item ...\fi` — never `\ifdefstring`.
- Bullet text lives inside the role-block macros (`\NorthwindBlock` etc.),
  never duplicated in layout branches.
- A `hide` value needs no anchor or condition — it works by matching nothing.

## Steps for a new variant on an existing slot

1. Ask for / confirm: which slot, the new value name (letters/digits, e.g.
   `scaled30x`), and the bullet text. Keep the text one coherent sentence in
   the persona's voice.
2. `resume_flex.tex`:
   - Preamble: `\def\Vnewvalue{newvalue}` (anchor name letters-only).
   - Inside the slot's role-block macro: `\ifx\SLOTVAR\Vnewvalue\item Text.\fi`
     next to the slot's other options.
   - Update the variable table in the header comment.
3. `compile.sh`: add the value to the slot's prompt.
4. `build.sh`: update the header comment; add to variants if requested.
5. `configurator.html` — **two index-aligned spots**:
   - the slot's `opts` array in `JA_SLOT_DEFS`/`JB_SLOT_DEFS`/`MISC_SLOT_DEFS`:
     `{ tag:'short label', text:'Exact bullet text.' }`
   - the same position appended to that slot's `vals` array in `SLOT_LATEX`.
6. `README.md`: update the parameters table.

## Extra steps for a brand-new slot

- Defaults block: `\ifx\SLOTVAR\undefined\def\SLOTVAR{default}\fi`.
- New entry in the configurator's `*_SLOT_DEFS` and `SLOT_LATEX`.
- Add `\def\SLOTVAR{...}` to the `defs` string in `compile.sh` **and** in the
  configurator's `renderCmd()`.

## Verify

Compile a variant that selects the new value and probe the PDF for the new
text (see docs/EXTENDING.md "Verifying a compiled PDF"); also compile the
default configuration to confirm nothing regressed and both stay **1 page**.
Delete test artifacts.
