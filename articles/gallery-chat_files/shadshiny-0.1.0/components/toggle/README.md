<!-- FILE: inst/assets/components/toggle/README.md -->
# toggle (Tier 2)

## Anatomy
`button.shad-toggle[.shad-toggle--outline][.shad-toggle--sm|--lg][data-shad=toggle][data-state=on|off]`

## Data-attribute API
`data-state="on|off"` · `data-disabled`/`disabled`.

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | boolean (pressed) |
| `setValue(v)` | boolean; emits on change |
| `destroy()` | unbind |
| `shad:change` | `{value: boolean}` |

## Keyboard
Space/Enter toggle (native button).

## A11y
`aria-pressed` mirrors state; icon-only needs `aria-label`.
