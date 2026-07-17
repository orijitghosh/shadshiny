<!-- FILE: inst/assets/components/form-field/README.md -->
# form-field (Tier 2)

## Anatomy
```
div.shad-form-field[data-shad=form-field][data-invalid?]
├─ label.shad-label                        (auto for/id wired)
├─ <control>                               (.shad-input/.shad-textarea/any [data-shad])
├─ p.shad-form-field__description          (optional; joins aria-describedby)
└─ p.shad-form-field__error[hidden]        (visible ⇒ invalid state)
```

## Data-attribute API
`data-invalid` (set by JS when error shown) — colors label; control gets `aria-invalid="true"`.

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` / `setValue(v)` | proxy to inner shad instance or native control |
| `setError(msg\|null)` | show/hide error, wire aria-describedby + aria-invalid |
| `destroy()` | no-op (no listeners) |
| `shad:change` | bubbles up from inner control |

## A11y
Description and visible error are both in the control's `aria-describedby`; error text should be concise and specific.

## R-wrapper hints
`shad_form_field(inputId, label, control, description)`, `update_shad_form_field(error = ...)`.
