<!-- FILE: inst/assets/components/value-box/README.md -->
# value-box (Tier 1, V2 — CSS-only)

KPI/stat card. Grid-friendly: fills container width; drop several in a CSS grid.

## Anatomy
```
div.shad-value-box            (or a.shad-value-box[href] — hover/focus ring)
│    [--sm | --lg size modifiers]
├─ div.shad-value-box__label
├─ span.shad-value-box__icon            (optional; pins top-right via grid)
│  └─ svg (1rem)
├─ div.shad-value-box__value            (tabular-nums; baseline row)
│  └─ span.shad-value-box__delta[data-trend=up|down|neutral]  (chip, optional svg arrow)
├─ div.shad-value-box__caption          (optional muted line)
└─ div.shad-value-box__sparkline        (optional; opaque child fills 2.5rem strip)
```

## Data-attribute API
| Attribute | On | Effect |
|---|---|---|
| `data-trend="up"` | __delta | green chip (dark mode lightens to green-500) |
| `data-trend="down"` | __delta | destructive chip |
| `data-trend="neutral"` | __delta | muted chip |

## Variants
- `a.shad-value-box[href]` — whole box is a link; hover raises border/shadow, focus-visible shows the standard ring.
- `--sm` / default / `--lg` — value type steps xl / 2xl / 30px; padding 4 / 6 / 8.

## Deviations
- Sparkline children get `width/height: 100% !important` — same htmlwidget inline-size exception as chart-container.
- Delta green is a literal Tailwind green (`oklch(0.527 0.154 150.069)` light / green-500 dark): shadshiny has no success token; documented rather than inventing one.

## A11y
Pure content — no roles needed. For the link variant, the label + value read as the link text; keep them meaningful. Delta arrows are decorative (`aria-hidden` recommended on the svg); the ± sign in text carries the meaning.
