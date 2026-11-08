<!-- FILE: inst/assets/components/button-group/README.md -->
# button-group (Tier 1, CSS-only)

## Anatomy
```
div.shad-button-group[role=group][data-orientation=horizontal|vertical][aria-label]
├─ button|a.shad-btn                              (any button variant/size)
├─ span.shad-button-group__text                   (non-interactive label segment)
├─ div.shad-button-group__separator[role=separator]
└─ …                                              (buttons in DOM order = paint order)
```

## Modifier / state
- Orientation: `data-orientation="horizontal"` (default) | `"vertical"`.
- Inner radii collapse automatically; only the first/last child keep outer corners.
- Adjoining children overlap by `-1px` so the shared border renders once; the
  hovered/focused/open child raises via `z-index` so its full border shows.

## Data-attribute API
`data-orientation` on the root only. All segmentation is class/selector driven –
drop in ordinary `.shad-btn` buttons and they adopt the joined look.

## Methods / Events
None – layout only. R wrapper: `shad_button_group(..., orientation = c("horizontal", "vertical"), aria_label = NULL)` + `shad_button_group_separator()` + `shad_button_group_text(...)`.

## Keyboard
Native – each button is its own tab stop. For a single-select segmented control,
give the buttons `role="radio"` inside `role="radiogroup"` yourself and manage
`aria-checked` (out of scope for the CSS layer).

## A11y
- Root carries `role="group"` and an `aria-label` describing the set.
- `__separator` is decorative: `role="separator"` with no label.
- `__text` is a `<span>`, never focusable.
