<!-- FILE: inst/assets/components/drawer/README.md -->
# drawer (Tier 3)

Bottom sheet with drag-to-dismiss (vaul-style). Reuses `shad-anim-sheet` bottom slide for enter/exit.

## Anatomy
```
div[data-shad=drawer]
├─ *.shad-drawer__trigger
├─ div.shad-drawer__overlay.shad-anim-overlay[hidden]
└─ div.shad-drawer__content.shad-anim-sheet[hidden]   (JS stamps data-side=bottom)
   ├─ div.shad-drawer__handle
   ├─ div.shad-drawer__header > __title + __description
   ├─ div.shad-drawer__body        (scrollable region; drag yields to its scroll)
   └─ div.shad-drawer__footer      ([data-shad-drawer-close] closes)
```

## Drag physics (decisions)
- Dismiss on release when downward velocity > **0.5 px/ms** OR travel > **50 %** of panel height; otherwise spring back (300 ms ease-out transition).
- Upward drag rubber-bands at 1/3 rate. Overlay opacity tracks drag progress.
- `data-dragging` present during drag (disables the transform transition).

## Methods / Events
`getValue()/setValue(bool)/open()/close()/isOpen/destroy()`; `shad:open`/`shad:close`/`shad:change {value:bool}`.

## Keyboard / A11y
Modal dialog semantics (trap, Esc, scroll lock, focus restore), `role=dialog` + `aria-modal`, labelled by title.
