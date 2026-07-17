# Define a custom theme

Build a custom shadshiny theme by overriding design tokens. Only the
tokens you supply are emitted; everything else inherits the base theme,
so a one-liner like `shad_theme(primary = "#7c3aed")` is a complete
brand theme. Pass the result to
[`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md),
[`shad_theme_scope()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_scope.md),
or
[`update_shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_theme.md).

## Usage

``` r
shad_theme(
  primary = NULL,
  primary_foreground = NULL,
  background = NULL,
  foreground = NULL,
  card = NULL,
  card_foreground = NULL,
  muted = NULL,
  muted_foreground = NULL,
  accent = NULL,
  accent_foreground = NULL,
  destructive = NULL,
  border = NULL,
  input = NULL,
  ring = NULL,
  radius = NULL,
  font_sans = NULL,
  font_mono = NULL,
  chart = NULL,
  dark = NULL,
  ...
)
```

## Arguments

- primary, primary_foreground, background, foreground, card,
  card_foreground, muted, muted_foreground, accent, accent_foreground,
  destructive, border, input, ring:

  Color tokens. Accept any CSS color string (`"#7c3aed"`,
  `"oklch(...)"`) or an R color name.

- radius:

  Base radius (e.g. `"0.5rem"`).

- font_sans, font_mono:

  CSS font-family strings.

- chart:

  Character vector of up to 6 chart series colors.

- dark:

  Optional dark-mode overrides, applied under `.dark`. Either a second
  `shad_theme()` or a named list of the same token arguments, which is
  passed to `shad_theme()` for you. Tokens you omit keep their light
  value.

- ...:

  Any additional raw token: `sidebar = ...` maps to `--shad-sidebar`,
  `sidebar_primary = ...` to `--shad-sidebar-primary`, etc.

## Value

A `shad_theme` object.

## See also

Other shadshiny theming:
[`shad_chart_colors()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_colors.md),
[`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md),
[`shad_theme_echarts4r()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_echarts4r.md),
[`shad_theme_from_registry()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_from_registry.md),
[`shad_theme_ggplot2()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md),
[`shad_theme_plotly()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_plotly.md),
[`shad_theme_scope()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_scope.md),
[`shad_tokens()`](https://orijitghosh.github.io/shadshiny/reference/shad_tokens.md)

## Examples

``` r
shad_theme(primary = "#7c3aed", radius = "0.75rem")
#> $tokens
#> $tokens$primary
#> [1] "#7c3aed"
#> 
#> $tokens$radius
#> [1] "0.75rem"
#> 
#> 
#> $dark
#> NULL
#> 
#> attr(,"class")
#> [1] "shad_theme"
```
