<!-- FILE: inst/assets/components/calendar/README.md -->
# calendar (Tier 2)

## Anatomy (JS-rendered inside the root)
```
div.shad-calendar[data-shad=calendar][data-mode][data-value][data-value-end]
                 [data-min][data-max][data-week-start][data-month]
                 [data-caption-layout][data-from-year][data-to-year]
├─ div.shad-calendar__header
│  ├─ button.shad-calendar__nav[data-nav=-1]
│  ├─ div.shad-calendar__label[aria-live=polite]        (caption layout "label")
│  │  or div.shad-calendar__caption                     (any dropdown layout)
│  │     └─ select.shad-calendar__dropdown[data-caption=month|year] × 1–2
│  └─ button.shad-calendar__nav[data-nav=1]
└─ table.shad-calendar__grid[role=grid]
   ├─ thead > th.shad-calendar__weekday × 7
   └─ tbody > tr × 6 > td.shad-calendar__cell[data-in-range?]
      └─ button.shad-calendar__day[data-date][data-selected?][data-today?]
                                  [data-outside?][data-disabled?]
                                  [data-range-start?][data-range-end?]
```

## Data-attribute API
| Attribute | Effect |
|---|---|
| `data-mode` | `single` (default) / `range` |
| `data-value` / `data-value-end` | ISO `YYYY-MM-DD` initial selection |
| `data-min` / `data-max` | selectable bounds (inclusive) |
| `data-week-start` | `0` Sunday (default) / `1` Monday |
| `data-month` | `YYYY-MM` opening month; no selection |
| `data-caption-layout` | `label` (default) / `dropdown` / `dropdown-months` / `dropdown-years` |
| `data-from-year` / `data-to-year` | year-dropdown bounds; default `data-min`/`data-max` years, else −100/+10 |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | single: `"YYYY-MM-DD"\|null` · range: `{start, end}` |
| `setValue(v)` | same shape; moves view to selection; emits |
| `goToMonth("YYYY-MM")` | change displayed month only |
| `destroy()` | unbind |
| `shad:change` | `{value}` |

## Keyboard (APG grid)
Arrows ±1 day / ±1 week · PageUp/Down ±1 month (Shift: ±1 year) · Home/End week start/end · Enter/Space select. Shift+PageUp/Down is the only year jump in the default `label` layout; `data-caption-layout` adds a pointer-reachable one. One roving tab stop; month auto-flips when focus crosses boundaries. Range: first pick sets start, second sets end (auto-swaps if earlier); pointer hover previews the band.

## Deviation
Grid re-renders via innerHTML on each interaction — simple and fast at this size; focus is restored to the roving cell after each render.
