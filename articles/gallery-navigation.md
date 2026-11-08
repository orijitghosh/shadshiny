# Gallery: navigation & structure

These components arrange the rest. Like the overlays, they run
client-side, so the tabs switch, the accordion expands and the carousel
slides right here. Those with an `inputId` also report the active pane
through `input$id`. See [Layout &
composition](https://orijitghosh.github.io/shadshiny/articles/layout.md)
for putting them together into a full app shell.

## Tabs

Switch between panes. The active value is `input$id`; drive it from the
server with
[`update_shad_tabs()`](https://orijitghosh.github.io/shadshiny/reference/update_shad.md).

Account

Password

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjEyIiBjeT0iMTIiIHI9IjEwIj48L2NpcmNsZT48L3N2Zz4=)
Team

Update your account details here.

Change your password here.

Manage your team members.

Code


    shad_tabs("demo_tabs", selected = "account", shad_tab("account", "Account", tags$div(style = "padding-top:0.75rem", shad_p("Update your account details here."))), shad_tab("password", "Password", tags$div(style = "padding-top:0.75rem", shad_p("Change your password here."))), shad_tab("team", "Team", icon = "circle", tags$div(style = "padding-top:0.75rem", shad_p("Manage your team members."))))

## Accordion

Vertically stacked, collapsible sections. `type = "single"` keeps one
open; `"multiple"` allows many.

Is it accessible?
![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1hY2NvcmRpb25fX2NoZXZyb24iIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0ibTYgOSA2IDYgNi02IiAvPjwvc3ZnPg==)

Yes. It follows the WAI-ARIA disclosure pattern.

Is it styled?
![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1hY2NvcmRpb25fX2NoZXZyb24iIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0ibTYgOSA2IDYgNi02IiAvPjwvc3ZnPg==)

Yes. It comes with sensible defaults you can theme.

Is it animated?
![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1hY2NvcmRpb25fX2NoZXZyb24iIHZpZXdib3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJjdXJyZW50Q29sb3IiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0ibTYgOSA2IDYgNi02IiAvPjwvc3ZnPg==)

Yes – height transitions come for free.

Code


    shad_accordion("demo_acc", type = "single", collapsible = TRUE, value = "a1", shad_accordion_item("a1", "Is it accessible?", shad_p("Yes. It follows the WAI-ARIA disclosure pattern.")), shad_accordion_item("a2", "Is it styled?", shad_p("Yes. It comes with sensible defaults you can theme.")), shad_accordion_item("a3", "Is it animated?", shad_p("Yes – height transitions come for free.")))

## Collapsible

A single show/hide region behind any trigger.

Show advanced options
![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Im03IDE1IDUgNSA1LTUiIC8+PHBhdGggZD0ibTcgOSA1LTUgNSA1IiAvPjwvc3ZnPg==)

These options are hidden until requested.

Enable experimental features

Code


    shad_collapsible("demo_coll", open = FALSE, trigger = shad_button("Show advanced options", variant = "ghost", icon = "chevrons-up-down", icon_position = "right"), tags$div(style = "padding:0.75rem 0;display:grid;gap:0.5rem", shad_muted("These options are hidden until requested."), shad_switch("adv_a", label = "Enable experimental features")))

## Pagination

Page controls that report the current page as `input$id`.

Code


    shad_pagination("demo_pg", pages = 8, selected = 3)

## Carousel

A horizontal slider with optional dots and arrows.

1

2

3

4

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIHNoYWQtaWNvbi0tZGlyZWN0aW9uYWwiIGRhdGEtZGlyZWN0aW9uPSJiYWNrIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Im0xMiAxOS03LTcgNy03IiAvPjxwYXRoIGQ9Ik0xOSAxMkg1IiAvPjwvc3ZnPg==)

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIHNoYWQtaWNvbi0tZGlyZWN0aW9uYWwiIGRhdGEtZGlyZWN0aW9uPSJmb3J3YXJkIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik01IDEyaDE0IiAvPjxwYXRoIGQ9Im0xMiA1IDcgNy03IDciIC8+PC9zdmc+)

Code


    tags$div(style = "max-width:22rem;width:100%;margin:0 auto", do.call(shad_carousel, c(list("demo_car", show_dots = TRUE), lapply(1:4, function(i) shad_carousel_item(shad_card(shad_card_content(tags$div(style = "display:grid;place-items:center;height:8rem;font-size:2rem;font-weight:600", i))))))))

## Scroll area

A styled, fixed-height scroll container.

#### Tags

Item 1

Item 2

Item 3

Item 4

Item 5

Item 6

Item 7

Item 8

Item 9

Item 10

Item 11

Item 12

Item 13

Item 14

Item 15

Item 16

Item 17

Item 18

Item 19

Item 20

Code


    shad_scroll_area(height = "10rem", tags$div(style = "padding-right:1rem", shad_h4("Tags", style = "margin-top:0"), tagList(lapply(1:20, function(i) tagList(shad_p(paste("Item", i), style = "margin:0.35rem 0"), shad_separator())))))

## Resizable

Draggable split panes. Drag the handle to resize.

Sidebar

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNiIgaGVpZ2h0PSIxMCIgdmlld2JveD0iMCAwIDYgMTAiIGZpbGw9ImN1cnJlbnRDb2xvciIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjEuNSIgY3k9IjIiIHI9IjEiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjQuNSIgY3k9IjIiIHI9IjEiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjEuNSIgY3k9IjUiIHI9IjEiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjQuNSIgY3k9IjUiIHI9IjEiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjEuNSIgY3k9IjgiIHI9IjEiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjQuNSIgY3k9IjgiIHI9IjEiPjwvY2lyY2xlPjwvc3ZnPg==)

Content

Code


    tags$div(style = "height:12rem", shad_resizable("demo_rz", shad_resizable_panel(default_size = 40, tags$div(style = "display:grid;place-items:center;height:100%", "Sidebar")), shad_resizable_handle(), shad_resizable_panel(default_size = 60, tags$div(style = "display:grid;place-items:center;height:100%", "Content"))))

## Layout primitives

*A shadshiny addition: no shadcn/ui counterpart.*

[`shad_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_container.md),
[`shad_stack()`](https://orijitghosh.github.io/shadshiny/reference/shad_stack.md)
and
[`shad_grid()`](https://orijitghosh.github.io/shadshiny/reference/shad_grid.md)
cover page layout without hand-written CSS. Spacing takes a token step –
`gap = 4` is `var(--shad-space-4)`, the same scale the components use
internally – or any CSS length.

`shad_grid(min_width = )` fits as many equal columns as will fit, with
no breakpoints to maintain. **Resize the window** to watch this reflow:

Revenue

\$45,231
![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik03IDE3TDE3IDdNNyA3aDEwdjEwIiAvPjwvc3ZnPg==)
+20.1%

Subscribers

2,350
![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik03IDE3TDE3IDdNNyA3aDEwdjEwIiAvPjwvc3ZnPg==)
+180

Active now

573

Code


    shad_grid(shad_value_box("$45,231", "Revenue", delta = "+20.1%"), shad_value_box("2,350", "Subscribers", delta = "+180"), shad_value_box("573", "Active now"), min_width = "13rem")

For an exact column count, pass `cols` – optionally per breakpoint
(`base`, `sm` 40rem, `md` 48rem, `lg` 64rem), where each falls back to
the one below it. `shad_grid_item(span = )` spans cells, and `template`
takes a raw track list:

1fr

2fr

full row

Code


    shad_grid(shad_card(shad_card_content("1fr")), shad_card(shad_card_content("2fr")), shad_grid_item(shad_card(shad_card_content("full row")), span = "full"), template = "1fr 2fr")

[`shad_stack()`](https://orijitghosh.github.io/shadshiny/reference/shad_stack.md)
is the one-dimensional version – a column by default, a row when asked,
with `align`, `justify`, `wrap` and `fill`:

Save

Cancel

Delete

Code


    shad_stack(shad_button("Save"), shad_button("Cancel", variant = "outline"), shad_button("Delete", variant = "destructive"), direction = "horizontal", gap = 2, wrap = TRUE)

## Page shells

*A shadshiny addition: no shadcn/ui counterpart.*

Two wrappers assemble a whole page in one call, taking the
[`page_shad()`](https://orijitghosh.github.io/shadshiny/reference/page_shad.md)
theming arguments and wrapping content in a
[`shad_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_container.md)
unless you pass `container = FALSE`.

``` r

# a title bar carrying a tab strip; input$nav is the active view
ui <- shad_page_navbar(
  shad_tab("overview", "Overview", overview_ui),
  shad_tab("reports",  "Reports",  reports_ui),
  title = "Acme", inputId = "nav",
  header_end = bslib::input_dark_mode()
)

# the application frame: collapsible sidebar, bar with its trigger, scrolling main
ui <- shad_page_sidebar(
  sidebar = shad_sidebar(
    shad_sidebar_group("Platform",
      shad_sidebar_item("home", "Home", icon = "home", active = TRUE))),
  inputId = "shell", title = "Acme",
  shad_grid(kpi_one, kpi_two, min_width = "14rem")
)
```

The two differ in what scrolls. The navbar shell lets the window scroll
and pins its bar with `position: sticky`; the sidebar shell takes the
viewport height and scrolls its main region instead, because a sidebar
that scrolls away is a sidebar with a drifting rail and footer.

## Sidebar layout

The full app shell: a collapsible sidebar with grouped, badged nav items
and a main region. `input$id` reports `{collapsed, mobileOpen, active}`
– observe `input$id$active` for the selected item.

In a Shiny app you observe `input$demo_shell$active` and swap the main
pane server-side. This static preview does the same thing client-side
(listening for the sidebar’s `shad:change` event) so you can see
navigation work – **click Home, Inbox, Search, Settings.**

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwb2x5bGluZSBwb2ludHM9IjQgMTcgMTAgMTEgNCA1Ij48L3BvbHlsaW5lPjxsaW5lIHgxPSIxMiIgeDI9IjIwIiB5MT0iMTkiIHkyPSIxOSI+PC9saW5lPjwvc3ZnPg==)**Acme**

Platform

- ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Im0zIDkgOS03IDkgN3YxMWEyIDIgMCAwIDEtMiAySDVhMiAyIDAgMCAxLTItMnoiIC8+PHBvbHlsaW5lIHBvaW50cz0iOSAyMiA5IDEyIDE1IDEyIDE1IDIyIj48L3BvbHlsaW5lPjwvc3ZnPg==)Home
- ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxyZWN0IHdpZHRoPSIyMCIgaGVpZ2h0PSIxNiIgeD0iMiIgeT0iNCIgcng9IjIiIC8+PHBhdGggZD0ibTIyIDctOC45NyA1LjdhMS45NCAxLjk0IDAgMCAxLTIuMDYgMEwyIDciIC8+PC9zdmc+)Inbox
  3
- ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjExIiBjeT0iMTEiIHI9IjgiPjwvY2lyY2xlPjxwYXRoIGQ9Im0yMSAyMS00LjMtNC4zIiAvPjwvc3ZnPg==)Search

Account

- ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xMi4yMiAyaC0uNDRhMiAyIDAgMCAwLTIgMnYuMThhMiAyIDAgMCAxLTEgMS43M2wtLjQzLjI1YTIgMiAwIDAgMS0yIDBsLS4xNS0uMDhhMiAyIDAgMCAwLTIuNzMuNzNsLS4yMi4zOGEyIDIgMCAwIDAgLjczIDIuNzNsLjE1LjFhMiAyIDAgMCAxIDEgMS43MnYuNTFhMiAyIDAgMCAxLTEgMS43NGwtLjE1LjA5YTIgMiAwIDAgMC0uNzMgMi43M2wuMjIuMzhhMiAyIDAgMCAwIDIuNzMuNzNsLjE1LS4wOGEyIDIgMCAwIDEgMiAwbC40My4yNWEyIDIgMCAwIDEgMSAxLjczVjIwYTIgMiAwIDAgMCAyIDJoLjQ0YTIgMiAwIDAgMCAyLTJ2LS4xOGEyIDIgMCAwIDEgMS0xLjczbC40My0uMjVhMiAyIDAgMCAxIDIgMGwuMTUuMDhhMiAyIDAgMCAwIDIuNzMtLjczbC4yMi0uMzlhMiAyIDAgMCAwLS43My0yLjczbC0uMTUtLjA4YTIgMiAwIDAgMS0xLTEuNzR2LS41YTIgMiAwIDAgMSAxLTEuNzRsLjE1LS4wOWEyIDIgMCAwIDAgLjczLTIuNzNsLS4yMi0uMzhhMiAyIDAgMCAwLTIuNzMtLjczbC0uMTUuMDhhMiAyIDAgMCAxLTIgMGwtLjQzLS4yNWEyIDIgMCAwIDEtMS0xLjczVjRhMiAyIDAgMCAwLTItMnoiIC8+PGNpcmNsZSBjeD0iMTIiIGN5PSIxMiIgcj0iMyI+PC9jaXJjbGU+PC9zdmc+)Settings

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxyZWN0IHdpZHRoPSIxOCIgaGVpZ2h0PSIxOCIgeD0iMyIgeT0iMyIgcng9IjIiIC8+PHBhdGggZD0iTTkgM3YxOCIgLz48L3N2Zz4=)

#### Home

Dashboard overview. Toggle the sidebar with the trigger; resize the
window to see it collapse to a rail.

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxyZWN0IHdpZHRoPSIyMCIgaGVpZ2h0PSIxNiIgeD0iMiIgeT0iNCIgcng9IjIiIC8+PHBhdGggZD0ibTIyIDctOC45NyA1LjdhMS45NCAxLjk0IDAgMCAxLTIuMDYgMEwyIDciIC8+PC9zdmc+)

Welcome to Acme

2 min ago

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xNSAySDZhMiAyIDAgMCAwLTIgMnYxNmEyIDIgMCAwIDAgMiAyaDEyYTIgMiAwIDAgMCAyLTJWN1oiIC8+PHBhdGggZD0iTTE0IDJ2NGEyIDIgMCAwIDAgMiAyaDQiIC8+PC9zdmc+)

Your invoice is ready

1 hour ago

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjExIiBjeT0iMTEiIHI9IjgiPjwvY2lyY2xlPjxwYXRoIGQ9Im0yMSAyMS00LjMtNC4zIiAvPjwvc3ZnPg==)

Search

Type to search across Acme.

Email notifications

Beta features

Code


    tags$div(style = "height:18rem;border-radius:var(--shad-radius-lg);overflow:hidden;border:1px solid var(--shad-border)", shad_sidebar_layout("demo_shell", sidebar = shad_sidebar(header = tags$div(style = "display:flex;gap:0.5rem;align-items:center;padding:0.25rem", shad_icon("terminal"), tags$strong("Acme")), shad_sidebar_group("Platform", shad_sidebar_item("home", "Home", icon = "home", active = TRUE), shad_sidebar_item("inbox", "Inbox", icon = "mail", badge = "3"), shad_sidebar_item("search", "Search", 
        icon = "search")), shad_sidebar_group("Account", shad_sidebar_item("settings", "Settings", icon = "settings"))), main = tags$div(style = "padding:1rem", tags$div(style = "display:flex;gap:0.5rem;align-items:center;margin-bottom:0.75rem", shad_sidebar_trigger(), shad_h4("Home", style = "margin:0", `data-shell-title` = NA)), tags$div(`data-panel` = "home", shad_p("Dashboard overview. Toggle the sidebar with the trigger; resize the window to see it collapse to a rail.")), tags$div(`data-panel` = "inbox", 
        hidden = NA, shad_item_group(shad_item(title = "Welcome to Acme", description = "2 min ago", media = "mail", media_variant = "icon"), shad_item(title = "Your invoice is ready", description = "1 hour ago", media = "file", media_variant = "icon"))), tags$div(`data-panel` = "search", hidden = NA, shad_empty(title = "Search", description = "Type to search across Acme.", media = "search", media_variant = "icon")), tags$div(`data-panel` = "settings", hidden = NA, shad_switch("demo_notify", label = "Email notifications", 
        value = TRUE), shad_switch("demo_beta", label = "Beta features")), tags$script(htmltools::HTML("(function(){\n          var root = document.getElementById('demo_shell'); if(!root) return;\n          var names = {home:'Home', inbox:'Inbox', search:'Search', settings:'Settings'};\n          function show(a){\n            root.querySelectorAll('[data-panel]').forEach(function(p){\n              p.hidden = p.getAttribute('data-panel') !== a; });\n            var t = root.querySelector('[data-shell-title]');\n            if(t) t.textContent = names[a] || a;\n          }\n          root.addEventListener('shad:change', function(e){\n            var v = e.detail && e.detail.value; if(v && v.active) show(v.active); });\n        })();")))))

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxyZWN0IHdpZHRoPSIxOCIgaGVpZ2h0PSIxOCIgeD0iMyIgeT0iMyIgcng9IjIiIC8+PHBhdGggZD0iTTkgM3YxOCIgLz48L3N2Zz4=)

#### Home

Dashboard overview. Toggle the sidebar with the trigger; resize the
window to see it collapse to a rail.

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxyZWN0IHdpZHRoPSIyMCIgaGVpZ2h0PSIxNiIgeD0iMiIgeT0iNCIgcng9IjIiIC8+PHBhdGggZD0ibTIyIDctOC45NyA1LjdhMS45NCAxLjk0IDAgMCAxLTIuMDYgMEwyIDciIC8+PC9zdmc+)

Welcome to Acme

2 min ago

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xNSAySDZhMiAyIDAgMCAwLTIgMnYxNmEyIDIgMCAwIDAgMiAyaDEyYTIgMiAwIDAgMCAyLTJWN1oiIC8+PHBhdGggZD0iTTE0IDJ2NGEyIDIgMCAwIDAgMiAyaDQiIC8+PC9zdmc+)

Your invoice is ready

1 hour ago

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjExIiBjeT0iMTEiIHI9IjgiPjwvY2lyY2xlPjxwYXRoIGQ9Im0yMSAyMS00LjMtNC4zIiAvPjwvc3ZnPg==)

Search

Type to search across Acme.

Email notifications

Beta features
