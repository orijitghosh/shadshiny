<!-- FILE: inst/assets/components/tabs/README.md -->
# tabs (Tier 3)

## Anatomy
```
div[data-shad=tabs][data-value][data-orientation?]
├─ div.shad-tabs__list[role=tablist]
│  ├─ div.shad-tabs__indicator          (animated pill; JS sets width+translateX)
│  └─ button.shad-tabs__trigger[data-value] ×n
└─ div.shad-tabs__content[data-value] ×n
```

## Data-attribute API
`data-value` on root = active tab (author sets initial; JS maintains). `data-state="active|inactive"` on triggers/panels (runtime). `data-disabled` on a trigger. `data-orientation="vertical"` for vertical arrow keys.

## Methods / Events
`getValue()` → active value; `setValue(v)` selects + fires; `destroy()`. `shad:change {value}` on user/API selection.

## Keyboard
←/→ (or ↑/↓ vertical) move focus AND select (automatic activation); Home/End; Tab exits to the active panel (`tabindex=0`).

## A11y
`role=tablist/tab/tabpanel`, `aria-selected`, `aria-controls`/`aria-labelledby` auto-wired. Indicator repositions on resize + font load.
