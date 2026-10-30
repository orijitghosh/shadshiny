<!-- FILE: inst/assets/components/sidebar/README.md -->
# sidebar (Tier 3)

## Anatomy
```
div.shad-sidebar-layout[data-shad=sidebar]
├─ div.shad-sidebar__overlay[hidden]          (mobile scrim)
├─ aside.shad-sidebar[data-collapsed?]
│  ├─ div.shad-sidebar__header
│  ├─ div.shad-sidebar__content
│  │  └─ div.shad-sidebar__group
│  │     ├─ div.shad-sidebar__group-label
│  │     └─ ul.shad-sidebar__menu > li > button/a.shad-sidebar__item[data-value]
│  │        ├─ svg.shad-icon + span.shad-sidebar__label + span.shad-sidebar__badge?
│  ├─ div.shad-sidebar__separator
│  └─ div.shad-sidebar__footer
└─ main.shad-sidebar-layout__main
   └─ button.shad-sidebar__trigger            (anywhere in the layout)
```

## Modes
- **Desktop (≥768 px)**: trigger (or ⌘/Ctrl+B) toggles `data-collapsed` — 16rem ↔ 3rem icon rail (labels/badges hide, items center).
- **Mobile (<768 px)**: trigger opens an off-canvas sheet (`data-mobile-open`) with overlay, focus trap, scroll lock, Esc/outside dismiss; item click closes it. Crossing back to desktop width auto-closes.

## Data-attribute API
`data-collapsed` (author may set initial) · `data-mobile-open` (runtime) · `data-value` per item · `data-state="active|inactive"` on items (click-tracked; author sets initial active).

## Methods / Events
`getValue()` → `{collapsed, mobileOpen, active}`; `setValue({collapsed?, mobileOpen?})`; `open()/close()` (mobile sheet); `isOpen`; `toggleCollapsed()`; `destroy()`. Events: `shad:change {value:{collapsed,mobileOpen,active}}`; `shad:open`/`shad:close` for the mobile sheet.

## Keyboard
⌘/Ctrl+B toggles. Items are native buttons/links (Tab + Enter). Mobile sheet traps focus, Esc closes.

## Theming
Uses the `--shad-sidebar-*` token family exclusively — presets restyle it independently of the main surface.
