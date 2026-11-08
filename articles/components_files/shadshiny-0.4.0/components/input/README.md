<!-- FILE: inst/assets/components/input/README.md -->
# input (Tier 2, no JS file – native control)

## Anatomy
`input.shad-input[type=text|email|password|number|file|...]`

## States
- `disabled` – dimmed, no pointer events
- `aria-invalid="true"` – destructive border + destructive focus ring

## Methods / Events
Native `input`/`change` events; value via `.value`. Shiny binds like a plain text input. R wrapper: `shad_input(inputId, label, value, placeholder, type, disabled)` (composes with form-field).

## Keyboard
Native.
