# Fixture: a shad_select inserted via renderUI after a click still binds, and
# update_shad_select works on it (autoInit + fallback path).
library(shiny)
library(shadshiny)

ui <- page_shad(
  shad_button("add", "Add select"),
  uiOutput("holder"),
  shad_button("set_b", "Set to B"),
  verbatimTextOutput("val")
)

server <- function(input, output, session) {
  output$val <- renderPrint(input$dyn)

  observeEvent(input$add, {
    output$holder <- renderUI(
      shad_select("dyn", label = "Dynamic",
                  choices = c(A = "a", B = "b"), selected = "a")
    )
  })

  observeEvent(input$set_b, update_shad_select("dyn", selected = "b"))
}

shinyApp(ui, server)
