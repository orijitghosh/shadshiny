# Fixture: every Tier 2 form control on one page, plus buttons that drive the
# server-side update_shad_* API. Used by test-shinytest2-tier2.R.
library(shiny)
library(shadshiny)

ui <- page_shad(
  shad_checkbox("chk", label = "Accept", value = FALSE),
  shad_switch("sw", label = "Notify", value = TRUE),
  shad_radio_group("rg", label = "Plan",
                   choices = c(Free = "free", Pro = "pro"), selected = "free"),
  shad_slider("sl", min = 0, max = 100, value = 30),
  shad_select("sel", label = "Colour",
              choices = c(Red = "red", Green = "green"), selected = "red"),
  shad_combobox("cb", label = "Fruit",
                choices = c(Apple = "apple", Banana = "banana"),
                selected = "apple"),
  shad_toggle_group("tg", choices = c(Left = "left", Right = "right"),
                    type = "single", selected = "left"),
  shad_input_otp("otp", length = 4, groups = c(2, 2)),
  shad_date_picker("dp", label = "Date", value = "2026-07-11"),

  shad_button("do_update", "Update all"),
  verbatimTextOutput("vals")
)

server <- function(input, output, session) {
  output$vals <- renderPrint(reactiveValuesToList(input))

  observeEvent(input$do_update, {
    update_shad_checkbox("chk", value = TRUE)
    update_shad_switch("sw", value = FALSE)
    update_shad_radio_group("rg", selected = "pro")
    update_shad_slider("sl", value = 70)
    update_shad_select("sel", selected = "green")
    update_shad_combobox("cb", selected = "banana")
    update_shad_toggle_group("tg", selected = "right")
    update_shad_input_otp("otp", value = "1234")
    update_shad_date_picker("dp", value = "2026-12-25")
  })
}

shinyApp(ui, server)
