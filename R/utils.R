# Internal utilities -----------------------------------------------------------

#' Validate an argument against a set of allowed values
#'
#' Like [base::match.arg()] but produces a message that names the calling
#' function and argument, and never partial-matches.
#' @noRd
arg_match_shad <- function(arg, choices, arg_name = deparse(substitute(arg)),
                           fn = as.character(sys.call(-1)[[1]])) {
  if (missing(choices)) {
    stop("`choices` must be supplied to arg_match_shad().", call. = FALSE)
  }
  if (length(arg) > 1) arg <- arg[[1]]
  if (is.null(arg) || !arg %in% choices) {
    stop(sprintf(
      "`%s` must be one of %s, not %s.",
      arg_name,
      paste(sprintf('"%s"', choices), collapse = ", "),
      if (is.null(arg)) "NULL" else sprintf('"%s"', as.character(arg))
    ), call. = FALSE)
  }
  arg
}

#' Package-scoped unique id counter
#' @noRd
.shad_uid_env <- new.env(parent = emptyenv())
.shad_uid_env$counter <- 0L

#' Generate a stable-ish unique id (per R session)
#' @noRd
shad_uid <- function(prefix = "shad") {
  .shad_uid_env$counter <- .shad_uid_env$counter + 1L
  paste0("shad-", prefix, "-", .shad_uid_env$counter)
}

#' Merge a base class vector with a user-supplied `class` argument
#' @noRd
shad_class <- function(..., extra = NULL) {
  base <- unlist(list(...), use.names = FALSE)
  base <- base[!is.na(base) & nzchar(base)]
  extra <- if (is.null(extra)) character() else unlist(strsplit(paste(extra, collapse = " "), "\\s+"))
  extra <- extra[nzchar(extra)]
  paste(c(base, extra), collapse = " ")
}

#' Drop NULL elements from a list
#' @noRd
drop_nulls <- function(x) x[!vapply(x, is.null, logical(1))]

#' Coerce a logical flag into an attribute value (present or absent)
#'
#' Returns `NA` (htmltools renders a valueless boolean attribute) when `flag`
#' is TRUE, and `NULL` (attribute omitted) otherwise.
#' @noRd
flag_attr <- function(flag) {
  if (isTRUE(flag)) NA else NULL
}

#' Split `...` into named attributes and unnamed children (htmltools style)
#' @noRd
split_dots <- function(...) {
  dots <- list(...)
  nms <- names(dots)
  if (is.null(nms)) nms <- rep("", length(dots))
  is_attr <- nzchar(nms)
  list(
    attribs = dots[is_attr],
    children = dots[!is_attr]
  )
}

#' A width style string, or NULL
#' @noRd
width_style <- function(width) {
  if (is.null(width)) return(NULL)
  paste0("width:", htmltools::validateCssUnit(width), ";")
}

#' Attach the bundled shadshiny dependency to a tag
#' @noRd
with_deps <- function(tag) {
  htmltools::attachDependencies(tag, shadshiny_dependency(), append = TRUE)
}

#' Normalise a `choices` argument into a list of item specs
#'
#' Accepts: a named character vector (names = labels, values = values), an
#' unnamed character vector (value == label), or a list of item constructor
#' outputs (passed through untouched). Returns a list of
#' `list(value=, label=)` for the vector forms, or the original list.
#' @noRd
normalize_choices <- function(choices) {
  if (is.null(choices)) return(list())
  if (is.list(choices)) return(choices)
  vals <- unname(choices)
  labs <- names(choices)
  if (is.null(labs)) labs <- as.character(vals)
  labs[!nzchar(labs)] <- as.character(vals[!nzchar(labs)])
  mapply(function(v, l) list(value = as.character(v), label = l), vals, labs,
         SIMPLIFY = FALSE, USE.NAMES = FALSE)
}

#' TRUE if a value looks like an htmltools tag / tagList
#' @noRd
is_tag_like <- function(x) {
  inherits(x, c("shiny.tag", "shiny.tag.list", "html"))
}
