bounce_rate <- function(df) {

  df %>%
    dplyr::filter(bounce_rate != 0) %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(col_1 = (sum(bounce_rate) / dplyr::n()) %>%
                       round(2)) -> bounce_rate

  bounce_rate %>%
    plotly::plot_ly(
      data = .,
      x = ~ date,
      y = ~ col_1,
      type = 'scatter',
      mode = 'lines'
    ) -> fig

  bounce_rate_cards <- bounce_rate %>%
    dplyr::filter(date == max(date) - 1 | date == max(date) - 2) %>%
    dplyr::arrange(date) %>%
    dplyr::mutate(col_2 = -round((diff(c(NA, col_1)) / .$col_1[1]) * 100, 2),
                  col_3 = "Bounce Rate",
                  icon = "exclamation-circle")

  return(
    list(
      bounce_rate_fig   = fig,
      cards_bounce_rate = bounce_rate_cards
    )
  )

}
