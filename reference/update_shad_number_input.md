# Update a number input from the server

Update a number input from the server

## Usage

``` r
update_shad_number_input(
  id,
  value = NULL,
  min = NULL,
  max = NULL,
  step = NULL,
  disabled = NULL,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- id:

  Input id (namespaced automatically).

- value:

  Optional new value.

- min, max, step:

  Optional numeric attribute patches.

- disabled:

  Optional logical.

- session:

  The Shiny session.

## Value

Invisibly `NULL`.

## See also

Other shadshiny flow:
[`shad_dropzone()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropzone.md),
[`shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_number_input.md),
[`shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/shad_rating.md),
[`shad_step()`](https://orijitghosh.github.io/shadshiny/reference/shad_step.md),
[`shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/shad_stepper.md),
[`shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree.md),
[`shad_tree_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree_item.md),
[`update_shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_rating.md),
[`update_shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_stepper.md),
[`update_shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_tree.md)

## Examples

``` r
if (interactive()) {
  ui <- page_shad(
    shad_number_input("qty", "Quantity", value = 1, min = 1, max = 10),
    shad_switch("bulk", "Bulk order")
  )
  server <- function(input, output, session) {
    shiny::observeEvent(input$bulk, {
      if (isTRUE(input$bulk)) {
        update_shad_number_input("qty", value = 10, max = 100, step = 10)
      } else {
        update_shad_number_input("qty", value = 1, max = 10, step = 1)
      }
    })
  }
  shiny::shinyApp(ui, server)
}
```
