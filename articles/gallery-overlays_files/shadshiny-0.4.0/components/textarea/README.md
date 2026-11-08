<!-- FILE: inst/assets/components/textarea/README.md -->
# textarea (Tier 2)

## Anatomy
`textarea.shad-textarea[data-shad="textarea"][data-autosize]` – `data-shad` only needed for autosize/JS API.

## Data-attribute API
| Attribute | Effect |
|---|---|
| `data-autosize` | grows with content (`field-sizing: content` native, JS fallback) |
| `aria-invalid="true"` | destructive border/ring |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | current string |
| `setValue(v)` | sets value, resizes, emits |
| `destroy()` | unbind |
| `shad:change` | `{value}` on input/setValue |

## Keyboard
Native.
