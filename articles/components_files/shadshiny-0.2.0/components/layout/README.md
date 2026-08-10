<!-- FILE: inst/assets/components/layout/README.md -->
# layout (CSS-only)

Container / stack / grid primitives plus the chrome for the two page shells. No
JS, no state, no Shiny binding — every knob is a custom property set inline by
the R constructor.

## Anatomy
- `div.shad-container[.shad-container--full|--flush]` — `--shad-container-max`, `--shad-container-pad`
- `div.shad-stack[.shad-stack--wrap|--fill]` — `--shad-stack-dir|-gap|-align|-justify`
- `div.shad-grid[.shad-grid--auto|--template]` — `--shad-grid-gap|-align|-min|-template`, `--shad-grid-cols[-sm|-md|-lg]`
- `div.shad-grid__item[.shad-grid__item--full]` — `--shad-span`
- `div.shad-page[.shad-page--sidebar|--navbar]` > `header.shad-page__bar[.shad-page__bar--sticky]` (`.shad-page__title`, `.shad-page__bar-end`) + `div.shad-page__main`

## Breakpoints
sm 40rem · md 48rem · lg 64rem. The column chain falls back outward
(`lg → md → sm → base → 1`) via nested `var()` defaults, so only the
breakpoints you name emit a value.

`.shad-grid--auto` and `.shad-grid--template` are declared **after** the media
queries: equal specificity, later source order, so they win at every width.

## A11y
Nothing to wire — these are presentational wrappers. The navbar shell keeps the
`data-shad="tabs"` element as its root so the tabs component's root-scoped
queries, roles and input binding are unaffected by the bar sitting between the
root and the tab list.
