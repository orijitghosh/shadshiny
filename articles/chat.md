# Streaming chat

shadshiny ships two levels of chat. The **chat kit**
([`shad_bubble()`](https://orijitghosh.github.io/shadshiny/reference/shad_bubble.md),
[`shad_message()`](https://orijitghosh.github.io/shadshiny/reference/shad_message.md),
[`shad_message_scroller()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller.md),
[`shad_attachment()`](https://orijitghosh.github.io/shadshiny/reference/shad_attachment.md),
[`shad_marker()`](https://orijitghosh.github.io/shadshiny/reference/shad_marker.md))
is a set of transcript primitives you compose yourself – see [Gallery:
chat](https://orijitghosh.github.io/shadshiny/articles/gallery-chat.html).
This guide is about the level above it:
[`shad_chat_ui()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_ui.md)
/
[`shad_chat_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_server.md),
a Shiny module that gives you the whole thing – scroller, composer,
streaming, Markdown – for two calls.

## The whole app

``` r

library(shiny)
library(shadshiny)

ui <- page_shad(
  div(style = "max-width:44rem;margin:0 auto;",
    shad_chat_ui("chat", placeholder = "Ask me anything...")
  )
)

server <- function(input, output, session) {
  shad_chat_server("chat", handler = function(user_text, history) {
    paste("You said:", user_text)
  })
}

shinyApp(ui, server)
```

It is an ordinary Shiny module, so the `id` is the only wiring: pass the
same string to both halves. Nesting it inside another module works
without thought – all the namespacing is internal.

## The UI half

``` r

shad_chat_ui(
  "chat",
  placeholder = "Message...",
  height      = "60vh",
  send_label  = "Send",
  welcome     = shad_empty(
    title       = "Start the conversation",
    description = "Type a message below and press Enter."
  )
)
```

`welcome` renders while the transcript is empty and disappears on the
first message. The composer is a
[`shad_textarea()`](https://orijitghosh.github.io/shadshiny/reference/shad_textarea.md)
that grows with the content; **Enter sends, Shift+Enter inserts a
newline**. The scroller sticks to the bottom while streaming unless the
user has scrolled up – then it stays put, which is what you want when
someone is reading back.

## The handler

`handler` is `function(user_text, history)`, where `history` is the
transcript so far as a list of `list(role, content)` with `role` being
`"user"` or `"assistant"`. It may return any of three things.

**A string** – the complete reply, rendered at once:

``` r

function(user_text, history) {
  paste("You said:", user_text)
}
```

**A chunk function** – a function of no arguments returning the next
piece of text, or `NULL` when done. This is the simple streaming
protocol:

``` r

function(user_text, history) {
  words <- strsplit("A reply that arrives one word at a time.", " ")[[1]]
  i <- 0L
  function() {
    i <<- i + 1L
    if (i > length(words)) NULL else paste0(if (i > 1) " ", words[i])
  }
}
```

**A coro generator** – drained the same way, which is what makes
`ellmer` a one-liner. Live provider integrations like this one are
experimental: they depend on the provider’s package and API, and may
change before a stable 1.0 release.

``` r

chat <- ellmer::chat_openai(model = "gpt-4o-mini")

shad_chat_server("chat", handler = function(user_text, history) {
  chat$stream(user_text)     # a coro generator; streams straight through
})
```

That chat object keeps its own conversation state, so you can ignore
`history` there. Use `history` when you’re calling an API yourself and
need to send the prior turns along.

Chunks are pulled on a short timer and appended to the partial reply, so
the transcript renders progressively. Because the pump runs in the Shiny
event loop, a chunk function that blocks blocks the whole session –
never [`Sys.sleep()`](https://rdrr.io/r/base/Sys.sleep.html) inside one,
and never do a synchronous HTTP call per chunk.

## The returned object

``` r

server <- function(input, output, session) {
  chat <- shad_chat_server("chat", handler = my_handler)

  observeEvent(input$clear, chat$clear())

  observeEvent(input$greet, {
    chat$append("assistant", "Hi! What can I help with?")
  })

  output$n <- renderText(sprintf("%d messages", length(chat$messages())))
}
```

| Member | Is |
|----|----|
| `messages()` | A reactive holding the transcript: a list of `list(role, content)`. |
| `clear()` | Empty the transcript and drop any in-flight reply. |
| `busy()` | A read-only reactive that is `TRUE` while a reply is streaming. |
| `cancel()` | Stop an in-flight reply without clearing existing messages. |
| `append(role, content)` | Push a message in directly, without going through the handler. |

[`append()`](https://rdrr.io/r/base/append.html) is how you seed an
opening line, replay a saved conversation, or inject a system notice
mid-thread.

## Utility elements for transcripts

Use shad_code_block() for escaped fenced source shown in a transcript or
tool result, and shad_shimmer() for a temporary loading label. The
latter remains ordinary readable text when inactive or when reduced
motion is requested.

~{r} shad_shimmer(“Thinking…”, active = TRUE) shad_code_block( ‘answer
\<- model\$complete(prompt)’, language = “r”, filename = “tool.R”, copy
= TRUE ) ~

## Markdown

Assistant replies render as Markdown by default – bold, italics, links,
code spans, and fenced code blocks. Raw HTML inside that Markdown is
escaped. User messages are also escaped and rendered literally, so
neither side can inject markup into your page by default.

Turn it off with `markdown = FALSE` and assistant text is escaped too:

``` r

shad_chat_server("chat", handler = my_handler, markdown = FALSE)
```

For trusted, developer-controlled replies only, raw HTML can be enabled
with `allow_html = TRUE`. Never enable it for user or LLM output: model
output is untrusted input even when Markdown rendering is useful.

If a streaming generator fails, the server emits a warning for
operators, cancels the stream, and shows a fixed safe error message. The
underlying error is never copied into the transcript.

## Try it

``` r

shad_run_example("08-llm-chat")
```

Runs offline against a fake token-streaming model, with the experimental
`ellmer` swap commented in the source.

## See also

- [Gallery:
  chat](https://orijitghosh.github.io/shadshiny/articles/gallery-chat.html)
  – the primitives, if you want to build a transcript by hand instead.
