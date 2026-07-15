#!/bin/bash
# Build named resume variants from resume_flex.tex
#
# Usage:
#   ./build.sh              — compile all variants
#   ./build.sh systems      — compile one variant by name
#
# Variants (each is a full configuration; see the variable table in resume_flex.tex):
#   general   — general bio, three roles (both jobs + internship)
#   systems   — systems-emphasis bio and bullets, portfolio layout
#   product   — product-emphasis bio and bullets, portfolio layout
#   research  — general bio, research layout (industry + project + research experience)

set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

compile() {
    local name="$1"
    local defs="$2"
    echo "Building ${name}.pdf ..."
    pdflatex -interaction=nonstopmode -jobname="$name" "${defs}\input{resume_flex}" > /dev/null
    pdflatex -interaction=nonstopmode -jobname="$name" "${defs}\input{resume_flex}" > /dev/null
    rm -f "${name}.aux" "${name}.log" "${name}.out"
    echo "  done → ${name}.pdf"
}

DEFS_GENERAL='\def\biover{general}\def\layout{threeroles}\def\teamlabel{Platform}\def\jaone{streaming}\def\jatwo{latency}\def\jathree{hide}\def\jbone{fullstack}\def\jbtwo{migration}\def\inone{logsearch}\def\sline{gofirst}'
DEFS_SYSTEMS='\def\biover{systems}\def\layout{portfolio}\def\teamlabel{Platform}\def\jaone{streaming}\def\jatwo{reliability}\def\jathree{tooling}\def\jbone{metering}\def\jbtwo{migration}\def\projfocus{systems}\def\sline{gofirst}\def\showcomm{false}'
DEFS_PRODUCT='\def\biover{product}\def\layout{portfolio}\def\teamlabel{Growth}\def\jaone{dashboards}\def\jatwo{latency}\def\jathree{mentoring}\def\jbone{fullstack}\def\jbtwo{testing}\def\projfocus{product}\def\sline{tsfirst}\def\showcomm{true}\def\showoncall{false}'
DEFS_RESEARCH='\def\biover{general}\def\layout{research}\def\teamlabel{Platform}\def\jaone{streaming}\def\jatwo{latency}\def\jbone{metering}\def\jbtwo{migration}\def\rone{paper}\def\projfocus{systems}\def\sline{gofirst}'

build_all() {
    compile "Rivera_general"  "$DEFS_GENERAL"
    compile "Rivera_systems"  "$DEFS_SYSTEMS"
    compile "Rivera_product"  "$DEFS_PRODUCT"
    compile "Rivera_research" "$DEFS_RESEARCH"
}

case "${1:-all}" in
    all)       build_all ;;
    general)   compile "Rivera_general"  "$DEFS_GENERAL" ;;
    systems)   compile "Rivera_systems"  "$DEFS_SYSTEMS" ;;
    product)   compile "Rivera_product"  "$DEFS_PRODUCT" ;;
    research)  compile "Rivera_research" "$DEFS_RESEARCH" ;;
    *)         echo "Unknown variant: $1. Options: all general systems product research" && exit 1 ;;
esac
