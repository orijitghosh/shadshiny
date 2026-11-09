## R CMD check results

0 errors | 0 warnings | 2 notes

* This is a new submission.
  On win-builder this note also lists possibly misspelled words in
  DESCRIPTION: reimplementation, sparklines, themeable, theming and
  validator. They are spelled correctly; each is a standard technical term.
* "checking for future file timestamps ... unable to verify current time":
  the local machine couldn't reach the time service.

## Test environments

* Local: Windows 11 Pro, R 4.4.3, `R CMD check --as-cran --no-manual` (no
  LaTeX on that machine, so the PDF manual was not built there).

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
