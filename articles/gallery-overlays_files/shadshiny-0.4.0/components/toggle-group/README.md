<!-- FILE: inst/assets/components/toggle-group/README.md -->
# toggle-group (Tier 2)

## Anatomy
```
div.shad-toggle-group[.shad-toggle-group--outline][data-shad=toggle-group][data-type][role=group]
└─ button.shad-toggle[data-value][data-state=on|off] × n
```
Do NOT put `data-shad="toggle"` on items – the group owns them.

## Data-attribute API
| Attribute | On | Values |
|---|---|---|
| `data-type` | group | `single` / `multiple` |
| `data-orientation` | group | `horizontal` (default) / `vertical` |
| `data-value` / `data-state` | item | value / `on|off` |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | single: string\|null · multiple: string[] |
| `setValue(v)` | same shape; emits on change |
| `destroy()` | unbind |
| `shad:change` | `{value}` |

## Keyboard
Arrows move focus (roving), Space/Enter toggles focused item, Home/End.

## A11y
Group `role="group"` + `aria-label`; items use `aria-pressed`. Single-select mode intentionally allows deselect (Radix parity).
