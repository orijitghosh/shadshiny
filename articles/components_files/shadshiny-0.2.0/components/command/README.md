<!-- FILE: inst/assets/components/command/README.md -->
# command (Tier 3)

cmdk-style palette. Inline (always visible) or dialog mode (hidden behind a hotkey).

## Anatomy
```
div.shad-command[data-shad=command][data-hotkey?][aria-label]
├─ div.shad-command__header > svg.__search-icon + input.shad-command__input
└─ div.shad-command__list[role=listbox]
   ├─ div.shad-command__empty                       (auto-toggled)
   ├─ div.shad-command__group
   │  ├─ div.shad-command__group-heading
   │  └─ button.shad-command__item[data-value][data-keywords?] (+ span.__shortcut)
   └─ div.shad-command__separator
```

## Modes
- **Inline** (default): filter-as-you-type list.
- **Dialog**: add `data-hotkey="mod+k"` (mod = ⌘ on mac, Ctrl elsewhere) or `data-dialog`. JS adds `.shad-command--dialog`, creates the overlay, portals, traps focus, locks scroll. Toggle also via `instance.open()/close()`.

## Filtering (decision)
Case-insensitive **substring** match on item text + `data-keywords`; groups/separators hide when emptied; `__empty` shows on zero matches; first match auto-highlighted. No fuzzy scoring.

## Methods / Events
`getValue()` → last activated `data-value`; `setValue(v)` sets stored value; `open()/close()/isOpen` (dialog mode); `refresh()` re-filters after DOM swaps; `destroy()`. Events: `shad:change {value}` on activate; `shad:open`/`shad:close` (dialog mode).

## Keyboard
↓/↑ move highlight (clamped, not looped — cmdk behavior), Home/End, Enter activates, Esc closes (dialog), hotkey toggles. Pointermove highlights; highlight is shared pointer/keyboard state via `data-highlighted` + `aria-activedescendant`.

## A11y
Input: `role=combobox` + `aria-controls`/`aria-activedescendant`; list `role=listbox`; items `role=option` + `aria-selected`. Dialog mode: `role=dialog` + `aria-modal`.
