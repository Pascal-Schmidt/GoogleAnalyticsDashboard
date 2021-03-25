ui_time_series <- function(id) {

  ns <- shiny::NS(id)

  shiny::tagList(
    div(
      class = "container",
      id = "time_series_out",
      plotly::plotlyOutput(outputId = ns("plotly"), height = "600px"),
      DT::DTOutput(outputId = ns("data"))
    )
  )

}

server_time_series <- function(id, df) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      time_series <- shiny::reactive({

        actual_df <- df() %>%
          dplyr::group_by(date) %>%
          dplyr::summarise(page_views = sum(pageviews))

        new_dat <- validation %>%
          dplyr::select(-page_views) %>%
          dplyr::left_join(actual_df, by = "date")

        if(!is.na(new_dat$page_views[1])) {
          data_dt <- refit_tbl[, 1:3] %>%
            modeltime::modeltime_calibrate(
              new_data = new_dat %>%
                dplyr::filter(!is.na(page_views))
            ) %>%
            modeltime::modeltime_accuracy()
        } else {
          data_dt <- NULL
        }

        plot_plotly <- refit_tbl %>%
          modeltime::modeltime_forecast(
            new_data = new_dat,
            actual_data = actual_df
          ) %>%
          modeltime::plot_modeltime_forecast(
            .legend_show = FALSE,
            .conf_interval_show = FALSE
          )


        return(
          list(
            dt = data_dt,
            plot = plot_plotly
          )
        )

      })

      output$plotly <- plotly::renderPlotly({
        time_series()$plot
      })

      output$data <- DT::renderDT({
        DT::datatable(time_series()$dt)
      })



    }

  )

}
