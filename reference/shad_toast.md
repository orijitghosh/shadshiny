# Show a toast notification

Sonner-style imperative toasts, driven from the server. Returns the
toast id so you can later `shad_toast_update()` or
`shad_toast_dismiss()` it (e.g. a loading toast that resolves to
success).

## Usage

``` r
shad_toast(
  message = NULL,
  title = NULL,
  description = NULL,
  variant = c("default", "success", "error", "warning", "loading"),
  duration = 5000,
  id = NULL,
  action_label = NULL,
  action_input = NULL,
  session = shiny::getDefaultReactiveDomain()
)

shad_toast_success(message, ...)

shad_toast_error(message, ...)

shad_toast_warning(message, ...)

shad_toast_loading(message, ...)

shad_toast_update(
  id,
  message = NULL,
  title = NULL,
  description = NULL,
  variant = NULL,
  duration = NULL,
  action_label = NULL,
  action_input = NULL,
  session = shiny::getDefaultReactiveDomain()
)

shad_toast_dismiss(id = NULL, session = shiny::getDefaultReactiveDomain())
```

## Arguments

- message:

  Main message text (used as the title if `title` is `NULL`).

- title, description:

  Optional title / secondary line.

- variant:

  One of `"default"`, `"success"`, `"error"`, `"warning"`, `"loading"`.
  `"loading"` toasts never auto-dismiss until updated.

- duration:

  Auto-dismiss delay in ms (default 5000).

- id:

  Toast id. Generated if `NULL`.

- action_label:

  Optional action-button label.

- action_input:

  Input id set (to `Date.now()`) when the action is clicked, giving the
  server a reactive hook. Defaults to `<id>_action`.

- session:

  The Shiny session.

- ...:

  Passed to `shad_toast()`.

## Value

The toast id (character), invisibly.

## Details

Text is injected client-side via `textContent`; pass plain strings, not
HTML. There is no R analogue of `shad.toast.promise()` — use the loading
→ `shad_toast_update()` flow instead.

## See also

Other shadshiny server API:
[`bind_shad_task_button()`](https://orijitghosh.github.io/shadshiny/reference/bind_shad_task_button.md),
[`shad_message_scroller_to_bottom()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller_to_bottom.md),
[`shad_overlay_server`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md),
[`shad_remove_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_remove_dialog.md),
[`shad_show_dialog()`](https://orijitghosh.github.io/shadshiny/reference/shad_show_dialog.md),
[`update_shad`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md),
[`update_shad_command()`](https://orijitghosh.github.io/shadshiny/reference/update_shad_command.md)

## Examples

``` r
if (FALSE) { # \dontrun{
shad_toast("Saved", variant = "success")
id <- shad_toast_loading("Uploading...")
shad_toast_update(id, message = "Uploaded", variant = "success")
} # }
```
