library(shiny)

`%or%` <- function(x, fallback) {
  if (is.null(x)) fallback else x
}

status_output <- function(id, testid) {
  htmltools::tagAppendAttributes(
    shiny::textOutput(id),
    `data-testid` = testid
  )
}

ui <- page_shad(
  htmltools::tags$main(
    style = "max-width: 48rem; margin: 0 auto; padding: 2rem; display: grid; gap: 2rem;",
    htmltools::tags$h1("Behavioral browser fixture"),

    htmltools::tags$section(
      `aria-labelledby` = "state-heading",
      htmltools::tags$h2(id = "state-heading", "Disabled and read-only inputs"),
      shad_stack(
        shad_number_input(
          "qty", label = "Quantity", value = 4, min = 0, max = 10,
          disabled = TRUE
        ),
        htmltools::tags$div(
          shad_button(inputId = "enable_quantity", "Enable quantity")
        ),
        shad_rating("readonly_rating", value = 3, max = 5, readonly = TRUE),
        gap = 3
      )
    ),

    htmltools::tags$section(
      `aria-labelledby` = "updates-heading",
      htmltools::tags$h2(id = "updates-heading", "Server updates"),
      shad_stack(
        shad_checkbox("server_check", label = "Server checkbox", value = FALSE),
        shad_combobox(
          "server_combo", label = "Server fruit",
          choices = c(Apple = "apple", Banana = "banana"),
          selected = "apple"
        ),
        htmltools::tags$div(
          shad_button(inputId = "update_controls", "Update controls")
        ),
        status_output("update_status", "update-status"),
        gap = 3
      )
    ),

    htmltools::tags$section(
      `aria-labelledby` = "choices-heading",
      htmltools::tags$h2(id = "choices-heading", "Choice values"),
      shad_stack(
        shad_select(
          "num_select", label = "Numeric choice",
          choices = c(One = 1, Two = 2, Big = 1e5), selected = 1
        ),
        shad_combobox(
          "multi_combo", label = "Toppings",
          choices = c(Cheese = "cheese", Olives = "olives", Basil = "basil"),
          selected = "cheese", multiple = TRUE
        ),
        shad_stack(
          shad_button(inputId = "send_numeric", "Send numeric values"),
          shad_button(inputId = "send_unknown", "Send unknown values"),
          direction = "horizontal", gap = 2, wrap = TRUE
        ),
        status_output("choice_status", "choice-status"),
        gap = 3
      )
    ),

    htmltools::tags$section(
      `aria-labelledby` = "dates-heading",
      htmltools::tags$h2(id = "dates-heading", "Date values"),
      shad_stack(
        shad_date_picker(
          "due", label = "Due date", value = as.Date("2026-10-14"),
          min = as.Date("2026-10-01"), max = as.Date("2026-10-31")
        ),
        shad_calendar(
          "span", mode = "range", month = as.Date("2026-10-01"),
          min = as.Date("2026-10-01"), max = as.Date("2026-10-31")
        ),
        shad_stack(
          shad_button(inputId = "send_dates", "Send dates"),
          shad_button(inputId = "send_bad_dates", "Send dates outside min/max"),
          direction = "horizontal", gap = 2, wrap = TRUE
        ),
        status_output("date_status", "date-status"),
        gap = 3
      )
    ),

    htmltools::tags$section(
      `aria-labelledby` = "dynamic-heading",
      htmltools::tags$h2(id = "dynamic-heading", "Dynamic UI"),
      shad_stack(
        shad_stack(
          shad_button(inputId = "insert_dynamic", "Insert dynamic select"),
          shad_button(inputId = "remove_dynamic", "Remove dynamic select"),
          direction = "horizontal", gap = 2, wrap = TRUE
        ),
        shiny::uiOutput("dynamic_holder"),
        status_output("dynamic_status", "dynamic-status"),
        gap = 2
      )
    ),

    htmltools::tags$section(
      `aria-labelledby` = "theme-heading",
      htmltools::tags$h2(id = "theme-heading", "Runtime theme"),
      shad_stack(
        shad_stack(
          shad_button(inputId = "apply_theme", "Apply blue dark theme"),
          shad_button(inputId = "reset_theme", "Reset theme"),
          direction = "horizontal", gap = 2, wrap = TRUE
        ),
        status_output("theme_status", "theme-status"),
        gap = 2
      )
    )
  )
)

server <- function(input, output, session) {
  dynamic_visible <- shiny::reactiveVal(FALSE)

  observeEvent(input$enable_quantity, {
    update_shad_number_input("qty", disabled = FALSE)
  })

  observeEvent(input$update_controls, {
    update_shad_checkbox("server_check", value = TRUE)
    update_shad_combobox("server_combo", selected = "banana")
  })

  output$update_status <- renderText({
    paste0(
      "checkbox=", tolower(as.character(isTRUE(input$server_check))),
      "; combobox=", input$server_combo %or% "<none>"
    )
  })

  observeEvent(input$send_numeric, {
    update_shad_select("num_select", 1e5)
    update_shad_combobox("multi_combo", c("olives", "basil"), multiple = TRUE)
  })
  observeEvent(input$send_unknown, {
    update_shad_select("num_select", "zzz")
    update_shad_combobox("multi_combo", c("basil", "anchovy"), multiple = TRUE)
  })

  observeEvent(input$send_dates, {
    update_shad_date_picker("due", as.Date("2026-10-20"))
    # reversed on purpose: the calendar puts a range in order
    update_shad_calendar("span", as.Date(c("2026-10-12", "2026-10-05")))
  })
  observeEvent(input$send_bad_dates, {
    update_shad_date_picker("due", as.Date("2026-11-15"))
    update_shad_calendar("span", as.Date(c("2026-09-25", "2026-10-03")))
  })

  output$date_status <- renderText({
    span <- if (length(input$span)) paste(format(input$span), collapse = "..") else "<none>"
    paste0("due=", format(input$due %or% "<none>"), "; span=", span)
  })

  output$choice_status <- renderText({
    paste0(
      "select=", input$num_select %or% "<none>",
      " (", class(input$num_select)[[1]], ")",
      "; combo=", paste(input$multi_combo, collapse = ",")
    )
  })

  observeEvent(input$insert_dynamic, dynamic_visible(TRUE))
  observeEvent(input$remove_dynamic, dynamic_visible(FALSE))

  output$dynamic_holder <- renderUI({
    if (!dynamic_visible()) return(NULL)
    shad_select(
      "dynamic_choice", label = "Dynamic choice",
      choices = c(Alpha = "alpha", Beta = "beta"), selected = "alpha"
    )
  })

  output$dynamic_status <- renderText({
    paste0("dynamic=", input$dynamic_choice %or% "<none>")
  })

  observeEvent(input$apply_theme, {
    update_shad_theme(preset = "blue", dark = TRUE)
  })
  observeEvent(input$reset_theme, {
    update_shad_theme(preset = "default", dark = FALSE)
  })

  output$theme_status <- renderText({
    theme <- input$.shad_theme
    if (is.null(theme)) return("preset=default; dark=false")
    paste0(
      "preset=", theme$preset %or% "default",
      "; dark=", tolower(as.character(isTRUE(theme$dark)))
    )
  })
}

shinyApp(ui, server)
