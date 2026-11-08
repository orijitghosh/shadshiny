<!-- FILE: inst/assets/components/popover/README.md -->
# popover (Tier 3)

## Anatomy
```
div[data-shad=popover][data-side][data-align]
├─ *.shad-popover__trigger
└─ div.shad-popover__content.shad-anim-pop[hidden]
   ├─ div.shad-popover__arrow    (optional)
   └─ …rich content…
```
Modifier: `.shad-popover__content--auto` (max-content width instead of 18rem).

## Behavior
Non-modal: focus moves into panel on open (`[data-shad-autofocus]` → first tabbable → panel) but is NOT trapped – tabbing out closes. Trigger click toggles. Esc closes and refocuses trigger; outside press closes. Portaled + FloatingEngine (flip/shift, 6px offset); `data-side`/`data-align` drive the animation origin.

## Data-attribute API
`data-side` (default `bottom`), `data-align` (default `center`) on root; `data-shad-autofocus` inside panel.

## Methods / Events
`getValue()/setValue(bool)/open()/close()/isOpen/destroy()`; `shad:open`/`shad:close`/`shad:change {value:bool}`.

## A11y
Trigger: `aria-haspopup=dialog`, `aria-expanded`, `aria-controls`.
