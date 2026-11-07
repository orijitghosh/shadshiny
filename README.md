# shadshiny <img src="man/figures/logo.png" align="right" height="139" alt="shadshiny hex logo" />

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/orijitghosh/shadshiny/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/orijitghosh/shadshiny/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/orijitghosh/shadshiny/graph/badge.svg)](https://app.codecov.io/gh/orijitghosh/shadshiny)
[![pkgdown](https://github.com/orijitghosh/shadshiny/actions/workflows/pkgdown.yaml/badge.svg)](https://orijitghosh.github.io/shadshiny/)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
<!-- badges: end -->

**shadshiny** brings the [shadcn/ui](https://ui.shadcn.com) design system to
[Shiny](https://shiny.posit.co). It is a broad, experimental reimplementation:
73 accessible, themeable components rebuilt in framework-free CSS and vanilla
JavaScript, then wrapped as ordinary R functions with native Shiny input
bindings.

- **No build step, no npm, no React.** Components are plain `htmltools` tags
  backed by a single bundled asset dependency.
- **Native Shiny inputs.** Read values with `input$id`; drive them from the
  server with `update_shad_*()`. Modules, `renderUI()` and bookmarking all work.
- **Layout primitives.** `shad_container()`, `shad_stack()` and `shad_grid()`
  cover page layout on the token spacing scale, and `shad_page_sidebar()` /
  `shad_page_navbar()` assemble a whole app shell in one call.
- **Full data table.** `shad_data_table()` does multi-column sort, global and
  per-column filtering, paging, and selection that survives paging, all
  client-side and themed, with no `DT`. The experimental
  `shad_data_table_server()` adds lazy server-backed paging.
- **Dashboards & charts.** `shad_value_box()` and `shad_chart_container()` for
  the shell; `shad_sparkline()` and `shad_mini_donut()` draw inline SVG that
  follows the theme in CSS with no re-render; `shad_theme_ggplot2()` /
  `shad_theme_plotly()` / `shad_theme_echarts4r()` restyle plots onto the live
  theme.
- **Server-side validation.** `shad_validator()` plus a rule set drive
  `aria-invalid` and inline, shadcn-styled field messages.
- **Streaming chat.** `shad_chat_ui()` / `shad_chat_server()` render a
  stick-to-bottom transcript from any token source, so an `ellmer` stream drops
  straight in. Live provider integrations like that are experimental.
- **Structured AI workbench (experimental).** `shad_chat_workbench_ui()` /
  `shad_chat_workbench_server()` render provider-owned public text, source,
  tool, attachment, and status events without an AI SDK or network call.
- **Coexists with Bootstrap 5 / bslib.** Dark mode keys off the same signals
  `bslib::input_dark_mode()` uses, so theme sync needs no glue.
- **OKLCH token theming.** Seven presets out of the box, switchable at runtime,
  plus custom palettes via `shad_theme()` and the shadcn theme registry.

> shadshiny is an independent reimplementation. It ships no shadcn/ui or Radix
> source, only visually-compatible CSS/JS written for this package. See
> [Attribution](#attribution).

## API stability

The package remains experimental as a whole while its release-facing core is
being stabilized across R versions and platforms. The stable core boundary for
the current development line is the documented page, layout, input, overlay,
theme, client-side data-table, validation, chat, and `update_shad_*()` APIs,
including their tested Shiny value and lifecycle contracts, apart from the
experimental functions below.

These remain experimental and may change before a stable 1.0 release; each
help page and article that documents them says so:

- importing themes from an external shadcn/tweakcn registry schema,
  `shad_theme_from_registry()`;
- the optional chart adapters, whose behavior also depends on third-party
  packages: `shad_theme_ggplot2()`, `shad_scale_color_shad()`,
  `shad_scale_fill_shad()`, `shad_theme_plotly()`, and
  `shad_theme_echarts4r()`;
- the server-backed, lazily paged data table, `shad_data_table_server()`;
- the questionnaire workflow, `shad_questionnaire()`, `shad_question()`, and
  `update_shad_questionnaire()`;
- the `ExtendedTask` button lifecycle binding, `bind_shad_task_button()`;
- the structured AI workbench, `shad_chat_workbench_ui()` and
  `shad_chat_workbench_server()`;
- the field composition family, `shad_fieldset()`, `shad_field_group()`, and
  `shad_field_separator()`;
- live integrations with external chat stream providers.

## Installation

```r
# install.packages("pak")
pak::pak("orijitghosh/shadshiny")
```

## Quick start

```r
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

```r
shad_run_example("kitchen-sink")
```

## Components

Names marked `+` have no shadcn/ui counterpart; they are shadshiny additions.
The marker covers components only. The server-side API (`update_shad_*()`,
`shad_<name>_open()` / `_close()`, `shad_show_dialog()`, the toast functions) is
Shiny plumbing that shadcn/ui has no equivalent for by construction, so it goes
unmarked throughout.

**Tier 1: display & typography**

| | | | |
|---|---|---|---|
| `shad_button` | `shad_badge` | `shad_avatar` | `shad_card` |
| `shad_alert` | `shad_separator` | `shad_skeleton` | `shad_spinner` |
| `shad_aspect_ratio` | `shad_label` | `shad_progress` | `shad_breadcrumb` |
| `shad_table` | `shad_kbd` | `shad_code` | typography (`shad_h1` to `shad_p`) |
| `shad_item` | `shad_empty` | `shad_button_group` | `shad_kbd_group` + |
| `shad_code_block` + | `shad_scroll_fade` + | `shad_shimmer` + | |

**Tier 2: form inputs**

| | | | |
|---|---|---|---|
| `shad_input` | `shad_textarea` | `shad_checkbox` | `shad_switch` |
| `shad_radio_group` | `shad_toggle` | `shad_toggle_group` | `shad_slider` |
| `shad_select` | `shad_native_select` | `shad_combobox` | `shad_input_otp` |
| `shad_calendar` | `shad_date_picker` | `shad_form_field` | `shad_input_group` |
| `shad_fieldset` `+` | `shad_field_group` `+` | `shad_field_separator` `+` | |
| `shad_number_input` `+` | `shad_rating` `+` | `shad_dropzone` `+` | |

**Tier 3: overlays**

| | | | |
|---|---|---|---|
| `shad_dialog` | `shad_alert_dialog` | `shad_sheet` | `shad_drawer` |
| `shad_popover` | `shad_tooltip` | `shad_hover_card` | `shad_dropdown_menu` |
| `shad_context_menu` | `shad_menubar` | `shad_command` | `shad_toast` |
| `shad_command_palette` | `shad_show_dialog` | | |

**Tier 3: navigation & structure**

| | | | |
|---|---|---|---|
| `shad_tabs` | `shad_accordion` | `shad_collapsible` | `shad_pagination` |
| `shad_scroll_area` | `shad_resizable` | `shad_carousel` | `shad_navigation_menu` |
| `shad_sidebar_layout` | `shad_stepper` `+` | `shad_tree` `+` | |
| `shad_container` `+` | `shad_stack` `+` | `shad_grid` `+` | `shad_page_sidebar` `+` |
| `shad_page_navbar` `+` | `shad_questionnaire` `+` | | |

**Data, dashboards & flow**

| | | | |
|---|---|---|---|
| `shad_data_table` | `shad_value_box` `+` | `shad_chart_container` | `shad_timeline` `+` |
| `shad_sparkline` `+` | `shad_mini_donut` `+` | `shad_validator` | `shad_form_message` |
| `shad_form_summary` `+` | `shad_theme` | | |

**Chat / AI kit**

| | | | |
|---|---|---|---|
| `shad_message` | `shad_bubble` | `shad_attachment` | `shad_marker` |
| `shad_message_scroller` | `shad_chat_ui` `+` | `shad_chat_server` `+` | |

Every stateful component is namespaced-module safe and has a matching
`update_shad_*()` server helper where it holds a value. Overlays add
`shad_<name>_open()` / `shad_<name>_close()`. Inputs that take an initial value
seed it from `shiny::restoreInput()`, so `enableBookmarking()` restores them on
reload.

## Data tables

`shad_data_table()` is an **input**, not an output. It serialises the frame once
and does everything else in the browser, so interaction never round-trips to R
unless you ask for it.

```r
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

Formatters keep the raw value as the sort key, so a `$1,200.00` cell still sorts
numerically. See `vignette("data-tables")`.

### Server-backed paging (experimental)

For datasets that should not be serialized into the browser, keep the
constructor empty/loading and connect it to a source function:

```r
ui <- page_shad(
  shad_data_table(
    "orders", data = NULL, selection = "multiple", filter = "both",
    page_size = 25, loading = TRUE
  )
)

server_rows <- data.frame(
  order_id = sprintf("order-%03d", seq_len(100L)),
  customer = paste("Customer", seq_len(100L)),
  status = rep(c("paid", "pending", "refunded"), length.out = 100L),
  amount = seq(12.50, by = 7.25, length.out = 100L),
  stringsAsFactors = FALSE
)

server_source <- function(request) {
  filtered <- server_rows
  global <- trimws(request$filter$global)
  if (nzchar(global)) {
    hit <- Reduce(`|`, lapply(filtered, function(x) {
      grepl(tolower(global), tolower(as.character(x)), fixed = TRUE)
    }))
    filtered <- filtered[hit, , drop = FALSE]
  }
  for (column in names(request$filter$columns)) {
    needle <- trimws(request$filter$columns[[column]])
    if (nzchar(needle) && column %in% names(filtered)) {
      keep <- grepl(tolower(needle), tolower(as.character(filtered[[column]])), fixed = TRUE)
      filtered <- filtered[keep, , drop = FALSE]
    }
  }
  for (spec in rev(request$sort)) {
    filtered <- filtered[order(
      filtered[[spec$column]],
      decreasing = identical(spec$direction, "desc"), method = "radix"
    ), , drop = FALSE]
  }
  total <- nrow(server_rows)
  filtered_total <- nrow(filtered)
  first <- (request$page - 1L) * request$page_size + 1L
  page <- if (first <= filtered_total) {
    filtered[seq.int(first, min(first + request$page_size - 1L, filtered_total)), , drop = FALSE]
  } else {
    filtered[0, , drop = FALSE]
  }
  list(data = page, total_rows = total, filtered_rows = filtered_total)
}

server <- function(input, output, session) {
  shad_data_table_server(
    "orders",
    source = server_source,
    columns = list(
      order_id = shad_col("Order"),
      amount = shad_col("Amount", format = shad_fmt_number(2, prefix = "$")),
      status = shad_col("Status", format = shad_fmt_badge(
        c(paid = "default", pending = "secondary", refunded = "destructive")
      ))
    ),
    row_key = "order_id",
    session = session
  )
}
```

For a database source, keep the same response shape, allowlist sort columns
before composing SQL, and bind every user value. For example, the query layer
can use `DBI::dbGetQuery(conn, sql, params = list(global, page_size, offset))`;
do not paste request filters or sort names directly into SQL.

`source()` receives validated 1-based paging, multi-sort, global filtering,
and named column filters. It must return no more than the requested page and
the two total counts. The helper reuses `shad_col()` formatting, ignores stale
responses, and shows a fixed safe error with retry if the source fails. Provide
a unique, non-missing `row_key` for selections that survive paging; the helper
does not provide database adapters, editing, grouping, pivoting, aggregation,
downloads, or spreadsheet behavior. See `vignette("data-tables")` for the full
contract.

## Questionnaire workflows (experimental)

`shad_questionnaire()` sequences native fieldsets for single-choice,
multiple-choice, and text questions. It reports one bookmarkable value with
`active`, named `answers`, explicit `skipped` question names, and `complete`.
All questions remain mounted; inactive or conditionally hidden questions are
`hidden` and `inert`, so preserved answers do not enter the keyboard order.

```r
ui <- page_shad(
  shad_questionnaire(
    "onboarding",
    shad_question(
      "direction", "What should be built?",
      choices = c(data = "Server table", rtl = "RTL"),
      shortcuts = c(data = "1", rtl = "2")
    ),
    shad_question(
      "details", "Describe the table", type = "text",
      show_if = list(direction = "data")
    )
  )
)
```

Use named equality data for `show_if`; the browser evaluates no application
code. `update_shad_questionnaire()` patches active state, answers, or named
errors, and `reset = TRUE` clears the workflow. The generic binding is
module-safe and uses `shiny::restoreInput()` for bookmark restoration. See
`vignette("questionnaire")` for validation, branching, modules, and the full
state contract.

## Field composition

Use native fieldsets for related controls, keeping `shad_form_field()` as the
single-control wrapper. `shad_field_group()` supports vertical, horizontal,
and container-responsive layouts; the responsive form switches to two logical
columns at a 36rem container width and mirrors correctly in RTL.

~~~r
shad_fieldset(
  "Payment",
  description = "Use the billing address associated with this card.",
  shad_field_group(
    shad_form_field(shad_input("card_number"), label = "Card number"),
    shad_form_field(shad_input("card_name"), label = "Name on card"),
    orientation = "responsive"
  )
)

shad_fieldset(
  "Settings",
  variant = "label",
  shad_field_group(
    shad_form_field(shad_switch("notifications"), label = "Notifications"),
    shad_field_separator("Optional"),
    shad_form_field(shad_input("timezone"), label = "Time zone")
  )
)
~~~

The native `fieldset`/`legend` relationship remains available to assistive
technology, while field descriptions and validator errors retain their
existing `aria-describedby` and `aria-invalid` behavior. The constructors
forward ordinary HTML attributes, so a choice-card or radio group can be
placed inside the same composition primitives.

## Page shells and layout

### Directionality

Set the page direction with ordinary HTML attributes passed through
`page_shad(...)`; this preserves the existing function signature:

```r
page_shad(dir = "rtl", lang = "ar", shad_p("واجهة عربية"))
```

Floating panels inherit the nearest direction and language even after they are
ported to `body`. For content that may mix scripts, use the browser's automatic
direction detection on the content wrapper or table root:

```r
shad_message(tags$span(dir = "auto", "שלום / English"))
shad_data_table("mixed", data, dir = "auto")
```

Named physical sides such as `data-side = "right"` remain explicit placement
contracts; logical spacing, borders, alignment, and start/end controls mirror
with the document direction.

Three primitives cover page layout, on the same spacing scale the components use
internally (`gap = 4` is `var(--shad-space-4)`):

```r
shad_container(size = "lg",
  shad_stack(
    shad_grid(kpi_one, kpi_two, kpi_three, min_width = "14rem"),
    shad_card(...),
    gap = 6
  )
)
```

`shad_grid()` takes `min_width` for an auto-fit track list, or `cols` for an
exact count, optionally per breakpoint, `cols = c(base = 1, md = 2, lg = 4)`.

Two shells assemble a whole page, taking the `page_shad()` theming arguments:

```r
ui <- shad_page_navbar(
  shad_tab("overview", "Overview", overview_ui),
  shad_tab("reports",  "Reports",  reports_ui),
  title = "Acme", inputId = "nav"
)

ui <- shad_page_sidebar(sidebar = shad_sidebar(...), title = "Acme", body_ui)
```

See `vignette("layout")`.

## Dialogs from the server

Overlays can be declared in the UI with a `trigger`, or built in the server when
their content depends on what just happened:

```r
observeEvent(input$delete, {
  shad_show_dialog(shad_dialog(
    "confirm", title = paste("Delete", input$project, "?"),
    description = "This cannot be undone.",
    footer = tagList(shad_dialog_close_button(),
                     shad_button(inputId = "go", "Delete", variant = "destructive"))
  ))
})
```

It opens itself and, by default, removes itself once it closes. Also takes
`shad_alert_dialog()`, `shad_sheet()` and `shad_drawer()`. See
`vignette("overlays-and-server")`.

## ⌘K navigation

```r
shad_command_palette("palette", items = list(
  "Go to"   = c(Dashboard = "dashboard", Reports = "reports"),
  "Actions" = list(list(value = "new", label = "New report", shortcut = "N"))
))

observeEvent(input$palette_event, { ... })   # fires on every activation
```

Observe `input$palette_event`, not `input$palette`: Shiny drops a repeat of the
same value, so picking "Reports" twice would only fire once.

## Charts that follow the theme

Themes switch at runtime, which a plot rendered in R cannot see on its own.
`shad_current_theme()` is the bridge: read it in a render block and the plot
re-runs whenever the preset or dark mode changes.

```r
output$plot <- renderPlot({
  shad_current_theme()
  ggplot(df, aes(month, revenue)) +
    geom_col(fill = shad_chart_colors(1)) +
    shad_theme_ggplot2()
})
```

`shad_chart_colors()` returns the categorical ramp as hex (OKLCH converted in
base R, with no new dependency). `shad_tokens()` exposes the full token set as
CSS strings.

For small inline graphics, skip the plotting stack. `shad_sparkline()` and
`shad_mini_donut()` are inline SVG painted with the chart tokens, so a dark-mode
toggle restyles them in CSS with no re-render and no round trip:

```r
shad_value_box("1,204", "Sessions", delta = "-3.1%",
               sparkline = shad_sparkline(sessions, type = "area"))
```

See `vignette("charts")`.

## Validation

```r
v <- shad_validator()
v$add_rule("email", shad_rule_required(), label = "Email")
v$add_rule("email", shad_rule_email())
v$add_rule("pw", shad_rule_min_chars(8))
v$bind_submit("submit")   # disables the button until valid
v$bind_summary("errors")  # renders an error summary panel
v$enable()
```

Put `shad_rule_required()` first so an empty field reports *Required.* rather
than a format complaint. See `vignette("forms")`.

## Streaming chat

The handler may return a complete string, a chunk-yielding function, or a coro
generator, so an `ellmer` stream drops straight in. Live provider integrations
are experimental.

```r
shad_chat_server("chat", handler = function(user, history) {
  chat$stream(user)
})
```

See `vignette("chat")`.

## ExtendedTask buttons (experimental)

`bind_shad_task_button()` connects an application-owned
`shiny::ExtendedTask` to an existing `shad_button()`. It observes only
`task$status()`: while the task is running the button shows a spinner and is
disabled; after success or error it is enabled again, with optional labels.
The helper never invokes the task, calls `task$result()`, creates workers, or
imports an asynchronous backend.

```r
task <- shiny::ExtendedTask$new(function(value) {
  expensive_work(value)  # return a promise-compatible result
})

ui <- shad_button("Run", inputId = "run")
server <- function(input, output, session) {
  bind_shad_task_button(task, "run", label_success = "Complete",
                        label_error = "Try again", session = session)
  observeEvent(input$run, task$invoke(input$value), ignoreInit = TRUE)
}
```

Task creation and asynchronous execution remain application concerns. For
example, an application can use optional `mirai` or `promises::future_promise()`
backends when installed:

```r
if (requireNamespace("mirai", quietly = TRUE)) {
  task <- shiny::ExtendedTask$new(function(value) {
    mirai::mirai(expensive_work(value), value = value)
  })
}

if (requireNamespace("promises", quietly = TRUE) &&
    requireNamespace("future", quietly = TRUE)) {
  task <- shiny::ExtendedTask$new(function(value) {
    promises::future_promise(expensive_work(value))
  })
}
```

These optional packages are not shadshiny dependencies. See
`vignette("server-api")` for the lifecycle contract.

## Theming

Colours are OKLCH `--shad-*` custom properties, so never hard-code hex. Pick a
preset at page level or swap it live:

```r
page_shad(theme_preset = "green")            # slate stone blue green rose violet orange

# server-side, e.g. from a shad_select + shad_switch toolbar
update_shad_theme(preset = input$preset, dark = input$dark)
```

Build a custom palette with `shad_theme()`, scope one to a subtree with
`shad_theme_scope()`, or import tweakcn / shadcn registry JSON with
`shad_theme_from_registry()`.

Dark mode is driven by `.dark` / `[data-bs-theme="dark"]`, so
`bslib::input_dark_mode()` toggles shadshiny components with no extra wiring.
See `vignette("theming")`.

## Example apps

Each is a real app, launchable with `shad_run_example()`:

| | |
|---|---|
| `kitchen-sink` | Every component, variant and server round-trip |
| `01-auth-onboarding` | Tabbed auth card, a 4-step wizard, and input-OTP 2FA |
| `02-analytics-dashboard` | Admin console: live chart, date range, command palette, mutable team directory |
| `03-support-chat` | Conversation list, stick-to-bottom transcript, composer with attachments |
| `04-storefront` | Product page: carousel, variant pickers, add-to-cart sheet, reviews |
| `05-settings-profile` | Vertical tabs, profile and notification forms, a live appearance panel |
| `06-docs-reader` | Sidebar nav, ⌘K palette, resizable article/TOC split, prev/next paging |
| `07-data-explorer` | `shad_data_table()` with value boxes and theme-following plots |
| `08-llm-chat` | Streaming `shad_chat_server()`; swap the handler for `ellmer` to go live (experimental) |
| `09-app-shell` | `shad_page_sidebar()`, layout primitives, sparklines, a ⌘K palette that navigates, and server-built dialogs |

## Guides

`vignette("shadshiny")` to get started, then: `installation`, `theming`,
`forms`, `data-tables`, `charts`, `chat`, `layout`, `server-api`,
`overlays-and-server`, and `migrating-inputs`, a complete base-Shiny to
shadshiny reference. The [pkgdown site](https://orijitghosh.github.io/shadshiny/)
adds a live component gallery and an icon reference (78 built-in icons; use any
other Lucide glyph via `shad_icon_raw()`).

## Attribution

shadshiny is inspired by and visually compatible with
[shadcn/ui](https://ui.shadcn.com) (MIT) by shadcn, which itself builds on
[Radix UI](https://www.radix-ui.com) primitives. **No upstream source code is
vendored.** All CSS and JavaScript in this package were reimplemented from
scratch to be framework-free and Shiny-native. shadcn/ui and Radix are
trademarks of their respective owners. shadshiny is released under the
[MIT License](LICENSE).
