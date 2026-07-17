# Chat UI

The UI half of a streaming chat module: a stick-to-bottom transcript
plus a composer (auto-sizing textarea + send button). Pair with
[`shad_chat_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_server.md).

## Usage

``` r
shad_chat_ui(
  id,
  placeholder = "Message...",
  height = "60vh",
  welcome = NULL,
  send_label = "Send"
)
```

## Arguments

- id:

  Module id.

- placeholder:

  Composer placeholder text.

- height:

  Transcript height (CSS unit).

- welcome:

  Optional tags shown before the first message (empty state).

- send_label:

  Accessible label for the send button.

## Value

A chat UI tag.

## See also

Other shadshiny chat:
[`shad_chat_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_server.md)

## Examples

``` r
if (interactive()) shad_chat_ui("chat", height = "60vh")
```
