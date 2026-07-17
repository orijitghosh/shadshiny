<!-- FILE: inst/assets/components/slider/README.md -->
# slider (Tier 2)

## Anatomy
```
div.shad-slider[data-shad=slider][data-min][data-max][data-step]
                [data-value][data-value2?][data-marks?][data-marks-labels?]
                [data-orientation=vertical?][data-disabled?]
├─ div.shad-slider__track > div.shad-slider__range
├─ (JS-rendered) div.shad-slider__marks (dots + optional labels)
└─ div.shad-slider__thumb[role=slider][tabindex=0] × 1 or 2
```
Two thumbs (+ `data-value2`) ⇒ range slider; value is `[lo, hi]`.

## Data-attribute API
| Attribute | Effect |
|---|---|
| `data-min` / `data-max` / `data-step` | numeric domain (defaults 0/100/1) |
| `data-value` / `data-value2` | initial value(s) |
| `data-marks="0,25,50"` | tick dots; `data-marks-labels` adds text labels |
| `data-orientation="vertical"` | vertical axis |
| `data-disabled` | inert + dimmed |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | number or `[number, number]` |
| `setValue(v)` | same shape; snapped to step; emits |
| `destroy()` | unbind |
| `shad:change` | `{value}` (fires continuously during drag) |

## Keyboard (APG slider)
Arrow Right/Up +step · Arrow Left/Down −step · PageUp/Down ±10×step · Home/End min/max. Each thumb is its own tab stop; range thumbs clamp against each other.

## Pointer
Track press jumps nearest thumb and starts drag; pointer capture keeps drag outside bounds; `touch-action: none`.
