---
name: add-skill-group
description: Add a new show/hide skill group to the resume's Skills section, keeping resume_flex.tex, compile.sh, the configurator, and the README in sync.
---

# Add a skill group

The user wants a new toggleable group (e.g. "Security") in the Skills &
Expertise section. The Skills section appears once, after the layout switch —
no duplication.

## Rules

- Toggle name: `\showNAME`, letters only.
- Uses the `\ifx\showNAME\Vtrue ... \fi` pattern; `\Vtrue` already exists.
- The blank line before the closing `\fi` is required (it ends the paragraph);
  the **last** group in the section omits the `\vspace{-0.05in}`.

## Steps

1. Confirm: group title, the semicolon-separated skill list, default
   visibility (true/false), and position among the existing groups.
2. `resume_flex.tex`:
   - Header comment: add to the visibility list.
   - Defaults block: `\ifx\showNAME\undefined\def\showNAME{true}\fi`.
   - Skills section, in position:

     ```latex
     \ifx\showNAME\Vtrue
     \textbf{Group Title}: Skill; Skill; Skill\vspace{-0.05in}

     \fi
     ```

   - If inserting as the new last group, move the `\vspace` handling
     accordingly.
3. `compile.sh`: an `ask` prompt and `\def\showNAME{${showNAME}}` in `defs`.
4. `configurator.html` — five spots:
   - toggle-row HTML with ids `sk-KEY-show` / `sk-KEY-hide`;
   - `showKEY` default in the `S` state object;
   - a `parts.push(...)` line in `skillsSection()` in the right position;
   - `\def\showNAME{...}` in `renderCmd()`;
   - `KEY` added to the `['sys','web','comm','prog']` array in `render()`
     (KEY must match the HTML ids).
5. `README.md`: parameters table.

## Verify

Compile once with the group shown and once hidden; probe the PDF for the group
title in each case, confirm 1 page, delete test artifacts.
