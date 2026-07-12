# Fixture: tabs, accordion, pagination, carousel, collapsible round trips.
library(shiny)
library(shadshiny)

ui <- page_shad(
  shad_tabs("tabs", selected = "one",
    shad_tab("one", "One", shad_p("First")),
    shad_tab("two", "Two", shad_p("Second"))),
  shad_accordion("acc", type = "single",
    shad_accordion_item("a1", "Section 1", shad_p("Body 1")),
    shad_accordion_item("a2", "Section 2", shad_p("Body 2"))),
  shad_pagination("pg", pages = 5, selected = 1),
  shad_carousel("car",
    shad_carousel_item(shad_p("Slide 1")),
    shad_carousel_item(shad_p("Slide 2"))),

  shad_button(inputId = "go", "Advance all"),
  verbatimTextOutput("state")
)

server <- function(input, output, session) {
  output$state <- renderPrint(list(tabs = input$tabs, acc = input$acc,
                                    pg = input$pg, car = input$car))
  observeEvent(input$go, {
    update_shad_tabs("tabs", selected = "two")
    update_shad_accordion("acc", value = "a2")
    update_shad_pagination("pg", selected = 3)
    update_shad_carousel("car", selected = 2)
  })
}

shinyApp(ui, server)
