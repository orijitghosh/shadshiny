<!-- FILE: inst/assets/components/message/README.md -->
# message (Tier 1, CSS-only — composes bubble)

Load `bubble/bubble.css` before `message.css`; the bubble surface inside a message is a plain `.shad-bubble`.

## Anatomy
```
div.shad-message-group                                        (optional wrapper)
└─ div.shad-message[.shad-message--start|--end][data-state]
   ├─ div.shad-message__avatar                                (img | initials; anchors to row bottom)
   └─ div.shad-message__content
      ├─ div.shad-message__header
      │  ├─ span.shad-message__sender
      │  └─ span                                              (meta: time, badge…)
      ├─ div.shad-bubble.shad-bubble--{variant}
      │  └─ div.shad-bubble__content
      │     └─ span.shad-message__typing > span ×3            (typing state only)
      └─ div.shad-message__footer                             (status text, .shad-message__spinner, retry action…)
```

## Modifier classes
- Alignment: `shad-message--start` (received; avatar inline-start) | `shad-message--end` (sent; row-reversed, content right-aligned)
- `shad-message__spinner` — wraps an svg, spins (in-progress)
- In `shad-message-group`, rows after the first hide header + avatar (width preserved for bubble alignment)

## Data-attribute API
| Attribute | Effect |
|---|---|
| `data-state="typing"` | pair with a `__typing` dots bubble |
| `data-state="in-progress"` | pair with `__spinner` in the footer |
| `data-state="failed"` | destructive tint on bubble + footer |

## Methods / Events
None — display-only. R wrapper: `shad_message(..., align = c("start", "end"), avatar = NULL, sender = NULL, meta = NULL, footer = NULL, state = NULL, bubble_variant = "muted")` + `shad_message_group(...)`.

## Keyboard
None of its own; footer actions (retry buttons) keep native tab order.

## A11y
- Sender is conveyed in `__header` text, not by alignment alone.
- Avatar `img` needs empty `alt=""` when the sender is named in the header (avoid double announcement).
- Typing dots are decorative — put `aria-label="Typing"` (or `role="status"` + visually hidden text) on the typing bubble.
- The footer height shifts the avatar via `:has()` — pure CSS, nothing announced.
