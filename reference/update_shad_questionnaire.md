# Update a questionnaire from the server

Experimental. Sends only the supplied state facets. `reset = TRUE` calls
the client instance's reset method. Answer and error lists must be named
so module instances and question definitions remain stable.

## Usage

``` r
update_shad_questionnaire(
  id,
  active = NULL,
  answers = NULL,
  errors = NULL,
  reset = FALSE,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- id:

  Input id (namespaced automatically).

- active:

  Optional 1-based active question index.

- answers:

  Optional named answer list.

- errors:

  Optional named question-error list; use `NULL` values to clear.

- reset:

  If `TRUE`, reset active state, answers, skips, errors, and completion.

- session:

  The Shiny session.

## Value

Invisibly `NULL`.

## See also

Other shadshiny questionnaire:
[`shad_question()`](https://orijitghosh.github.io/shadshiny/reference/shad_question.md),
[`shad_questionnaire()`](https://orijitghosh.github.io/shadshiny/reference/shad_questionnaire.md)

## Examples

``` r
if (interactive()) {
  ui <- page_shad(
    shad_questionnaire(
      "survey",
      shad_question("plan", "Choose a plan",
                    choices = c(Free = "free", Pro = "pro")),
      shad_question("notes", "Anything else?", type = "text",
                    required = FALSE)
    ),
    shad_button("Start over", inputId = "restart")
  )
  server <- function(input, output, session) {
    shiny::observeEvent(input$restart, {
      update_shad_questionnaire("survey", reset = TRUE)
    })
  }
  shiny::shinyApp(ui, server)
}
```
