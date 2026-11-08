<!-- FILE: inst/assets/components/command/README.md -->
# command (Tier 3)

cmdk-style palette. Inline (always visible) or dialog mode (hidden behind a hotkey).

## Anatomy
```
div.shad-command[data-shad=command][data-hotkey?][aria-label]
├─ div.shad-command__header > svg.__search-icon + input.shad-command__input
└─ div.shad-command__list[role=listbox]
   ├─ div.shad-command__empty                       (auto-toggled)
   ├─ div.shad-command__group[role=group][aria-labelledby=heading]
   │  ├─ div.shad-command__group-heading[id]
   │  └─ button.shad-command__item[role=option][id][tabindex=-1][data-value][data-keywords?][data-disabled?]
   │       (+ span.__shortcut)
   └─ div.shad-command__separator
```
JS adds the roles, ids, `tabindex=-1` and `aria-disabled` (from `data-disabled`) at init and again on `refresh()`, so swapped-in items match.

## Modes
- **Inline** (default): filter-as-you-type list.
- **Dialog**: add `data-hotkey="mod+k"` (mod = ⌘ on mac, Ctrl elsewhere) or `data-dialog`. JS adds `.shad-command--dialog`, creates the overlay, portals, traps focus, locks scroll. Toggle also via `instance.open()/close()`.

## Hotkey format
`+`-separated modifiers, then the key, in any case: `mod` (⌘ or Ctrl), `ctrl`/`control`, `meta`/`cmd`/`command`, `alt`/`option`, `shift`; `space` names the space bar (`"mod+shift+p"`, `"alt+space"`, `"/"`).
- Exactly the named modifiers: `mod+k` ignores Ctrl+Shift+K, `mod+shift+p` leaves Ctrl+P (Print) alone.
- A symbol key (`/`, `?`) may come with Shift, since some layouts need it; letters and named keys may not.
- A letter that types another script (a Russian layout, Option on a Mac) matches by its physical key (`ev.code`).
- A hotkey without Ctrl, ⌘ or Alt does not fire in an editable field (input, textarea, select, contenteditable), the palette's own search included.
- Key-less keydowns (autofill), auto-repeats and IME compositions are ignored.
- An unknown modifier (`"hyper+k"`) never fires; `console.warn` says so.

## Filtering (decision)
Case-insensitive **substring** match on item text + `data-keywords`; groups/separators hide when emptied; `__empty` shows on zero matches; first match auto-highlighted. No fuzzy scoring.

## Methods / Events
`getValue()` → last activated `data-value`; `setValue(v)` sets stored value; `open()/close()/isOpen` (dialog mode); `refresh()` re-reads the items (roles, ids, groups, the empty text) and re-runs the filter with the current query after DOM swaps (`update_shad_command()` calls it); `destroy()`. Events: `shad:change {value}` on activate; `shad:open`/`shad:close` (dialog mode).

## Keyboard
The search input is the palette's only tab stop: Tab leaves an inline palette, and an open dialog keeps Tab on the search. ↓/↑ move highlight (clamped, not looped – cmdk behavior), Home/End, Enter activates, Esc closes (dialog), hotkey toggles. While an IME composition is in progress its keys belong to the IME. Pointermove highlights; highlight is shared pointer/keyboard state via `data-highlighted` + `aria-activedescendant`. Pressing an item keeps focus in the search, so the arrows keep working after a click.

## A11y
Input: `role=combobox` + `aria-controls`/`aria-activedescendant` (removed when nothing is highlighted); list `role=listbox`; items `role=option` + `aria-selected`, disabled items `aria-disabled`; groups `role=group` named by their heading. Dialog mode: `role=dialog` + `aria-modal`.

Contract: `tests/js/command-contract.test.js`.
