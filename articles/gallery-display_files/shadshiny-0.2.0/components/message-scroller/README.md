<!-- FILE: inst/assets/components/message-scroller/README.md -->
# message-scroller (Tier 3, +JS)

## Anatomy
```
div.shad-message-scroller[data-shad=message-scroller][data-state=following|detached]
├─ div.shad-message-scroller__viewport[aria-live=polite]      (scrollable)
│  └─ div.shad-message-scroller__content
│     └─ div.shad-message-scroller__item[data-anchor?]        (rows; messages, markers…)
└─ button.shad-message-scroller__button[data-visible?]        (jump to latest)
```

## Modifier classes
None — state is data-attribute driven.

## Data-attribute API
| Attribute | On | Effect |
|---|---|---|
| `data-auto-scroll="false"` | root | never auto-follow new content (default true) |
| `data-default-position="start\|end\|last-anchor"` | root | initial scroll position (default `end`) |
| `data-anchor` | `__item` | marks a turn boundary; `last-anchor` scrolls the last one to the top |
| `data-state="following\|detached"` | root (live, set by JS) | styling hook |
| `data-visible` | `__button` (live, set by JS) | button shown while detached |

## Methods / Events
| Member | Description |
|---|---|
| `getValue()` | `{following, atBottom, scrollTop}` position state |
| `setValue("end"\|"start")` | jump to bottom (re-attach) / top (detach) |
| `scrollToBottom(smooth = TRUE)` | re-attach + scroll; callable through the `shadshiny:invoke` channel |
| `destroy()` | disconnect observers + listeners |

No `shad:change` — position is not a form value; the Shiny binding polls `getValue()` on scroll settle if needed.

R wrapper: `shad_message_scroller(id, ..., auto_scroll = TRUE, default_position = c("end", "start", "last-anchor"), height = NULL)`.

## Behavior contract
- Sticks to the bottom ONLY while the user is at the bottom; wheel-up, ArrowUp/PageUp/Home, or selecting text detaches immediately.
- Content arriving while detached never moves the viewport — the jump button appears instead.
- Prepended history (infinite scroll) preserves the visible scroll anchor: `scrollTop` is compensated by the height delta in the same frame.
- Uses one ResizeObserver (content growth) + one MutationObserver (prepend detection); no external libs.

## Keyboard
Viewport is natively scrollable (arrows/PageUp/PageDown/Home when focused); End re-attaches to the bottom. The jump button is a plain focusable `<button>`.

## A11y
- `aria-live="polite"` on the viewport announces appended messages without stealing focus.
- Give the jump button a label ("Jump to latest") — icon-only needs `aria-label`.
- Smooth scrolling is disabled under `prefers-reduced-motion`.
