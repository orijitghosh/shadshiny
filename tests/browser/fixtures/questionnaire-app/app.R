library(shiny)
library(shadshiny)

question_set <- function() {
  list(
    shad_question(
      "plan", "Choose a direction", type = "single",
      choices = c(data = "Server table", rtl = "RTL"),
      shortcuts = c(data = "1", rtl = "2")
    ),
    shad_question(
      "features", "Select features", type = "multiple",
      choices = list(
        list(value = "search", label = "Search"),
        list(value = "export", label = "Export")
      )
    ),
    shad_question(
      "notes", "Add notes", type = "text", required = FALSE,
      skippable = TRUE
    ),
    shad_question(
      "details", "Server-table details", type = "text", required = FALSE,
      skippable = TRUE, show_if = list(plan = "data")
    )
  )
}

questionnaire_ui <- function(id, label) {
  ns <- NS(id)
  tagList(
    tags$h2(label),
    do.call(
      shad_questionnaire,
      c(list(inputId = ns("survey")), question_set())
    ),
    shad_button(inputId = ns("set"), "Set notes from server"),
    shad_button(inputId = ns("reset"), "Reset survey", variant = "outline"),
    tags$p(tags$strong("State: "), textOutput(ns("state"), inline = TRUE))
  )
}

ui <- page_shad(
  tags$main(
    style = "max-width: 72rem; margin: 0 auto; padding: 2rem; display: grid; gap: 2rem;",
    tags$h1("Questionnaire workflow fixture"),
    tags$p(
      id = "fixture-description",
      "Two independent module-style questionnaire instances with branching and server updates."
    ),
    tags$section(id = "w1", questionnaire_ui("w1", "Primary questionnaire")),
    tags$section(id = "w2", questionnaire_ui("w2", "Second questionnaire"))
  )
)

questionnaire_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$state <- renderText({
      state <- input$survey
      if (is.null(state)) return("waiting")
      answers <- if (is.null(state$answers)) list() else state$answers
      skipped <- if (is.null(state$skipped)) character() else state$skipped
      paste0(
        "active=", state$active,
        "; complete=", if (isTRUE(state$complete)) "true" else "false",
        "; skipped=", paste(skipped, collapse = ","),
        "; answers=", paste(names(answers), collapse = ",")
      )
    })

    observeEvent(input$set, {
      update_shad_questionnaire(
        "survey", active = 3L, answers = list(notes = "From server"),
        session = session
      )
    })
    observeEvent(input$reset, {
      update_shad_questionnaire("survey", reset = TRUE, session = session)
    })
  })
}

server <- function(input, output, session) {
  questionnaire_server("w1")
  questionnaire_server("w2")
}

shinyApp(ui, server)
