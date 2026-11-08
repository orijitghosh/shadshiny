<!-- FILE: inst/assets/components/aspect-ratio/README.md -->
# aspect-ratio (Tier 1, CSS-only)

## Anatomy
`div.shad-aspect-ratio[style="--shad-ratio: W / H"]` – direct img/video/iframe children are absolutely filled with `object-fit: cover`.

## API
CSS custom prop `--shad-ratio` (default `16 / 9`).

## Methods / Events
None. R wrapper: `shad_aspect_ratio(ratio, content)`.
