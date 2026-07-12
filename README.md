<!-- README.md is generated. Edit the source, not the rendered gallery. -->

# shadshiny

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/orijitghosh/shadshiny/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/orijitghosh/shadshiny/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
<!-- badges: end -->

**shadshiny** brings the [shadcn/ui](https://ui.shadcn.com) design system to
[Shiny](https://shiny.posit.co). It is a from-scratch port — 59 accessible,
themeable components rebuilt in framework-free CSS and vanilla JavaScript, then
wrapped as ordinary R functions with native Shiny input bindings.

- **No build step, no npm, no React.** Components are plain `htmltools` tags
  backed by a single bundled asset dependency.
- **Native Shiny inputs.** Read values with `input$id`; drive them from the
  server with `update_shad_*()`. Modules and `renderUI()` just work.
- **Coexists with Bootstrap 5 / bslib.** Dark mode keys off the same signals
  `bslib::input_dark_mode()` uses, so theme sync needs zero glue.
- **OKLCH token theming.** Seven presets out of the box, switchable at runtime.

> shadshiny is an independent reimplementation. It ships no shadcn/ui or Radix
> source — only visually-compatible CSS/JS written for this package. See
> [Attribution](#attribution).

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

Run the flagship demo covering every component:

```r
shad_run_example("kitchen-sink")
```

## Components

**Tier 1 — display & typography**

| | | | |
|---|---|---|---|
| `shad_button` | `shad_badge` | `shad_avatar` | `shad_card` |
| `shad_alert` | `shad_separator` | `shad_skeleton` | `shad_spinner` |
| `shad_aspect_ratio` | `shad_label` | `shad_progress` | `shad_breadcrumb` |
| `shad_table` | `shad_kbd` | `shad_code` | typography (`shad_h1`…`shad_p`) |
| `shad_item` | `shad_empty` | `shad_button_group` | |

**Tier 2 — form inputs**

| | | | |
|---|---|---|---|
| `shad_input` | `shad_textarea` | `shad_checkbox` | `shad_switch` |
| `shad_radio_group` | `shad_toggle` | `shad_toggle_group` | `shad_slider` |
| `shad_select` | `shad_native_select` | `shad_combobox` | `shad_input_otp` |
| `shad_calendar` | `shad_date_picker` | `shad_form_field` | `shad_input_group` |

**Tier 3 — overlays**

| | | | |
|---|---|---|---|
| `shad_dialog` | `shad_alert_dialog` | `shad_sheet` | `shad_drawer` |
| `shad_popover` | `shad_tooltip` | `shad_hover_card` | `shad_dropdown_menu` |
| `shad_context_menu` | `shad_menubar` | `shad_command` | `shad_toast` |

**Tier 3 — navigation & structure**

| | | | |
|---|---|---|---|
| `shad_tabs` | `shad_accordion` | `shad_collapsible` | `shad_pagination` |
| `shad_scroll_area` | `shad_resizable` | `shad_carousel` | `shad_navigation_menu` |
| `shad_sidebar_layout` | | | |

**Chat / AI kit**

| | | | |
|---|---|---|---|
| `shad_message` | `shad_bubble` | `shad_attachment` | `shad_marker` |
| `shad_message_scroller` | | | |

Every stateful component is namespaced-module safe and has a matching
`update_shad_*()` server helper where it holds a value. Overlays add
`shad_<name>_open()` / `shad_<name>_close()`.

## Theming

Colours are OKLCH `--shad-*` custom properties — never hard-code hex. Pick a
preset at page level or swap it live:

```r
page_shad(theme_preset = "green")            # slate stone blue green rose violet orange

# server-side, e.g. from a shad_select + shad_switch toolbar
update_shad_theme(preset = input$preset, dark = input$dark)
```

Dark mode is driven by `.dark` / `[data-bs-theme="dark"]`, so
`bslib::input_dark_mode()` toggles shadshiny components with no extra wiring.
See `vignette("theming")`.

## Attribution

shadshiny is inspired by and visually compatible with
[shadcn/ui](https://ui.shadcn.com) (MIT) by shadcn, which itself builds on
[Radix UI](https://www.radix-ui.com) primitives. **No upstream source code is
vendored.** All CSS and JavaScript in this package were reimplemented from
scratch to be framework-free and Shiny-native. shadcn/ui and Radix are
trademarks of their respective owners. shadshiny is released under the
[MIT License](LICENSE).
