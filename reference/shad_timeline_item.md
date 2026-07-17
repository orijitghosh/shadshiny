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
[`shad_timeline()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline.md),
[`shad_value_box()`](https://orijitghosh.github.io/shadshiny/reference/shad_value_box.md)
