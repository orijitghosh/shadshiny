<!-- FILE: inst/assets/components/toast/README.md -->
# toast (Tier 3)

Sonner-style imperative toast system. **No `data-shad` markup** — call `shad.toast()`; the bottom-right container is created lazily.

## API
| Call | Description |
|---|---|
| `shad.toast(msg\|opts)` → id | opts: `{title, description, variant, duration, action:{label,onClick}}` |
| `shad.toast.success/error/warning/loading(msg, opts?)` → id | variant shorthands |
| `shad.toast.update(id, opts)` | re-render + re-arm timer (loading → success flow) |
| `shad.toast.dismiss(id?)` | one or all |
| `shad.toast.promise(p, {loading, success, error})` → p | loading toast that resolves; success/error may be `fn(value)` |

## Behavior decisions
- Default duration **5000 ms**; `loading` never auto-dismisses (until updated).
- Max **3** visible collapsed; rear cards peek 12 px and scale −5 % each; extra are hidden but queued.
- **Hover fans the stack** and pauses ALL timers (remaining time preserved); leave resumes.
- **Swipe right** dismisses at > 80 px travel or > 0.3 px/ms velocity; left drag rubber-bands.
- Exit animates before removal (Presence). Titles/descriptions injected via `textContent` (no HTML injection).

## Events
None on document — toasts are fire-and-forget UI. Action buttons call your `onClick`.

## A11y
Container `aria-live=polite`; error toasts `role=alert`, others `role=status`; close button labelled.
