# Update a tree from the server

Update a tree from the server

## Usage

``` r
update_shad_tree(
  id,
  selected = NULL,
  expanded = NULL,
  children = NULL,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- id:

  Input id (namespaced automatically).

- selected:

  Optional character vector of keys to select.

- expanded:

  Optional named list mapping keys to logicals (expand/collapse).

- children:

  Optional list
  `list(value = <parent key>, items = <tagList of [shad_tree_item()]>)`
  to fill a lazy branch (an empty `items` marks it a leaf).

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
[`update_shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_stepper.md)

## Examples

``` r
if (interactive()) {
  ui <- page_shad(
    shad_tree("files", shad_tree_item("data", "data", lazy = TRUE))
  )
  server <- function(input, output, session) {
    # A lazy branch asks for its children the first time it opens.
    shiny::observeEvent(input$files_expanded, {
      event <- input$files_expanded
      if (identical(event$key, "data") && isTRUE(event$expanded)) {
        update_shad_tree("files", children = list(
          value = "data",
          items = htmltools::tagList(
            shad_tree_item("data/a.csv", "a.csv"),
            shad_tree_item("data/b.csv", "b.csv")
          )
        ))
      }
    })
  }
  shiny::shinyApp(ui, server)
}
```
