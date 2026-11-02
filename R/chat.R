# Chat module ------------------------------------------------------------------

# Render markdown to HTML (commonmark if available; escaped plain text else).
.shad_chat_md <- function(text, allow_html = FALSE) {
  source <- if (isTRUE(allow_html)) {
    as.character(text)
  } else {
    as.character(htmltools::htmlEscape(text))
  }
  if (requireNamespace("commonmark", quietly = TRUE)) {
    htmltools::HTML(commonmark::markdown_html(
      source, hardbreaks = TRUE, smart = TRUE,
      extensions = c("strikethrough", "table", "autolink")
    ))
  } else {
    htmltools::HTML(gsub("\n", "<br>", source, fixed = TRUE))
  }
}

.shad_chat_bubble <- function(role, content, in_progress = FALSE) {
  is_user <- identical(role, "user")
  shad_bubble(
    content,
    variant = if (is_user) "tinted" else "default",
    align = if (is_user) "end" else "start",
    class = if (in_progress) "shad-bubble--in-progress"
  )
}

#' Chat UI
#'
#' The UI half of a streaming chat module: a stick-to-bottom transcript plus a
#' composer (auto-sizing textarea + send button). Pair with [shad_chat_server()].
#'
#' @param id Module id.
#' @param placeholder Composer placeholder text.
#' @param height Transcript height (CSS unit).
#' @param welcome Optional tags shown before the first message (empty state).
#' @param send_label Accessible label for the send button.
#' @returns A chat UI tag.
#' @family shadshiny chat
#' @examples
#' if (interactive()) shad_chat_ui("chat", height = "60vh")
#' @export
shad_chat_ui <- function(id, placeholder = "Message...", height = "60vh",
                         welcome = NULL, send_label = "Send") {
  ns <- shiny::NS(id)
  # The welcome follows the transcript so CSS can hide it once the transcript
  # has content.
  scroller <- shad_message_scroller(
    ns("scroller"), height = height,
    shiny::uiOutput(ns("transcript"), class = "shad-chat__transcript"),
    if (!is.null(welcome)) htmltools::tags$div(class = "shad-chat__welcome", welcome)
  )
  composer <- htmltools::tags$div(
    class = "shad-chat__composer",
    shad_input_group(
      shad_textarea(ns("text"), placeholder = placeholder, rows = 1),
      shad_input_group_button(send_label, inputId = ns("send"), variant = "default"),
      block = TRUE
    )
  )
  with_deps(htmltools::tagList(
    htmltools::tags$div(class = "shad-chat", scroller, composer),
    # Enter sends, Shift+Enter inserts a newline.
    htmltools::tags$script(htmltools::HTML(sprintf(
      "(function(){var t=document.getElementById('%s');if(!t)return;t.addEventListener('keydown',function(e){if(e.key==='Enter'&&!e.shiftKey){e.preventDefault();var b=document.getElementById('%s');if(b)b.click();}});})();",
      ns("text"), ns("send")
    )))
  ))
}

#' Chat server
#'
#' The server half of the chat module. Wires the composer to `handler` and
#' streams replies into the transcript.
#'
#' `handler` is `function(user_text, history)` returning one of:
#' \itemize{
#'   \item a character string — the complete reply;
#'   \item a function of no arguments returning the next chunk, or `NULL` when
#'     done (the simple streaming protocol);
#'   \item a \pkg{coro} generator (e.g. an \pkg{ellmer} `chat$stream()`), drained
#'     the same way.
#' }
#' `history` is the list of prior messages (`list(role, content)`).
#'
#' Raw HTML in assistant Markdown is escaped by default. Set `allow_html = TRUE`
#' only when every reply is trusted developer-controlled content; never enable
#' it for user or LLM output. Stream failures emit a warning and append a fixed
#' user-safe error message without exposing the underlying condition.
#'
#' @param id Module id (matching [shad_chat_ui()]).
#' @param handler The reply function (see Details).
#' @param markdown If `TRUE` (default), render assistant replies as Markdown.
#' @param allow_html If `TRUE`, allow raw HTML in assistant Markdown. Defaults to
#'   `FALSE`; only use with trusted content.
#' @returns A list with `messages` (a reactive of the transcript), `busy` (a
#'   read-only reactive), `clear()`, `cancel()`, and `append(role, content)`.
#'   `clear()` also cancels an in-flight stream; `cancel()` stops only the
#'   in-flight stream.
#' @family shadshiny chat
#' @examples
#' if (interactive()) {
#'   shad_chat_server("chat", function(user_text, history) {
#'     paste("You said:", user_text)
#'   })
#' }
#' @export
shad_chat_server <- function(id, handler, markdown = TRUE, allow_html = FALSE) {
  shiny::moduleServer(id, function(input, output, session) {
    messages  <- shiny::reactiveVal(list())
    streaming <- shiny::reactiveVal(NULL)   # partial assistant text
    active_gen <- shiny::reactiveVal(NULL)
    acc <- shiny::reactiveVal("")
    busy <- shiny::reactiveVal(FALSE)

    cancel_stream <- function() {
      active_gen(NULL)
      acc("")
      streaming(NULL)
      busy(FALSE)
      invisible(NULL)
    }

    render_html <- function(role, content) {
      if (identical(role, "assistant") && isTRUE(markdown)) {
        .shad_chat_md(content, allow_html = allow_html)
      }
      else htmltools::HTML(gsub("\n", "<br>", htmltools::htmlEscape(content)))
    }

    append_msg <- function(role, content) {
      m <- messages()
      m[[length(m) + 1L]] <- list(role = role, content = content,
                                  html = render_html(role, content))
      messages(m)
    }

    output$transcript <- shiny::renderUI({
      msgs <- messages()
      partial <- streaming()
      rows <- lapply(msgs, function(m) .shad_chat_bubble(m$role, m$html))
      if (!is.null(partial)) {
        rows <- c(rows, list(.shad_chat_bubble(
          "assistant", htmltools::HTML(gsub("\n", "<br>", htmltools::htmlEscape(partial))),
          in_progress = TRUE
        )))
      }
      if (!length(rows)) return(NULL)
      do.call(htmltools::tagList, rows)
    })

    # Normalise a handler return into a uniform generator with $next_chunk().
    make_gen <- function(reply) {
      if (is.character(reply)) {
        i <- 0L
        list(next_chunk = function() { i <<- i + 1L; if (i == 1L) reply else NULL })
      } else if (inherits(reply, "coro_generator_instance") ||
                 (is.function(reply) && requireNamespace("coro", quietly = TRUE) &&
                  isTRUE(attr(reply, "coro_generator")))) {
        list(next_chunk = function() {
          v <- reply()
          if (coro::is_exhausted(v)) NULL else as.character(v)
        })
      } else if (is.function(reply)) {
        list(next_chunk = function() { v <- reply(); if (is.null(v)) NULL else as.character(v) })
      } else {
        stop("chat handler must return a string, a function, or a coro generator.",
             call. = FALSE)
      }
    }

    fail_chat <- function(stage, error) {
      warning("chat ", stage, " failed: ", conditionMessage(error),
              call. = FALSE)
      cancel_stream()
      append_msg("assistant", "Something went wrong. Please try again.")
    }

    shiny::observeEvent(input$send, {
      text <- input$text
      if (is.null(text) || !nzchar(trimws(text))) return()
      cancel_stream()
      history <- messages()
      append_msg("user", text)
      shad_set_value("text", "", session)  # clear composer

      setup <- tryCatch({
        reply <- handler(text, history)
        list(ok = TRUE, reply = reply, gen = make_gen(reply))
      }, error = function(e) list(ok = FALSE, error = e))
      if (!isTRUE(setup$ok)) {
        fail_chat("handler", setup$error)
        return()
      }
      reply <- setup$reply
      gen <- setup$gen
      # complete-string fast path finalises immediately
      if (is.character(reply)) {
        append_msg("assistant", reply)
      } else {
        acc(""); streaming("")
        active_gen(gen)
        busy(TRUE)
      }
    })

    # streaming pump
    shiny::observe({
      gen <- active_gen()
      if (is.null(gen)) return()
      shiny::invalidateLater(30)
      shiny::isolate({
        result <- tryCatch(
          list(ok = TRUE, chunk = gen$next_chunk()),
          error = function(e) list(ok = FALSE, error = e)
        )
        if (!isTRUE(result$ok)) {
          fail_chat("stream", result$error)
        } else if (is.null(result$chunk)) {
          final <- acc()
          cancel_stream()
          append_msg("assistant", final)
        } else {
          acc(paste0(acc(), result$chunk))
          streaming(acc())
        }
      })
    })

    list(
      messages = shiny::reactive(messages()),
      busy = shiny::reactive(busy()),
      clear = function() { cancel_stream(); messages(list()) },
      cancel = cancel_stream,
      append = function(role, content) append_msg(role, content)
    )
  })
}
