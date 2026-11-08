<!-- FILE: inst/assets/components/checkbox/README.md -->
# checkbox (Tier 2)

## Anatomy
```
button.shad-checkbox[data-shad=checkbox][role=checkbox][data-state]
├─ svg.shad-checkbox__indicator--check   (pathLength=1 for draw anim)
└─ svg.shad-checkbox__indicator--minus   (indeterminate)
```
Pair with `label.shad-label` inside `div.shad-checkbox-row`.

## Data-attribute API
| Attribute | Values |
|---|---|
| `data-state` | `checked` / `unchecked` / `indeterminate` (initial + live) |
| `data-disabled` + `disabled` | disabled |
| `data-tristate` | clicks cycle unchecked → checked → indeterminate (shadshiny addition) |
| `aria-invalid="true"` | destructive border |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | `true` / `false` / `"indeterminate"` |
| `setValue(v)` | same domain; emits on change |
| `destroy()` | unbind |
| `shad:change` | `{value}` |

## Keyboard
Space toggles (native button click). Enter is suppressed per APG. Indeterminate → click ⇒ checked,
unless `data-tristate` is set.

## A11y
`role="checkbox"`, `aria-checked` (`mixed` for indeterminate), label via `aria-labelledby`.
