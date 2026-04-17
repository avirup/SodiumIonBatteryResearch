#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEXTBOOK_DIR="${ROOT_DIR}/Textbook"
HEADER_FILE="${ROOT_DIR}/scripts/pandoc-print-header.tex"
OUTPUT_MD="${TEXTBOOK_DIR}/battery_textbook_combined.md"
OUTPUT_PDF="${TEXTBOOK_DIR}/pdf/battery_textbook_combined.pdf"
TMP_PDF="${TEXTBOOK_DIR}/pdf/battery_textbook_combined.tmp.pdf"
COVER_IMAGE="${TEXTBOOK_DIR}/Book_Cover.png"

COPYRIGHT_YEAR="${COPYRIGHT_YEAR:-2026}"
COPYRIGHT_HOLDER="${COPYRIGHT_HOLDER:-Avirup}"
ISBN_13="${ISBN_13:-TBD}"
LCCN="${LCCN:-TBD}"
PUBLISHER_NAME="${PUBLISHER_NAME:-Independent publication}"
PUBLISHER_INFO="${PUBLISHER_INFO:-Publisher details to be confirmed.}"

chapters=(
  "battery_textbook_chapter1_edited.md"
  "battery_textbook_chapter2_revised.md"
  "battery_textbook_chapter3_revised.md"
  "battery_textbook_chapter4_revised.md"
  "battery_textbook_chapter5_revised.md"
  "battery_textbook_chapter6_revised.md"
  "battery_textbook_chapter7_edited.md"
  "battery_textbook_chapter8_reviewed.md"
  "battery_textbook_chapter9_reviewed.md"
)

mkdir -p "${TEXTBOOK_DIR}/pdf"

if [[ ! -f "${COVER_IMAGE}" ]]; then
  echo "Missing cover image: ${COVER_IMAGE}" >&2
  exit 1
fi

clean_chapter() {
  local input_file="$1"

  perl -0pe '
    s/\A# Battery Technology for Electrical Engineers: A Self-Study Text\s*\n---\s*\n//s;
    s/\A## Chapter 1:/# Chapter 1:/;
    s/^(#+)\s+Chapter\s+\d+:\s+/$1 /mg;
    s/^(#+)\s+\d+(?:\.\d+)*\s+/$1 /mg;
    s/\n*---\n\n\*Next chapter:.*?Prompt me with "write Chapter \d+" to continue\.\*\s*\z/\n/s;
  ' "${input_file}"
}

{
  printf -- "---\n"
  printf 'title: "Battery Technology for Electrical Engineers: A Self-Study Text"\n'
  printf 'documentclass: book\n'
  printf -- "---\n\n"

  cat <<EOF
\pagenumbering{gobble}
\newgeometry{margin=0pt}
\thispagestyle{empty}
\noindent
\includegraphics[width=\paperwidth,height=\paperheight]{${COVER_IMAGE}}
\clearpage
\restoregeometry

\pagestyle{empty}
\thispagestyle{empty}
\vspace*{\fill}
\noindent\textbf{Copyright \textcopyright{} ${COPYRIGHT_YEAR} ${COPYRIGHT_HOLDER}}\\
This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0).\\
You are free to share and adapt this material for noncommercial purposes, provided you give appropriate attribution and indicate if changes were made.\\
License text: \url{https://creativecommons.org/licenses/by-nc/4.0/}\\

\vspace{1.5em}
\noindent\textbf{ISBN:} ${ISBN_13}\\
\textbf{Library of Congress Control Number:} ${LCCN}\\

\vspace{1.5em}
\noindent\textbf{Publisher:} ${PUBLISHER_NAME}\\
${PUBLISHER_INFO}
\vspace*{\fill}
\clearpage

\pagestyle{empty}
\tableofcontents
\clearpage
\pagenumbering{arabic}
\setcounter{page}{1}
\pagestyle{fancy}

EOF

  for i in "${!chapters[@]}"; do
    chapter_path="${TEXTBOOK_DIR}/${chapters[$i]}"

    if [[ ! -f "${chapter_path}" ]]; then
      echo "Missing chapter file: ${chapters[$i]}" >&2
      exit 1
    fi

    if (( i > 0 )); then
      printf '\n\\newpage\n\n'
    fi

    clean_chapter "${chapter_path}"
    printf '\n'
  done
} > "${OUTPUT_MD}"

pandoc "${OUTPUT_MD}" \
  --standalone \
  --from markdown+tex_math_dollars \
  --number-sections \
  --pdf-engine=xelatex \
  --include-in-header="${HEADER_FILE}" \
  -V documentclass:book \
  -V classoption:openany \
  -V classoption:twoside \
  -V papersize:a4 \
  -V geometry:margin=22mm \
  -V fontsize=11pt \
  -V colorlinks=false \
  -V linkcolor=black \
  -V urlcolor=black \
  -o "${TMP_PDF}"

mv "${TMP_PDF}" "${OUTPUT_PDF}"

echo "Wrote ${OUTPUT_MD}"
echo "Wrote ${OUTPUT_PDF}"
