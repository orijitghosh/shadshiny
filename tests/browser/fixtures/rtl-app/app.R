library(shiny)
library(shadshiny)

rows <- data.frame(
  الاسم = c("ألف", "باء", "جيم"),
  الحالة = c("نشط", "معلّق", "مكتمل"),
  stringsAsFactors = FALSE
)

ui <- page_shad(
  dir = "rtl", lang = "ar",
  shad_sidebar_layout(
    "rtl-sidebar",
    sidebar = shad_sidebar(
      shad_sidebar_group(
        "التنقل",
        shad_sidebar_item("home", "الرئيسية", active = TRUE),
        shad_sidebar_item("reports", "التقارير")
      )
    ),
    main = tags$main(
      id = "rtl-fixture",
      style = "padding: 1.5rem; display: grid; gap: 1.25rem; max-width: 86rem; margin: 0 auto;",
      tags$h1("اختبار الاتجاه من اليمين إلى اليسار"),
      tags$p(
        id = "rtl-status",
        tags$strong("الاتجاه: "), tags$span("rtl", id = "direction-value")
      ),
      tags$section(
        id = "rtl-overlays",
        tags$h2("النوافذ العائمة"),
        shad_dialog(
          "rtl-dialog", trigger = shad_button("فتح الحوار"),
          title = "حوار عربي", description = "نص داخل بوابة الاتجاه.",
          shad_message(tags$span(dir = "auto", "שלום / English")),
          footer = shad_dialog_close_button("إغلاق الحوار")
        ),
        shad_sheet(
          "rtl-sheet", side = "right", trigger = shad_button("فتح اللوحة"),
          title = "لوحة جانبية", "محتوى اللوحة", footer = shad_button("تم")
        ),
        shad_dropdown_menu(
          "rtl-menu", trigger = shad_button("فتح القائمة"),
          shad_menu_item("profile", "الملف الشخصي"),
          shad_menu_sub("المزيد", shad_menu_item("help", "المساعدة"))
        ),
        shad_select(
          "rtl-select", label = "اختيار", choices = c("أول" = "one", "ثان" = "two")
        ),
        shad_combobox(
          "rtl-combobox", label = "بحث", choices = c("ألف", "باء", "جيم")
        ),
        shad_calendar("rtl-calendar", value = as.Date("2026-08-28")),
        shad_popover(
          "rtl-popover", trigger = shad_button("فتح التلميح الموسّع"),
          "محتوى منبثق"
        ),
        shad_tooltip(shad_button("مرّر هنا"), "تلميح عربي")
      ),
      tags$section(
        id = "rtl-navigation",
        tags$h2("عناصر الاتجاه"),
        shad_pagination("rtl-pagination", pages = 5),
        shad_carousel(
          "rtl-carousel",
          shad_carousel_item(tags$strong("الشريحة الأولى")),
          shad_carousel_item(tags$strong("الشريحة الثانية")),
          shad_carousel_item(tags$strong("الشريحة الثالثة"))
        ),
        shad_stepper(
          "rtl-stepper",
          shad_step("الحساب"), shad_step("الملف"), shad_step("المراجعة")
        ),
        shad_timeline(
          shad_timeline_item("تم الإنشاء", time = "اليوم", status = "active"),
          shad_timeline_item("تمت المراجعة", time = "غداً")
        )
      ),
      tags$section(
        id = "rtl-data",
        tags$h2("البيانات والمحتوى المختلط"),
        shad_data_table("rtl-table", rows, filter = "global", dir = "auto"),
        shad_table(rows, striped = TRUE, hover = TRUE),
        shad_tree(
          "rtl-tree",
          shad_tree_item("src", "المصدر", expanded = TRUE,
                         shad_tree_item("app", "التطبيق"),
                         shad_tree_item("utils", "الأدوات")),
          shad_tree_item("data", "البيانات")
        ),
        shad_rating("rtl-rating", label = "التقييم", value = 3),
        tags$div(id = "mixed-content", dir = "auto",
                 shad_message(tags$span("עברית / English / العربية")))
      ),
      tags$section(
        id = "rtl-chat",
        tags$h2("المحادثة"),
        shad_chat_ui("chat", height = "12rem", welcome = "ابدأ محادثة")
      ),
      tags$section(
        id = "ltr-nested", dir = "ltr",
        tags$h2("Nested LTR"),
        shad_popover(
          "ltr-popover", trigger = shad_button("Open LTR popover"),
          tags$span(dir = "auto", "English / العربية")
        )
      ),
      shad_command(
        "rtl-command", dialog = TRUE, hotkey = TRUE,
        shad_command_group("الأوامر",
                           shad_command_item("first", "الأول"),
                           shad_command_item("second", "الثاني"))
      )
    )
  )
)

shinyApp(ui, function(input, output, session) {})
