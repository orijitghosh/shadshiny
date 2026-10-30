library(shiny)
library(shadshiny)

ui <- page_shad(
  title = "Field family",
  shad_fieldset(
    "Shipping",
    description = "Where the order will be sent.",
    class = "shipping-fieldset",
    `data-testid` = "shipping-fieldset",
    shad_field_group(
      shad_form_field(
        shad_input("street", value = "", placeholder = "123 Main Street"),
        label = "Street",
        description = "Include the building number."
      ),
      shad_form_field(
        shad_input("city", value = "Springfield"),
        label = "City"
      ),
      orientation = "responsive",
      class = "responsive-fields",
      `data-testid` = "responsive-group"
    )
  ),
  shad_fieldset(
    "Preferences",
    variant = "label",
    shad_field_group(
      shad_form_field(
        shad_input("nickname", value = "Sam"),
        label = "Nickname"
      ),
      shad_field_separator("Optional"),
      shad_form_field(
        shad_input("company", value = "Acme"),
        label = "Company"
      ),
      orientation = "vertical"
    )
  ),
  shad_fieldset(
    "معلومات الشحن",
    dir = "rtl",
    style = "width: 48rem;",
    class = "rtl-fieldset",
    `data-testid` = "rtl-fieldset",
    shad_field_group(
      shad_form_field(
        shad_input("rtl_city", value = "القاهرة"),
        label = "المدينة"
      ),
      orientation = "horizontal"
    )
  ),
  tags$div(`data-testid` = "validation-status", textOutput("validation_status")),
  shad_button("Validate fields", inputId = "validate")
)

server <- function(input, output, session) {
  validator <- shad_validator(session)
  validator$add_rule("street", shad_rule_required(), label = "Street")

  observeEvent(input$validate, {
    ok <- validator$validate()
    output$validation_status <- renderText(if (isTRUE(ok)) "valid" else "invalid")
  })

  output$validation_status <- renderText("not-validated")
}

shinyApp(ui, server)
