<!-- FILE: inst/assets/components/dialog/README.md -->
# dialog (Tier 3)

## Anatomy
```
div.shad-dialog[data-shad=dialog]
├─ *.shad-dialog__trigger                       (optional; any clickable)
├─ div.shad-dialog__overlay.shad-anim-overlay[hidden]
└─ div.shad-dialog__content.shad-anim-dialog[hidden][role=dialog][aria-modal]
   ├─ button.shad-dialog__close[data-shad-dialog-close]
   ├─ div.shad-dialog__header > __title + __description
   ├─ …body…
   └─ div.shad-dialog__footer > buttons ([data-shad-dialog-close] closes)
```
Overlay + content are portaled to `<body>` on open, restored on close.

## Data-attribute API
| Attribute | Effect |
|---|---|
| `data-shad-dialog-close` | any element inside content closes the dialog |
| `data-shad-autofocus` | initial focus target inside content |
| `data-state` | `open`/`closed` on overlay + content (runtime-managed) |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | boolean (open) |
| `setValue(v)` | open/close |
| `open()` / `close()` / `isOpen` | same |
| `destroy()` | close + unbind |
| `shad:open` / `shad:close` / `shad:change {value:boolean}` | lifecycle |

## Keyboard / Focus
Focus trapped (Tab cycles); Esc closes (topmost layer only); focus restored to trigger on close. Scroll locked with scrollbar compensation. Exit animates before unmount (Presence).

## A11y
`role=dialog` + `aria-modal` + `aria-labelledby`/`aria-describedby` auto-wired from title/description.
