<!-- FILE: inst/assets/components/breadcrumb/README.md -->
# breadcrumb (Tier 1, CSS-only)

## Anatomy
```
nav.shad-breadcrumb[aria-label=Breadcrumb]
└─ ol.shad-breadcrumb__list
   ├─ li.shad-breadcrumb__item > a.shad-breadcrumb__link
   ├─ li.shad-breadcrumb__separator > svg (chevron-right)
   ├─ li.shad-breadcrumb__item > span.shad-breadcrumb__ellipsis  (collapse)
   └─ li.shad-breadcrumb__item > span.shad-breadcrumb__page[aria-current=page]
```

## Methods / Events
None. R wrapper: `shad_breadcrumb(items, collapse_after)` — wrapper decides which middle items to replace with the ellipsis (static collapse; pair with dropdown-menu for interactive expansion).

## A11y
`nav[aria-label]`, separators `aria-hidden`, current page `aria-current="page"`.
