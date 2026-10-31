test_that(".iso_date formats Dates and date-like strings to ISO", {
  expect_identical(shadshiny:::.iso_date(as.Date("2026-07-11")), "2026-07-11")
  expect_identical(shadshiny:::.iso_date("2026-07-11"), "2026-07-11")
  expect_null(shadshiny:::.iso_date(NULL))
})

test_that("calendar range update serializes to {start,end} ISO strings", {
  s <- new_fake_session()
  update_shad_calendar("cal", value = c(as.Date("2026-01-01"),
                                        as.Date("2026-01-31")), session = s)
  msg <- one_message(s)$message
  expect_identical(msg$value, list(start = "2026-01-01", end = "2026-01-31"))
})

test_that("multi-combobox update preserves a length-1 value as a JSON array", {
  s <- new_fake_session()
  update_shad_combobox("cb", selected = "apple", multiple = TRUE, session = s)
  val <- one_message(s)$message$value
  json <- jsonlite::toJSON(val, auto_unbox = TRUE)
  expect_identical(as.character(json), "[\"apple\"]")
})

test_that("single-combobox update leaves the value a scalar", {
  s <- new_fake_session()
  update_shad_combobox("cb", selected = "apple", session = s)
  expect_identical(one_message(s)$message$value, "apple")
})

test_that("select and combobox updates send the strings the options carry", {
  # The constructors write as.character(value) into data-value. A bare number
  # would reach the browser as JSON 100000 and match neither "1e+05" nor
  # anything else, so the updaters have to send the same string.
  options <- function(tag) {
    nodes <- xml2::xml_find_all(render_xml(tag), "//*[@data-value]")
    xml2::xml_attr(nodes, "data-value")
  }
  choices <- c(Big = 1e5, Two = 2)
  expect_identical(options(shad_select("s", choices = choices)), c("1e+05", "2"))
  expect_identical(options(shad_combobox("c", choices = choices)), c("1e+05", "2"))

  sent <- function(f) {
    s <- new_fake_session()
    f(s)
    as.character(jsonlite::toJSON(one_message(s)$message$value, auto_unbox = TRUE))
  }
  expect_identical(sent(function(s) update_shad_select("s", 1e5, session = s)), "\"1e+05\"")
  expect_identical(sent(function(s) update_shad_select("s", 2, session = s)), "\"2\"")
  expect_identical(sent(function(s) update_shad_combobox("c", 1e5, session = s)), "\"1e+05\"")
  expect_identical(
    sent(function(s) update_shad_combobox("c", c(1e5, 2), multiple = TRUE, session = s)),
    "[\"1e+05\",\"2\"]"
  )
})

test_that("select and combobox updates still clear with NULL", {
  s <- new_fake_session()
  update_shad_select("s", NULL, session = s)
  update_shad_combobox("c", NULL, session = s)
  expect_null(s$messages[[1]]$message$value)
  expect_null(s$messages[[2]]$message$value)
})

test_that("toast payload has the expected shape", {
  s <- new_fake_session()
  shad_toast_success("Saved", description = "All good", id = "t1", session = s)
  m <- one_message(s)
  expect_identical(m$type, "shadshiny:toast")
  expect_identical(m$message$kind, "success")
  expect_identical(m$message$id, "t1")
  opts <- m$message$opts
  expect_identical(opts$message, "Saved")
  expect_identical(opts$title, "Saved")           # title defaults to message
  expect_identical(opts$description, "All good")
  expect_identical(opts$variant, "success")
  expect_identical(opts$duration, 5000)
})

test_that("loading toast omits duration entirely", {
  s <- new_fake_session()
  shad_toast_loading("Working", id = "t2", session = s)
  opts <- one_message(s)$message$opts
  expect_false("duration" %in% names(opts))
  expect_identical(one_message(s)$message$kind, "loading")
})

test_that("default-variant toast drops the variant key", {
  s <- new_fake_session()
  shad_toast("Hi", id = "t3", session = s)
  opts <- one_message(s)$message$opts
  expect_false("variant" %in% names(opts))
})
