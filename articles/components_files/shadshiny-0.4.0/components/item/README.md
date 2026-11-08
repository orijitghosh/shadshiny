<!-- FILE: inst/assets/components/item/README.md -->
# item (Tier 1, CSS-only)

## Anatomy
```
div.shad-item-group[role=list]
├─ div|a.shad-item[.shad-item--{variant}][.shad-item--{size}][role=listitem]
│  ├─ div.shad-item__header                      (optional, full-width top row)
│  ├─ div.shad-item__media(--icon|--image)       [aria-hidden=true when decorative]
│  │  └─ svg.shad-icon | img
│  ├─ div.shad-item__content
│  │  ├─ div.shad-item__title
│  │  └─ div.shad-item__description              (clamped to 2 lines)
│  ├─ div.shad-item__actions                     (buttons, switches, …)
│  └─ div.shad-item__footer                      (optional, full-width bottom row)
└─ hr.shad-item-separator                        [aria-hidden=true]
```

## Modifier classes
- Variants: `(none = transparent) | shad-item--outline | shad-item--muted`
- Sizes: `(none = default) | shad-item--sm | shad-item--xs`
- Media: `shad-item__media--icon` (2rem bordered muted tile) | `shad-item__media--image` (2.5rem rounded thumb) | none (avatar / free-form)

## Data-attribute API
None – layout is fully class-driven. Rendering as `<a class="shad-item" href>` (or `<button>`) enables hover/focus states automatically.

## Methods / Events
None – display-only. R wrapper: `shad_item(title, description = NULL, media = NULL, actions = NULL, variant = c("default", "outline", "muted"), size = c("default", "sm", "xs"), href = NULL)` + `shad_item_group(...)` + `shad_item_separator()`.

## Keyboard
Native – link/button items are single tab stops; controls in `__actions` keep their own tab order.

## A11y
- Use `role="list"` / `role="listitem"` on group/items when the collection is semantic.
- `shad-item-separator` is decorative: `aria-hidden="true"`.
- Don't nest interactive `__actions` inside an `<a>` item – pick one interaction model per row.
