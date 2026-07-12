# shadshiny (development version)

* **New components (chat / AI kit):** `shad_bubble()` (+ group), `shad_message()`
  (+ group, `shad_message_spinner()`), `shad_attachment()` (+ group,
  `shad_attachment_action()`), `shad_marker()`, and `shad_message_scroller()`
  (+ item, and the `shad_message_scroller_to_bottom()` server helper) — a
  stick-to-bottom streaming transcript.
* **New components (layout & inputs):** `shad_native_select()` (a styled real
  `<select>` with `update_shad_native_select()`), `shad_empty()` (empty-state
  panel), `shad_item()` (+ group, separator) — the flex list-row primitive,
  `shad_button_group()` (+ text, separator) — segmented button controls, and
  `shad_input_group()` (+ addon, text, button) — a field shell for
  icon/prefix/button affixes around `shad_input()` / `shad_textarea()`.
* **New icons:** `file`, `folder`, `clock`.

# shadshiny 0.1.0

Initial release.

* A framework-free port of the [shadcn/ui](https://ui.shadcn.com) design system
  for Shiny: 49 components across three tiers, shipped as a single bundled
  `htmlDependency()` (no npm, no React, no build step).
* **Tier 1 — display & typography:** button, badge, avatar (+ group), card
  (+ parts), alert, separator, skeleton, spinner, aspect-ratio, label,
  progress, breadcrumb, table (+ parts), kbd, code, and the `shad_h1()`–
  `shad_p()` typography set.
* **Tier 2 — form inputs:** input, textarea, checkbox, switch, radio group,
  toggle, toggle group, slider, select, combobox, input-OTP, calendar,
  date-picker, and the `shad_form_field()` wrapper. All expose native Shiny
  input values via a generic `data-shad` binding.
* **Tier 3 — overlays:** dialog, alert-dialog, sheet, drawer, popover, tooltip,
  hover-card, dropdown-menu, context-menu, menubar, command palette, and toast.
* **Tier 3 — navigation & structure:** tabs, accordion, collapsible,
  pagination, scroll-area, resizable, carousel, navigation-menu, and the
  sidebar layout family.
* **Server API:** `update_shad_*()` helpers for every valued component,
  `shad_<overlay>_open()` / `_close()` controllers, and a `shad_toast()` family
  (success/error/warning/loading, plus `shad_toast_update()` for loading→done
  flows). All are Shiny-module safe.
* **Theming:** OKLCH `--shad-*` token system with seven presets
  (slate, stone, blue, green, rose, violet, orange), `page_shad(theme_preset=)`,
  and runtime `update_shad_theme()`. Dark mode synchronizes with
  `bslib::input_dark_mode()` out of the box.
* **Demo:** `shad_run_example("kitchen-sink")` exercises every component,
  variant, and server round-trip.
