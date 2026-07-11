<!-- FILE: inst/assets/components/scroll-area/README.md -->
# scroll-area (Tier 3)

Native scrolling with styled overlay scrollbars (native bars hidden).

## Anatomy
```
div.shad-scroll-area[data-shad=scroll-area]     (sized by author)
├─ div.shad-scroll-area__viewport               (overflow:auto, native bars hidden)
│  └─ …content…
├─ div.shad-scroll-area__scrollbar[data-orientation=vertical] > div.__thumb
└─ div.shad-scroll-area__scrollbar[data-orientation=horizontal] > div.__thumb   (optional)
```

## Behavior
Thumb size/position sync from native scroll metrics (min 24 px thumb); bars auto-hide (visible on hover, during scroll +800 ms, while dragging via `data-state="visible"` / `data-dragging`); thumb drag scrolls proportionally; track click pages. `ResizeObserver` keeps metrics honest; bars with no overflow hide entirely. Scrolling itself stays native (wheel, touch, keyboard all work).

## Methods / Events
`getValue()` → `{top, left}`; `setValue({top?, left?})`; `refresh()` after content swaps; `destroy()`. No `shad:change` (scroll position isn't a form value).

## A11y
Viewport keeps native keyboard scrolling; custom bars are pointer-only decoration.
