create_cards <- function(df) {
  color <- ifelse(df$col_1[1] < df$col_1[2], "green", "red")
  direction <- ifelse(df$col_1[1] < df$col_1[2], "up", "down")

  div(
    class = "col-xs-12 col-md-3 col-lg-3 col-sm-3",
    style = "display:flex;",
    div(
      class = "panel panel-default shadow",
      style = "margin: 5px; width: 100%",
      div(
        class = "panel-body",
        style = "display: flex;",
        div(
          style = "color: black;",
          h1(df$col_1[2]),
          div(
            style = "color: grey;",
            h4(df$col_3[1])
          ),
          div(
            style = stringr::str_glue("color: {color};"),
            p(
              shiny::icon(paste0("arrow-", direction)),
              paste0(df$col_2[2], "%")
            )
          )
        ),
        div(
          style = "font-size: 70px;
                   color: grey;
                   align-self: center;
                   margin: 0 auto;
                   margin-right: 10px;",
          shiny::icon(df$icon[1])
        )
      )
    )
  )
}
