# Chat server

The server half of the chat module. Wires the composer to `handler` and
streams replies into the transcript.

## Usage

``` r
shad_chat_server(id, handler, markdown = TRUE, allow_html = FALSE)
```

## Arguments

- id:

  Module id (matching
  [`shad_chat_ui()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_ui.md)).

- handler:

  The reply function (see Details).

- markdown:

  If `TRUE` (default), render assistant replies as Markdown.

- allow_html:

  If `TRUE`, allow raw HTML in assistant Markdown. Defaults to `FALSE`;
  only use with trusted content.

## Value

A list with `messages` (a reactive of the transcript), `busy` (a
read-only reactive), `clear()`, `cancel()`, and `append(role, content)`.
`clear()` also cancels an in-flight stream; `cancel()` stops only the
in-flight stream.

## Details

`handler` is `function(user_text, history)` returning one of:

- a character string — the complete reply;

- a function of no arguments returning the next chunk, or `NULL` when
  done (the simple streaming protocol);

- a coro generator (e.g. an ellmer `chat$stream()`), drained the same
  way. Live provider integrations such as ellmer are experimental.

`history` is the list of prior messages (`list(role, content)`).

Raw HTML in assistant Markdown is escaped by default. Set
`allow_html = TRUE` only when every reply is trusted
developer-controlled content; never enable it for user or LLM output.
Stream failures emit a warning and append a fixed user-safe error
message without exposing the underlying condition.

## See also

Other shadshiny chat:
[`shad_chat_ui()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_ui.md)

## Examples

``` r
if (interactive()) {
  ui <- page_shad(shad_chat_ui("chat"))
  server <- function(input, output, session) {
    shad_chat_server("chat", function(user_text, history) {
      paste("You said:", user_text)
    })
  }
  shiny::shinyApp(ui, server)
}
```
