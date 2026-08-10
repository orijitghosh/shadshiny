# Timeline

A vertical timeline of dated events (dot + connector + content). Compose
from
[`shad_timeline_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline_item.md)
children.

## Usage

``` r
shad_timeline(..., align = c("left", "alternate"), class = NULL)
```

## Arguments

- ...:

  [`shad_timeline_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline_item.md)
  entries, plus optional named attributes.

- align:

  `"left"` (default) or `"alternate"` (two-column, items alternate sides
  of a center spine).

- class:

  Extra CSS classes.

## Value

A timeline `<ol>` tag.

## See also

Other shadshiny dashboard:
[`shad_chart_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_container.md),
[`shad_mini_donut()`](https://orijitghosh.github.io/shadshiny/reference/shad_mini_donut.md),
[`shad_sparkline()`](https://orijitghosh.github.io/shadshiny/reference/shad_sparkline.md),
[`shad_timeline_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline_item.md),
[`shad_value_box()`](https://orijitghosh.github.io/shadshiny/reference/shad_value_box.md)

## Examples

``` r
shad_timeline(
  shad_timeline_item("Order placed", time = "Jul 10", status = "active"),
  shad_timeline_item("Shipped", time = "Jul 12")
)
#> <ol class="shad-timeline">
#>   <li class="shad-timeline__item" data-state="active">
#>     <span class="shad-timeline__marker">
#>       <span class="shad-timeline__dot"></span>
#>       <span class="shad-timeline__connector" aria-hidden="true"></span>
#>     </span>
#>     <div class="shad-timeline__content">
#>       <time class="shad-timeline__time">Jul 10</time>
#>       <div class="shad-timeline__title">Order placed</div>
#>     </div>
#>   </li>
#>   <li class="shad-timeline__item">
#>     <span class="shad-timeline__marker">
#>       <span class="shad-timeline__dot"></span>
#>       <span class="shad-timeline__connector" aria-hidden="true"></span>
#>     </span>
#>     <div class="shad-timeline__content">
#>       <time class="shad-timeline__time">Jul 12</time>
#>       <div class="shad-timeline__title">Shipped</div>
#>     </div>
#>   </li>
#> </ol>
```
