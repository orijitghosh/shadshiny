<!-- FILE: inst/assets/components/form-message/README.md -->
# form-message (Tier 1, V2 – CSS-only)

Validation messaging beyond form-field's error slot: field-level success / warning / info lines with icons, a character counter, and a form-level error summary. Load after `form-field.css` (composes its field grid).

## Anatomy
```
div.shad-form-field[data-invalid?]
├─ label.shad-label / input.shad-input[aria-invalid?][aria-describedby → message id]
└─ div.shad-form-message[--error|--success|--warning|--counter]
   ├─ svg (1rem, optional)
   └─ text

div.shad-form-summary[role=alert]
├─ div.shad-form-summary__title > svg + text
└─ ul.shad-form-summary__list > li > a[href=#field-id]
```

## Variants
| Class / attr | Effect |
|---|---|
| (base) | muted info/help line |
| `--error` | destructive (same tone as form-field__error) |
| `--success` | green (literal green-600/500 – no success token; matches value-box) |
| `--warning` | amber (literal amber-700/500) |
| `--counter` | right-aligned tabular counter; `data-state="over"` flips destructive |

## A11y
Point the control's `aria-describedby` at the message id; add `aria-invalid="true"` + `data-invalid` on the field for errors (input-group/input pick up the destructive ring from V1 CSS). The summary is `role=alert` with anchor links to the offending fields – place it before the form and move focus to it on failed submit. Icons are decorative (`aria-hidden`).

## Deviations
- Green/amber literals (documented, same rationale as value-box delta): shadshiny defines no success/warning tokens; values are Tailwind green-600/149.579-hue and amber-700/70.08-hue OKLCH with dark-mode lightening.
