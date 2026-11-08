<!-- FILE: inst/assets/components/progress/README.md -->
# progress (Tier 1, CSS-only)

## Anatomy
```
div.shad-progress[role=progressbar][aria-valuenow][data-state]
└─ div.shad-progress__indicator   (style="transform: translateX(-(100-value)%)")
```

## Data-attribute API
| Attribute | Values |
|---|---|
| `data-state` | `loading` / `complete` / `indeterminate` |

Indeterminate ignores the transform and runs the sweep animation.

## Methods / Events
None (server updates re-render the transform + aria-valuenow). R wrapper: `shad_progress(value = NULL)` – `NULL` ⇒ indeterminate. `update_shad_progress()` patches style + aria via Shiny message.

## A11y
`role="progressbar"` + `aria-valuemin/max/now`; `aria-label` when indeterminate.
