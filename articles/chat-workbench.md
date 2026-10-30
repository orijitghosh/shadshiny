# Structured chat workbench

[`shad_chat_workbench_ui()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_workbench_ui.md)
and
[`shad_chat_workbench_server()`](https://orijitghosh.github.io/shadshiny/reference/shad_chat_workbench_server.md)
are experimental, provider-neutral modules for public structured
assistant output. They do not make network calls or select a
model/provider.

``` r

events <- function(prompt, history) {
  list(
    list(type = "text_delta", text = paste("You asked:", prompt$text)),
    list(type = "source", title = "Documentation", url = "https://example.org"),
    list(type = "status", text = "Public summary only"),
    list(type = "done")
  )
}
```

The handler receives `prompt`, a list containing text and public
attachment metadata (`name`, `size`, and MIME `type`), plus prior
structured messages. Native Shiny upload paths are never passed to the
browser transcript. Assistant text, tool content, attachment names, and
source titles are escaped; source URLs must use `https` or `http`. Do
not place private reasoning or operator diagnostics in events. Use
`status` only for provider-returned user-facing progress or summaries.

Retries add a new immutable response version; selecting a prior version
only changes presentation and does not call the provider again.
