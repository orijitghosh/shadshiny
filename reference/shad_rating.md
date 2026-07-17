# Star rating

A star-rating input. A bound Shiny input: `input$<inputId>` is the
numeric rating (0 = unset). Stars are built client-side; half steps are
supported.

## Usage

``` r
shad_rating(
  inputId,
  label = NULL,
  value = 0,
  max = 5,
  half = FALSE,
  readonly = FALSE,
  size = c("md", "sm", "lg"),
  disabled = FALSE,
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

  Initial rating (0 = unset).

- max:

  Number of stars.

- half:

  If `TRUE`, allow half-star (0.5) steps.

- readonly:

  If `TRUE`, render display-only (no tab stops; `role="img"`).

- size:

  `"md"` (default), `"sm"`, or `"lg"`.

- disabled:

  If `TRUE`, disable the control.

- class:

  Extra CSS classes.

- ...:

  Extra attributes on the root.

## Value

A rating tag, bound as a Shiny input.

## See also

Other shadshiny flow:
[`shad_dropzone()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropzone.md),
[`shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_number_input.md),
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
shad_rating("score", value = 3)
#> <div class="shad-rating" id="score" data-shad="rating" role="radiogroup" data-value="3" data-max="5"></div>
shad_rating("precise", value = 4.5, half = TRUE)
#> <div class="shad-rating" id="precise" data-shad="rating" role="radiogroup" data-value="4.5" data-max="5" data-half></div>
```
