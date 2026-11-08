# Migrating from base Shiny

shadshiny is designed to sit on top of an ordinary Shiny app: same
`inputId` in, same `input$id` out, same reactive graph. Most migrations
are a find-and- replace of the UI constructor. This page is the
**complete map** of base Shiny (and common `shiny`/`bslib`) UI to its
shadshiny counterpart, grouped by area, with the value-shape differences
flagged so nothing surprises you server-side.

A handful of base functions have **no drop-in** – they are render slots
(`plotOutput`, `uiOutput`) or wiring (`fileInput`, `downloadButton`)
that shadshiny deliberately doesn’t re-implement. Those rows say so and
tell you what to keep. Where shadshiny only restyles the surrounding
markup, that is noted too.

> **Conventions.** “drop-in” = same `inputId`/`input$id` contract, swap
> the constructor. “restyle” = keep the base binding, wrap or class it
> for the shadcn look. “keep base” = no shadshiny equivalent; use the
> base function.

## Inputs

| base Shiny | shadshiny | Kind | Notes |
|----|----|----|----|
| [`textInput()`](https://rdrr.io/pkg/shiny/man/textInput.html) | [`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md) | drop-in | `type=` for email/password/number/search. |
| [`passwordInput()`](https://rdrr.io/pkg/shiny/man/passwordInput.html) | `shad_input(type = "password")` | drop-in | – |
| [`textAreaInput()`](https://rdrr.io/pkg/shiny/man/textAreaInput.html) | [`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md) | drop-in | `autosize = TRUE` grows with content. |
| [`numericInput()`](https://rdrr.io/pkg/shiny/man/numericInput.html) | [`shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_number_input.md) | drop-in | Numeric value with stepper buttons, `min`/`max`/`step`, and clamping. `shad_input(type = "number")` is the plainer alternative. |
| [`checkboxInput()`](https://rdrr.io/pkg/shiny/man/checkboxInput.html) | [`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md) | drop-in | Adds a tri-state `"indeterminate"`. |
| [`checkboxInput()`](https://rdrr.io/pkg/shiny/man/checkboxInput.html) (on/off) | [`shad_switch()`](https://orijitghosh.github.io/shadshiny/reference/shad_switch.md) | drop-in | Logical value; the toggle-switch look. |
| [`checkboxGroupInput()`](https://rdrr.io/pkg/shiny/man/checkboxGroupInput.html) | `shad_toggle_group(type = "multiple")` | drop-in | Returns a character vector of selected values. |
| [`radioButtons()`](https://rdrr.io/pkg/shiny/man/radioButtons.html) | [`shad_radio_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_radio_group.md) | drop-in | Single string value. |
| [`selectInput()`](https://rdrr.io/pkg/shiny/man/selectInput.html) | [`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md) | drop-in | Single value; styled listbox. |
| [`selectInput()`](https://rdrr.io/pkg/shiny/man/selectInput.html) (plain `<select>`) | [`shad_native_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_native_select.md) | drop-in | A styled real `<select>` – lightest option. |
| `selectInput(multiple = TRUE)` | `shad_combobox(multiple = TRUE)` | drop-in | Searchable; returns a character vector. |
| [`selectizeInput()`](https://rdrr.io/pkg/shiny/man/selectInput.html) | [`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md) | drop-in | Type-ahead search; `multiple =` for tags. |
| [`varSelectInput()`](https://rdrr.io/pkg/shiny/man/varSelectInput.html) | [`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md) / [`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md) | restyle | Feed `choices = names(data)` yourself. |
| [`sliderInput()`](https://rdrr.io/pkg/shiny/man/sliderInput.html) | [`shad_slider()`](https://orijitghosh.github.io/shadshiny/reference/shad_slider.md) | drop-in | Two-element `value` makes it a range. |
| [`sliderInput()`](https://rdrr.io/pkg/shiny/man/sliderInput.html) (range) | `shad_slider(value = c(lo, hi))` | drop-in | Returns a length-2 numeric. |
| [`dateInput()`](https://rdrr.io/pkg/shiny/man/dateInput.html) | [`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md) | drop-in | Value is an ISO `"YYYY-MM-DD"` string. `caption_layout = "dropdown"` gives the month/year selects that [`dateInput()`](https://rdrr.io/pkg/shiny/man/dateInput.html) has by default. |
| [`dateRangeInput()`](https://rdrr.io/pkg/shiny/man/dateRangeInput.html) | `shad_date_picker(mode = "range")` | drop-in | Value is `list(start, end)`. |
| – (calendar surface) | [`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md) | new | Inline month grid; `input$id` is the picked date. |
| – (segmented code) | [`shad_input_otp()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_otp.md) | new | One-time-code entry; no base analogue. |
| [`fileInput()`](https://rdrr.io/pkg/shiny/man/fileInput.html) | [`shad_dropzone()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropzone.md) | drop-in | Drag-and-drop surface over a hidden [`fileInput()`](https://rdrr.io/pkg/shiny/man/fileInput.html), so `input$id` is the same files data frame. Pair with [`shad_attachment()`](https://orijitghosh.github.io/shadshiny/reference/shad_attachment.md) to render the uploaded-file list. |
| – (star rating) | [`shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/shad_rating.md) | new | Numeric rating; `half = TRUE` for half-stars. |
| – (wizard) | [`shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/shad_stepper.md) (+ [`shad_step()`](https://orijitghosh.github.io/shadshiny/reference/shad_step.md)) | new | Multi-step flow; `input$id` is the active step. |
| – (hierarchy picker) | [`shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree.md) (+ [`shad_tree_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree_item.md)) | new | Tree with selection and `input$<id>_expanded`. |
| [`dateRangeInput()`](https://rdrr.io/pkg/shiny/man/dateRangeInput.html) + preset buttons | `shad_date_picker(mode = "range", presets = shad_date_presets())` | drop-in | Adds a preset rail (“Last 7 days”, “This month”, …). |

## Buttons & actions

| base Shiny | shadshiny | Kind | Notes |
|----|----|----|----|
| [`actionButton()`](https://rdrr.io/pkg/shiny/man/actionButton.html) | [`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md) | drop-in | Same action-button semantics + `variant`/`size`/`icon`. |
| [`actionLink()`](https://rdrr.io/pkg/shiny/man/actionButton.html) | `shad_button(variant = "link")` | drop-in | Link-styled action button. |
| [`submitButton()`](https://rdrr.io/pkg/shiny/man/submitButton.html) | [`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md) + explicit reactivity | restyle | `submitButton` is discouraged in modern Shiny; wire [`observeEvent()`](https://rdrr.io/pkg/shiny/man/observeEvent.html). |
| [`downloadButton()`](https://rdrr.io/pkg/shiny/man/downloadButton.html) / [`downloadLink()`](https://rdrr.io/pkg/shiny/man/downloadButton.html) | keep base | keep base | Needs the `downloadHandler` binding. Add `class = "shad-btn ..."` to style it. |
| toggle button | [`shad_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle.md) | new | Single pressable toggle; `input$id` is logical. |
| segmented buttons | [`shad_button_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_button_group.md) | new | Grouped/segmented button bar. |

## Layout & page structure

| base Shiny / bslib | shadshiny | Kind | Notes |
|----|----|----|----|
| [`fluidPage()`](https://rdrr.io/pkg/shiny/man/fluidPage.html) / [`fillPage()`](https://rdrr.io/pkg/shiny/man/fillPage.html) | [`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md) | drop-in | Loads tokens + assets; `theme_preset =` sets the palette. |
| [`titlePanel()`](https://rdrr.io/pkg/shiny/man/titlePanel.html) | [`shad_h1()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md) (typography set) | restyle | – |
| [`sidebarLayout()`](https://rdrr.io/pkg/shiny/man/sidebarLayout.html) / [`sidebarPanel()`](https://rdrr.io/pkg/shiny/man/sidebarLayout.html) / [`mainPanel()`](https://rdrr.io/pkg/shiny/man/sidebarLayout.html) | [`shad_sidebar_layout()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md) | drop-in | Collapsible app sidebar; `input$id` reports `{collapsed, mobileOpen, active}`. |
| [`wellPanel()`](https://rdrr.io/pkg/shiny/man/wellPanel.html) | [`shad_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_card.md) (+ parts) | restyle | Panel/box surface. |
| [`fluidRow()`](https://rdrr.io/pkg/shiny/man/fluidPage.html) / [`column()`](https://rdrr.io/pkg/shiny/man/column.html) | CSS grid/flex or [`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md) body | restyle | Use Bootstrap grid or your own CSS; shadshiny doesn’t reimplement the grid. |
| [`splitLayout()`](https://rdrr.io/pkg/shiny/man/splitLayout.html) / [`verticalLayout()`](https://rdrr.io/pkg/shiny/man/verticalLayout.html) | [`shad_resizable()`](https://orijitghosh.github.io/shadshiny/reference/shad_resizable.md) (+ panel/handle) | restyle | Draggable split panes when you want resizing. |
| [`conditionalPanel()`](https://rdrr.io/pkg/shiny/man/conditionalPanel.html) | [`shad_collapsible()`](https://orijitghosh.github.io/shadshiny/reference/shad_collapsible.md) | restyle | Client-side show/hide; or keep `conditionalPanel` for JS-expression gating. |
| [`hr()`](https://rstudio.github.io/htmltools/reference/builder.html) | [`shad_separator()`](https://orijitghosh.github.io/shadshiny/reference/shad_separator.md) | drop-in | Horizontal or vertical rule. |
| [`absolutePanel()`](https://rdrr.io/pkg/shiny/man/absolutePanel.html) / [`fixedPanel()`](https://rdrr.io/pkg/shiny/man/absolutePanel.html) | keep base | keep base | Positioning helpers; no shadcn analogue. |
| [`bslib::card()`](https://rstudio.github.io/bslib/reference/card.html) | [`shad_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_card.md) | drop-in | Header/title/description/content/footer parts. |
| [`bslib::value_box()`](https://rstudio.github.io/bslib/reference/value_box.html) | [`shad_value_box()`](https://orijitghosh.github.io/shadshiny/reference/shad_value_box.md) | drop-in | KPI card with trend delta chip, icon, and a sparkline slot. |
| [`bslib::accordion()`](https://rstudio.github.io/bslib/reference/accordion.html) | [`shad_accordion()`](https://orijitghosh.github.io/shadshiny/reference/shad_accordion.md) (+ item) | drop-in | `type = "single"|"multiple"`. |

## Navigation

| base Shiny / bslib | shadshiny | Kind | Notes |
|----|----|----|----|
| [`tabsetPanel()`](https://rdrr.io/pkg/shiny/man/tabsetPanel.html) / [`tabPanel()`](https://rdrr.io/pkg/shiny/man/tabPanel.html) | [`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md) / [`shad_tab()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md) | drop-in | `input$id` is the active tab value. |
| [`navbarPage()`](https://rdrr.io/pkg/shiny/man/navbarPage.html) | [`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md) + [`shad_navigation_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_navigation_menu.md) or [`shad_sidebar_layout()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md) | restyle | Compose the shell yourself. |
| [`navlistPanel()`](https://rdrr.io/pkg/shiny/man/navlistPanel.html) | [`shad_sidebar_layout()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md) | restyle | Sidebar nav; observe `input$id$active`. |
| `bslib::navset_*()` | [`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md) / [`shad_navigation_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_navigation_menu.md) | restyle | – |
| `breadcrumb` (manual) | [`shad_breadcrumb()`](https://orijitghosh.github.io/shadshiny/reference/shad_breadcrumb.md) (+ item/separator) | new | – |
| paging controls (manual) | [`shad_pagination()`](https://orijitghosh.github.io/shadshiny/reference/shad_pagination.md) | new | `input$id` is the current page. |

## Overlays & modals

| base Shiny | shadshiny | Kind | Notes |
|----|----|----|----|
| [`modalDialog()`](https://rdrr.io/pkg/shiny/man/modalDialog.html) + [`showModal()`](https://rdrr.io/pkg/shiny/man/showModal.html) / [`removeModal()`](https://rdrr.io/pkg/shiny/man/showModal.html) | [`shad_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_dialog.md) in UI + [`shad_dialog_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md) / [`shad_dialog_close()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md) | pattern shift | Define the dialog in the UI, toggle by `id` from the server (not built server-side). |
| destructive confirm modal | [`shad_alert_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_alert_dialog.md) + `_open()` / `_close()` | new | Purpose-built confirm/cancel dialog. |
| off-canvas / `bslib::*_sidebar` slide-over | [`shad_sheet()`](https://orijitghosh.github.io/shadshiny/reference/shad_sheet.md) + `_open()` / `_close()` | new | Edge sheet panel. |
| bottom sheet | [`shad_drawer()`](https://orijitghosh.github.io/shadshiny/reference/shad_drawer.md) + `_open()` / `_close()` | new | – |
| [`bslib::popover()`](https://rstudio.github.io/bslib/reference/popover.html) | [`shad_popover()`](https://orijitghosh.github.io/shadshiny/reference/shad_popover.md) + `_open()` / `_close()` | drop-in | – |
| [`bslib::tooltip()`](https://rstudio.github.io/bslib/reference/tooltip.html) | [`shad_tooltip()`](https://orijitghosh.github.io/shadshiny/reference/shad_tooltip.md) | drop-in | Hover/focus tooltip. |
| hover preview | [`shad_hover_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_hover_card.md) | new | Rich hover card. |
| dropdown menu | [`shad_dropdown_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropdown_menu.md) (+ items) | new | Menu, checkbox/radio items, submenus. |
| right-click menu | [`shad_context_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_context_menu.md) | new | – |
| app menubar | [`shad_menubar()`](https://orijitghosh.github.io/shadshiny/reference/shad_menubar.md) (+ menu) | new | – |
| ⌘K palette | [`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md) (+ group/item) | new | Grouped, keyword-searchable command palette. |

## Notifications & feedback

| base Shiny | shadshiny | Kind | Notes |
|----|----|----|----|
| [`showNotification()`](https://rdrr.io/pkg/shiny/man/showNotification.html) | [`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md) (+ `_success`/`_error`/`_warning`) | drop-in | Server-raised toasts. |
| `showNotification(type = "message", duration = NULL)` (loading) | [`shad_toast_loading()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md) → [`shad_toast_update()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md) | drop-in | Loading→done flow; pass `session` from deferred callbacks. |
| [`removeNotification()`](https://rdrr.io/pkg/shiny/man/showNotification.html) | [`shad_toast_dismiss()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md) | drop-in | – |
| [`withProgress()`](https://rdrr.io/pkg/shiny/man/withProgress.html) / `Progress$new()` / [`incProgress()`](https://rdrr.io/pkg/shiny/man/withProgress.html) | [`shad_progress()`](https://orijitghosh.github.io/shadshiny/reference/shad_progress.md) + [`update_shad_progress()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md) | pattern shift | Determinate bar you drive by `id`; wrap your own loop. |
| [`insertUI()`](https://rdrr.io/pkg/shiny/man/insertUI.html) / [`removeUI()`](https://rdrr.io/pkg/shiny/man/insertUI.html) | keep base | keep base | Works as-is – inserted shadshiny components auto-initialise. |
| [`validate()`](https://rdrr.io/pkg/shiny/man/validate.html) / [`need()`](https://rdrr.io/pkg/shiny/man/validate.html) | [`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md) (+ `shad_rules`) | pattern shift | Declare rules per field; the validator drives `aria-invalid` and inline [`shad_form_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_message.md) text. Base [`validate()`](https://rdrr.io/pkg/shiny/man/validate.html)/[`need()`](https://rdrr.io/pkg/shiny/man/validate.html) still works for output gating. |

## Outputs & display

| base Shiny | shadshiny | Kind | Notes |
|----|----|----|----|
| [`tableOutput()`](https://rdrr.io/pkg/shiny/man/renderTable.html) / [`renderTable()`](https://rdrr.io/pkg/shiny/man/renderTable.html) | [`shad_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_table.md) (+ parts) via [`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html) | restyle | `shad_table` is static markup; build rows from your data and [`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html). |
| [`dataTableOutput()`](https://rdrr.io/pkg/shiny/man/renderDataTable.html) / `DT` / `reactable` | [`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md) | drop-in | Client-side sort/filter/page/select, styled to the theme. `input$id` reports `{selected, sort, filter, page, pageSize}`; refresh with [`update_shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_data_table.md). Keep `DT` when you need server-side paging over large data. |
| [`plotOutput()`](https://rdrr.io/pkg/shiny/man/plotOutput.html) / [`renderPlot()`](https://rdrr.io/pkg/shiny/man/renderPlot.html) | keep base, inside [`shad_chart_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_container.md) | keep base | Card wrapper with title/description/legend. Theme the plot with [`shad_theme_ggplot2()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md) + [`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md). |
| `plotly` / `echarts4r` widgets | keep base, inside [`shad_chart_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_container.md) | keep base | Restyle with [`shad_theme_plotly()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_plotly.md) / [`shad_theme_echarts4r()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_echarts4r.md). The plot adapters are experimental. |
| event log / activity feed (manual) | [`shad_timeline()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline.md) (+ item) | new | – |
| [`uiOutput()`](https://rdrr.io/pkg/shiny/man/htmlOutput.html) / [`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html) | keep base | keep base | Render slot; emit shadshiny tags into it – they auto-initialise. |
| [`textOutput()`](https://rdrr.io/pkg/shiny/man/textOutput.html) / [`verbatimTextOutput()`](https://rdrr.io/pkg/shiny/man/textOutput.html) | keep base | keep base | Wrap in [`shad_code()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md) / typography for styling. |
| [`icon()`](https://rdrr.io/pkg/shiny/man/icon.html) (Font Awesome) | [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md) | drop-in | Lucide set; see `vignette("icons")`. Any custom SVG also accepted. |
| `progressBar` (manual) | [`shad_progress()`](https://orijitghosh.github.io/shadshiny/reference/shad_progress.md) | new | Determinate progress bar. |
| avatar / badge (manual) | [`shad_avatar()`](https://orijitghosh.github.io/shadshiny/reference/shad_avatar.md) / [`shad_badge()`](https://orijitghosh.github.io/shadshiny/reference/shad_badge.md) | new | – |
| skeleton / spinner (manual) | [`shad_skeleton()`](https://orijitghosh.github.io/shadshiny/reference/shad_skeleton.md) / [`shad_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_spinner.md) | new | Loading placeholders. |

## Typography & static content

| base Shiny / htmltools | shadshiny | Notes |
|----|----|----|
| [`h1()`](https://rstudio.github.io/htmltools/reference/builder.html)–[`h4()`](https://rstudio.github.io/htmltools/reference/builder.html) | [`shad_h1()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md)–[`shad_h4()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md) | Tuned type scale. |
| [`p()`](https://rstudio.github.io/htmltools/reference/builder.html) | [`shad_p()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md) | – |
| `tags$blockquote()` | [`shad_blockquote()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md) | – |
| [`helpText()`](https://rdrr.io/pkg/shiny/man/helpText.html) | [`shad_muted()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md) / [`shad_small()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md) | Muted helper text. |
| [`strong()`](https://rstudio.github.io/htmltools/reference/builder.html) / lead text | [`shad_lead()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md) / [`shad_large()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md) | – |
| [`code()`](https://rstudio.github.io/htmltools/reference/builder.html) | [`shad_code()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md) | Inline code. |
| `tags$kbd()` | [`shad_kbd()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md) | Keyboard key. |
| `tags$ul()` / `tags$li()` | [`shad_list()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md) | Styled list; pass `tags$li()` children, `ordered = TRUE` for `<ol>`. |

## shadshiny-only – no base equivalent

Worth adopting on their own; there is nothing to migrate *from*:

- [`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md)
  – ⌘K command palette with grouped, keyword-searchable items.
- [`shad_input_otp()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_otp.md)
  – segmented one-time-code entry.
- [`shad_sidebar_layout()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md)
  – full collapsible application sidebar with groups, items, badges, and
  a server-toggled state.
- [`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md)
  – server-raised notifications, including loading→done flows.
- The **chat / AI kit** –
  [`shad_bubble()`](https://orijitghosh.github.io/shadshiny/reference/shad_bubble.md),
  [`shad_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_message.md)
  (+ scroller),
  [`shad_attachment()`](https://orijitghosh.github.io/shadshiny/reference/shad_attachment.md),
  [`shad_marker()`](https://orijitghosh.github.io/shadshiny/reference/shad_marker.md)
  – a stick-to-bottom streaming transcript, or
  [`shad_chat_ui()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_ui.md)
  /
  [`shad_chat_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_server.md)
  for the whole module at once.
- [`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md)
  /
  [`shad_theme_from_registry()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_from_registry.md)
  – build a custom palette, or import one from the shadcn theme registry
  (experimental).
- [`shad_empty()`](https://orijitghosh.github.io/shadshiny/reference/shad_empty.md)
  – empty-state panel;
  [`shad_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_item.md)
  – flex list-row primitive.

## Value-shape differences to watch

- **Multi-value inputs return character vectors.**
  `shad_combobox(multiple = TRUE)` and
  `shad_toggle_group(type = "multiple")` give you `c("a", "b")`, not a
  comma-joined string.
- **Range inputs return structured values.**
  `shad_slider(value = c(20, 80))` reports `c(20, 80)`;
  `shad_date_picker(mode = "range")` reports
  `list(start = ..., end = ...)`.
- **Dates are ISO strings.** Convert with `as.Date(input$id)` when you
  need a `Date`.
- **Checkbox tri-state.**
  [`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md)
  can report `"indeterminate"` in addition to `TRUE`/`FALSE`; guard with
  `isTRUE(input$id)`. Users can only click back to it when the checkbox
  has `tristate = TRUE`.
- **Overlays are UI-defined, server-toggled.** Unlike
  [`showModal()`](https://rdrr.io/pkg/shiny/man/showModal.html), a
  [`shad_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_dialog.md)
  lives in the UI and you open/close it by `id`
  (`shad_dialog_open("confirm")`) – Shiny-module safe via the session’s
  ns.

## Updating from the server

Base `updateXxxInput()` calls become `update_shad_*()`, one per valued
component:

``` r

# base Shiny
updateSelectInput(session, "plan", selected = "pro")
updateSliderInput(session, "range", value = c(10, 40))
updateCheckboxInput(session, "agree", value = TRUE)
updateTabsetPanel(session, "tabs", selected = "billing")

# shadshiny
update_shad_select("plan", selected = "pro")
update_shad_slider("range", value = c(10, 40))
update_shad_switch("agree", value = TRUE)
update_shad_tabs("tabs", selected = "billing")
```

The full set:
[`update_shad_input_otp()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_switch()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_radio_group()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_select()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_native_select()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_slider()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_toggle()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_toggle_group()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_button()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_accordion()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_pagination()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_carousel()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_progress()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
and
[`update_shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_theme.md).
See
[`?update_shad`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)
and the [server API
guide](https://orijitghosh.github.io/shadshiny/articles/server-api.md)
for the overlay controllers and the
[`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md)
family.

## See also

- [`vignette("shadshiny")`](https://orijitghosh.github.io/shadshiny/articles/shadshiny.md)
  – get started.
- The **Component gallery** – every component rendered live next to its
  source.
- `shad_run_example("kitchen-sink")` – a live tour of the whole library.
