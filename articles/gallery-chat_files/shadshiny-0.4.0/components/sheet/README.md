<!-- FILE: inst/assets/components/sheet/README.md -->
# sheet (Tier 3)

## Anatomy
```
div[data-shad=sheet][data-side=right|left|top|bottom]
├─ *.shad-sheet__trigger
├─ div.shad-sheet__overlay.shad-anim-overlay[hidden]
└─ div.shad-sheet__content.shad-anim-sheet[hidden]   (JS stamps data-side)
   ├─ button.shad-sheet__close[data-shad-sheet-close]
   ├─ div.shad-sheet__header > __title + __description
   ├─ …body…
   └─ div.shad-sheet__footer
```

## Data-attribute API
`data-side` on root (default `right`) · `data-shad-sheet-close` closes · `data-shad-autofocus` initial focus.

## Methods / Events
Identical to dialog: `getValue()/setValue(bool)/open()/close()/isOpen/destroy()`; `shad:open`/`shad:close`/`shad:change {value:bool}`.

## Keyboard / A11y
Modal: focus trap, Esc closes, scroll lock, focus restore. `role=dialog` + `aria-modal`, labelled by title. Slide animation is side-keyed (`shad-anim-sheet` + `data-side`).
