<!-- FILE: inst/assets/components/input-otp/README.md -->
# input-otp (Tier 2)

## Anatomy
```
div.shad-otp[data-shad=input-otp][data-length][data-pattern?][data-disabled?]
├─ input.shad-otp__input        (REAL input, opacity 0, overlays control)
├─ div.shad-otp__group > div.shad-otp__cell × n
└─ div.shad-otp__separator      (optional, between groups)
```
Total cell count MUST equal `data-length`.

## Design decision
One real hidden input over the control (input-otp library approach) instead of n inputs: paste, auto-advance, backspace, IME and autofill (`autocomplete="one-time-code"`) all work natively; cells are a pure render of value + caret (blinking fake caret in the active cell).

## Data-attribute API
| Attribute | Effect |
|---|---|
| `data-length` | code length |
| `data-pattern` | per-char regex (e.g. `\d` digits only) |
| `data-active` | (cell, JS-set) ring highlight |
| `data-disabled` / `aria-invalid` | dim / destructive borders |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | current string |
| `setValue(v)` | sanitized to pattern+length; emits |
| `destroy()` | unbind |
| `shad:change` | `{value, complete}` — `complete` true at full length |

## Keyboard
Native single-input editing: type to advance, Backspace deletes, paste splits, Cmd/Ctrl-V anywhere in control.
