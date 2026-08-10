# Responsive grid

A CSS grid with either a fixed (optionally per-breakpoint) column count
or a responsive auto-fit track list.

## Usage

``` r
shad_grid(
  ...,
  cols = NULL,
  min_width = NULL,
  template = NULL,
  gap = 4,
  align = NULL,
  class = NULL
)

shad_grid_item(..., span = 1, class = NULL)
```

## Arguments

- ...:

  Children, or named HTML attributes for the root.

- cols:

  Column count: a number, or a named vector over `base`/`sm`/`md`/`lg`.

- min_width:

  Minimum column width for an auto-fit grid (e.g. `"16rem"`). Takes
  precedence over `cols`.

- template:

  An explicit `grid-template-columns` value, e.g. `"1fr 2fr"`. Takes
  precedence over both.

- gap:

  Gap between cells: a spacing token step (default `4`) or a CSS length.

- align:

  Block-axis alignment of cells: `"stretch"` (default), `"start"`,
  `"center"`, `"end"`.

- class:

  Extra CSS classes.

- span:

  Number of columns this cell spans, or `"full"` for the whole row.

## Value

A `<div>` tag.

## Details

Pass `cols` as a single number for a fixed count, or as a named vector
over the breakpoints `base`/`sm`/`md`/`lg` (40rem / 48rem / 64rem) —
unnamed entries are the base. Each breakpoint falls back to the one
below it, so `cols = c(base = 1, md = 3)` is two rules, not four.

`min_width` is usually simpler still: it lays out as many equal columns
as fit at that minimum width, with no breakpoints at all.

## See also

Other shadshiny layout:
[`shad_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_container.md),
[`shad_page_navbar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_navbar.md),
[`shad_page_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_sidebar.md),
[`shad_stack()`](https://orijitghosh.github.io/shadshiny/reference/shad_stack.md)

## Examples

``` r
shad_grid(shad_value_box("1", "One"), shad_value_box("2", "Two"),
          min_width = "12rem")
#> <div class="shad-grid shad-grid--auto" style="--shad-grid-gap:var(--shad-space-4);--shad-grid-min:12rem;">
#>   <div class="shad-value-box">
#>     <div class="shad-value-box__label">One</div>
#>     <div class="shad-value-box__value">1</div>
#>   </div>
#>   <div class="shad-value-box">
#>     <div class="shad-value-box__label">Two</div>
#>     <div class="shad-value-box__value">2</div>
#>   </div>
#> </div>
shad_grid(shad_card("a"), shad_card("b"), cols = c(base = 1, md = 2))
#> <div class="shad-grid" style="--shad-grid-cols:1;--shad-grid-cols-md:2;--shad-grid-gap:var(--shad-space-4);">
#>   <div class="shad-card">a</div>
#>   <div class="shad-card">b</div>
#> </div>
```
