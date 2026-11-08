# A stepper step

A stepper step

## Usage

``` r
shad_step(title, description = NULL, content = NULL, error = FALSE)
```

## Arguments

- title:

  Step label.

- description:

  Optional secondary line.

- content:

  Optional panel content shown when the step is active.

- error:

  If `TRUE`, seed the step in an error state.

## Value

A `shad_step` object consumed by
[`shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/shad_stepper.md).

## See also

Other shadshiny flow:
[`shad_dropzone()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropzone.md),
[`shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_number_input.md),
[`shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/shad_rating.md),
[`shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/shad_stepper.md),
[`shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree.md),
[`shad_tree_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree_item.md),
[`update_shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_number_input.md),
[`update_shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_rating.md),
[`update_shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_stepper.md),
[`update_shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_tree.md)

## Examples

``` r
shad_stepper(
  "checkout",
  shad_step("Cart"),
  shad_step("Payment", description = "Card declined", error = TRUE),
  shad_step("Review"),
  active = 2
)
#> <div class="shad-stepper" id="checkout" data-shad="stepper" data-orientation="horizontal" data-active="1" data-clickable>
#>   <ol class="shad-stepper__list">
#>     <li class="shad-stepper__item">
#>       <button type="button" class="shad-stepper__trigger">
#>         <span class="shad-stepper__indicator">
#>           <span class="shad-stepper__number">1</span>
#>           <svg class="shad-stepper__check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 12l5 5L20 7" pathLength="1"/></svg>
#>           <svg class="shad-stepper__x" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"/></svg>
#>         </span>
#>         <span class="shad-stepper__meta">
#>           <span class="shad-stepper__label">Cart</span>
#>         </span>
#>       </button>
#>       <span class="shad-stepper__connector" aria-hidden="true"></span>
#>     </li>
#>     <li class="shad-stepper__item" data-state="error">
#>       <button type="button" class="shad-stepper__trigger">
#>         <span class="shad-stepper__indicator">
#>           <span class="shad-stepper__number">2</span>
#>           <svg class="shad-stepper__check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 12l5 5L20 7" pathLength="1"/></svg>
#>           <svg class="shad-stepper__x" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"/></svg>
#>         </span>
#>         <span class="shad-stepper__meta">
#>           <span class="shad-stepper__label">Payment</span>
#>           <span class="shad-stepper__description">Card declined</span>
#>         </span>
#>       </button>
#>       <span class="shad-stepper__connector" aria-hidden="true"></span>
#>     </li>
#>     <li class="shad-stepper__item">
#>       <button type="button" class="shad-stepper__trigger">
#>         <span class="shad-stepper__indicator">
#>           <span class="shad-stepper__number">3</span>
#>           <svg class="shad-stepper__check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 12l5 5L20 7" pathLength="1"/></svg>
#>           <svg class="shad-stepper__x" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"/></svg>
#>         </span>
#>         <span class="shad-stepper__meta">
#>           <span class="shad-stepper__label">Review</span>
#>         </span>
#>       </button>
#>     </li>
#>   </ol>
#> </div>
```
