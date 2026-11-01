# Fixture: components inserted, removed and re-rendered by renderUI.
# - A shad_select inserted after a click still binds, and update_shad_select
#   works on it (autoInit + fallback path).
# - The five interaction-heavy components, the data table server-backed,
#   shown, hidden and re-rendered by `input$phase`, with server updates for
#   each, so popups and dialogs open at removal can be checked for leftovers.
library(shiny)
library(shadshiny)

rows <- data.frame(id = sprintf("r%02d", 1:30), name = paste("Item", 1:30),
                   stringsAsFactors = FALSE)

suite <- function() {
  tagList(
    shad_select("l_sel", label = "Fruit",
                choices = c(Apple = "a", Banana = "b"), selected = "a"),
    shad_combobox("l_cbx", label = "Tags", choices = c(Red = "red", Blue = "blue"),
                  selected = "red", multiple = TRUE),
    shad_date_picker("l_dp", label = "Due", value = as.Date("2026-10-14")),
    shad_command_palette("l_cmd", items = c(Alpha = "alpha", Beta = "beta")),
    shad_data_table("l_tbl", data = NULL, page_size = 10, loading = TRUE,
                    column_visibility = TRUE)
  )
}

ui <- page_shad(
  shad_button(inputId = "add", "Add select"),
  uiOutput("holder"),
  shad_button(inputId = "set_b", "Set to B"),
  verbatimTextOutput("val"),
  uiOutput("suite")
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

  # "show", "hide" or "again" (render anew while shown)
  shown <- reactiveVal(FALSE)
  generation <- reactiveVal(0L)
  observeEvent(input$phase, {
    if (input$phase == "again") generation(generation() + 1L)
    else shown(input$phase == "show")
  })
  output$suite <- renderUI({
    generation()
    if (shown()) suite()
  })

  observeEvent(input$update, {
    update_shad_select("l_sel", selected = "b")
    update_shad_combobox("l_cbx", selected = c("red", "blue"), multiple = TRUE)
    update_shad_date_picker("l_dp", value = as.Date("2026-10-20"))
    update_shad_command("l_cmd", items = c(Gamma = "gamma"))
  })

  shad_data_table_server("l_tbl", function(request) {
    i <- seq((request$page - 1L) * request$page_size + 1L, length.out = request$page_size)
    i <- i[i <= nrow(rows)]
    list(data = rows[i, , drop = FALSE], total_rows = nrow(rows),
         filtered_rows = nrow(rows))
  }, row_key = "id")
}

shinyApp(ui, server)
