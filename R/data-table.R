# data-table -------------------------------------------------------------------

#' Column specification for [shad_data_table()]
#'
#' Describe how a single data-table column renders. Pass a named list of these
#' as the `columns` argument of [shad_data_table()], keyed by data-frame column
#' name; any column without a spec uses sensible type-based defaults.
#'
#' @param header Column header label. `NULL` uses the data-frame column name.
#' @param sortable Whether the column is sortable. `NULL` inherits the table's
#'   `sortable` master switch.
#' @param filterable Whether the per-column filter (when enabled) applies here.
#'   `NULL` defaults to `TRUE`.
#' @param align `"left"` (default), `"center"`, or `"right"`.
#' @param width Optional CSS width for the column header.
#' @param visible Whether the column starts visible (column-visibility menu can
#'   toggle it).
#' @param html If `TRUE`, the column's character values are treated as trusted,
#'   pre-rendered HTML rather than escaped text. Mutually exclusive with
#'   `format`/`cell`.
#' @param format A formatter from `shad_fmt_number()`, `shad_fmt_percent()`,
#'   `shad_fmt_date()`, or `shad_fmt_badge()`. Mutually exclusive with `cell`.
#' @param cell A function `function(value, row)` returning an htmltools tag or
#'   character string, evaluated in R at render time (for embedding
#'   [shad_badge()], [shad_button()], links, …). Mutually exclusive with
#'   `format`.
#' @returns A `shad_col` specification list.
#' @family shadshiny data table
#' @examples
#' shad_col("Amount", format = shad_fmt_number(prefix = "$"))
#' shad_col("Status", cell = function(v, row) shad_badge(v))
#' @export
shad_col <- function(header = NULL, sortable = NULL, filterable = NULL,
                     align = c("left", "center", "right"), width = NULL,
                     visible = TRUE, html = FALSE, format = NULL, cell = NULL) {
  align <- match.arg(align)
  if (!is.null(format) && !is.null(cell)) {
    stop("`format` and `cell` are mutually exclusive in shad_col().", call. = FALSE)
  }
  if (isTRUE(html) && (!is.null(format) || !is.null(cell))) {
    stop("`html = TRUE` cannot combine with `format`/`cell` in shad_col().",
         call. = FALSE)
  }
  if (!is.null(cell) && !is.function(cell)) {
    stop("`cell` must be a function(value, row) in shad_col().", call. = FALSE)
  }
  if (!is.null(format) && !inherits(format, "shad_fmt")) {
    stop("`format` must come from a shad_fmt_*() function.", call. = FALSE)
  }
  structure(
    list(header = header, sortable = sortable, filterable = filterable,
         align = align, width = width, visible = isTRUE(visible),
         html = isTRUE(html), format = format, cell = cell),
    class = "shad_col"
  )
}

# --- formatters ---------------------------------------------------------------
# A shad_fmt is a function(x) -> list of per-cell {html, text, sort} lists,
# carrying numeric sort keys so formatted display strings still order correctly.

#' Cell formatters for [shad_data_table()]
#'
#' Declarative column formatters passed to `shad_col(format=)`. Each renders a
#' display string while preserving a numeric (or raw) sort key so ordering stays
#' correct.
#'
#' @param digits Decimal places.
#' @param big_mark Thousands separator (number formatter).
#' @param prefix,suffix Strings wrapped around the formatted value.
#' @param format A [base::strftime()] format string (date formatter).
#' @param map A named vector mapping cell values to [shad_badge()] variants,
#'   e.g. `c(active = "default", failed = "destructive")`.
#' @returns A `shad_fmt` object (a function of the column vector).
#' @name shad_fmt
#' @family shadshiny data table
#' @examples
#' shad_fmt_number(digits = 2, prefix = "$")
#' shad_fmt_percent(digits = 1)
#' shad_fmt_date("%b %d, %Y")
#' shad_fmt_badge(c(active = "default", failed = "destructive"))
NULL

.as_shad_fmt <- function(fn) structure(fn, class = "shad_fmt")

.cell_num <- function(display, sort) {
  # plain-text display (escaped into html so textContent-only cells still show)
  # with an explicit numeric sort key.
  mapply(function(d, s) {
    if (is.na(s)) return(NULL)
    list(html = htmltools::htmlEscape(d), text = d, sort = s)
  }, display, sort, SIMPLIFY = FALSE, USE.NAMES = FALSE)
}

#' @rdname shad_fmt
#' @export
shad_fmt_number <- function(digits = 2, big_mark = ",", prefix = "", suffix = "") {
  .as_shad_fmt(function(x) {
    num <- suppressWarnings(as.numeric(x))
    disp <- ifelse(is.na(num), NA_character_,
                   paste0(prefix,
                          formatC(num, format = "f", digits = digits,
                                  big.mark = big_mark),
                          suffix))
    .cell_num(disp, num)
  })
}

#' @rdname shad_fmt
#' @export
shad_fmt_percent <- function(digits = 1) {
  .as_shad_fmt(function(x) {
    num <- suppressWarnings(as.numeric(x))
    disp <- ifelse(is.na(num), NA_character_,
                   paste0(formatC(100 * num, format = "f", digits = digits), "%"))
    .cell_num(disp, num)
  })
}

#' @rdname shad_fmt
#' @export
shad_fmt_date <- function(format = "%Y-%m-%d") {
  .as_shad_fmt(function(x) {
    d <- if (inherits(x, c("Date", "POSIXct"))) x else as.Date(as.character(x))
    disp <- ifelse(is.na(d), NA_character_, format(d, format))
    .cell_num(disp, as.numeric(d))
  })
}

#' @rdname shad_fmt
#' @export
shad_fmt_badge <- function(map) {
  .as_shad_fmt(function(x) {
    xs <- as.character(x)
    lapply(xs, function(v) {
      if (is.na(v)) return(NULL)
      variant <- if (!is.na(map[v]) && nzchar(map[v])) unname(map[v]) else "default"
      html <- htmltools::doRenderTags(shad_badge(v, variant = variant))
      list(html = html, text = v, sort = v)
    })
  })
}

# --- serialization ------------------------------------------------------------

# Serialize a single (unformatted) column vector to a list of cell values.
.shad_dt_default_cells <- function(vec, html_col) {
  if (isTRUE(html_col)) {
    return(lapply(as.character(vec), function(v) if (is.na(v)) NULL else list(html = v)))
  }
  if (inherits(vec, c("Date", "POSIXct"))) {
    disp <- ifelse(is.na(vec), NA_character_, format(vec))
    return(.cell_num(disp, as.numeric(vec)))
  }
  if (is.numeric(vec)) {
    return(lapply(vec, function(v) if (is.na(v)) NULL else v))
  }
  if (is.factor(vec)) vec <- as.character(vec)
  if (is.logical(vec)) vec <- ifelse(is.na(vec), NA_character_, as.character(vec))
  lapply(as.character(vec), function(v) if (is.na(v)) NULL else v)
}

# Build the {columns, rows, options} model list for jsonlite.
.shad_dt_model <- function(data, columns, row_key, sortable, filter,
                           column_visibility, sticky_header, max_height,
                           page_size, page_sizes, empty, filter_placeholder,
                           columns_label, page_size_label, loading) {
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  nms <- names(data)
  n <- nrow(data)

  # row keys
  keys <- if (!is.null(row_key)) {
    if (!row_key %in% nms) stop(sprintf("`row_key` \"%s\" is not a column.", row_key), call. = FALSE)
    as.character(data[[row_key]])
  } else {
    as.character(seq_len(n))
  }

  cols_meta <- list()
  col_cells <- list()   # colKey -> list of n cells
  for (nm in nms) {
    spec <- columns[[nm]]
    if (is.null(spec)) spec <- shad_col()
    vec <- data[[nm]]

    if (inherits(vec, "list")) {
      stop(sprintf("Column \"%s\" is a list-column; flatten it or provide a `cell` function.", nm),
           call. = FALSE)
    }

    cells <- if (!is.null(spec$cell)) {
      rows_list <- lapply(seq_len(n), function(i) as.list(data[i, , drop = FALSE]))
      lapply(seq_len(n), function(i) {
        out <- spec$cell(vec[[i]], rows_list[[i]])
        if (is_tag_like(out)) {
          list(html = htmltools::doRenderTags(out), text = .strip_tags_text(vec[[i]]))
        } else if (is.na(out[1])) {
          NULL
        } else {
          list(html = htmltools::htmlEscape(as.character(out)), text = as.character(out))
        }
      })
    } else if (!is.null(spec$format)) {
      spec$format(vec)
    } else {
      .shad_dt_default_cells(vec, spec$html)
    }
    col_cells[[nm]] <- cells

    is_sortable <- if (!is.null(spec$sortable)) isTRUE(spec$sortable) else isTRUE(sortable)
    is_filterable <- if (!is.null(spec$filterable)) isTRUE(spec$filterable) else TRUE
    cols_meta[[length(cols_meta) + 1L]] <- drop_nulls(list(
      key = nm,
      label = spec$header %||% nm,
      sortable = is_sortable,
      filterable = is_filterable,
      visible = spec$visible
    ))
  }

  # assemble rows
  rows <- lapply(seq_len(n), function(i) {
    cells <- lapply(nms, function(nm) col_cells[[nm]][[i]])
    names(cells) <- nms
    list(key = keys[i], cells = cells)
  })

  opts <- drop_nulls(list(
    selection = NULL,  # carried as a data attribute instead
    globalFilter = filter %in% c("global", "both"),
    columnFilters = filter %in% c("columns", "both"),
    columnVisibility = isTRUE(column_visibility),
    sticky = isTRUE(sticky_header),
    maxHeight = if (isTRUE(sticky_header)) max_height else NULL,
    pageSize = page_size,
    pageSizes = page_sizes,
    loading = isTRUE(loading),
    emptyText = if (is.character(empty)) empty else NULL,
    emptyHtml = if (is_tag_like(empty)) htmltools::doRenderTags(empty) else NULL,
    filterPlaceholder = filter_placeholder,
    columnsLabel = columns_label,
    pageSizeLabel = page_size_label
  ))

  list(columns = cols_meta, rows = rows, options = opts)
}

.strip_tags_text <- function(x) {
  if (is_tag_like(x)) return(trimws(gsub("<[^>]*>", "", htmltools::doRenderTags(x))))
  as.character(x)
}

# Serialize a model list to a compact JSON string with numeric sort keys intact.
.shad_dt_json <- function(model) {
  jsonlite::toJSON(model, auto_unbox = TRUE, na = "null", null = "null",
                   json_verbatim = TRUE, digits = NA)
}

#' Interactive data table
#'
#' A shadcn-styled data table: client-side multi-sort (Shift+click), global and
#' per-column filtering, windowed pagination, row selection, and column
#' visibility, rendered from a data frame. It is a bound Shiny input:
#' `input$<inputId>` is a list with `selected` (row keys), `sort`, `filter`,
#' `page`, and `pageSize`. Only the current page is in the DOM, so it stays
#' responsive to a few thousand rows; for larger or server-computed data push
#' new rows with [update_shad_data_table()].
#'
#' Row identity comes from `row_key` (a column of stable ids) or the 1-based row
#' index. Selection is reported as these keys.
#'
#' @param inputId Input id.
#' @param data A data frame (or object coercible with [as.data.frame()]).
#' @param columns Optional named list of [shad_col()] specs, keyed by column
#'   name. Columns without a spec use type-based defaults.
#' @param row_key Optional column name providing stable row identities. `NULL`
#'   uses the row index.
#' @param selection `"none"` (default), `"single"`, or `"multiple"`.
#' @param filter `"none"` (default), `"global"`, `"columns"`, or `"both"`.
#' @param page_size Initial rows per page.
#' @param page_sizes Selectable page sizes.
#' @param sortable Master switch for column sorting (per-column overridable in
#'   [shad_col()]).
#' @param column_visibility Show the column-visibility dropdown.
#' @param sticky_header Freeze the header and scroll the body within
#'   `max_height`.
#' @param max_height Viewport height when `sticky_header = TRUE`.
#' @param empty Text or tags shown when there are no rows.
#' @param filter_placeholder Placeholder for the global filter input.
#' @param columns_label,page_size_label Labels for the column-visibility trigger
#'   and page-size select.
#' @param loading If `TRUE`, render skeleton rows until [update_shad_data_table()]
#'   supplies data.
#' @param width CSS width.
#' @param class Extra CSS classes.
#' @param ... Extra attributes on the root.
#' @returns A data-table tag, bound as a Shiny input.
#' @family shadshiny data table
#' @examples
#' if (interactive()) {
#'   shad_data_table(
#'     "tbl", head(mtcars),
#'     selection = "multiple", filter = "global",
#'     columns = list(mpg = shad_col("MPG", format = shad_fmt_number(1)))
#'   )
#' }
#' @export
shad_data_table <- function(inputId, data, columns = NULL, row_key = NULL,
                            selection = c("none", "single", "multiple"),
                            filter = c("none", "global", "columns", "both"),
                            page_size = 10, page_sizes = c(10, 25, 50, 100),
                            sortable = TRUE, column_visibility = FALSE,
                            sticky_header = FALSE, max_height = "24rem",
                            empty = "No results.",
                            filter_placeholder = "Filter rows...",
                            columns_label = "Columns",
                            page_size_label = "Rows per page",
                            loading = FALSE, width = NULL, class = NULL, ...) {
  selection <- arg_match_shad(selection, c("none", "single", "multiple"), "selection")
  filter <- arg_match_shad(filter, c("none", "global", "columns", "both"), "filter")

  n_cells <- (if (is.null(data)) 0L else nrow(as.data.frame(data))) *
    (if (is.null(data)) 0L else ncol(as.data.frame(data)))
  if (n_cells > 1e6) {
    stop("data-table exceeds 1,000,000 cells; pre-aggregate or page server-side.",
         call. = FALSE)
  } else if (n_cells > 1e5) {
    warning("data-table over 100,000 cells: client-side rendering may lag. Consider server-side paging.",
            call. = FALSE)
  }

  model <- .shad_dt_model(
    data, columns, row_key, sortable, filter, column_visibility, sticky_header,
    max_height, page_size, page_sizes, empty, filter_placeholder, columns_label,
    page_size_label, loading
  )

  root <- htmltools::tags$div(
    class = shad_class("shad-data-table", extra = class),
    id = inputId,
    `data-shad` = "data-table",
    `data-selection` = if (selection != "none") selection else NULL,
    `data-sticky` = flag_attr(sticky_header),
    `data-global-filter` = flag_attr(filter %in% c("global", "both")),
    `data-column-filters` = flag_attr(filter %in% c("columns", "both")),
    `data-page-size` = page_size,
    style = width_style(width),
    ...,
    htmltools::tags$script(
      type = "application/json",
      htmltools::HTML(.shad_dt_json(model))
    )
  )
  with_deps(root)
}

#' Update a data table from the server
#'
#' Push new rows to a [shad_data_table()] (replacing its data while keeping
#' selection keys) and/or patch its interaction state.
#'
#' @param id The input id (namespaced automatically).
#' @param data Optional new data frame; sent via the table's `setData()`.
#' @param columns The [shad_col()] specs used when re-serializing `data`. Supply
#'   the same specs used at construction for consistent formatting.
#' @param row_key Row-key column (as in [shad_data_table()]) for the new data.
#' @param selected Optional character vector of row keys to select.
#' @param page,page_size Optional pagination patch.
#' @param loading Optional logical to toggle the skeleton state.
#' @param session The Shiny session.
#' @returns Invisibly `NULL`.
#' @family shadshiny data table
#' @export
update_shad_data_table <- function(id, data = NULL, columns = NULL,
                                    row_key = NULL, selected = NULL,
                                    page = NULL, page_size = NULL,
                                    loading = NULL,
                                    session = shiny::getDefaultReactiveDomain()) {
  if (!is.null(data)) {
    model <- .shad_dt_model(
      data, columns, row_key, TRUE, "none", FALSE, FALSE, "24rem",
      page_size %||% 10, c(10, 25, 50, 100), "No results.", "Filter rows...",
      "Columns", "Rows per page", FALSE
    )
    shad_invoke(id, "setData", list(model$rows), session)
  }
  patch <- drop_nulls(list(
    selected = if (!is.null(selected)) I(as.character(selected)) else NULL,
    page = page, pageSize = page_size, loading = loading
  ))
  if (length(patch)) shad_set_value(id, patch, session)
  invisible(NULL)
}
