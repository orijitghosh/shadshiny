# Structured chat workbench server

Experimental server module accepting provider-owned structured events.
The handler receives public prompt text and attachment metadata only.

## Usage

``` r
shad_chat_workbench_server(
  id,
  handler,
  markdown = TRUE,
  allow_html = FALSE,
  render_part = NULL
)
```

## Arguments

- id:

  Module id.

- handler:

  Function of `prompt` and prior `history`.

- markdown:

  Render assistant text as safe Markdown.

- allow_html:

  Trusted-content escape hatch for assistant Markdown.

- render_part:

  Optional renderer for one validated part.

## Value

A structured transcript controller.
