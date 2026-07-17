<!-- FILE: inst/assets/components/tree/README.md -->
# tree (Tier 2, V2)

File-explorer TreeView per the APG pattern. Reuses `shad.roving` from the runtime (arrows/Home/End/typeahead).

## Anatomy
```
div.shad-tree[data-shad=tree][data-selection=single|multiple]
└─ ul.shad-tree__list[role=tree][aria-label][aria-multiselectable?]
   └─ li.shad-tree__item[role=treeitem][data-key]
      │    [aria-expanded=true|false (branches only)] [aria-disabled] [data-lazy]
      │    (JS sets aria-level, aria-selected, tabindex, data-state=selected)
      ├─ div.shad-tree__row
      │  ├─ svg.shad-tree__chevron[--leaf on leaves]   (rotates 90° when expanded)
      │  ├─ span.shad-tree__icon (optional)
      │  └─ span.shad-tree__label
      └─ ul.shad-tree__group[role=group]   (children; indent guide hairline)
```
Branch = item with `aria-expanded`. Lazy branch = `data-lazy` with no group: expanding injects a spinner row and emits `shad:expand`; the host answers with `setChildren`.

## Data-attribute API
| Attribute | On | Effect |
|---|---|---|
| `data-selection` | root | `single` (default) / `multiple` |
| `data-key` | item | row identity in values/events |
| `aria-expanded` | item | marks a branch + its open state |
| `data-lazy` | item | children fetched on first expand |
| `aria-disabled="true"` | item | unselectable, skipped by roving |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | selected keys `[]` |
| `setValue(keys)` | replace selection; emits |
| `setChildren(key, html)` | fill a lazy branch (HTML string or nodes); `[]` ⇒ becomes a leaf |
| `expand(key, on)` | programmatic expand/collapse |
| `destroy()` | unbind |
| `shad:change` | `{value: selectedKeys}` |
| `shad:expand` | `{key, expanded}` — also the lazy-load request signal |

## Keyboard
Up/Down move (roving tabindex), Home/End jump, typeahead (1 s buffer). Right: expand, or move into first child. Left: collapse, or move to parent. Enter/Space: select (Ctrl/Cmd toggles in multiple mode).

## Pointer
Chevron click or double-click toggles a branch; single click on a branch row toggles **and** selects (file-explorer feel); Ctrl/Cmd+click toggles membership in multiple mode.

## A11y
`role=tree/group/treeitem`, `aria-level` computed, `aria-expanded`/`aria-selected` managed, one item at `tabindex=0`. Add `aria-multiselectable="true"` to the `role=tree` list in multiple mode (markup-side). Spinner row is `role=presentation`.
