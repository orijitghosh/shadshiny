# questionnaire --------------------------------------------------------------

.shad_question_scalar <- function(value, label) {
  if (is.null(value) || length(value) != 1L || is.list(value) ||
      !is.atomic(value) || is.na(value)) {
    stop(sprintf("`%s` must be a non-missing scalar value.", label), call. = FALSE)
  }
  as.character(value)
}

.shad_question_logical <- function(value, label) {
  if (length(value) != 1L || is.na(value) || !is.logical(value)) {
    stop(sprintf("`%s` must be TRUE or FALSE.", label), call. = FALSE)
  }
  isTRUE(value)
}

.shad_question_choices <- function(choices, type) {
  if (identical(type, "text")) {
    if (!is.null(choices)) {
      stop("text questions must not have choices.", call. = FALSE)
    }
    return(list())
  }
  if (is.null(choices) || !length(choices)) {
    stop(sprintf("%s questions require choices.", type), call. = FALSE)
  }

  # Questionnaire vectors use stable names as values and their contents as
  # labels, matching the serializable question contract. Unnamed vectors keep
  # the conventional value == label form; explicit item lists are unchanged.
  items <- if (!is.list(choices) && !is.null(names(choices))) {
    Map(function(value, label) list(value = value, label = label),
        names(choices), unname(choices))
  } else {
    normalize_choices(choices)
  }
  if (!is.list(items) || !length(items)) {
    stop("question choices must be a non-empty vector or item list.", call. = FALSE)
  }
  items <- lapply(items, function(item) {
    if (!is.list(item) || is.null(item$value)) {
      stop("question choices must contain value/label item lists.", call. = FALSE)
    }
    value <- .shad_question_scalar(item$value, "choice value")
    label <- if (is.null(item$label)) value else
      .shad_question_scalar(item$label, "choice label")
    if (!nzchar(value) || !nzchar(label)) {
      stop("question choice values and labels must be non-empty.", call. = FALSE)
    }
    list(value = value, label = label)
  })
  values <- vapply(items, `[[`, character(1), "value")
  if (anyDuplicated(values)) {
    stop("question choice values must be unique.", call. = FALSE)
  }
  items
}

.shad_question_conditions <- function(show_if) {
  if (is.null(show_if)) return(list())
  if (!is.list(show_if) || !length(show_if) || is.null(names(show_if)) ||
      any(!nzchar(names(show_if))) || anyDuplicated(names(show_if))) {
    stop("`show_if` must be a named list of scalar accepted values.", call. = FALSE)
  }
  lapply(show_if, .shad_question_scalar, label = "show_if value") |>
    stats::setNames(names(show_if))
}

.shad_question_shortcuts <- function(shortcuts, type, choices) {
  if (is.null(shortcuts)) return(NULL)
  if (identical(type, "text") || !is.atomic(shortcuts) || is.list(shortcuts) ||
      !length(shortcuts) || is.null(names(shortcuts)) ||
      any(!nzchar(names(shortcuts))) || anyDuplicated(names(shortcuts))) {
    stop("`shortcuts` must be a named vector for choice questions.", call. = FALSE)
  }
  keys <- as.character(shortcuts)
  if (anyNA(keys) || any(!nzchar(keys)) ||
      any(!grepl("^(Enter|Space|[[:alnum:][:punct:]])$", keys))) {
    stop("shortcut keys must be one printable key, Enter, or Space.", call. = FALSE)
  }
  values <- vapply(choices, `[[`, character(1), "value")
  unknown <- setdiff(names(shortcuts), values)
  if (length(unknown)) {
    stop("shortcut names must match a choice value.", call. = FALSE)
  }
  stats::setNames(keys, names(shortcuts))
}

#' Define one questionnaire question
#'
#' Experimental.
#' Creates a serializable question definition consumed by
#' [shad_questionnaire()]. Conditions are named equality checks; they are data,
#' not R or JavaScript callbacks.
#'
#' @param name Stable question name. Names must be non-empty and unique within
#'   one questionnaire.
#' @param prompt Question prompt rendered in the fieldset legend.
#' @param ... Reserved named HTML attributes for the question definition.
#' @param type One of `"single"`, `"multiple"`, or `"text"`.
#' @param choices A named/unnamed vector, or a list of `value`/`label` items,
#'   required for choice questions and forbidden for text questions.
#' @param description Optional help text.
#' @param required If `TRUE`, the question must be answered before advancing.
#' @param skippable If `TRUE`, the user may explicitly skip the question.
#' @param show_if Named list of question names to accepted values. All entries
#'   must match for this question to be visible.
#' @param shortcuts Named choice values mapped to printable keyboard keys.
#' @returns A serializable `shad_question` object.
#' @family shadshiny questionnaire
#' @examples
#' shad_question(
#'   "plan", "What should be built?", type = "single",
#'   choices = c("Server table" = "data", RTL = "rtl")
#' )
#' @export
shad_question <- function(name, prompt, ..., type = c("single", "multiple", "text"),
                           choices = NULL, description = NULL, required = TRUE,
                           skippable = FALSE, show_if = NULL, shortcuts = NULL) {
  name <- .shad_question_scalar(name, "name")
  if (!nzchar(name)) stop("question name must be non-empty.", call. = FALSE)
  type <- arg_match_shad(type, c("single", "multiple", "text"), "type")
  required <- .shad_question_logical(required, "required")
  skippable <- .shad_question_logical(skippable, "skippable")
  dots <- list(...)
  if (length(dots) && (is.null(names(dots)) || any(!nzchar(names(dots))) ||
                       anyDuplicated(names(dots)))) {
    stop("extra question attributes must be named and unique.", call. = FALSE)
  }
  if (!is.null(description) && !is_tag_like(description) &&
      (length(description) != 1L || is.na(description))) {
    stop("`description` must be a scalar value or HTML tag.", call. = FALSE)
  }
  choices <- .shad_question_choices(choices, type)
  show_if <- .shad_question_conditions(show_if)
  shortcuts <- .shad_question_shortcuts(shortcuts, type, choices)

  structure(
    list(
      name = name,
      prompt = prompt,
      attributes = dots,
      type = type,
      choices = choices,
      description = description,
      required = required,
      skippable = skippable,
      show_if = show_if,
      shortcuts = shortcuts
    ),
    class = "shad_question"
  )
}

.shad_question_index <- function(value, n, label = "active") {
  numeric_value <- suppressWarnings(as.numeric(value))
  if (length(value) != 1L || length(numeric_value) != 1L ||
      is.na(numeric_value) || !is.finite(numeric_value) ||
      numeric_value != floor(numeric_value) || numeric_value < 1L ||
      numeric_value > n) {
    stop(sprintf("`%s` must be a valid 1-based question index.", label), call. = FALSE)
  }
  as.integer(numeric_value)
}

.shad_question_named_list <- function(value, label, allow_null = TRUE) {
  if (is.null(value) && isTRUE(allow_null)) return(list())
  if (!is.list(value) || (length(value) &&
                          (is.null(names(value)) || any(!nzchar(names(value))) ||
                           anyDuplicated(names(value))))) {
    stop(sprintf("`%s` must be a named list.", label), call. = FALSE)
  }
  value
}

.shad_question_answer <- function(value, question) {
  if (identical(question$type, "multiple")) {
    if (is.null(value)) return(character())
    if (is.list(value) || !is.atomic(value) || anyNA(value)) {
      stop("multiple-question answers must be a character vector.", call. = FALSE)
    }
    answer <- unique(as.character(value))
    allowed <- vapply(question$choices, `[[`, character(1), "value")
    if (length(setdiff(answer, allowed))) {
      stop("answer contains a value not present in its question choices.", call. = FALSE)
    }
    return(answer)
  }
  if (is.null(value)) return(NULL)
  answer <- .shad_question_scalar(value, "answer")
  if (identical(question$type, "single")) {
    allowed <- vapply(question$choices, `[[`, character(1), "value")
    if (!answer %in% allowed) {
      stop("answer contains a value not present in its question choices.", call. = FALSE)
    }
  }
  answer
}

.shad_question_state <- function(value, questions) {
  names_questions <- vapply(questions, `[[`, character(1), "name")
  value <- value %||% list()
  if (!is.list(value)) stop("questionnaire `value` must be a list.", call. = FALSE)
  active <- .shad_question_index(value$active %||% 1L, length(questions))
  answers <- .shad_question_named_list(value$answers, "answers")
  unknown_answers <- setdiff(names(answers), names_questions)
  if (length(unknown_answers)) {
    stop("answers contain unknown question names.", call. = FALSE)
  }
  answers <- lapply(names(answers), function(name) {
    .shad_question_answer(answers[[name]], questions[[match(name, names_questions)]])
  }) |> stats::setNames(names(answers))
  skipped <- value$skipped %||% character()
  if (is.list(skipped) && !length(skipped)) skipped <- character()
  if (is.null(skipped) || !is.atomic(skipped) || anyNA(skipped)) {
    stop("`skipped` must be a character vector.", call. = FALSE)
  }
  skipped <- unique(as.character(skipped))
  if (length(setdiff(skipped, names_questions))) {
    stop("skipped contains unknown question names.", call. = FALSE)
  }
  complete <- value$complete %||% FALSE
  complete <- .shad_question_logical(complete, "complete")
  list(active = active, answers = answers, skipped = skipped, complete = complete)
}

.shad_question_json <- function(value) {
  if (is.atomic(value) && !is.null(names(value))) value <- as.list(value)
  json <- as.character(jsonlite::toJSON(
    value, auto_unbox = TRUE, na = "null", null = "null"
  ))
  # This JSON is placed in a data attribute. Keep the same text-safe boundary
  # if a text answer contains markup-like characters.
  gsub("<", "\\\\u003c", json, fixed = TRUE)
}

.shad_question_control <- function(question, input_id, answer, legend_id,
                                   description_id, error_id) {
  described_by <- paste(drop_nulls(c(description_id, error_id)), collapse = " ")
  if (identical(question$type, "text")) {
    return(htmltools::tags$input(
      class = "shad-questionnaire__text shad-input",
      id = paste0(input_id, "-", question$name),
      type = "text",
      name = paste0(input_id, "-", question$name),
      value = answer %||% "",
      `aria-labelledby` = legend_id,
      `aria-describedby` = if (nzchar(described_by)) described_by else NULL
    ))
  }

  input_type <- if (identical(question$type, "multiple")) "checkbox" else "radio"
  rows <- lapply(seq_along(question$choices), function(index) {
    choice <- question$choices[[index]]
    choice_id <- paste(input_id, question$name, index, sep = "-")
    checked <- if (identical(question$type, "multiple")) {
      choice$value %in% (answer %||% character())
    } else {
      identical(choice$value, answer)
    }
    input <- htmltools::tags$input(
      class = "shad-questionnaire__choice",
      id = choice_id,
      type = input_type,
      name = paste0(input_id, "-", question$name),
      value = choice$value,
      checked = flag_attr(checked),
      `aria-describedby` = if (nzchar(described_by)) described_by else NULL
    )
    htmltools::tags$label(
      class = "shad-questionnaire__choice-label",
      `for` = choice_id,
      input,
      htmltools::tags$span(class = "shad-questionnaire__choice-text", choice$label)
    )
  })
  htmltools::tags$div(class = "shad-questionnaire__choices", rows)
}

.shad_question_fieldset <- function(question, input_id, index, state) {
  legend_id <- paste(input_id, question$name, "legend", sep = "-")
  description_id <- if (is.null(question$description)) NULL else
    paste(input_id, question$name, "description", sep = "-")
  error_id <- paste(input_id, question$name, "error", sep = "-")
  answer <- state$answers[[question$name]]
  attrs <- question$attributes
  attrs$class <- shad_class("shad-questionnaire__question", extra = attrs$class)
  attrs$id <- paste(input_id, question$name, "question", sep = "-")
  attrs[["data-questionnaire-question"]] <- NA
  attrs[["data-question-name"]] <- question$name
  attrs[["data-question-index"]] <- index
  attrs[["data-question-type"]] <- question$type
  attrs[["data-required"]] <- flag_attr(question$required)
  attrs[["data-skippable"]] <- flag_attr(question$skippable)
  attrs[["data-show-if"]] <- if (length(question$show_if)) {
    .shad_question_json(question$show_if)
  }
  attrs[["data-shortcuts"]] <- if (!is.null(question$shortcuts)) {
    .shad_question_json(question$shortcuts)
  }
  if (index != state$active) {
    attrs$hidden <- NA
    attrs$inert <- NA
  }

  legend <- htmltools::tags$legend(id = legend_id, tabindex = "-1", question$prompt)
  description <- if (is.null(question$description)) NULL else
    htmltools::tags$div(
      id = description_id, class = "shad-questionnaire__description",
      question$description
    )
  error <- htmltools::tags$div(
    id = error_id, class = "shad-questionnaire__error",
    `data-question-error` = NA, role = "alert", hidden = NA
  )
  children <- list(
    legend, description,
    .shad_question_control(
      question, input_id, answer, legend_id, description_id, error_id
    ),
    error
  )
  do.call(htmltools::tags$fieldset, c(attrs, children))
}

#' Questionnaire input
#'
#' Experimental.
#' A bookmarkable, accessible sequence of single-choice, multiple-choice, and
#' freeform questions. The bound Shiny value is a JSON-safe list with
#' `active` (1-based index), `answers` (named list), `skipped` (question names),
#' and `complete` (logical). All questions remain in the DOM; inactive or
#' conditionally hidden questions are hidden and inert.
#'
#' @param inputId Input id.
#' @param ... [shad_question()] definitions.
#' @param value Initial or restored state, shaped as `list(active, answers,
#'   skipped, complete)`.
#' @param progress_label Text format with two `%s` values: current visible
#'   question and visible question count.
#' @param previous_label Previous-button label.
#' @param next_label Next-button label.
#' @param skip_label Skip-button label.
#' @param submit_label Submit-button label.
#' @param class Extra CSS classes.
#' @returns A questionnaire tag, bound as a Shiny input.
#' @family shadshiny questionnaire
#' @seealso [update_shad_questionnaire()]
#' @examples
#' shad_questionnaire(
#'   "onboarding",
#'   shad_question("plan", "Choose a plan", choices = c(Free = "free", Pro = "pro")),
#'   shad_question("notes", "Anything else?", type = "text", required = FALSE)
#' )
#' @export
shad_questionnaire <- function(
    inputId, ..., value = NULL, progress_label = "Question %s of %s",
    previous_label = "Previous", next_label = "Next", skip_label = "Skip",
    submit_label = "Submit", class = NULL) {
  questions <- list(...)
  if (!length(questions) ||
      !all(vapply(questions, inherits, logical(1), "shad_question"))) {
    stop("questionnaire requires one or more shad_question() definitions.", call. = FALSE)
  }
  names_questions <- vapply(questions, `[[`, character(1), "name")
  if (anyDuplicated(names_questions)) {
    stop("duplicate question names are not allowed within a questionnaire.", call. = FALSE)
  }
  for (question in questions) {
    unknown <- setdiff(names(question$show_if), names_questions)
    if (length(unknown)) {
      stop("show_if refers to an unknown question name.", call. = FALSE)
    }
  }
  labels <- list(progress_label, previous_label, next_label, skip_label, submit_label)
  if (any(!vapply(labels, function(x) length(x) == 1L && is.character(x) && !is.na(x), logical(1)))) {
    stop("questionnaire labels must be scalar character values.", call. = FALSE)
  }

  default <- list(active = 1L, answers = list(), skipped = character(), complete = FALSE)
  state <- .shad_question_state(shiny::restoreInput(id = inputId, default = value %||% default), questions)
  fieldsets <- Map(
    .shad_question_fieldset,
    questions, MoreArgs = list(input_id = inputId, state = state),
    index = seq_along(questions)
  )
  root <- htmltools::tags$div(
    class = shad_class("shad-questionnaire", extra = class),
    id = inputId,
    `data-shad` = "questionnaire",
    `data-active` = state$active,
    `data-value` = .shad_question_json(state),
    `data-progress-label` = progress_label,
    `data-previous-label` = previous_label,
    `data-next-label` = next_label,
    `data-skip-label` = skip_label,
    `data-submit-label` = submit_label,
    htmltools::tags$div(
      class = "shad-questionnaire__progress-wrap",
      htmltools::tags$div(
        class = "shad-questionnaire__progress",
        role = "progressbar", `aria-valuemin` = "0",
        `aria-valuemax` = length(questions), `aria-valuenow` = state$active,
        `aria-label` = sprintf(progress_label, state$active, length(questions)),
        htmltools::tags$span(class = "shad-questionnaire__progress-label",
                             sprintf(progress_label, state$active, length(questions)))
      )
    ),
    htmltools::tags$div(class = "shad-questionnaire__questions", fieldsets),
    htmltools::tags$div(
      class = "shad-questionnaire__status", `data-questionnaire-status` = NA,
      role = "status", `aria-live` = "polite", `aria-atomic` = "true"
    ),
    htmltools::tags$div(
      class = "shad-questionnaire__actions",
      htmltools::tags$button(
        type = "button", class = "shad-btn shad-btn--outline",
        `data-questionnaire-previous` = NA, previous_label
      ),
      htmltools::tags$button(
        type = "button", class = "shad-btn shad-btn--default",
        `data-questionnaire-next` = NA, next_label
      ),
      htmltools::tags$button(
        type = "button", class = "shad-btn shad-btn--ghost",
        `data-questionnaire-skip` = NA, skip_label
      ),
      htmltools::tags$button(
        type = "button", class = "shad-btn shad-btn--default",
        `data-questionnaire-submit` = NA, submit_label, hidden = NA
      )
    )
  )
  with_deps(root)
}

.shad_question_update_list <- function(value, label) {
  if (!is.list(value) || (length(value) &&
                          (is.null(names(value)) || any(!nzchar(names(value))) ||
                           anyDuplicated(names(value))))) {
    stop(sprintf("`%s` must be a named list.", label), call. = FALSE)
  }
  value
}

.shad_question_update_json_safe <- function(value, label) {
  if (is.function(value) || is.environment(value) || is.language(value)) {
    stop(sprintf("`%s` contains a non-serializable value.", label), call. = FALSE)
  }
  value
}

#' Update a questionnaire from the server
#'
#' Experimental.
#' Sends only the supplied state facets. `reset = TRUE` calls the client
#' instance's reset method. Answer and error lists must be named so module
#' instances and question definitions remain stable.
#'
#' @param id Input id (namespaced automatically).
#' @param active Optional 1-based active question index.
#' @param answers Optional named answer list.
#' @param errors Optional named question-error list; use `NULL` values to clear.
#' @param reset If `TRUE`, reset active state, answers, skips, errors, and
#'   completion.
#' @param session The Shiny session.
#' @returns Invisibly `NULL`.
#' @family shadshiny questionnaire
#' @export
update_shad_questionnaire <- function(
    id, active = NULL, answers = NULL, errors = NULL, reset = FALSE,
    session = shiny::getDefaultReactiveDomain()) {
  reset <- .shad_question_logical(reset, "reset")
  if (!is.null(active)) {
    numeric_active <- suppressWarnings(as.numeric(active))
    if (length(active) != 1L || length(numeric_active) != 1L ||
        is.na(numeric_active) || !is.finite(numeric_active) ||
        numeric_active != floor(numeric_active) || numeric_active < 1L) {
      stop("`active` must be a positive 1-based question index.", call. = FALSE)
    }
    active <- as.integer(numeric_active)
  }
  if (!is.null(answers)) answers <- .shad_question_update_list(answers, "answers")
  if (!is.null(errors)) errors <- .shad_question_update_list(errors, "errors")
  if (!is.null(answers)) {
    answers <- lapply(answers, .shad_question_update_json_safe, label = "answers")
  }
  if (!is.null(errors)) {
    errors <- lapply(errors, function(error) {
      if (is.null(error)) return(NULL)
      .shad_question_scalar(error, "error")
    })
  }
  if (reset) {
    shad_invoke(id, "reset", list(), session)
    return(invisible(NULL))
  }
  patch <- drop_nulls(list(active = active, answers = answers))
  if (length(patch)) shad_set_value(id, patch, session)
  if (!is.null(errors)) shad_invoke(id, "setErrors", list(errors), session)
  invisible(NULL)
}
