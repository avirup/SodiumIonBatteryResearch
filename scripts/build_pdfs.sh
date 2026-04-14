#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${ROOT_DIR}/Textbook/pdf"
HEADER_FILE="${ROOT_DIR}/scripts/pandoc-print-header.tex"

mkdir -p "${OUTPUT_DIR}"

mapfile -t markdown_files < <(cd "${ROOT_DIR}/Textbook" && rg --files -g '*.md' | sort)

if [[ ${#markdown_files[@]} -eq 0 ]]; then
  echo "No Markdown files found."
  exit 0
fi

for file in "${markdown_files[@]}"; do
  input_path="${ROOT_DIR}/Textbook/${file}"
  output_name="$(basename "${file%.*}").pdf"
  output_path="${OUTPUT_DIR}/${output_name}"

  echo "Building ${file} -> pdf/${output_name}"

  pandoc "${input_path}" \
    --standalone \
    --from markdown+tex_math_dollars \
    --toc \
    --number-sections \
    --pdf-engine=xelatex \
    --include-in-header="${HEADER_FILE}" \
    -V papersize:a4 \
    -V geometry:margin=22mm \
    -V fontsize=11pt \
    -V colorlinks=false \
    -V linkcolor=black \
    -V urlcolor=black \
    -o "${output_path}"
done

echo "PDFs written to ${OUTPUT_DIR}"
