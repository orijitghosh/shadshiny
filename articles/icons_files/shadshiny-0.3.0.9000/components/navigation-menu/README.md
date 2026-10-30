<!-- FILE: inst/assets/components/navigation-menu/README.md -->
# navigation-menu (Tier 3)

## Anatomy
```
nav.shad-nav-menu[data-shad=navigation-menu]
├─ ul.shad-nav-menu__list
│  ├─ li[data-shad-nav-item]
│  │  ├─ button.shad-nav-menu__trigger (+ svg.shad-nav-menu__chevron)
│  │  └─ div.shad-nav-menu__panel[hidden]     (JS moves it into the viewport)
│  └─ li > a.shad-nav-menu__link              (plain link item)
└─ div.shad-nav-menu__viewport[hidden]        (shared animated panel)
```
Content helpers: `.shad-nav-menu__grid`, `__card`, `__card-title`, `__card-desc`.

## Behavior
- Single shared **viewport** under the row: switching triggers cross-fades panels while the viewport animates width/height (`--shad-nav-viewport-width/height` transitions) and slides its left edge under the active trigger.
- Hover opens with 150 ms intent delay; leaving trigger+viewport closes after 200 ms; click toggles; Esc/outside press close.
- Panels are NOT portaled (nav is page-level chrome).

## Methods / Events
`getValue()` → active index (−1 closed); `setValue(i)` opens index / closes on null; `open()/close()/isOpen/destroy()`; `shad:open`/`shad:close`.

## Keyboard
←/→ rove across triggers and links; Enter/Space toggles; ↓ moves focus into the open panel; Tab walks panel links; Esc closes.

## A11y
`aria-expanded`/`aria-controls` per trigger; chevron rotates via `data-state`.
