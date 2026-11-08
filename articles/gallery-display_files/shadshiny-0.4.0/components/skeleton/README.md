<!-- FILE: inst/assets/components/skeleton/README.md -->
# skeleton (Tier 1, CSS-only)

## Anatomy
`div.shad-skeleton[.shad-skeleton--circle|.shad-skeleton--text]` — size via inline style or context.

## Modifier classes
- `--circle` full radius
- `--text` 1rem tall line

## Methods / Events
None. R wrapper: `shad_skeleton(width, height, shape)`.

## A11y
Always `aria-hidden="true"`; announce loading on the container (`aria-busy`).
