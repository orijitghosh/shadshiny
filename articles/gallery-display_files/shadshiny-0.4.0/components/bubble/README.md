<!-- FILE: inst/assets/components/bubble/README.md -->
# bubble (Tier 1, CSS-only)

## Anatomy
```
div.shad-bubble-group[.shad-bubble-group--start|--end]        (optional wrapper)
└─ div.shad-bubble.shad-bubble--{variant}[.shad-bubble--start|--end]
   ├─ div.shad-bubble__content                                (text / rich content)
   └─ div.shad-bubble__reactions[data-side][data-align]       (optional, overhangs)
      └─ span.shad-bubble__reaction                           (overlapping chips)
```

## Modifier classes
- Variants: `shad-bubble--default | --secondary | --muted | --tinted | --outline | --ghost | --destructive`
- Alignment: `shad-bubble--start` (received) | `shad-bubble--end` (sent); on `shad-bubble-group` the same `--start`/`--end` aligns all children
- Ghost is full-width with no inline padding (assistant prose); all others cap at 80% of the container

## Data-attribute API
| Attribute | On | Effect |
|---|---|---|
| `data-side="start\|end"` | `__reactions` | inline side the chips anchor to (default start) |
| `data-align="top\|bottom"` | `__reactions` | block edge the chips overhang (default bottom) |

## Methods / Events
None — display-only. R wrapper: `shad_bubble(..., variant = "default", align = c("start", "end"), reactions = NULL)` + `shad_bubble_group(..., align = "start")`.

## Keyboard
None — static content. Interactive reactions should be rendered as `<button class="shad-bubble__reaction">`.

## A11y
- Alignment is visual; reading order stays DOM order. Convey the sender in text (see `message`), not by position alone.
- Reaction chips: give a count + emoji an `aria-label` ("2 thumbs up").
- Consecutive-bubble radius tightening is purely decorative.
