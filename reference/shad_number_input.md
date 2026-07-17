# Number input with stepper buttons

A numeric input flanked by decrement/increment buttons (hold to repeat,
Shift for ×10). A bound Shiny input: `input$<inputId>` is the numeric
value (`NULL` while the field is empty/invalid, mirroring
[`shiny::numericInput()`](https://rdrr.io/pkg/shiny/man/numericInput.html)).
A drop-in restyle of
[`numericInput()`](https://rdrr.io/pkg/shiny/man/numericInput.html).

## Usage

``` r
shad_number_input(
  inputId,
  label = NULL,
  value = 0,
  min = NA,
  max = NA,
  step = 1,
  precision = NULL,
  disabled = FALSE,
  width = NULL,
  class = NULL,
  ...
)
```

## Arguments

- inputId:

  Input id.

- label:

  Optional label (wraps in
  [`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)).

- value:

  Initial value.

- min, max:

  Optional numeric bounds (`NA` = unbounded); buttons disable at the
  bounds.

- step:

  Increment (default 1; decimals allowed).

- precision:

  Display decimal places (default: inferred from `step`).

- disabled:

  If `TRUE`, disable the control.

- width:

  CSS width.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the root.

## Value

A number-stepper tag, bound as a Shiny input.

## See also

Other shadshiny flow:
[`shad_dropzone()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropzone.md),
[`shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/shad_rating.md),
[`shad_step()`](https://orijitghosh.github.io/shadshiny/reference/shad_step.md),
[`shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/shad_stepper.md),
[`shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree.md),
[`shad_tree_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree_item.md),
[`update_shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_number_input.md),
[`update_shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_rating.md),
[`update_shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_stepper.md),
[`update_shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_tree.md)

## Examples

``` r
shad_number_input("qty", value = 2, min = 0, max = 10)
#> <div class="shad-input-group shad-number-stepper" id="qty" data-shad="number-stepper" data-min="0" data-max="10" data-step="1">
#>   <input class="shad-input" type="text" inputmode="decimal" value="2" aria-label="Number"/>
#>   <button type="button" class="shad-number-stepper__btn shad-number-stepper__btn--dec" aria-label="Decrease"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M5 12h14"/></svg></button>
#>   <button type="button" class="shad-number-stepper__btn shad-number-stepper__btn--inc" aria-label="Increase"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14"/></svg></button>
#> </div>
shad_number_input("dose", value = 1.5, min = 0, max = 5, step = 0.25)
#> <div class="shad-input-group shad-number-stepper" id="dose" data-shad="number-stepper" data-min="0" data-max="5" data-step="0.25">
#>   <input class="shad-input" type="text" inputmode="decimal" value="1.5" aria-label="Number"/>
#>   <button type="button" class="shad-number-stepper__btn shad-number-stepper__btn--dec" aria-label="Decrease"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M5 12h14"/></svg></button>
#>   <button type="button" class="shad-number-stepper__btn shad-number-stepper__btn--inc" aria-label="Increase"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14"/></svg></button>
#> </div>
```
