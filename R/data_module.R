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
          inputId = "toggle_date",
          label = "",
          icon = shiny::icon("angle-down")
        ),
        div(
          style = "padding: 10px;",
          id = "data_go",
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

data_server <- function(id, my_id) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      shiny::observeEvent(input$toggle_date, {
        shinyjs::toggle(id = "data_go", anim = TRUE)
      })

      web_data <- shiny::eventReactive(input$go, {

        web_data <- google_analytics(my_id,
                                     date_range = c(as.character(input$google_data[1]),
                                                    as.character(input$google_data[2])),
                                     metrics = c("sessions","pageviews",
                                                 "entrances","bounces", "bounceRate", "sessionDuration"),
                                     dimensions = c("date","deviceCategory", "hour", "dayOfWeekName",
                                                    "channelGrouping", "source", "keyword", "pagePath"),
                                     anti_sample = TRUE) %>%
          janitor::clean_names() %>%
          dplyr::mutate(page_path = stringr::str_remove_all(page_path, ".*[0-9+]/") %>%
                          stringr::str_remove_all("\\/"))

        return(web_data)

      })

      return(web_data)

    }

  )

}
