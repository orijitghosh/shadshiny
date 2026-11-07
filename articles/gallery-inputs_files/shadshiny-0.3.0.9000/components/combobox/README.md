<!-- FILE: inst/assets/components/combobox/README.md -->
# combobox (Tier 2)

## Anatomy
```
div.shad-combobox[data-shad=combobox][data-multiple?][data-state]
├─ (JS-rendered, multi only) div.shad-combobox__chips
│  └─ span.shad-combobox__badge × n > text + button.shad-combobox__badge-x[aria-label]
├─ button.shad-combobox__trigger[data-placeholder?]
│  ├─ span.shad-combobox__value   (multi with chips: their labels, .shad-sr-only)
│  └─ svg.shad-combobox__chevrons
└─ div.shad-combobox__content.shad-anim-pop[hidden]  (portaled on open)
   ├─ div.shad-combobox__search > svg + input.shad-combobox__input[role=combobox]
   ├─ div.shad-combobox__list[role=listbox]
   │  └─ div.shad-combobox__item[data-value][data-state] > svg.__item-check + text
   └─ div.shad-combobox__empty[hidden]
```

## Data-attribute API
| Attribute | On | Effect |
|---|---|---|
| `data-multiple` | root | multi mode; value is string[]; the root draws the box and chips render before the trigger |
| `data-value` / `data-state` | item | value / seed selection |
| `data-disabled` | item | skipped |
| `data-highlighted` | item | live highlight |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | string\|null or string[] |
| `setValue(v)` | same shape; emits |
| `open()` / `close()` / `isOpen` | panel |
| `destroy()` | unbind |
| `shad:change` / `shad:open` / `shad:close` | uniform contract |

## Keyboard
Trigger: ArrowDown/Up/Enter/Space open (focus moves to search input). Input: type filters (substring); arrows loop highlight; Enter selects (multi: toggles, stays open); Backspace on empty input removes last chip (multi); Esc closes and focuses the trigger; Tab closes and moves on from the trigger (the panel is portaled, so focus goes to the next tabbable after the trigger); Shift+Tab closes and focuses the trigger.

Chips (multi): each ✕ is a tab stop before the trigger. Enter, Space, Delete or Backspace removes that value; focus moves to the next chip's ✕, else the previous one, else the trigger. Clicking a chip's text toggles the panel.

## A11y
APG combobox pattern: input `role=combobox` + `aria-activedescendant`, list `role=listbox` (+`aria-multiselectable`), chips' ✕ are real buttons named "Remove <label>", kept outside the trigger because a button's children are presentational.
