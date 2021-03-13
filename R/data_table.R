popular_posts_bar <- function(df) {

  df %>%
    group_by(page_path) %>%
    dplyr::summarise(Views = sum(pageviews)) %>%
    dplyr::arrange(desc(Views)) %>%
    .[1:25, ] %>%
    DT::datatable(
      options = list(
        autoWidth = TRUE,
        columnDefs = list(
          list(className = "nowrap", width = "100px", targets = "_all")
        )
      )
    ) -> data_table

  data_table <- div(
    style = "overflow-x: scroll;",
    data_table
  ) %>%
    shiny::tagList()

  return(data_table)

}
