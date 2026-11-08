# Fixture: the mod+K command palette – trigger, hotkey, activation event, and
# server-side item refresh.
library(shiny)
library(shadshiny)

ui <- page_shad(
  shad_command_trigger("pal"),
  shad_button(inputId = "open_server", "Open from server"),
  shad_button(inputId = "refresh", "Refresh items"),
  shad_command_palette("pal", items = list(
    "Go to" = c(Dashboard = "dashboard", Reports = "reports"),
    "Actions" = list(list(value = "new", label = "New report",
                          keywords = "create"))
  )),
  verbatimTextOutput("state")
)

server <- function(input, output, session) {
  picks <- reactiveVal(character())
  observeEvent(input$pal_event, picks(c(picks(), input$pal_event$value)))
  observeEvent(input$open_server, shad_command_open("pal"))
  observeEvent(input$refresh, {
    update_shad_command("pal", items = c("Recent Q3" = "q3"))
  })
  output$state <- renderPrint(list(value = input$pal, picks = picks()))
  # picks is what the tests read: input$pal alone cannot distinguish one
  # selection of "reports" from two.
  outputOptions(output, "state", suspendWhenHidden = FALSE)
}

shinyApp(ui, server)
