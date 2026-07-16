# Chat module ------------------------------------------------------------------

# Render markdown to HTML (commonmark if available; escaped plain text else).
.shad_chat_md <- function(text) {
  if (requireNamespace("commonmark", quietly = TRUE)) {
    htmltools::HTML(commonmark::markdown_html(
      text, hardbreaks = TRUE, smart = TRUE,
      extensions = c("strikethrough", "table", "autolink")
    ))
  } else {
    htmltools::HTML(gsub("\n", "<br>", htmltools::htmlEscape(text)))
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
  scroller <- shad_message_scroller(
    ns("scroller"), height = height,
    shiny::uiOutput(ns("transcript"), class = "shad-chat__transcript")
  )
  composer <- htmltools::tags$div(
    class = "shad-chat__composer",
    shad_input_group(
      shad_textarea(ns("text"), placeholder = placeholder, rows = 1),
      shad_input_group_button(send_label, inputId = ns("send"), variant = "default")
    )
  )
  with_deps(htmltools::tagList(
    htmltools::tags$div(
      class = "shad-chat",
      `data-welcome` = if (!is.null(welcome)) "" else NULL,
      scroller, composer
    ),
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
#' @param id Module id (matching [shad_chat_ui()]).
#' @param handler The reply function (see Details).
#' @param markdown If `TRUE` (default), render assistant replies as Markdown.
#' @returns A list with `messages` (a reactive of the transcript), `clear()`, and
#'   `append(role, content)`.
#' @family shadshiny chat
#' @examples
#' if (interactive()) {
#'   shad_chat_server("chat", function(user_text, history) {
#'     paste("You said:", user_text)
#'   })
#' }
#' @export
shad_chat_server <- function(id, handler, markdown = TRUE) {
  shiny::moduleServer(id, function(input, output, session) {
    messages  <- shiny::reactiveVal(list())
    streaming <- shiny::reactiveVal(NULL)   # partial assistant text
    active_gen <- shiny::reactiveVal(NULL)
    acc <- shiny::reactiveVal("")

    render_html <- function(role, content) {
      if (identical(role, "assistant") && isTRUE(markdown)) .shad_chat_md(content)
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

    shiny::observeEvent(input$send, {
      text <- input$text
      if (is.null(text) || !nzchar(trimws(text))) return()
      append_msg("user", text)
      shad_set_value("text", "", session)  # clear composer

      reply <- handler(text, messages())
      gen <- make_gen(reply)
      # complete-string fast path finalises immediately
      if (is.character(reply)) {
        append_msg("assistant", reply)
      } else {
        acc(""); streaming("")
        active_gen(gen)
      }
    })

    # streaming pump
    shiny::observe({
      gen <- active_gen()
      if (is.null(gen)) return()
      shiny::invalidateLater(30)
      shiny::isolate({
        chunk <- tryCatch(gen$next_chunk(), error = function(e) NULL)
        if (is.null(chunk)) {
          final <- acc()
          append_msg("assistant", final)
          active_gen(NULL); acc(""); streaming(NULL)
        } else {
          acc(paste0(acc(), chunk))
          streaming(acc())
        }
      })
    })

    list(
      messages = shiny::reactive(messages()),
      clear = function() { messages(list()); streaming(NULL) },
      append = function(role, content) append_msg(role, content)
    )
  })
}
