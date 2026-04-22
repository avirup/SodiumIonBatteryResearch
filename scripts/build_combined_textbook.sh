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
COPYRIGHT_HOLDER="${COPYRIGHT_HOLDER:-Avirup Kundu}"
ISBN_13="${ISBN_13:-978-0-00000-000-0}"
PUBLISH_MONTH_YEAR="${PUBLISH_MONTH_YEAR:-May 2026}"
AUTHOR_NAME="${AUTHOR_NAME:-Avirup Kundu}"
WEBSITE_URL="${WEBSITE_URL:-www.avirup.net}"
COVER_DESIGN_CREDIT="${COVER_DESIGN_CREDIT:-AI-generated artwork}"
COMPANION_VOLUME="${COMPANION_VOLUME:-Modelling and Simulation Companion to Battery Technology for Electrical Engineers}"

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
  "battery_textbook_chapter10_revised.md"
  "battery_textbook_chapter11_revised.md"
  "battery_textbook_chapter12_revised.md"
  "battery_textbook_chapter13_reviewed.md"
  "battery_textbook_chapter14_reviewed.md"
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
    s/^\$\$(.+?\\tag\{[^}]*\}.*?)\$\$\s*$/\\begin{equation}\n$1\n\\end{equation}/mg;
  ' "${input_file}"
}

format_chapter() {
  local input_file="$1"

  clean_chapter "${input_file}" | perl -ne '
    BEGIN {
      $mode = "body";
    }

    sub normalize_heading_text {
      my ($text) = @_;

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

    sub reset_body_style {
      if ($mode ne "body") {
        print "\\bodytextstyle\n\n";
        $mode = "body";
      }
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

      if ($title =~ /^Worked Interpretation Exercise:\s*(.+)$/) {
        my $subtitle = normalize_heading_text($1);
        print "\\specialsectionwithsubtitle{Worked Interpretation Exercise}{$subtitle}\n\n";
        print "\\specialsectionstyle\n\n";
        $mode = "special";
        next;
      }

      if ($title =~ /^(What Changes for [^:]+):\s*(.+)$/) {
        my $label = normalize_heading_text($1);
        my $subtitle = normalize_heading_text($2);
        print "\\specialsectionwithsubtitle{$label}{$subtitle}\n\n";
        print "\\specialsectionstyle\n\n";
        $mode = "special";
        next;
      }

      if ($title =~ /^What Changes for /) {
        print "\\specialsectionplain{$title}\n\n";
        print "\\specialsectionstyle\n\n";
        $mode = "special";
        next;
      }

      if ($title eq "Chapter Summary" || $title eq "Deliverable" || $title eq "Further Reading") {
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

\vspace{1.25\baselineskip}
This work is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0).\par

\vspace{0.75\baselineskip}
You are free to share and adapt the material for noncommercial purposes, provided that appropriate credit is given, a link to the license is included, and any changes made are indicated.\par

\vspace{0.75\baselineskip}
License:\par
\url{https://creativecommons.org/licenses/by-nc/4.0/}\par

\vspace{1.25\baselineskip}
\textbf{ISBN:} ${ISBN_13}\par

\vspace{1.25\baselineskip}
\textbf{Author:} ${AUTHOR_NAME}\par
\textbf{Website:} ${WEBSITE_URL}\par
\textbf{Cover design:} ${COVER_DESIGN_CREDIT}\par

\vspace{1.25\baselineskip}
\textbf{Companion volume:}\par
${COMPANION_VOLUME}\par
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
    chapter_path="${TEXTBOOK_DIR}/${chapters[$i]}"

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
