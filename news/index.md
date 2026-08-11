# Changelog

## shadshiny (development version)

- [`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md)
  and
  [`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md)
  gain `caption_layout` and `year_range`. The header previously stepped
  one month per click, so reaching a distant year meant hundreds of
  clicks (Shift+PageUp/Down was the only jump, and only from the
  keyboard). `caption_layout = "dropdown"` renders the month and year as
  selects, matching shadcn/ui’s `captionLayout`; `"dropdown-months"` and
  `"dropdown-years"` pick one of the two.

- `shad_calendar(month =)` now works. It set `data-month` but the
  browser code never read it, so the argument was silently ignored.

- Assets now ship as one minified stylesheet and one minified script
  (`inst/assets/dist`), built by `npm run build:assets`. A page used to
  carry ~145 tags and 1.3 MB of source; it now carries 2 tags and 274
  kB. Set `options(shadshiny.assets = "source")` to load the
  per-component files when debugging. Node is still not needed to
  install or use the package.

- `tools/audit-registry.R` diffs the port against the live shadcn/ui
  registry. Running it corrected the README component markers: upstream
  now ships `native-select` and the chat primitives, which shadshiny had
  listed as its own additions.

## shadshiny 0.2.0

Eleven new components and several server-side systems that turn
shadshiny from a component library into a full application toolkit.

- **Data table
  ([`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md)):**
  a client-side, shadcn-styled data table with multi-column sort
  (Shift+click), global and per-column filtering, windowed pagination,
  single/multiple row selection persisted across pages, column
  visibility, sticky header, and loading skeletons. Column specs via
  [`shad_col()`](https://orijitghosh.github.io/shadshiny/reference/shad_col.md)
  with formatters
  [`shad_fmt_number()`](https://orijitghosh.github.io/shadshiny/reference/shad_fmt.md),
  [`shad_fmt_percent()`](https://orijitghosh.github.io/shadshiny/reference/shad_fmt.md),
  [`shad_fmt_date()`](https://orijitghosh.github.io/shadshiny/reference/shad_fmt.md),
  and
  [`shad_fmt_badge()`](https://orijitghosh.github.io/shadshiny/reference/shad_fmt.md),
  plus arbitrary `cell` render functions. `input$<id>` reports
  `{selected, sort, filter, page, pageSize}`; refresh from the server
  with
  [`update_shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_data_table.md).

- **Dashboard shells:**
  [`shad_value_box()`](https://orijitghosh.github.io/shadshiny/reference/shad_value_box.md)
  (KPI card with trend delta chip, icon and sparkline slots),
  [`shad_chart_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_container.md)
  (card wrapper for
  [`plotOutput()`](https://rdrr.io/pkg/shiny/man/plotOutput.html)/htmlwidgets
  with legend strip), and
  [`shad_timeline()`](https://orijitghosh.github.io/shadshiny/reference/shad_timeline.md).

- **Chart theming:**
  [`shad_theme_ggplot2()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md)
  /
  [`shad_scale_color_shad()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md)
  /
  [`shad_scale_fill_shad()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md),
  [`shad_theme_plotly()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_plotly.md),
  and
  [`shad_theme_echarts4r()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_echarts4r.md)
  restyle plots to the active theme.
  [`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md)
  is a reactive that re-runs plot code on dark-mode/preset switches.
  [`shad_chart_colors()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_colors.md)
  returns the categorical chart ramp as hex (OKLCH converted in base R –
  no new dependency);
  [`shad_tokens()`](https://orijitghosh.github.io/shadshiny/reference/shad_tokens.md)
  exposes the full resolved token set as CSS strings.

- **Theming V2:**
  [`shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme.md)
  builds arbitrary custom themes from token overrides;
  [`shad_theme_from_registry()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_from_registry.md)
  imports tweakcn / shadcn registry theme JSON; `page_shad(theme=)`,
  [`shad_theme_scope()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_scope.md),
  and `update_shad_theme(theme=)` apply them at page, subtree, and
  runtime scope.

- **Form validation:**
  [`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md)
  with rules
  ([`shad_rule_required()`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md),
  [`shad_rule_email()`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md),
  [`shad_rule_min_chars()`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md),
  [`shad_rule_range()`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md),
  [`shad_rule_regex()`](https://orijitghosh.github.io/shadshiny/reference/shad_rules.md),
  …), live validation, submit gating, and an error summary.
  [`update_shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_form_field.md),
  [`shad_form_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_message.md),
  and
  [`shad_form_summary()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_summary.md)
  provide the underlying messaging.

- **Flow / input components:**
  [`shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/shad_stepper.md),
  [`shad_tree()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree.md)
  (with lazy branches via `update_shad_tree(children=)`),
  [`shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/shad_rating.md),
  [`shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_number_input.md),
  and
  [`shad_dropzone()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropzone.md)
  (bridged to Shiny’s native file upload, so `input$<id>` is the
  standard files data frame). Each is a bound input with an `update_*()`
  companion.

- **Date-range presets:**
  `shad_date_picker(mode = "range", presets = ...)` adds a quick-range
  rail;
  [`shad_date_presets()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_presets.md)
  supplies a default set.

- **Streaming chat
  ([`shad_chat_ui()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_ui.md)
  /
  [`shad_chat_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_server.md)):**
  a module whose handler may return a complete string, a chunk-yielding
  function, or a coro generator (e.g. an ellmer stream); replies stream
  into a stick-to-bottom transcript and render as Markdown.

- **[`shad_icon_raw()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon_raw.md):**
  use any raw `<svg>` (e.g. a Lucide glyph) with the `.shad-icon` sizing
  class.

- **New guides:**
  [`vignette("data-tables")`](https://orijitghosh.github.io/shadshiny/articles/data-tables.md),
  [`vignette("charts")`](https://orijitghosh.github.io/shadshiny/articles/charts.md),
  and
  [`vignette("chat")`](https://orijitghosh.github.io/shadshiny/articles/chat.md);
  the theming and forms guides now cover custom themes and
  [`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md).
  Two new examples: `shad_run_example("07-data-explorer")` and
  `shad_run_example("08-llm-chat")`.

- `input$<id>$sort` on a data table now reports `{column, direction}`
  rather than the client’s terser `{col, dir}`.

- **Bug fix (theme reporter):** the `input$.shad_theme` reporter read
  `document.body` and `Shiny.setInputValue` unguarded, and ran even with
  no Shiny on the page. Since the asset bundle loads in `<head>`, both
  were absent on the first pass, so it threw and aborted the rest of
  `shadshiny-shiny.js` — taking `shad.autoInit()` with it.
  [`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md)
  therefore never fired (charts could not follow runtime theme changes),
  components inserted by
  [`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html) /
  [`insertUI()`](https://rdrr.io/pkg/shiny/man/insertUI.html) were left
  un-wired, and the pkgdown gallery previews (no Shiny) failed the same
  way. Components already on the page still worked, which masked it: the
  runtime self-initialises on `DOMContentLoaded`.

- **Layout primitives:**
  [`shad_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_container.md),
  [`shad_stack()`](https://orijitghosh.github.io/shadshiny/reference/shad_stack.md),
  [`shad_grid()`](https://orijitghosh.github.io/shadshiny/reference/shad_grid.md)
  /
  [`shad_grid_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_grid.md),
  plus the page shells
  [`shad_page_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_sidebar.md)
  and
  [`shad_page_navbar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_navbar.md).
  CSS-only; spacing arguments take a token step (`gap = 4` is
  `var(--shad-space-4)`) or any CSS length, and
  [`shad_grid()`](https://orijitghosh.github.io/shadshiny/reference/shad_grid.md)
  handles responsive columns with an outward
  [`var()`](https://rdrr.io/r/stats/cor.html) fallback chain rather than
  a utility-class grid system.

- **Bug fix (layout):** the layout primitives’ custom properties
  inherited, so a
  [`shad_stack()`](https://orijitghosh.github.io/shadshiny/reference/shad_stack.md)
  nested inside a horizontal one laid itself out sideways (and picked up
  its parent’s gap and alignment). Each rule now resets its own
  variables to `initial`.

- `update_shad_sidebar(active=)` selects a sidebar item from the server,
  so navigating from elsewhere — a command palette, a link — moves the
  rail too.

- **New example:** `shad_run_example("09-app-shell")` —
  [`shad_page_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/shad_page_sidebar.md)
  with the layout primitives, sparklines, a ⌘K palette that drives
  navigation, and dialogs built in the server.

- **Server-created overlays:**
  [`shad_show_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_show_dialog.md)
  /
  [`shad_remove_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_remove_dialog.md)
  build a dialog, alert dialog, sheet or drawer in the server and show
  it, the way
  [`shiny::showModal()`](https://rdrr.io/pkg/shiny/man/showModal.html)
  does. Transient by default: the overlay removes itself once it closes.

- **Native mini-charts:**
  [`shad_sparkline()`](https://orijitghosh.github.io/shadshiny/reference/shad_sparkline.md)
  (line/area/bar/step) and
  [`shad_mini_donut()`](https://orijitghosh.github.io/shadshiny/reference/shad_mini_donut.md)
  — inline SVG painted with the chart tokens, so they follow dark mode
  and preset switches in CSS with no re-render. Fills
  `shad_value_box(sparkline=)`.

- **Command palette:**
  [`shad_command_palette()`](https://orijitghosh.github.io/shadshiny/reference/shad_command_palette.md)
  takes its items as data,
  [`shad_command_trigger()`](https://orijitghosh.github.io/shadshiny/reference/shad_command_palette.md)
  opens one from anywhere, and
  [`update_shad_command()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_command.md)
  refreshes the items from the server. Read selections from
  `input$<id>_event` — `input$<id>` alone cannot tell one selection of
  “Settings” from two.

- **Bug fix (command dialog):**
  `shad_command(dialog = TRUE, hotkey = FALSE)` rendered a visible
  inline palette — the asset infers dialog mode from `data-hotkey` or
  `data-dialog`, and the constructor emitted neither.

- **Bug fix (runtime):** opening a command dialog destroyed it.
  `shad.portal()` moves the root itself to `<body>`, and the runtime’s
  MutationObserver read that removal as an unmount. A move is a removal
  plus an insertion, so the teardown now skips nodes still connected to
  the document.

- **Scroll/focus sweep:** no component calls `scrollIntoView()` any more
  — it walks every scrollable ancestor, so a component in ordinary
  document flow drags the whole page to itself. Highlights now scroll
  their own container via `shad.util.keepInView()`, and pointer-driven
  `focus()` passes `preventScroll`. Keyboard roving focus still scrolls,
  deliberately.

- **Bug fix (command):** an inline
  [`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md)
  scrolled the page to itself on load, and again on every keystroke. Its
  highlight used `scrollIntoView()`/`scrollIntoViewIfNeeded()`, which
  scroll *every* scrollable ancestor — harmless in dialog mode, but an
  inline palette is part of the document, so a page containing one
  opened wherever the palette sat (in the kitchen sink, a long way down
  at *Tier 3 — overlays*). The highlight now scrolls only the command
  list itself.

- **Gallery:** a new *Data, dashboards & flow* page renders the V2 kit
  live — data table, value boxes, chart container, timeline, stepper,
  tree, rating, number input, dropzone, and the form-messaging
  components.

- **Demo:** `kitchen-sink` now covers the V2 components, including a
  plot that tracks the theme toolbar via
  [`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md)
  and a live
  [`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md)
  form. Its `update_*()` / scroll / sidebar controls moved next to the
  components they drive — previously they sat in a card at the foot of
  the page and appeared to do nothing, because the component they
  changed was scrolled far out of view.

- **Bookmarking:** `shad_input_otp(value=)` now seeds and restores its
  code.

- `jsonlite` moves to Imports (used by the data table and theming).

- **Bookmarking support:** every stateful input now seeds its initial
  value from
  [`shiny::restoreInput()`](https://rdrr.io/pkg/shiny/man/restoreInput.html),
  so
  [`enableBookmarking()`](https://rdrr.io/pkg/shiny/man/enableBookmarking.html)
  (both `"url"` and `"server"`) restores saved state on reload. Covers
  [`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md),
  [`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md),
  [`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md),
  [`shad_switch()`](https://orijitghosh.github.io/shadshiny/reference/shad_switch.md),
  [`shad_slider()`](https://orijitghosh.github.io/shadshiny/reference/shad_slider.md),
  [`shad_toggle()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle.md),
  [`shad_toggle_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_toggle_group.md),
  [`shad_radio_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_radio_group.md),
  [`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md),
  [`shad_native_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_native_select.md),
  [`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md),
  [`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md),
  [`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md),
  [`shad_accordion()`](https://orijitghosh.github.io/shadshiny/reference/shad_accordion.md),
  [`shad_pagination()`](https://orijitghosh.github.io/shadshiny/reference/shad_pagination.md),
  and
  [`shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/shad_tabs.md).
  Not restored (they take no initial-value argument): the overlays’ open
  state,
  [`shad_input_otp()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_otp.md),
  [`shad_carousel()`](https://orijitghosh.github.io/shadshiny/reference/shad_carousel.md),
  and
  [`shad_sidebar()`](https://orijitghosh.github.io/shadshiny/reference/shad_sidebar_layout.md)
  — their values are still *saved*, only not seeded back on restore.

- **Docs:** the *Migrating from base Shiny* guide is now a **complete**
  base-Shiny→shadshiny reference — sectioned tables covering inputs,
  buttons, layout, navigation, overlays, notifications, outputs, and
  typography, each row tagged drop-in / restyle / keep-base, plus the
  value-shape gotchas and the full `update_shad_*()` map. (Previously an
  inputs-only table.)

- **Bug fix (icons):**
  [`shad_icon()`](https://orijitghosh.github.io/shadshiny/reference/shad_icon.md)
  now carries the shadshiny asset dependency, so a standalone icon still
  loads its `.shad-icon` sizing CSS when it is the only shadshiny output
  on a page (previously such icons rendered size-less / invisible —
  e.g. the icon previews in the pkgdown *Icons* article). Nested in a
  component, the duplicate dependency is de-duplicated as before.

- **Bug fix (component init):** `shad.autoInit()` no longer throws when
  the asset bundle loads in `<head>` before `document.body` exists.
  Previously the `MutationObserver` attached to a null body, which
  aborted initialisation and left dynamically inserted components
  (`renderUI`, `insertUI`, dynamic tabs) un-wired. Components now
  initialise immediately and the observer attaches on DOM ready.

- **Bug fix (input group):** the wrapped control’s `width: 100%` no
  longer forces leading/trailing addons onto their own rows — the
  control now flexes from a zero basis so icons, prefixes and buttons
  sit inline as intended.

- **More icons:** the built-in set grows from 32 to 78, adding common
  glyphs — `home`, `user`, `users`, `settings`, `bell`, `trash`,
  `pencil`, `download`, `upload`, `external-link`, `eye`, `eye-off`,
  `lock`, `unlock`, `heart`, `star`, `bookmark`, `filter`, `refresh-cw`,
  `log-in`, `log-out`, `copy`, `clipboard`, `save`, `sun`, `moon`,
  `image`, `link`, `phone`, `map-pin`, `credit-card`, `shopping-cart`,
  `package`, `bar-chart`, `activity`, `zap`, `message-circle`, `send`,
  `paperclip`, `thumbs-up`, `globe`, `github`, `circle-x`,
  `circle-plus`, `circle-help`, `arrow-up`, `arrow-down`, and
  `chevrons-down-up`.

- **Demo:** the `kitchen-sink` sidebar now switches its main pane per
  nav item, and its chat scroller starts at the top so the “Scroll chat”
  round-trip is visible.

- **Documentation site.** The pkgdown site is now a full handbook. A new
  **Component gallery** renders every component *live* — the real
  component next to the exact source that made it — across pages for
  display, inputs, overlays, navigation and the chat kit, plus a live
  **Icons** reference. The previews initialise client-side (dialogs,
  tabs and carousels work) and follow the site’s light/dark switch. New
  prose guides cover **Installation & setup**, **Forms & validation**,
  **Layout & composition**, and **The server API**.

- **New components (chat / AI kit):**
  [`shad_bubble()`](https://orijitghosh.github.io/shadshiny/reference/shad_bubble.md)
  (+ group),
  [`shad_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_message.md)
  (+ group,
  [`shad_message_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_spinner.md)),
  [`shad_attachment()`](https://orijitghosh.github.io/shadshiny/reference/shad_attachment.md)
  (+ group,
  [`shad_attachment_action()`](https://orijitghosh.github.io/shadshiny/reference/shad_attachment.md)),
  [`shad_marker()`](https://orijitghosh.github.io/shadshiny/reference/shad_marker.md),
  and
  [`shad_message_scroller()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller.md)
  (+ item, and the
  [`shad_message_scroller_to_bottom()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller_to_bottom.md)
  server helper) — a stick-to-bottom streaming transcript.

- **New components (layout & inputs):**
  [`shad_native_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_native_select.md)
  (a styled real `<select>` with
  [`update_shad_native_select()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)),
  [`shad_empty()`](https://orijitghosh.github.io/shadshiny/reference/shad_empty.md)
  (empty-state panel),
  [`shad_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_item.md)
  (+ group, separator) — the flex list-row primitive,
  [`shad_button_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_button_group.md)
  (+ text, separator) — segmented button controls, and
  [`shad_input_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_group.md)
  (+ addon, text, button) — a field shell for icon/prefix/button affixes
  around
  [`shad_input()`](https://orijitghosh.github.io/shadshiny/reference/shad_input.md)
  /
  [`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md).

- **New icons:** `file`, `folder`, `clock`.

- **Bug fix:**
  [`shad_context_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_context_menu.md)
  now wraps its `target` in the `.shad-context-menu__zone` element the
  JS binds to, so the right-click zone initialises instead of erroring
  on load.

- **Demo:** the `kitchen-sink` example now exercises the full variant /
  size / state matrix for every component.

- **Example apps:** six new real-world example apps under
  `inst/examples`, launchable with
  [`shad_run_example()`](https://orijitghosh.github.io/shadshiny/reference/shad_run_example.md),
  that together exercise the whole component library:
  `01-auth-onboarding`, `02-analytics-dashboard`, `03-support-chat`,
  `04-storefront`, `05-settings-profile`, and `06-docs-reader`.

- **Bug fix:**
  [`shad_toast_update()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md)
  called from a deferred
  ([`later::later`](https://later.r-lib.org/reference/later.html))
  callback now requires the `session` to be passed explicitly; the
  bundled demos do so, fixing an “attempt to apply non-function” crash
  on toast loading→update outside the reactive domain.

## shadshiny 0.1.0

Initial release.

- A framework-free port of the [shadcn/ui](https://ui.shadcn.com) design
  system for Shiny: 49 components across three tiers, shipped as a
  single bundled `htmlDependency()` (no npm, no React, no build step).
- **Tier 1 — display & typography:** button, badge, avatar (+ group),
  card (+ parts), alert, separator, skeleton, spinner, aspect-ratio,
  label, progress, breadcrumb, table (+ parts), kbd, code, and the
  [`shad_h1()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md)–
  [`shad_p()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md)
  typography set.
- **Tier 2 — form inputs:** input, textarea, checkbox, switch, radio
  group, toggle, toggle group, slider, select, combobox, input-OTP,
  calendar, date-picker, and the
  [`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)
  wrapper. All expose native Shiny input values via a generic
  `data-shad` binding.
- **Tier 3 — overlays:** dialog, alert-dialog, sheet, drawer, popover,
  tooltip, hover-card, dropdown-menu, context-menu, menubar, command
  palette, and toast.
- **Tier 3 — navigation & structure:** tabs, accordion, collapsible,
  pagination, scroll-area, resizable, carousel, navigation-menu, and the
  sidebar layout family.
- **Server API:** `update_shad_*()` helpers for every valued component,
  `shad_<overlay>_open()` / `_close()` controllers, and a
  [`shad_toast()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md)
  family (success/error/warning/loading, plus
  [`shad_toast_update()`](https://orijitghosh.github.io/shadshiny/reference/shad_toast.md)
  for loading→done flows). All are Shiny-module safe.
- **Theming:** OKLCH `--shad-*` token system with seven presets (slate,
  stone, blue, green, rose, violet, orange), `page_shad(theme_preset=)`,
  and runtime
  [`update_shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_theme.md).
  Dark mode synchronizes with
  [`bslib::input_dark_mode()`](https://rstudio.github.io/bslib/reference/input_dark_mode.html)
  out of the box.
- **Demo:** `shad_run_example("kitchen-sink")` exercises every
  component, variant, and server round-trip.
