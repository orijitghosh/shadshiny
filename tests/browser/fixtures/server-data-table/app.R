library(shiny)

`%or%` <- function(x, fallback) {
  if (is.null(x)) fallback else x
}

rows <- data.frame(
  id = sprintf("row-%06d", seq_len(100000L)),
  name = paste("Item", sprintf("%06d", seq_len(100000L))),
  category = rep(c("Alpha", "Beta", "Gamma", "Delta"), length.out = 100000L),
  value = ((seq_len(100000L) * 17L) %% 10000L) / 10,
  status = rep(c("active", "queued", "failed"), length.out = 100000L),
  stringsAsFactors = FALSE
)

columns <- list(
  id = shad_col("ID"),
  name = shad_col("Name"),
  category = shad_col("Category"),
  value = shad_col("Value", format = shad_fmt_number(1)),
  status = shad_col(
    "Status",
    format = shad_fmt_badge(c(active = "default", queued = "secondary", failed = "destructive"))
  )
)

ui <- page_shad(
  tags$main(
    style = "max-width: 72rem; margin: 0 auto; padding: 2rem; display: grid; gap: 1rem;",
    tags$h1("Server-backed data table fixture"),
    tags$p(
      id = "fixture-description",
      "A deterministic 100,000-row source with server-side paging."
    ),
    tags$p(tags$strong("Requests: "), textOutput("request_count", inline = TRUE)),
    tags$p(tags$strong("Last request: "), textOutput("last_request", inline = TRUE)),
    shad_button(inputId = "remove_table", "Remove table"),
    shad_data_table(
      "tbl", data = NULL, columns = columns, row_key = NULL,
      selection = "multiple", filter = "both", page_size = 10,
      page_sizes = c(10, 25, 50), loading = TRUE,
      empty = "No matching rows."
    )
  )
)

server <- function(input, output, session) {
  request_count <- reactiveVal(0L)
  fail_next_error <- TRUE

  source <- function(request) {
    request_count(isolate(request_count()) + 1L)
    global <- trimws(request$filter$global)
    if (identical(tolower(global), "error") && isTRUE(fail_next_error)) {
      fail_next_error <<- FALSE
      stop("fixture backend detail must not reach the browser")
    }

    filtered <- rows
    if (nzchar(global) && !identical(tolower(global), "error")) {
      hit <- Reduce(`|`, lapply(filtered[c("id", "name", "category", "status")],
        function(x) grepl(tolower(global), tolower(x), fixed = TRUE)
      ))
      hit <- hit | grepl(tolower(global), tolower(as.character(filtered$value)), fixed = TRUE)
      filtered <- filtered[hit, , drop = FALSE]
    }
    for (column in names(request$filter$columns)) {
      needle <- trimws(request$filter$columns[[column]])
      if (nzchar(needle) && column %in% names(filtered)) {
        filtered <- filtered[
          grepl(tolower(needle), tolower(as.character(filtered[[column]])), fixed = TRUE),
          , drop = FALSE
        ]
      }
    }

    if (length(request$sort)) {
      for (sort_spec in rev(request$sort)) {
        column <- sort_spec$column
        if (column %in% names(filtered)) {
          order_index <- order(
            filtered[[column]],
            decreasing = identical(sort_spec$direction, "desc"),
            na.last = TRUE,
            method = "radix"
          )
          filtered <- filtered[order_index, , drop = FALSE]
        }
      }
    }

    total <- nrow(rows)
    filtered_total <- nrow(filtered)
    first <- (request$page - 1L) * request$page_size + 1L
    last <- min(first + request$page_size - 1L, filtered_total)
    page <- if (first <= filtered_total) filtered[seq.int(first, last), , drop = FALSE] else filtered[0, , drop = FALSE]
    list(data = page, total_rows = total, filtered_rows = filtered_total)
  }

  shad_data_table_server("tbl", source, columns = columns, row_key = "id", session = session)

  output$request_count <- renderText(request_count())
  output$last_request <- renderText({
    current <- input$tbl
    if (is.null(current)) return("waiting")
    paste0(
      "id=", current$requestId %or% "?",
      "; page=", current$page %or% "?",
      "; size=", current$pageSize %or% "?"
    )
  })

  observeEvent(input$remove_table, {
    removeUI("#tbl", immediate = TRUE)
  })
}

shinyApp(ui, server)
