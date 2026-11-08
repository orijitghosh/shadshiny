# Gallery: display & typography

Everything on this page is a **real component**, rendered by the same
code you see under each preview. Expand *Code* to copy it. The previews
recolour with the light/dark switch in the navbar, exactly as they would
in your app.

These are the non-interactive building blocks – the display layer of
Tier 1. For inputs see [Gallery: form
inputs](https://orijitghosh.github.io/shadshiny/articles/gallery-inputs.md);
for dialogs and menus see [Gallery:
overlays](https://orijitghosh.github.io/shadshiny/articles/gallery-overlays.md).

## Button

The workhorse.
[`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md)
is an ordinary Shiny action button: give it an `inputId` and read clicks
with `input$id`. Six variants cover the usual intent hierarchy.

Default

Secondary

Destructive

Outline

Ghost

Link

Code


    shad_button("Default")
    shad_button("Secondary", variant = "secondary")
    shad_button("Destructive", variant = "destructive")
    shad_button("Outline", variant = "outline")
    shad_button("Ghost", variant = "ghost")
    shad_button("Link", variant = "link")

Three sizes, plus an icon-only size. Any [icon
name](https://orijitghosh.github.io/shadshiny/articles/icons.md) can
lead or trail the label.

Small

Default

Large

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik01IDEyaDE0IiAvPjxwYXRoIGQ9Ik0xMiA1djE0IiAvPjwvc3ZnPg==)

Continue
![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik01IDEyaDE0IiAvPjxwYXRoIGQ9Im0xMiA1IDcgNy03IDciIC8+PC9zdmc+)

Code


    shad_button("Small", size = "sm")
    shad_button("Default")
    shad_button("Large", size = "lg")
    shad_button(icon = "plus", size = "icon", aria_label = "Add")
    shad_button("Continue", icon = "arrow-right", icon_position = "right")

`loading = TRUE` swaps the icon for a spinner and disables the button;
toggle it from the server around a long task.

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMSAxMmE5IDkgMCAxIDEtNi4yMTktOC41NiIgLz48L3N2Zz4=)
Saving…

Disabled

Code


    shad_button("Saving…", loading = TRUE)
    shad_button("Disabled", disabled = TRUE)

## Badge

A small status pill. Same variant vocabulary as buttons.

Default Secondary Destructive Outline
![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMCA2IDkgMTdsLTUtNSIgLz48L3N2Zz4=)
Verified

Code


    shad_badge("Default")
    shad_badge("Secondary", variant = "secondary")
    shad_badge("Destructive", variant = "destructive")
    shad_badge("Outline", variant = "outline")
    shad_badge("Verified", icon = "check")

## Avatar

An image with a text fallback shown while (or if) the image fails to
load.
[`shad_avatar_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_avatar.md)
overlaps a set and can cap the overflow with `max`.

AG SK AG SK JL +1

Code


    shad_avatar(fallback = "AG")
    shad_avatar(fallback = "SK", size = "lg")
    shad_avatar_group(shad_avatar(fallback = "AG"), shad_avatar(fallback = "SK"), shad_avatar(fallback = "JL"), shad_avatar(fallback = "MC"), max = 3)

## Card

The primary surface for grouping content. Compose it from the header /
title / description / content / footer parts.

Monthly report

Revenue and active users, last 30 days.

You're up 12.4% month over month.

View report

Dismiss

Code


    shad_card(shad_card_header(shad_card_title("Monthly report"), shad_card_description("Revenue and active users, last 30 days.")), shad_card_content(shad_p("You're up 12.4% month over month.")), shad_card_footer(shad_button("View report", size = "sm"), shad_button("Dismiss", variant = "ghost", size = "sm")))

## Alert

An inline callout. Pair a variant with a matching
[icon](https://orijitghosh.github.io/shadshiny/articles/icons.md).

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1hbGVydF9faWNvbiIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxMCI+PC9jaXJjbGU+PHBhdGggZD0iTTEyIDE2di00IiAvPjxwYXRoIGQ9Ik0xMiA4aC4wMSIgLz48L3N2Zz4=)

Heads up

You can add components to your app using the CLI.

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1hbGVydF9faWNvbiIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxMCI+PC9jaXJjbGU+PGxpbmUgeDE9IjEyIiB4Mj0iMTIiIHkxPSI4IiB5Mj0iMTIiPjwvbGluZT48bGluZSB4MT0iMTIiIHgyPSIxMi4wMSIgeTE9IjE2IiB5Mj0iMTYiPjwvbGluZT48L3N2Zz4=)

Payment failed

Your card was declined. Update your billing details.

Code


    shad_alert(title = "Heads up", "You can add components to your app using the CLI.", icon = "info")
    shad_alert(title = "Payment failed", "Your card was declined. Update your billing details.", variant = "destructive", icon = "circle-alert")

## Progress & spinner

[`shad_progress()`](https://orijitghosh.github.io/shadshiny/reference/shad_progress.md)
shows determinate or indeterminate progress; drive its value from the
server with
[`update_shad_progress()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md).
[`shad_spinner()`](https://orijitghosh.github.io/shadshiny/reference/shad_spinner.md)
is a bare loading indicator in three sizes.

Code


    shad_progress(value = 32)
    shad_progress(value = 72)
    shad_progress(indeterminate = TRUE)

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zcGlubmVyIHNoYWQtc3Bpbm5lci0tc20iIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiByb2xlPSJzdGF0dXMiIGFyaWEtbGFiZWw9IkxvYWRpbmciPjxwYXRoIGQ9Ik0yMSAxMmE5IDkgMCAxIDEtNi4yMTktOC41NiIgLz48L3N2Zz4=)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zcGlubmVyIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgcm9sZT0ic3RhdHVzIiBhcmlhLWxhYmVsPSJMb2FkaW5nIj48cGF0aCBkPSJNMjEgMTJhOSA5IDAgMSAxLTYuMjE5LTguNTYiIC8+PC9zdmc+)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zcGlubmVyIHNoYWQtc3Bpbm5lci0tbGciIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiByb2xlPSJzdGF0dXMiIGFyaWEtbGFiZWw9IkxvYWRpbmciPjxwYXRoIGQ9Ik0yMSAxMmE5IDkgMCAxIDEtNi4yMTktOC41NiIgLz48L3N2Zz4=)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zcGlubmVyIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgcm9sZT0ic3RhdHVzIiBhcmlhLWxhYmVsPSJMb2FkaW5n4oCmIj48cGF0aCBkPSJNMjEgMTJhOSA5IDAgMSAxLTYuMjE5LTguNTYiIC8+PC9zdmc+)

Code


    shad_spinner(size = "sm")
    shad_spinner()
    shad_spinner(size = "lg")
    shad_spinner(label = "Loading…")

## Skeleton

A shimmer placeholder for content that hasn’t loaded yet.

Code


    tags$div(style = "display:flex;gap:0.75rem;align-items:center", shad_skeleton(width = "2.75rem", height = "2.75rem", variant = "circle"), tags$div(style = "display:grid;gap:0.5rem;flex:1", shad_skeleton(width = "60%", height = "0.85rem"), shad_skeleton(width = "40%", height = "0.85rem")))

## Table

[`shad_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_table.md)
renders a data frame with optional striping, hover, and a sticky header.

| Invoice | Status  | Amount   |
|---------|---------|----------|
| INV-001 | Paid    | \$250.00 |
| INV-002 | Pending | \$150.00 |
| INV-003 | Paid    | \$350.00 |

Code


    shad_table(data.frame(Invoice = c("INV-001", "INV-002", "INV-003"), Status = c("Paid", "Pending", "Paid"), Amount = c("$250.00", "$150.00", "$350.00"), check.names = FALSE), striped = TRUE, hover = TRUE)

## Item

[`shad_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_item.md)
is the flexible list row – media, title, description and actions – used
for settings lists, results, and menus. Group them with
[`shad_item_group()`](https://orijitghosh.github.io/shadshiny/reference/shad_item.md).

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMCAyMGEyIDIgMCAwIDAgMi0yVjhhMiAyIDAgMCAwLTItMmgtNy45YTIgMiAwIDAgMS0xLjY5LS45TDkuNiAzLjlBMiAyIDAgMCAwIDcuOTMgM0g0YTIgMiAwIDAgMC0yIDJ2MTNhMiAyIDAgMCAwIDIgMloiIC8+PC9zdmc+)

Design assets

24 files · 128 MB

Open

------------------------------------------------------------------------

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xNSAySDZhMiAyIDAgMCAwLTIgMnYxNmEyIDIgMCAwIDAgMiAyaDEyYTIgMiAwIDAgMCAyLTJWN1oiIC8+PHBhdGggZD0iTTE0IDJ2NGEyIDIgMCAwIDAgMiAyaDQiIC8+PC9zdmc+)

brand-guidelines.pdf

2.4 MB

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjEyIiBjeT0iMTIiIHI9IjEiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjE5IiBjeT0iMTIiIHI9IjEiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjUiIGN5PSIxMiIgcj0iMSI+PC9jaXJjbGU+PC9zdmc+)

Code


    shad_item_group(shad_item(title = "Design assets", description = "24 files · 128 MB", media = "folder", media_variant = "icon", actions = shad_button("Open", variant = "outline", size = "sm")), shad_item_separator(), shad_item(title = "brand-guidelines.pdf", description = "2.4 MB", media = "file", media_variant = "icon", actions = shad_button(icon = "more-horizontal", size = "icon", variant = "ghost", aria_label = "More")))

## Empty state

[`shad_empty()`](https://orijitghosh.github.io/shadshiny/reference/shad_empty.md)
fills the void when a list or search has no results.

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjExIiBjeT0iMTEiIHI9IjgiPjwvY2lyY2xlPjxwYXRoIGQ9Im0yMSAyMS00LjMtNC4zIiAvPjwvc3ZnPg==)

No results found

Try adjusting your filters or search terms.

Clear filters

Code


    shad_empty(title = "No results found", description = "Try adjusting your filters or search terms.", media = "search", media_variant = "icon", content = shad_button("Clear filters", variant = "outline", size = "sm"))

## kbd & code

Inline helpers for keyboard shortcuts and code fragments.

⌘ K
[`shad_button()`](https://orijitghosh.github.io/shadshiny/reference/shad_button.md)

Code


    shad_kbd("⌘")
    shad_kbd("K")
    shad_code("shad_button()")

Keyboard shortcuts, source snippets, loading text, and long content can
use the four utility elements below. Code is displayed as escaped text
and can be copied without including line numbers.

~{r} demo({ shad_kbd_group(shad_kbd(“⌘”), shad_kbd(“K”))
shad_code_block( ‘shad_button(“Run”)’, language = “r”, filename =
“app.R”, line_numbers = TRUE ) shad_scroll_fade(
shad_p(paste(rep(“Scrollable utility content.”, 8), collapse = ” “)),
axis =”vertical”, style = “max-height: 6rem;” )
shad_shimmer(“Thinking…”, active = TRUE) }) ~

## Typography

A tuned type scale.
[`shad_h1()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md)–[`shad_h4()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md),
[`shad_p()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md),
[`shad_lead()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md),
[`shad_large()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md),
[`shad_small()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md),
[`shad_muted()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md),
[`shad_blockquote()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md),
and
[`shad_list()`](https://orijitghosh.github.io/shadshiny/reference/shad_typography.md).

## The quick brown fox

A lead paragraph introduces a section with slightly larger, muted text.

Body copy sits at a comfortable measure with sensible line height.

> Design systems shouldn't require a toolchain.

Muted text for captions and secondary detail.

Code


    shad_h2("The quick brown fox")
    shad_lead("A lead paragraph introduces a section with slightly larger, muted text.")
    shad_p("Body copy sits at a comfortable measure with sensible line height.")
    shad_blockquote("Design systems shouldn't require a toolchain.")
    shad_muted("Muted text for captions and secondary detail.")
