<!-- FILE: inst/assets/components/separator/README.md -->
# separator (Tier 1, CSS-only)

## Anatomy
`div.shad-separator[data-orientation="horizontal|vertical"]`

## Data-attribute API
| Attribute | Values | Effect |
|---|---|---|
| `data-orientation` | `horizontal` (default) / `vertical` | axis |

## Methods / Events
None. R wrapper: `shad_separator(orientation, decorative)`.

## A11y
Semantic: `role="separator"` + `aria-orientation`. Decorative: `aria-hidden="true"`, no role.
