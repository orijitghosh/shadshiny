# Structured chat workbench ----------------------------------------------------

.shad_chat_event_types <- c(
  "text_delta", "source", "tool", "attachment", "status", "replace", "done"
)
.shad_chat_part_types <- c("text", "source", "tool", "attachment", "status")

.shad_chat_scalar_character <- function(value, name) {
  if (!is.character(value) || length(value) != 1L || is.na(value)) {
    stop(name, " must be one non-missing character value.", call. = FALSE)
  }
  value
}

.shad_chat_json_safe <- function(value, name) {
  if (is.function(value) || is.environment(value) || is.language(value)) {
    stop(name, " must be JSON-safe.", call. = FALSE)
  }
  ok <- tryCatch({
    jsonlite::toJSON(value, auto_unbox = TRUE, null = "null")
    TRUE
  }, error = function(error) FALSE)
  if (!ok) stop(name, " must be JSON-safe.", call. = FALSE)
  value
}

.shad_chat_safe_url <- function(url) {
  url <- .shad_chat_scalar_character(url, "url")
  if (!grepl("^https?://[^/?#[:space:]]+(?:[/?#]|$)", url, perl = TRUE)) {
    stop("source url must use an http or https scheme.", call. = FALSE)
  }
  url
}

.shad_chat_normalize_parts <- function(parts) {
  if (!is.list(parts)) stop("parts must be a list.", call. = FALSE)
  lapply(parts, function(part) {
    if (!is.list(part) || is.null(part$type)) {
      stop("each replacement part must be a typed list.", call. = FALSE)
    }
    part_type <- part$type
    if (!identical(length(part_type), 1L) || !part_type %in% .shad_chat_part_types) {
      stop("replacement parts must use a supported part type.", call. = FALSE)
    }
    type_positions <- which(names(part) == "type")
    payload <- part[-type_positions[[1L]]]
    # A direct replacement list uses `type = "attachment"` as the
    # discriminator and `mime` for its public MIME metadata. Keep support for
    # the compact duplicate-name form used by JSON-like R lists too.
    if (identical(part_type, "attachment") && length(type_positions) > 1L) {
      payload$type <- part[[type_positions[[length(type_positions)]]]]
    }
    if (identical(part_type, "text")) {
      return(list(
        type = "text",
        text = .shad_chat_scalar_character(payload$text, "text part")
      ))
    }
    do.call(
      .shad_chat_event,
      c(list(event_type = part_type), payload)
    )
  })
}

.shad_chat_event <- function(event_type, ...) {
  event_type <- .shad_chat_scalar_character(event_type, "event type")
  if (!event_type %in% .shad_chat_event_types) {
    stop("Unknown chat event type: ", event_type, ".", call. = FALSE)
  }
  fields <- list(...)
  event <- c(list(type = event_type), fields)

  switch(event_type,
    text_delta = {
      event$text <- .shad_chat_scalar_character(event$text, "text_delta text")
    },
    source = {
      event$title <- .shad_chat_scalar_character(event$title, "source title")
      event$url <- .shad_chat_safe_url(event$url)
      event$id <- event$id %||% event$url
      event$id <- .shad_chat_scalar_character(event$id, "source id")
    },
    tool = {
      event$id <- .shad_chat_scalar_character(event$id, "tool id")
      event$name <- .shad_chat_scalar_character(event$name, "tool name")
      event$status <- .shad_chat_scalar_character(event$status, "tool status")
      if (!event$status %in% c("pending", "running", "success", "error")) {
        stop("tool status must be pending, running, success, or error.", call. = FALSE)
      }
      if (!is.null(event$input)) event$input <- .shad_chat_json_safe(event$input, "tool input")
      if (!is.null(event$output)) event$output <- .shad_chat_json_safe(event$output, "tool output")
      if (!is.null(event$error)) event$error <- .shad_chat_scalar_character(event$error, "tool error")
    },
    attachment = {
      event$name <- .shad_chat_scalar_character(event$name, "attachment name")
      if (!is.numeric(event$size) || length(event$size) != 1L || is.na(event$size) ||
          !is.finite(event$size) || event$size < 0) {
        stop("attachment size must be one finite non-negative number.", call. = FALSE)
      }
      mime <- event$mime %||% if (!identical(fields$type, "attachment")) fields$type
      event$mime <- .shad_chat_scalar_character(mime, "attachment type")
      event$type <- "attachment"
      event$id <- event$id %||% paste(event$name, event$size, event$mime, sep = ":")
      event$id <- .shad_chat_scalar_character(event$id, "attachment id")
    },
    status = {
      event$text <- .shad_chat_scalar_character(event$text, "status text")
    },
    replace = {
      event$parts <- .shad_chat_normalize_parts(event$parts)
    },
    done = NULL
  )
  event
}

.shad_chat_message <- function(role = c("assistant", "user"), id = NULL, parts = list()) {
  role <- match.arg(role)
  parts <- .shad_chat_normalize_parts(parts)
  list(
    id = id %||% paste0("message-", sprintf("%08x", sample.int(.Machine$integer.max, 1L))),
    role = role,
    versions = list(list(id = "version-1", parts = parts)),
    active_version = 1L,
    status = "pending"
  )
}

.shad_chat_active_parts <- function(message) {
  message$versions[[message$active_version]]$parts
}

.shad_chat_set_active_parts <- function(message, parts) {
  message$versions[[message$active_version]]$parts <- parts
  message
}

.shad_chat_append_unique_part <- function(message, event) {
  parts <- .shad_chat_active_parts(message)
  duplicate <- !is.null(event$id) && any(vapply(
    parts, function(part) identical(part$id %||% NULL, event$id), logical(1)
  ))
  if (!duplicate) {
    parts[[length(parts) + 1L]] <- event
  }
  .shad_chat_set_active_parts(message, parts)
}

.shad_chat_upsert_tool_part <- function(message, event) {
  parts <- .shad_chat_active_parts(message)
  index <- which(vapply(parts, function(part) identical(part$type, "tool") && identical(part$id, event$id), logical(1)))
  if (length(index)) {
    current <- parts[[index[[1L]]]]
    for (field in setdiff(names(event), "type")) {
      if (!is.null(event[[field]])) current[[field]] <- event[[field]]
    }
    parts[[index[[1L]]]] <- current
  } else {
    parts[[length(parts) + 1L]] <- event
  }
  .shad_chat_set_active_parts(message, parts)
}

.shad_chat_reduce <- function(message, event) {
  if (!is.list(message) || is.null(message$versions) || !is.list(event) || is.null(event$type)) {
    stop("message and event must use the structured chat schema.", call. = FALSE)
  }
  if (identical(message$status, "complete")) return(message)
  switch(event$type,
    text_delta = {
      parts <- .shad_chat_active_parts(message)
      last <- length(parts)
      if (last && identical(parts[[last]]$type, "text")) {
        parts[[last]]$text <- paste0(parts[[last]]$text, event$text)
      } else {
        parts[[last + 1L]] <- list(type = "text", text = event$text)
      }
      .shad_chat_set_active_parts(message, parts)
    },
    source = .shad_chat_append_unique_part(message, event),
    tool = .shad_chat_upsert_tool_part(message, event),
    attachment = .shad_chat_append_unique_part(message, event),
    status = {
      message$status <- event$text
      .shad_chat_append_unique_part(message, event)
    },
    replace = {
      number <- length(message$versions) + 1L
      message$versions[[number]] <- list(id = paste0("version-", number), parts = event$parts)
      message$active_version <- as.integer(number)
      message$status <- "pending"
      message
    },
    done = {
      message$status <- "complete"
      message
    },
    stop("Unknown chat event type: ", event$type, ".", call. = FALSE)
  )
}

.shad_chat_pre <- function(value, class = NULL) {
  htmltools::tags$pre(
    class = class,
    htmltools::tags$code(if (is.character(value)) value else jsonlite::toJSON(value, auto_unbox = TRUE, pretty = TRUE))
  )
}

.shad_chat_part_ui <- function(part, markdown = TRUE, allow_html = FALSE) {
  switch(part$type,
    text = {
      if (isTRUE(markdown)) .shad_chat_md(part$text, allow_html = allow_html) else htmltools::htmlEscape(part$text)
    },
    source = htmltools::tags$details(
      class = "shad-chat-source",
      htmltools::tags$summary("Source: ", part$title),
      htmltools::tags$a(
        href = part$url, target = "_blank", rel = "noopener noreferrer",
        part$title
      )
    ),
    tool = htmltools::tags$details(
      class = "shad-chat-tool", `data-status` = part$status,
      htmltools::tags$summary("Tool: ", part$name, " (", part$status, ")"),
      if (!is.null(part$input)) .shad_chat_pre(part$input, "shad-chat-tool__input"),
      if (!is.null(part$output)) .shad_chat_pre(part$output, "shad-chat-tool__output"),
      if (!is.null(part$error)) htmltools::tags$p(class = "shad-chat-tool__error", part$error)
    ),
    attachment = shad_attachment(
      part$name, description = paste(part$mime, format(part$size, big.mark = ","), "bytes"),
      state = "done", class = "shad-chat-attachment"
    ),
    status = shad_marker(part$text, role = "status", class = "shad-chat-status"),
    stop("Unknown chat part type: ", part$type, ".", call. = FALSE)
  )
}

.shad_chat_public_attachments <- function(files) {
  if (is.null(files) || !is.data.frame(files) || !nrow(files)) return(list())
  required <- c("name", "size", "type")
  if (!all(required %in% names(files))) return(list())
  lapply(seq_len(nrow(files)), function(index) {
    list(
      name = as.character(files$name[[index]]),
      size = as.numeric(files$size[[index]]),
      type = as.character(files$type[[index]])
    )
  })
}

.shad_chat_message_ui <- function(message, markdown = TRUE, allow_html = FALSE,
                                  render_part = NULL) {
  version <- message$versions[[message$active_version]]
  parts <- lapply(version$parts, function(part) {
    if (is.function(render_part)) render_part(part) else {
      .shad_chat_part_ui(part, markdown = markdown, allow_html = allow_html)
    }
  })
  footer <- if (length(message$versions) > 1L) {
    htmltools::tags$div(
      class = "shad-chat-branch", `data-shad` = "chat-branch", `data-message-id` = message$id,
      `data-version` = message$active_version,
      htmltools::tags$button(type = "button", class = "shad-chat-branch__previous", `data-chat-branch` = "previous", `aria-label` = "Previous response", disabled = flag_attr(message$active_version <= 1L), "Previous response"),
      htmltools::tags$span(paste("Response", message$active_version, "of", length(message$versions))),
      htmltools::tags$button(type = "button", class = "shad-chat-branch__next", `data-chat-branch` = "next", `aria-label` = "Next response", disabled = flag_attr(message$active_version >= length(message$versions)), "Next response")
    )
  }
  shad_message(
    parts,
    align = if (identical(message$role, "user")) "end" else "start",
    sender = if (identical(message$role, "user")) "You" else "Assistant",
    footer = footer,
    class = "shad-chat-workbench__message"
  )
}

#' Structured chat workbench UI
#'
#' Experimental, provider-neutral UI for structured chat events. Pair with
#' [shad_chat_workbench_server()]. Native uploads are handled by Shiny; no
#' server-side file paths are rendered into this UI.
#'
#' @param id Module id.
#' @param placeholder Composer placeholder text.
#' @param height Transcript height.
#' @param welcome Optional content before the first message.
#' @param send_label Send button label.
#' @param accept Native file-input accept value.
#' @param multiple Whether native upload accepts multiple files.
#' @returns A workbench UI tag.
#' @export
shad_chat_workbench_ui <- function(id, placeholder = "Message...", height = "60vh",
                                   welcome = NULL, send_label = "Send", accept = NULL,
                                   multiple = TRUE) {
  ns <- shiny::NS(id)
  with_deps(htmltools::tags$div(
    id = ns("root"), class = "shad-chat-workbench", `data-shad` = "chat-workbench",
    shad_message_scroller(ns("scroller"), height = height,
      shiny::uiOutput(ns("transcript"), class = "shad-chat-workbench__transcript")),
    if (!is.null(welcome)) htmltools::tags$div(class = "shad-chat-workbench__welcome", welcome),
    htmltools::tags$div(
      class = "shad-chat-prompt", `data-shad` = "chat-prompt",
      shiny::fileInput(ns("files"), label = "Attach files", accept = accept, multiple = multiple),
      shad_textarea(ns("text"), placeholder = placeholder, rows = 1),
      shad_button(send_label, inputId = ns("submit"), class = "shad-chat-prompt__send"),
      shad_button("Cancel", inputId = ns("cancel"), variant = "outline",
                  disabled = TRUE, class = "shad-chat-prompt__cancel")
    )
  ))
}

#' Structured chat workbench server
#'
#' Experimental server module accepting provider-owned structured events. The
#' handler receives public prompt text and attachment metadata only.
#'
#' @param id Module id.
#' @param handler Function of `prompt` and prior `history`.
#' @param markdown Render assistant text as safe Markdown.
#' @param allow_html Trusted-content escape hatch for assistant Markdown.
#' @param render_part Optional renderer for one validated part.
#' @returns A structured transcript controller.
#' @export
shad_chat_workbench_server <- function(id, handler, markdown = TRUE, allow_html = FALSE,
                                       render_part = NULL) {
  shiny::moduleServer(id, function(input, output, session) {
    messages <- shiny::reactiveVal(list())
    requests <- shiny::reactiveVal(list())
    busy <- shiny::reactiveVal(FALSE)
    generation <- shiny::reactiveVal(0L)
    active_stream <- shiny::reactiveVal(NULL)

    render_message <- function(message) {
      .shad_chat_message_ui(message, markdown = markdown, allow_html = allow_html,
                            render_part = render_part)
    }
    output$transcript <- shiny::renderUI({
      rows <- lapply(messages(), function(message) {
        rendered <- tryCatch(
          render_message(message),
          error = function(error) {
            warning("chat workbench render failed: ", conditionMessage(error), call. = FALSE)
            safe <- .shad_chat_message("assistant", id = message$id)
            safe <- .shad_chat_reduce(
              safe, .shad_chat_event("text_delta", text = "Something went wrong. Please try again.")
            )
            .shad_chat_message_ui(safe, markdown = FALSE)
          }
        )
        shad_message_scroller_item(`data-chat-message-id` = message$id, rendered)
      })
      if (length(rows)) do.call(htmltools::tagList, rows)
    })

    cancel <- function() {
      generation(generation() + 1L)
      active_stream(NULL)
      busy(FALSE)
      invisible(NULL)
    }
    append_message <- function(message) {
      all <- messages(); all[[length(all) + 1L]] <- message; messages(all)
    }
    replace_message <- function(index, message) {
      all <- messages(); all[[index]] <- message; messages(all)
    }
    remember_request <- function(message_id, prompt, history) {
      all <- requests()
      all[[message_id]] <- list(prompt = prompt, history = history)
      requests(all)
    }
    normalize_reply <- function(reply) {
      if (is.character(reply) && length(reply) == 1L) {
        return(list(.shad_chat_event("text_delta", text = reply), .shad_chat_event("done")))
      }
      if (inherits(reply, "coro_generator_instance") ||
          (is.function(reply) && requireNamespace("coro", quietly = TRUE) &&
           isTRUE(attr(reply, "coro_generator")))) {
        return(function() {
          value <- reply()
          if (coro::is_exhausted(value)) NULL else value
        })
      }
      if (is.function(reply)) return(reply)
      if (is.list(reply) && !is.null(reply$type)) return(list(do.call(.shad_chat_event, c(list(event_type = reply$type), reply[-match("type", names(reply))]))))
      if (is.list(reply)) return(reply)
      stop("workbench handler must return a string or a list of structured events.", call. = FALSE)
    }
    fail_workbench <- function(stage, error, index = NULL) {
      warning("chat workbench ", stage, " failed: ", conditionMessage(error), call. = FALSE)
      cancel()
      safe <- .shad_chat_event("text_delta", text = "Something went wrong. Please try again.")
      if (is.null(index)) {
        failed <- .shad_chat_message("assistant")
        failed <- .shad_chat_reduce(failed, safe)
        failed <- .shad_chat_reduce(failed, .shad_chat_event("done"))
        append_message(failed)
      } else {
        failed <- messages()[[index]]
        failed <- .shad_chat_reduce(failed, safe)
        failed <- .shad_chat_reduce(failed, .shad_chat_event("done"))
        replace_message(index, failed)
      }
    }
    run_handler <- function(prompt, history, index = NULL) {
      busy(TRUE)
      setup <- tryCatch(list(ok = TRUE, reply = handler(prompt, history)), error = function(error) list(ok = FALSE, error = error))
      if (!isTRUE(setup$ok)) return(fail_workbench("handler", setup$error, index))
      target <- if (is.null(index)) .shad_chat_message("assistant") else messages()[[index]]
      remember_request(target$id, prompt, history)
      events <- tryCatch(normalize_reply(setup$reply), error = function(error) error)
      if (inherits(events, "error")) return(fail_workbench("event", events, index))
      if (is.function(events)) {
        if (is.null(index)) {
          append_message(target)
          index <- length(messages())
        } else replace_message(index, target)
        active_stream(list(next_event = events, index = index, token = generation()))
        return(invisible(NULL))
      }
      result <- tryCatch({
        for (raw in events) {
          event <- if (is.list(raw) && !is.null(raw$type)) do.call(.shad_chat_event, c(list(event_type = raw$type), raw[-match("type", names(raw))])) else stop("invalid structured event", call. = FALSE)
          target <- .shad_chat_reduce(target, event)
        }
        target
      }, error = function(error) error)
      if (inherits(result, "error")) return(fail_workbench("stream", result, index))
      render_check <- tryCatch({ render_message(target); NULL }, error = function(error) error)
      if (inherits(render_check, "error")) return(fail_workbench("render", render_check, index))
      if (is.null(index)) append_message(target) else replace_message(index, target)
      busy(FALSE)
    }

    shiny::observe({
      stream <- active_stream()
      if (is.null(stream)) return()
      shiny::invalidateLater(30)
      shiny::isolate({
        if (!identical(stream$token, generation())) return()
        step <- tryCatch(list(ok = TRUE, value = stream$next_event()), error = function(error) list(ok = FALSE, error = error))
        if (!isTRUE(step$ok)) return(fail_workbench("stream", step$error, stream$index))
        if (is.null(step$value)) {
          all <- messages()
          all[[stream$index]] <- .shad_chat_reduce(
            all[[stream$index]], .shad_chat_event("done")
          )
          messages(all)
          active_stream(NULL); busy(FALSE); return()
        }
        event <- tryCatch(do.call(.shad_chat_event, c(list(event_type = step$value$type), step$value[-match("type", names(step$value))])), error = function(error) error)
        if (inherits(event, "error")) return(fail_workbench("event", event, stream$index))
        all <- messages(); all[[stream$index]] <- .shad_chat_reduce(all[[stream$index]], event); messages(all)
        if (identical(event$type, "done")) { active_stream(NULL); busy(FALSE) }
      })
    })

    shiny::observeEvent(input$submit, {
      text <- input$text
      if (is.null(text) || !nzchar(trimws(text)) || isTRUE(busy())) return()
      cancel()
      history <- messages()
      prompt <- list(text = text, attachments = .shad_chat_public_attachments(input$files))
      user <- .shad_chat_message("user")
      user <- .shad_chat_reduce(user, .shad_chat_event("text_delta", text = text))
      user$status <- "complete"
      append_message(user)
      shiny::updateTextAreaInput(session, "text", value = "")
      run_handler(prompt, history)
    })

    shiny::observeEvent(input$cancel, { cancel() }, ignoreInit = TRUE)
    shiny::observe({
      is_busy <- isTRUE(busy())
      shad_set_attr("submit", "disabled", is_busy, session)
      shad_set_attr("cancel", "disabled", !is_busy, session)
    })

    shiny::observeEvent(input$version, {
      value <- input$version
      if (!is.null(value$messageId) && !is.null(value$version)) {
        try(select_version(value$messageId, value$version), silent = TRUE)
      }
    })

    list(
      messages = shiny::reactive(messages()),
      busy = shiny::reactive(busy()),
      clear = function() { cancel(); messages(list()); requests(list()) },
      cancel = cancel,
      retry = function(message_id) {
        all <- messages(); index <- which(vapply(all, function(message) identical(message$id, message_id), logical(1)))
        request <- requests()[[message_id]]
        if (length(index) != 1L || is.null(request)) stop("message cannot be retried.", call. = FALSE)
        message <- all[[index]]; number <- length(message$versions) + 1L
        message$versions[[number]] <- list(id = paste0("version-", number), parts = list())
        message$active_version <- as.integer(number); message$status <- "pending"; replace_message(index, message)
        cancel()
        run_handler(request$prompt, request$history, index)
      },
      select_version = select_version <- function(message_id, version) {
        all <- messages(); index <- which(vapply(all, function(message) identical(message$id, message_id), logical(1)))
        if (length(index) != 1L || !is.numeric(version) || length(version) != 1L || version < 1L || version > length(all[[index]]$versions)) stop("invalid response version.", call. = FALSE)
        all[[index]]$active_version <- as.integer(version); messages(all)
      },
      append = function(message) { append_message(message); invisible(NULL) }
    )
  })
}
