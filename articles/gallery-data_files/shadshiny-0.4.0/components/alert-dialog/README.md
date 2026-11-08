<!-- FILE: inst/assets/components/alert-dialog/README.md -->
# alert-dialog (Tier 3)

## Anatomy
Same classes as dialog (see dialog/README.md), with `data-shad="alert-dialog"` on the root. No `__close` ✕ button – decisions must be explicit via footer actions.

Requires `components/dialog/dialog.css` and `components/dialog/dialog.js` to be loaded (dialog.js registers both factories; this dir's files are thin shims documented in their headers).

## Differences from dialog
- `role="alertdialog"`
- NO outside-press dismiss
- NO Esc dismiss (opt back in with `data-escape-close` on the root)
- Initial focus: put `data-shad-autofocus` on the least destructive action (Cancel)

## Methods / Events
Identical to dialog: `getValue()/setValue(v)/open()/close()/isOpen/destroy()`, `shad:open`/`shad:close`/`shad:change`.

## Keyboard
Tab cycles trapped focus; Enter activates focused action.
