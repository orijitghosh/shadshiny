# Fixture: a Tier 2 input and a dialog inside a Shiny module, to confirm
# ns-qualified update/open helpers work.
library(shiny)
library(shadshiny)

widgetUI <- function(id) {
  ns <- NS(id)
  page_shad(
    shad_select(ns("sel"), label = "Colour",
                choices = c(Red = "red", Green = "green"), selected = "red"),
    shad_dialog(ns("dlg"), trigger = shad_button("Open"), title = "Modal",
                shad_p("Inside a module")),
    shad_button(inputId = ns("set"), "Set green"),
    shad_button(inputId = ns("open"), "Open dialog"),
    verbatimTextOutput(ns("out"))
  )
}

widgetServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$out <- renderPrint(list(sel = input$sel, dlg = input$dlg))
    observeEvent(input$set, update_shad_select("sel", selected = "green"))
    observeEvent(input$open, shad_dialog_open("dlg"))
  })
}

ui <- widgetUI("w1")
server <- function(input, output, session) widgetServer("w1")

shinyApp(ui, server)
