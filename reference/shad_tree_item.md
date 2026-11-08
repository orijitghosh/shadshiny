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

## Examples

``` r
shad_tree_item(
  "docs", "docs", expanded = TRUE,
  shad_tree_item("docs/intro.md", "intro.md"),
  shad_tree_item("docs/draft.md", "draft.md", disabled = TRUE)
)
#> <li class="shad-tree__item" role="treeitem" data-key="docs" aria-expanded="true">
#>   <div class="shad-tree__row">
#>     <svg class="shad-tree__chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 6l6 6-6 6"/></svg>
#>     <span class="shad-tree__icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg></span>
#>     <span class="shad-tree__label">docs</span>
#>   </div>
#>   <ul class="shad-tree__group" role="group">
#>     <li class="shad-tree__item" role="treeitem" data-key="docs/intro.md">
#>       <div class="shad-tree__row">
#>         <svg class="shad-tree__chevron shad-tree__chevron--leaf" viewBox="0 0 24 24" aria-hidden="true"><path d="M9 6l6 6-6 6"/></svg>
#>         <span class="shad-tree__icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/></svg></span>
#>         <span class="shad-tree__label">intro.md</span>
#>       </div>
#>     </li>
#>     <li class="shad-tree__item" role="treeitem" data-key="docs/draft.md" aria-disabled="true">
#>       <div class="shad-tree__row">
#>         <svg class="shad-tree__chevron shad-tree__chevron--leaf" viewBox="0 0 24 24" aria-hidden="true"><path d="M9 6l6 6-6 6"/></svg>
#>         <span class="shad-tree__icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/></svg></span>
#>         <span class="shad-tree__label">draft.md</span>
#>       </div>
#>     </li>
#>   </ul>
#> </li>
```
