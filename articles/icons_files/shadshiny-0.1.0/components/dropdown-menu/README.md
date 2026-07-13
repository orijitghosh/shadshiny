<!-- FILE: inst/assets/components/dropdown-menu/README.md -->
# dropdown-menu (Tier 3)

Registers the **shared menu core** (`shad.__menuCore`) reused by context-menu and menubar — load this file (css+js) before those.

## Anatomy
```
div[data-shad=dropdown-menu][data-side][data-align]
├─ *.shad-menu__trigger
└─ div.shad-menu__content.shad-anim-pop[hidden][role=menu]
   ├─ div.shad-menu__label
   ├─ button.shad-menu__item[data-value]            (+ span.shad-menu__shortcut)
   ├─ button.shad-menu__item[data-type=checkbox][data-state] > span.shad-menu__indicator + text
   ├─ button.shad-menu__item[data-type=radio][data-group][data-state] > indicator + text
   ├─ div.shad-menu__separator
   └─ div[data-shad-submenu]
      ├─ button.shad-menu__item[data-shad-submenu-trigger] (+ svg.shad-menu__chevron)
      └─ div.shad-menu__content.shad-anim-pop[hidden]      (nested, opens right/start)
```
Modifiers: `.shad-menu__item--destructive`. Disabled: `data-disabled` or `aria-disabled="true"`.

## Data-attribute API
| Attribute | Where | Meaning |
|---|---|---|
| `data-side` / `data-align` | root | placement (default bottom/start) |
| `data-value` | item | value reported on activate |
| `data-type` | item | `checkbox` \| `radio` (omit = plain) |
| `data-state` | item | `checked`/`unchecked` (author sets initial; JS maintains + mirrors `aria-checked`) |
| `data-group` | radio item | radio group key |
| `data-highlighted` | item | runtime highlight (pointermove/arrows — **not** `:hover`) |
| `data-shad-submenu` / `data-shad-submenu-trigger` | wrapper/item | nested submenu |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | last activated item's value |
| `setValue(v)` | set stored value (no UI side effect for plain items) |
| `open()` / `close()` / `isOpen` | panel control |
| `destroy()` | unbind |
| `shad:open` / `shad:close` | panel lifecycle |
| `shad:change` | `{value, type:"item"|"checkbox"|"radio", checked?}` on activate |

## Keyboard
Trigger: Enter/Space/↓/↑ open (first item highlighted). Menu: ↓/↑ move, Home/End, →  opens submenu, ← closes submenu (or the menu), Enter/Space activate, Esc closes + refocuses trigger, typeahead (1 s buffer), Tab closes.

## A11y
`role=menu` / `menuitem` / `menuitemcheckbox` / `menuitemradio`, `aria-checked`, `aria-haspopup` + `aria-expanded` on triggers. Highlight follows pointer**move** (shadcn detail), keyboard and pointer share one highlight state.
