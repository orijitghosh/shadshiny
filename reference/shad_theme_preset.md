# Wrap UI in a theme-preset scope

Applies a shadshiny colour preset to a subtree via `data-shad-theme`.
Nest freely; the nearest ancestor wins.

## Usage

``` r
shad_theme_preset(preset, ...)
```

## Arguments

- preset:

  One of the full neutral ramps `"slate"`, `"stone"`, `"zinc"`,
  `"mauve"`, `"olive"`, `"mist"`, `"taupe"`, or the accents `"blue"`,
  `"green"`, `"rose"`, `"violet"`, `"orange"`.

- ...:

  UI children (and optional named attributes).

## Value

A `<div>` tag carrying `data-shad-theme`.

## See also

Other shadshiny page & theming:
[`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md),
[`update_shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_theme.md)

## Examples

``` r
shad_theme_preset("green", shad_badge("Success"))
#> <div data-shad-theme="green">
#>   <span class="shad-badge shad-badge--default">Success</span>
#> </div>
```
