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
    expect_identical(messages[[1L]]$type, "shadshiny:invoke")
    expect_identical(messages[[1L]]$message$method, "enableServerMode")

    session$setInputs(tbl = list(
      page = 1L, pageSize = 2L, sort = list(),
      filter = list(global = "", columns = list())
    ))
    expect_length(messages, 1L)

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
    expect_identical(messages[[2L]]$message$method, "setServerError")
    expect_identical(messages[[2L]]$message$args[[1L]]$message, "Unable to load data.")
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
    expect_length(messages, 2L)
    expect_identical(messages[[2L]]$message$method, "setServerError")
    expect_identical(messages[[2L]]$message$args[[1L]]$requestId, 1L)
    expect_identical(messages[[2L]]$message$args[[1L]]$message, "Unable to load data.")
  }, {})
})
