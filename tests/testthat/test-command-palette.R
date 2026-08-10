# Command palette: item coercion, dialog wiring, trigger, server refresh.

html <- function(x) as.character(htmltools::as.tags(x))

test_that("a named vector becomes a flat item list", {
  h <- html(shad_command_palette("p", items = c(Home = "home", Away = "away")))
  expect_match(h, '<button type="button" class="shad-command__item" data-value="home">Home')
  expect_match(h, 'data-value="away">Away')
  expect_false(grepl("shad-command__group", h, fixed = TRUE))
})

test_that("a named list becomes separated groups", {
  h <- html(shad_command_palette("p", items = list(
    "Go to" = c(Home = "home"), "Actions" = c(New = "new"))))
  expect_match(h, ">Go to<")
  expect_match(h, ">Actions<")
  expect_equal(lengths(regmatches(h, gregexpr("shad-command__group\"", h))), 2L)
  # exactly one separator between the two groups, none trailing
  expect_equal(lengths(regmatches(h, gregexpr("shad-command__separator", h))), 1L)
})

test_that("list entries carry the item's extra fields", {
  h <- html(shad_command_palette("p", items = list("Do" = list(
    list(value = "new", label = "New report", shortcut = "N",
         keywords = c("create", "add")),
    list(value = "old", label = "Archive", disabled = TRUE)))))
  expect_match(h, 'data-keywords="create add"')
  expect_match(h, "shad-command__shortcut\">N<")
  expect_match(h, 'data-value="old" data-disabled')
})

test_that("pre-built item tags pass through untouched", {
  h <- html(shad_command_palette("p", items = list(
    shad_command_item("a", "Alpha"), shad_command_item("b", "Beta"))))
  expect_match(h, 'data-value="a"')
  expect_match(h, 'data-value="b"')
  expect_false(grepl("shad-command__group", h, fixed = TRUE))
})

test_that("the palette is a dialog with or without a hotkey", {
  h <- html(shad_command_palette("p", items = c(A = "a")))
  expect_match(h, 'data-hotkey="mod\\+k"')
  expect_match(h, 'data-dialog')
  expect_match(h, 'aria-label="Command palette"')

  # no hotkey: still modal, opened from a trigger or the server. data-dialog is
  # what tells the asset that; without it the palette would render inline.
  nokey <- html(shad_command_palette("p", items = c(A = "a"), hotkey = NULL))
  expect_false(grepl("data-hotkey", nokey, fixed = TRUE))
  expect_match(nokey, "data-dialog")

  # a custom binding is passed straight through
  expect_match(html(shad_command_palette("p", hotkey = "mod+j")),
               'data-hotkey="mod\\+j"')
  expect_error(shad_command_palette("p", hotkey = c("a", "b")), "`hotkey` must be")
})

test_that("the trigger targets a palette and ends with its shortcut hint", {
  h <- html(shad_command_trigger("pal", shortcut = "⌘K"))
  expect_match(h, 'data-shad-command-open="pal"')
  expect_match(h, "shad-command__opener")
  # hint after the label, not before it
  expect_lt(regexpr("Search", h), regexpr("shad-kbd", h))
  expect_false(grepl("shad-kbd", html(shad_command_trigger("pal", shortcut = NULL)),
                     fixed = TRUE))
})

test_that("update_shad_command sends rendered items and keeps the empty state", {
  session <- new_fake_session()
  update_shad_command("pal", items = c(One = "one"), empty_text = "Nothing here",
                      session = session)
  msg <- one_message(session)
  expect_identical(msg$type, "shadshiny:html")
  expect_identical(msg$message$id, "pal")
  expect_identical(msg$message$selector, ".shad-command__list")
  expect_match(msg$message$html, 'data-value="one"')
  # the empty element lives inside the list being replaced, so it must come back
  expect_match(msg$message$html, "Nothing here")
})

test_that("update_shad_command namespaces its target in a module", {
  session <- new_fake_session("mod")
  update_shad_command("pal", items = c(One = "one"), session = session)
  expect_identical(one_message(session)$message$id, "mod-pal")
})

test_that("palette open/close invoke the instance", {
  session <- new_fake_session()
  shad_command_open("pal", session = session)
  expect_identical(one_message(session)$message$method, "open")

  session2 <- new_fake_session()
  shad_command_close("pal", session = session2)
  expect_identical(one_message(session2)$message$method, "close")
})
