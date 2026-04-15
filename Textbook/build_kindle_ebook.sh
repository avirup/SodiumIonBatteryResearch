#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$ROOT_DIR/kindle"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/math"

CHAPTERS=(
  "$ROOT_DIR/battery_textbook_chapter1_edited.md"
  "$ROOT_DIR/battery_textbook_chapter2_revised.md"
  "$ROOT_DIR/battery_textbook_chapter3_revised.md"
  "$ROOT_DIR/battery_textbook_chapter4_revised.md"
  "$ROOT_DIR/battery_textbook_chapter5_revised.md"
  "$ROOT_DIR/battery_textbook_chapter6_revised.md"
  "$ROOT_DIR/battery_textbook_chapter7_edited.md"
)

TITLE="Battery Technology for Electrical Engineers"
SUBTITLE="Chapters 1-7"
EPUB_OUT="$OUTPUT_DIR/battery_technology_chapters_1_7_kindle.epub"
HTML_OUT="$OUTPUT_DIR/battery_technology_chapters_1_7_kindle.html"
MOBI_OUT="$OUTPUT_DIR/battery_technology_chapters_1_7_kindle.mobi"

cd "$ROOT_DIR"
export KINDLE_BUILD_ROOT="$ROOT_DIR"

pandoc \
  "${CHAPTERS[@]}" \
  --from markdown+smart+tex_math_dollars \
  --to epub2 \
  --metadata-file "$ROOT_DIR/kindle-metadata.yaml" \
  --css "kindle.css" \
  --lua-filter "$ROOT_DIR/math_to_png.lua" \
  --resource-path "$ROOT_DIR" \
  --toc \
  --toc-depth=2 \
  --split-level=1 \
  --epub-cover-image "$ROOT_DIR/Book_Cover.png" \
  --output "$EPUB_OUT"

pandoc \
  "${CHAPTERS[@]}" \
  --from markdown+smart+tex_math_dollars \
  --metadata title="$TITLE" \
  --metadata subtitle="$SUBTITLE" \
  --css "kindle.css" \
  --lua-filter "$ROOT_DIR/math_to_png.lua" \
  --resource-path "$ROOT_DIR" \
  --toc \
  --toc-depth=2 \
  --embed-resources \
  --standalone \
  --output "$HTML_OUT"

if command -v ebook-convert >/dev/null 2>&1; then
  ebook-convert "$EPUB_OUT" "$MOBI_OUT" \
    --chapter "//*[(name()='h1' or name()='h2')]" \
    --level1-toc "//*[@id='TOC']//a" \
    --mobi-file-type old \
    --margin-top 20 \
    --margin-bottom 20 \
    --margin-left 20 \
    --margin-right 20
elif command -v kindlegen >/dev/null 2>&1; then
  kindlegen "$EPUB_OUT" -o "$(basename "$MOBI_OUT")"
fi

printf 'Built:\n%s\n%s\n' "$EPUB_OUT" "$HTML_OUT"
if [[ -f "$MOBI_OUT" ]]; then
  printf '%s\n' "$MOBI_OUT"
fi
