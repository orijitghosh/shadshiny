# Chart container

A card-styled wrapper that gives R plot output (a
[`shiny::plotOutput()`](https://rdrr.io/pkg/shiny/man/plotOutput.html),
htmlwidget, canvas, or inline SVG) the shadcn chart look: header title /
description, an aspect-locked body, an optional legend strip
auto-colored from the chart tokens, and a footer caption. Pair with the
theming adapters in
[`shad_theme_ggplot2()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md)
/
[`shad_theme_plotly()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_plotly.md)
so the plot itself follows the active theme.

## Usage

``` r
shad_chart_container(
  ...,
  title = NULL,
  description = NULL,
  footer = NULL,
  legend = NULL,
  legend_labels = NULL,
  aspect = c("video", "square", "wide", "auto"),
  plain = FALSE,
  class = NULL
)
```

## Arguments

- ...:

  The plot output (and any extra named attributes) placed in the chart
  body.

- title:

  Optional chart title.

- description:

  Optional description under the title.

- footer:

  Optional footer caption.

- legend:

  Optional legend: a named character vector `c("Label" = color)`, or
  `TRUE` to auto-color a supplied `legend_labels` vector from the chart
  tokens, or a tag. `NULL` omits the legend.

- legend_labels:

  Character labels used when `legend = TRUE`.

- aspect:

  `"video"` (16:9, default), `"square"`, `"wide"` (21:9), or `"auto"`
  (natural height).

- plain:

  If `TRUE`, drop the card border/background (`--plain` variant).

- class:

  Extra CSS classes.

## Value

A chart-container `<figure>` tag.

## See also

Other shadshiny dashboard:
[`shad_timeline()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline.md),
[`shad_timeline_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline_item.md),
[`shad_value_box()`](https://orijitghosh.github.io/shadshiny/reference/shad_value_box.md)

## Examples

``` r
if (interactive()) {
  shad_chart_container(
    shiny::plotOutput("p"),
    title = "Monthly revenue", description = "Jan - Jun 2026"
  )
}
```
