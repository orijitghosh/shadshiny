<!-- FILE: inst/assets/components/form-field/README.md -->
# form-field (Tier 2)

## Anatomy
```
div.shad-form-field[data-shad=form-field][data-invalid?]
├─ label.shad-label                        (names the part that takes focus; see A11y)
├─ <control>                               (.shad-input/.shad-textarea/any [data-shad])
├─ p.shad-form-field__description          (optional; joins aria-describedby)
└─ p.shad-form-field__error[hidden]        (visible ⇒ invalid state)
```

## Data-attribute API
`data-invalid` (set by JS when error shown) — colors label; the control and the part that takes focus get `aria-invalid="true"`.

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` / `setValue(v)` | proxy to inner shad instance or native control |
| `setError(msg\|null)` | show/hide error, wire aria-describedby + aria-invalid |
| `destroy()` | no-op (no listeners) |
| `shad:change` | bubbles up from inner control |

## A11y
A component root is a `<div>`, which `<label for>` cannot name, so the label goes to
the part that takes focus:

| Control | Named by |
|---|---|
| native input, textarea, select, button | `<label for>` |
| root with its own role (radio group, rating) | `aria-labelledby` = label |
| first input (OTP, number) | `aria-labelledby` = label |
| select trigger (`role=combobox`) | `aria-labelledby` = label; its text is the value |
| other trigger buttons (combobox, date picker) | `aria-labelledby` = label, then the button's own text |
| range slider thumbs | `aria-labelledby` = label, then each thumb's own name |

Description and visible error are both in that part's `aria-describedby`; error text
should be concise and specific. Contract: `tests/js/field-label.test.js`.
`update_shad_form_field()` takes a separate path and still marks the component root.

## R-wrapper hints
`shad_form_field(inputId, label, control, description)`, `update_shad_form_field(error = ...)`.
