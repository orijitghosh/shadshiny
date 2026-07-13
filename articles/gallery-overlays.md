# Gallery: overlays & menus

Overlays open and close **entirely client-side**, so every trigger on
this page works — click the buttons and try the menus. Each overlay also
has an `inputId` so you can open it from the server with
[`shad_dialog_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md)
/
[`shad_sheet_open()`](https://orijitghosh.github.io/shadshiny/reference/shad_overlay_server.md)
/ etc., and read menu selections with `input$id`. The [Overlays & the
server](https://orijitghosh.github.io/shadshiny/articles/overlays-and-server.md)
guide covers the reactive half.

## Dialog

A modal centred over a dimming backdrop. Supply a `trigger` to open it
from the UI; the content portals to `<body>` on open.

Edit profile

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xOCA2IDYgMTgiIC8+PHBhdGggZD0ibTYgNiAxMiAxMiIgLz48L3N2Zz4=)

Edit profile

Make changes to your profile here. Click save when done.

Name

Username

Save changes

Code


    shad_dialog("demo_dialog", trigger = shad_button("Edit profile"), title = "Edit profile", description = "Make changes to your profile here. Click save when done.", shad_input("d_name", label = "Name", value = "Ada Lovelace"), shad_input("d_user", label = "Username", value = "@ada"), footer = shad_dialog_close_button("Save changes"))

## Sheet & drawer

A
[`shad_sheet()`](https://orijitghosh.github.io/shadshiny/reference/shad_sheet.md)
slides in from an edge (`side`); a
[`shad_drawer()`](https://orijitghosh.github.io/shadshiny/reference/shad_drawer.md)
rises from the bottom with a drag handle. Both are ideal for secondary
forms and detail panes.

Open sheet

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xOCA2IDYgMTgiIC8+PHBhdGggZD0ibTYgNiAxMiAxMiIgLz48L3N2Zz4=)

Notifications

You have 3 unread messages.

Sheet body content goes here.

Open drawer

Move goal

Set your daily activity target.

Drawer body content goes here.

Code


    shad_sheet("demo_sheet", side = "right", trigger = shad_button("Open sheet", variant = "outline"), title = "Notifications", description = "You have 3 unread messages.", shad_p("Sheet body content goes here."))
    shad_drawer("demo_drawer", trigger = shad_button("Open drawer", variant = "outline"), title = "Move goal", description = "Set your daily activity target.", shad_p("Drawer body content goes here."))

## Popover

A small floating panel anchored to its trigger — good for pickers and
quick forms.

Dimensions

Width

Height

Code


    shad_popover("demo_popover", trigger = shad_button("Dimensions", variant = "outline"), title = "Dimensions", shad_input("po_w", label = "Width", value = "100%"), shad_input("po_h", label = "Height", value = "25px"))

## Tooltip & hover-card

[`shad_tooltip()`](https://orijitghosh.github.io/shadshiny/reference/shad_tooltip.md)
shows a terse label on hover/focus;
[`shad_hover_card()`](https://orijitghosh.github.io/shadshiny/reference/shad_hover_card.md)
reveals a richer panel after a short delay.

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjEyIiBjeT0iMTIiIHI9IjEwIj48L2NpcmNsZT48cGF0aCBkPSJNMTIgMTZ2LTQiIC8+PHBhdGggZD0iTTEyIDhoLjAxIiAvPjwvc3ZnPg==)

Add to library

@shadshiny

**shadshiny**

A framework-free port of shadcn/ui for Shiny.

Code


    shad_tooltip(trigger = shad_button(icon = "info", size = "icon", aria_label = "Info"), content = "Add to library")
    shad_hover_card(trigger = shad_button("@shadshiny", variant = "link"), tags$div(style = "max-width:16rem;display:grid;gap:0.35rem", tags$strong("shadshiny"), shad_muted("A framework-free port of shadcn/ui for Shiny.")))

## Dropdown menu

A menu of actions off a trigger. Items carry icons, shortcuts and a
`destructive` flag; read the chosen item with `input$id`.

Open menu

My account

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjEyIiBjeT0iMTIiIHI9IjEwIj48L2NpcmNsZT48L3N2Zz4=)
Profile ⇧⌘P

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjEyIiBjeT0iMTIiIHI9IjEiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjE5IiBjeT0iMTIiIHI9IjEiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjUiIGN5PSIxMiIgcj0iMSI+PC9jaXJjbGU+PC9zdmc+)
Settings

Log out

Code


    shad_dropdown_menu("demo_menu", trigger = shad_button("Open menu", variant = "outline"), shad_menu_label("My account"), shad_menu_separator(), shad_menu_item("profile", "Profile", icon = "circle", shortcut = "⇧⌘P"), shad_menu_item("settings", "Settings", icon = "more-horizontal"), shad_menu_separator(), shad_menu_item("logout", "Log out", destructive = TRUE))

## Context menu

Right-click the target zone to open a menu at the cursor.

Right-click here

Back ⌘\[

Forward ⌘\]

Reload ⌘R

Code


    shad_context_menu("demo_ctx", target = tags$div(style = paste("display:grid;place-items:center;height:8rem;width:100%;", "border:1px dashed var(--shad-border);border-radius:var(--shad-radius-lg);", "color:var(--shad-muted-foreground)"), "Right-click here"), shad_menu_item("back", "Back", shortcut = "⌘["), shad_menu_item("forward", "Forward", shortcut = "⌘]"), shad_menu_separator(), shad_menu_item("reload", "Reload", shortcut = "⌘R"))

## Menubar

An application menu bar — each
[`shad_menubar_menu()`](https://orijitghosh.github.io/shadshiny/reference/shad_menubar.md)
opens a dropdown; hovering across the bar moves between them.

File

New tab ⌘T

Open… ⌘O

Print ⌘P

Edit

Undo ⌘Z

Redo ⇧⌘Z

View

Zoom in

Zoom out

Code


    shad_menubar("demo_menubar", shad_menubar_menu("File", shad_menu_item("new", "New tab", shortcut = "⌘T"), shad_menu_item("open", "Open…", shortcut = "⌘O"), shad_menu_separator(), shad_menu_item("print", "Print", shortcut = "⌘P")), shad_menubar_menu("Edit", shad_menu_item("undo", "Undo", shortcut = "⌘Z"), shad_menu_item("redo", "Redo", shortcut = "⇧⌘Z")), shad_menubar_menu("View", shad_menu_item("zoom_in", "Zoom in"), shad_menu_item("zoom_out", "Zoom out")))

## Command palette

[`shad_command()`](https://orijitghosh.github.io/shadshiny/reference/shad_command.md)
is a searchable action list. Inline it (below) or set `dialog = TRUE`
for a ⌘K spotlight overlay you open from the server with the
`shadshiny:invoke` message. Type to filter.

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1jb21tYW5kX19zZWFyY2gtaWNvbiIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48Y2lyY2xlIGN4PSIxMSIgY3k9IjExIiByPSI4Ij48L2NpcmNsZT48cGF0aCBkPSJtMjEgMjEtNC4zLTQuMyIgLz48L3N2Zz4=)

No results found.

Suggestions

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik04IDJ2NCIgLz48cGF0aCBkPSJNMTYgMnY0IiAvPjxyZWN0IHdpZHRoPSIxOCIgaGVpZ2h0PSIxOCIgeD0iMyIgeT0iNCIgcng9IjIiIC8+PHBhdGggZD0iTTMgMTBoMTgiIC8+PC9zdmc+)
Calendar

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjExIiBjeT0iMTEiIHI9IjgiPjwvY2lyY2xlPjxwYXRoIGQ9Im0yMSAyMS00LjMtNC4zIiAvPjwvc3ZnPg==)
Search

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxyZWN0IHdpZHRoPSIyMCIgaGVpZ2h0PSIxNiIgeD0iMiIgeT0iNCIgcng9IjIiIC8+PHBhdGggZD0ibTIyIDctOC45NyA1LjdhMS45NCAxLjk0IDAgMCAxLTIuMDYgMEwyIDciIC8+PC9zdmc+)
Send mail

Settings

Profile ⌘P

Billing ⌘B

Code


    tags$div(style = "max-width:26rem;width:100%", shad_command("demo_cmd", placeholder = "Type a command or search…", shad_command_group("Suggestions", shad_command_item("cal", "Calendar", icon = "calendar"), shad_command_item("search", "Search", icon = "search"), shad_command_item("mail", "Send mail", icon = "mail")), shad_command_group("Settings", shad_command_item("profile", "Profile", shortcut = "⌘P"), shad_command_item("billing", "Billing", shortcut = "⌘B"))))
