#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPANION_DIR="${ROOT_DIR}/SimulationCompanion"
HEADER_FILE="${ROOT_DIR}/scripts/pandoc-print-header.tex"
OUTPUT_MD="${COMPANION_DIR}/simulation_companion_combined.md"
OUTPUT_PDF="${COMPANION_DIR}/pdf/simulation_companion_combined.pdf"
TMP_PDF="${COMPANION_DIR}/pdf/simulation_companion_combined.tmp.pdf"
COVER_IMAGE="${COMPANION_DIR}/Simulation_Cover.png"

COPYRIGHT_YEAR="${COPYRIGHT_YEAR:-2026}"
COPYRIGHT_HOLDER="${COPYRIGHT_HOLDER:-Avirup}"
LICENSE_URL="${LICENSE_URL:-https://creativecommons.org/licenses/by-nc/4.0/}"
PUBLISHER_NAME="${PUBLISHER_NAME:-Independent publication}"
PUBLISHER_INFO="${PUBLISHER_INFO:-Published as part of the SodiumIonBatteryResearch project.}"

chapters=(
  "lab-chapter-1-the-research-computing-environment.md"
  "lab-chapter-2-scientific-python-refresher-for-battery-work.md"
  "lab-chapter-3-your-first-pybamm-simulation.md"
  "lab-chapter-4-parameters-experiments-and-drive-cycles.md"
)

mkdir -p "${COMPANION_DIR}/pdf"

if [[ ! -f "${COVER_IMAGE}" ]]; then
  echo "Missing cover image: ${COVER_IMAGE}" >&2
  exit 1
fi

clean_chapter() {
  local input_file="$1"

  perl -0pe '
    s/\A# Lab Chapter \d+:\s+/# /;
    s/^(#+)\s+Step\s+\d+:\s+/$1 /mg;
  ' "${input_file}"
}

{
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
License text: \url{${LICENSE_URL}}\\

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
    chapter_path="${COMPANION_DIR}/${chapters[$i]}"

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

page_count="$(pdfinfo "${TMP_PDF}" | awk '/^Pages:/ {print $2}')"
if [[ -z "${page_count}" || "${page_count}" -lt 2 ]]; then
  echo "Unexpected PDF page count: ${page_count:-unknown}" >&2
  exit 1
fi

gs -q \
  -dNOPAUSE \
  -dBATCH \
  -sDEVICE=pdfwrite \
  -dCompatibilityLevel=1.5 \
  -dFirstPage=2 \
  -sOutputFile="${OUTPUT_PDF}" \
  "${TMP_PDF}"

rm -f "${TMP_PDF}"

echo "Wrote ${OUTPUT_MD}"
echo "Wrote ${OUTPUT_PDF}"
