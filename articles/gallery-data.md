# Gallery: data, dashboards & flow

The components on this page turn shadshiny from a component library into
an application toolkit: a client-side data table, the dashboard shells,
and the flow inputs. The previews are live — sort the table, drag the
rating, hold the stepper — but with no Shiny server attached they won’t
echo values back.

For the reactive side, see [Data
tables](https://orijitghosh.github.io/shadshiny/articles/data-tables.md),
[Dashboards &
charts](https://orijitghosh.github.io/shadshiny/articles/charts.md), and
[Forms &
validation](https://orijitghosh.github.io/shadshiny/articles/forms.md).

## Data table

[`shad_data_table()`](https://orijitghosh.github.io/shadshiny/reference/shad_data_table.md)
is a **bound input**, not an output. It serialises the frame once and
does all sorting, filtering, paging and selection in the browser.
`input$<id>` reports `{selected, sort, filter, page, pageSize}`.

Click a header to sort, Shift+click to add a second sort key, and use
the search box or the per-column filters to narrow the rows.

Code


    shad_data_table("tbl_demo", cars, columns = list(model = shad_col("Model", width = "12rem"), mpg = shad_col("MPG", format = shad_fmt_number(1)), cyl = shad_col("Cylinders", align = "center"), hp = shad_col("Horsepower", format = shad_fmt_number(0)), wt = shad_col("Weight", format = shad_fmt_number(2, suffix = " t"))), selection = "multiple", filter = "global", page_size = 5)

### Formatted cells

`shad_col(format=)` takes one of the `shad_fmt_*()` formatters. Each
keeps the **raw** value as the sort key, so a `$1,200.00` cell still
sorts numerically and a formatted date still sorts chronologically.

Code


    shad_data_table("tbl_fmt", sales, columns = list(order = shad_col("Order #", width = "8rem"), amount = shad_col("Amount", format = shad_fmt_number(2, prefix = "$")), margin = shad_col("Margin", format = shad_fmt_percent(1)), date = shad_col("Date", format = shad_fmt_date("%b %d, %Y")), status = shad_col("Status", format = shad_fmt_badge(c(paid = "default", pending = "secondary", refunded = "destructive")))), filter = "none", page_size = 5)

## Value box

*A shadshiny addition: no shadcn/ui counterpart.*

[`shad_value_box()`](https://orijitghosh.github.io/shadshiny/reference/shad_value_box.md)
is the KPI card. `delta_direction = "auto"` (the default) reads the sign
off the `delta` string, so `"+12.5%"` is up and `"-3%"` is down — pass
`delta_direction` explicitly when the arrow shouldn’t follow the sign (a
falling error rate is good news).

Revenue

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxyZWN0IHdpZHRoPSIyMCIgaGVpZ2h0PSIxNCIgeD0iMiIgeT0iNSIgcng9IjIiIC8+PGxpbmUgeDE9IjIiIHgyPSIyMiIgeTE9IjEwIiB5Mj0iMTAiPjwvbGluZT48L3N2Zz4=)

\$45,231
![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik03IDE3TDE3IDdNNyA3aDEwdjEwIiAvPjwvc3ZnPg==)
+20.1%

vs. last month

Subscribers

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xNiAyMXYtMmE0IDQgMCAwIDAtNC00SDZhNCA0IDAgMCAwLTQgNHYyIiAvPjxjaXJjbGUgY3g9IjkiIGN5PSI3IiByPSI0Ij48L2NpcmNsZT48cGF0aCBkPSJNMjIgMjF2LTJhNCA0IDAgMCAwLTMtMy44NyIgLz48cGF0aCBkPSJNMTYgMy4xM2E0IDQgMCAwIDEgMCA3Ljc1IiAvPjwvc3ZnPg==)

2,350
![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik03IDE3TDE3IDdNNyA3aDEwdjEwIiAvPjwvc3ZnPg==)
+180

Error rate

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMiAxMmgtNGwtMyA5TDkgM2wtMyA5SDIiIC8+PC9zdmc+)

0.9%
![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik03IDE3TDE3IDdNNyA3aDEwdjEwIiAvPjwvc3ZnPg==)
-0.4%

Lower is better

Active now

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwb2x5Z29uIHBvaW50cz0iMTMgMiAzIDE0IDEyIDE0IDExIDIyIDIxIDEwIDEyIDEwIDEzIDIiPjwvcG9seWdvbj48L3N2Zz4=)

573

Code


    shad_value_box("$45,231", "Revenue", delta = "+20.1%", icon = "credit-card", caption = "vs. last month")
    shad_value_box("2,350", "Subscribers", delta = "+180", icon = "users")
    shad_value_box("0.9%", "Error rate", delta = "-0.4%", delta_direction = "up", icon = "activity", caption = "Lower is better")
    shad_value_box("573", "Active now", icon = "zap", size = "sm")

## Sparkline

*A shadshiny addition: no shadcn/ui counterpart.*

[`shad_sparkline()`](https://orijitghosh.github.io/shadshiny/reference/shad_sparkline.md)
is a tiny inline chart with no axes, no labels, and no plotting stack —
one SVG path (or a row of bars) that stretches to fill its box. Every
mark is painted with the theme’s chart tokens, so the light/dark switch
at the top of this page restyles these in CSS, with no re-render.

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zcGFya2xpbmUiIHZpZXdib3g9IjAgMCAxMDAgMTAwIiBwcmVzZXJ2ZWFzcGVjdHJhdGlvPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHN0eWxlPSJ3aWR0aDoxMDAlO2hlaWdodDoyLjVyZW07IiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTAgOTEuMTRMMTQuMjkgNzAuNTdMMjguNTcgOThMNDIuODYgNDUuNDNMNTcuMTQgNjZMNzEuNDMgMjAuMjlMODUuNzEgMjkuNDNMMTAwIDIiIGZpbGw9Im5vbmUiIHN0cm9rZT0idmFyKC0tc2hhZC1jaGFydC0xKSIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHZlY3Rvci1lZmZlY3Q9Im5vbi1zY2FsaW5nLXN0cm9rZSIgLz48L3N2Zz4=)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zcGFya2xpbmUiIHZpZXdib3g9IjAgMCAxMDAgMTAwIiBwcmVzZXJ2ZWFzcGVjdHJhdGlvPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHN0eWxlPSJ3aWR0aDoxMDAlO2hlaWdodDoyLjVyZW07IiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTAgOTEuMTRMMTQuMjkgNzAuNTdMMjguNTcgOThMNDIuODYgNDUuNDNMNTcuMTQgNjZMNzEuNDMgMjAuMjlMODUuNzEgMjkuNDNMMTAwIDJWMTAwSDBaIiBmaWxsPSJ2YXIoLS1zaGFkLWNoYXJ0LTEpIiBmaWxsLW9wYWNpdHk9IjAuMTgiIHN0cm9rZT0ibm9uZSIgLz48cGF0aCBkPSJNMCA5MS4xNEwxNC4yOSA3MC41N0wyOC41NyA5OEw0Mi44NiA0NS40M0w1Ny4xNCA2Nkw3MS40MyAyMC4yOUw4NS43MSAyOS40M0wxMDAgMiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJ2YXIoLS1zaGFkLWNoYXJ0LTEpIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgdmVjdG9yLWVmZmVjdD0ibm9uLXNjYWxpbmctc3Ryb2tlIiAvPjwvc3ZnPg==)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zcGFya2xpbmUiIHZpZXdib3g9IjAgMCAxMDAgMTAwIiBwcmVzZXJ2ZWFzcGVjdHJhdGlvPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHN0eWxlPSJ3aWR0aDoxMDAlO2hlaWdodDoyLjVyZW07IiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHJlY3QgeD0iMSIgd2lkdGg9IjEwLjUiIHk9IjkyLjg2IiBoZWlnaHQ9IjcuMTQiIGZpbGw9InZhcigtLXNoYWQtY2hhcnQtMikiIGZpbGwtb3BhY2l0eT0iMC4xOCIgcng9IjEuNSIgLz48cmVjdCB4PSIxMy41IiB3aWR0aD0iMTAuNSIgeT0iNzEuNDMiIGhlaWdodD0iMjguNTciIGZpbGw9InZhcigtLXNoYWQtY2hhcnQtMikiIGZpbGwtb3BhY2l0eT0iMC4xOCIgcng9IjEuNSIgLz48cmVjdCB4PSIyNiIgd2lkdGg9IjEwLjUiIHk9IjEwMCIgaGVpZ2h0PSIwLjUiIGZpbGw9InZhcigtLXNoYWQtY2hhcnQtMikiIGZpbGwtb3BhY2l0eT0iMC4xOCIgcng9IjEuNSIgLz48cmVjdCB4PSIzOC41IiB3aWR0aD0iMTAuNSIgeT0iNDUuMjQiIGhlaWdodD0iNTQuNzYiIGZpbGw9InZhcigtLXNoYWQtY2hhcnQtMikiIGZpbGwtb3BhY2l0eT0iMC4xOCIgcng9IjEuNSIgLz48cmVjdCB4PSI1MSIgd2lkdGg9IjEwLjUiIHk9IjY2LjY3IiBoZWlnaHQ9IjMzLjMzIiBmaWxsPSJ2YXIoLS1zaGFkLWNoYXJ0LTIpIiBmaWxsLW9wYWNpdHk9IjAuMTgiIHJ4PSIxLjUiIC8+PHJlY3QgeD0iNjMuNSIgd2lkdGg9IjEwLjUiIHk9IjE5LjA1IiBoZWlnaHQ9IjgwLjk1IiBmaWxsPSJ2YXIoLS1zaGFkLWNoYXJ0LTIpIiBmaWxsLW9wYWNpdHk9IjAuMTgiIHJ4PSIxLjUiIC8+PHJlY3QgeD0iNzYiIHdpZHRoPSIxMC41IiB5PSIyOC41NyIgaGVpZ2h0PSI3MS40MyIgZmlsbD0idmFyKC0tc2hhZC1jaGFydC0yKSIgZmlsbC1vcGFjaXR5PSIwLjE4IiByeD0iMS41IiAvPjxyZWN0IHg9Ijg4LjUiIHdpZHRoPSIxMC41IiB5PSIwIiBoZWlnaHQ9IjEwMCIgZmlsbD0idmFyKC0tc2hhZC1jaGFydC0yKSIgZmlsbC1vcGFjaXR5PSIwLjE4IiByeD0iMS41IiAvPjwvc3ZnPg==)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zcGFya2xpbmUiIHZpZXdib3g9IjAgMCAxMDAgMTAwIiBwcmVzZXJ2ZWFzcGVjdHJhdGlvPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHN0eWxlPSJ3aWR0aDoxMDAlO2hlaWdodDoyLjVyZW07IiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTAgOTEuMTRIMTQuMjlWNzAuNTdIMjguNTdWOThINDIuODZWNDUuNDNINTcuMTRWNjZINzEuNDNWMjAuMjlIODUuNzFWMjkuNDNIMTAwVjIiIGZpbGw9Im5vbmUiIHN0cm9rZT0idmFyKC0tc2hhZC1jaGFydC0zKSIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHZlY3Rvci1lZmZlY3Q9Im5vbi1zY2FsaW5nLXN0cm9rZSIgLz48L3N2Zz4=)

Code


    shad_sparkline(c(31, 40, 28, 51, 42, 62, 58, 70), type = "line")
    shad_sparkline(c(31, 40, 28, 51, 42, 62, 58, 70), type = "area")
    shad_sparkline(c(31, 40, 28, 51, 42, 62, 58, 70), type = "bar", color = 2)
    shad_sparkline(c(31, 40, 28, 51, 42, 62, 58, 70), type = "step", color = 3)

Non-finite values break the series rather than being interpolated
across, and bars hang off a zero baseline once the data crosses it:

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zcGFya2xpbmUiIHZpZXdib3g9IjAgMCAxMDAgMTAwIiBwcmVzZXJ2ZWFzcGVjdHJhdGlvPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHN0eWxlPSJ3aWR0aDoxMDAlO2hlaWdodDoyLjVyZW07IiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTAgOThMMTYuNjcgMzhWMTAwSDBaIiBmaWxsPSJ2YXIoLS1zaGFkLWNoYXJ0LTEpIiBmaWxsLW9wYWNpdHk9IjAuMTgiIHN0cm9rZT0ibm9uZSIgLz48cGF0aCBkPSJNNjYuNjcgNzRMODMuMzMgMkwxMDAgNTBWMTAwSDY2LjY3WiIgZmlsbD0idmFyKC0tc2hhZC1jaGFydC0xKSIgZmlsbC1vcGFjaXR5PSIwLjE4IiBzdHJva2U9Im5vbmUiIC8+PHBhdGggZD0iTTAgOThMMTYuNjcgMzgiIGZpbGw9Im5vbmUiIHN0cm9rZT0idmFyKC0tc2hhZC1jaGFydC0xKSIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHZlY3Rvci1lZmZlY3Q9Im5vbi1zY2FsaW5nLXN0cm9rZSIgLz48cGF0aCBkPSJNNjYuNjcgNzRMODMuMzMgMkwxMDAgNTAiIGZpbGw9Im5vbmUiIHN0cm9rZT0idmFyKC0tc2hhZC1jaGFydC0xKSIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIHZlY3Rvci1lZmZlY3Q9Im5vbi1zY2FsaW5nLXN0cm9rZSIgLz48L3N2Zz4=)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zcGFya2xpbmUiIHZpZXdib3g9IjAgMCAxMDAgMTAwIiBwcmVzZXJ2ZWFzcGVjdHJhdGlvPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHN0eWxlPSJ3aWR0aDoxMDAlO2hlaWdodDoyLjVyZW07IiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHJlY3QgeD0iMSIgd2lkdGg9IjE0LjY3IiB5PSI2MCIgaGVpZ2h0PSI0MCIgZmlsbD0idmFyKC0tc2hhZC1jaGFydC00KSIgZmlsbC1vcGFjaXR5PSIwLjE4IiByeD0iMS41IiAvPjxyZWN0IHg9IjE3LjY3IiB3aWR0aD0iMTQuNjciIHk9IjYwIiBoZWlnaHQ9IjEwIiBmaWxsPSJ2YXIoLS1zaGFkLWNoYXJ0LTQpIiBmaWxsLW9wYWNpdHk9IjAuMTgiIHJ4PSIxLjUiIC8+PHJlY3QgeD0iMzQuMzMiIHdpZHRoPSIxNC42NyIgeT0iNDAiIGhlaWdodD0iMjAiIGZpbGw9InZhcigtLXNoYWQtY2hhcnQtNCkiIGZpbGwtb3BhY2l0eT0iMC4xOCIgcng9IjEuNSIgLz48cmVjdCB4PSI1MSIgd2lkdGg9IjE0LjY3IiB5PSIxMCIgaGVpZ2h0PSI1MCIgZmlsbD0idmFyKC0tc2hhZC1jaGFydC00KSIgZmlsbC1vcGFjaXR5PSIwLjE4IiByeD0iMS41IiAvPjxyZWN0IHg9IjY3LjY3IiB3aWR0aD0iMTQuNjciIHk9IjYwIiBoZWlnaHQ9IjMwIiBmaWxsPSJ2YXIoLS1zaGFkLWNoYXJ0LTQpIiBmaWxsLW9wYWNpdHk9IjAuMTgiIHJ4PSIxLjUiIC8+PHJlY3QgeD0iODQuMzMiIHdpZHRoPSIxNC42NyIgeT0iMCIgaGVpZ2h0PSI2MCIgZmlsbD0idmFyKC0tc2hhZC1jaGFydC00KSIgZmlsbC1vcGFjaXR5PSIwLjE4IiByeD0iMS41IiAvPjwvc3ZnPg==)

Code


    shad_sparkline(c(4, 9, NA, NA, 6, 12, 8), type = "area")
    shad_sparkline(c(-4, -1, 2, 5, -3, 6), type = "bar", color = 4)

Dropped into `shad_value_box(sparkline = )` it fills the strip at the
foot of the card:

Revenue

\$45,231
![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik03IDE3TDE3IDdNNyA3aDEwdjEwIiAvPjwvc3ZnPg==)
+20.1%

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zcGFya2xpbmUiIHZpZXdib3g9IjAgMCAxMDAgMTAwIiBwcmVzZXJ2ZWFzcGVjdHJhdGlvPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHN0eWxlPSJ3aWR0aDoxMDAlO2hlaWdodDoyLjVyZW07IiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTAgODkuNTNMMjAgNjQuMTJMNDAgOThMNjAgMzMuMDZMODAgNTguNDdMMTAwIDJWMTAwSDBaIiBmaWxsPSJ2YXIoLS1zaGFkLWNoYXJ0LTEpIiBmaWxsLW9wYWNpdHk9IjAuMTgiIHN0cm9rZT0ibm9uZSIgLz48cGF0aCBkPSJNMCA4OS41M0wyMCA2NC4xMkw0MCA5OEw2MCAzMy4wNkw4MCA1OC40N0wxMDAgMiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJ2YXIoLS1zaGFkLWNoYXJ0LTEpIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgdmVjdG9yLWVmZmVjdD0ibm9uLXNjYWxpbmctc3Ryb2tlIiAvPjwvc3ZnPg==)

Subscribers

2,350
![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik03IDE3TDE3IDdNNyA3aDEwdjEwIiAvPjwvc3ZnPg==)
+180

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zcGFya2xpbmUiIHZpZXdib3g9IjAgMCAxMDAgMTAwIiBwcmVzZXJ2ZWFzcGVjdHJhdGlvPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHN0eWxlPSJ3aWR0aDoxMDAlO2hlaWdodDoyLjVyZW07IiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHJlY3QgeD0iMSIgd2lkdGg9IjE0LjY3IiB5PSIxMDAiIGhlaWdodD0iMC41IiBmaWxsPSJ2YXIoLS1zaGFkLWNoYXJ0LTIpIiBmaWxsLW9wYWNpdHk9IjAuMTgiIHJ4PSIxLjUiIC8+PHJlY3QgeD0iMTcuNjciIHdpZHRoPSIxNC42NyIgeT0iNjMuMTYiIGhlaWdodD0iMzYuODQiIGZpbGw9InZhcigtLXNoYWQtY2hhcnQtMikiIGZpbGwtb3BhY2l0eT0iMC4xOCIgcng9IjEuNSIgLz48cmVjdCB4PSIzNC4zMyIgd2lkdGg9IjE0LjY3IiB5PSI4NC4yMSIgaGVpZ2h0PSIxNS43OSIgZmlsbD0idmFyKC0tc2hhZC1jaGFydC0yKSIgZmlsbC1vcGFjaXR5PSIwLjE4IiByeD0iMS41IiAvPjxyZWN0IHg9IjUxIiB3aWR0aD0iMTQuNjciIHk9IjIxLjA1IiBoZWlnaHQ9Ijc4Ljk1IiBmaWxsPSJ2YXIoLS1zaGFkLWNoYXJ0LTIpIiBmaWxsLW9wYWNpdHk9IjAuMTgiIHJ4PSIxLjUiIC8+PHJlY3QgeD0iNjcuNjciIHdpZHRoPSIxNC42NyIgeT0iMzYuODQiIGhlaWdodD0iNjMuMTYiIGZpbGw9InZhcigtLXNoYWQtY2hhcnQtMikiIGZpbGwtb3BhY2l0eT0iMC4xOCIgcng9IjEuNSIgLz48cmVjdCB4PSI4NC4zMyIgd2lkdGg9IjE0LjY3IiB5PSIwIiBoZWlnaHQ9IjEwMCIgZmlsbD0idmFyKC0tc2hhZC1jaGFydC0yKSIgZmlsbC1vcGFjaXR5PSIwLjE4IiByeD0iMS41IiAvPjwvc3ZnPg==)

Code


    shad_value_box("$45,231", "Revenue", delta = "+20.1%", sparkline = shad_sparkline(c(31, 40, 28, 51, 42, 62), type = "area"))
    shad_value_box("2,350", "Subscribers", delta = "+180", sparkline = shad_sparkline(c(12, 19, 15, 27, 24, 31), type = "bar", color = 2))

## Mini donut

*A shadshiny addition: no shadcn/ui counterpart.*

[`shad_mini_donut()`](https://orijitghosh.github.io/shadshiny/reference/shad_mini_donut.md)
shows a few parts of a whole, with optional content in the middle.
`thickness = 1` gives a pie.

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1kb251dF9fc3ZnIiB2aWV3Ym94PSIwIDAgMTAwIDEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iMzkuMDYiIGZpbGw9Im5vbmUiIHN0cm9rZT0idmFyKC0tc2hhZC1tdXRlZCkiIHN0cm9rZS13aWR0aD0iMjEuODgiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjUwIiBjeT0iNTAiIHI9IjM5LjA2IiBmaWxsPSJub25lIiBzdHJva2U9InZhcigtLXNoYWQtY2hhcnQtMSkiIHN0cm9rZS13aWR0aD0iMjEuODgiIHN0cm9rZS1kYXNoYXJyYXk9IjE1Mi4xNyA5My4yNyIgc3Ryb2tlLWRhc2hvZmZzZXQ9IjAiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjUwIiBjeT0iNTAiIHI9IjM5LjA2IiBmaWxsPSJub25lIiBzdHJva2U9InZhcigtLXNoYWQtY2hhcnQtMikiIHN0cm9rZS13aWR0aD0iMjEuODgiIHN0cm9rZS1kYXNoYXJyYXk9IjU4LjkgMTg2LjUzIiBzdHJva2UtZGFzaG9mZnNldD0iLTE1Mi4xNyI+PC9jaXJjbGU+PGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iMzkuMDYiIGZpbGw9Im5vbmUiIHN0cm9rZT0idmFyKC0tc2hhZC1jaGFydC0zKSIgc3Ryb2tlLXdpZHRoPSIyMS44OCIgc3Ryb2tlLWRhc2hhcnJheT0iMzQuMzYgMjExLjA4IiBzdHJva2UtZGFzaG9mZnNldD0iLTIxMS4wOCI+PC9jaXJjbGU+PC9zdmc+)

62%

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1kb251dF9fc3ZnIiB2aWV3Ym94PSIwIDAgMTAwIDEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iMzMuMzMiIGZpbGw9Im5vbmUiIHN0cm9rZT0idmFyKC0tc2hhZC1tdXRlZCkiIHN0cm9rZS13aWR0aD0iMzMuMzMiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjUwIiBjeT0iNTAiIHI9IjMzLjMzIiBmaWxsPSJub25lIiBzdHJva2U9InZhcigtLXNoYWQtY2hhcnQtMSkiIHN0cm9rZS13aWR0aD0iMzMuMzMiIHN0cm9rZS1kYXNoYXJyYXk9IjE1Ny4wOCA1Mi4zNiIgc3Ryb2tlLWRhc2hvZmZzZXQ9IjAiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjUwIiBjeT0iNTAiIHI9IjMzLjMzIiBmaWxsPSJub25lIiBzdHJva2U9InZhcigtLXNoYWQtY2hhcnQtMikiIHN0cm9rZS13aWR0aD0iMzMuMzMiIHN0cm9rZS1kYXNoYXJyYXk9IjUyLjM2IDE1Ny4wOCIgc3Ryb2tlLWRhc2hvZmZzZXQ9Ii0xNTcuMDgiPjwvY2lyY2xlPjwvc3ZnPg==)

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1kb251dF9fc3ZnIiB2aWV3Ym94PSIwIDAgMTAwIDEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iMjUiIGZpbGw9Im5vbmUiIHN0cm9rZT0idmFyKC0tc2hhZC1tdXRlZCkiIHN0cm9rZS13aWR0aD0iNTAiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjUwIiBjeT0iNTAiIHI9IjI1IiBmaWxsPSJub25lIiBzdHJva2U9InZhcigtLXNoYWQtY2hhcnQtMSkiIHN0cm9rZS13aWR0aD0iNTAiIHN0cm9rZS1kYXNoYXJyYXk9IjExNy44MSAzOS4yNyIgc3Ryb2tlLWRhc2hvZmZzZXQ9IjAiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjUwIiBjeT0iNTAiIHI9IjI1IiBmaWxsPSJub25lIiBzdHJva2U9InZhcigtLXNoYWQtY2hhcnQtMikiIHN0cm9rZS13aWR0aD0iNTAiIHN0cm9rZS1kYXNoYXJyYXk9IjM5LjI3IDExNy44MSIgc3Ryb2tlLWRhc2hvZmZzZXQ9Ii0xMTcuODEiPjwvY2lyY2xlPjwvc3ZnPg==)

![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1kb251dF9fc3ZnIiB2aWV3Ym94PSIwIDAgMTAwIDEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiBhcmlhLWhpZGRlbj0idHJ1ZSI+PGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iMzkuMDYiIGZpbGw9Im5vbmUiIHN0cm9rZT0idmFyKC0tc2hhZC1tdXRlZCkiIHN0cm9rZS13aWR0aD0iMjEuODgiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjUwIiBjeT0iNTAiIHI9IjM5LjA2IiBmaWxsPSJub25lIiBzdHJva2U9InZhcigtLXNoYWQtY2hhcnQtMSkiIHN0cm9rZS13aWR0aD0iMjEuODgiIHN0cm9rZS1kYXNoYXJyYXk9IjQ5LjA5IDE5Ni4zNSIgc3Ryb2tlLWRhc2hvZmZzZXQ9IjAiPjwvY2lyY2xlPjxjaXJjbGUgY3g9IjUwIiBjeT0iNTAiIHI9IjM5LjA2IiBmaWxsPSJub25lIiBzdHJva2U9InZhcigtLXNoYWQtY2hhcnQtMikiIHN0cm9rZS13aWR0aD0iMjEuODgiIHN0cm9rZS1kYXNoYXJyYXk9IjQ5LjA5IDE5Ni4zNSIgc3Ryb2tlLWRhc2hvZmZzZXQ9Ii00OS4wOSI+PC9jaXJjbGU+PGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iMzkuMDYiIGZpbGw9Im5vbmUiIHN0cm9rZT0idmFyKC0tc2hhZC1jaGFydC0zKSIgc3Ryb2tlLXdpZHRoPSIyMS44OCIgc3Ryb2tlLWRhc2hhcnJheT0iNDkuMDkgMTk2LjM1IiBzdHJva2UtZGFzaG9mZnNldD0iLTk4LjE3Ij48L2NpcmNsZT48Y2lyY2xlIGN4PSI1MCIgY3k9IjUwIiByPSIzOS4wNiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJ2YXIoLS1zaGFkLWNoYXJ0LTQpIiBzdHJva2Utd2lkdGg9IjIxLjg4IiBzdHJva2UtZGFzaGFycmF5PSI0OS4wOSAxOTYuMzUiIHN0cm9rZS1kYXNob2Zmc2V0PSItMTQ3LjI2Ij48L2NpcmNsZT48Y2lyY2xlIGN4PSI1MCIgY3k9IjUwIiByPSIzOS4wNiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSJ2YXIoLS1zaGFkLWNoYXJ0LTUpIiBzdHJva2Utd2lkdGg9IjIxLjg4IiBzdHJva2UtZGFzaGFycmF5PSI0OS4wOSAxOTYuMzUiIHN0cm9rZS1kYXNob2Zmc2V0PSItMTk2LjM1Ij48L2NpcmNsZT48L3N2Zz4=)

Code


    shad_mini_donut(c(62, 24, 14), center = "62%")
    shad_mini_donut(c(3, 1), size = "5rem", thickness = 0.5)
    shad_mini_donut(c(3, 1), size = "5rem", thickness = 1)
    shad_mini_donut(c(1, 1, 1, 1, 1), size = "5rem")

## Chart container

[`shad_chart_container()`](https://orijitghosh.github.io/shadshiny/reference/shad_chart_container.md)
is the card shell around a
[`plotOutput()`](https://rdrr.io/pkg/shiny/man/plotOutput.html) or any
htmlwidget, with an optional legend strip. The stage below holds a
static image in place of a plot, since these pages have no R server
behind them.

Revenue by month

Jan – Jun 2026

This year Last year

Code


    shad_chart_container(title = "Revenue by month", description = "Jan – Jun 2026", legend = TRUE, legend_labels = c("This year", "Last year"), aspect = "wide", shad_skeleton(width = "100%", height = "100%"))

In an app the child is your plot, and
[`shad_theme_ggplot2()`](https://orijitghosh.github.io/shadshiny/reference/shad_theme_ggplot2.md)
(or the plotly / echarts4r equivalents) restyles the figure onto the
active palette:

``` r

output$plot <- renderPlot({
  shad_current_theme()          # re-render when the theme changes at runtime
  ggplot(df, aes(month, revenue)) +
    geom_col(fill = shad_chart_colors(1)) +
    shad_theme_ggplot2()
})
```

## Timeline

*A shadshiny addition: no shadcn/ui counterpart.*

1.  
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMCA2IDkgMTdsLTUtNSIgLz48L3N2Zz4=)
    09:14
    Order placed

    Payment authorised.
2.  
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xMSAyMS43M2EyIDIgMCAwIDAgMiAwbDctNEEyIDIgMCAwIDAgMjEgMTZWOGEyIDIgMCAwIDAtMS0xLjczbC03LTRhMiAyIDAgMCAwLTIgMGwtNyA0QTIgMiAwIDAgMCAzIDh2OGEyIDIgMCAwIDAgMSAxLjczeiIgLz48cGF0aCBkPSJNMy4yOSA3IDEyIDEybDguNzEtNSIgLz48cGF0aCBkPSJNMTIgMjJWMTIiIC8+PC9zdmc+)
    11:02
    Packed

    Left the fulfilment centre.
3.  
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMCAxMGMwIDQuOTkzLTUuNTM5IDEwLjE5My03LjM5OSAxMS43OTlhMSAxIDAgMCAxLTEuMjAyIDBDOS41MzkgMjAuMTkzIDQgMTQuOTkzIDQgMTBhOCA4IDAgMCAxIDE2IDAiIC8+PGNpcmNsZSBjeD0iMTIiIGN5PSIxMCIgcj0iMyI+PC9jaXJjbGU+PC9zdmc+)
    14:30
    In transit

    Out for delivery.
4.  
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Im0zIDkgOS03IDkgN3YxMWEyIDIgMCAwIDEtMiAySDVhMiAyIDAgMCAxLTItMnoiIC8+PHBvbHlsaW5lIHBvaW50cz0iOSAyMiA5IDEyIDE1IDEyIDE1IDIyIj48L3BvbHlsaW5lPjwvc3ZnPg==)
    Delivered

    Expected today by 18:00.

Code


    shad_timeline(shad_timeline_item("Order placed", time = "09:14", description = "Payment authorised.", icon = "check"), shad_timeline_item("Packed", time = "11:02", description = "Left the fulfilment centre.", icon = "package"), shad_timeline_item("In transit", time = "14:30", status = "active", description = "Out for delivery.", icon = "map-pin"), shad_timeline_item("Delivered", status = "muted", last = TRUE, description = "Expected today by 18:00.", icon = "home"))

## Stepper

*A shadshiny addition: no shadcn/ui counterpart.*

[`shad_stepper()`](https://orijitghosh.github.io/shadshiny/reference/shad_stepper.md)
holds the **1-based** index of the active step. `linear = TRUE` stops
the user skipping ahead of the current step.

1.   1
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX19jaGVjayIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIzIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48cGF0aCBkPSJNNCAxMmw1IDVMMjAgNyIgcGF0aGxlbmd0aD0iMSIgLz48L3N2Zz4=)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX194IiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjMiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik02IDZsMTIgMTJNMTggNkw2IDE4IiAvPjwvc3ZnPg==)
    Account Email and password
2.   2
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX19jaGVjayIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIzIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48cGF0aCBkPSJNNCAxMmw1IDVMMjAgNyIgcGF0aGxlbmd0aD0iMSIgLz48L3N2Zz4=)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX194IiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjMiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik02IDZsMTIgMTJNMTggNkw2IDE4IiAvPjwvc3ZnPg==)
    Profile Name and avatar
3.   3
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX19jaGVjayIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIzIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48cGF0aCBkPSJNNCAxMmw1IDVMMjAgNyIgcGF0aGxlbmd0aD0iMSIgLz48L3N2Zz4=)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX194IiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjMiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik02IDZsMTIgMTJNMTggNkw2IDE4IiAvPjwvc3ZnPg==)
    Billing Card details
4.   4
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX19jaGVjayIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIzIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48cGF0aCBkPSJNNCAxMmw1IDVMMjAgNyIgcGF0aGxlbmd0aD0iMSIgLz48L3N2Zz4=)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX194IiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjMiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik02IDZsMTIgMTJNMTggNkw2IDE4IiAvPjwvc3ZnPg==)
    Done Confirm

1.   1
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX19jaGVjayIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIzIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48cGF0aCBkPSJNNCAxMmw1IDVMMjAgNyIgcGF0aGxlbmd0aD0iMSIgLz48L3N2Zz4=)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX194IiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjMiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik02IDZsMTIgMTJNMTggNkw2IDE4IiAvPjwvc3ZnPg==)
    Draft
2.   2
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX19jaGVjayIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIzIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48cGF0aCBkPSJNNCAxMmw1IDVMMjAgNyIgcGF0aGxlbmd0aD0iMSIgLz48L3N2Zz4=)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX194IiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjMiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik02IDZsMTIgMTJNMTggNkw2IDE4IiAvPjwvc3ZnPg==)
    In review Waiting on a second approver
3.   3
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX19jaGVjayIgdmlld2JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIzIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGFyaWEtaGlkZGVuPSJ0cnVlIj48cGF0aCBkPSJNNCAxMmw1IDVMMjAgNyIgcGF0aGxlbmd0aD0iMSIgLz48L3N2Zz4=)![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1zdGVwcGVyX194IiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjMiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik02IDZsMTIgMTJNMTggNkw2IDE4IiAvPjwvc3ZnPg==)
    Published

Code


    shad_stepper("wiz", active = 2, shad_step("Account", description = "Email and password"), shad_step("Profile", description = "Name and avatar"), shad_step("Billing", description = "Card details"), shad_step("Done", description = "Confirm"))
    shad_stepper("wiz_v", active = 2, orientation = "vertical", shad_step("Draft"), shad_step("In review", description = "Waiting on a second approver"), shad_step("Published", error = TRUE))

## Tree

*A shadshiny addition: no shadcn/ui counterpart.*

[`shad_tree_item()`](https://orijitghosh.github.io/shadshiny/reference/shad_tree_item.md)
takes the value first, then the label. Nest items to build branches;
`lazy = TRUE` marks a branch whose children arrive later via
`update_shad_tree(children=)`.

- ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC10cmVlX19jaGV2cm9uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik05IDZsNiA2LTYgNiIgLz48L3N2Zz4=)
  ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMCAyMGEyIDIgMCAwIDAgMi0yVjhhMiAyIDAgMCAwLTItMmgtNy45YTIgMiAwIDAgMS0xLjY5LS45TDkuNiAzLjlBMiAyIDAgMCAwIDcuOTMgM0g0YTIgMiAwIDAgMC0yIDJ2MTNhMiAyIDAgMCAwIDIgMloiIC8+PC9zdmc+)
  R

  - ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC10cmVlX19jaGV2cm9uIHNoYWQtdHJlZV9fY2hldnJvbi0tbGVhZiIgdmlld2JveD0iMCAwIDI0IDI0IiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTkgNmw2IDYtNiA2IiAvPjwvc3ZnPg==)
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xNSAySDZhMiAyIDAgMCAwLTIgMnYxNmEyIDIgMCAwIDAgMiAyaDEyYTIgMiAwIDAgMCAyLTJWN1oiIC8+PHBhdGggZD0iTTE0IDJ2NGEyIDIgMCAwIDAgMiAyaDQiIC8+PC9zdmc+)
    app.R

  - ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC10cmVlX19jaGV2cm9uIHNoYWQtdHJlZV9fY2hldnJvbi0tbGVhZiIgdmlld2JveD0iMCAwIDI0IDI0IiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTkgNmw2IDYtNiA2IiAvPjwvc3ZnPg==)
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xNSAySDZhMiAyIDAgMCAwLTIgMnYxNmEyIDIgMCAwIDAgMiAyaDEyYTIgMiAwIDAgMCAyLTJWN1oiIC8+PHBhdGggZD0iTTE0IDJ2NGEyIDIgMCAwIDAgMiAyaDQiIC8+PC9zdmc+)
    ui.R

- ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC10cmVlX19jaGV2cm9uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik05IDZsNiA2LTYgNiIgLz48L3N2Zz4=)
  ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMCAyMGEyIDIgMCAwIDAgMi0yVjhhMiAyIDAgMCAwLTItMmgtNy45YTIgMiAwIDAgMS0xLjY5LS45TDkuNiAzLjlBMiAyIDAgMCAwIDcuOTMgM0g0YTIgMiAwIDAgMC0yIDJ2MTNhMiAyIDAgMCAwIDIgMloiIC8+PC9zdmc+)
  www

  - ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC10cmVlX19jaGV2cm9uIHNoYWQtdHJlZV9fY2hldnJvbi0tbGVhZiIgdmlld2JveD0iMCAwIDI0IDI0IiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTkgNmw2IDYtNiA2IiAvPjwvc3ZnPg==)
    ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xNSAySDZhMiAyIDAgMCAwLTIgMnYxNmEyIDIgMCAwIDAgMiAyaDEyYTIgMiAwIDAgMCAyLTJWN1oiIC8+PHBhdGggZD0iTTE0IDJ2NGEyIDIgMCAwIDAgMiAyaDQiIC8+PC9zdmc+)
    style.css

- ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC10cmVlX19jaGV2cm9uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik05IDZsNiA2LTYgNiIgLz48L3N2Zz4=)
  ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMCAyMGEyIDIgMCAwIDAgMi0yVjhhMiAyIDAgMCAwLTItMmgtNy45YTIgMiAwIDAgMS0xLjY5LS45TDkuNiAzLjlBMiAyIDAgMCAwIDcuOTMgM0g0YTIgMiAwIDAgMC0yIDJ2MTNhMiAyIDAgMCAwIDIgMloiIC8+PC9zdmc+)
  data

- ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC10cmVlX19jaGV2cm9uIHNoYWQtdHJlZV9fY2hldnJvbi0tbGVhZiIgdmlld2JveD0iMCAwIDI0IDI0IiBhcmlhLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTkgNmw2IDYtNiA2IiAvPjwvc3ZnPg==)
  ![](data:image/svg+xml;base64,PHN2ZyBjbGFzcz0ic2hhZC1pY29uIiB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xNSAySDZhMiAyIDAgMCAwLTIgMnYxNmEyIDIgMCAwIDAgMiAyaDEyYTIgMiAwIDAgMCAyLTJWN1oiIC8+PHBhdGggZD0iTTE0IDJ2NGEyIDIgMCAwIDAgMiAyaDQiIC8+PC9zdmc+)
  README.md

Code


    shad_tree("files", selected = "app.R", selection = "single", shad_tree_item("R", "R", icon = "folder", expanded = TRUE, shad_tree_item("app.R", "app.R", icon = "file"), shad_tree_item("ui.R", "ui.R", icon = "file")), shad_tree_item("www", "www", icon = "folder", shad_tree_item("style.css", "style.css", icon = "file")), shad_tree_item("data", "data", icon = "folder", lazy = TRUE), shad_tree_item("README", "README.md", icon = "file"))

## Rating

*A shadshiny addition: no shadcn/ui counterpart.*

Rating

Half steps

Read-only

Ten stars

Code


    shad_rating("r1", label = "Rating", value = 3)
    shad_rating("r2", label = "Half steps", value = 3.5, half = TRUE)
    shad_rating("r3", label = "Read-only", value = 4, readonly = TRUE)
    shad_rating("r4", label = "Ten stars", value = 7, max = 10, size = "sm")

## Number input

*A shadshiny addition: no shadcn/ui counterpart.*

A text input with hold-to-repeat stepper buttons. `precision` fixes the
decimal places; `min` / `max` clamp the value.

Quantity

![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik01IDEyaDE0IiAvPjwvc3ZnPg==)

![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xMiA1djE0TTUgMTJoMTQiIC8+PC9zdmc+)

Price

![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik01IDEyaDE0IiAvPjwvc3ZnPg==)

![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xMiA1djE0TTUgMTJoMTQiIC8+PC9zdmc+)

Disabled

![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik01IDEyaDE0IiAvPjwvc3ZnPg==)

![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xMiA1djE0TTUgMTJoMTQiIC8+PC9zdmc+)

Code


    shad_number_input("qty", label = "Quantity", value = 1, min = 0, max = 99)
    shad_number_input("price", label = "Price", value = 9.99, step = 0.01, precision = 2)
    shad_number_input("dis", label = "Disabled", value = 5, disabled = TRUE)

## Dropzone

*A shadshiny addition: no shadcn/ui counterpart.*

[`shad_dropzone()`](https://orijitghosh.github.io/shadshiny/reference/shad_dropzone.md)
bridges to a hidden
[`fileInput()`](https://rdrr.io/pkg/shiny/man/fileInput.html), so
`input$<id>` is the **standard Shiny files data frame** (`name`, `size`,
`type`, `datapath`) — every `renderTable(input$files)` you already have
keeps working.

Browse...

Attachments

![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMSAxNXY0YTIgMiAwIDAgMS0yIDJINWEyIDIgMCAwIDEtMi0ydi00IiAvPjxwYXRoIGQ9Ik0xNyA4bC01LTUtNSA1IiAvPjxwYXRoIGQ9Ik0xMiAzdjEyIiAvPjwvc3ZnPg==)

CSV or Excel, up to 5 MB each

Browse...

Avatar

![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0yMSAxNXY0YTIgMiAwIDAgMS0yIDJINWEyIDIgMCAwIDEtMi0ydi00IiAvPjxwYXRoIGQ9Ik0xNyA4bC01LTUtNSA1IiAvPjxwYXRoIGQ9Ik0xMiAzdjEyIiAvPjwvc3ZnPg==)

PNG or JPG, square works best

Code


    shad_dropzone("files", label = "Attachments", multiple = TRUE, accept = c(".csv", ".xlsx"), hint = "CSV or Excel, up to 5 MB each")
    shad_dropzone("avatar", label = "Avatar", accept = "image/*", hint = "PNG or JPG, square works best")

## Form messaging

*[`shad_form_summary()`](https://orijitghosh.github.io/shadshiny/reference/shad_form_summary.md)
is a shadshiny addition; the rest mirrors shadcn/ui’s Form messaging.*

The pieces
[`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md)
drives from the server. In an app you rarely place these by hand — the
validator sets them for you — but they’re plain components.

![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik00IDEybDUgNUwyMCA3IiAvPjwvc3ZnPg==)
Looks good.

![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjEyIiBjeT0iMTIiIHI9IjEwIj48L2NpcmNsZT48cGF0aCBkPSJNMTIgOHY0TTEyIDE2aC4wMSIgLz48L3N2Zz4=)
Enter a valid email address.

![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxwYXRoIGQ9Ik0xMC4zIDMuODZMMS44MiAxOGEyIDIgMCAwIDAgMS43MSAzaDE2Ljk0YTIgMiAwIDAgMCAxLjcxLTNMMTMuNyAzLjg2YTIgMiAwIDAgMC0zLjQgMHoiIC8+PHBhdGggZD0iTTEyIDl2NE0xMiAxN2guMDEiIC8+PC9zdmc+)
This name is already taken.

214/280

![](data:image/svg+xml;base64,PHN2ZyB2aWV3Ym94PSIwIDAgMjQgMjQiIGZpbGw9Im5vbmUiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgYXJpYS1oaWRkZW49InRydWUiPjxjaXJjbGUgY3g9IjEyIiBjeT0iMTIiIHI9IjEwIj48L2NpcmNsZT48cGF0aCBkPSJNMTIgOHY0TTEyIDE2aC4wMSIgLz48L3N2Zz4=)
Please fix the errors below

- [Enter a valid email address.](#email)
- [Password must be at least 8 characters.](#pw)

Code


    shad_form_message("Looks good.", type = "success")
    shad_form_message("Enter a valid email address.", type = "error")
    shad_form_message("This name is already taken.", type = "warning")
    shad_form_counter(214, 280)
    shad_form_summary("errs", errors = c(email = "Enter a valid email address.", pw = "Password must be at least 8 characters."))

## See also

- [Data
  tables](https://orijitghosh.github.io/shadshiny/articles/data-tables.md)
  — the full table API.
- [Dashboards &
  charts](https://orijitghosh.github.io/shadshiny/articles/charts.md) —
  plot theming and the
  [`shad_current_theme()`](https://orijitghosh.github.io/shadshiny/reference/shad_current_theme.md)
  reactive bridge.
- [Forms &
  validation](https://orijitghosh.github.io/shadshiny/articles/forms.md)
  — wiring
  [`shad_validator()`](https://orijitghosh.github.io/shadshiny/reference/shad_validator.md).
- `shad_run_example("07-data-explorer")` and
  `shad_run_example("08-llm-chat")` are full apps built on this kit.
