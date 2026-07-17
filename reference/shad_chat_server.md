# Chat server

The server half of the chat module. Wires the composer to `handler` and
streams replies into the transcript.

## Usage

``` r
shad_chat_server(id, handler, markdown = TRUE)
```

## Arguments

- id:

  Module id (matching
  [`shad_chat_ui()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_ui.md)).

- handler:

  The reply function (see Details).

- markdown:

  If `TRUE` (default), render assistant replies as Markdown.

## Value

A list with `messages` (a reactive of the transcript), `clear()`, and
`append(role, content)`.

## Details

`handler` is `function(user_text, history)` returning one of:

- a character string — the complete reply;

- a function of no arguments returning the next chunk, or `NULL` when
  done (the simple streaming protocol);

- a coro generator (e.g. an ellmer `chat$stream()`), drained the same
  way.

`history` is the list of prior messages (`list(role, content)`).

## See also

Other shadshiny chat:
[`shad_chat_ui()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_ui.md)

## Examples

``` r
if (interactive()) {
  shad_chat_server("chat", function(user_text, history) {
    paste("You said:", user_text)
  })
}
```
