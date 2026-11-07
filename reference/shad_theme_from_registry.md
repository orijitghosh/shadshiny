# Import a theme from a shadcn / tweakcn registry export

Experimental. Convert a shadcn registry item or tweakcn theme export
(its `cssVars` blocks) into a
[`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md),
mapping upstream variable names to shadshiny tokens via the bundled
theme map. Unmapped variables are skipped with a single warning.

## Usage

``` r
shad_theme_from_registry(json)
```

## Arguments

- json:

  A file path, URL, or JSON string of a registry/tweakcn export.

## Value

A `shad_theme` object.

## See also

Other shadshiny theming:
[`shad_chart_colors()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_colors.md),
[`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md),
[`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md),
[`shad_theme_echarts4r()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_echarts4r.md),
[`shad_theme_ggplot2()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md),
[`shad_theme_plotly()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_plotly.md),
[`shad_theme_scope()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_scope.md),
[`shad_tokens()`](https://orijitghosh.github.io/shadshiny/reference/shad_tokens.md)

## Examples

``` r
if (FALSE) { # \dontrun{
shad_theme_from_registry("https://tweakcn.com/r/themes/my-theme.json")
} # }
```
