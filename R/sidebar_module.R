sidebar_ui <- function(id) {

  ns <- shiny::NS(id)

  shiny::tagList(
    div(
      div(
        id = "entire-sidebar",
        span(
          id = "menu",
          class = "nav",
          div(
            style = "color: white;",
            h1("Charts")
          ),
          shiny::actionLink(
            inputId = "close",
            label = "",
            icon = shiny::icon("times"),
            onclick = "close_sidebar()"
          ),
          shiny::uiOutput(outputId = ns("sidebar_viz"))
        )
      )

    )
  )

}

sidebar_server <- function(id, auth, db_viz, data_btn) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      rv <- shiny::reactiveValues()

      # only used when action button first clicked
      shiny::observe({
        shiny::req((data_btn() == 1) & auth() & is.null(names(rv$x)))
        rv$x <- db_viz()
        rv$x <- all_visualizations[!(unname(all_visualizations) %in% rv$x)]
      })

      output$sidebar_viz <- shiny::renderUI({

        purrr::map2(
          .x = rv$x, .y = names(rv$x),
          ~ div(
            class = paste0("added_", .x),
            graphs(
              input_id = .x,
              txt = .y
            )
          )
        )

      })

    }

  )

}
