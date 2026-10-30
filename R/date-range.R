# date-range presets -----------------------------------------------------------

#' Default date-range presets
#'
#' A ready-made set of range presets for [shad_date_picker()]'s `presets`
#' argument: Today, Yesterday, Last 7 days, Last 30 days, This month, Last month.
#'
#' @returns A named list suitable for `shad_date_picker(presets=)`.
#' @family shadshiny tier-2 components
#' @examples
#' shad_date_picker("range", mode = "range", presets = shad_date_presets())
#' @export
shad_date_presets <- function() {
  list(
    "Today" = "today",
    "Yesterday" = "yesterday",
    "Last 7 days" = 7,
    "Last 30 days" = 30,
    "This month" = "this-month",
    "Last month" = "last-month"
  )
}

# Build the preset rail from a named list. Each value is a keyword
# ("today"/"yesterday"/"this-week"/"this-month"/"last-month"/"this-year"), an
# integer N (last N days), or a length-2 Date vector (explicit start/end).
.shad_build_presets <- function(presets) {
  labels <- names(presets)
  if (is.null(labels)) {
    stop("`presets` must be a named list (names are button labels).", call. = FALSE)
  }
  buttons <- lapply(seq_along(presets), function(i) {
    spec <- presets[[i]]
    attrs <- list(
      type = "button", class = "shad-date-range-presets__item"
    )
    if (inherits(spec, "Date") && length(spec) >= 2) {
      attrs[["data-start"]] <- .iso_date(spec[[1]])
      attrs[["data-end"]] <- .iso_date(spec[[2]])
    } else if (is.numeric(spec)) {
      attrs[["data-days"]] <- as.integer(spec)
    } else {
      attrs[["data-preset"]] <- as.character(spec)
    }
    do.call(htmltools::tags$button, c(attrs, list(labels[i])))
  })

  do.call(htmltools::tags$div, c(
    list(class = "shad-date-range-presets", `data-shad` = "date-range-presets",
         role = "group", `aria-label` = "Quick ranges"),
    buttons
  ))
}
