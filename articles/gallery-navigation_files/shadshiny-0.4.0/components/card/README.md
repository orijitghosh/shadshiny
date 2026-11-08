<!-- FILE: inst/assets/components/card/README.md -->
# card (Tier 1, CSS-only)

## Anatomy
```
div.shad-card
├─ div.shad-card__header [.shad-card__header--border]
│  ├─ div.shad-card__title
│  ├─ div.shad-card__description
│  └─ div.shad-card__action        (optional; pins top-right via grid)
├─ div.shad-card__content
└─ div.shad-card__footer [.shad-card__footer--border]
```

## Modifier classes
`--border` variants on header/footer add hairline dividers.

## Methods / Events
None. R wrapper: `shad_card(header, content, footer, title, description, action)`.

## A11y
Plain containers. Use headings inside `__title` when the card titles a page region.
