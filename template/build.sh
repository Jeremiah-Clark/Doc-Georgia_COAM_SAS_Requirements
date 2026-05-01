#!/bin/bash
# ─────────────────────────────────────────────────────────────
# SimpleDoc v1.1.2 — Build Script
# Converts Markdown files into a styled PDF via Pandoc + XeLaTeX.
# Run from template folder:  ./build.sh
# ─────────────────────────────────────────────────────────────

set -euo pipefail

# ── Configuration ────────────────────────────────────────────

# EDIT BELOW TO MATCH YOUR PROJECT:

OUTPUT="../Georgia_COAM_SAS_Requirements-Latest.pdf"

# List your Markdown content files below, in reading order.
# Use relative paths from this script's directory.
INPUT_FILES=(
  ../content/00-Frontmatter.md
  ../content/01-SAS_Requirements.md
  ../content/02-Source_Documents.md
  # Add more files here, one per line
)

# DO NOT EDIT BELOW THIS LINE  ──────────────────────────────────

# ── Help ─────────────────────────────────────────────────────
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
Simple Doc — Build Script

Usage:  ./build.sh [--help]

This script converts Markdown files into a professionally styled PDF
using Pandoc and XeLaTeX. Before running:

  1. Install Pandoc 3.0+     → https://pandoc.org/installing.html
  2. Install a TeX distro    → TeX Live (Linux/macOS) or MiKTeX (Windows)
  3. Install the required fonts (see README for details)
  4. Edit the INPUT_FILES list at the top of this script to point
     to your Markdown content files
  5. Edit master.yaml with your document metadata

Then run:  ./build.sh

The output PDF will be saved as: output.pdf
EOF
  exit 0
fi

# ── Pre-flight checks ───────────────────────────────────────

errors=0

# Check Pandoc
if ! command -v pandoc &>/dev/null; then
  echo "ERROR: pandoc is not installed."
  echo "       Install it from https://pandoc.org/installing.html"
  errors=1
else
  pandoc_version=$(pandoc --version | head -1 | sed 's/[^0-9.]//g' | cut -d. -f1,2)
  echo "  Found pandoc $pandoc_version"
fi

# Check XeLaTeX
if ! command -v xelatex &>/dev/null; then
  echo "ERROR: xelatex is not installed."
  echo "       Install TeX Live: sudo apt install texlive-xetex (Ubuntu)"
  echo "       or: brew install --cask mactex (macOS)"
  errors=1
else
  echo "  Found xelatex"
fi

# Check required template files
for f in master.yaml template.tex gfm-to-latex.lua; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: Required template file not found: $f"
    echo "       Make sure you're running this script from the project root."
    errors=1
  fi
done

# Check input files
if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
  echo "ERROR: No input files listed."
  echo "       Edit the INPUT_FILES array at the top of build.sh."
  errors=1
else
  for f in "${INPUT_FILES[@]}"; do
    if [[ ! -f "$f" ]]; then
      echo "ERROR: Input file not found: $f"
      echo "       Check the filename and path in the INPUT_FILES list."
      errors=1
    fi
  done
fi

# Check fonts (non-fatal — warns instead of blocking)
# The template tries the primary font first, then the fallback. We only
# warn if BOTH are missing for a given slot.
if command -v fc-list &>/dev/null; then
  installed_fonts=$(fc-list 2>/dev/null)

  check_font_pair() {
    local label="$1" primary="$2" fallback="$3"
    if [[ -z "$primary" && -z "$fallback" ]]; then return; fi

    local primary_ok=false fallback_ok=false
    if [[ -n "$primary" ]] && echo "$installed_fonts" | grep -qi "$primary"; then
      primary_ok=true
    fi
    if [[ -n "$fallback" ]] && echo "$installed_fonts" | grep -qi "$fallback"; then
      fallback_ok=true
    fi

    if $primary_ok; then
      return  # preferred font found, all good
    elif $fallback_ok; then
      echo "  NOTE: $label primary font '$primary' not found — fallback '$fallback' will be used."
    else
      echo "WARNING: $label fonts not found (tried '$primary' and '$fallback')."
      echo "         The build may fail. See the README for installation instructions."
    fi
  }

  body_font=$(grep -oP '(?<=font-body:\s").*?(?=")' master.yaml 2>/dev/null | head -1 || true)
  body_fb=$(grep -oP '(?<=font-body-fallback:\s").*?(?=")' master.yaml 2>/dev/null || true)
  mono_font=$(grep -oP '(?<=font-mono:\s").*?(?=")' master.yaml 2>/dev/null | head -1 || true)
  mono_fb=$(grep -oP '(?<=font-mono-fallback:\s").*?(?=")' master.yaml 2>/dev/null || true)

  check_font_pair "Body" "$body_font" "$body_fb"
  check_font_pair "Mono" "$mono_font" "$mono_fb"
fi

if [[ $errors -ne 0 ]]; then
  echo ""
  echo "Build aborted — fix the errors above and try again."
  exit 1
fi

echo ""
echo "Building PDF..."

# ── Build ────────────────────────────────────────────────────
pandoc --from gfm-alerts \
       --metadata-file master.yaml \
       --template template.tex \
       --pdf-engine=xelatex \
       --lua-filter gfm-to-latex.lua \
       "${INPUT_FILES[@]}" \
       -o "$OUTPUT"

echo "Done → $OUTPUT"
