# ggplot2 theme matching the shadshiny design system

Experimental. A complete ggplot2 theme (transparent plot/panel
backgrounds, tokenised grid and text colors) so plots sit correctly on
any shadshiny surface. Pair with `shad_scale_color_shad()` /
`shad_scale_fill_shad()` for the categorical palette. Requires ggplot2.

## Usage

``` r
shad_theme_ggplot2(preset = NULL, dark = FALSE, base_size = 14)

shad_scale_color_shad(preset = NULL, dark = FALSE, ...)

shad_scale_fill_shad(preset = NULL, dark = FALSE, ...)
```

## Arguments

- preset:

  A theme preset name, or a
  [`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md)
  list (its `preset`/`dark` are used).

- dark:

  If `TRUE`, use dark-mode token colors.

- base_size:

  Base font size.

- ...:

  Passed to the underlying ggplot2 scale.

## Value

A ggplot2 theme object.

## See also

Other shadshiny theming:
[`shad_chart_colors()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_colors.md),
[`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md),
[`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md),
[`shad_theme_echarts4r()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_echarts4r.md),
[`shad_theme_from_registry()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_from_registry.md),
[`shad_theme_plotly()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_plotly.md),
[`shad_theme_scope()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_scope.md),
[`shad_tokens()`](https://orijitghosh.github.io/shadshiny/reference/shad_tokens.md)

## Examples

``` r
if (interactive() && requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  ggplot(mtcars, aes(wt, mpg)) + geom_point() + shad_theme_ggplot2()
}
```
