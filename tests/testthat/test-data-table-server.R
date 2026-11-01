# Contract: what shad_data_table_server() lets through to `source`. Any other
# request is refused before `source` runs: a warning with the detail on the
# server, and the fixed "Unable to load data." state in the browser. The
# browser half is at the top of tests/js/data-table-contract.test.js.
# 1. page and page size are positive whole numbers, the page size is at most
#    max_page_size (1000 by default), and (page - 1) * page_size fits in an R
#    integer, so OFFSET arithmetic in `source` never turns into NA.
# 2. Each sort entry names a column and "asc" or "desc", both scalar strings,
#    and no column is sorted twice. With `columns`, a sort column must be
#    declared and sortable.
# 3. The global filter and each column filter are scalar strings. With
#    `columns`, a filtered column must be declared and filterable.
# 4. A response may not hold more rows than the page size asked for. With
#    `columns`, it offers sorting and filtering only where 2 and 3 allow
#    them; other columns still show, so the browser never asks for a sort or
#    filter the server would refuse.

test_that("server table requests normalize the public input shape", {
  request <- shadshiny:::.shad_dt_request(list(
    requestId = 7,
    page = 2,
    pageSize = 25,
    sort = list(list(column = "mpg", direction = "desc")),
    filter = list(global = "mazda", columns = list(cyl = "6"))
  ))

  expect_identical(request$request_id, 7L)
  expect_identical(request$page, 2L)
  expect_identical(request$page_size, 25L)
  expect_identical(request$sort[[1]], list(column = "mpg", direction = "desc"))
  expect_identical(request$filter$columns$cyl, "6")
})

test_that("server table requests reject unsafe pagination and sort values", {
  expect_error(
    shadshiny:::.shad_dt_request(list(page = 0, pageSize = 0)),
    "positive"
  )
  expect_error(
    shadshiny:::.shad_dt_request(list(
      page = 1, pageSize = 25,
      sort = list(list(column = "mpg", direction = "sideways"))
    )),
    "asc.*desc"
  )
  expect_error(
    shadshiny:::.shad_dt_request(list(filter = list(columns = list("6")))),
    "named list"
  )
})

test_that("server table pages stay within max_page_size and integer range (1)", {
  request <- shadshiny:::.shad_dt_request
  expect_identical(request(list(pageSize = 1000))$page_size, 1000L)
  expect_error(request(list(pageSize = 1001)), "page size.*1000")
  expect_identical(
    request(list(pageSize = 5000), max_page_size = 5000L)$page_size, 5000L
  )
  # the offset of the millionth page of 1000 still fits an R integer
  expect_identical(request(list(page = 1e6, pageSize = 1000))$page, 1000000L)
  expect_error(
    request(list(page = .Machine$integer.max, pageSize = 2)),
    "page.*out of range"
  )
})

test_that("server table requests take scalar strings and sort a column once (2, 3)", {
  request <- shadshiny:::.shad_dt_request
  expect_error(
    request(list(sort = list(list(column = list("a"), direction = "asc")))),
    "sort column"
  )
  expect_error(
    request(list(sort = list(list(column = "a", direction = list("asc"))))),
    "asc.*desc"
  )
  expect_error(
    request(list(sort = list(list(column = "a", direction = "asc"),
                             list(column = "a", direction = "desc")))),
    "more than once"
  )
  expect_error(request(list(filter = list(global = list(x = "a")))), "global filter")
  expect_error(
    request(list(filter = list(columns = list(a = list(b = "x"))))),
    "column filters"
  )
})

test_that("server helper validates max_page_size (1)", {
  expect_error(
    shad_data_table_server("tbl", identity, max_page_size = 0, session = NULL),
    "max_page_size.*positive whole number"
  )
  expect_error(
    shad_data_table_server("tbl", identity, max_page_size = 2.5, session = NULL),
    "max_page_size.*positive whole number"
  )
  expect_error(
    shad_data_table_server("tbl", identity, max_page_size = NA, session = NULL),
    "max_page_size.*positive whole number"
  )
})

test_that("server table response row keys are unique and non-missing", {
  request <- shadshiny:::.shad_dt_request(list(pageSize = 2))
  duplicate <- data.frame(id = c("a", "a"), value = 1:2)
  missing <- data.frame(id = c("a", NA_character_), value = 1:2)

  expect_error(
    shadshiny:::.shad_dt_response(
      list(data = duplicate, total_rows = 2L, filtered_rows = 2L),
      request, NULL, "id"
    ),
    "unique"
  )
  expect_error(
    shadshiny:::.shad_dt_response(
      list(data = missing, total_rows = 2L, filtered_rows = 2L),
      request, NULL, "id"
    ),
    "missing"
  )
})

test_that("server table responses validate counts and page bounds", {
  request <- shadshiny:::.shad_dt_request(list(page = 2, pageSize = 2))
  valid <- list(
    data = data.frame(id = c("b", "c"), mpg = c(20, 30)),
    total_rows = 10L,
    filtered_rows = 3L
  )

  response <- shadshiny:::.shad_dt_response(valid, request, NULL, "id")
  expect_identical(response$requestId, 0L)
  expect_identical(response$totalRows, 10L)
  expect_identical(response$filteredRows, 3L)
  expect_identical(vapply(response$rows, `[[`, character(1), "key"), c("b", "c"))

  expect_error(
    shadshiny:::.shad_dt_response(
      list(total_rows = 10L, filtered_rows = 3L), request, NULL, "id"
    ),
    "data"
  )
  expect_error(
    shadshiny:::.shad_dt_response(
      list(data = valid$data, total_rows = -1L, filtered_rows = 0L),
      request, NULL, "id"
    ),
    "total_rows"
  )
  expect_error(
    shadshiny:::.shad_dt_response(
      list(data = valid$data, total_rows = 2L, filtered_rows = 3L),
      request, NULL, "id"
    ),
    "filtered_rows.*total_rows"
  )
  expect_error(
    shadshiny:::.shad_dt_response(
      list(data = rbind(valid$data, data.frame(id = "d", mpg = 40)),
           total_rows = 10L, filtered_rows = 3L),
      request, NULL, "id"
    ),
    "page size"
  )
})

test_that("server table responses reuse the existing cell serialization", {
  request <- shadshiny:::.shad_dt_request(list(requestId = 4, pageSize = 2))
  response <- shadshiny:::.shad_dt_response(
    list(
      data = data.frame(
        id = c("a", "b"),
        amount = c(250.5, 1200),
        status = c("active", "failed"),
        stringsAsFactors = FALSE
      ),
      total_rows = 2L,
      filtered_rows = 2L
    ),
    request,
    list(
      amount = shad_col("Amount", format = shad_fmt_number(2, prefix = "$")),
      status = shad_col(
        "Status",
        format = shad_fmt_badge(c(active = "default", failed = "destructive"))
      )
    ),
    "id"
  )

  expect_identical(response$requestId, 4L)
  expect_equal(response$rows[[1]]$cells$amount$sort, 250.5)
  expect_match(response$rows[[2]]$cells$status$html, "shad-badge")
  expect_identical(response$columns[[2]]$label, "Amount")
})

test_that("server helper enables the table and answers validated requests", {
  messages <- list()
  shiny::testServer(function(input, output, session) {
    session$sendCustomMessage <- function(type, message) {
      messages[[length(messages) + 1L]] <<- list(type = type, message = message)
      invisible(TRUE)
    }
    source <- function(request) {
      data <- data.frame(
        id = c("b", "c"), name = c("Beta", "Gamma"),
        stringsAsFactors = FALSE
      )
      list(data = data, total_rows = 8L, filtered_rows = 2L)
    }
    observer <- shad_data_table_server(
      "tbl", source,
      columns = list(id = shad_col("ID"), name = shad_col("Name")),
      row_key = "id", session = session
    )
    expect_s3_class(observer, "Observer")
    expect_length(messages, 0L)

    session$setInputs(tbl = list(
      page = 1L, pageSize = 2L, sort = list(),
      filter = list(global = "", columns = list())
    ))
    expect_length(messages, 1L)
    expect_identical(messages[[1L]]$type, "shadshiny:invoke")
    expect_identical(messages[[1L]]$message$method, "enableServerMode")

    session$setInputs(tbl = list(
      requestId = 1L, page = 1L, pageSize = 2L,
      sort = list(), filter = list(global = "", columns = list())
    ))
    session$flushReact()

    expect_length(messages, 2L)
    expect_identical(messages[[2L]]$type, "shadshiny:invoke")
    expect_identical(messages[[2L]]$message$method, "setServerPage")
    expect_identical(messages[[2L]]$message$args[[1L]]$requestId, 1L)
    expect_identical(messages[[2L]]$message$args[[1L]]$filteredRows, 2L)

    observer$destroy()
    session$setInputs(tbl = list(
      requestId = 2L, page = 2L, pageSize = 2L,
      sort = list(), filter = list(global = "", columns = list())
    ))
    session$flushReact()
    expect_length(messages, 2L)
  }, {})
})

test_that("server helper enables each table as it arrives, rendered late or anew", {
  # A table from renderUI() reaches the browser after the server function
  # has run, and a re-rendered one starts again in client mode with request
  # IDs from 1. Each sends its first value without a requestId; that value,
  # not the server function's start, switches it to server mode. Within one
  # table, a request older than the last one answered is stale.
  messages <- list()
  shiny::testServer(function(input, output, session) {
    session$sendCustomMessage <- function(type, message) {
      messages[[length(messages) + 1L]] <<- list(type = type, message = message)
      invisible(TRUE)
    }
    source <- function(request) {
      list(data = data.frame(id = "a"), total_rows = 1L, filtered_rows = 1L)
    }
    shad_data_table_server("tbl", source, session = session)
    arrive <- function(page_size) {
      session$setInputs(tbl = list(
        page = 1L, pageSize = page_size, sort = list(),
        filter = list(global = "", columns = list())
      ))
    }
    ask <- function(id) {
      session$setInputs(tbl = list(
        requestId = id, page = 1L, pageSize = 2L, sort = list(),
        filter = list(global = "", columns = list())
      ))
    }
    methods <- function() vapply(messages, function(m) m$message$method, "")

    expect_length(messages, 0L)
    arrive(10L)
    ask(1L)
    ask(2L)
    ask(1L)                         # stale
    expect_identical(methods(), c("enableServerMode", "setServerPage", "setServerPage"))

    arrive(25L)                     # rendered anew
    ask(1L)
    expect_identical(methods()[4:5], c("enableServerMode", "setServerPage"))
    expect_identical(messages[[5L]]$message$args[[1L]]$requestId, 1L)
  }, {})
})

test_that("server helper rejects columns outside the declared allowlist", {
  messages <- list()
  calls <- 0L
  shiny::testServer(function(input, output, session) {
    session$sendCustomMessage <- function(type, message) {
      messages <<- append(messages, list(list(type = type, message = message)))
      invisible(TRUE)
    }
    shad_data_table_server(
      "tbl", function(request) calls <<- calls + 1L,
      columns = list(id = shad_col("ID")), session = session
    )
    expect_warning(session$setInputs(tbl = list(
      requestId = 1L, page = 1L, pageSize = 2L,
      sort = list(list(col = "not_declared", dir = "asc")),
      filter = list(global = "", columns = list())
    )), "unknown column")
    expect_identical(calls, 0L)
    expect_identical(messages[[1L]]$message$method, "setServerError")
    expect_identical(messages[[1L]]$message$args[[1L]]$message, "Unable to load data.")
  }, {})
})

test_that("server table responses offer sorts and filters only where allowed (4)", {
  request <- shadshiny:::.shad_dt_request(list(pageSize = 2))
  response <- shadshiny:::.shad_dt_response(
    list(
      data = data.frame(id = c("a", "b"), name = c("Alpha", "Beta"),
                        note = c("x", "y")),
      total_rows = 2L, filtered_rows = 2L
    ),
    request,
    list(id = shad_col("ID"), name = shad_col("Name", sortable = FALSE)),
    "id"
  )
  flags <- lapply(response$columns, `[`, c("key", "sortable", "filterable"))
  expect_identical(flags, list(
    list(key = "id", sortable = TRUE, filterable = TRUE),
    list(key = "name", sortable = FALSE, filterable = TRUE),
    # not declared: shown, but neither, as the request check refuses both
    list(key = "note", sortable = FALSE, filterable = FALSE)
  ))
})

test_that("server helper refuses sorts and filters the columns do not allow (2, 3)", {
  messages <- list()
  calls <- 0L
  shiny::testServer(function(input, output, session) {
    session$sendCustomMessage <- function(type, message) {
      messages <<- append(messages, list(list(type = type, message = message)))
      invisible(TRUE)
    }
    source <- function(request) {
      calls <<- calls + 1L
      list(data = data.frame(id = "a", name = "Alpha"), total_rows = 1L,
           filtered_rows = 1L)
    }
    shad_data_table_server(
      "tbl", source,
      columns = list(
        id = shad_col("ID"),
        name = shad_col("Name", sortable = FALSE, filterable = FALSE)
      ),
      session = session
    )
    ask <- function(id, sort = list(), columns = list()) {
      session$setInputs(tbl = list(
        requestId = id, page = 1L, pageSize = 2L, sort = sort,
        filter = list(global = "", columns = columns)
      ))
    }
    last_method <- function() messages[[length(messages)]]$message$method

    expect_warning(ask(1L, sort = list(list(col = "name", dir = "asc"))),
                   "not sortable")
    expect_identical(last_method(), "setServerError")
    expect_warning(ask(2L, columns = list(name = "Al")), "not filterable")
    expect_identical(last_method(), "setServerError")
    expect_identical(calls, 0L)

    ask(3L, sort = list(list(col = "id", dir = "desc")), columns = list(id = "a"))
    expect_identical(calls, 1L)
    expect_identical(last_method(), "setServerPage")
  }, {})
})

test_that("server helper refuses a page larger than max_page_size (1)", {
  messages <- list()
  sizes <- integer()
  shiny::testServer(function(input, output, session) {
    session$sendCustomMessage <- function(type, message) {
      messages <<- append(messages, list(list(type = type, message = message)))
      invisible(TRUE)
    }
    source <- function(request) {
      sizes <<- c(sizes, request$page_size)
      list(data = data.frame(id = "a"), total_rows = 1L, filtered_rows = 1L)
    }
    shad_data_table_server("tbl", source, max_page_size = 50, session = session)
    ask <- function(id, size) {
      session$setInputs(tbl = list(
        requestId = id, page = 1L, pageSize = size, sort = list(),
        filter = list(global = "", columns = list())
      ))
    }
    expect_warning(ask(1L, 51L), "page size.*50")
    expect_identical(messages[[length(messages)]]$message$method, "setServerError")
    ask(2L, 50L)
    expect_identical(sizes, 50L)
  }, {})
})

test_that("server helper emits a fixed error message and warns with internal detail", {
  messages <- list()
  shiny::testServer(function(input, output, session) {
    session$sendCustomMessage <- function(type, message) {
      messages[[length(messages) + 1L]] <<- list(type = type, message = message)
      invisible(TRUE)
    }
    shad_data_table_server(
      "tbl", function(request) stop("database password=secret"), session = session
    )
    expect_warning(session$setInputs(tbl = list(
      requestId = 1L, page = 1L, pageSize = 2L,
      sort = list(), filter = list(global = "", columns = list())
    )), "database password=secret")
    expect_length(messages, 1L)
    expect_identical(messages[[1L]]$message$method, "setServerError")
    expect_identical(messages[[1L]]$message$args[[1L]]$requestId, 1L)
    expect_identical(messages[[1L]]$message$args[[1L]]$message, "Unable to load data.")
  }, {})
})
