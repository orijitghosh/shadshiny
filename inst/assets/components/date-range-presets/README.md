<!-- FILE: inst/assets/components/date-range-presets/README.md -->
# date-range-presets (Tier 2, V2 — CSS + tiny JS)

Preset rail ("Today", "Last 7 days", "This month"…) that slots inside a **range-mode date-picker**'s popover, beside the calendar. Load order: `calendar` → `date-picker` → this (both CSS and JS).

## Anatomy
```
div.shad-date-picker (range mode)
└─ div.shad-date-picker__content            (:has(presets) ⇒ flex row + owns popover chrome)
   ├─ div.shad-date-range-presets[data-shad=date-range-presets][role=group][aria-label]
   │  ├─ button.shad-date-range-presets__item[data-state=active?]
   │  │    range source (first wins): data-start+data-end (ISO) |
   │  │    data-preset=today|yesterday|this-week|this-month|last-month|this-year |
   │  │    data-days=N
   │  └─ div.shad-date-range-presets__separator[role=separator]
   └─ div.shad-calendar[data-mode=range]
```

## Behavior
- Click computes the range and writes it into the inner calendar via its instance `setValue({start, end})` — single source of truth stays the calendar, and the click counts as a pick, so the picker closes and refocuses its trigger.
- Ranges are cut to the calendar's `data-min` / `data-max`; a preset wholly outside them is disabled.
- The item whose computed range equals the picker's current value gets `data-state="active"` (re-checked on every picker `shad:change`).
- `this-week` starts Monday; `data-days=N` = last N days ending today.
- ≤480 px: rail stacks above the calendar as a wrapping row.

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | `{start,end}` of the active preset, or `null` (custom range) |
| `destroy()` | unbind |
| `shad:change` | `{value: {start,end}}` on preset click (picker also emits its own) |

## Keyboard
Items are plain buttons in DOM order — Tab/Enter/Space. Focus stays in the popover (picker owns the dismiss/focus-trap behavior).

## A11y
`role=group` with `aria-label`; separators are `role=separator`. Active preset is visual state (`data-state`) reflecting the picker value, not a radio — the calendar remains the canonical input.
