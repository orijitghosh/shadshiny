# Fixture: the interaction-heavy inputs and a dialog inside a Shiny module, to
# confirm ns-qualified update/open helpers work. The server-backed data table
# is rendered by the module's renderUI(), as module UI often is.
library(shiny)
library(shadshiny)

rows <- data.frame(id = sprintf("r%02d", 1:12), name = paste("Item", 1:12),
                   stringsAsFactors = FALSE)

widgetUI <- function(id) {
  ns <- NS(id)
  page_shad(
    shad_select(ns("sel"), label = "Colour",
                choices = c(Red = "red", Green = "green"), selected = "red"),
    shad_combobox(ns("cbx"), label = "Tags", choices = c(Red = "red", Blue = "blue"),
                  selected = "red", multiple = TRUE),
    shad_date_picker(ns("dp"), label = "Due", value = as.Date("2026-10-14")),
    shad_command_palette(ns("cmd"), items = c(Alpha = "alpha", Beta = "beta"),
                         hotkey = NULL),
    shad_dialog(ns("dlg"), trigger = shad_button("Open"), title = "Modal",
                shad_p("Inside a module")),
    shad_button(inputId = ns("set"), "Set green"),
    shad_button(inputId = ns("open"), "Open dialog"),
    shad_button(inputId = ns("open_cmd"), "Open commands"),
    uiOutput(ns("table")),
    verbatimTextOutput(ns("out"))
  )
}

widgetServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$out <- renderPrint(list(sel = input$sel, dlg = input$dlg))
    observeEvent(input$set, {
      update_shad_select("sel", selected = "green")
      update_shad_combobox("cbx", selected = c("red", "blue"), multiple = TRUE)
      update_shad_date_picker("dp", value = as.Date("2026-10-20"))
      update_shad_command("cmd", items = c(Gamma = "gamma"))
    })
    observeEvent(input$open, shad_dialog_open("dlg"))
    observeEvent(input$open_cmd, shad_command_open("cmd"))
    output$table <- renderUI(
      shad_data_table(session$ns("tbl"), data = NULL, page_size = 5, loading = TRUE)
    )
    shad_data_table_server("tbl", function(request) {
      i <- seq((request$page - 1L) * request$page_size + 1L, length.out = request$page_size)
      i <- i[i <= nrow(rows)]
      list(data = rows[i, , drop = FALSE], total_rows = nrow(rows),
           filtered_rows = nrow(rows))
    }, row_key = "id")
  })
}

ui <- widgetUI("w1")
server <- function(input, output, session) widgetServer("w1")

shinyApp(ui, server)
