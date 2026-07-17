# Chart series colors

The categorical chart palette (`--shad-chart-1` … `--shad-chart-6`) for
a theme, converted to hex for use with R plotting libraries.

## Usage

``` r
shad_chart_colors(n = 6, preset = NULL, dark = FALSE)
```

## Arguments

- n:

  Number of colors (recycled past 6, with a warning).

- preset:

  Theme preset (see
  [`shad_tokens()`](https://orijitghosh.github.io/shadshiny/reference/shad_tokens.md));
  `NULL` = base.

- dark:

  If `TRUE`, use dark-mode values.

## Value

A character vector of `#rrggbb` hex colors.

## See also

Other shadshiny theming:
[`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md),
[`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md),
[`shad_theme_echarts4r()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_echarts4r.md),
[`shad_theme_from_registry()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_from_registry.md),
[`shad_theme_ggplot2()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md),
[`shad_theme_plotly()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_plotly.md),
[`shad_theme_scope()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_scope.md),
[`shad_tokens()`](https://orijitghosh.github.io/shadshiny/reference/shad_tokens.md)

## Examples

``` r
shad_chart_colors(3)
#> [1] "#F54900" "#009689" "#104E64"
shad_chart_colors(4, preset = "blue")
#> [1] "#155DFC" "#00B8DB" "#8E51FF" "#22C55E"
```
