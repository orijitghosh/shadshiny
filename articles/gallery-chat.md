# Gallery: chat & AI kit

The chat kit is a small set of composable pieces for building assistant
and messaging UIs: **bubbles** carry text, **messages** wrap a bubble
with an avatar and metadata, **attachments** show files, **markers**
annotate the stream, and the **scroller** keeps a growing transcript
pinned to the bottom. The [support-chat
example](https://github.com/orijitghosh/shadshiny/tree/main/inst/examples/03-support-chat)
wires them into a working inbox.

## Bubble

The atom of a conversation. `variant` sets the surface; `align` places
it left (received) or right (sent).

Hey! Are we still on for 3pm?

Absolutely — see you then.

Code


    shad_bubble("Hey! Are we still on for 3pm?", align = "start")
    shad_bubble("Absolutely — see you then.", variant = "tinted", align = "end")

## Message

A bubble with an avatar, sender name and timestamp. Group consecutive
turns with
[`shad_message_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_message.md).

You

You 9:41 AM

Can you summarise the Q3 report?

AI

Assistant 9:41 AM

Revenue rose 12% to \$4.2M, driven by the new tier.

Code


    shad_message_group(shad_message(shad_bubble("Can you summarise the Q3 report?"), align = "start", avatar = shad_avatar(fallback = "You"), sender = "You", meta = "9:41 AM"), shad_message(shad_bubble("Revenue rose 12% to $4.2M, driven by the new tier."), align = "start", avatar = shad_avatar(fallback = "AI"), sender = "Assistant", meta = "9:41 AM"))

## Typing indicator

[`shad_message_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_spinner.md)
is the animated three-dot “typing…” bubble, shown while a reply streams
in.

AI

Assistant

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMSAxMmE5IDkgMCAxIDEtNi4yMTktOC41NiIgLz48L3N2Zz4=)

Code


    shad_message(shad_message_spinner(), align = "start", avatar = shad_avatar(fallback = "AI"), sender = "Assistant")

## Marker

A slim inline annotation for the stream — a date break, a “streaming…”
cue, or a status note.

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik04IDJ2NCIgLz48cGF0aCBkPSJNMTYgMnY0IiAvPjxyZWN0IHdpZHRoPSIxOCIgaGVpZ2h0PSIxOCIgeD0iMyIgeT0iNCIgcng9IjIiIC8+PHBhdGggZD0iTTMgMTBoMTgiIC8+PC9zdmc+)
Today

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMSAxMmE5IDkgMCAxIDEtNi4yMTktOC41NiIgLz48L3N2Zz4=)
Generating response

Code


    shad_marker("Today", icon = "calendar")
    shad_marker("Generating response", icon = "loader", streaming = TRUE)

## Attachment

A file card with title, size, a media thumbnail slot and actions. Group
several with
[`shad_attachment_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_attachment.md).

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xNSAySDZhMiAyIDAgMCAwLTIgMnYxNmEyIDIgMCAwIDAgMiAyaDEyYTIgMiAwIDAgMCAyLTJWN1oiIC8+PHBhdGggZD0iTTE0IDJ2NGEyIDIgMCAwIDAgMiAyaDQiIC8+PC9zdmc+)

quarterly-report.pdf

2.4 MB

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIHNoYWQtaWNvbi0tc20iIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTUgMTJoMTQiIC8+PHBhdGggZD0ibTEyIDUgNyA3LTcgNyIgLz48L3N2Zz4=)

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xNSAySDZhMiAyIDAgMCAwLTIgMnYxNmEyIDIgMCAwIDAgMiAyaDEyYTIgMiAwIDAgMCAyLTJWN1oiIC8+PHBhdGggZD0iTTE0IDJ2NGEyIDIgMCAwIDAgMiAyaDQiIC8+PC9zdmc+)

budget.xlsx

845 KB · uploading

Code


    shad_attachment_group(shad_attachment(title = "quarterly-report.pdf", description = "2.4 MB", media = "file", media_variant = "icon", actions = shad_attachment_action(icon = "arrow-right", aria_label = "Download")), shad_attachment(title = "budget.xlsx", description = "845 KB · uploading", media = "file", media_variant = "icon", state = "uploading"))

## Message scroller

[`shad_message_scroller()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller.md)
is a fixed-height transcript that sticks to the bottom as content
arrives, with a “jump to latest” affordance. Append to it and pin it
from the server with
[`shad_message_scroller_to_bottom()`](https://orijitghosh.github.io/shadshiny/reference/shad_message_scroller_to_bottom.md).

AI

Assistant

Welcome to support — how can I help?

You

You

My invoice looks wrong.

AI

Assistant

I can help with that. What's the invoice number?

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIHNoYWQtaWNvbi0tc20iIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTEyIDV2MTQiIC8+PHBhdGggZD0ibTE5IDEyLTcgNy03LTciIC8+PC9zdmc+)
Jump to latest

Code


    shad_message_scroller("demo_scroller", height = "16rem", auto_scroll = TRUE, shad_message_scroller_item(shad_message(shad_bubble("Welcome to support — how can I help?"), align = "start", avatar = shad_avatar(fallback = "AI"), sender = "Assistant")), shad_message_scroller_item(shad_message(shad_bubble("My invoice looks wrong.", variant = "tinted"), align = "end", avatar = shad_avatar(fallback = "You"), sender = "You")), shad_message_scroller_item(shad_message(shad_bubble("I can help with that. What's the invoice number?"), 
        align = "start", avatar = shad_avatar(fallback = "AI"), sender = "Assistant")))
