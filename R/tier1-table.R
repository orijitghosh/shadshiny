#' Table
#'
#' A styled table. Pass a data frame for automatic rendering, or compose
#' manually with the part constructors.
#'
#' @param x Optional data frame. When supplied, header and body are generated
#'   automatically.
#' @param ... Table sections when composing manually (and optional attributes).
#' @param striped,hover,sticky_header Style options.
#' @param caption Optional caption text.
#' @param class Extra CSS classes.
#' @returns A `<div class="shad-table-container">` wrapping a `<table>`.
#' @family shadshiny tier-1 components
#' @examples
#' shad_table(head(mtcars), striped = TRUE)
#' @export
shad_table <- function(x = NULL, ..., striped = FALSE, hover = FALSE,
                       sticky_header = FALSE, caption = NULL, class = NULL) {
  modifier <- c(
    if (isTRUE(striped)) "shad-table--striped",
    if (isTRUE(hover)) "shad-table--hover",
    if (isTRUE(sticky_header)) "shad-table--sticky"
  )
  caption_tag <- if (!is.null(caption)) shad_table_caption(caption)

  body <- if (!is.null(x)) {
    x <- as.data.frame(x)
    header <- shad_table_header(
      do.call(shad_table_row, lapply(names(x), function(nm) shad_table_head(nm)))
    )
    rows <- lapply(seq_len(nrow(x)), function(i) {
      # unname: named arguments would become <tr> attributes, not cells
      do.call(shad_table_row, unname(lapply(x[i, , drop = FALSE], function(v) shad_table_cell(format(v)))))
    })
    tbody <- do.call(shad_table_body, rows)
    list(caption_tag, header, tbody)
  } else {
    c(list(caption_tag), list(...))
  }

  tbl <- do.call(htmltools::tags$table, c(
    list(class = shad_class("shad-table", modifier)),
    drop_nulls(body)
  ))
  with_deps(htmltools::tags$div(
    class = shad_class("shad-table-container", extra = class), tbl
  ))
}

#' @rdname shad_table
#' @export
shad_table_header <- function(..., class = NULL) {
  htmltools::tags$thead(class = shad_class("shad-table__header", extra = class), ...)
}

#' @rdname shad_table
#' @export
shad_table_body <- function(..., class = NULL) {
  htmltools::tags$tbody(class = shad_class("shad-table__body", extra = class), ...)
}

#' @rdname shad_table
#' @export
shad_table_footer <- function(..., class = NULL) {
  htmltools::tags$tfoot(class = shad_class("shad-table__footer", extra = class), ...)
}

#' @rdname shad_table
#' @export
shad_table_row <- function(..., class = NULL) {
  htmltools::tags$tr(class = shad_class("shad-table__row", extra = class), ...)
}

#' @rdname shad_table
#' @param scope `<th>` scope attribute.
#' @export
shad_table_head <- function(..., scope = "col", class = NULL) {
  htmltools::tags$th(class = shad_class("shad-table__head", extra = class), scope = scope, ...)
}

#' @rdname shad_table
#' @export
shad_table_cell <- function(..., class = NULL) {
  htmltools::tags$td(class = shad_class("shad-table__cell", extra = class), ...)
}

#' @rdname shad_table
#' @export
shad_table_caption <- function(..., class = NULL) {
  htmltools::tags$caption(class = shad_class("shad-table__caption", extra = class), ...)
}
