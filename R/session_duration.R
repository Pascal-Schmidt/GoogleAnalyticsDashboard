session_duration <- function(df) {
  df %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(col_1 = (sum(session_duration) / dplyr::n()) %>%
      round(2)) %>%
    dplyr::filter(date == max(date) - 1 | date == max(date) - 2) %>%
    dplyr::arrange(date) %>%
    dplyr::mutate(
      col_2 = round((diff(c(NA, col_1)) / .$col_1[1]) * 100, 2),
      col_3 = "Session Duration",
      col_1 = paste(col_1, "Secs"),
      icon = "clock"
    ) -> duration

  return(duration)
}
