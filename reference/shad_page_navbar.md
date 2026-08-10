# Page shell with a tabbed navbar

A full-height page whose top bar carries a
[`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md)
strip: the standard "app with a handful of top-level views" shell.
`input$<inputId>` is the active tab value; switch it from the server
with
[`update_shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md).

## Usage

``` r
shad_page_navbar(
  ...,
  inputId = "navbar",
  title = NULL,
  selected = NULL,
  header_end = NULL,
  container = TRUE,
  page_title = title,
  theme_preset = NULL,
  dark = NULL,
  theme = NULL,
  lang = "en"
)
```

## Arguments

- ...:

  One or more
  [`shad_tab()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md),
  or named HTML attributes for the scope container.

- inputId:

  Input id for the tab set.

- title:

  Optional brand/title shown at the start of the bar.

- selected:

  Initially active tab value (defaults to the first tab).

- header_end:

  Optional content pinned to the end of the bar.

- container:

  If `TRUE` (default), wrap each panel's content in a
  [`shad_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_container.md).
  Pass a list of arguments to configure it, or `FALSE`.

- page_title, theme_preset, dark, theme, lang:

  Passed to
  [`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md).

## Value

A page UI object.

## See also

[`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md),
[`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md)

Other shadshiny layout:
[`shad_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_container.md),
[`shad_grid()`](https://orijitghosh.github.io/shadshiny/reference/shad_grid.md),
[`shad_page_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_sidebar.md),
[`shad_stack()`](https://orijitghosh.github.io/shadshiny/reference/shad_stack.md)

## Examples

``` r
if (interactive()) {
  shiny::shinyApp(
    shad_page_navbar(
      shad_tab("home", "Home", shad_p("Home panel")),
      shad_tab("about", "About", shad_p("About panel")),
      title = "Acme"
    ),
    function(input, output, session) {}
  )
}
```
