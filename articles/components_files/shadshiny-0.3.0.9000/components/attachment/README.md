<!-- FILE: inst/assets/components/attachment/README.md -->
# attachment (Tier 1, CSS-only — lifecycle via data-state)

## Anatomy
```
div.shad-attachment-group                                     (optional scrollable row)
└─ div.shad-attachment[--{orientation}][--{size}][data-state]
   ├─ button.shad-attachment__trigger                         (optional full-card click overlay, first child)
   ├─ div.shad-attachment__media(--icon|--image)              [aria-hidden=true when decorative]
   │  └─ svg.shad-icon | img
   ├─ div.shad-attachment__content
   │  ├─ div.shad-attachment__title                           (truncates)
   │  └─ div.shad-attachment__description                     (truncates)
   └─ div.shad-attachment__actions
      └─ button.shad-attachment__action > svg.shad-icon
```

## Modifier classes
- Orientation: `(none = horizontal) | shad-attachment--vertical` (media on top, actions float top-corner)
- Sizes: `(none = default) | shad-attachment--sm | shad-attachment--xs`
- Media: `shad-attachment__media--icon` (muted tile) | `shad-attachment__media--image` (cover thumb)

## Data-attribute API
| Attribute | Effect |
|---|---|
| `data-state="idle"` / absent | resting |
| `data-state="uploading"` | progress shimmer sweep, dimmed content |
| `data-state="processing"` | pulsing media tile |
| `data-state="error"` | destructive border/background/description tint |
| `data-state="done"` | resting (semantic hook only) |

## Methods / Events
None — no JS binding; the server (or composer JS) flips `data-state`. R wrapper: `shad_attachment(title, description = NULL, media = NULL, actions = NULL, orientation = c("horizontal", "vertical"), size = NULL, state = "idle", href = NULL)` + `shad_attachment_group(...)`.

## Keyboard
`__trigger` and `__action` are native buttons — Tab/Enter/Space work natively. Actions sit above the trigger overlay (`z-index`), so both are reachable.

## A11y
- `__trigger` needs an `aria-label` naming the file ("Open report.pdf") since its text is empty.
- `__action` buttons need `aria-label` ("Remove attachment").
- Media is decorative when the title names the file: `aria-hidden="true"`.
- Announce upload progress separately (e.g. `role="status"` text updated by the server) — the shimmer is visual only.
