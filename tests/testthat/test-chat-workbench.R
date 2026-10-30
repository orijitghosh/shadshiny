# Structured chat workbench contracts -----------------------------------------

test_that("structured events validate public boundaries", {
  source <- shadshiny:::.shad_chat_event(
    "source", title = "Documentation", url = "https://example.org/docs"
  )
  expect_identical(source$type, "source")
  expect_identical(source$title, "Documentation")
  expect_error(
    shadshiny:::.shad_chat_event("source", title = "Bad", url = "javascript:alert(1)"),
    "http"
  )
  expect_error(
    shadshiny:::.shad_chat_event("private_reasoning", text = "never render this"),
    "Unknown chat event type"
  )
  expect_error(
    shadshiny:::.shad_chat_event("tool", id = "search-1", name = "search", status = "secret"),
    "tool status"
  )
  expect_error(
    shadshiny:::.shad_chat_event("attachment", name = "x", size = list(1), type = "text/plain"),
    "size"
  )
})

test_that("the pure reducer coalesces deltas and upserts tool lifecycle", {
  message <- shadshiny:::.shad_chat_message("assistant", id = "answer-1")
  message <- shadshiny:::.shad_chat_reduce(
    message, shadshiny:::.shad_chat_event("text_delta", text = "Result")
  )
  message <- shadshiny:::.shad_chat_reduce(
    message, shadshiny:::.shad_chat_event("text_delta", text = " found")
  )
  message <- shadshiny:::.shad_chat_reduce(
    message,
    shadshiny:::.shad_chat_event("tool", id = "search-1", name = "search", status = "running",
                                 input = list(query = "cats"))
  )
  message <- shadshiny:::.shad_chat_reduce(
    message,
    shadshiny:::.shad_chat_event("tool", id = "search-1", name = "search", status = "success",
                                 output = "3 results")
  )

  parts <- message$versions[[1]]$parts
  expect_identical(parts[[1]]$text, "Result found")
  expect_length(Filter(function(part) identical(part$type, "tool"), parts), 1)
  expect_identical(parts[[2]]$status, "success")
  expect_identical(parts[[2]]$output, "3 results")

  message <- shadshiny:::.shad_chat_reduce(
    message, shadshiny:::.shad_chat_event("status", text = "Public summary only")
  )
  expect_identical(tail(message$versions[[1]]$parts, 1)[[1]]$text, "Public summary only")
})

test_that("tool lifecycle preserves prior public fields", {
  message <- shadshiny:::.shad_chat_message("assistant", id = "answer-tool")
  message <- shadshiny:::.shad_chat_reduce(
    message,
    shadshiny:::.shad_chat_event(
      "tool", id = "lookup", name = "lookup", status = "pending",
      input = list(query = "cats")
    )
  )
  message <- shadshiny:::.shad_chat_reduce(
    message,
    shadshiny:::.shad_chat_event(
      "tool", id = "lookup", name = "lookup", status = "running"
    )
  )
  message <- shadshiny:::.shad_chat_reduce(
    message,
    shadshiny:::.shad_chat_event(
      "tool", id = "lookup", name = "lookup", status = "success",
      output = "3 results"
    )
  )

  tool <- message$versions[[1]]$parts[[1]]
  expect_identical(tool$input, list(query = "cats"))
  expect_identical(tool$output, "3 results")
  expect_identical(tool$status, "success")
})

test_that("done is terminal for the pure reducer", {
  message <- shadshiny:::.shad_chat_message("assistant", id = "answer-terminal")
  message <- shadshiny:::.shad_chat_reduce(
    message, shadshiny:::.shad_chat_event("text_delta", text = "Finished")
  )
  message <- shadshiny:::.shad_chat_reduce(
    message, shadshiny:::.shad_chat_event("done")
  )
  late <- shadshiny:::.shad_chat_reduce(
    message, shadshiny:::.shad_chat_event("text_delta", text = " late")
  )

  expect_identical(late$status, "complete")
  expect_identical(late$versions[[1]]$parts[[1]]$text, "Finished")
})

test_that("replacement preserves immutable prior versions and done is terminal", {
  message <- shadshiny:::.shad_chat_message("assistant", id = "answer-2")
  message <- shadshiny:::.shad_chat_reduce(
    message, shadshiny:::.shad_chat_event("text_delta", text = "First")
  )
  message <- shadshiny:::.shad_chat_reduce(
    message,
    shadshiny:::.shad_chat_event("replace", parts = list(list(type = "text", text = "Second")))
  )
  message <- shadshiny:::.shad_chat_reduce(
    message, shadshiny:::.shad_chat_event("done")
  )

  expect_length(message$versions, 2)
  expect_identical(message$versions[[1]]$parts[[1]]$text, "First")
  expect_identical(message$versions[[2]]$parts[[1]]$text, "Second")
  expect_identical(message$active_version, 2L)
  expect_identical(message$status, "complete")
})

test_that("replacement retains validated public source and attachment metadata", {
  parts <- list(
    list(type = "source", title = "Guide", url = "https://example.org/guide"),
    list(type = "attachment", name = "brief.pdf", size = 1200, type = "application/pdf")
  )
  message <- shadshiny:::.shad_chat_reduce(
    shadshiny:::.shad_chat_message("assistant", id = "answer-3"),
    shadshiny:::.shad_chat_event("replace", parts = parts)
  )
  replaced <- message$versions[[2]]$parts
  expect_identical(replaced[[1]]$url, "https://example.org/guide")
  expect_identical(replaced[[2]]$name, "brief.pdf")
  expect_identical(replaced[[2]]$mime, "application/pdf")
})

test_that("structured renderers escape untrusted parts and keep safe source links", {
  hostile_tool <- shadshiny:::.shad_chat_event(
    "tool", id = "tool-1", name = '<img src=x onerror="INERT_MARKER">', status = "error",
    input = list(query = '<script>INERT_MARKER</script>'),
    output = '<img src=x onerror="INERT_MARKER">'
  )
  tool_html <- as.character(shadshiny:::.shad_chat_part_ui(hostile_tool))
  expect_false(grepl("<script>", tool_html, fixed = TRUE))
  expect_false(grepl("<img ", tool_html, fixed = TRUE))
  expect_match(tool_html, "&lt;img", fixed = TRUE)
  expect_match(tool_html, "INERT_MARKER", fixed = TRUE)

  source_html <- as.character(shadshiny:::.shad_chat_part_ui(
    shadshiny:::.shad_chat_event("source", title = "Guide", url = "https://example.org/guide")
  ))
  expect_match(source_html, 'href="https://example.org/guide"', fixed = TRUE)
})

test_that("workbench UI uses native uploads without exposing server paths", {
  html <- as.character(shad_chat_workbench_ui("assistant", accept = ".pdf"))
  expect_match(html, 'type="file"', fixed = TRUE)
  expect_match(html, 'accept=".pdf"', fixed = TRUE)
  expect_false(grepl("datapath", html, fixed = TRUE))
})

test_that("workbench server passes public upload metadata and retries as a new version", {
  calls <- list()
  handler <- function(prompt, history) {
    calls[[length(calls) + 1L]] <<- list(prompt = prompt, history = history)
    list(
      shadshiny:::.shad_chat_event("text_delta", text = paste("Reply", length(calls))),
      shadshiny:::.shad_chat_event("done")
    )
  }

  shiny::testServer(shad_chat_workbench_server, args = list(handler = handler), {
    session$setInputs(
      text = "Read this",
      files = data.frame(name = "brief.pdf", size = 1200, type = "application/pdf",
                         datapath = "C:/secret/upload.tmp", stringsAsFactors = FALSE),
      submit = 1
    )
    messages <- session$returned$messages()
    expect_identical(calls[[1]]$prompt$text, "Read this")
    expect_named(calls[[1]]$prompt$attachments[[1]], c("name", "size", "type"))
    expect_length(messages, 2)
    expect_named(messages[[2]], c("id", "role", "versions", "active_version", "status"))
    expect_identical(messages[[2]]$versions[[1]]$parts[[1]]$text, "Reply 1")

    session$returned$retry(messages[[2]]$id)
    retried <- session$returned$messages()[[2]]
    expect_length(retried$versions, 2)
    expect_identical(retried$versions[[1]]$parts[[1]]$text, "Reply 1")
    expect_identical(retried$versions[[2]]$parts[[1]]$text, "Reply 2")

    session$returned$select_version(retried$id, 1)
    expect_identical(session$returned$messages()[[2]]$active_version, 1L)
    expect_length(calls, 2)
  })
})

test_that("workbench handler failures finalize with a safe assistant message", {
  shiny::testServer(
    shad_chat_workbench_server,
    args = list(handler = function(prompt, history) stop("operator secret")),
    {
      expect_warning(session$setInputs(text = "fail", submit = 1), "operator secret")
      messages <- session$returned$messages()
      expect_length(messages, 2)
      expect_identical(
        messages[[2]]$versions[[1]]$parts[[1]]$text,
        "Something went wrong. Please try again."
      )
      expect_false(session$returned$busy())
      expect_false(grepl("operator secret", paste(capture.output(print(messages)), collapse = " "), fixed = TRUE))
    }
  )
})

test_that("callback streams stop on cancel and ignore late events", {
  handler <- function(prompt, history) {
    events <- list(
      shadshiny:::.shad_chat_event("text_delta", text = "first"),
      shadshiny:::.shad_chat_event("text_delta", text = " late"),
      shadshiny:::.shad_chat_event("done")
    )
    index <- 0L
    function() { index <<- index + 1L; if (index <= length(events)) events[[index]] else NULL }
  }

  shiny::testServer(shad_chat_workbench_server, args = list(handler = handler), {
    session$setInputs(text = "stream", submit = 1)
    session$elapse(35)
    before_cancel <- session$returned$messages()
    expect_true(session$returned$busy())
    expect_identical(before_cancel[[2]]$versions[[1]]$parts[[1]]$text, "first late")
    session$returned$cancel()
    session$elapse(100)
    after_cancel <- session$returned$messages()
    expect_identical(after_cancel[[2]]$versions[[1]]$parts[[1]]$text, "first late")
    expect_false(session$returned$busy())
  })
})
