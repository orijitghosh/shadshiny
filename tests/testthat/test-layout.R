# Layout primitives: container, stack, grid, and the two page shells.

html <- function(x) as.character(htmltools::as.tags(x))

# --- spacing scale ------------------------------------------------------------

test_that("spacing arguments map token steps to vars and pass CSS through", {
  expect_identical(shadshiny:::shad_space(4), "var(--shad-space-4)")
  expect_identical(shadshiny:::shad_space(0.5), "var(--shad-space-0_5)")
  expect_identical(shadshiny:::shad_space(2.5), "var(--shad-space-2_5)")
  expect_identical(shadshiny:::shad_space(0), "0")
  # not a token step -> a plain CSS length
  expect_identical(shadshiny:::shad_space(7), "7px")
  expect_identical(shadshiny:::shad_space("3ch"), "3ch")
  expect_null(shadshiny:::shad_space(NULL))
})

# --- container ----------------------------------------------------------------

test_that("container sizes resolve, and full/flush drop their properties", {
  expect_match(html(shad_container(size = "lg")), "--shad-container-max:80rem")
  expect_match(html(shad_container(size = "42rem")), "--shad-container-max:42rem")

  full <- html(shad_container(size = "full"))
  expect_match(full, "shad-container--full")
  expect_false(grepl("--shad-container-max", full, fixed = TRUE))

  flush <- html(shad_container(padding = FALSE))
  expect_match(flush, "shad-container--flush")
  expect_false(grepl("--shad-container-pad", flush, fixed = TRUE))
})

# --- stack --------------------------------------------------------------------

test_that("stack emits only the properties it was given", {
  plain <- html(shad_stack("a"))
  expect_match(plain, "--shad-stack-gap:var\\(--shad-space-4\\)")
  # vertical is the CSS default, so no direction property is written
  expect_false(grepl("--shad-stack-dir", plain, fixed = TRUE))

  h <- html(shad_stack("a", direction = "horizontal", gap = 2,
                       align = "center", justify = "between",
                       wrap = TRUE, fill = TRUE))
  expect_match(h, "--shad-stack-dir:row")
  expect_match(h, "--shad-stack-gap:var\\(--shad-space-2\\)")
  expect_match(h, "--shad-stack-align:center")
  expect_match(h, "--shad-stack-justify:space-between")
  expect_match(h, "shad-stack--wrap")
  expect_match(h, "shad-stack--fill")
})

test_that("stack rejects unknown alignment keywords", {
  expect_error(shad_stack(align = "middle"), "`align` must be one of")
  expect_error(shad_stack(justify = "space-between"), "`justify` must be one of")
})

# --- grid ---------------------------------------------------------------------

test_that("grid defaults to an auto-fit track list", {
  g <- html(shad_grid("a"))
  expect_match(g, "shad-grid--auto")
  expect_match(g, "--shad-grid-min:16rem")
})

test_that("grid writes one custom property per named breakpoint", {
  g <- html(shad_grid("a", cols = c(base = 1, md = 3)))
  expect_match(g, "--shad-grid-cols:1")
  expect_match(g, "--shad-grid-cols-md:3")
  # unnamed breakpoints stay unset so the var() fallback chain does the work
  expect_false(grepl("--shad-grid-cols-sm", g, fixed = TRUE))
  expect_false(grepl("--shad-grid-cols-lg", g, fixed = TRUE))
  expect_false(grepl("shad-grid--auto", g, fixed = TRUE))

  # a bare number is the base breakpoint
  expect_match(html(shad_grid("a", cols = 2)), "--shad-grid-cols:2")
})

test_that("grid rejects unknown breakpoint names", {
  expect_error(shad_grid(cols = c(xl = 4)), "must be base/sm/md/lg")
})

test_that("grid template beats cols and min_width", {
  g <- html(shad_grid("a", template = "1fr 2fr", min_width = "10rem"))
  expect_match(g, "shad-grid--template")
  expect_match(g, "--shad-grid-template:1fr 2fr")
  expect_false(grepl("shad-grid--auto", g, fixed = TRUE))
  expect_false(grepl("--shad-grid-min", g, fixed = TRUE))
})

test_that("grid items span columns", {
  expect_match(html(shad_grid_item("x", span = 3)), "--shad-span:3")
  full <- html(shad_grid_item("x", span = "full"))
  expect_match(full, "shad-grid__item--full")
  expect_false(grepl("--shad-span", full, fixed = TRUE))
})

# --- page shells --------------------------------------------------------------

test_that("sidebar shell wires the trigger, title and sidebar input id", {
  h <- html(shad_page_sidebar(
    sidebar = shad_sidebar(shad_sidebar_item("home", "Home")),
    inputId = "sb", title = "Acme", header_end = shad_badge("beta"),
    shad_p("body")
  ))
  expect_match(h, 'data-shad="sidebar"')
  expect_match(h, 'id="sb"')
  expect_match(h, "shad-page--sidebar")
  expect_match(h, "shad-sidebar__trigger")
  expect_match(h, "shad-page__title")
  expect_match(h, "shad-page__bar-end")
  # content is wrapped in a container by default
  expect_match(h, "shad-page__main")
  expect_match(h, "shad-container")
})

test_that("sidebar shell can place content flush", {
  h <- html(shad_page_sidebar(sidebar = shad_sidebar(), container = FALSE,
                              shad_p("body")))
  expect_false(grepl("shad-container", h, fixed = TRUE))
})

test_that("navbar shell keeps the tabs element as the page root", {
  h <- html(shad_page_navbar(
    shad_tab("home", "Home", shad_p("Home panel")),
    shad_tab("about", "About", shad_p("About panel")),
    inputId = "nav", title = "Acme"
  ))
  # the root carries BOTH the page class and the tabs binding hook: the tab
  # list moves into the bar, so a nested root would break shad_tabs()'s
  # root-scoped queries and its input binding.
  expect_match(h, '<div data-shad="tabs" id="nav"[^>]*class="shad-page shad-page--navbar"')
  expect_match(h, "shad-page__bar[^\"]*\"[^<]*<h1")
  # tab list inside the bar, panels inside main
  bar <- regmatches(h, regexpr("<header.*?</header>", h))
  expect_match(bar, "shad-tabs__list")
  expect_match(bar, "shad-tabs__trigger")
  expect_false(grepl("shad-tabs__content", bar, fixed = TRUE))
  expect_match(h, "shad-page__main")
})

test_that("navbar shell honours the selected tab", {
  h <- html(shad_page_navbar(shad_tab("a", "A", "x"), shad_tab("b", "B", "y"),
                             selected = "b"))
  expect_match(h, 'data-value="b"')
})

# --- CSS contract -------------------------------------------------------------

test_that("each primitive resets its own custom properties", {
  # Custom properties INHERIT. Without a reset, a stack nested inside a
  # horizontal stack picks up its parent's --shad-stack-dir and lays itself out
  # sideways; the same goes for gap, alignment and every grid knob. Each rule
  # therefore declares its variables `initial`, which discards the inherited
  # value and lets the var() fallback apply (an inline style still wins).
  css <- readLines(system.file("assets", "components", "layout", "layout.css",
                               package = "shadshiny"), warn = FALSE)
  css <- paste(css, collapse = "\n")

  rule <- function(selector) {
    m <- regmatches(css, regexpr(
      paste0("[.]", sub("^[.]", "", selector), "[[:space:]]*[{][^}]*[}]"), css))
    expect_length(m, 1L)
    m
  }

  stack <- rule(".shad-stack")
  for (v in c("dir", "gap", "align", "justify")) {
    expect_match(stack, paste0("--shad-stack-", v, ": initial"), fixed = TRUE)
  }

  grid <- rule(".shad-grid")
  for (v in c("gap", "align", "min", "template", "cols",
              "cols-sm", "cols-md", "cols-lg")) {
    expect_match(grid, paste0("--shad-grid-", v, ": initial"), fixed = TRUE)
  }

  container <- rule(".shad-container")
  expect_match(container, "--shad-container-max: initial", fixed = TRUE)
  expect_match(container, "--shad-container-pad: initial", fixed = TRUE)

  expect_match(rule(".shad-grid__item"), "--shad-span: initial", fixed = TRUE)
})
