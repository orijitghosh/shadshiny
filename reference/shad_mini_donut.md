# Mini donut chart

A ring showing a handful of parts of a whole, with an optional label in
the middle. Like
[`shad_sparkline()`](https://orijitghosh.github.io/shadshiny/reference/shad_sparkline.md)
it is plain SVG painted with the theme's chart tokens, so it follows
dark mode and preset switches in CSS.

## Usage

``` r
shad_mini_donut(
  values,
  colors = 1:5,
  size = "6rem",
  thickness = 0.28,
  center = NULL,
  track = TRUE,
  label = NULL,
  class = NULL,
  ...
)
```

## Arguments

- values:

  A numeric vector of non-negative parts. They are shown in proportion
  to their sum, so they need not add to 1 or 100.

- colors:

  Chart-token indices or CSS colours, recycled across the segments.
  Defaults to chart tokens 1–5.

- size:

  CSS diameter (default `"6rem"`).

- thickness:

  Ring thickness as a fraction of the radius (default `0.28`). `1` gives
  a pie.

- center:

  Optional content for the middle of the ring (a value, a percentage, a
  tag).

- track:

  If `TRUE` (default), draw the muted background ring that shows through
  when the segments do not fill it.

- label:

  Accessible name. `NULL` (default) marks the chart decorative.

- class:

  Extra CSS classes.

- ...:

  Extra attributes for the root `<div>`.

## Value

A `<div>` wrapping an SVG.

## Details

Segments are drawn as dashes on a single circle, which is why there is
no path arithmetic here and why the ring stays perfectly round at any
size.

## See also

[`shad_sparkline()`](https://orijitghosh.github.io/shadshiny/reference/shad_sparkline.md)

Other shadshiny dashboard:
[`shad_chart_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_container.md),
[`shad_sparkline()`](https://orijitghosh.github.io/shadshiny/reference/shad_sparkline.md),
[`shad_timeline()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline.md),
[`shad_timeline_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline_item.md),
[`shad_value_box()`](https://orijitghosh.github.io/shadshiny/reference/shad_value_box.md)

## Examples

``` r
shad_mini_donut(c(62, 24, 14), center = "62%")
#> <div class="shad-donut" style="width:6rem;height:6rem;">
#>   <svg class="shad-donut__svg" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
#>     <circle cx="50" cy="50" r="39.06" fill="none" stroke="var(--shad-muted)" stroke-width="21.88"></circle>
#>     <circle cx="50" cy="50" r="39.06" fill="none" stroke="var(--shad-chart-1)" stroke-width="21.88" stroke-dasharray="152.17 93.27" stroke-dashoffset="0"></circle>
#>     <circle cx="50" cy="50" r="39.06" fill="none" stroke="var(--shad-chart-2)" stroke-width="21.88" stroke-dasharray="58.9 186.53" stroke-dashoffset="-152.17"></circle>
#>     <circle cx="50" cy="50" r="39.06" fill="none" stroke="var(--shad-chart-3)" stroke-width="21.88" stroke-dasharray="34.36 211.08" stroke-dashoffset="-211.08"></circle>
#>   </svg>
#>   <div class="shad-donut__center">62%</div>
#> </div>
```
