cards_ui <- function(id) {

  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::uiOutput(outputId = ns("value_cards"))
  )

}

cards_server <- function(id, df) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      output$value_cards <- shiny::renderUI({

        shiny::req(!is.null(df()), nrow(df()) > 0)
        div(
          class = "row eq-height",
          shiny::tagList(
            create_cards(time_series_pageviews(df())$cards_sessions),
            create_cards(time_series_pageviews(df())$cards_pageviews),
            create_cards(bounce_rate(df())$cards_bounce_rate),
            create_cards(session_duration(df()))
          )
        )

      })

    }

  )

}
