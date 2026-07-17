# Scope a custom theme to a subtree

Wrap UI in a custom
[`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md)
applied only to its descendants.

## Usage

``` r
shad_theme_scope(theme, ..., class = NULL)
```

## Arguments

- theme:

  A
  [`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md)
  object.

- ...:

  UI to wrap.

- class:

  Extra CSS classes on the wrapper.

## Value

A `<div>` scoping the theme.

## See also

Other shadshiny theming:
[`shad_chart_colors()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_colors.md),
[`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md),
[`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md),
[`shad_theme_echarts4r()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_echarts4r.md),
[`shad_theme_from_registry()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_from_registry.md),
[`shad_theme_ggplot2()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md),
[`shad_theme_plotly()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_plotly.md),
[`shad_tokens()`](https://orijitghosh.github.io/shadshiny/reference/shad_tokens.md)

## Examples

``` r
shad_theme_scope(shad_theme(primary = "#16a34a"), shad_button("Go"))
#> <style>.shad-theme-1 {
#>   --shad-primary: #16a34a;
#> }</style>
#> <div class="shad-theme-1">
#>   <button type="button" class="shad-btn shad-btn--default">Go</button>
#> </div>
```
