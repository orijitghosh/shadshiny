# input-otp --------------------------------------------------------------------

.shad_otp_separator <- htmltools::HTML(paste0(
  '<div class="shad-otp__separator" aria-hidden="true">',
  '<svg class="shad-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" ',
  'stroke-width="2" stroke-linecap="round"><path d="M5 12h14"/></svg></div>'
))

#' One-time-code input
#'
#' A shadcn OTP input: one real hidden input overlays a row of rendered cells.
#' `input$<inputId>` is the string as typed (may be partial).
#'
#' @param inputId Input id.
#' @param length Total number of cells / code length.
#' @param groups Optional integer vector splitting cells into groups separated by
#'   a divider (e.g. `c(3, 3)`). Must sum to `length`.
#' @param label Optional label (wraps in [shad_form_field()]).
#' @param pattern `"numeric"` (digits only) or `"alphanumeric"` (any character).
#' @param disabled If `TRUE`, disables the control.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the OTP root.
#' @returns An OTP input tag.
#' @family shadshiny tier-2 components
#' @examples
#' shad_input_otp("code", length = 6, groups = c(3, 3))
#' @export
shad_input_otp <- function(inputId, length = 6, groups = NULL, label = NULL,
                           pattern = c("numeric", "alphanumeric"),
                           disabled = FALSE, class = NULL, ...) {
  pattern <- arg_match_shad(pattern, c("numeric", "alphanumeric"), "pattern")
  if (is.null(groups)) groups <- length
  groups <- as.integer(groups)
  if (sum(groups) != length) {
    stop("`groups` must sum to `length`.", call. = FALSE)
  }

  cell <- htmltools::tags$div(class = "shad-otp__cell", `aria-hidden` = "true")
  group_tags <- lapply(groups, function(n) {
    do.call(htmltools::tags$div,
            c(list(class = "shad-otp__group"), rep(list(cell), n)))
  })
  # Interleave separators between groups.
  body <- list()
  for (i in seq_along(group_tags)) {
    if (i > 1) body <- c(body, list(.shad_otp_separator))
    body <- c(body, list(group_tags[[i]]))
  }

  real_input <- htmltools::tags$input(
    class = "shad-otp__input",
    type = "text",
    inputmode = if (pattern == "numeric") "numeric" else NULL,
    autocomplete = "one-time-code",
    `aria-label` = "One-time code",
    disabled = flag_attr(disabled)
  )

  root <- do.call(htmltools::tags$div, c(
    list(
      class = shad_class("shad-otp", extra = if (is.null(label)) class),
      `data-shad` = "input-otp",
      id = inputId,
      `data-length` = length,
      `data-pattern` = if (pattern == "numeric") "\\d" else NULL,
      `data-disabled` = flag_attr(disabled),
      ...
    ),
    list(real_input),
    body
  ))

  if (is.null(label)) return(with_deps(root))
  shad_form_field(root, label = label, class = class)
}
