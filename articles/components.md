# Component gallery

Every shadshiny component, rendered live on one of the gallery pages
below. Each preview shows the real component alongside the exact source
that produced it — these are not screenshots. Previews follow the site’s
light/dark switch, so you can see both modes without leaving the page.

New to the package? Read [Get
started](https://orijitghosh.github.io/shadshiny/articles/shadshiny.md)
first, then browse here.

[**Display & typography**Buttons, badges, avatars, cards, alerts,
tables, progress, and the type
scale.](https://orijitghosh.github.io/shadshiny/articles/gallery-display.md)
[**Form inputs**Text, select, combobox, checkbox, switch, radio, toggle,
slider, OTP,
dates.](https://orijitghosh.github.io/shadshiny/articles/gallery-inputs.md)
[**Overlays & menus**Dialog, sheet, drawer, popover, tooltip, dropdown,
context-menu,
command.](https://orijitghosh.github.io/shadshiny/articles/gallery-overlays.md)
[**Navigation & structure**Tabs, accordion, pagination, carousel,
resizable, container/stack/grid, page shells,
sidebar.](https://orijitghosh.github.io/shadshiny/articles/gallery-navigation.md)
[**Data, dashboards & flow**Data table, value boxes, sparklines, donuts,
chart shells, timeline, stepper, tree, rating,
dropzone.](https://orijitghosh.github.io/shadshiny/articles/gallery-data.md)
[**Chat & AI kit**Bubbles, messages, typing indicator, attachments, and
the sticky
scroller.](https://orijitghosh.github.io/shadshiny/articles/gallery-chat.md)
[**Icons**The full icon set, live, with names you pass to
`icon =`.](https://orijitghosh.github.io/shadshiny/articles/icons.md)

## A taste

A few components, live — expand *Code* under any preview to see how it’s
built.

Get started
![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik01IDEyaDE0IiAvPjxwYXRoIGQ9Im0xMiA1IDcgNy03IDciIC8+PC9zdmc+)

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMCA2IDkgMTdsLTUtNSIgLz48L3N2Zz4=)
New

Outline

Code


    shad_button("Get started", icon = "arrow-right", icon_position = "right")
    shad_badge("New", icon = "check")
    shad_button("Outline", variant = "outline")

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1hbGVydF9faWNvbiIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxMCI+PC9jaXJjbGU+PHBhdGggZD0iTTEyIDE2di00IiAvPjxwYXRoIGQ9Ik0xMiA4aC4wMSIgLz48L3N2Zz4=)

It's all live

Every preview on these pages is the real component, initialised in your
browser.

Code


    shad_alert(title = "It's all live", "Every preview on these pages is the real component, initialised in your browser.", icon = "info")

## How the previews work

shadshiny components are plain `htmltools` tags that each carry the
bundled asset dependency. Rendering one in an article embeds the real
CSS and JavaScript, so the component initialises client-side exactly as
it would in a running app — dialogs open, tabs switch, carousels slide.
Because dark mode keys off `[data-bs-theme="dark"]` (which the navbar’s
light-switch toggles), the previews recolour with the rest of the site.
The
[Theming](https://orijitghosh.github.io/shadshiny/articles/theming.md)
guide explains the token system behind that.
