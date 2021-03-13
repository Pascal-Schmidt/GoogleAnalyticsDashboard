switch_fn <- function(viz) {

  base::switch(
    viz,
    `Time Series Graph`  = time_series_pageviews(web_data)$plot_pageviews,
    `Most Popular Posts` = popular_posts_bar(web_data),
    `Week Day Sessions`  = day_of_week(web_data),
    `Visitor Map`        = map(web_data_c),
    `Channels`           = channel_groupings(web_data),
    `Bounce Rate`        = bounce_rate(web_data)$bounce_rate_fig,
    `Device Category`    = device_category(web_data),
    `CTR By Position`    = click_through_pos(web_data)
  )

}

google_analytics_viz <- function(title = NULL, viz = NULL, btn_id,
                                 class_all, class_specific, color) {

  shiny::tagList(
    div(
      class = class_specific,
      div(
        class = "col-md-6",
        div(
          class = "panel panel-default",
          div(
            class = "panel-heading clearfix",
            tags$h2(title, class = "panel-title pull-left"),
            div(
              class = "pull-right",
              shiny::actionButton(
                inputId = btn_id,
                label   = "",
                class   = stringr::str_glue("btn-{color} {class_all}"),
                icon    = shiny::icon("minus")
              )
            )
          ),
          div(
            class = "panel-body",
            switch_fn(viz)
          )
        )
      )
    )
  )

}
