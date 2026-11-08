# Changelog

## shadshiny 0.4.0

- Prepared for a first CRAN release. Every exported help page now has an
  example; those that need a running app build one inside
  `if (interactive())`. The
  [`shad_theme_from_registry()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_from_registry.md)
  and toast examples no longer use `\dontrun{}`, and the
  [`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md)
  and
  [`shad_chat_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_server.md)
  examples are now complete apps: they called server functions outside a
  session, so they failed when run. The package now ships a `COPYRIGHTS`
  file with the licence notices for the Lucide icons (ISC; some derive
  from Feather, MIT) and the shadcn/ui colour token values (MIT), and
  DESCRIPTION points to it in a `Copyright:` field. The README and the
  package help say the same.

- Five more full-ramp colour presets from shadcn/ui: `"zinc"`,
  `"mauve"`, `"olive"`, `"mist"` and `"taupe"`. Like `"slate"` and
  `"stone"`, each one recolours every surface, border and text token, in
  light and dark mode, and tunes the chart grid and labels to match. Use
  them with `page_shad(theme_preset=)`,
  [`shad_theme_preset()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_preset.md),
  [`update_shad_theme()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_theme.md)
  and
  [`shad_tokens()`](https://orijitghosh.github.io/shadshiny/reference/shad_tokens.md).
  Muted text is darkened in light mode, as in the other presets, so that
  it keeps a 4.5:1 contrast. Tests now check that the CSS and
  `shad-tokens.json` agree for every preset, and that the text in each
  full-ramp preset stays at 4.5:1 on its surfaces. The bundle’s gzip
  budget for the CSS rises from 22 KiB to 23 KiB, and for CSS and
  JavaScript together from 64 KiB to 65 KiB.

- Live integrations with external chat stream providers, such as
  streaming an `ellmer` chat, are experimental, and now say so wherever
  they are shown: the README, the chat article, the
  [`shad_chat_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_server.md)
  and
  [`shad_run_example()`](https://orijitghosh.github.io/shadshiny/reference/shad_run_example.md)
  help, and the `08-llm-chat` example. A test requires it.

- [`shad_theme_echarts4r()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_echarts4r.md)
  keeps a text style already set on the chart, such as its font family
  and size, and changes only its colour; it used to replace the whole
  style. Tests now cover the chart adapters for ggplot2, plotly and
  echarts4r, in light and dark mode.

- Fixes from a visual review in light, dark, right-to-left and reduced
  motion.
  [`shad_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_table.md)
  given a data frame renders its body rows again. Dialogs, alert dialogs
  and the command palette are centred on right-to-left pages, where they
  sat partly off-screen, and so are resizable grips and vertical slider
  thumbs. Breadcrumb lists drop Bootstrap’s list indent, and the
  checkbox tick no longer animates under reduced motion. The
  `.shad-scope` link colour no longer overrides component link colours:
  breadcrumb links are muted again, and an anchor styled as a button
  keeps its text colour on hover. A short bubble in a message footer
  stays on one line, and `shad_chart_container(aspect = "auto")` keeps
  the height of the plot output inside it instead of collapsing it.

- [`shad_chat_ui()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_ui.md)
  shows its `welcome` until the first message (it was accepted but never
  shown), and its composer now spans the chat’s width.

- The examples and the charts article pass `bg = "transparent"` to
  [`renderPlot()`](https://rdrr.io/pkg/shiny/man/renderPlot.html), so
  plots sit on the card in dark mode. The LLM chat example’s Clear
  button works, and the examples’ native selects have accessible names.

- [`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md)’s
  help page documents `input$<inputId>_event`, which every command emits
  on each activation, not only the palette. The component-contract test
  now requires each such side input on its constructor’s help page, and
  counts
  [`update_shad_command()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_command.md)
  as the command’s updater.

- The twelve articles that show code without running it use the
  `knitr::rmarkdown_notangle` engine. `R CMD check` on R versions that
  run vignette code, such as R 4.3, ran their examples, which failed and
  in the chat article started an app that never returned. A test now
  requires such articles to tangle to no code.

- The advertised component count now follows a documented rule: a
  component is an asset family with an exported constructor of its own,
  which gives 73. Every experimental function is labelled as such in its
  help page, in the README’s API stability list, and in each article
  that uses it. A test derives these claims from the source so they
  cannot drift.

- [`shad_checkbox()`](https://orijitghosh.github.io/shadshiny/reference/shad_checkbox.md)
  gains `tristate = TRUE`, letting clicks cycle unchecked, checked, and
  indeterminate. The default keeps the shadcn/ui behavior, where only
  the server can set the indeterminate state again.

- Inputs can now return to their empty state. Clearing a
  [`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md)
  or single
  [`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md)
  restores its placeholder instead of the label it was created with;
  picking the selected item of a single combobox, or the selected day of
  a single-mode calendar or date picker, clears it as in shadcn/ui; and
  a non-numeric
  [`update_shad_number_input()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_number_input.md)
  value is ignored instead of showing `NaN`.

- [`update_shad_select()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)
  and
  [`update_shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)
  only select real choices. A numeric `selected` now matches its choice
  (it used to show the placeholder while reporting the number), a value
  that is not a choice is ignored with a browser console warning instead
  of being reported as the input’s value, and multiple mode drops
  unknown and duplicate entries.

- A multiple
  [`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md)
  can be used from the keyboard alone. Each chip’s remove control is now
  a real button placed before the trigger rather than inside it, so Tab
  reaches it and Enter, Space, Delete or Backspace removes the value;
  the combobox root now draws the input box. Tab in the open search
  closes the list and moves on from the trigger instead of losing focus,
  and Shift+Tab returns to the trigger.

- [`shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/shad_calendar.md)
  and
  [`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md)
  handle dates more strictly and keep focus. An impossible date such as
  `"2026-02-31"` no longer rolls into the next month;
  [`update_shad_calendar()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)
  and
  [`update_shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md)
  ignore a date outside `min` / `max` with a browser console warning and
  put a reversed range in order; and a server value no longer closes the
  date picker or moves focus to its trigger. Arrow keys move whole days
  across daylight-saving changes, PageUp and PageDown stop at the end of
  a shorter month, and the month buttons and selects keep focus.
  `disabled = TRUE` calendars now disable every control, and date-range
  presets are cut to `min` / `max` (a preset wholly outside them is
  disabled).

- [`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md)
  and
  [`shad_command_palette()`](https://orijitghosh.github.io/shadshiny/reference/shad_command_palette.md)
  are easier to use from the keyboard. The search input is now the only
  tab stop (every item used to be one too), an open palette keeps Tab on
  its search instead of wrapping onto an item, and clicking an item
  keeps focus in the search. Items swapped in by
  [`update_shad_command()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_command.md)
  are proper options, and their empty text now shows when nothing
  matches. The `hotkey` needs exactly the modifiers it names, so
  `"mod+k"` no longer fires on Ctrl+Shift+K, `"mod+shift+p"` leaves
  Ctrl+P (Print) alone, and `"ctrl+k"` no longer fires on a plain K. A
  hotkey without Ctrl, ⌘ or Alt, such as `"/"`, is left to text fields,
  and an IME composition keeps Enter and the arrows. Focus traps
  (dialogs, sheets, popovers) now skip elements with a negative
  `tabindex`, as Tab does.

- [`shad_data_table_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table_server.md)
  gains `max_page_size = 1000` and checks every request before `source`
  runs. A request for a larger page, a page whose offset would overflow
  an R integer, a sort or filter value that is not a single string, or a
  column sorted twice is refused with a server warning and the table’s
  error state, instead of reaching `source` (a crafted request could ask
  for the whole dataset). With `columns`, a sort or filter on a column
  declared `sortable = FALSE` or `filterable = FALSE` is refused too,
  and undeclared columns in a page still show but no longer offer
  sorting or filtering the server would refuse.

- [`update_shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_data_table.md)
  on a server-backed table now asks the server for the new `page` or
  `page_size` instead of relabelling the rows already shown. A page size
  the table does not offer, or several `selected` keys for a
  single-selection table, is ignored with a browser console warning, and
  `page` and `page_size` must be positive whole numbers.
  [`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md)
  adds its `page_size` to `page_sizes` when it is missing, so the select
  shows the size in use, and refuses a `page_size` of 0, which hung the
  browser. Filtering and sorting read HTML cells through an inert
  template, so they no longer load images or run handlers for rows that
  are not on the page.

- [`shad_data_table_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table_server.md)
  now serves a table that
  [`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html) draws
  after the server function has run, or draws again: the table switches
  to server mode when its value first reaches the server, instead of the
  helper sending the switch at startup, which such a table never
  received. It also ignores a request older than the last one answered,
  as documented; it used to pass stale requests to `source`.

- Removing UI with a popup or dialog open no longer leaves it behind. A
  command palette dialog that was open when
  [`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html) replaced
  its output stayed on the page with its hotkey live, its scroll lock
  held and its input still bound, and a second one appeared when the
  output came back. A menu closed in the frame it opened (Escape pressed
  at once) keeps focus on its trigger instead of moving it into the
  closing menu.

- A label given to
  [`shad_select()`](https://orijitghosh.github.io/shadshiny/reference/shad_select.md),
  [`shad_combobox()`](https://orijitghosh.github.io/shadshiny/reference/shad_combobox.md),
  [`shad_date_picker()`](https://orijitghosh.github.io/shadshiny/reference/shad_date_picker.md),
  [`shad_radio_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_radio_group.md),
  [`shad_rating()`](https://orijitghosh.github.io/shadshiny/reference/shad_rating.md),
  [`shad_slider()`](https://orijitghosh.github.io/shadshiny/reference/shad_slider.md)
  or
  [`shad_input_otp()`](https://orijitghosh.github.io/shadshiny/reference/shad_input_otp.md)
  now names the part that takes focus, and the description and error
  describe it; before, the label pointed at a wrapper that cannot be
  labelled, so screen readers announced the control without its label.
  The select trigger is now a combobox, which makes its open state valid
  ARIA; with no label, its placeholder names it.

- Development hardening now runs every fixture-gated browser suite in
  CI, enforces an 82% repository coverage floor plus 80% patch coverage,
  tests the declared R 4.1 minimum explicitly, and selects local
  `Rscript` from `PATH` unless `SHADSHINY_RSCRIPT` is set. The
  behavioral fixture now demonstrates the package’s spacing primitives
  instead of relying on incidental flow layout.

- Plan 7 adds the keyboard shortcut group, escaped code-block, CSS-only
  scroll fade, and readable shimmer text utilities. Code copy uses a
  native button, exact code text, repeatable polite status
  announcements, and safe delegated handling; scroll fades use masks
  only and shimmer text respects reduced-motion and forced-colors
  preferences.

- Experimental structured AI workbench modules
  [`shad_chat_workbench_ui()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_workbench_ui.md)
  and
  [`shad_chat_workbench_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_workbench_server.md)
  accept provider-owned public events for text, sources, tools,
  attachments, status, replacement, and completion. They keep the
  existing streaming chat API unchanged, escape untrusted content,
  retain response versions for retry, and never expose upload server
  paths or private reasoning.

- Experimental
  [`bind_shad_task_button()`](https://orijitghosh.github.io/shadshiny/reference/bind_shad_task_button.md)
  observes an application-owned
  [`shiny::ExtendedTask`](https://rdrr.io/pkg/shiny/man/ExtendedTask.html)
  and maps its initial, running, success, and error states to the
  existing button updater. It does not create tasks, invoke results,
  start workers, or add an asynchronous backend dependency.

- The experimental field composition family adds
  [`shad_fieldset()`](https://orijitghosh.github.io/shadshiny/reference/shad_fieldset.md),
  [`shad_field_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_field_group.md),
  and
  [`shad_field_separator()`](https://orijitghosh.github.io/shadshiny/reference/shad_field_separator.md)
  as additive native-semantic primitives. Responsive groups use
  framework-free container-query CSS with logical properties for RTL; no
  JavaScript or new dependency is required. Existing
  [`shad_form_field()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_field.md)
  and validator contracts are unchanged.

- The release-boundary work adds derived contract gates for the 253
  exported functions and 71 important signatures, including all server
  update helpers, without adding a generated inventory. The approved
  additive API is
  [`shad_data_table_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table_server.md).

- Browser coverage now exercises representative overlay, navigation,
  input, server-update, dynamic-UI, and runtime-theme behavior. The
  focused repairs include `ArrowUp` opening a dropdown on its last
  enabled item and making the number-stepper disabled state
  authoritative in both the browser and server updater paths. The four
  maintained visual baselines remain unchanged.

- Development-only JavaScript gates now protect deterministic bundles,
  compressed CSS/JavaScript transfer budgets, and representative
  initialization and teardown timings. Node remains unnecessary for
  package installation and use.

- The experimental
  [`shad_data_table_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table_server.md)
  adds lazy server-backed paging, validated page/sort/filter requests,
  stable row-key selection, stale-response rejection, fixed safe browser
  errors with retry, and the same R cell serialization as the
  client-side table. Database adapters, editing, grouping, pivoting,
  aggregation, downloads, and spreadsheet behavior remain out of scope.

- The experimental
  [`shad_questionnaire()`](https://orijitghosh.github.io/shadshiny/reference/shad_questionnaire.md)
  workflow adds serializable question definitions, native semantic
  fieldsets, required/multiple/text answers, explicit skips, named
  equality branching, bookmark restoration, module-safe server patches,
  and deterministic reset/error handling. The input value is
  `{active, answers, skipped, complete}`; arbitrary condition code,
  persistence, and application-specific submission remain out of scope.

- Chat failure finalization, trusted raw-icon handling, bookmarking, and
  component lifecycle behavior now have focused regression coverage.
  External registry-theme schemas, optional third-party chart
  integrations and live integrations with external chat stream providers
  remain explicitly outside the stable core boundary.

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
