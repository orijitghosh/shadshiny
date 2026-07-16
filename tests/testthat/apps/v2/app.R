# Fixture: the V2 bound inputs on one page, plus buttons driving their
# update_shad_* API. Used by test-shinytest2-v2.R.
library(shiny)
library(shadshiny)

cars <- data.frame(
  model = rownames(mtcars)[1:8],
  mpg   = mtcars$mpg[1:8],
  cyl   = mtcars$cyl[1:8],
  stringsAsFactors = FALSE
)

ui <- page_shad(
  shad_data_table("tbl", cars, selection = "multiple", filter = "global",
                  page_size = 5),
  shad_rating("rate", value = 2, max = 5),
  shad_number_input("num", value = 4, min = 0, max = 10, step = 1),
  shad_stepper(
    "step",
    shad_step("One"), shad_step("Two"), shad_step("Three"),
    active = 1
  ),
  shad_tree(
    "tree",
    shad_tree_item("fruit", "Fruit", expanded = TRUE,
                   shad_tree_item("apple", "Apple"),
                   shad_tree_item("pear", "Pear")),
    shad_tree_item("veg", "Veg")
  ),

  shad_button(inputId = "do_update", "Update all"),
  verbatimTextOutput("vals")
)

server <- function(input, output, session) {
  output$vals <- renderPrint(reactiveValuesToList(input))

  observeEvent(input$do_update, {
    update_shad_rating("rate", value = 4)
    update_shad_number_input("num", value = 7)
    update_shad_stepper("step", active = 2)
    update_shad_tree("tree", selected = "pear")
    update_shad_data_table("tbl", selected = c(1, 3))
  })
}

shinyApp(ui, server)
