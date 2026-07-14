# Bookmarking restore: every stateful constructor must seed its initial value
# from shiny::restoreInput(), so a bookmarked/restored app reopens with the
# saved values in the DOM (where each binding's getValue then reads them).

# Build a restore context carrying `value` for `id`, then render `expr` inside
# it and return the HTML. Returns NULL if the shiny internals we lean on move.
restore_html <- function(id, value, expr) {
  qs <- paste0(
    "?_inputs_&", id, "=",
    utils::URLencode(jsonlite::toJSON(value, auto_unbox = TRUE), reserved = TRUE)
  )
  rc <- shiny:::RestoreContext$new(qs)
  rc$flushPending()
  shiny:::withRestoreContext(rc, as.character(expr))
}

restore_api_available <- function() {
  ns <- asNamespace("shiny")
  exists("RestoreContext", ns) && exists("withRestoreContext", ns)
}

test_that("bookmarked values seed each stateful constructor", {
  skip_if_not_installed("jsonlite")
  skip_if_not(restore_api_available(), "shiny restore internals unavailable")

  # id, restored value, expression (uses a *different* default), marker regex
  cases <- list(
    list("i",  "ZZZ",  quote(shad_input("i", value = "def")),                      "value=\"ZZZ\""),
    list("t",  "ZZZ",  quote(shad_textarea("t", value = "def")),                    "ZZZ"),
    list("c",  TRUE,   quote(shad_checkbox("c", value = FALSE)),                    "data-state=\"checked\""),
    list("w",  TRUE,   quote(shad_switch("w", value = FALSE)),                      "data-state=\"checked\""),
    list("s",  42,     quote(shad_slider("s", min = 0, max = 100, value = 0)),      "data-value=\"42\""),
    list("sel","x",    quote(shad_select("sel", choices = c("a","b","x"), selected = "a")),        "data-value=\"x\" data-state=\"checked\""),
    list("n",  "x",    quote(shad_native_select("n", choices = c("a","b","x"), selected = "a")),   "value=\"x\" selected"),
    list("r",  "x",    quote(shad_radio_group("r", choices = c("a","b","x"), selected = "a")),     "data-value=\"x\" data-state=\"checked\""),
    list("cb", "x",    quote(shad_combobox("cb", choices = c("a","b","x"), selected = "a")),       "data-value=\"x\" data-state=\"checked\""),
    list("tg2",TRUE,   quote(shad_toggle("tg2", value = FALSE)),                    "data-state=\"on\""),
    list("tgr","x",    quote(shad_toggle_group("tgr", choices = c("a","b","x"), selected = "a")),  "data-value=\"x\" data-state=\"on\""),
    list("cal","2024-03-14", quote(shad_calendar("cal", value = as.Date("2020-01-01"))),           "data-value=\"2024-03-14\""),
    list("dp", "2024-03-14", quote(shad_date_picker("dp", value = as.Date("2020-01-01"))),         "data-value=\"2024-03-14\""),
    list("tb", "b",    quote(shad_tabs("tb", shad_tab("a","A","x"), shad_tab("b","B","y"), selected = "a")), "id=\"tb\" data-value=\"b\""),
    list("p",  7L,     quote(shad_pagination("p", pages = 9, selected = 1)),        "data-page=\"7\""),
    list("ac", "s1",   quote(shad_accordion("ac", shad_accordion_item("s1","T","B"), value = NULL)), "data-value=\"s1\" data-open")
  )

  for (case in cases) {
    id <- case[[1]]; value <- case[[2]]; expr <- case[[3]]; marker <- case[[4]]
    html <- restore_html(id, value, eval(expr))
    expect_match(html, marker, fixed = FALSE,
                 info = paste("restore did not seed", id))
  }
})

test_that("no restore context leaves defaults untouched", {
  # Outside any restore context restoreInput() returns the default, so the
  # rendered output must be byte-identical to a build with no bookmarking.
  expect_match(as.character(shad_input("i", value = "def")), "value=\"def\"")
  expect_match(as.character(shad_slider("s", value = 5)), "data-value=\"5\"")
  expect_no_match(as.character(shad_checkbox("c", value = FALSE)),
                  "data-state=\"checked\"")
})
