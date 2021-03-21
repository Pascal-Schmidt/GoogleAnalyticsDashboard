cards_ui <- function(id) {

  ns <- shiny::NS(id)

  shiny::tagList(
    div(
      id = ns("insert_value_cards")
    )
  )

}

cards_server <- function(id, df, btn) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      ns <- shiny::NS(id)

      inserted_ui_element <- shiny::reactive({

        shiny::req(btn() == 1)
        html <- div(
          class = "row eq-height",
          shiny::tagList(
            create_cards(time_series_pageviews(df())$cards_sessions),
            create_cards(time_series_pageviews(df())$cards_pageviews),
            create_cards(bounce_rate(df())$cards_bounce_rate),
            create_cards(session_duration(df()))
          )
        )

      })

      shiny::observe({
        shiny::insertUI(
          selector = paste0("#", ns("insert_value_cards")),
          where = "afterBegin",
          ui = inserted_ui_element()
        )
      })

    }

  )

}
