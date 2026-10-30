# Structured chat workbench UI

Experimental, provider-neutral UI for structured chat events. Pair with
[`shad_chat_workbench_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_workbench_server.md).
Native uploads are handled by Shiny; no server-side file paths are
rendered into this UI.

## Usage

``` r
shad_chat_workbench_ui(
  id,
  placeholder = "Message...",
  height = "60vh",
  welcome = NULL,
  send_label = "Send",
  accept = NULL,
  multiple = TRUE
)
```

## Arguments

- id:

  Module id.

- placeholder:

  Composer placeholder text.

- height:

  Transcript height.

- welcome:

  Optional content before the first message.

- send_label:

  Send button label.

- accept:

  Native file-input accept value.

- multiple:

  Whether native upload accepts multiple files.

## Value

A workbench UI tag.
