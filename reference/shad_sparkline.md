# Sparkline

A tiny inline chart with no axes, no labels and no plotting stack: one
SVG path (or a row of bars) that stretches to fill its container. Built
for
[`shad_value_box()`](https://orijitghosh.github.io/shadshiny/reference/shad_value_box.md)'s
`sparkline` slot, a table cell, or an item row.

## Usage

``` r
shad_sparkline(
  values,
  type = c("line", "area", "bar", "step"),
  color = 1,
  width = "100%",
  height = "2.5rem",
  stroke_width = 2,
  fill_opacity = 0.18,
  baseline = NULL,
  label = NULL,
  class = NULL,
  ...
)
```

## Arguments

- values:

  A numeric vector.

- type:

  `"line"` (default), `"area"`, `"bar"`, or `"step"`.

- color:

  Chart-token index `1`–`5` (default `1`), or any CSS colour.

- width, height:

  CSS dimensions of the drawing box. Height defaults to `"2.5rem"`;
  width to `"100%"`, so it fills whatever it is dropped into.

- stroke_width:

  Line thickness in px (line/step/area outline).

- fill_opacity:

  Opacity of the area fill / bars.

- baseline:

  For `"bar"`, draw bars from zero when the data crosses it. `NULL`
  (default) picks automatically: zero-anchored if any value is negative,
  otherwise bars grow from the floor.

- label:

  Accessible name. When `NULL` (default) the chart is decorative and
  hidden from assistive technology – correct when the number it
  illustrates is already on screen.

- class:

  Extra CSS classes.

- ...:

  Extra attributes for the root `<svg>`.

## Value

An SVG tag.

## Details

Marks are painted with the theme's chart tokens, so dark mode and preset
switches restyle them in CSS – nothing re-renders, and no Shiny session
is involved. Non-finite values (`NA`, `NaN`, `Inf`) break the series
into separate runs rather than being interpolated across.

## See also

[`shad_mini_donut()`](https://orijitghosh.github.io/shadshiny/reference/shad_mini_donut.md),
[`shad_value_box()`](https://orijitghosh.github.io/shadshiny/reference/shad_value_box.md)

Other shadshiny dashboard:
[`shad_chart_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_container.md),
[`shad_mini_donut()`](https://orijitghosh.github.io/shadshiny/reference/shad_mini_donut.md),
[`shad_timeline()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline.md),
[`shad_timeline_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline_item.md),
[`shad_value_box()`](https://orijitghosh.github.io/shadshiny/reference/shad_value_box.md)

## Examples

``` r
shad_sparkline(c(3, 5, 4, 8, 7, 12, 11))
#> <svg class="shad-sparkline" viewBox="0 0 100 100" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg" style="width:100%;height:2.5rem;" aria-hidden="true">
#>   <path d="M0 98L16.67 76.67L33.33 87.33L50 44.67L66.67 55.33L83.33 2L100 12.67" fill="none" stroke="var(--shad-chart-1)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" vector-effect="non-scaling-stroke"></path>
#> </svg>
shad_sparkline(c(-2, 1, 3, -1, 4), type = "bar", color = 2)
#> <svg class="shad-sparkline" viewBox="0 0 100 100" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg" style="width:100%;height:2.5rem;" aria-hidden="true">
#>   <rect x="1" width="18" y="66.67" height="33.33" fill="var(--shad-chart-2)" fill-opacity="0.18" rx="1.5"></rect>
#>   <rect x="21" width="18" y="50" height="16.67" fill="var(--shad-chart-2)" fill-opacity="0.18" rx="1.5"></rect>
#>   <rect x="41" width="18" y="16.67" height="50" fill="var(--shad-chart-2)" fill-opacity="0.18" rx="1.5"></rect>
#>   <rect x="61" width="18" y="66.67" height="16.67" fill="var(--shad-chart-2)" fill-opacity="0.18" rx="1.5"></rect>
#>   <rect x="81" width="18" y="0" height="66.67" fill="var(--shad-chart-2)" fill-opacity="0.18" rx="1.5"></rect>
#> </svg>
```
