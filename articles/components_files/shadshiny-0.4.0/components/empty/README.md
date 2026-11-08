<!-- FILE: inst/assets/components/empty/README.md -->
# empty (Tier 1, CSS-only)

## Anatomy
```
div.shad-empty
├─ div.shad-empty__header
│  ├─ div.shad-empty__media(--icon|--default)   [aria-hidden=true when decorative]
│  │  └─ svg.shad-icon | img | any illustration
│  ├─ div.shad-empty__title
│  └─ div.shad-empty__description               (links styled inside)
└─ div.shad-empty__content                      (actions: .shad-btn, inputs, …)
```

## Modifier classes
- Media: `shad-empty__media--icon` (2.5rem rounded muted tile) | `shad-empty__media--default` / none (free-form: illustration, avatar)

## Data-attribute API
None — layout is fully class-driven.

## Methods / Events
None — display-only. R wrapper: `shad_empty(title, description = NULL, media = NULL, media_variant = c("default", "icon"), content = NULL)`.

## Keyboard
None of its own; actions in `__content` keep native tab order.

## A11y
- Decorative `__media` gets `aria-hidden="true"`.
- `__title` is a `<div>` by design — pass a heading element instead when the state is a page-level landmark.
- Pair with `role="status"`/`aria-live="polite"` on a wrapper when the empty state replaces loading content dynamically.
