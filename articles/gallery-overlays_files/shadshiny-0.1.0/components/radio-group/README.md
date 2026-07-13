<!-- FILE: inst/assets/components/radio-group/README.md -->
# radio-group (Tier 2)

## Anatomy
```
div.shad-radio-group[data-shad=radio-group][role=radiogroup][data-orientation]
└─ div.shad-radio-row × n
   ├─ button.shad-radio[role=radio][data-value][data-state]
   │  └─ span.shad-radio__indicator
   └─ label.shad-label
```

## Data-attribute API
| Attribute | On | Values |
|---|---|---|
| `data-orientation` | group | `vertical` (default) / `horizontal` (layout only) |
| `data-value` | item | option value |
| `data-state` | item | `checked` / `unchecked` |
| `data-disabled` + `disabled` | item | skip in nav |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | selected `data-value` or `null` |
| `setValue(v)` | select by value; emits |
| `destroy()` | unbind |
| `shad:change` | `{value}` |

## Keyboard (APG radio)
Arrows (all four) move focus AND select, looping; Home/End first/last; Space selects focused; Tab enters on the checked item (roving tabindex).
