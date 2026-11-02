chunk_handler <- function(chunks) {
  force(chunks)
  function(user_text, history) {
    i <- 0L
    function() {
      i <<- i + 1L
      if (i <= length(chunks)) chunks[[i]] else NULL
    }
  }
}

test_that("chat markdown escapes raw HTML unless explicitly allowed", {
  payload <- '<img src="x" onerror="INERT_MARKER">'
  safe <- as.character(shadshiny:::.shad_chat_md(payload))
  trusted <- as.character(shadshiny:::.shad_chat_md(payload, allow_html = TRUE))

  expect_false(grepl("<img", safe, fixed = TRUE))
  expect_match(safe, "&lt;img", fixed = TRUE)
  expect_match(trusted, "<img", fixed = TRUE)
})

test_that("clear cancels an active stream without an orphan reply", {
  handler <- chunk_handler(c("Hel", "lo"))

  shiny::testServer(shad_chat_server, args = list(handler = handler), {
    session$setInputs(text = "hi", send = 1)
    session$elapse(35)
    session$returned$clear()
    session$elapse(250)

    expect_length(session$returned$messages(), 0)
    expect_false(session$returned$busy())
  })
})

test_that("generator errors become a fixed safe assistant error", {
  handler <- function(user_text, history) function() {
    stop("secret backend detail")
  }

  expect_warning(
    shiny::testServer(shad_chat_server, args = list(handler = handler), {
      session$setInputs(text = "hi", send = 1)
      session$elapse(35)

      out <- session$returned$messages()
      expect_identical(out[[2]]$content, "Something went wrong. Please try again.")
      expect_false(session$returned$busy())
    }),
    "chat stream failed"
  )
})

test_that("handler receives only messages that precede the current user turn", {
  seen_history <- NULL
  handler <- function(user_text, history) {
    seen_history <<- history
    "reply"
  }

  shiny::testServer(shad_chat_server, args = list(handler = handler), {
    session$returned$append("assistant", "earlier")
    session$setInputs(text = "current", send = 1)

    expect_length(seen_history, 1)
    expect_identical(seen_history[[1]]$content, "earlier")
    expect_identical(
      vapply(session$returned$messages(), `[[`, character(1), "content"),
      c("earlier", "current", "reply")
    )
  })
})

test_that("handler setup errors become a fixed safe assistant error", {
  handler <- function(user_text, history) stop("secret handler detail")

  expect_warning(
    shiny::testServer(shad_chat_server, args = list(handler = handler), {
      session$setInputs(text = "hi", send = 1)

      out <- session$returned$messages()
      expect_identical(out[[2]]$content, "Something went wrong. Please try again.")
      expect_false(session$returned$busy())
    }),
    "chat handler failed"
  )
})

test_that("invalid handler returns become a fixed safe assistant error", {
  handler <- function(user_text, history) list(unsupported = TRUE)

  expect_warning(
    shiny::testServer(shad_chat_server, args = list(handler = handler), {
      session$setInputs(text = "hi", send = 1)

      out <- session$returned$messages()
      expect_identical(out[[2]]$content, "Something went wrong. Please try again.")
      expect_false(session$returned$busy())
    }),
    "chat handler failed"
  )
})

test_that("chat UI renders its welcome and a full-width composer", {
  html <- as.character(shad_chat_ui(
    "chat", welcome = shad_empty(title = "Start the conversation")
  ))

  expect_match(html, '<div class="shad-chat__welcome">', fixed = TRUE)
  expect_match(html, "Start the conversation", fixed = TRUE)
  expect_match(html, '<div class="shad-input-group shad-input-group--block"', fixed = TRUE)
  expect_no_match(html, "data-welcome", fixed = TRUE)
})
