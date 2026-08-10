# Flex stack

A one-dimensional flex layout: children in a column (default) or a row,
with a token-scale gap. The workhorse for "these things, spaced".

## Usage

``` r
shad_stack(
  ...,
  direction = c("vertical", "horizontal"),
  gap = 4,
  align = NULL,
  justify = NULL,
  wrap = FALSE,
  fill = FALSE,
  class = NULL
)
```

## Arguments

- ...:

  Children, or named HTML attributes for the root.

- direction:

  `"vertical"` (default) or `"horizontal"`.

- gap:

  Gap between children: a spacing token step (default `4` = 1rem) or a
  CSS length.

- align:

  Cross-axis alignment: `"stretch"` (default), `"start"`, `"center"`,
  `"end"`, `"baseline"`.

- justify:

  Main-axis distribution: `"start"` (default), `"center"`, `"end"`,
  `"between"`, `"around"`, `"evenly"`.

- wrap:

  If `TRUE`, children wrap onto new lines.

- fill:

  If `TRUE`, children share the free space equally.

- class:

  Extra CSS classes.

## Value

A `<div>` tag.

## See also

Other shadshiny layout:
[`shad_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_container.md),
[`shad_grid()`](https://orijitghosh.github.io/shadshiny/reference/shad_grid.md),
[`shad_page_navbar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_navbar.md),
[`shad_page_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_sidebar.md)

## Examples

``` r
shad_stack(shad_button("Save"), shad_button("Cancel", variant = "outline"),
           direction = "horizontal", gap = 2)
#> <div class="shad-stack" style="--shad-stack-dir:row;--shad-stack-gap:var(--shad-space-2);">
#>   <button type="button" class="shad-btn shad-btn--default">Save</button>
#>   <button type="button" class="shad-btn shad-btn--outline">Cancel</button>
#> </div>
```
