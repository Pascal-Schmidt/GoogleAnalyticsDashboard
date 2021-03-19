library(shiny)
library(plotly)
library(leaflet)
library(fuzzyjoin)
library(tidyverse)
library(googleAnalyticsR)
library(searchConsoleR)
library(googleAuthR)
library(here)
library(shiny.router)
library(shinyjs)

here::here("R") %>%
  list.files() %>%
  here::here("R", .) %>%
  purrr::walk(~ source(.))

# start of page
div(

  br(),
  br(),

  data_ui(id = "refresh_data"),
  sidebar_ui(id = "sidebar"),

  br(),
  br(),

  div(
    cards_ui(id = "value_cards")
  ),

  br(),
  br(),

  div(
    id = "placeholder-cards,"
  ),

  div(
    id = "placeholder"
  ),
  main_viz_ui(id = "main_viz"),
  shiny::uiOutput(
    outputId = "second"
  )
) -> page_1

page_2 <- div(
  titlePanel("Settings"),
  p("This is a settings page")
)

router <- make_router(
  route("/", page_1),
  route("page_2", page_2)
)

ui <- fluidPage(

  shinyjs::useShinyjs(),
  shiny::includeCSS(here::here("inst/www/styles.css")),

  div(
    class = "wrapper",
    tags$ul(
      tags$li(
        a(
          class = "item", href = route_link("/"),
          shiny::icon("globe-americas"), "Google Analytics Dashboard"
        )
      ),
      tags$li(
        a(class = "item", href = route_link("page_2"),
          shiny::icon("chart-line"), "Time Series Forecast")
      )
    )
  ),
  router$ui,

  shiny::includeScript("www/script.js")

)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  router$server(input, output, session)
  sidebar_server(id = "sidebar")
  new_data <- data_server(id = "refresh_data")

  cards_server(id = "value_cards", df = new_data$new_ga)


  main_viz_server(id = "main_viz",
                  data_btn = new_data$new_data_btn,
                  ga       = new_data$new_ga,
                  sc       = new_data$new_sc)


  # shiny::observeEvent(input$add_btn_clicked, {
  #
  #   panel <- input$add_btn_clicked
  #   panel_plot_item <-
  #     google_analytics_viz(
  #       title = input$header,
  #       viz = input$header,
  #       btn_id = panel,
  #       class_all = "delete",
  #       class_specific = paste0("class_", panel),
  #       color = "danger"
  #     )
  #
  #   css_selector <- ifelse(input$last_panel == "#placeholder",
  #                          "#placeholder",
  #                          paste0(".", input$last_panel))
  #
  #   shiny::insertUI(
  #     selector = css_selector,
  #     "afterEnd",
  #     ui = panel_plot_item
  #   )
  #
  # })

}

# Run the application
shinyApp(ui = ui, server = server)
