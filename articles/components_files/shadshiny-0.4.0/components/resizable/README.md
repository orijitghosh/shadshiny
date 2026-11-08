<!-- FILE: inst/assets/components/resizable/README.md -->
# resizable (Tier 3)

Panel group with draggable/keyboard-operable splitters. Nestable (a panel may contain another group).

## Anatomy
```
div.shad-resizable[data-shad=resizable][data-orientation=horizontal|vertical]
├─ div.shad-resizable__panel[data-size][data-min?]     ×n
└─ div.shad-resizable__handle (between each panel pair)
   └─ span.shad-resizable__grip     (optional visual grip)
```

## Data-attribute API
`data-size` initial percent (normalized to 100 across panels) · `data-min` min percent (default 10) · `data-dragging` on handle while dragging (runtime).

## Methods / Events
`getValue()` → `number[]` percents (1 dp); `setValue(number[])` (renormalized); `destroy()`. `shad:change {value: number[]}` fires on drag **release** and each keyboard step – not per pointermove.

## Keyboard (APG window splitter)
Handle is focusable: ←/→ (or ↑/↓ vertical) move 1 %, Shift = 10 %, Home collapses the leading panel to its min, End expands it to max.

## A11y
`role=separator`, `aria-orientation`, `aria-valuenow/min/max` maintained per handle; 1 px visual line with an 8 px hit area.
