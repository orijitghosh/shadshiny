<!-- FILE: inst/assets/components/select/README.md -->
# select (Tier 2)

## Anatomy
```
div.shad-select[data-shad=select]
├─ button.shad-select__trigger[data-placeholder?]
│  ├─ span.shad-select__value
│  └─ svg.shad-select__chevron
└─ div.shad-select__content.shad-anim-pop[hidden]      (portaled to body on open)
   ├─ button.shad-select__scroll-btn[data-dir=up]
   ├─ div.shad-select__viewport[role=listbox]
   │  ├─ div[role=group] > div.shad-select__group-label + items
   │  ├─ div.shad-select__item[role=option][data-value][data-state]
   │  │  └─ svg.shad-select__item-check
   │  └─ div.shad-select__separator
   └─ button.shad-select__scroll-btn[data-dir=down]
```

## Data-attribute API
| Attribute | On | Effect |
|---|---|---|
| `data-placeholder` | trigger | muted value text (managed by JS after init) |
| `data-value` | item | option value |
| `data-state` | item | `checked`/`unchecked` (seed initial selection) |
| `data-disabled` + `aria-disabled` | item | skipped |
| `data-highlighted` | item | set by JS on pointermove/arrows |
| `data-side`/`data-align`/`data-state` | content | set by runtime for animation |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | selected value or `null` |
| `setValue(v)` | select programmatically; emits |
| `open()` / `close()` / `isOpen` | panel control |
| `destroy()` | unbind + close |
| `shad:change` | `{value}` on selection |
| `shad:open` / `shad:close` | panel lifecycle |

## Keyboard
Closed: ArrowDown/Up/Enter/Space open; printable char opens + typeahead. Open: arrows move highlight, Home/End, typeahead (1s buffer), Enter/Space select, Esc close, Tab closes. Focus stays on the trigger; `aria-activedescendant` tracks highlight. pointermove (not hover) highlights.

## A11y
APG select-only combobox: the trigger is `role=combobox` (set by R and by the
JS for hand-written markup), so it may carry `aria-activedescendant`. A field
label names it (`aria-labelledby`, from form-field); with none, the
placeholder is its `aria-label`. Its text is the value, read after the name. Scroll buttons are `aria-hidden` conveniences; keyboard scrolls via highlight.
