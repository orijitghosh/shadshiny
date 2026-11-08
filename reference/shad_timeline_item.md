# Timeline item

Timeline item

## Usage

``` r
shad_timeline_item(
  title,
  ...,
  time = NULL,
  description = NULL,
  icon = NULL,
  status = c("default", "active", "muted"),
  last = FALSE,
  class = NULL
)
```

## Arguments

- title:

  The item title (string or tags).

- ...:

  Additional content appended after the description.

- time:

  Optional timestamp (rendered in a `<time>` element).

- description:

  Optional description line.

- icon:

  Optional icon inside the dot: a
  [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md)
  name or a tag. When omitted the dot is a small filled circle.

- status:

  `"default"`, `"active"` (primary-filled dot), or `"muted"`.

- last:

  If `TRUE`, omit the trailing connector (auto for the final child; set
  explicitly if composing dynamically).

- class:

  Extra CSS classes.

## Value

A timeline item `<li>` tag.

## See also

Other shadshiny dashboard:
[`shad_chart_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_container.md),
[`shad_mini_donut()`](https://orijitghosh.github.io/shadshiny/reference/shad_mini_donut.md),
[`shad_sparkline()`](https://orijitghosh.github.io/shadshiny/reference/shad_sparkline.md),
[`shad_timeline()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline.md),
[`shad_value_box()`](https://orijitghosh.github.io/shadshiny/reference/shad_value_box.md)

## Examples

``` r
shad_timeline(
  shad_timeline_item("Deployed", time = "10:42", status = "active",
                     description = "Version 2.1 is live."),
  shad_timeline_item("Tests passed", time = "10:30", status = "muted",
                     last = TRUE)
)
#> <ol class="shad-timeline">
#>   <li class="shad-timeline__item" data-state="active">
#>     <span class="shad-timeline__marker">
#>       <span class="shad-timeline__dot"></span>
#>       <span class="shad-timeline__connector" aria-hidden="true"></span>
#>     </span>
#>     <div class="shad-timeline__content">
#>       <time class="shad-timeline__time">10:42</time>
#>       <div class="shad-timeline__title">Deployed</div>
#>       <div class="shad-timeline__description">Version 2.1 is live.</div>
#>     </div>
#>   </li>
#>   <li class="shad-timeline__item" data-state="muted">
#>     <span class="shad-timeline__marker">
#>       <span class="shad-timeline__dot"></span>
#>     </span>
#>     <div class="shad-timeline__content">
#>       <time class="shad-timeline__time">10:30</time>
#>       <div class="shad-timeline__title">Tests passed</div>
#>     </div>
#>   </li>
#> </ol>
```
