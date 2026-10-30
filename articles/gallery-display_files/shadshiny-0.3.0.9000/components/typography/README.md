<!-- FILE: inst/assets/components/typography/README.md -->
# typography (Tier 1, CSS-only)

Rules live in `core/shad-base.css` (loaded everywhere); `typography.css` here is a documented stub — see its header.

## Classes
| Class | Use |
|---|---|
| `shad-h1` … `shad-h4` | headings (h2 carries a bottom hairline) |
| `shad-p` | body paragraph (adjacent `shad-p`s get top margin) |
| `shad-lead` | intro paragraph, muted xl |
| `shad-large` / `shad-small` | emphasized / compact labels |
| `shad-muted` | secondary text |
| `shad-blockquote` | left-bordered italic quote |
| `shad-code` | inline code chip |
| `shad-kbd` | keyboard key chip |
| `shad-list` | disc list with spacing |

## Methods / Events
None. R wrappers: `shad_h1()` … `shad_muted()` etc., thin `tags$*` + class.
