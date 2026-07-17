# Stepper

A multi-step progress indicator with optional content panels. A bound
Shiny input: `input$<inputId>` is the active step index (1-based).
Compose from
[`shad_step()`](https://orijitghosh.github.io/shadshiny/reference/shad_step.md)
children.

## Usage

``` r
shad_stepper(
  inputId,
  ...,
  active = 1,
  orientation = c("horizontal", "vertical"),
  linear = FALSE,
  clickable = TRUE,
  class = NULL
)
```

## Arguments

- inputId:

  Input id.

- ...:

  [`shad_step()`](https://orijitghosh.github.io/shadshiny/reference/shad_step.md)
  entries.

- active:

  Initial active step (1-based).

- orientation:

  `"horizontal"` (default) or `"vertical"`.

- linear:

  If `TRUE`, steps beyond the first incomplete one are gated (not
  clickable).

- clickable:

  If `TRUE`, step triggers are interactive.

- class:

  Extra CSS classes.

## Value

A stepper tag, bound as a Shiny input.

## See also

Other shadshiny flow:
[`shad_dropzone()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropzone.md),
[`shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_number_input.md),
[`shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/shad_rating.md),
[`shad_step()`](https://orijitghosh.github.io/shadshiny/reference/shad_step.md),
[`shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree.md),
[`shad_tree_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree_item.md),
[`update_shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_number_input.md),
[`update_shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_rating.md),
[`update_shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_stepper.md),
[`update_shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_tree.md)

## Examples

``` r
shad_stepper(
  "wizard",
  shad_step("Account", description = "Email + password"),
  shad_step("Profile"),
  shad_step("Review"),
  active = 1
)
#> <div class="shad-stepper" id="wizard" data-shad="stepper" data-orientation="horizontal" data-active="0" data-clickable>
#>   <ol class="shad-stepper__list">
#>     <li class="shad-stepper__item">
#>       <button type="button" class="shad-stepper__trigger">
#>         <span class="shad-stepper__indicator">
#>           <span class="shad-stepper__number">1</span>
#>           <svg class="shad-stepper__check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 12l5 5L20 7" pathLength="1"/></svg>
#>           <svg class="shad-stepper__x" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"/></svg>
#>         </span>
#>         <span class="shad-stepper__meta">
#>           <span class="shad-stepper__label">Account</span>
#>           <span class="shad-stepper__description">Email + password</span>
#>         </span>
#>       </button>
#>       <span class="shad-stepper__connector" aria-hidden="true"></span>
#>     </li>
#>     <li class="shad-stepper__item">
#>       <button type="button" class="shad-stepper__trigger">
#>         <span class="shad-stepper__indicator">
#>           <span class="shad-stepper__number">2</span>
#>           <svg class="shad-stepper__check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 12l5 5L20 7" pathLength="1"/></svg>
#>           <svg class="shad-stepper__x" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18"/></svg>
#>         </span>
#>         <span class="shad-stepper__meta">
#>           <span class="shad-stepper__label">Profile</span>
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
