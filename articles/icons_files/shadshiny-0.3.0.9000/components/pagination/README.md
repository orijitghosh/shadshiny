<!-- FILE: inst/assets/components/pagination/README.md -->
# pagination (Tier 3, light JS)

Two modes: **static** (hand-authored links, CSS only) and **JS-driven** (`data-shad="pagination"` renders a windowed page list).

## Anatomy
```
nav.shad-pagination[data-shad=pagination][data-pages][data-page]
└─ ul.shad-pagination__list
   ├─ li > button/a.shad-pagination__link--nav        (Previous / Next)
   ├─ li > button/a.shad-pagination__link[data-state=active][aria-current=page]
   └─ li > span.shad-pagination__ellipsis
```

## Window model (decision)
Always show first, last, and current ±1; ellipsis fills gaps (e.g. `1 … 4 5 6 … 10`).

## Methods / Events
`getValue()` → current page (number); `setValue(p)`; `setPages(n)` updates total; `destroy()`. `shad:change {value: page}` on navigation.

## Keyboard / A11y
Native buttons/links (Tab + Enter). `role=navigation` + label; `aria-current="page"` on the active page; prev/next disabled at bounds via `data-disabled`.
