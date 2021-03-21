click_through_pos <- function(df) {

  df %>%
    dplyr::group_by(Position = round(position)) %>%
    dplyr::summarise(`Average CTR` = round(mean(ctr)*100, 2)) %>%
    dplyr::arrange(Position) %>%
    .[1:20, ] -> df_test

  plotly::plot_ly(df_test, x = ~Position,
                  text = ~paste0(`Average CTR`, "%"),
                  hoverinfo = 'text',
                  hovertext = ~paste('Average click through rate <br>
                                   for position: ', Position,
                                     'is', `Average CTR`),
                  showlegend = FALSE) %>%
    add_trace(y = ~`Average CTR`,
              type = 'scatter',
              mode = 'lines+markers+text',
              textposition = "top right",
              showarrow = TRUE) -> fig

  return(fig)

}


