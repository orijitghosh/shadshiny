<!-- FILE: inst/assets/components/marker/README.md -->
# marker (Tier 1, CSS-only)

## Anatomy
```
div.shad-marker.shad-marker--{variant}[.shad-marker--shimmer][role=status]
├─ span.shad-marker__icon[aria-hidden=true]     (optional)
│  └─ svg.shad-icon
└─ span.shad-marker__content                    (label text)
```

## Modifier classes
- Variants: `(none = default row) | shad-marker--border (bottom rule) | shad-marker--separator (centered label, divider lines both sides)`
- `shad-marker--shimmer` – animated gradient sweep over `__content` for streaming/"thinking" text; falls back to static muted text under `prefers-reduced-motion`

## Data-attribute API
None – appearance is fully class-driven.

## Methods / Events
None – display-only. R wrapper: `shad_marker(label, icon = NULL, variant = c("default", "border", "separator"), streaming = FALSE)` – `streaming = TRUE` adds `--shimmer` + `role="status"`.

## Keyboard
None – static content.

## A11y
- Streaming markers ("Thinking…") should carry `role="status"` so updates are announced politely.
- `__icon` is decorative: `aria-hidden="true"`.
- Separator/border rules are drawn with `::before`/`::after`/borders – nothing extra is announced.
