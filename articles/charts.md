# Dashboards & charts

shadshiny does not draw charts. It gives you the shell around them –
[`shad_value_box()`](https://orijitghosh.github.io/shadshiny/reference/shad_value_box.md)
and
[`shad_chart_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_container.md)
– and the palette inside them, so a ggplot2, plotly, or echarts4r figure
matches the page instead of fighting it.

## KPI cards

``` r

library(shiny)
library(shadshiny)

shad_value_box(
  value           = "$48,120",
  label           = "Revenue",
  delta           = "+12.4%",
  delta_direction = "up",       # "auto", "up", "down", "neutral"
  icon            = "activity",
  caption         = "vs. last month"
)
```

`delta_direction = "auto"` reads the sign off the `delta` string: a
leading `-` or `−` renders the down/destructive chip, anything else
renders up. Set it explicitly whenever “up” isn’t the good direction –
churn going up is not a win.

`sparkline` takes any tag. Reach for
[`shad_sparkline()`](https://orijitghosh.github.io/shadshiny/reference/shad_sparkline.md)
before a
[`plotOutput()`](https://rdrr.io/pkg/shiny/man/plotOutput.html): it is
inline SVG with no plotting stack and, more usefully, its marks are
painted with the theme’s chart tokens, so a dark-mode toggle or a preset
switch restyles it *in CSS* – no re-render, no server round-trip.

``` r

shad_value_box("1,204", "Sessions", delta = "-3.1%",
               sparkline = shad_sparkline(sessions, type = "area"))
```

`size` is `"sm"`, `"md"`, or `"lg"`; `href` turns the whole card into a
link.

Lay them out with
[`shad_grid()`](https://orijitghosh.github.io/shadshiny/reference/shad_grid.md)
– `min_width` fits as many equal columns as will fit, with no
breakpoints to maintain:

``` r

shad_grid(
  shad_value_box("$48,120", "Revenue", delta = "+12.4%"),
  shad_value_box("1,204", "Sessions", delta = "-3.1%"),
  shad_value_box("2.4%", "Conversion", delta = "0.0%", delta_direction = "neutral"),
  min_width = "12rem"
)
```

## Sparklines and donuts

[`shad_sparkline()`](https://orijitghosh.github.io/shadshiny/reference/shad_sparkline.md)
draws `"line"`, `"area"`, `"bar"`, or `"step"` from a numeric vector,
with no axes and no labels. It stretches to fill whatever box it is
dropped into – a value box strip, a table cell, an item row:

``` r

shad_sparkline(c(31, 40, 28, 51, 42, 62), type = "area")
shad_sparkline(c(-4, -1, 2, 5, -3), type = "bar", color = 2)  # bars hang off zero
```

Non-finite values break the series rather than being interpolated
across, so a gap in the data reads as a gap in the line.

[`shad_mini_donut()`](https://orijitghosh.github.io/shadshiny/reference/shad_mini_donut.md)
shows a few parts of a whole, with optional content in the middle:

``` r

shad_mini_donut(c(62, 24, 14), center = "62%")
shad_mini_donut(c(3, 1), thickness = 1)   # thickness = 1 is a pie
```

`color` (and the donut’s `colors`) take a chart-token index `1`–`5`, or
any CSS colour when you need to step outside the palette. Both charts
are decorative by default and hidden from screen readers – the number
they illustrate is normally right next to them. Pass `label` when the
chart is the only carrier of the information.

## The chart card

``` r

shad_chart_container(
  plotOutput("trend", height = "260px"),
  title       = "Revenue by region",
  description = "Last 6 months",
  legend      = TRUE,
  aspect      = "video"   # "video", "square", "wide", or "auto"
)
```

`aspect` locks the card’s ratio. Use `"auto"` when you set an explicit
height on the plot yourself – otherwise the two fight and you get
letterboxing. `plain = TRUE` drops the card chrome and keeps only the
sizing wrapper, which is what you want when the container already sits
inside a
[`shad_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_card.md).

`legend_labels` renders a legend strip in the chart palette, in order,
so you can label a plot whose own legend you suppressed:

``` r

shad_chart_container(
  plotOutput("stack"),
  title = "Channel mix",
  legend_labels = c("Online", "Retail", "Partner")
)
```

## The palette

`shad_chart_colors(n, preset, dark)` returns `n` hex colours from the
active theme’s `--shad-chart-1` … `--shad-chart-6` ramp, interpolating
past six:

``` r

shad_chart_colors(3)                        # default preset, light
shad_chart_colors(8, "blue", dark = TRUE)   # 8 colours, blue preset, dark mode
```

`shad_tokens(preset, dark)` gives you the whole token set as OKLCH
strings if you need something the chart ramp doesn’t cover
(`background`, `border`, `muted-foreground`, …).

## Following the live theme

This is the part that matters.
[`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md)
themes are switched at *runtime* – by
[`update_shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_theme.md)
or the user’s dark-mode toggle – and a plot rendered in R has no idea.
[`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md)
is the bridge: a reactive read of the browser’s current theme that
returns `list(preset = , dark = )`. Touch it inside
[`renderPlot()`](https://rdrr.io/pkg/shiny/man/renderPlot.html) and the
plot re-renders whenever the theme changes.

``` r

output$trend <- renderPlot({
  th <- shad_current_theme()          # reactive dependency on the live theme
  ggplot2::ggplot(sales, ggplot2::aes(month, amount, colour = region)) +
    ggplot2::geom_line(linewidth = 1) +
    shad_scale_color_shad(th$preset, th$dark) +
    shad_theme_ggplot2(th$preset, th$dark)
}, bg = "transparent")                 # let the card show through in dark mode
```

Forget
[`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md)
and your chart keeps its old colours until some unrelated reactive
happens to invalidate it. Forget `bg = "transparent"` and
[`renderPlot()`](https://rdrr.io/pkg/shiny/man/renderPlot.html) paints a
white PNG behind the plot, so dark-mode text lands on white.

## ggplot2

The plot adapters in this and the next section are experimental: their
behavior also depends on the third-party plotting packages, so they may
change before shadshiny 1.0.

| Helper | Does |
|----|----|
| `shad_theme_ggplot2(preset, dark, base_size)` | A [`theme()`](https://ggplot2.tidyverse.org/reference/theme.html) matching the page: background, grid, text, and border colours. |
| `shad_scale_color_shad(preset, dark, ...)` | Discrete colour scale from the chart ramp. |
| `shad_scale_fill_shad(preset, dark, ...)` | The same, for `fill`. |

Extra `...` pass through to
[`ggplot2::discrete_scale()`](https://ggplot2.tidyverse.org/reference/discrete_scale.html),
so `name`, `labels`, and `guide` work as usual.

``` r

ggplot2::ggplot(agg, ggplot2::aes(region, amount, fill = region)) +
  ggplot2::geom_col() +
  shad_scale_fill_shad(th$preset, th$dark, guide = "none") +
  shad_theme_ggplot2(th$preset, th$dark, base_size = 13) +
  ggplot2::labs(x = NULL, y = NULL)
```

## plotly and echarts4r

These take the widget and return it, so they pipe:

``` r

output$p <- plotly::renderPlotly({
  th <- shad_current_theme()
  plotly::plot_ly(sales, x = ~month, y = ~amount, color = ~region,
                  type = "scatter", mode = "lines") |>
    shad_theme_plotly(th$preset, th$dark)
})

output$e <- echarts4r::renderEcharts4r({
  th <- shad_current_theme()
  sales |>
    echarts4r::e_charts(month) |>
    echarts4r::e_line(amount) |>
    shad_theme_echarts4r(th$preset, th$dark)
})
```

Both `plotly` and `echarts4r` are Suggests – the helpers error with a
clear message if the package isn’t installed.

## Base graphics

There is no theme helper, but the palette is just hex, so:

``` r

output$bar <- renderPlot({
  th <- shad_current_theme()
  ink <- if (th$dark) "#A1A1A1" else "#737373"   # axis text for either card
  op <- par(fg = ink, col.axis = ink)
  on.exit(par(op), add = TRUE)
  barplot(values, col = shad_chart_colors(length(values), th$preset, th$dark),
          border = NA)
}, bg = "transparent")
```

## Timelines

For event feeds rather than figures:

``` r

shad_timeline(
  shad_timeline_item("Order placed", time = "09:12", icon = "check",
                     description = "Payment authorised"),
  shad_timeline_item("Shipped", time = "14:40", status = "active"),
  shad_timeline_item("Delivered", time = "–", status = "muted", last = TRUE),
  align = "left"   # or "alternate"
)
```

## See also

- [`vignette("theming")`](https://orijitghosh.github.io/shadshiny/articles/theming.md)
  for presets, custom palettes, and runtime switching.
- [`vignette("data-tables")`](https://orijitghosh.github.io/shadshiny/articles/data-tables.md)
  for the table these dashboards usually sit above.
- `shad_run_example("07-data-explorer")` for all of it in one app.
