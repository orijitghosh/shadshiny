# Fixture: toast lifecycle — raise, variant, dismiss, loading -> success.
library(shiny)
library(shadshiny)

ui <- page_shad(
  shad_button("success", "Success toast"),
  shad_button("error", "Error toast"),
  shad_button("dismiss", "Dismiss all"),
  shad_button("flow", "Loading -> success")
)

server <- function(input, output, session) {
  observeEvent(input$success,
               shad_toast_success("Saved", description = "All good", id = "s1"))
  observeEvent(input$error, shad_toast_error("Failed", id = "e1"))
  observeEvent(input$dismiss, shad_toast_dismiss())
  observeEvent(input$flow, {
    id <- shad_toast_loading("Working", id = "flow1")
    shad_toast_update(id, message = "Done", variant = "success")
  })
}

shinyApp(ui, server)
