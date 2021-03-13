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

sidebar_server <- function(id) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      output$sidebar_viz <- shiny::renderUI({

        x <- c(`Time Series Graph` = "a", `Most Popular Posts` = "b", `Device Category` = "h",
               `CTR By Position` = "i")
        purrr::map2(
          .x = x, .y = names(x),
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
