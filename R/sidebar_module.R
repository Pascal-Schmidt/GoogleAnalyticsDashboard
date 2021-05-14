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

      # only used when action button first clicked
      sidebar_plots <- shiny::reactive({
        shiny::req((data_btn() == 1) & auth())
        x <- db_viz()
        x <- all_visualizations[!(unname(all_visualizations) %in% db_viz())]
        return(x)
      })

      output$sidebar_viz <- shiny::renderUI({
        sidebar_plots <- shiny::isolate(sidebar_plots())
        purrr::map2(
          .x = sidebar_plots, .y = names(sidebar_plots),
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
