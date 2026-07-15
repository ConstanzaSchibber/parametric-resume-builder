#!/bin/bash
# Interactive compile — prompts for each option, then builds the PDF.
# Press Enter to accept the shown default.
# Appends "date<TAB>jobname<TAB>defs" to applications.log so you keep a record
# of which configuration was sent where.

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

ask() { echo -n "$1 [$2]: "; read -r v; echo "${v:-$2}"; }

echo ""
layout=$(ask   "Layout        (threeroles / research / portfolio)"          "threeroles")
biover=$(ask   "Bio           (general / systems / product)"               "general")
team=$(ask     "Team label    (free text)"                                  "Platform")
cert=$(ask     "Show cert     (true / false)"                               "false")
echo ""
jaone=$(ask    "Job A 1st bullet   streaming | dashboards | leadership"     "streaming")
jatwo=$(ask    "Job A 2nd bullet   latency | reliability"                   "latency")
jathree=$(ask  "Job A 3rd bullet   mentoring | tooling | hide"              "hide")
echo ""
jbone=$(ask    "Job B 1st bullet   fullstack | metering"                    "fullstack")
jbtwo=$(ask    "Job B 2nd bullet   migration | testing"                     "migration")
echo ""
inone=$(ask    "Internship bullet  logsearch | releasenotes"                "logsearch")
rone=$(ask     "Research bullet    harness | paper"                         "harness")
projfocus=$(ask "Project focus     systems | product"                       "systems")
echo ""
sline=$(ask    "Languages line     gofirst | tsfirst"                       "gofirst")
showsys=$(ask  "Show Systems & Infrastructure  (true / false)"              "true")
showweb=$(ask  "Show Product & Web             (true / false)"              "true")
showcomm=$(ask "Show Collaboration             (true / false)"              "false")
showprog=$(ask "Show Languages                 (true / false)"              "true")
showoncall=$(ask "Include On-Call in Systems line (true / false)"           "true")
echo ""
outname=$(ask "Output filename (no .pdf)"                                   "Rivera_resume")
[ -z "$outname" ] && echo "No filename entered." && exit 1

defs="\def\biover{${biover}}\def\layout{${layout}}\def\teamlabel{${team}}\def\showcert{${cert}}\def\jaone{${jaone}}\def\jatwo{${jatwo}}\def\jathree{${jathree}}\def\jbone{${jbone}}\def\jbtwo{${jbtwo}}\def\inone{${inone}}\def\rone{${rone}}\def\projfocus{${projfocus}}\def\sline{${sline}}\def\showsys{${showsys}}\def\showweb{${showweb}}\def\showcomm{${showcomm}}\def\showprog{${showprog}}\def\showoncall{${showoncall}}"

printf '%s\t%s\t%s\n' "$(date +%F)" "$outname" "$defs" >> applications.log

echo ""
echo "Building ${outname}.pdf ..."
pdflatex -interaction=nonstopmode -jobname="$outname" "${defs}\input{resume_flex}" > /dev/null
pdflatex -interaction=nonstopmode -jobname="$outname" "${defs}\input{resume_flex}" > /dev/null
rm -f "${outname}.aux" "${outname}.log" "${outname}.out"
echo "Done → ${outname}.pdf"
