<!-- FILE: inst/assets/MANIFEST.md -->
# shadshiny — asset manifest

All paths relative to `inst/assets/`. Every file is complete and self-parsable; component dirs follow `<name>/<name>.css|.js|.html` + `README.md` (JS omitted for CSS-only components).

## tokens/
- `shad-tokens.css` — all `--shad-*` custom properties: OKLCH color tokens (light + dark via `.dark` AND `[data-bs-theme="dark"]`), radius/type/spacing/shadow/motion/focus tokens, 12 theme presets (`slate`/`stone`/`zinc`/`mauve`/`olive`/`mist`/`taupe` full neutral ramps; `blue`/`green`/`rose`/`violet`/`orange` accent overrides) via `[data-shad-theme]`.

## core/
- `shad-base.css` — `:where()`-scoped reset-lite (shad-classed elements only), icon sizing, `.shad-scope` canvas, `.shad-focusable` ring recipe, `.shad-sr-only`, typography utilities (`.shad-h1…h4/p/lead/large/small/muted/blockquote/code/kbd/list`).
- `shad-animations.css` — every keyframe (fade/zoom/dialog/pop/slide/collapse/spin/skeleton/progress/caret/check-draw) + motion utility classes (`shad-anim-overlay/dialog/pop/sheet`) keyed to `data-state`/`data-side`/`data-align`; `prefers-reduced-motion` kill-switch.
- `shad-runtime.js` — `window.shad`: FloatingEngine (flip/shift/offset/arrow, shared rAF-batched scroll/resize), DismissLayer (stack; Esc/outside topmost-only), FocusTrap, RovingTabindex (+1 s typeahead), Presence (animated unmount), ScrollLock (ref-counted, scrollbar-compensated), Portal (comment-marker restore), `uid/util`, registry (`register/init/get/destroy/autoInit`, plus the init-time `data-shad-open` / `data-shad-transient` attributes behind `shad_show_dialog()`). Load FIRST.

## components/

The authoritative CSS and JavaScript input lists are recorded in
`dist/manifest.json`; this document intentionally does not duplicate their
counts.
Tier 1 (CSS-only: css + html + README): `button` (6 variants × 4 sizes, loading), `badge` (4 variants), `card`, `alert` (default/destructive), `separator`, `skeleton`, `avatar` (sizes, group), `label`, `breadcrumb` (ellipsis), `table` (striped/hover/sticky), `typography` (thin pointer to base classes), `progress` (determinate/indeterminate), `aspect-ratio`, `spinner`, `item` (list-row: media/content/actions/header/footer, group + separator), `empty` (empty-state: media/title/description/content), `button-group` (segmented, horizontal/vertical, text + separator).

Tier 2 (+ js): `input`, `textarea` (autosize), `checkbox` (indeterminate, check draw), `radio-group`, `switch`, `slider` (single/range/marks), `toggle`, `toggle-group` (single/multiple), `select` (listbox, typeahead, groups), `native-select` (styled real `<select>`, groups, sizes), `combobox` (single/multi + badges), `input-otp` (single hidden input), `form-field` (aria wiring), `calendar` (APG grid, range), `date-picker`, `input-group` (CSS-only field shell: inline/block addons, focus/invalid ring; wraps input/textarea).

Chat / AI kit (CSS-only except message-scroller js): `bubble` (7 variants, align, reactions, group), `message` (avatar/sender/meta/footer, typing/in-progress/failed states, spinner, group), `attachment` (media/actions, upload/processing/error/done states, orientation, group + action), `marker` (default/border/separator, streaming shimmer), `message-scroller` (+ js: stick-to-bottom viewport, jump-to-latest, `scrollToBottom()` invokable; emits no `shad:change`).

Tier 3 (+ js): `dialog`, `alert-dialog`, `sheet` (4 sides), `drawer` (drag-dismiss), `tooltip` (delay group), `popover`, `hover-card`, `dropdown-menu` (submenus, check/radio items), `context-menu`, `menubar`, `navigation-menu` (animated viewport), `command` (inline + mod+K dialog; `data-dialog` forces dialog mode without a hotkey, `[data-shad-command-open]` on any element opens a palette), `toast` (imperative sonner-style), `tabs` (animated indicator), `accordion`, `collapsible`, `pagination`, `scroll-area`, `resizable`, `sidebar` (icon rail + mobile sheet), `carousel` (scroll-snap).


Dashboard (CSS-only): `mini-chart` — `sparkline` (line/area/bar/step; 0..100 viewBox stretched with `preserveAspectRatio="none"`, `vector-effect="non-scaling-stroke"`) and `donut` (segments as dashes on one circle, `-90deg` rotation, optional centre slot). Marks are painted `var(--shad-chart-N)`, so presets and dark mode restyle them with no re-render.

Layout (CSS-only): `layout` — `container` / `stack` / `grid` primitives (+ `grid__item` span) and the `.shad-page*` chrome behind `shad_page_sidebar()` / `shad_page_navbar()`. Every knob is a custom property set inline by the R constructor; breakpoints sm 40rem / md 48rem / lg 64rem with an outward `var()` fallback chain.

## dist/
Built by `npm run build:assets` (`tools/build-assets.mjs`) and committed, so installing the R package never needs Node.
- `shadshiny.min.css` — every stylesheet above concatenated in load order and minified.
- `shadshiny.min.js` — runtime, component JS and the Shiny binding, same order, minified.
- `manifest.json` — the source list that went into each, in order. `tests/testthat/test-deps.R` compares it against `shad_asset_css_order()` / `shad_asset_js_order()` so the two orderings cannot drift.

Edit the per-component sources, never `dist/`. `shadshiny_dependency()` serves the bundle when present; `options(shadshiny.assets = "source")` forces the split files.

## demo/
- `kitchen-sink.html` — every component/variant, sticky toolbar with dark toggle (flips `.dark` + `data-bs-theme` on `<html>`) and theme-preset select (`data-shad-theme` on the page root); loads every input listed in `dist/manifest.json` in dependency order; `shad.autoInit()`.

## Deviations & decisions
0. **Scrolling and focus are never page-level side effects.** No component
   calls `scrollIntoView()` — it walks *every* scrollable ancestor, so a
   component in ordinary document flow drags the whole page to itself (this is
   what opened the kitchen sink at "Tier 3"). Use `shad.util.keepInView(container,
   item)`, which scrolls that one container. Pointer-driven `focus()` passes
   `{preventScroll: true}`: the user can already see what they clicked.
   Keyboard roving focus (tree, rating, focus-trap Tab wrap) deliberately does
   NOT, because the user needs to see where focus landed.
1. **No `@layer`.** Bootstrap/bslib ships unlayered CSS and unlayered beats layered regardless of specificity; all shad rules are unlayered and class-scoped instead.
2. **alert-dialog factory lives in `dialog/dialog.js`** (registers both `dialog` and `alert-dialog`; sets `window.__shadDialogLoaded`). The alert-dialog dir's css/js are documented thin shims — load dialog's files alongside.
3. **`context-menu` and `menubar` reuse `.shad-menu*` CSS and `shad.__menuCore`** from dropdown-menu — load `dropdown-menu.css`/`.js` first.
4. **typography** is utility classes in `core/shad-base.css`; the component dir carries the demo/README (+stub css).
5. **toast is imperative** (`shad.toast()` API, lazily created container) — no `data-shad` markup, no `shad:change`.
6. **pagination window model**: first, last, current ±1, ellipsis in gaps.
7. **tooltip/hover-card emit no `shad:change`** (no value); `shad:open`/`shad:close` only.
8. **command filter is substring** (text + `data-keywords`), not fuzzy — predictable, fast.
9. **sidebar hotkey** ⌘/Ctrl+B; mobile breakpoint 768 px.
10. **input-otp**: ONE real hidden input overlaying rendered cells (paste/IME/autofill native) instead of n inputs.
11. **avatar fallback**: layered under the image + `onerror` hide — Radix-equivalent visual with zero JS.
12. **Drag physics**: drawer dismiss at >0.5 px/ms down or >50 % travel; toast swipe at >80 px or >0.3 px/ms.
13. **Events fire on user/API mutation only**; resizable fires on drag release (not per move). All stateful roots: `shad:change {value}`; overlays add `shad:open`/`shad:close`; instances expose `getValue/setValue/destroy` (+`open/close/isOpen`).
