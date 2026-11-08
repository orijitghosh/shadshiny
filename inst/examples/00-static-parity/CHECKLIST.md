# Static-parity acceptance checklist

Visual acceptance for the framework-free CSS/JS port. Run this example next to
the canonical static reference and, for Phase 5 sign-off, next to the R-built
demo (`shad_run_example("kitchen-sink")`).

```r
# reference (this app): the hand-written anatomy demo
shadshiny::shad_run_example("00-static-parity")

# under test (Phase 5): the R-generated equivalent
shadshiny::shad_run_example("kitchen-sink")
```

Compare the two windows and tick each row. Note any pixel/behaviour drift.

## Theming

- [ ] Light mode: surfaces, borders, and text tokens match.
- [ ] Dark mode toggle recolours every component (no light-mode leaks).
- [ ] Each preset — slate, stone, zinc, mauve, olive, mist, taupe, blue, green,
      rose, violet, orange — shifts the accent consistently across buttons,
      switches, sliders, and focus rings.
- [ ] Focus-visible rings use `--shad-ring` and are keyboard-reachable.

## Overlays (one of each)

- [ ] Dialog opens/closes, traps focus, restores focus on close, Esc dismisses.
- [ ] Alert-dialog is non-dismissible on overlay click; confirm/cancel work.
- [ ] Sheet slides from the correct side; scrim covers the page.
- [ ] Drawer drags from the bottom and snaps; grab handle visible.
- [ ] Popover / tooltip / hover-card position and flip near viewport edges.

## Toasts

- [ ] Toast stack fans out on hover and collapses on leave.
- [ ] Each variant (default/success/error/warning/loading) shows its icon/colour.
- [ ] Loading → success updates in place (no duplicate toast).

## Form controls

- [ ] Checkbox / switch / radio pressed + disabled + indeterminate states.
- [ ] Slider thumb, range fill, and marks align; keyboard arrows step.
- [ ] Select / combobox open, filter, keyboard-navigate, and check the choice.
- [ ] Input-OTP segments advance and accept paste.
- [ ] Calendar / date-picker render the month grid and selection range.

## Structure & navigation

- [ ] Tabs, accordion, collapsible animate open/close.
- [ ] Pagination and carousel controls move through pages/slides.
- [ ] Sidebar collapses to icon rail and restores; mobile off-canvas works.

Record the reviewer, date, browser, and any deltas below.

| Date | Reviewer | Browser | Result | Notes |
|------|----------|---------|--------|-------|
|      |          |         |        |       |
