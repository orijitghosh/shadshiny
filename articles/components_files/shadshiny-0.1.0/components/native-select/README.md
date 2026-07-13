<!-- FILE: inst/assets/components/native-select/README.md -->
# native-select (Tier 2, +JS)

## Anatomy
```
div.shad-native-select[data-shad=native-select][.shad-native-select--{size}]
├─ select.shad-native-select__select            (real <select>; option / optgroup)
└─ svg.shad-icon.shad-native-select__chevron    [aria-hidden=true]
```

## Modifier classes
- Sizes: `shad-native-select--sm | (none = default) | shad-native-select--lg`

## Data-attribute API
| Attribute | Effect |
|---|---|
| `data-invalid` (root) | destructive border + focus ring; auto-mirrored from `aria-invalid="true"` on the `<select>` at init |
| `disabled` (select) | dims select + chevron, `cursor: not-allowed` |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | `select.value` (string) |
| `setValue(v)` | sets `select.value`; emits on change |
| `destroy()` | unbind |
| `shad:change` | `{value: string}` — fired on native `change` and API mutation |

R wrapper: `shad_native_select(inputId, choices, selected = NULL, size = NULL, disabled = FALSE, invalid = FALSE, width = NULL)` — `choices` may be a named list of named lists for `<optgroup>`.

## Keyboard
Fully native: Space/Enter open the picker, arrows move, typeahead matches — nothing is intercepted.

## A11y
- Real `<select>` — native semantics, mobile pickers, form participation all intact.
- Chevron is decorative (`aria-hidden="true"`, `pointer-events: none`).
- Invalid fields should set `aria-invalid="true"` on the `<select>` (root `data-invalid` follows).
- Label via `<label for>` or `aria-label` on the `<select>`.
