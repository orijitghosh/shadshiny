<!-- FILE: inst/assets/components/switch/README.md -->
# switch (Tier 2)

## Anatomy
```
button.shad-switch[data-shad=switch][role=switch][data-state]
└─ span.shad-switch__thumb
```

## Data-attribute API
`data-state="checked|unchecked"` (initial + live) · `data-disabled`/`disabled`.

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | boolean |
| `setValue(v)` | boolean; emits on change |
| `destroy()` | unbind |
| `shad:change` | `{value: boolean}` |

## Keyboard
Space and Enter toggle (APG switch).

## A11y
`role="switch"` + `aria-checked`; label via `for`/`id` or `aria-labelledby`.
