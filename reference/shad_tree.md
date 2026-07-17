# Tree view

A file-explorer tree (APG TreeView) with keyboard navigation, single or
multiple selection, and optional lazy branches. A bound Shiny input:
`input$<inputId>` is the character vector of selected keys. Expanding a
lazy branch fires `input$<inputId>_expanded` (a list with `key`,
`expanded`, and a `nonce`); answer it with
`update_shad_tree(children=)`. Compose from
[`shad_tree_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree_item.md).

## Usage

``` r
shad_tree(
  inputId,
  ...,
  selected = NULL,
  selection = c("single", "multiple"),
  label = "Tree",
  class = NULL
)
```

## Arguments

- inputId:

  Input id.

- ...:

  [`shad_tree_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree_item.md)
  entries, plus optional named attributes.

- selected:

  Character vector of initially selected keys.

- selection:

  `"single"` (default) or `"multiple"`.

- label:

  Accessible label for the tree.

- class:

  Extra CSS classes.

## Value

A tree tag, bound as a Shiny input.

## See also

Other shadshiny flow:
[`shad_dropzone()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropzone.md),
[`shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_number_input.md),
[`shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/shad_rating.md),
[`shad_step()`](https://orijitghosh.github.io/shadshiny/reference/shad_step.md),
[`shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/shad_stepper.md),
[`shad_tree_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree_item.md),
[`update_shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_number_input.md),
[`update_shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_rating.md),
[`update_shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_stepper.md),
[`update_shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_tree.md)

## Examples

``` r
shad_tree(
  "files",
  shad_tree_item("src", "src", expanded = TRUE,
    shad_tree_item("src/app.R", "app.R"),
    shad_tree_item("src/utils.R", "utils.R")
  ),
  shad_tree_item("data", "data", lazy = TRUE)
)
#> <div class="shad-tree" id="files" data-shad="tree" data-selection="single">
#>   <ul class="shad-tree__list" role="tree" aria-label="Tree">
#>     <li class="shad-tree__item" role="treeitem" data-key="src" aria-expanded="true">
#>       <div class="shad-tree__row">
#>         <svg class="shad-tree__chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 6l6 6-6 6"/></svg>
#>         <span class="shad-tree__icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg></span>
#>         <span class="shad-tree__label">src</span>
#>       </div>
#>       <ul class="shad-tree__group" role="group">
#>         <li class="shad-tree__item" role="treeitem" data-key="src/app.R">
#>           <div class="shad-tree__row">
#>             <svg class="shad-tree__chevron shad-tree__chevron--leaf" viewBox="0 0 24 24" aria-hidden="true"><path d="M9 6l6 6-6 6"/></svg>
#>             <span class="shad-tree__icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/></svg></span>
#>             <span class="shad-tree__label">app.R</span>
#>           </div>
#>         </li>
#>         <li class="shad-tree__item" role="treeitem" data-key="src/utils.R">
#>           <div class="shad-tree__row">
#>             <svg class="shad-tree__chevron shad-tree__chevron--leaf" viewBox="0 0 24 24" aria-hidden="true"><path d="M9 6l6 6-6 6"/></svg>
#>             <span class="shad-tree__icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/></svg></span>
#>             <span class="shad-tree__label">utils.R</span>
#>           </div>
#>         </li>
#>       </ul>
#>     </li>
#>     <li class="shad-tree__item" role="treeitem" data-key="data" aria-expanded="false" data-lazy>
#>       <div class="shad-tree__row">
#>         <svg class="shad-tree__chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 6l6 6-6 6"/></svg>
#>         <span class="shad-tree__icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg></span>
#>         <span class="shad-tree__label">data</span>
#>       </div>
#>     </li>
#>   </ul>
#> </div>
```
