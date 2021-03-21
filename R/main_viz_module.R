all_visualizations <- c(
  `Visitor Map` = "c", `Bounce Rate` = "e",
  `Week Day Sessions` = "f", `Channels` = "g",
  `Time Series Graph` = "a", `Most Popular Posts` = "b",
  `Device Category` = "h", `CTR By Position` = "i"
)
what_df <- c(
  `Visitor Map` = "sc", `Bounce Rate` = "ga",
  `Week Day Sessions` = "ga", `Channels` = "ga",
  `Time Series Graph` = "ga", `Most Popular Posts` = "ga",
  `Device Category` = "ga", `CTR By Position` = "sc"
)

main_viz_ui <- function(id) {

  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::uiOutput(
      outputId = ns("first")
    )
  )

}


main_viz_server <- function(id, data_btn, ga, sc, js_btn,
                            what_viz, last_panel, get_current_viz) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      ns <- session$ns

      # from database first
      rv <- shiny::reactiveValues(
        x = c(`Visitor Map` = "c", `Bounce Rate` = "e",
              `Week Day Sessions` = "f", `Channels` = "g"),
        single_viz = NULL
      )

      # only used when action button first clicked
      shiny::observeEvent(data_btn(), {
        shiny::req(data_btn() == 1)
        rv$dfs <- what_df[names(what_df) %in% names(rv$x)]
      })

      # when data refreshes all displayed plots will be re-created
      shiny::observeEvent(data_btn(), {
        shiny::req(data_btn() >= 2)
        rv$x <- all_visualizations[all_visualizations %in% get_current_viz()]
        rv$dfs <- what_df[names(what_df) %in% names(rv$x)]
      })

      # runs when app is opened and when data changes
      output$first <- shiny::renderUI({

        shiny::req(!is.null(ga()) | !is.null(sc()))
        purrr::pmap(
          list(x = rv$x, y = names(rv$x), z = rv$dfs),

          function(x, y, z)
            google_analytics_viz(
              title = y,
              viz = y,
              df = if(z == "ga"){ga()}else{sc()},
              btn_id = x,
              class_all = "delete",
              class_specific = paste0("class_", x),
              color = "danger"
            )
        )

      })

      # run when we add visualization
      shiny::observeEvent(js_btn(), {

        panel <- js_btn()
        rv$single_viz <- unname(what_df[names(what_df) %in% what_viz()])

        panel_plot_item <-
          google_analytics_viz(
            title = what_viz(),
            viz = what_viz(),
            df = if(rv$single_viz == "ga"){ga()}else{sc()},
            btn_id = panel,
            class_all = "delete",
            class_specific = paste0("class_", panel),
            color = "danger"
          )

        css_selector <- ifelse(last_panel() == "#placeholder",
                               "#placeholder",
                               paste0(".", last_panel()))

        shiny::insertUI(
          selector = css_selector,
          "afterEnd",
          ui = panel_plot_item
        )

      })

    }

  )

}
