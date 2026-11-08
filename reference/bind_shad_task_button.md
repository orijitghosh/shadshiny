# Bind an ExtendedTask status to a shadshiny button

Experimental. Observes a compatible Shiny
[shiny::ExtendedTask](https://rdrr.io/pkg/shiny/man/ExtendedTask.html)
status function and maps its lifecycle to
[`update_shad_button()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md).
The task remains application-owned; this helper does not invoke the
task, inspect its result, or create an async backend.

## Usage

``` r
bind_shad_task_button(
  task,
  id,
  label_busy = "Processing...",
  label_success = NULL,
  label_error = NULL,
  session = shiny::getDefaultReactiveDomain()
)
```

## Arguments

- task:

  An object with a callable `$status()` member returning `"initial"`,
  `"running"`, `"success"`, or `"error"`.

- id:

  Button input id.

- label_busy:

  Label while the task is running.

- label_success:

  Optional label after success.

- label_error:

  Optional label after an error.

- session:

  The Shiny session.

## Value

Invisibly, the observer driving the binding.

## See also

Other shadshiny server API:
[`shad_message_scroller_to_bottom()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller_to_bottom.md),
[`shad_overlay_server`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_remove_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_remove_dialog.md),
[`shad_show_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_show_dialog.md),
[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md),
[`update_shad`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_command()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_command.md)

## Examples

``` r
if (interactive()) {
  ui <- page_shad(
    shad_button("Run report", inputId = "run"),
    shad_button("Finish", inputId = "finish", variant = "outline")
  )
  server <- function(input, output, session) {
    # Usually a shiny::ExtendedTask; any object with a $status() works.
    state <- shiny::reactiveVal("initial")
    task <- list(status = function() state())
    bind_shad_task_button(task, "run", label_success = "Done")
    shiny::observeEvent(input$run, state("running"))
    shiny::observeEvent(input$finish, state("success"))
  }
  shiny::shinyApp(ui, server)
}
```
