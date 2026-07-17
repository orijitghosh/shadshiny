<!-- FILE: inst/assets/components/number-stepper/README.md -->
# number-stepper (Tier 2, V2)

Numeric input with −/+ buttons. **Composes input-group** (load `input/input.css` + `input-group/input-group.css` first): the root carries BOTH classes (`shad-input-group shad-number-stepper`) so the group owns the chrome (border, focus-within ring, invalid state via `data-invalid`).

## Anatomy
```
div.shad-input-group.shad-number-stepper[data-shad=number-stepper]
│    [data-min] [data-max] [data-step=1] [data-precision]
├─ input.shad-input[type=text][inputmode=decimal]     (JS adds role=spinbutton + aria-value*)
├─ button.shad-number-stepper__btn--dec[aria-label]   (order:-1 → renders first)
└─ button.shad-number-stepper__btn--inc[aria-label]
```

## Data-attribute API
| Attribute | On | Effect |
|---|---|---|
| `data-min` / `data-max` | root | clamp bounds (omit = unbounded); buttons disable at bounds |
| `data-step` | root | increment (default 1; decimals OK) |
| `data-precision` | root | display decimals (default: inferred from step) |

## Behavior
- Buttons: click ±step; **hold to repeat** (500 ms delay, 60 ms interval); disabled at bounds.
- Typing: free text; committed on Enter/blur (parsed, `,`→`.`; junk reverts to last value).
- FP drift killed via `toFixed` snap.

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | number |
| `setValue(v)` | clamp + emit |
| `destroy()` | unbind + stop repeat timers |
| `shad:change` | `{value}` |

## Keyboard
In the input: Up/Down ±step, Shift+Up/Down ±10×step, Home/End jump to min/max (when bounded), Enter commits typed text. Buttons are tabbable with Enter/Space.

## A11y
`role=spinbutton` with `aria-valuenow/min/max` on the input; buttons carry `aria-label`s; native spin arrows hidden (appearance) since the component provides its own. Invalid styling comes free from input-group (`data-invalid` on root).
