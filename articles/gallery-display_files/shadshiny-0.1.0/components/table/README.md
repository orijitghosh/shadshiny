<!-- FILE: inst/assets/components/table/README.md -->
# table (Tier 1, CSS-only)

## Anatomy
```
div.shad-table-container            (scroll wrapper; set max-height for sticky)
└─ table.shad-table[.shad-table--hover][.shad-table--striped][.shad-table--sticky]
   ├─ caption.shad-table__caption
   ├─ thead.shad-table__header > tr.shad-table__row > th.shad-table__head
   ├─ tbody.shad-table__body   > tr.shad-table__row > td.shad-table__cell
   └─ tfoot.shad-table__footer > tr.shad-table__row > td.shad-table__cell
```

## Modifier classes
`--hover` row hover tint · `--striped` zebra rows · `--sticky` sticky thead (container needs max-height).

## Data-attribute API
`data-state="selected"` on a row → muted background.

## Methods / Events
None. R wrapper: `shad_table(df, hover, striped, sticky, caption)`.

## A11y
Native table semantics; `scope="col"` on headers; caption for context.
