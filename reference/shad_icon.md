# Inline Lucide icon

Returns a 24x24 inline SVG (stroke-width 2, `currentColor`) matching the
icon markup embedded throughout the shadshiny asset bundle. Use it for
leading/trailing icons on buttons, menu items, and other slots that
accept an `icon` argument.

## Usage

``` r
shad_icon(name, class = "shad-icon", ...)
```

## Arguments

- name:

  Icon name. See
  [`shad_icon_names()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon_names.md)
  for the available set.

- class:

  CSS class(es) for the `<svg>`. Defaults to `"shad-icon"`.

- ...:

  Additional attributes for the `<svg>` (e.g. `aria-label`).

## Value

An
[`htmltools::HTML()`](https://rstudio.github.io/htmltools/reference/HTML.html)
SVG string.

## See also

Other shadshiny utilities:
[`shad_icon_names()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon_names.md),
[`shad_run_example()`](https://orijitghosh.github.io/shadshiny/reference/shad_run_example.md),
[`shadshiny_deps()`](https://orijitghosh.github.io/shadshiny/reference/shadshiny_deps.md)

## Examples

``` r
shad_icon("check")
#> <svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5"/></svg>
shad_icon("chevron-down", class = "shad-select__chevron")
#> <svg class="shad-select__chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"/></svg>
```
