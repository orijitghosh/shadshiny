# Attach the shadshiny asset bundle

Returns the html dependency (tokens, core CSS, runtime JS, every
component's CSS/JS, and the Shiny binding layer) in the correct load
order. Every `shad_*()` constructor already attaches this, so you only
need it when composing raw HTML by hand or ensuring assets load on a
page that renders no shadshiny component up front.

## Usage

``` r
shadshiny_deps()
```

## Value

An
[`htmltools::tagList()`](https://rstudio.github.io/htmltools/reference/tagList.html)
carrying the html dependency.

## See also

Other shadshiny utilities:
[`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md),
[`shad_icon_names()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon_names.md),
[`shad_run_example()`](https://orijitghosh.github.io/shadshiny/reference/shad_run_example.md)

## Examples

``` r
if (interactive()) {
  shiny::fluidPage(shadshiny_deps(), shad_badge("Ready"))
}
```
