# Update a stepper from the server

Update a stepper from the server

## Usage

``` r
update_shad_stepper(
  id,
  active = NULL,
  error = NULL,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- id:

  Input id (namespaced automatically).

- active:

  Optional new active step (1-based).

- error:

  Optional named list mapping step index (1-based) to a logical: `TRUE`
  marks that step as an error, `FALSE` clears it.

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
[`update_shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_number_input.md),
[`update_shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_rating.md),
[`update_shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_tree.md)

## Examples

``` r
if (interactive()) {
  ui <- page_shad(
    shad_stepper("wizard", shad_step("Account"), shad_step("Profile"),
                 shad_step("Review")),
    shad_button("Continue", inputId = "forward")
  )
  server <- function(input, output, session) {
    step <- shiny::reactiveVal(1)
    shiny::observeEvent(input$forward, {
      step(min(step() + 1, 3))
      update_shad_stepper("wizard", active = step())
    })
  }
  shiny::shinyApp(ui, server)
}
```
