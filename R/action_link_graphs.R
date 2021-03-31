graphs <- function(input_id, txt) {
  shiny::actionLink(
    inputId = input_id,
    label = txt,
    class = "added_btn"
  )
}
