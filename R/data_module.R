# start ui module
data_ui <- function(id) {

  ns <- shiny::NS(id)

  shiny::tagList(

    br(),
    br(),

    div(
      class = "row text-center",
      style = 'padding-bottom: 50px;',
      div(
        id = "get-date",
        class = "col-xl-3 col-md-3 col-sm-3 text-center",
        style = "padding-top: 20px;",
        shiny::actionLink(
          inputId = ns("toggle_date"),
          label = "",
          icon = shiny::icon("angle-down")
        ),
        div(
          style = "padding: 10px;",
          id = ns("show_dates"),
          shiny::dateRangeInput(
            inputId = ns("google_data"),
            label = "Choose Time Frame",
            start = Sys.Date() - 7,
            end = Sys.Date(),
            min = Sys.Date() - 30,
            max = Sys.Date(),
            width = "100%"
          ),
          actionButton(
            inputId = ns("go"),
            label = "",
            icon = shiny::icon("filter")
          )
        ) %>% shinyjs::hidden()
      ),
      div(
        class = "col-xl-6 col-md-6 col-sm-6",
        h1("Google Analytics Dashboard")
      ),
      div(
        id = "slide",
        class = "col-xl-3 col-md-3 col-sm-3",
        style = "padding-top: 20px;",
        shiny::actionLink(
          inputId = "open",
          label = "",
          icon = shiny::icon("bars"),
          onclick = "open_sidebar()"
        )
      )
    )
  )

}

# start server module
data_server <- function(id, auth) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      # toggle dates and filter icon
      shiny::observeEvent(input$toggle_date, {
        shinyjs::toggle(id = "show_dates", anim = TRUE)
      })


      shinyjs::click(id = "go")

      get_data <- shiny::reactive({
        shiny::req(auth())
        return(auth() + input$go)
      })

      web_data <- shiny::eventReactive(get_data(), {

        date_1 <- input$google_data[1]
        date_2 <- input$google_data[2]

        web_data <-
          googleAnalyticsR::google_analytics(
            my_id,
            date_range = c(date_1,
                           date_2),
            metrics = c("sessions","pageviews",
                        "entrances","bounces", "bounceRate", "sessionDuration"),
            dimensions = c("date","deviceCategory", "hour", "dayOfWeekName",
                           "channelGrouping", "source", "keyword", "pagePath"),
            anti_sample = TRUE
          ) %>%
          janitor::clean_names() %>%
          dplyr::mutate(page_path = stringr::str_remove_all(page_path, ".*[0-9+]/") %>%
                          stringr::str_remove_all("\\/"))


        searchConsoleR::search_analytics(
          website,
          start = date_1, end = date_2,
          dimensions = c("page", "query", "country", "date"),
          rowLimit = 5000
        ) %>%
          janitor::clean_names() -> web_data_c

        return(
          list(
            ga = web_data,
            sc = web_data_c
          )
        )

      })

      return(
        list(
          new_ga = shiny::reactive(web_data()$ga),
          new_sc = shiny::reactive(web_data()$sc),
          new_data_btn = shiny::reactive(input$go)
        )
      )

    }

  )

}
