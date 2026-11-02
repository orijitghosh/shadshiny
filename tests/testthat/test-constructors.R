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

test_that("a data frame renders one body cell per value", {
  html <- as.character(shad_table(data.frame(metric = c("Revenue", "Churn"),
                                             change = c("+12%", "-0.3pp"))))
  body <- sub(".*<tbody[^>]*>(.*)</tbody>.*", "\\1", html)

  expect_identical(lengths(regmatches(body, gregexpr("<td", body))), 4L)
  expect_match(body, "<td[^>]*>Revenue</td>")
  expect_match(body, "<td[^>]*>-0.3pp</td>")
  expect_no_match(body, "<tr[^>]*metric=")
})

test_that("manual table composition retains every public section helper", {
  html <- as.character(shad_table(
    shad_table_caption("Quarterly totals"),
    shad_table_header(shad_table_row(shad_table_head("Quarter"))),
    shad_table_body(shad_table_row(shad_table_cell("Q1"))),
    shad_table_footer(shad_table_row(shad_table_cell("Total"))),
    x = NULL
  ))

  expect_match(html, "<thead")
  expect_match(html, '<th[^>]*scope="col"')
  expect_match(html, "<tfoot")
  expect_match(html, "<caption")
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

test_that("toggle-group items retain icon and disabled metadata", {
  html <- as.character(shad_toggle_group(
    "tools",
    choices = list(shad_toggle_group_item(
      "add", label = "Add", icon = "plus", disabled = TRUE
    ))
  ))

  expect_match(html, 'data-value="add"')
  expect_match(html, "shad-icon")
  expect_match(html, "disabled")
})

test_that("select and combobox keep the placeholder when a value is preselected", {
  # The value span shows the selected label, so the browser needs the
  # placeholder separately to restore it when the value is cleared.
  sel <- as.character(shad_select("s", choices = c(Apple = "a", Pear = "p"),
                                  selected = "p", placeholder = "Fruit"))
  expect_match(sel, 'class="shad-select__value" data-placeholder-text="Fruit">Pear<')

  cbx <- as.character(shad_combobox("c", choices = c(Apple = "a", Pear = "p"),
                                    selected = "p", placeholder = "Fruit"))
  expect_match(cbx, 'class="shad-combobox__value" data-placeholder-text="Fruit">Pear<')
})

test_that("checkbox tri-state cycling is opt-in", {
  expect_match(as.character(shad_checkbox("all", "Select all", tristate = TRUE)),
               "data-tristate")
  expect_false(grepl("data-tristate", as.character(shad_checkbox("all", "Select all"))))
})

test_that("calendar caption layouts and year bounds reach the markup", {
  html <- as.character(shad_calendar("dob", month = "1993-06",
                                     caption_layout = "dropdown",
                                     year_range = c(1900, 2026)))
  expect_match(html, 'data-caption-layout="dropdown"')
  expect_match(html, 'data-from-year="1900"')
  expect_match(html, 'data-to-year="2026"')
  expect_match(html, 'data-month="1993-06"')

  # the default layout stays attribute-free
  expect_false(grepl("data-caption-layout", as.character(shad_calendar("plain"))))

  # date-picker forwards both to its inner calendar
  expect_match(as.character(shad_date_picker("dp2", caption_layout = "dropdown-years",
                                             year_range = c(1900, 2026))),
               'data-caption-layout="dropdown-years"')

  expect_error(shad_calendar("bad", year_range = 1900), "length-2")
  expect_error(shad_calendar("bad", caption_layout = "spinner"), "caption_layout")
})

test_that("text inputs use native binding, not data-shad root", {
  expect_match(as.character(shad_input("txt", label = "Name")), "<input")
  expect_match(as.character(shad_textarea("ta", label = "Bio")), "<textarea")
})

test_that("new tier 1 layout constructors render", {
  expect_renders(shad_item("Title", description = "d", media = "clock",
                           variant = "outline", size = "sm",
                           actions = shad_button("Edit", size = "sm")))
  expect_renders(shad_item_group(shad_item("A"), shad_item_separator(),
                                 shad_item("B")))
  expect_renders(shad_item("Link", href = "#"))
  expect_renders(shad_empty("Nothing here", description = "Add one",
                            media = "folder", media_variant = "icon",
                            content = shad_button("New")))
  expect_renders(shad_button_group(
    shad_button("Left", variant = "outline"),
    shad_button_group_text("or"),
    shad_button_group_separator(),
    shad_button("Right", variant = "outline"),
    aria_label = "Choose"))
  expect_renders(shad_button_group(shad_button("A"), orientation = "vertical"))
})

test_that("native-select exposes a data-shad root and renders options", {
  ns <- shad_native_select("ns", choices = c(A = "a", B = "b"), selected = "b")
  html <- as.character(ns)
  expect_match(html, 'data-shad="native-select"')
  expect_match(html, "<select")
  expect_match(html, "<option")
  grouped <- shad_native_select("ns2",
    choices = list(G1 = c(x = "1"), G2 = c(y = "2", z = "3")))
  expect_match(as.character(grouped), "<optgroup")
})

test_that("input-group wraps a control inside a group shell", {
  ig <- shad_input_group(
    shad_input_group_addon(shad_icon("search"), align = "inline-start"),
    shad_input("q", placeholder = "Search"),
    shad_input_group_addon(shad_input_group_button("Go", inputId = "go"),
                           align = "inline-end"),
    block = TRUE, invalid = TRUE)
  html <- as.character(ig)
  expect_match(html, 'role="group"')
  expect_match(html, "shad-input-group--block")
  expect_match(html, "data-invalid")
  expect_match(html, 'data-align="inline-start"')
  expect_match(html, "<input")
})

test_that("chat / AI kit constructors render", {
  expect_renders(shad_bubble("hi", variant = "muted", align = "end",
                             reactions = c("A 1", "B 2")))
  expect_renders(shad_bubble_group(shad_bubble("a"), shad_bubble("b")))
  expect_renders(shad_message("hello", sender = "Ada", meta = "9:41",
                              avatar = "AK"))
  expect_renders(shad_message(align = "end", avatar = "ME", state = "typing"))
  expect_renders(shad_message_group(shad_message("x")))
  expect_renders(shad_message_spinner())
  expect_renders(shad_attachment("f.pdf", description = "PDF", media = "file",
                                 actions = shad_attachment_action("x", "Remove"),
                                 state = "uploading"))
  expect_renders(shad_attachment_group(shad_attachment("a")))
  expect_renders(shad_marker("Thinking", icon = "clock", streaming = TRUE))
  expect_renders(shad_marker("Today", variant = "separator"))
  sc <- shad_message_scroller("chat", height = 400,
    shad_message_scroller_item(shad_marker("Today", variant = "separator"),
                               anchor = TRUE),
    shad_message_scroller_item(shad_bubble("Hi", align = "start")))
  expect_match(as.character(sc), 'data-shad="message-scroller"')
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
  expect_renders(shad_collapsible(
    "col", trigger = shad_button("Toggle"), shad_p("Body")
  ))
  expect_renders(shad_context_menu(
    "ctx", target = htmltools::div("Target"),
    shad_menu_item("open", "Open")
  ))
  expect_renders(shad_menubar(
    "bar", shad_menubar_menu("File", shad_menu_item("new", "New"))
  ))
  expect_renders(shad_navigation_menu(
    "nav", shad_navigation_menu_item("Docs", href = "#")
  ))
  expect_renders(shad_command("cmd", shad_command_group(
    "Group", shad_command_item("a", "Alpha"))))
  expect_renders(shad_tabs("tabs",
    shad_tab("one", "One", shad_p("1")),
    shad_tab("two", "Two", shad_p("2"))))
  expect_renders(shad_accordion("acc",
    shad_accordion_item("i1", "First", shad_p("a"))))
  expect_renders(shad_pagination("pg", pages = 5))
  expect_renders(shad_carousel("car", shad_carousel_item(shad_p("slide"))))
  expect_renders(shad_resizable(
    "split",
    shad_resizable_panel("A", default_size = 40),
    shad_resizable_handle(),
    shad_resizable_panel("B", default_size = 60)
  ))
  expect_renders(shad_sidebar_layout("sbl",
    sidebar = shad_sidebar(shad_sidebar_item("home", "Home")),
    main = shad_p("main")))
})
