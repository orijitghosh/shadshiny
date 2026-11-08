<!-- FILE: inst/assets/components/hover-card/README.md -->
# hover-card (Tier 3)

## Anatomy
```
div[data-shad=hover-card][data-side][data-align]
├─ *.shad-hover-card__trigger      (usually a link)
└─ div.shad-hover-card__content.shad-anim-pop[hidden]
```

## Behavior
Pointer-only preview: opens after **700 ms** hover, closes **300 ms** after the pointer leaves both trigger and panel (entering the panel cancels the close). Touch never opens. Keyboard focus opens immediately; blur/Esc close. Portaled + FloatingEngine.

## Methods / Events
`getValue()/setValue(bool)/open()/close()/isOpen/destroy()`; `shad:open`/`shad:close`.

## A11y
No tooltip role — content is rich/supplementary; ensure the trigger itself carries the essential information (hover-cards are progressive enhancement).
