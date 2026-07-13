<!-- FILE: inst/assets/components/combobox/README.md -->
# combobox (Tier 2)

## Anatomy
```
div.shad-combobox[data-shad=combobox][data-multiple?][data-state]
├─ button.shad-combobox__trigger[data-placeholder?]
│  ├─ (JS-rendered) span.shad-combobox__badge × n   (multi mode chips w/ ✕)
│  ├─ span.shad-combobox__value
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
| `data-multiple` | root | multi mode; value is string[]; chips render in trigger |
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
Trigger: ArrowDown/Up/Enter/Space open (focus moves to search input). Input: type filters (substring); arrows loop highlight; Enter selects (multi: toggles, stays open); Backspace on empty input removes last chip (multi); Esc closes; Tab closes.

## A11y
APG combobox pattern: input `role=combobox` + `aria-activedescendant`, list `role=listbox` (+`aria-multiselectable`), chips' ✕ have `aria-label`.
