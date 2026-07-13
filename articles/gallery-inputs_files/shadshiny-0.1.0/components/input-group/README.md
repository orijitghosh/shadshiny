<!-- FILE: inst/assets/components/input-group/README.md -->
# input-group (Tier 2, CSS-only)

## Anatomy
```
div.shad-input-group[.shad-input-group--block][role=group][data-invalid]
├─ span.shad-input-group__addon[data-align=inline-start]
│  └─ svg.shad-icon | span.shad-input-group__text | button.shad-input-group__button
├─ input.shad-input | textarea.shad-textarea       (chrome-shedding control)
├─ span.shad-input-group__addon[data-align=inline-end]
└─ span.shad-input-group__addon[data-align=block-start|block-end]   (full-row toolbar)
```

## Modifier / state
- `--block` stretches the shell to `width:100%` (default is `fit-content`).
- `data-invalid` on the root paints the destructive border + focus ring.
- The shell owns border/shadow/focus; the wrapped `.shad-input` / `.shad-textarea`
  drop their own via `:focus-within` on the group.

## Data-attribute API
- `data-align` on each addon: `inline-start` | `inline-end` | `block-start` | `block-end`.
  Block addons occupy their own row (order-controlled) for toolbar strips.

## Methods / Events
None — layout only. The wrapped control keeps its native Shiny binding
(`shad_input()` / `shad_textarea()`). R wrapper: `shad_input_group(..., block = FALSE, invalid = FALSE)` + `shad_input_group_addon(..., align = c("inline-start", "inline-end", "block-start", "block-end"))` + `shad_input_group_text(...)` + `shad_input_group_button(...)`.

## Keyboard
Native — focus flows to the wrapped control and any addon buttons in DOM order.

## A11y
- Root carries `role="group"`; label it via `aria-label` or an associated `shad_label()`.
- Mirror the control's `aria-invalid` onto the root `data-invalid` so the shell
  reflects the error state.
- Decorative addon icons stay `aria-hidden="true"`.
