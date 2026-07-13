<!-- FILE: inst/assets/components/avatar/README.md -->
# avatar (Tier 1, CSS-only)

## Anatomy
```
span.shad-avatar[.shad-avatar--sm|--lg|--xl]
├─ span.shad-avatar__fallback     (initials; sits under image)
└─ img.shad-avatar__image         (optional; onerror="this.hidden=true")

span.shad-avatar-group > span.shad-avatar × n   (stacked, -0.5rem overlap)
```

## Modifier classes
Sizes: `--sm` 24px, default 32px, `--lg` 40px, `--xl` 64px.

## Methods / Events
None. R wrapper: `shad_avatar(src, fallback, alt, size)`, `shad_avatar_group(...)`.

## A11y
Meaningful images need `alt`; decorative fallback initials `aria-hidden="true"` when an image is present.

## Deviation
Radix delays fallback render; we layer fallback under the image + `onerror` hide — same visual result, zero JS.
