# shadshiny

**shadshiny** brings the [shadcn/ui](https://ui.shadcn.com) design
system to [Shiny](https://shiny.posit.co). It is a from-scratch port —
72 accessible, themeable components rebuilt in framework-free CSS and
vanilla JavaScript, then wrapped as ordinary R functions with native
Shiny input bindings.

- **No build step, no npm, no React.** Components are plain `htmltools`
  tags backed by a single bundled asset dependency.
- **Native Shiny inputs.** Read values with `input$id`; drive them from
  the server with `update_shad_*()`. Modules,
  [`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html) and
  bookmarking just work.
- **Layout without CSS gymnastics.**
  [`shad_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_container.md),
  [`shad_stack()`](https://orijitghosh.github.io/shadshiny/reference/shad_stack.md)
  and
  [`shad_grid()`](https://orijitghosh.github.io/shadshiny/reference/shad_grid.md)
  cover page layout on the token spacing scale, and
  [`shad_page_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_sidebar.md)
  /
  [`shad_page_navbar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_navbar.md)
  assemble a whole app shell in one call.
- **A real data table.**
  [`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md)
  does multi-column sort, global and per-column filtering, paging, and
  selection that survives paging — client-side and themed, with no `DT`.
- **Dashboards & charts.**
  [`shad_value_box()`](https://orijitghosh.github.io/shadshiny/reference/shad_value_box.md)
  and
  [`shad_chart_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_container.md)
  for the shell;
  [`shad_sparkline()`](https://orijitghosh.github.io/shadshiny/reference/shad_sparkline.md)
  and
  [`shad_mini_donut()`](https://orijitghosh.github.io/shadshiny/reference/shad_mini_donut.md)
  draw inline SVG that follows the theme in CSS with no re-render;
  [`shad_theme_ggplot2()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md)
  /
  [`shad_theme_plotly()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_plotly.md)
  /
  [`shad_theme_echarts4r()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_echarts4r.md)
  restyle plots onto the live theme.
- **Server-side validation.**
  [`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md)
  plus a rule set drive `aria-invalid` and inline, shadcn-styled field
  messages.
- **Streaming chat.**
  [`shad_chat_ui()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_ui.md)
  /
  [`shad_chat_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_server.md)
  render a stick-to-bottom transcript from any token source — an
  `ellmer` stream drops straight in.
- **Coexists with Bootstrap 5 / bslib.** Dark mode keys off the same
  signals
  [`bslib::input_dark_mode()`](https://rstudio.github.io/bslib/reference/input_dark_mode.html)
  uses, so theme sync needs zero glue.
- **OKLCH token theming.** Seven presets out of the box, switchable at
  runtime, plus custom palettes via
  [`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md)
  and the shadcn theme registry.

> shadshiny is an independent reimplementation. It ships no shadcn/ui or
> Radix source — only visually-compatible CSS/JS written for this
> package. See [Attribution](#attribution).

## Installation

``` r

# install.packages("pak")
pak::pak("orijitghosh/shadshiny")
```

## Quick start

``` r

library(shiny)
library(shadshiny)

ui <- page_shad(
  theme_preset = "violet",
  shad_card(
    shad_card_header(
      shad_card_title("Create account"),
      shad_card_description("Enter your details below.")
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
      shad_button(inputId = "submit", "Sign up", variant = "default")
    )
  ),
  verbatimTextOutput("out")
)

server <- function(input, output, session) {
  output$out <- renderPrint(
    list(email = input$email, plan = input$plan, tos = input$tos)
  )
  observeEvent(input$submit, {
    if (!isTRUE(input$tos)) {
      shad_toast_error("Please accept the terms.")
    } else {
      shad_toast_success(paste("Welcome,", input$email))
    }
  })
}

shinyApp(ui, server)
```

Run the flagship demo, which covers every component:

``` r

shad_run_example("kitchen-sink")
```

## Components

**Tier 1 — display & typography**

|  |  |  |  |
|----|----|----|----|
| `shad_button` | `shad_badge` | `shad_avatar` | `shad_card` |
| `shad_alert` | `shad_separator` | `shad_skeleton` | `shad_spinner` |
| `shad_aspect_ratio` | `shad_label` | `shad_progress` | `shad_breadcrumb` |
| `shad_table` | `shad_kbd` | `shad_code` | typography (`shad_h1`…`shad_p`) |
| `shad_item` | `shad_empty` | `shad_button_group` |  |

**Tier 2 — form inputs**

|  |  |  |  |
|----|----|----|----|
| `shad_input` | `shad_textarea` | `shad_checkbox` | `shad_switch` |
| `shad_radio_group` | `shad_toggle` | `shad_toggle_group` | `shad_slider` |
| `shad_select` | `shad_native_select` | `shad_combobox` | `shad_input_otp` |
| `shad_calendar` | `shad_date_picker` | `shad_form_field` | `shad_input_group` |
| `shad_number_input` | `shad_rating` | `shad_dropzone` |  |

**Tier 3 — overlays**

|  |  |  |  |
|----|----|----|----|
| `shad_dialog` | `shad_alert_dialog` | `shad_sheet` | `shad_drawer` |
| `shad_popover` | `shad_tooltip` | `shad_hover_card` | `shad_dropdown_menu` |
| `shad_context_menu` | `shad_menubar` | `shad_command` | `shad_toast` |
| `shad_command_palette` | `shad_show_dialog` |  |  |

**Tier 3 — navigation & structure**

|  |  |  |  |
|----|----|----|----|
| `shad_tabs` | `shad_accordion` | `shad_collapsible` | `shad_pagination` |
| `shad_scroll_area` | `shad_resizable` | `shad_carousel` | `shad_navigation_menu` |
| `shad_sidebar_layout` | `shad_stepper` | `shad_tree` |  |
| `shad_container` | `shad_stack` | `shad_grid` | `shad_page_sidebar` |
| `shad_page_navbar` |  |  |  |

**Data, dashboards & flow**

|  |  |  |  |
|----|----|----|----|
| `shad_data_table` | `shad_value_box` | `shad_chart_container` | `shad_timeline` |
| `shad_sparkline` | `shad_mini_donut` | `shad_validator` | `shad_form_message` |
| `shad_form_summary` | `shad_theme` |  |  |

**Chat / AI kit**

|                         |                |                    |               |
|-------------------------|----------------|--------------------|---------------|
| `shad_message`          | `shad_bubble`  | `shad_attachment`  | `shad_marker` |
| `shad_message_scroller` | `shad_chat_ui` | `shad_chat_server` |               |

Every stateful component is namespaced-module safe and has a matching
`update_shad_*()` server helper where it holds a value. Overlays add
`shad_<name>_open()` / `shad_<name>_close()`. Inputs that take an
initial value seed it from
[`shiny::restoreInput()`](https://rdrr.io/pkg/shiny/man/restoreInput.html),
so
[`enableBookmarking()`](https://rdrr.io/pkg/shiny/man/enableBookmarking.html)
restores them on reload.

## Data tables

[`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md)
is an **input**, not an output. It serialises the frame once and does
everything else in the browser, so interaction never round-trips to R
unless you ask for it.

``` r

ui <- page_shad(
  shad_data_table(
    "tbl", sales,
    columns = list(
      amount = shad_col("Amount", format = shad_fmt_number(2, prefix = "$")),
      status = shad_col("Status", format = shad_fmt_badge(
        c(paid = "default", refunded = "destructive")
      ))
    ),
    selection = "multiple", filter = "both", page_size = 25
  )
)

server <- function(input, output, session) {
  # $selected, $sort, $filter, $page, $pageSize
  observe(print(input$tbl$selected))
}
```

Formatters keep the raw value as the sort key, so a `$1,200.00` cell
still sorts numerically. See
[`vignette("data-tables")`](https://orijitghosh.github.io/shadshiny/articles/data-tables.md).

## Page shells and layout

Three primitives cover page layout, on the same spacing scale the
components use internally (`gap = 4` is `var(--shad-space-4)`):

``` r

shad_container(size = "lg",
  shad_stack(
    shad_grid(kpi_one, kpi_two, kpi_three, min_width = "14rem"),
    shad_card(...),
    gap = 6
  )
)
```

[`shad_grid()`](https://orijitghosh.github.io/shadshiny/reference/shad_grid.md)
takes `min_width` for an auto-fit track list, or `cols` for an exact
count — optionally per breakpoint, `cols = c(base = 1, md = 2, lg = 4)`.

Two shells assemble a whole page, taking the
[`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md)
theming arguments:

``` r

ui <- shad_page_navbar(
  shad_tab("overview", "Overview", overview_ui),
  shad_tab("reports",  "Reports",  reports_ui),
  title = "Acme", inputId = "nav"
)

ui <- shad_page_sidebar(sidebar = shad_sidebar(...), title = "Acme", body_ui)
```

See
[`vignette("layout")`](https://orijitghosh.github.io/shadshiny/articles/layout.md).

## Dialogs from the server

Overlays can be declared in the UI with a `trigger`, or built in the
server when their content depends on what just happened:

``` r

observeEvent(input$delete, {
  shad_show_dialog(shad_dialog(
    "confirm", title = paste("Delete", input$project, "?"),
    description = "This cannot be undone.",
    footer = tagList(shad_dialog_close_button(),
                     shad_button(inputId = "go", "Delete", variant = "destructive"))
  ))
})
```

It opens itself and, by default, removes itself once it closes. Also
takes
[`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md),
[`shad_sheet()`](https://orijitghosh.github.io/shadshiny/reference/shad_sheet.md)
and
[`shad_drawer()`](https://orijitghosh.github.io/shadshiny/reference/shad_drawer.md).
See
[`vignette("overlays-and-server")`](https://orijitghosh.github.io/shadshiny/articles/overlays-and-server.md).

## ⌘K navigation

``` r

shad_command_palette("palette", items = list(
  "Go to"   = c(Dashboard = "dashboard", Reports = "reports"),
  "Actions" = list(list(value = "new", label = "New report", shortcut = "N"))
))

observeEvent(input$palette_event, { ... })   # fires on every activation
```

Observe `input$palette_event`, not `input$palette`: Shiny drops a repeat
of the same value, so picking “Reports” twice would only fire once.

## Charts that follow the theme

Themes switch at *runtime*, and a plot rendered in R has no idea.
[`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md)
is the bridge — read it in a render block and the plot re-runs whenever
the preset or dark mode changes.

``` r

output$plot <- renderPlot({
  shad_current_theme()
  ggplot(df, aes(month, revenue)) +
    geom_col(fill = shad_chart_colors(1)) +
    shad_theme_ggplot2()
})
```

[`shad_chart_colors()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_colors.md)
returns the categorical ramp as hex (OKLCH converted in base R — no new
dependency).
[`shad_tokens()`](https://orijitghosh.github.io/shadshiny/reference/shad_tokens.md)
exposes the full token set as CSS strings.

For the small stuff, skip the plotting stack entirely —
[`shad_sparkline()`](https://orijitghosh.github.io/shadshiny/reference/shad_sparkline.md)
and
[`shad_mini_donut()`](https://orijitghosh.github.io/shadshiny/reference/shad_mini_donut.md)
are inline SVG painted with the chart tokens, so a dark-mode toggle
restyles them in CSS with no re-render and no round trip:

``` r

shad_value_box("1,204", "Sessions", delta = "-3.1%",
               sparkline = shad_sparkline(sessions, type = "area"))
```

See
[`vignette("charts")`](https://orijitghosh.github.io/shadshiny/articles/charts.md).

## Validation

``` r

v <- shad_validator()
v$add_rule("email", shad_rule_required(), label = "Email")
v$add_rule("email", shad_rule_email())
v$add_rule("pw", shad_rule_min_chars(8))
v$bind_submit("submit")   # disables the button until valid
v$bind_summary("errors")  # renders an error summary panel
v$enable()
```

Put
[`shad_rule_required()`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md)
first so an empty field reports *Required.* rather than a format
complaint. See
[`vignette("forms")`](https://orijitghosh.github.io/shadshiny/articles/forms.md).

## Streaming chat

The handler may return a complete string, a chunk-yielding function, or
a coro generator, so an `ellmer` stream drops straight in.

``` r

shad_chat_server("chat", handler = function(user, history) {
  chat$stream(user)
})
```

See
[`vignette("chat")`](https://orijitghosh.github.io/shadshiny/articles/chat.md).

## Theming

Colours are OKLCH `--shad-*` custom properties — never hard-code hex.
Pick a preset at page level or swap it live:

``` r

page_shad(theme_preset = "green")            # slate stone blue green rose violet orange

# server-side, e.g. from a shad_select + shad_switch toolbar
update_shad_theme(preset = input$preset, dark = input$dark)
```

Build a custom palette with
[`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md),
scope one to a subtree with
[`shad_theme_scope()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_scope.md),
or import tweakcn / shadcn registry JSON with
[`shad_theme_from_registry()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_from_registry.md).

Dark mode is driven by `.dark` / `[data-bs-theme="dark"]`, so
[`bslib::input_dark_mode()`](https://rstudio.github.io/bslib/reference/input_dark_mode.html)
toggles shadshiny components with no extra wiring. See
[`vignette("theming")`](https://orijitghosh.github.io/shadshiny/articles/theming.md).

## Example apps

Each is a real app, launchable with
[`shad_run_example()`](https://orijitghosh.github.io/shadshiny/reference/shad_run_example.md):

|  |  |
|----|----|
| `kitchen-sink` | Every component, variant and server round-trip |
| `01-auth-onboarding` | Tabbed auth card, a 4-step wizard, and input-OTP 2FA |
| `02-analytics-dashboard` | Admin console: live chart, date range, command palette, mutable team directory |
| `03-support-chat` | Conversation list, stick-to-bottom transcript, composer with attachments |
| `04-storefront` | Product page: carousel, variant pickers, add-to-cart sheet, reviews |
| `05-settings-profile` | Vertical tabs, profile and notification forms, a live appearance panel |
| `06-docs-reader` | Sidebar nav, ⌘K palette, resizable article/TOC split, prev/next paging |
| `07-data-explorer` | [`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md) with value boxes and theme-following plots |
| `08-llm-chat` | Streaming [`shad_chat_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_server.md) — swap the handler for `ellmer` to go live |
| `09-app-shell` | [`shad_page_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_sidebar.md), layout primitives, sparklines, a ⌘K palette that navigates, and server-built dialogs |

## Guides

[`vignette("shadshiny")`](https://orijitghosh.github.io/shadshiny/articles/shadshiny.md)
to get started, then: `installation`, `theming`, `forms`, `data-tables`,
`charts`, `chat`, `layout`, `server-api`, `overlays-and-server`, and
`migrating-inputs` — a complete base-Shiny → shadshiny reference. The
[pkgdown site](https://orijitghosh.github.io/shadshiny/) adds a live
component gallery and an icon reference (78 built-in icons; use any
other Lucide glyph via
[`shad_icon_raw()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon_raw.md)).

## Attribution

shadshiny is inspired by and visually compatible with
[shadcn/ui](https://ui.shadcn.com) (MIT) by shadcn, which itself builds
on [Radix UI](https://www.radix-ui.com) primitives. **No upstream source
code is vendored.** All CSS and JavaScript in this package were
reimplemented from scratch to be framework-free and Shiny-native.
shadcn/ui and Radix are trademarks of their respective owners. shadshiny
is released under the [MIT
License](https://orijitghosh.github.io/shadshiny/LICENSE).
