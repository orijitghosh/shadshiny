# shadshiny (development version)

* **Bug fix (icons):** `shad_icon()` now carries the shadshiny asset dependency,
  so a standalone icon still loads its `.shad-icon` sizing CSS when it is the
  only shadshiny output on a page (previously such icons rendered size-less /
  invisible — e.g. the icon previews in the pkgdown *Icons* article). Nested in
  a component, the duplicate dependency is de-duplicated as before.
* **Bug fix (component init):** `shad.autoInit()` no longer throws when the
  asset bundle loads in `<head>` before `document.body` exists. Previously the
  `MutationObserver` attached to a null body, which aborted initialisation and
  left dynamically inserted components (`renderUI`, `insertUI`, dynamic tabs)
  un-wired. Components now initialise immediately and the observer attaches on
  DOM ready.
* **Bug fix (input group):** the wrapped control's `width: 100%` no longer
  forces leading/trailing addons onto their own rows — the control now flexes
  from a zero basis so icons, prefixes and buttons sit inline as intended.
* **More icons:** the built-in set grows from 32 to 78, adding common glyphs —
  `home`, `user`, `users`, `settings`, `bell`, `trash`, `pencil`, `download`,
  `upload`, `external-link`, `eye`, `eye-off`, `lock`, `unlock`, `heart`,
  `star`, `bookmark`, `filter`, `refresh-cw`, `log-in`, `log-out`, `copy`,
  `clipboard`, `save`, `sun`, `moon`, `image`, `link`, `phone`, `map-pin`,
  `credit-card`, `shopping-cart`, `package`, `bar-chart`, `activity`, `zap`,
  `message-circle`, `send`, `paperclip`, `thumbs-up`, `globe`, `github`,
  `circle-x`, `circle-plus`, `circle-help`, `arrow-up`, `arrow-down`, and
  `chevrons-down-up`.
* **Demo:** the `kitchen-sink` sidebar now switches its main pane per nav item,
  and its chat scroller starts at the top so the "Scroll chat" round-trip is
  visible.

* **Documentation site.** The pkgdown site is now a full handbook. A new
  **Component gallery** renders every component *live* — the real component
  next to the exact source that made it — across pages for display, inputs,
  overlays, navigation and the chat kit, plus a live **Icons** reference. The
  previews initialise client-side (dialogs, tabs and carousels work) and follow
  the site's light/dark switch. New prose guides cover **Installation & setup**,
  **Forms & validation**, **Layout & composition**, and **The server API**.

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
* **Bug fix:** `shad_context_menu()` now wraps its `target` in the
  `.shad-context-menu__zone` element the JS binds to, so the right-click zone
  initialises instead of erroring on load.
* **Demo:** the `kitchen-sink` example now exercises the full variant / size /
  state matrix for every component.
* **Example apps:** six new real-world example apps under `inst/examples`,
  launchable with `shad_run_example()`, that together exercise the whole
  component library: `01-auth-onboarding`, `02-analytics-dashboard`,
  `03-support-chat`, `04-storefront`, `05-settings-profile`, and
  `06-docs-reader`.
* **Bug fix:** `shad_toast_update()` called from a deferred (`later::later`)
  callback now requires the `session` to be passed explicitly; the bundled demos
  do so, fixing an "attempt to apply non-function" crash on toast loading→update
  outside the reactive domain.

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
