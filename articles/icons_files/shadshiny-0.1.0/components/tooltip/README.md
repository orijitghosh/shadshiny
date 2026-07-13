<!-- FILE: inst/assets/components/tooltip/README.md -->
# tooltip (Tier 3)

## Anatomy
```
div[data-shad=tooltip][data-side][data-align]
├─ *.shad-tooltip__trigger
└─ div.shad-tooltip__content.shad-anim-pop[hidden][role=tooltip]
   └─ div.shad-tooltip__arrow    (optional)
```

## Behavior decisions
- **Delay group** (module-level, all tooltips share it): first open **700 ms**; if any tooltip closed < 1.5 s ago, next opens after **300 ms**.
- **Touch pointers never open tooltips** (pen included).
- Keyboard focus (`:focus-visible`) opens immediately; blur closes.
- `pointerdown` on the trigger closes (pressing hides).
- Esc closes. Content is `pointer-events:none` — never traps focus or hover.
- Portaled to body; positioned by FloatingEngine (flip + shift); `data-side`/`data-align` drive the pop animation origin.

## Data-attribute API
`data-side` (default `top`), `data-align` (default `center`) on root.

## Methods / Events
`getValue()/setValue(bool)/open()/close()/isOpen/destroy()`; `shad:open`/`shad:close`. (No `shad:change` — tooltips carry no value.)

## A11y
`role=tooltip`; trigger gets `aria-describedby` → content id.
