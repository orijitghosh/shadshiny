<!-- FILE: inst/assets/components/chart-container/README.md -->
# chart-container (Tier 1, V2 – CSS-only)

Wrapper giving R plot outputs (`plotOutput()` <img>, htmlwidget <div>, canvas) the shadcn chart look. No JS. Works with any opaque child.

## Anatomy
```
figure.shad-chart[--plain?]
├─ div.shad-chart__header
│  ├─ div.shad-chart__title
│  └─ div.shad-chart__description
├─ div.shad-chart__body[data-aspect=video|square|wide]   (or __body--auto)
│  └─ (opaque child: img / canvas / svg / div – stretched to fill)
├─ div.shad-chart-legend
│  └─ span.shad-chart-legend__item > span.shad-chart-legend__swatch + text
└─ figcaption.shad-chart__footer
```
Standalone: `.shad-chart-tooltip` (__label / __row > __swatch + text + __value) – a themed tooltip class plot libs can adopt.

## Data-attribute API
| Attribute | On | Effect |
|---|---|---|
| `data-aspect="video"` | __body | 16:9 aspect lock |
| `data-aspect="square"` | __body | 1:1 |
| `data-aspect="wide"` | __body | 21:9 |
| (none) + `__body--auto` | __body | natural height, child flows |
| `--legend-color` | swatch style | explicit series color |

Legend swatches auto-color from `--shad-chart-1…6` by nth-child; override per-item with `style="--legend-color: …"`.

## Deviations
- `width/height: 100% !important` on body children: htmlwidgets write inline sizes; this is the only way to make an opaque child fill the aspect box (documented exception, matches V1's !important policy).

## A11y
Use `<figure>`/`<figcaption>` as shown; the plot child should carry its own `alt`/`aria-label`. Legend is decorative duplication of the plot's own legend unless the plot has none.
