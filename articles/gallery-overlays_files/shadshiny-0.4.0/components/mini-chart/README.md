<!-- FILE: inst/assets/components/mini-chart/README.md -->
# mini-chart (CSS-only)

Sparkline + mini donut. There is no JS: the R constructors emit finished SVG
geometry, and the CSS only handles sizing and the donut's rotation.

## Anatomy
- `svg.shad-sparkline` — `viewBox="0 0 100 100"`, `preserveAspectRatio="none"`,
  strokes carry `vector-effect="non-scaling-stroke"` so stretching the box does
  not thicken the line.
- `div.shad-donut` > `svg.shad-donut__svg` + optional `div.shad-donut__center`.
  Segments are dashes on one circle (`stroke-dasharray` / `stroke-dashoffset`),
  which keeps the ring perfectly round at any size and needs no arc maths.

## Theming
Every mark is painted `var(--shad-chart-N)`. That is the reason these exist:
a dark-mode toggle or a preset switch restyles them in CSS, with no re-render
and no Shiny session — unlike a `renderPlot()` sparkline, which needs a server
round-trip to follow the theme.

## A11y
Decorative by default (`aria-hidden="true"`) — the number a sparkline
illustrates is normally already on screen. Pass `label` to promote it to
`role="img"` with an accessible name.
