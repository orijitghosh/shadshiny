# Smoke tests: representative constructors render to tags without error and
# carry their expected data-shad binding hook.

expect_renders <- function(tag) {
  expect_true(inherits(tag, c("shiny.tag", "shiny.tag.list")))
  expect_silent(as.character(tag))
  invisible(tag)
}

test_that("tier 1 display constructors render", {
  expect_renders(shad_button("Click"))
  expect_renders(shad_badge("New"))
  expect_renders(shad_avatar(fallback = "AB"))
  expect_renders(shad_alert(title = "Heads up", "Body"))
  expect_renders(shad_separator())
  expect_renders(shad_skeleton(width = "50%"))
  expect_renders(shad_spinner())
  expect_renders(shad_progress(value = 40))
  expect_renders(shad_breadcrumb(shad_breadcrumb_item("Home", href = "#")))
  expect_renders(shad_card(shad_card_content(shad_p("Hi"))))
  expect_renders(shad_table(data.frame(a = 1:2, b = c("x", "y"))))
  expect_renders(shad_table(shad_table_body(shad_table_row(shad_table_cell("x"))),
                            x = NULL))
  expect_renders(shad_kbd("Ctrl"))
  expect_renders(shad_h1("Title"))
})

test_that("tier 2 inputs render and expose a data-shad root", {
  binders <- list(
    shad_checkbox("chk", label = "Accept"),
    shad_switch("sw", label = "On"),
    shad_radio_group("rg", choices = c(A = "a", B = "b")),
    shad_slider("sl", min = 0, max = 100, value = 50),
    shad_select("sel", choices = c(A = "a", B = "b")),
    shad_combobox("cb", choices = c(A = "a", B = "b")),
    shad_toggle_group("tg", choices = c(A = "a", B = "b"), type = "single"),
    shad_input_otp("otp", length = 6, groups = c(3, 3)),
    shad_calendar("cal"),
    shad_date_picker("dp")
  )
  for (b in binders) {
    html <- as.character(b)
    expect_match(html, "data-shad", info = html)
  }
})

test_that("text inputs use native binding, not data-shad root", {
  expect_match(as.character(shad_input("txt", label = "Name")), "<input")
  expect_match(as.character(shad_textarea("ta", label = "Bio")), "<textarea")
})

test_that("tier 3 overlays and structure render", {
  expect_renders(shad_dialog("d", trigger = shad_button("Open"), title = "T",
                             shad_p("body")))
  expect_renders(shad_alert_dialog("ad", title = "Sure?", description = "d",
                                   trigger = shad_button("Go")))
  expect_renders(shad_sheet("sh", trigger = shad_button("Open"), title = "T"))
  expect_renders(shad_drawer("dr", trigger = shad_button("Open"), title = "T"))
  expect_renders(shad_popover("po", trigger = shad_button("Open"), shad_p("x")))
  expect_renders(shad_tooltip(trigger = shad_button("Hover"), content = "Tip"))
  expect_renders(shad_dropdown_menu("dm", trigger = shad_button("Menu"),
                                    shad_menu_item("a", "Item A")))
  expect_renders(shad_command("cmd", shad_command_group(
    "Group", shad_command_item("a", "Alpha"))))
  expect_renders(shad_tabs("tabs",
    shad_tab("one", "One", shad_p("1")),
    shad_tab("two", "Two", shad_p("2"))))
  expect_renders(shad_accordion("acc",
    shad_accordion_item("i1", "First", shad_p("a"))))
  expect_renders(shad_pagination("pg", pages = 5))
  expect_renders(shad_carousel("car", shad_carousel_item(shad_p("slide"))))
  expect_renders(shad_sidebar_layout("sbl",
    sidebar = shad_sidebar(shad_sidebar_item("home", "Home")),
    main = shad_p("main")))
})
