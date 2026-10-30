<!-- FILE: inst/assets/components/alert/README.md -->
# alert (Tier 1, CSS-only)

## Anatomy
```
div.shad-alert[.shad-alert--destructive][role=alert]
├─ svg.shad-alert__icon          (optional; grid auto-adjusts)
├─ div.shad-alert__title
└─ div.shad-alert__description   (optional)
```

## Modifier classes
`shad-alert--destructive`

## Methods / Events
None. R wrapper: `shad_alert(title, description, variant, icon)`.

## A11y
`role="alert"` for live announcements; drop it for static callouts.
