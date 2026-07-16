# Form validation framework ----------------------------------------------------

# --- rules --------------------------------------------------------------------
# A rule is function(value) -> NULL (pass) | character(1) (error message).

.is_empty_value <- function(v) {
  is.null(v) || length(v) == 0 ||
    (length(v) == 1 && (is.na(v) || (is.character(v) && !nzchar(trimws(v)))))
}

#' Validation rules
#'
#' Rules for [shad_validator()]. Each is a function of a field value returning
#' `NULL` when valid or an error message string. Empty optional fields skip
#' non-`required` rules (matching shinyvalidate).
#'
#' @param message Custom error message (`NULL` uses a sensible default).
#' @param n Character/threshold count.
#' @param min,max Numeric bounds.
#' @param pattern A regular expression.
#' @param choices Allowed values.
#' @param fn A custom `function(value)` returning `NULL` or a message.
#' @returns A rule function.
#' @name shad_rules
#' @family shadshiny forms
#' @examples
#' r <- shad_rule_required()
#' r("")      # error message
#' r("hello") # NULL
NULL

#' @rdname shad_rules
#' @export
shad_rule_required <- function(message = "Required.") {
  function(value) {
    if (isFALSE(value)) return(message)          # unchecked checkbox/switch
    if (.is_empty_value(value)) return(message)
    NULL
  }
}

#' @rdname shad_rules
#' @export
shad_rule_email <- function(message = "Enter a valid email address.") {
  function(value) {
    if (.is_empty_value(value)) return(NULL)
    if (!grepl("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", value, perl = TRUE)) return(message)
    NULL
  }
}

#' @rdname shad_rules
#' @export
shad_rule_min_chars <- function(n, message = NULL) {
  message <- message %||% sprintf("Must be at least %d characters.", n)
  function(value) {
    if (.is_empty_value(value)) return(NULL)
    if (nchar(as.character(value)) < n) return(message)
    NULL
  }
}

#' @rdname shad_rules
#' @export
shad_rule_max_chars <- function(n, message = NULL) {
  message <- message %||% sprintf("Must be at most %d characters.", n)
  function(value) {
    if (.is_empty_value(value)) return(NULL)
    if (nchar(as.character(value)) > n) return(message)
    NULL
  }
}

#' @rdname shad_rules
#' @export
shad_rule_range <- function(min = -Inf, max = Inf, message = NULL) {
  message <- message %||% sprintf("Must be between %s and %s.", min, max)
  function(value) {
    if (.is_empty_value(value)) return(NULL)
    num <- suppressWarnings(as.numeric(value))
    if (is.na(num) || num < min || num > max) return(message)
    NULL
  }
}

#' @rdname shad_rules
#' @export
shad_rule_regex <- function(pattern, message = "Invalid format.") {
  function(value) {
    if (.is_empty_value(value)) return(NULL)
    if (!grepl(pattern, value)) return(message)
    NULL
  }
}

#' @rdname shad_rules
#' @export
shad_rule_in <- function(choices, message = NULL) {
  message <- message %||% "Not an allowed value."
  function(value) {
    if (.is_empty_value(value)) return(NULL)
    if (!all(value %in% choices)) return(message)
    NULL
  }
}

#' @rdname shad_rules
#' @export
shad_rule_fn <- function(fn) {
  stopifnot(is.function(fn))
  fn
}

# --- validator ----------------------------------------------------------------

#' Form validator
#'
#' A server-side validator that pushes shadcn-styled errors into the
#' [shad_form_field()] wrapping each control (via [update_shad_form_field()]),
#' with optional submit-button gating and an error summary. API shape mirrors
#' \pkg{shinyvalidate}; implemented natively with no extra dependencies.
#'
#' The returned object's methods:
#' \describe{
#'   \item{`add_rule(inputId, rule, ...)`}{Register a rule (chainable). Multiple
#'     rules per field run in order; the first failure wins.}
#'   \item{`enable()` / `disable()`}{Start / stop live validation (errors show on
#'     change once enabled; `disable()` clears them).}
#'   \item{`is_valid()`}{Reactive-context logical: all rules currently pass.}
#'   \item{`validate()`}{Imperative full pass; shows every error and returns a
#'     logical (use in submit handlers).}
#'   \item{`fields()`}{Registered input ids.}
#'   \item{`bind_submit(buttonId)`}{Disable a [shad_button()] while invalid.}
#'   \item{`bind_summary(id)`}{Render a [shad_form_summary()] on validate/enable.}
#' }
#'
#' @param session The Shiny session.
#' @returns A validator object (list of functions).
#' @family shadshiny forms
#' @examples
#' if (interactive()) {
#'   server <- function(input, output, session) {
#'     sv <- shad_validator()
#'     sv$add_rule("email", shad_rule_required())
#'     sv$add_rule("email", shad_rule_email())
#'     sv$enable()
#'     observeEvent(input$submit, if (sv$validate()) message("ok"))
#'   }
#' }
#' @export
shad_validator <- function(session = shiny::getDefaultReactiveDomain()) {
  rules <- new.env(parent = emptyenv())
  rules$map <- list()
  rules$labels <- list()
  enabled <- shiny::reactiveVal(FALSE)
  observers <- list()

  field_error <- function(id) {
    value <- session$input[[id]]
    fns <- rules$map[[id]]
    for (fn in fns) {
      msg <- fn(value)
      if (!is.null(msg)) return(msg)
    }
    NULL
  }

  show_field <- function(id) {
    update_shad_form_field(id, field_error(id), session = session)
  }

  self <- list()

  self$add_rule <- function(inputId, rule, label = NULL) {
    if (!is.function(rule)) stop("`rule` must be a rule function.", call. = FALSE)
    rules$map[[inputId]] <- c(rules$map[[inputId]], list(rule))
    if (!is.null(label)) rules$labels[[inputId]] <- label
    invisible(self)
  }

  self$fields <- function() names(rules$map)

  self$is_valid <- function() {
    all(vapply(names(rules$map), function(id) is.null(field_error(id)), logical(1)))
  }

  self$enable <- function() {
    enabled(TRUE)
    for (id in names(rules$map)) {
      local({
        fid <- id
        observers[[fid]] <<- shiny::observeEvent(
          session$input[[fid]],
          if (isTRUE(enabled())) show_field(fid),
          ignoreInit = FALSE, ignoreNULL = FALSE
        )
      })
    }
    invisible(self)
  }

  self$disable <- function() {
    enabled(FALSE)
    for (o in observers) o$destroy()
    observers <<- list()
    for (id in names(rules$map)) update_shad_form_field(id, NULL, session = session)
    invisible(self)
  }

  self$validate <- function() {
    for (id in names(rules$map)) show_field(id)
    ok <- self$is_valid()
    if (!is.null(rules$summary_id)) self$.render_summary()
    ok
  }

  self$bind_submit <- function(buttonId) {
    observers[[paste0(".submit-", buttonId)]] <- shiny::observe({
      if (isTRUE(enabled())) {
        update_shad_button(buttonId, disabled = !self$is_valid(), session = session)
      }
    })
    invisible(self)
  }

  self$bind_summary <- function(id) {
    rules$summary_id <- id
    invisible(self)
  }

  self$.render_summary <- function() {
    errs <- drop_nulls(stats::setNames(
      lapply(names(rules$map), function(id) field_error(id)),
      names(rules$map)
    ))
    ui <- if (length(errs)) {
      shad_form_summary(
        paste0(rules$summary_id, "__inner"),
        title = sprintf("%d field%s need attention", length(errs),
                        if (length(errs) == 1) "" else "s"),
        errors = unlist(errs)
      )
    } else {
      NULL
    }
    session$output[[rules$summary_id]] <- shiny::renderUI(ui)
    invisible(NULL)
  }

  self
}
