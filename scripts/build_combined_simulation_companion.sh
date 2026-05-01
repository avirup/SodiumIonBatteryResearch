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
COPYRIGHT_HOLDER="${COPYRIGHT_HOLDER:-Avirup Kundu}"
PUBLISH_MONTH_YEAR="${PUBLISH_MONTH_YEAR:-May 2026}"
PUBLISHER_INFO="${PUBLISHER_INFO:-Self Published by Avirup Kundu}"
AUTHOR_NAME="${AUTHOR_NAME:-Avirup Kundu}"
WEBSITE_URL="${WEBSITE_URL:-https://www.avirup.net/}"
COVER_DESIGN_CREDIT="${COVER_DESIGN_CREDIT:-AI-generated artwork}"
TEXTBOOK_VOLUME="${TEXTBOOK_VOLUME:-Battery Technology for Electrical Engineers: A Self-Study Text}"
PDF_TITLE="${PDF_TITLE:-Battery Simulation and Research Tools: A Hands-On Companion}"

chapters=(
  "lab-chapter-1-the-research-computing-environment.md"
  "lab-chapter-2-scientific-python-refresher-for-battery-work.md"
  "lab-chapter-3-your-first-pybamm-simulation.md"
  "lab-chapter-4-parameters-experiments-and-drive-cycles.md"
  "lab-chapter-5-parameter-estimation-in-pybamm.md"
  "lab-chapter-6-equivalent-circuit-models-from-scratch.md"
  "lab-chapter-7-soc-estimation-with-kalman-filters.md"
  "lab-chapter-8-soh-and-aging-models.md"
  "lab-chapter-9-thermal-modeling-and-electrothermal-coupling.md"
  "lab-chapter-10-bridging-pybamm-and-matlab.md"
  "lab-chapter-11-public-battery-datasets-in-depth.md"
  "lab-chapter-12-the-reproduction-project.md"
  "lab-chapter-13-specialization-tracks.md"
  "lab-chapter-14-the-capstone-project.md"
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

format_chapter() {
  local input_file="$1"

  clean_chapter "${input_file}" | perl -ne '
    BEGIN {
      $mode = "body";
      $in_fence = 0;
    }

    sub tex_escape {
      my ($text) = @_;

      $text =~ s/\\/\\textbackslash{}/g;
      $text =~ s/([%&#_\$\{\}])/\\$1/g;
      $text =~ s/\^/\\textasciicircum{}/g;
      $text =~ s/~/\\textasciitilde{}/g;

      return $text;
    }

    sub normalize_heading_part {
      my ($text) = @_;

      $text = tex_escape($text);
      $text =~ s/⁺/\\textsuperscript{+}/g;
      $text =~ s/⁻/\\textsuperscript{-}/g;
      $text =~ s/₀/\\textsubscript{0}/g;
      $text =~ s/₁/\\textsubscript{1}/g;
      $text =~ s/₂/\\textsubscript{2}/g;
      $text =~ s/₃/\\textsubscript{3}/g;
      $text =~ s/₄/\\textsubscript{4}/g;
      $text =~ s/₅/\\textsubscript{5}/g;
      $text =~ s/₆/\\textsubscript{6}/g;
      $text =~ s/₇/\\textsubscript{7}/g;
      $text =~ s/₈/\\textsubscript{8}/g;
      $text =~ s/₉/\\textsubscript{9}/g;

      return $text;
    }

    sub normalize_heading_text {
      my ($text) = @_;
      my @parts = split(/(`[^`]*`)/, $text);
      my $out = "";

      for my $part (@parts) {
        if ($part =~ /^`([^`]*)`$/) {
          $out .= "\\texttt{" . tex_escape($1) . "}";
        } else {
          $out .= normalize_heading_part($part);
        }
      }

      return $out;
    }

    sub reset_body_style {
      if ($mode ne "body") {
        print "\\bodytextstyle\n\n";
        $mode = "body";
      }
    }

    if (/^```/) {
      print;
      $in_fence = !$in_fence;
      next;
    }

    if ($in_fence) {
      print;
      next;
    }

    if (/^# (.+?)\s*$/) {
      reset_body_style();
      my $title = normalize_heading_text($1);
      print "\\chapter{$title}\n\n";
      next;
    }

    if (/^## (.+?)\s*$/) {
      my $title = normalize_heading_text($1);

      if ($title eq "Chapter Opening") {
        reset_body_style();
        print "\\chapteropeningstyle\n\n";
        $mode = "opening";
        next;
      }

      reset_body_style();

      if ($title =~ /^What Changes for /) {
        print "\\specialsectionplain{$title}\n\n";
        print "\\specialsectionstyle\n\n";
        $mode = "special";
        next;
      }

      if ($title =~ /^(Guided Walkthrough \d+|Reproduction Exercise|Dataset Integration):\s*(.+)$/) {
        my $label = normalize_heading_text($1);
        my $subtitle = normalize_heading_text($2);
        print "\\specialsectionwithsubtitle{$label}{$subtitle}\n\n";
        print "\\specialsectionstyle\n\n";
        $mode = "special";
        next;
      }

      if ($title =~ /^(Chapter Summary|Chapter Summary and Skill Checklist|Deliverable|Further Practice and Reading|Further Reading)/) {
        if ($mode ne "chapterend") {
          print "\\chapterendstyle\n\n";
          $mode = "chapterend";
        }
        print "\\chapterendsection{$title}\n\n";
        next;
      }

      print "\\section{$title}\n\n";
      next;
    }

    if (/^### (.+?)\s*$/) {
      reset_body_style();
      my $title = normalize_heading_text($1);
      print "\\subsection{$title}\n\n";
      next;
    }

    if (/^#### (.+?)\s*$/) {
      reset_body_style();
      my $title = normalize_heading_text($1);
      print "\\subsubsection{$title}\n\n";
      next;
    }

    print;

    END {
      reset_body_style();
    }
  '
}

{
  cat <<EOF
\hypersetup{
  pdfauthor={${AUTHOR_NAME}},
  pdftitle={${PDF_TITLE}}
}
\pagenumbering{gobble}
\thispagestyle{empty}
\AddToShipoutPictureBG*{%
  \AtPageLowerLeft{%
    \includegraphics[width=\paperwidth,height=\paperheight]{${COVER_IMAGE}}%
  }%
}
\mbox{}
\ClearShipoutPictureBG
\clearpage

\pagestyle{empty}
\thispagestyle{empty}
\null
\vspace*{\fill}
\begingroup
\fontsize{11pt}{14pt}\selectfont
\setlength{\parindent}{0pt}
\hyphenpenalty=10000
\exhyphenpenalty=10000
\tolerance=1000
\emergencystretch=1.5em
\begin{minipage}{0.8\textwidth}
\raggedright
\textbf{Copyright \textcopyright{} ${COPYRIGHT_YEAR} ${COPYRIGHT_HOLDER}}\par

\vspace{1.25\baselineskip}
First edition\par
Published ${PUBLISH_MONTH_YEAR}\par
\textbf{Publisher:} ${PUBLISHER_INFO}\par

\vspace{1.25\baselineskip}
This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0).\par

\vspace{0.75\baselineskip}
You are free to share and adapt the material for noncommercial purposes, provided that appropriate credit is given, a link to the license is included, and any changes made are indicated.\par

\vspace{0.75\baselineskip}
License:\par
\url{https://creativecommons.org/licenses/by-nc/4.0/}\par

\vspace{1.25\baselineskip}
\textbf{Author:} ${AUTHOR_NAME}\par
\textbf{Website:} ${WEBSITE_URL}\par
\textbf{Cover design:} ${COVER_DESIGN_CREDIT}\par

\vspace{1.25\baselineskip}
\textbf{Companion to:}\par
${TEXTBOOK_VOLUME}\par
\end{minipage}
\endgroup
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

    format_chapter "${chapter_path}"
    printf '\n'
  done
} > "${OUTPUT_MD}"

pandoc "${OUTPUT_MD}" \
  --standalone \
  --from markdown+tex_math_dollars \
  --pdf-engine=xelatex \
  --include-in-header="${HEADER_FILE}" \
  -V mainfont="Libertinus Serif" \
  -V mathfont="Libertinus Math" \
  -V sansfont="TeX Gyre Adventor" \
  -V monofont="DejaVu Sans Mono" \
  -V documentclass:book \
  -V classoption:openany \
  -V classoption:twoside \
  -V geometry:paperwidth=7in,paperheight=10in,inner=0.90in,outer=0.72in,top=0.64in,bottom=0.82in \
  -V fontsize=11pt \
  -V colorlinks=true \
  -o "${TMP_PDF}"

mv "${TMP_PDF}" "${OUTPUT_PDF}"

echo "Wrote ${OUTPUT_MD}"
echo "Wrote ${OUTPUT_PDF}"
