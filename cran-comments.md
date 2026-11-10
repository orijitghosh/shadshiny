## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.
  The note also lists possibly misspelled words in DESCRIPTION:
  reimplementation, sparklines, themeable, theming and validator. They are
  spelled correctly; each is a standard technical term.

## Test environments

* win-builder: R-devel (2026-11-07 r90850 ucrt), Windows Server 2022 x64.
  The note above, and nothing else.
* macOS builder: R 4.6.1 Patched (2026-07-27 r90311), macOS Tahoe 26.6,
  arm64. Status OK, PDF manual included.
* GitHub Actions: R release on macOS, Windows and Ubuntu; R-devel, R
  oldrel-1 and R 4.1 on Ubuntu. All pass.
* Local: Windows 11 Pro, R 4.4.3, `R CMD check --as-cran --no-manual`. The
  same note, plus "unable to verify current time" because that machine
  couldn't reach the time service. It has no LaTeX, so the PDF manual was
  built on win-builder and the macOS builder only.

## Notes for the reviewer

* The package ships a prebuilt stylesheet and script,
  `inst/assets/dist/shadshiny.min.css` and `inst/assets/dist/shadshiny.min.js`.
  Their unminified sources ship too, in `inst/assets/components`,
  `inst/assets/core`, `inst/assets/shiny` and `inst/assets/tokens`, and
  `inst/assets/MANIFEST.md` says how the bundle is built from them.
  `options(shadshiny.assets = "source")` serves the unminified files instead.
  Building the bundle needs Node, but only in development: installing or using
  the package never does.

* The icon paths are from Lucide (ISC licence; some derive from Feather, MIT
  licence), and the colour token values follow those published by shadcn/ui
  (MIT licence). The `Copyright` field in DESCRIPTION names them, and
  `inst/COPYRIGHTS` holds their copyright and licence notices.

* Examples that start a Shiny app are wrapped in `if (interactive())`. Every
  other example runs, and no example uses `\dontrun{}`.
