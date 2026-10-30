library(shiny)
library(shadshiny)

questions <- list(
  shad_question(
    "plan", "Choose a direction", type = "single",
    choices = c(data = "Server table", rtl = "RTL")
  ),
  shad_question(
    "features", "Select features", type = "multiple",
    choices = list(
      list(value = "search", label = "Search"),
      list(value = "export", label = "Export")
    )
  ),
  shad_question("notes", "Add notes", type = "text", required = FALSE, skippable = TRUE),
  shad_question(
    "details", "Server-table details", type = "text", required = FALSE,
    skippable = TRUE, show_if = list(plan = "data")
  )
)

ui <- fluidPage(
  do.call(shad_questionnaire, c(list(inputId = "survey"), questions)),
  actionButton("set_server", "Set from server"),
  actionButton("reset", "Reset"),
  verbatimTextOutput("state")
)

server <- function(input, output, session) {
  output$state <- renderPrint(input$survey)
  observeEvent(input$set_server, {
    update_shad_questionnaire(
      "survey", active = 3L, answers = list(notes = "From server"), session = session
    )
  })
  observeEvent(input$reset, update_shad_questionnaire("survey", reset = TRUE, session = session))
}

shinyApp(ui, server)
