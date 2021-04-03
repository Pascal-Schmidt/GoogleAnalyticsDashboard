start_app <- function() {
  dir <- here::here("inst") %>%
    list.files() %>%
    .[stringr::str_detect(., "app")] %>%
    here::here("inst", .)
  shiny::runApp(dir, display.mode = "normal")
}
