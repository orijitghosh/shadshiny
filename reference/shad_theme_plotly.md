# Apply the shadshiny theme to a plotly chart

Experimental. Restyle a plotly plot with transparent backgrounds,
tokenised fonts and gridlines, and the shadshiny categorical colorway.
Requires plotly.

## Usage

``` r
shad_theme_plotly(p, preset = NULL, dark = FALSE)
```

## Arguments

- p:

  A plotly object.

- preset:

  A preset name or
  [`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md)
  list.

- dark:

  If `TRUE`, use dark-mode colors.

## Value

The modified plotly object.

## See also

Other shadshiny theming:
[`shad_chart_colors()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_colors.md),
[`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md),
[`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md),
[`shad_theme_echarts4r()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_echarts4r.md),
[`shad_theme_from_registry()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_from_registry.md),
[`shad_theme_ggplot2()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md),
[`shad_theme_scope()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_scope.md),
[`shad_tokens()`](https://orijitghosh.github.io/shadshiny/reference/shad_tokens.md)
