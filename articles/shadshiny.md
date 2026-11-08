# Get started with shadshiny

shadshiny is a port of the [shadcn/ui](https://ui.shadcn.com) design
system to Shiny. Components are plain `htmltools` tags backed by one
bundled asset dependency — there is no npm step and no React. Bound
components behave like ordinary Shiny inputs.

## Install

``` r

pak::pak("orijitghosh/shadshiny")
```

## The page wrapper

Every app starts with
[`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md).
It attaches the shadshiny asset bundle, establishes the theme scope, and
otherwise behaves like a Shiny page. Pass a `theme_preset` to choose one
of the twelve palettes.

``` r

library(shiny)
library(shadshiny)

page_shad(
  theme_preset = "violet",
  # ... UI ...
)
```

## A first form

Components take an `inputId` and read back through `input$<inputId>`
exactly like base Shiny inputs.
[`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md),
[`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md),
and
[`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md)
below each contribute one reactive value.

``` r

library(shiny)
library(shadshiny)

ui <- page_shad(
  theme_preset = "violet",
  shad_card(
    shad_card_header(
      shad_card_title("Create account"),
      shad_card_description("It only takes a minute.")
    ),
    shad_card_content(
      shad_input("email", label = "Email", type = "email",
                 placeholder = "you@example.com"),
      shad_select("plan", label = "Plan",
                  choices = c(Free = "free", Pro = "pro", Team = "team"),
                  selected = "pro"),
      shad_checkbox("tos", label = "I accept the terms")
    ),
    shad_card_footer(
      shad_button(inputId = "submit", "Sign up"),
      shad_button(inputId = "reset", "Reset", variant = "outline")
    )
  ),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  # Read values straight off `input$`.
  output$out <- renderPrint(
    list(email = input$email, plan = input$plan, tos = input$tos)
  )

  # Update a component from the server with its `update_shad_*()` helper.
  observeEvent(input$reset, {
    update_shad_select("plan", selected = "free")
    update_shad_checkbox("tos", value = FALSE)
  })

  # Open an overlay and raise a toast.
  observeEvent(input$submit, {
    if (!isTRUE(input$tos)) {
      shad_toast_error("Please accept the terms first.")
    } else {
      shad_toast_success(paste("Welcome,", input$email))
    }
  })
}

shinyApp(ui, server)
```

## Reading and updating values

- **Read:** `input$email`, `input$plan`, `input$tos`. Value shapes match
  what the component holds — a string, a logical, a vector for
  multi-selects.
- **Update:** each valued component has an `update_shad_*()` twin
  ([`update_shad_select()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
  [`update_shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
  …). They accept the same `inputId` and are Shiny-module safe.

## Overlays and toasts

Overlays such as
[`shad_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_dialog.md)
can be driven by a trigger element in the UI or opened from the server
with `shad_dialog_open(id)`. Toasts are entirely server-side:
[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md)
and its
[`shad_toast_success()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md)
/ `_error()` / `_warning()` / `_loading()` shorthands.

``` r

shad_dialog(
  "confirm",
  trigger = shad_button("Open"),
  title = "Are you sure?",
  shad_p("This action can be undone."),
  footer = shad_dialog_close_button("Close")
)
```

A dialog can also be built in the server and shown with
[`shad_show_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_show_dialog.md),
the way
[`shiny::showModal()`](https://rdrr.io/pkg/shiny/man/showModal.html)
works — useful when its content depends on what the user just did.

## Laying out a page

[`shad_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_container.md),
[`shad_stack()`](https://orijitghosh.github.io/shadshiny/reference/shad_stack.md)
and
[`shad_grid()`](https://orijitghosh.github.io/shadshiny/reference/shad_grid.md)
handle page layout on the same spacing scale the components use
internally:

``` r

shad_container(
  shad_stack(
    shad_grid(kpi_one, kpi_two, kpi_three, min_width = "14rem"),
    shad_card(shad_card_content("Details")),
    gap = 6
  ),
  size = "lg"
)
```

For a whole app,
[`shad_page_navbar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_navbar.md)
and
[`shad_page_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_sidebar.md)
replace
[`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md)
and assemble the shell — bar, navigation and scrolling main region — in
one call.

## Where to next

- [`vignette("theming")`](https://orijitghosh.github.io/shadshiny/articles/theming.md)
  — the token system, presets, and dark mode.
- [`vignette("layout")`](https://orijitghosh.github.io/shadshiny/articles/layout.md)
  — containers, grids, and the page shells.
- [`vignette("overlays-and-server")`](https://orijitghosh.github.io/shadshiny/articles/overlays-and-server.md)
  — dialogs, confirm flows, and toasts.
- [`vignette("migrating-inputs")`](https://orijitghosh.github.io/shadshiny/articles/migrating-inputs.md)
  — moving from base Shiny inputs.
- `shad_run_example("kitchen-sink")` — a live tour of every component.
