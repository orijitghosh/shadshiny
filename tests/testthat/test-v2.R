# V2 feature tests: data table, theming, charts, validation, chat, constructors.

# --- data table serialization -------------------------------------------------

test_that("data-table model serializes cells, sort keys, and options", {
  df <- data.frame(
    id = c("a", "b"), amount = c(250.5, 1200),
    when = as.Date(c("2026-01-02", "2026-03-15")),
    status = c("active", "failed"), stringsAsFactors = FALSE
  )
  cols <- list(
    amount = shad_col("Amount", format = shad_fmt_number(2, prefix = "$")),
    status = shad_col("Status", format = shad_fmt_badge(c(active = "default", failed = "destructive")))
  )
  m <- shadshiny:::.shad_dt_model(
    df, cols, "id", TRUE, "both", TRUE, FALSE, "24rem", 10, c(10, 25),
    "No results.", "Filter...", "Columns", "Rows", FALSE
  )
  expect_length(m$columns, 4)
  expect_length(m$rows, 2)
  expect_identical(m$rows[[1]]$key, "a")
  # numeric formatter keeps a numeric sort key
  expect_equal(m$rows[[1]]$cells$amount$sort, 250.5)
  # date sort key is the epoch-day numeric
  expect_equal(m$rows[[2]]$cells$when$sort, as.numeric(as.Date("2026-03-15")))
  # badge cell carries rendered HTML
  expect_match(m$rows[[1]]$cells$status$html, "shad-badge")
  expect_true(m$options$globalFilter)
  expect_true(m$options$columnFilters)
})

test_that("data-table JSON emits an empty rows array for 0 rows", {
  df <- data.frame(x = integer(0), y = character(0))
  m <- shadshiny:::.shad_dt_model(df, NULL, NULL, TRUE, "none", FALSE, FALSE,
    "24rem", 10, c(10), "None", "F", "C", "R", FALSE)
  json <- shadshiny:::.shad_dt_json(m)
  expect_match(json, '"rows":\\[\\]')
})

test_that("data-table rejects list columns and enforces the cell budget", {
  df <- data.frame(x = 1:2)
  df$lst <- list(1:2, 3:4)
  expect_error(
    shadshiny:::.shad_dt_model(df, NULL, NULL, TRUE, "none", FALSE, FALSE,
      "24rem", 10, c(10), "", "", "", "", FALSE),
    "list-column"
  )
})

test_that("shad_data_table renders a bound input with the model script", {
  html <- as.character(shad_data_table("tbl", head(iris, 3), selection = "multiple"))
  expect_match(html, 'data-shad="data-table"')
  expect_match(html, 'data-selection="multiple"')
  expect_match(html, 'type="application/json"')
})

# --- theming ------------------------------------------------------------------

test_that("OKLCH converts to the expected hex", {
  expect_identical(shadshiny:::.oklch_to_hex("oklch(1 0 0)"), "#FFFFFF")
  expect_identical(shadshiny:::.oklch_to_hex("oklch(0 0 0)"), "#000000")
  expect_identical(shadshiny:::.oklch_to_hex("oklch(1 0 0 / 0.1)"), "#FFFFFF1A")
  # raw hex passes through untouched
  expect_identical(shadshiny:::.oklch_to_hex("#abc123"), "#abc123")
})

test_that("shad_chart_colors returns n hex colors and recycles past 6", {
  expect_length(shad_chart_colors(3), 3)
  expect_match(shad_chart_colors(1, "blue")[1], "^#[0-9A-F]{6}$")
  expect_warning(cols <- shad_chart_colors(8), "recycling")
  expect_length(cols, 8)
})

test_that("shad_tokens merges preset overrides", {
  base <- shad_tokens()
  blue <- shad_tokens("blue")
  expect_true("primary" %in% names(base))
  expect_false(identical(base$primary, blue$primary))
})

test_that("all theme presets resolve through page and token APIs", {
  presets <- c("slate", "stone", "blue", "green", "rose", "violet", "orange")

  for (preset in presets) {
    expect_match(
      as.character(shad_theme_preset(preset, "content")),
      sprintf('data-shad-theme="%s"', preset),
      fixed = TRUE,
      info = preset
    )
    expect_true(length(shad_tokens(preset)) > 0, info = preset)
  }
})

test_that("a theme preset can be scoped to one subtree", {
  html <- as.character(shad_theme_preset("green", shad_badge("Ready")))
  expect_match(html, 'data-shad-theme="green"', fixed = TRUE)
})

test_that("shad_theme maps args to tokens and renders CSS", {
  th <- shad_theme(primary = "#7c3aed", radius = "0.75rem",
                   dark = shad_theme(primary = "#a78bfa"))
  expect_s3_class(th, "shad_theme")
  css <- shadshiny:::.shad_theme_css(th)
  expect_match(css, "--shad-primary: #7c3aed;")
  expect_match(css, "data-bs-theme=\"dark\"")
  # R color names normalize to hex
  expect_identical(shadshiny:::.normalize_color("steelblue"), "#4682B4")
})

test_that("shad_theme accepts a bare list for dark, and rejects an unnamed one", {
  th <- shad_theme(primary = "#7c3aed", dark = list(primary = "#a78bfa"))
  expect_s3_class(th$dark, "shad_theme")
  expect_match(shadshiny:::.shad_theme_css(th), "--shad-primary: #a78bfa;")
  expect_identical(
    shad_theme(primary = "#7c3aed", dark = list(primary = "#a78bfa")),
    shad_theme(primary = "#7c3aed", dark = shad_theme(primary = "#a78bfa"))
  )
  expect_error(shad_theme(primary = "#7c3aed", dark = list("#a78bfa")),
               "fully named list")
})

test_that("shad_theme_from_registry maps upstream cssVars", {
  fix <- '{"cssVars":{"light":{"--primary":"oklch(0.6 0.2 250)","--radius":"0.5rem"},"dark":{"--primary":"oklch(0.7 0.2 250)"}}}'
  th <- shad_theme_from_registry(fix)
  expect_identical(th$tokens$primary, "oklch(0.6 0.2 250)")
  expect_identical(th$tokens$radius, "0.5rem")
  expect_identical(th$dark$tokens$primary, "oklch(0.7 0.2 250)")
})

# --- validation rules ---------------------------------------------------------

test_that("validation rules pass and fail correctly", {
  expect_equal(shad_rule_required()(""), "Required.")
  expect_equal(shad_rule_required()(FALSE), "Required.")
  expect_null(shad_rule_required()("x"))
  expect_match(shad_rule_email()("bad@"), "valid email")
  expect_null(shad_rule_email()("a@b.co"))
  expect_null(shad_rule_email()(""))          # optional empty skips
  expect_match(shad_rule_min_chars(8)("ab"), "at least 8")
  expect_null(shad_rule_min_chars(8)("abcdefgh"))
  expect_match(shad_rule_range(0, 10)(20), "between 0 and 10")
  expect_null(shad_rule_range(0, 10)(5))
})

# --- constructors render ------------------------------------------------------

test_that("V2 constructors render without error", {
  expect_match(as.character(shad_value_box("$1", "Rev", delta = "+2%")), "shad-value-box")
  expect_match(as.character(shad_timeline(shad_timeline_item("x"))), "shad-timeline")
  expect_match(as.character(shad_stepper("s", shad_step("A"), shad_step("B"))), 'data-shad="stepper"')
  expect_match(as.character(shad_tree("t", shad_tree_item("k", "L"))), 'data-shad="tree"')
  expect_match(as.character(shad_rating("r", value = 3)), 'data-shad="rating"')
  expect_match(as.character(shad_number_input("n", value = 1)), 'data-shad="number-stepper"')
  expect_match(as.character(shad_dropzone("d")), 'data-shad="dropzone"')
  expect_match(as.character(shad_form_message("x", type = "error")), "shad-form-message--error")
  expect_match(as.character(shad_chart_container(shiny::plotOutput("p"))), "shad-chart")
})

test_that("tree seeds initial selection as aria-selected", {
  html <- as.character(shad_tree("t",
    shad_tree_item("a", "A"), shad_tree_item("b", "B"), selected = "b"))
  expect_match(html, 'data-key="b"[^>]*aria-selected="true"')
})

test_that("shad_stepper 1-based active maps to 0-based data attribute", {
  html <- as.character(shad_stepper("s", shad_step("A"), shad_step("B"), active = 2))
  expect_match(html, 'data-active="1"')
})

test_that("date-picker presets require range mode", {
  expect_error(shad_date_picker("d", presets = shad_date_presets()), "range")
  expect_match(
    as.character(shad_date_picker("d", mode = "range", presets = shad_date_presets())),
    "shad-date-range-presets"
  )
})

test_that("shad_icon_raw injects the sizing class", {
  html <- as.character(shad_icon_raw('<svg viewBox="0 0 24 24"><path d="M5 12h14"/></svg>'))
  expect_match(html, 'class="shad-icon"')
})

test_that("validator updates controls nested in a fieldset unchanged", {
  html <- as.character(shad_fieldset(
    "Account",
    shad_form_field(
      shad_input("email"),
      label = "Email",
      description = "Used for account notifications."
    )
  ))
  expect_match(html, "<fieldset", fixed = TRUE)
  expect_match(html, 'data-shad="form-field"', fixed = TRUE)

  messages <- list()
  shiny::testServer(function(input, output, session) {
    session$sendCustomMessage <- function(type, message) {
      messages[[length(messages) + 1L]] <<- list(type = type, message = message)
      invisible(TRUE)
    }
    validator <- shad_validator(session)
    validator$add_rule("email", shad_rule_required())
    session$setInputs(email = "")

    expect_false(validator$validate())
    expect_length(messages, 1L)
    expect_identical(messages[[1L]]$type, "shadshiny:formField")
    expect_identical(messages[[1L]]$message$id, session$ns("email"))
    expect_identical(messages[[1L]]$message$error, "Required.")
  }, {})
})

# --- chat server --------------------------------------------------------------

test_that("chat server handles string and streaming handlers", {
  shiny::testServer(shad_chat_server, args = list(handler = function(u, h) paste("Echo:", u)), {
    session$setInputs(text = "hi", send = 1)
    msgs <- session$returned$messages()
    expect_length(msgs, 2)
    expect_identical(msgs[[2]]$content, "Echo: hi")
  })
  gen_handler <- function(u, h) {
    chunks <- c("Hel", "lo"); i <- 0L
    function() { i <<- i + 1L; if (i <= length(chunks)) chunks[i] else NULL }
  }
  shiny::testServer(shad_chat_server, args = list(handler = gen_handler), {
    session$setInputs(text = "hi", send = 1)
    for (k in 1:6) session$elapse(30)
    msgs <- session$returned$messages()
    expect_identical(msgs[[2]]$content, "Hello")
  })
})

test_that("the dataTable input handler normalizes selected and sort keys", {
  h <- shiny:::inputHandlers$get("shadshiny.dataTable")
  expect_true(is.function(h))

  wire <- list(
    selected = list("1", "3"),
    sort = list(list(col = "model", dir = "asc"),
                list(col = "mpg", dir = "desc")),
    filter = list(global = "", columns = list()),
    page = 1L, pageSize = 5L, requestId = 9L
  )
  out <- h(wire, NULL, "tbl")
  expect_identical(out$selected, c("1", "3"))
  expect_identical(out$sort[[1]], list(column = "model", direction = "asc"))
  expect_identical(out$sort[[2]], list(column = "mpg", direction = "desc"))
  # untouched keys pass straight through
  expect_identical(out$page, 1L)
  expect_identical(out$requestId, 9L)
  expect_identical(out$filter$global, "")

  # an empty selection is character(0), not list(); no sort is an empty list
  empty <- h(list(selected = list(), sort = list()), NULL, "tbl")
  expect_identical(empty$selected, character(0))
  expect_identical(empty$sort, list())
})
