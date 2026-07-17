<!-- FILE: inst/assets/components/button/README.md -->
# button (Tier 1, CSS-only)

## Anatomy
```
button.shad-btn.shad-btn--{variant}[.shad-btn--{size}]
├─ span.shad-btn__spinner > svg.shad-icon   (only if loading supported)
├─ svg.shad-icon                            (optional leading/trailing icon)
└─ text
```

## Modifier classes
- Variants: `shad-btn--default | --secondary | --destructive | --outline | --ghost | --link`
- Sizes: `shad-btn--sm | (none = default) | --lg | --icon` (`--icon` combines with `--sm`/`--lg`)

## Data-attribute API
| Attribute | Effect |
|---|---|
| `data-loading` | shows spinner, disables pointer events, dims |
| `data-disabled` / `disabled` / `aria-disabled="true"` | disabled styling |

## Methods / Events
None — native `<button>`; `click` is the event surface. R wrapper: `shad_button(inputId, label, variant, size, icon, loading, disabled)` maps to Shiny's actionButton binding via class `action-button` if desired.

## Keyboard
Native button semantics (Enter/Space).

## A11y
- Icon-only buttons require `aria-label`.
- Loading buttons should also set `disabled` and may set `aria-busy="true"`.
