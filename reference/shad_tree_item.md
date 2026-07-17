# Tree item

Tree item

## Usage

``` r
shad_tree_item(
  value,
  label,
  ...,
  icon = NULL,
  expanded = FALSE,
  lazy = FALSE,
  disabled = FALSE
)
```

## Arguments

- value:

  The item key (row identity in values/events; must be unique).

- label:

  The item label.

- ...:

  Child `shad_tree_item()` nodes (makes this a branch), plus optional
  named attributes.

- icon:

  Optional icon: a
  [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md)
  name or tag. Defaults to a folder glyph for branches and a file glyph
  for leaves.

- expanded:

  If `TRUE`, a branch starts open.

- lazy:

  If `TRUE`, mark a childless branch whose children load on first expand
  (via `update_shad_tree(children=)`).

- disabled:

  If `TRUE`, the item is unselectable and skipped by keyboard
  navigation.

## Value

A tree item `<li>` tag.

## See also

Other shadshiny flow:
[`shad_dropzone()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropzone.md),
[`shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_number_input.md),
[`shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/shad_rating.md),
[`shad_step()`](https://orijitghosh.github.io/shadshiny/reference/shad_step.md),
[`shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/shad_stepper.md),
[`shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree.md),
[`update_shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_number_input.md),
[`update_shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_rating.md),
[`update_shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_stepper.md),
[`update_shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_tree.md)
