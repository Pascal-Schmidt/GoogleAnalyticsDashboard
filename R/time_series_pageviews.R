time_series_pageviews <- function(df) {
  page_view_df <- df %>%
    group_by(date) %>%
    dplyr::summarise(
      col_1 = sum(pageviews),
      col_4 = sum(sessions)
    )

  cards_page_view <- page_view_df %>%
    dplyr::filter(date == max(date) - 1 | date == max(date) - 2) %>%
    dplyr::arrange(date) %>%
    dplyr::mutate(
      col_2 = round((diff(c(NA, col_1)) / .$col_1[1]) * 100, 2),
      col_3 = "Page Views",
      icon = "user",
      col_5 = round((diff(c(NA, col_4)) / .$col_4[1]) * 100, 2),
      col_6 = "Sessions",
      icon_2 = "eye"
    )

  fig <- plot_ly(page_view_df, x = ~date)
  fig <- fig %>% add_lines(y = ~col_1, name = "Page Views")
  fig <- fig %>% add_lines(y = ~col_4, name = "Sessions", visible = F)
  fig <- fig %>% layout(
    xaxis = list(domain = range(page_view_df$date), title = ""),
    yaxis = list(title = ""),
    updatemenus = list(
      list(
        y = 1.25,
        x = 0,
        buttons = list(
          list(
            method = "restyle",
            args = list("visible", list(TRUE, FALSE)),
            label = "Page Views"
          ),

          list(
            method = "restyle",
            args = list("visible", list(FALSE, TRUE)),
            label = "Sessions"
          )
        )
      )
    )
  )

  return(
    list(
      plot_pageviews = fig,
      cards_pageviews = cards_page_view,
      cards_sessions = cards_page_view[, c("date", "col_4", "col_5", "col_6", "icon_2")] %>%
        purrr::set_names(c("date", "col_1", "col_2", "col_3", "icon"))
    )
  )
}
