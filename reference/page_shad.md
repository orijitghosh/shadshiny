# A shadshiny page

A page wrapper that attaches the shadshiny asset bundle and establishes
a `.shad-scope` root. Built on
[`bslib::page_fillable()`](https://rstudio.github.io/bslib/reference/page_fillable.html)
when bslib is installed, otherwise on
[`shiny::fluidPage()`](https://rdrr.io/pkg/shiny/man/fluidPage.html).
Dark mode follows
[`bslib::input_dark_mode()`](https://rstudio.github.io/bslib/reference/input_dark_mode.html)
automatically because the assets key off both `.dark` and
`[data-bs-theme="dark"]`.

## Usage

``` r
page_shad(
  ...,
  title = NULL,
  theme_preset = NULL,
  dark = NULL,
  theme = NULL,
  lang = "en"
)
```

## Arguments

- ...:

  UI elements, or named HTML attributes for the scope container.

- title:

  Page title (browser tab).

- theme_preset:

  One of `NULL` (default zinc), `"slate"`, `"stone"`, `"blue"`,
  `"green"`, `"rose"`, `"violet"`, `"orange"`. Sets `data-shad-theme` on
  the scope container.

- dark:

  `NULL` to follow bslib/OS, `TRUE` to force dark, `FALSE` to force
  light.

- theme:

  An optional custom
  [`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md)
  applied page-wide (layered over `theme_preset` when both are given).

- lang:

  Document language attribute.

## Value

A page UI object.

## See also

Other shadshiny page & theming:
[`shad_theme_preset()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_preset.md),
[`update_shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_theme.md)

## Examples

``` r
if (interactive()) {
  shiny::shinyApp(
    page_shad(shad_badge("Hello"), theme_preset = "blue"),
    function(input, output, session) {}
  )
}
```
