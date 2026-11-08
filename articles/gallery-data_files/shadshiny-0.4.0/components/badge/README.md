<!-- FILE: inst/assets/components/badge/README.md -->
# badge (Tier 1, CSS-only)

## Anatomy
```
span.shad-badge.shad-badge--{variant}
├─ svg.shad-icon (optional)
└─ text
```

## Modifier classes
Variants: `shad-badge--default | --secondary | --destructive | --outline`

## Methods / Events
None (static). R wrapper: `shad_badge(label, variant, icon)`.

## A11y
Purely decorative text container; no roles needed.
