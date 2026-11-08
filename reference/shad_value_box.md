# KPI / value box

A compact stat card: a label, a large value, an optional trend delta
chip, an optional icon, caption, and sparkline slot. Grid-friendly –
drop several into a CSS grid for a KPI row.

## Usage

``` r
shad_value_box(
  value,
  label,
  delta = NULL,
  delta_direction = c("auto", "up", "down", "neutral"),
  icon = NULL,
  caption = NULL,
  sparkline = NULL,
  size = c("md", "sm", "lg"),
  href = NULL,
  class = NULL,
  ...
)
```

## Arguments

- value:

  The headline value (string or number; tags allowed).

- label:

  The stat label.

- delta:

  Optional delta text (e.g. `"+20.1%"`). Rendered as a chip.

- delta_direction:

  Trend for the chip: `"auto"` (default – inferred from a leading
  `+`/`-` in `delta`), `"up"`, `"down"`, or `"neutral"`.

- icon:

  Optional icon: a
  [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md)
  name or a tag, pinned top-right.

- caption:

  Optional muted caption line below the value.

- sparkline:

  Optional tag/output filling a small strip at the bottom (e.g. an
  inline `<svg>` or a
  [`plotOutput()`](https://rdrr.io/pkg/shiny/man/plotOutput.html)).

- size:

  `"md"` (default), `"sm"`, or `"lg"`.

- href:

  Optional URL; makes the whole box a link.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the root.

## Value

A value-box tag.

## See also

Other shadshiny dashboard:
[`shad_chart_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_container.md),
[`shad_mini_donut()`](https://orijitghosh.github.io/shadshiny/reference/shad_mini_donut.md),
[`shad_sparkline()`](https://orijitghosh.github.io/shadshiny/reference/shad_sparkline.md),
[`shad_timeline()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline.md),
[`shad_timeline_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline_item.md)

## Examples

``` r
shad_value_box("$45,231.89", "Total revenue", delta = "+20.1%",
               caption = "vs. last month")
#> <div class="shad-value-box">
#>   <div class="shad-value-box__label">Total revenue</div>
#>   <div class="shad-value-box__value">
#>     $45,231.89
#>     <span class="shad-value-box__delta" data-trend="up">
#>       <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7 17L17 7M7 7h10v10"/></svg>
#>       +20.1%
#>     </span>
#>   </div>
#>   <div class="shad-value-box__caption">vs. last month</div>
#> </div>
```
