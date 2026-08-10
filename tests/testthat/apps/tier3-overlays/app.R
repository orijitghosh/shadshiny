# Fixture: dialog + alert-dialog + sheet, driven from the server.
library(shiny)
library(shadshiny)

ui <- page_shad(
  shad_dialog("dlg", trigger = shad_button("Open dialog"), title = "Edit",
              shad_input("dlg_name", label = "Name", value = "Ada"),
              footer = shad_dialog_close_button("Close")),
  shad_alert_dialog("ad", trigger = shad_button("Delete", variant = "destructive"),
                    title = "Are you sure?", description = "This cannot be undone.",
                    action = "Delete", action_variant = "destructive"),
  shad_sheet("sh", side = "right", trigger = shad_button("Open sheet"),
             title = "Panel", shad_p("Sheet body")),

  shad_button(inputId = "open_dlg", "Open via server"),
  shad_button(inputId = "close_dlg", "Close via server"),
  shad_button(inputId = "show_made", "Show server-created"),
  shad_button(inputId = "show_kept", "Show server-created (kept)"),
  shad_button(inputId = "remove_made", "Remove server-created"),
  verbatimTextOutput("state")
)

server <- function(input, output, session) {
  output$state <- renderPrint(list(dlg = input$dlg, ad = input$ad,
                                    sh = input$sh, ad_confirm = input$ad_confirm))
  observeEvent(input$open_dlg, shad_dialog_open("dlg"))
  observeEvent(input$close_dlg, shad_dialog_close("dlg"))

  observeEvent(input$show_made, {
    shad_show_dialog(shad_dialog("made", title = "Made on the server",
      shad_input("made_name", label = "Name", value = "Grace"),
      footer = shad_dialog_close_button("Close")))
  })
  observeEvent(input$show_kept, {
    shad_show_dialog(shad_dialog("keptdlg", title = "Kept",
      footer = shad_dialog_close_button("Close")), transient = FALSE)
  })
  observeEvent(input$remove_made, shad_remove_dialog("made"))
}

shinyApp(ui, server)
