<!-- FILE: inst/assets/components/date-picker/README.md -->
# date-picker (Tier 2)

## Anatomy
```
div.shad-date-picker[data-shad=date-picker]
├─ button.shad-date-picker__trigger[data-placeholder?]
│  ├─ svg (calendar icon)
│  └─ span.shad-date-picker__value
└─ div.shad-date-picker__content.shad-anim-pop[hidden]   (portaled on open)
   └─ div.shad-calendar[data-shad=calendar]              (full calendar API applies)
```
Composition: the inner calendar owns selection; the picker owns the popover + trigger text and re-emits `shad:change` from its root.

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` / `setValue(v)` | proxied to inner calendar (same shapes) |
| `open()` / `close()` / `isOpen` | popover |
| `destroy()` | unbind |
| `shad:change` | `{value}` (re-emitted on root) |
| `shad:open` / `shad:close` | popover lifecycle |

## Behavior
Single mode closes on pick; range mode stays open until the range completes. A `setValue()` (the server's path) only updates the value: it never opens, closes or moves focus. Long-date display format via `toLocaleDateString`.

## Keyboard
Trigger: Enter/Space opens; focus lands on the roving day; Esc closes (DismissLayer) and refocuses trigger. Calendar keys per calendar README.
