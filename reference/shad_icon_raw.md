# Use an arbitrary SVG as a shadshiny icon

Wrap a raw `<svg>` string (e.g. any Lucide glyph pasted from
<https://lucide.dev>) with the `.shad-icon` sizing class, so icons
beyond the built-in set can be used anywhere a
[`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md)
is accepted.

## Usage

``` r
shad_icon_raw(svg, class = "shad-icon")
```

## Arguments

- svg:

  A raw `<svg>...</svg>` string, or an htmltools tag.

- class:

  CSS classes to apply (default `"shad-icon"`).

## Value

An icon tag carrying the shadshiny asset dependency.

## See also

Other shadshiny utilities:
[`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md),
[`shad_icon_names()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon_names.md),
[`shad_run_example()`](https://orijitghosh.github.io/shadshiny/reference/shad_run_example.md),
[`shadshiny_deps()`](https://orijitghosh.github.io/shadshiny/reference/shadshiny_deps.md)

## Examples

``` r
shad_icon_raw('<svg viewBox="0 0 24 24"><path d="M5 12h14"/></svg>')
#> <svg class="shad-icon" viewBox="0 0 24 24"><path d="M5 12h14"/></svg>
```
