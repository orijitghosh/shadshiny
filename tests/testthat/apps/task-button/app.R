library(shiny)
library(shadshiny)

ui <- fluidPage(
  shad_button("Run", inputId = "run"),
  selectInput("mode", "Mode", choices = c(success = "success", error = "error")),
  textOutput("status"),
  textOutput("invocations")
)

server <- function(input, output, session) {
  task <- shiny::ExtendedTask$new(function(mode) {
    promises::promise(function(resolve, reject) {
      later::later(function() {
        if (identical(mode, "error")) {
          reject(simpleError("deterministic task failure"))
        } else {
          resolve("deterministic task success")
        }
      }, delay = 0.5)
    })
  })
  invocations <- reactiveVal(0L)

  bind_shad_task_button(
    task, "run", label_busy = "Processing...",
    label_success = "Complete", label_error = "Try again", session = session
  )
  observeEvent(input$run, {
    invocations(invocations() + 1L)
    task$invoke(input$mode)
  }, ignoreInit = TRUE)

  output$status <- renderText(task$status())
  output$invocations <- renderText(invocations())
}

shinyApp(ui, server)
