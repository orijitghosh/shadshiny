<!-- FILE: inst/assets/components/stepper/README.md -->
# stepper (Tier 2, V2)

Multi-step progress indicator with optional content panels.

## Anatomy
```
div.shad-stepper[data-shad=stepper]
│    [data-orientation=horizontal|vertical] [data-linear] [data-clickable] [data-active=N]
├─ ol.shad-stepper__list
│  └─ li.shad-stepper__item[data-state=inactive|active|complete|error]
│     ├─ button.shad-stepper__trigger[aria-current=step?]
│     │  ├─ span.shad-stepper__indicator
│     │  │  ├─ span.shad-stepper__number
│     │  │  ├─ svg.shad-stepper__check (drawn on complete, pathLength=1)
│     │  │  └─ svg.shad-stepper__x     (shown on error)
│     │  └─ span.shad-stepper__meta > __label [+ __description]
│     └─ span.shad-stepper__connector[aria-hidden]
└─ div.shad-stepper__panels           (optional)
   └─ div.shad-stepper__panel[data-state=open|closed]   (one per step, in order)
```

## Data-attribute API
| Attribute | On | Effect |
|---|---|---|
| `data-orientation` | root | `horizontal` (default) / `vertical` |
| `data-active="N"` | root | initial step index (0-based) |
| `data-clickable` | root | triggers become interactive |
| `data-linear` | root | clicks capped at first incomplete step (active+1) |
| `data-state="error"` | item (seed) | preserved until that step is revisited |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | active step index |
| `setValue(i)` / `goTo(i)` | jump (clamped; linear rules apply) |
| `next()` / `prev()` | sequential nav |
| `setError(i, on)` | mark/clear an error step |
| `destroy()` | unbind |
| `shad:change` | `{value: stepIndex}` |

## Keyboard
Clickable triggers are real buttons – Tab reaches each enabled trigger, Enter/Space activates. In linear mode unreachable steps are `disabled` (skipped by Tab). Non-clickable steppers remove triggers from the tab order.

## A11y
`aria-current="step"` on the active trigger; connectors and indicator icons are `aria-hidden`; state is conveyed by the label + `data-state` styling and, for errors, the description text. Panels show/hide with `hidden` + a fade honored by `prefers-reduced-motion`.
