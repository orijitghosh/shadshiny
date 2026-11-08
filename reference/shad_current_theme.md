# The active shadshiny theme (reactive)

Read the theme currently applied in the browser – its preset and
dark-mode flag – inside a reactive context. The asset layer reports this
as a hidden input on load and whenever the theme changes, so a
[`renderPlot()`](https://rdrr.io/pkg/shiny/man/renderPlot.html) that
calls `shad_current_theme()` re-executes on every dark toggle or preset
switch.

## Usage

``` r
shad_current_theme(session = shiny::getDefaultReactiveDomain())
```

## Arguments

- session:

  The Shiny session.

## Value

A list with `preset` (character or `NULL`) and `dark` (logical).

## See also

Other shadshiny theming:
[`shad_chart_colors()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_colors.md),
[`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md),
[`shad_theme_echarts4r()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_echarts4r.md),
[`shad_theme_from_registry()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_from_registry.md),
[`shad_theme_ggplot2()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md),
[`shad_theme_plotly()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_plotly.md),
[`shad_theme_scope()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_scope.md),
[`shad_tokens()`](https://orijitghosh.github.io/shadshiny/reference/shad_tokens.md)

## Examples

``` r
if (interactive()) {
  ui <- page_shad(
    shad_select("preset", "Theme", selected = "slate",
                choices = c("slate", "blue", "rose")),
    shiny::plotOutput("plot")
  )
  server <- function(input, output, session) {
    shiny::observe(update_shad_theme(preset = input$preset))
    output$plot <- shiny::renderPlot({
      th <- shad_current_theme()
      plot(1:10, pch = 19, col = shad_chart_colors(1, th$preset, th$dark))
    }, bg = "transparent")
  }
  shiny::shinyApp(ui, server)
}
```
