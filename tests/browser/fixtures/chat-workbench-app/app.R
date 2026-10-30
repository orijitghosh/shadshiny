library(shiny)
library(shadshiny)

ui <- page_shad(
  title = "Structured chat workbench",
  shad_chat_workbench_ui(
    "workbench", welcome = "Safe offline provider", accept = ".txt"
  ),
  shad_button("Retry response", inputId = "retry_response"),
  shad_button("Clear transcript", inputId = "clear_transcript")
)

server <- function(input, output, session) {
  attempts <- shiny::reactiveVal(0L)
  workbench <- shad_chat_workbench_server("workbench", function(prompt, history) {
    text <- prompt$text
    if (identical(text, "fail")) stop("operator diagnostics")
    if (identical(text, "cancel")) {
      index <- 0L
      return(function() {
        index <<- index + 1L
        if (index == 1L) {
          list(type = "text_delta", text = "Started")
        } else {
          list(type = "status", text = "Still working")
        }
      })
    }
    if (identical(text, "hostile")) {
      return(list(
        list(type = "text_delta", text = "<img src=x onerror=\"hostile\">"),
        list(type = "source", title = "<script>hostile</script>", url = "https://example.org/safe"),
        list(type = "tool", id = "hostile-tool", name = "<b>lookup</b>", status = "success",
             input = list(query = "<script>hostile</script>"), output = "<img src=x>"),
        list(type = "status", text = "Public summary only"),
        list(type = "done")
      ))
    }
    attempt <- attempts() + 1L
    attempts(attempt)
    if (attempt > 1L) {
      return(list(
        list(type = "text_delta", text = paste("Retry:", text)),
        list(type = "done")
      ))
    }
    parts <- list(
      list(type = "text_delta", text = paste("Echo:", text)),
      list(type = "source", title = "Documentation", url = "https://example.org/docs"),
      list(type = "source", title = "Reference", url = "https://example.org/reference"),
      list(type = "tool", id = "lookup", name = "lookup", status = "pending",
           input = list(query = text)),
      list(type = "tool", id = "lookup", name = "lookup", status = "running"),
      list(type = "tool", id = "lookup", name = "lookup", status = "success",
           output = "complete"),
      list(type = "status", text = "Public summary only")
    )
    if (length(prompt$attachments)) {
      file <- prompt$attachments[[1L]]
      parts[[length(parts) + 1L]] <- list(
        type = "attachment", name = file$name, size = file$size, mime = file$type
      )
    }
    c(parts, list(list(type = "done")))
  })

  observeEvent(input$retry_response, {
    messages <- workbench$messages()
    assistant <- vapply(messages, function(message) identical(message$role, "assistant"), logical(1))
    index <- which(assistant)
    if (length(index)) workbench$retry(messages[[index[[length(index)]]]]$id)
  })
  observeEvent(input$clear_transcript, workbench$clear())
}

shinyApp(ui, server)
