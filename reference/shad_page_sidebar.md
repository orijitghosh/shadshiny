# Page shell with a sidebar

A full-height page built on
[`shad_sidebar_layout()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md):
a collapsible sidebar, a bar carrying the sidebar trigger and page
title, and a scrolling main region. `input$<inputId>` reports the
sidebar state (including `active`, the clicked
[`shad_sidebar_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md));
toggle it from the server with
[`shad_sidebar_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md).

## Usage

``` r
shad_page_sidebar(
  sidebar,
  ...,
  inputId = "sidebar",
  title = NULL,
  header = NULL,
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

- sidebar:

  A
  [`shad_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md).

- ...:

  Main content, or named HTML attributes for the scope container.

- inputId:

  Input id for the sidebar layout.

- title:

  Optional page title shown in the bar.

- header:

  Optional content appended to the bar (after the title).

- header_end:

  Optional content pinned to the end of the bar (e.g. a dark mode
  switch).

- container:

  If `TRUE` (default), wrap the main content in a
  [`shad_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_container.md).
  Pass a list of arguments to configure it, or `FALSE` to place content
  flush.

- page_title, theme_preset, dark, theme, lang:

  Passed to
  [`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md).

## Value

A page UI object.

## See also

[`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md),
[`shad_sidebar_layout()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md)

Other shadshiny layout:
[`shad_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_container.md),
[`shad_grid()`](https://orijitghosh.github.io/shadshiny/reference/shad_grid.md),
[`shad_page_navbar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_navbar.md),
[`shad_stack()`](https://orijitghosh.github.io/shadshiny/reference/shad_stack.md)

## Examples

``` r
if (interactive()) {
  shiny::shinyApp(
    shad_page_sidebar(
      sidebar = shad_sidebar(shad_sidebar_group("Menu",
        shad_sidebar_item("home", "Home", icon = "home"))),
      title = "Acme", shad_p("Main content")
    ),
    function(input, output, session) {}
  )
}
```
