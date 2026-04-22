# Textbook PDF Design Spec

## Purpose

This document defines the visual and typographic design choices for the combined textbook PDF generated from the Markdown manuscript. The goal is a screen-first PDF ebook that still feels like a professionally typeset technical textbook rather than a plain document export.

## Core Direction

- Reading mode: screen-first PDF ebook
- Editorial tone: serious, polished, modern technical textbook
- Layout model: hybrid mirrored layout with left/right page logic, but no forced blank verso pages
- Chapter style: structured textbook chapter openers with restrained accent use
- Color strategy: one quiet accent color used sparingly at chapter-level elements

## Page Geometry

- Page size: `7 x 10 in`
- Margin strategy: reduced digital margins for denser PDF reading
- Inner margin: `0.90 in`
- Outer margin: `0.72 in`
- Top margin: `0.64 in`
- Bottom margin: `0.82 in`
- Running furniture: minimal
- Page number position: outer bottom corners
- Chapter-opening pages: page number suppressed

## Typography

### Body Text

- Preferred body font: `Libertinus Serif`
- Body size: `11.5 pt`
- Leading: approximately `1.22`
- Text color: near-black, not pure black
- Alignment: mostly justified, with a looser screen-friendly texture
- Hyphenation: restrained
- Paragraph style: indented body paragraphs, with spacing-based separation only in instructional and chapter-end blocks

### Math

- Preferred math font: `Libertinus Math`
- Equation treatment: formal textbook presentation
- Equation numbering: chapter-based, right-aligned, and understated

### Headings

- Heading font: `TeX Gyre Adventor`
- Heading case: sentence case
- Section numbering: numeric prefixes present and visually emphasized
- Main section headings: clear technical hierarchy
- Subsection headings: same sans family, smaller, semibold, and compact stacked

### Monospace

- Monospace direction: book-integrated mono
- Relative size: slightly smaller than body text
- Intended use: code fences, plain-text blocks, ASCII-style technical inserts

## Chapter Openers

- Alignment: left-aligned structured opener
- Chapter number: moderately prominent
- Chapter title: large sans-serif title
- Opening whitespace: moderate, not ceremonial
- First paragraph after opener: flush left, no indent
- Accent treatment: thin accent rule plus subtle chapter-number color

## Table of Contents

- TOC depth: chapters plus main sections
- TOC visual hierarchy: chapter entries more prominent than section entries
- Overall tone: structured and readable, but not overly designed

## Technical Elements

### Tables

- Style: `booktabs`-style open tables
- Vertical rules: none
- Header row: quiet bold headers, no shading
- Tone: classical editorial tables, not spreadsheet-like grids

### Figures

- Placement: centered within the text block
- Default maximum width: about `90%` of the text width
- Sizing philosophy: large enough for technical readability, but not full-width by default

### Captions

- Figures: caption below
- Tables: caption above
- Caption tone: quiet and integrated
- Visual priority: subordinate to the content itself

### Links

- Hyperlink style: subtle digital treatment
- Behavior: links remain usable without making the page feel web-like

### Code And Plain-Text Blocks

- Block treatment: light framed treatment
- Tone: editorial and integrated, not developer-doc styling

### Lists

- List style: tight academic lists
- Goal: compact and disciplined, not presentation-like

## Teaching And Recurring Sections

These recurring sections should have a dedicated textbook styling layer:

- `Chapter Opening`
- `Worked Interpretation Exercise`
- `What Changes for Sodium-Ion?`
- `Chapter Summary`
- `Deliverable`
- `Further Reading`

### Treatment

- Styling system: rule-and-spacing treatment
- Section labels: small sans-serif labels with thin rules
- Visual goal: easy to spot, but still editorial and restrained
- End-of-chapter material: grouped into a structured end-of-chapter zone

## Color System

- Accent strategy: one restrained accent color only
- Accent family: dark slate blue
- Accent usage: primarily chapter-level elements, selected TOC emphasis, subtle navigational cues, and select special-section labels
- Regular section headings: remain dark neutral rather than accent-colored

## Intentional Omissions

The design should avoid the following:

- Decorative drop caps
- Heavy callout boxes
- Workbook-style interior treatment
- Deep, subsection-heavy TOCs
- Strongly visible hyperlink styling
- Developer-doc code styling
- Vertical table rules
- Overly ceremonial print-era blank pages

## Implementation Notes

This design spec was written for the Pandoc plus XeLaTeX textbook build pipeline in this repository. It describes the intended design target. If the preferred fonts are missing from the local environment, the build implementation should use the nearest stable LaTeX-safe fallback while preserving the hierarchy, spacing, and overall editorial tone described here.
