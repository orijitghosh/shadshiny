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

.shad_dt_integer <- function(value, default, label, positive = FALSE) {
  value <- value %||% default
  numeric_value <- suppressWarnings(as.numeric(value))
  lower_bound <- if (isTRUE(positive)) 1 else 0
  if (length(value) != 1L || length(numeric_value) != 1L ||
      is.na(numeric_value) || !is.finite(numeric_value) ||
      numeric_value != floor(numeric_value) ||
      numeric_value < lower_bound || numeric_value > .Machine$integer.max) {
    qualifier <- if (isTRUE(positive)) "positive" else "non-negative"
    stop(sprintf("server table %s must be %s integers", label, qualifier),
         call. = FALSE)
  }
  as.integer(numeric_value)
}

.shad_dt_request <- function(value) {
  value <- value %||% list()
  if (!is.list(value)) {
    stop("server table request must be a list", call. = FALSE)
  }

  sort <- value$sort %||% list()
  if (!is.list(sort)) {
    stop("server table sort must be a list", call. = FALSE)
  }
  sort <- lapply(sort, function(entry) {
    if (!is.list(entry)) {
      stop("server table sort entries must be lists", call. = FALSE)
    }
    column <- entry$column %||% entry$col
    direction <- entry$direction %||% entry$dir
    if (length(column) != 1L || is.na(column) || !nzchar(as.character(column))) {
      stop("server table sort column must be a non-empty string", call. = FALSE)
    }
    direction <- as.character(direction)
    if (length(direction) != 1L || is.na(direction) ||
        !direction %in% c("asc", "desc")) {
      stop("server table sort direction must be asc or desc", call. = FALSE)
    }
    list(column = as.character(column), direction = direction)
  })

  filter <- value$filter %||% list()
  if (!is.list(filter)) {
    stop("server table filter must be a list", call. = FALSE)
  }
  global <- filter$global %||% ""
  if (length(global) != 1L || is.na(global)) {
    stop("server table global filter must be a scalar string", call. = FALSE)
  }
  column_filters <- filter$columns %||% list()
  if (!is.list(column_filters) ||
      (length(column_filters) > 0L &&
       (is.null(names(column_filters)) || any(!nzchar(names(column_filters)))))) {
    stop("server table column filters must be a named list", call. = FALSE)
  }
  column_filters <- lapply(column_filters, function(entry) {
    if (length(entry) != 1L || is.na(entry)) {
      stop("server table column filters must contain scalar strings", call. = FALSE)
    }
    as.character(entry)
  })

  list(
    request_id = .shad_dt_integer(value$requestId, 0L, "request id"),
    page = .shad_dt_integer(value$page, 1L, "page", positive = TRUE),
    page_size = .shad_dt_integer(value$pageSize, 25L, "page size", positive = TRUE),
    sort = sort,
    filter = list(global = as.character(global), columns = column_filters)
  )
}

.shad_dt_response_count <- function(value, label) {
  .shad_dt_integer(value, NULL, label)
}

.shad_dt_response <- function(value, request, columns, row_key) {
  if (!is.list(value) || is.null(value$data) || !is.data.frame(value$data)) {
    stop("server table response `data` must be a data.frame", call. = FALSE)
  }
  total_rows <- .shad_dt_response_count(value$total_rows, "total_rows")
  filtered_rows <- .shad_dt_response_count(value$filtered_rows, "filtered_rows")
  if (filtered_rows > total_rows) {
    stop("server table filtered_rows cannot exceed total_rows", call. = FALSE)
  }
  if (nrow(value$data) > request$page_size) {
    stop("server table response exceeds the requested page size", call. = FALSE)
  }
  if (!is.null(row_key)) {
    response_keys <- as.character(value$data[[row_key]])
    if (anyNA(response_keys) || any(!nzchar(response_keys))) {
      stop("server table row keys must not be missing or empty", call. = FALSE)
    }
    if (anyDuplicated(response_keys)) {
      stop("server table row keys must be unique", call. = FALSE)
    }
  }

  model <- .shad_dt_model(
    value$data, columns, row_key, TRUE, "none", FALSE, FALSE, "24rem",
    request$page_size, request$page_size, "No results.", "Filter rows...",
    "Columns", "Rows per page", FALSE
  )
  list(
    requestId = request$request_id,
    rows = model$rows,
    columns = model$columns,
    totalRows = total_rows,
    filteredRows = filtered_rows
  )
}

.shad_dt_server_columns <- function(columns) {
  if (is.null(columns)) return(NULL)
  if (!is.list(columns) || is.null(names(columns)) ||
      any(!nzchar(names(columns))) || anyDuplicated(names(columns))) {
    stop("server table `columns` must be a named list", call. = FALSE)
  }
  empty <- as.data.frame(
    stats::setNames(lapply(names(columns), function(x) character()), names(columns)),
    stringsAsFactors = FALSE
  )
  .shad_dt_model(
    empty, columns, NULL, TRUE, "none", FALSE, FALSE, "24rem", 10L,
    c(10L, 25L, 50L, 100L), "No results.", "Filter rows...",
    "Columns", "Rows per page", FALSE
  )$columns
}

.shad_dt_server_check_columns <- function(request, columns) {
  if (is.null(columns)) return(invisible(NULL))
  known <- names(columns)
  sort_columns <- vapply(request$sort, `[[`, character(1), "column")
  bad_sort <- setdiff(sort_columns, known)
  bad_filter <- setdiff(names(request$filter$columns), known)
  if (length(bad_sort) || length(bad_filter)) {
    bad <- unique(c(bad_sort, bad_filter))[[1L]]
    stop(sprintf("server table request refers to unknown column `%s`", bad), call. = FALSE)
  }
  invisible(NULL)
}

.shad_dt_server_error <- function(id, request_id, session) {
  shad_invoke(id, "setServerError", list(list(
    requestId = as.integer(request_id),
    message = "Unable to load data."
  )), session)
}

#' Server-backed interactive data table
#'
#' Experimental server-side paging for [shad_data_table()]. The table sends a
#' normalized request to `source` whenever its page, page size, sort, or filter
#' changes. `source` must return a list with `data` (a data frame containing at
#' most the requested page), `total_rows`, and `filtered_rows`.
#'
#' The request passed to `source` has `page`, `page_size`, `sort` (a list of
#' `column`/`direction` pairs), and `filter` (a global string plus named column
#' filters). The response is serialized using the same [shad_col()] formatters
#' and trusted-HTML rules as the client-side table.
#'
#' Supply a stable `row_key` column when selections must survive paging. With
#' `row_key = NULL`, the existing page-local row-index behavior is retained and
#' is not suitable for cross-page selection. This helper deliberately does not
#' provide editing, grouping, pivoting, aggregation, downloads, or database
#' adapter behavior; the source owns query construction and parameterization.
#'
#' @param id The data-table input id.
#' @param source A function accepting one normalized request list and returning
#'   `list(data = <data.frame>, total_rows = <integer>, filtered_rows =
#'   <integer>)`.
#' @param columns Optional named list of [shad_col()] specs. When omitted,
#'   column metadata is inferred from the first response.
#' @param row_key Optional stable id column in each response page.
#' @param session The Shiny session.
#' @returns Invisibly, the Shiny observer driving the source.
#' @family shadshiny data table
#' @export
shad_data_table_server <- function(
    id, source, columns = NULL, row_key = NULL,
    session = shiny::getDefaultReactiveDomain()) {
  if (!is.function(source)) stop("`source` must be a function.", call. = FALSE)
  if (!is.null(row_key) &&
      (length(row_key) != 1L || is.na(row_key) || !nzchar(as.character(row_key)))) {
    stop("`row_key` must be a non-empty column name or NULL.", call. = FALSE)
  }
  column_meta <- .shad_dt_server_columns(columns)
  shad_invoke(id, "enableServerMode", list(list(
    columns = column_meta, totalRows = 0L, filteredRows = 0L
  )), session)

  last_request_id <- -1L
  observer <- shiny::observeEvent(
    session$input[[id]],
    {
      raw <- session$input[[id]]
      raw_id <- suppressWarnings(as.numeric(raw$requestId %||% 0L))
      request_id <- if (length(raw_id) == 1L && is.finite(raw_id) &&
                        raw_id == floor(raw_id) && raw_id >= 0 &&
                        raw_id <= .Machine$integer.max) as.integer(raw_id) else 0L
      result <- tryCatch({
        request <- .shad_dt_request(raw)
        .shad_dt_server_check_columns(request, columns)
        request
      }, error = function(e) {
        warning(conditionMessage(e), call. = FALSE)
        .shad_dt_server_error(id, request_id, session)
        NULL
      })
      if (is.null(result) || result$request_id < 1L ||
          result$request_id <= last_request_id) return(invisible(NULL))
      last_request_id <- result$request_id

      answer <- tryCatch(source(result), error = function(e) {
        warning(sprintf("server-backed data table source failed: %s", conditionMessage(e)),
                call. = FALSE)
        NULL
      })
      if (is.null(answer)) {
        .shad_dt_server_error(id, result$request_id, session)
        return(invisible(NULL))
      }
      response <- tryCatch(
        .shad_dt_response(answer, result, columns, row_key),
        error = function(e) {
          warning(sprintf("server-backed data table response failed: %s", conditionMessage(e)),
                  call. = FALSE)
          NULL
        }
      )
      if (is.null(response)) {
        .shad_dt_server_error(id, result$request_id, session)
        return(invisible(NULL))
      }
      shad_invoke(id, "setServerPage", list(response), session)
      invisible(NULL)
    },
    ignoreNULL = TRUE,
    domain = session
  )
  session$onSessionEnded(function() observer$destroy())
  invisible(observer)
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
