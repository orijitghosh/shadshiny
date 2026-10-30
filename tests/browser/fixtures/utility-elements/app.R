library(shiny)

ui <- page_shad(
  htmltools::tags$main(
    style = "max-width: 60rem; margin: 0 auto; padding: 2rem; display: grid; gap: 2rem;",
    htmltools::tags$h1("Utility elements"),

    htmltools::tags$section(
      `aria-labelledby` = "keys-heading",
      htmltools::tags$h2(id = "keys-heading", "Keyboard and loading"),
      shad_kbd_group(shad_kbd("Ctrl"), shad_kbd("K"), `data-testid` = "kbd-group"),
      htmltools::tags$p(
        "Inactive: ", shad_shimmer("Ready", active = FALSE, `data-testid` = "shimmer-inactive"),
        " Active: ", shad_shimmer("Loading", `data-testid` = "shimmer-active")
      )
    ),

    htmltools::tags$section(
      `aria-labelledby` = "code-heading",
      htmltools::tags$h2(id = "code-heading", "Code"),
      shad_code_block(
        '<script>alert("x")</script>\nconst value = "safe";\n',
        language = "html", filename = "demo.html", copy = TRUE,
        line_numbers = TRUE, class = "fixture-code"
      ),
      shad_code_block(
        "copy failure sample", language = "text", filename = "failure.txt",
        copy = TRUE, line_numbers = FALSE, class = "failure-code"
      )
    ),

    htmltools::tags$section(
      `aria-labelledby` = "scroll-heading",
      htmltools::tags$h2(id = "scroll-heading", "Scroll fades"),
      shad_scroll_fade(
        htmltools::tags$div(
          style = "height: 24rem; display: grid; align-content: start; gap: 1rem;",
          lapply(seq_len(18), function(i) htmltools::tags$p(paste("Keyboard-scroll row", i)))
        ),
        axis = "vertical", class = "fixture-scroll", style = "height: 12rem;",
        `data-testid` = "vertical-fade",
        `aria-label` = "Vertical scroll example"
      ),
      shad_scroll_fade(
        htmltools::tags$div(
          style = "width: 90rem; white-space: nowrap;",
          "A long horizontal line for keyboard scrolling and overflow verification."
        ),
        axis = "horizontal", class = "fixture-horizontal", `data-testid` = "horizontal-fade",
        `aria-label` = "Horizontal scroll example"
      ),
      htmltools::tags$div(
        dir = "rtl",
        shad_scroll_fade(
          htmltools::tags$div(
            style = "width: 90rem; height: 24rem;",
            "RTL both-axis content"
          ),
          axis = "both", class = "fixture-both", style = "height: 12rem;",
          `data-testid` = "both-fade",
          `aria-label` = "RTL both-axis scroll example"
        )
      )
    ),

    shad_button(inputId = "dark_mode", "Toggle dark mode")
  ),
  title = "Utility elements"
)

server <- function(input, output, session) {
  observeEvent(input$dark_mode, {
    update_shad_theme(dark = TRUE)
  })
}

shinyApp(ui, server)
