<!-- FILE: inst/assets/components/rating/README.md -->
# rating (Tier 2, V2)

Star rating radiogroup. JS builds the stars; half-star support via a left-clipped overlay star.

## Anatomy (JS-built)
```
div.shad-rating[data-shad=rating][role=radiogroup|img(readonly)]
│    [data-value] [data-max=5] [data-half] [data-readonly] [data-size=sm|lg]
│    [data-preview (transient, while hovering)]
└─ button.shad-rating__item[role=radio][data-index][data-state=on|half|off][data-active?]
   ├─ svg (base star, fill currentColor)
   └─ span.shad-rating__half[aria-hidden] > svg   (clip-path: inset(0 50% 0 0); RTL flips)
```

## Data-attribute API
| Attribute | On | Effect |
|---|---|---|
| `data-value` | root | current value (kept in sync by JS) |
| `data-max` | root | star count (default 5) |
| `data-half` | root | 0.5 steps; click position picks the half |
| `data-readonly` | root | display-only: `role=img`, no tab stops |
| `data-size` | root | `sm` 1rem / default 1.25rem / `lg` 1.5rem |

Colors via `--shad-rating-on` (default yellow-500 literal — no success/warn token; documented like value-box's delta green) and `--shad-rating-off` (border token); override per-instance with inline style.

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | number (0 = unset) |
| `setValue(v)` | clamp/snap to step; emits |
| `destroy()` | unbind + remove stars |
| `shad:change` | `{value}` |

## Keyboard
Right/Up +step, Left/Down −step (RTL-aware), Home = min step, End = max. Clicking the current value clears to 0. Roving tabindex: the checked star (or the first) is the tab stop.

## A11y
Interactive: `role=radiogroup` with `role=radio` stars, `aria-checked`, per-star `aria-label` ("3 stars"). Readonly: single `role=img` with "4.5 out of 5 stars" label; stars are disabled and untabbable. Hover preview is visual-only and resets on mouseleave.
