<!-- FILE: inst/assets/components/menubar/README.md -->
# menubar (Tier 3)

**Depends on dropdown-menu** (css + js): supplies `.shad-menu*` styles and `shad.__menuCore`.

## Anatomy
```
div.shad-menubar[data-shad=menubar][role=menubar]
└─ div[data-shad-menubar-menu]        (one per menu)
   ├─ button.shad-menubar__trigger[role=menuitem]
   └─ div.shad-menu__content.shad-anim-pop[hidden]   (dropdown-menu item anatomy)
```

## Behavior
- Roving tabindex across triggers (←/→, Home/End); one Tab stop.
- Click / Enter / Space / ↓ opens; click again closes.
- **Hover-switch**: once any menu is open, pointerenter on another trigger opens it.
- Inside an open menu, ← / → move to the adjacent menubar menu (→ on a submenu trigger opens the submenu instead; ← inside a submenu closes it first).
- Esc closes and refocuses the trigger.

## Methods / Events
`getValue()/setValue(v)` (last activated item value), `open()` (first menu), `close()`, `isOpen`, `destroy()`; `shad:open {menu}` / `shad:close`; `shad:change {value, type, checked?}`.

## A11y
`role=menubar` / `menuitem`, `aria-haspopup`/`aria-expanded` per trigger; menus follow the dropdown-menu APG mapping.
