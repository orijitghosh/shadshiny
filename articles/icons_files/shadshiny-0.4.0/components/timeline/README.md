<!-- FILE: inst/assets/components/timeline/README.md -->
# timeline (Tier 1, V2 — CSS-only)

Vertical timeline: dot + connector + content per item. Left-aligned (default) or alternating.

## Anatomy
```
ol.shad-timeline[--alternate?]
└─ li.shad-timeline__item[data-state=active|muted]     (no attr = default)
   ├─ span.shad-timeline__marker
   │  ├─ span.shad-timeline__dot        (empty = small filled dot; or svg icon inside)
   │  └─ span.shad-timeline__connector[aria-hidden]    (omit/auto-hidden on last item)
   └─ div.shad-timeline__content
      ├─ time.shad-timeline__time       (optional)
      ├─ div.shad-timeline__title
      └─ div.shad-timeline__description (optional)
```

## Data-attribute API
| Attribute | On | Effect |
|---|---|---|
| `data-state="active"` | item | primary-filled dot, emphasized title |
| `data-state="muted"` | item | 60% opacity, hollow small dot |
| (class) `--alternate` | root | items alternate left/right of a center spine |

## A11y
Semantic `<ol>`/`<li>` conveys order; connectors and dot icons are `aria-hidden`. Use `<time datetime>` for machine-readable dates. Pure CSS — no roles, no JS.
