# Resolve theme tokens

Return the resolved shadshiny design tokens for a theme preset and mode,
as a named list of raw CSS values (OKLCH strings). Used by the chart
adapters and available for custom plotting. Names are the token keys
without the `--shad-` prefix (e.g. `primary`, `chart-1`, `chart-grid`).

## Usage

``` r
shad_tokens(preset = NULL, dark = FALSE, overrides = NULL)
```

## Arguments

- preset:

  One of the twelve presets (`"slate"`, `"stone"`, `"zinc"`, `"mauve"`,
  `"olive"`, `"mist"`, `"taupe"`, `"blue"`, `"green"`, `"rose"`,
  `"violet"`, `"orange"`), or `NULL` for the base (neutral) theme.

- dark:

  If `TRUE`, return dark-mode values.

- overrides:

  Optional named list of token overrides (without `--shad-`), e.g. from
  a
  [`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md)
  object, applied on top.

## Value

A named list of CSS value strings.

## See also

Other shadshiny theming:
[`shad_chart_colors()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_colors.md),
[`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md),
[`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md),
[`shad_theme_echarts4r()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_echarts4r.md),
[`shad_theme_from_registry()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_from_registry.md),
[`shad_theme_ggplot2()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md),
[`shad_theme_plotly()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_plotly.md),
[`shad_theme_scope()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_scope.md)

## Examples

``` r
shad_tokens()[["primary"]]
#> [1] "oklch(0.205 0 0)"
shad_tokens("blue", dark = TRUE)[["chart-1"]]
#> [1] "oklch(0.623 0.214 259.815)"
```
