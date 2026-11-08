<!-- FILE: inst/assets/components/context-menu/README.md -->
# context-menu (Tier 3)

**Depends on dropdown-menu** (load `dropdown-menu/dropdown-menu.css` + `.js` first – supplies all `.shad-menu*` styles and `shad.__menuCore`).

## Anatomy
```
div[data-shad=context-menu]
├─ div.shad-context-menu__zone      (right-click capture area; focusable)
└─ div.shad-menu__content.shad-anim-pop[hidden]   (identical item anatomy to dropdown-menu)
```

## Behavior
`contextmenu` inside the zone is prevented and opens the panel at the pointer via a **virtual 1×1 anchor rect** (flip/shift keep it in the viewport). Second right-click while open just repositions. Keyboard: Shift+F10 / ContextMenu key opens at zone center.

## Methods / Events
Same contract as dropdown-menu: `getValue()/setValue(v)/open()/close()/isOpen/destroy()`; `shad:open`/`shad:close`; `shad:change {value, type, checked?}`.

## Keyboard
Zone: Shift+F10 / ContextMenu open. Menu keys identical to dropdown-menu (arrows, Home/End, →/← submenus, Enter/Space, Esc, typeahead).
