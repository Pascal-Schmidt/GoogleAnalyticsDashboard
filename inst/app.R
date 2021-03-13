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

# # ## First, authenticate with our client OAUTH credentials from step 5 of the blog post.
# googleAuthR::gar_set_client(json = here::here("credentials/client_id.json"))
# #
# # ## Now, provide the service account email and private key
# googleAnalyticsR::ga_auth(email = "thatdatatho-analysis@vast-operator-306204.iam.gserviceaccount.com",
#                            json_file = here::here("credentials/thatdatatho.json"))
# #
# my_accounts <- ga_account_list()
# my_id <- my_accounts$viewId
# #
# web_data <- google_analytics(my_id,
#                              date_range = c("2021-02-28", "today"),
#                              metrics = c("sessions","pageviews",
#                                          "entrances","bounces", "bounceRate", "sessionDuration"),
#                              dimensions = c("date","deviceCategory", "hour", "dayOfWeekName",
#                                             "channelGrouping", "source", "keyword", "pagePath"),
#                              anti_sample = TRUE) %>%
#   janitor::clean_names() %>%
#   dplyr::mutate(page_path = stringr::str_remove_all(page_path, ".*[0-9+]/") %>%
#                   stringr::str_remove_all("\\/"))
#
# # https://blog.rstudio.com/2020/11/27/google-analytics-part1/
# searchConsoleR::scr_auth()
# website <- "https://thatdatatho.com/"
# searchConsoleR::search_analytics(website,
#                                  start = "2020-01-15", end = "2020-01-20",
#                                  dimensions = c("page", "query", "country", "date"),
#                                  rowLimit = 5000)  %>%
#            janitor::clean_names() -> web_data_c
#
# View(web_data_c)
# View(web_data)

p <- ggplot(web_data %>%
         dplyr::group_by(date) %>%
         dplyr::summarise(n = sum(pageviews)), aes(x = date, y = n)) +
  geom_line()
plotly::ggplotly(p)

df <- web_data %>%
  dplyr::mutate(page_path = stringr::str_remove_all(page_path, ".*[0-9+]/") %>%
                  stringr::str_remove_all("\\/"))

# start of page
div(

  br(),
  br(),

  div(
    class = "row text-center",
    style = 'padding-bottom: 50px;',
    div(
      id = "get-date",
      class = "col-xl-3 col-md-3 col-sm-3 text-center",
      style = "padding-top: 20px;",
      shiny::actionLink(
        inputId = "toggle_date",
        label = "",
        icon = shiny::icon("angle-down")
      ),
      div(
        style = "padding: 10px;",
        id = "data_go",
        shiny::dateRangeInput(
          inputId = "google_data",
          label = "Choose Time Frame",
          start = Sys.Date() - 7,
          end = Sys.Date(),
          min = Sys.Date() - 30,
          max = Sys.Date(),
          width = "100%"
        ),
        actionButton(
          inputId = "go",
          label = "",
          icon = shiny::icon("filter")
        )
      ) %>% shinyjs::hidden()
    ),
    div(
      class = "col-xl-6 col-md-6 col-sm-6",
      h1("Google Analytics Dashboard")
    ),
    div(
      id = "slide",
      class = "col-xl-3 col-md-3 col-sm-3",
      style = "padding-top: 20px;",
      shiny::actionLink(
        inputId = "open",
        label = "",
        icon = shiny::icon("bars"),
        onclick = "open_sidebar()"
      )
    )
  ),

  sidebar_ui(id = "sidebar"),

  br(),
  br(),

  div(
    class = "row eq-height",
    create_cards(time_series_pageviews(web_data)$cards_sessions),
    create_cards(time_series_pageviews(web_data)$cards_pageviews),
    create_cards(bounce_rate(web_data)$cards_bounce_rate),
    create_cards(session_duration(web_data))
  ),

  br(),
  br(),

  div(
    id = "placeholder-cards,"
  ),

  div(
    id = "placeholder"
  ),
  shiny::uiOutput(
    outputId = "first"
  ),
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

  # sidebar_ui(id = "sidebar"),
  #
  # br(),
  # br(),
  #
  # div(
  #   class = "row eq-height",
  #   create_cards(time_series_pageviews(web_data)$cards_sessions),
  #   create_cards(time_series_pageviews(web_data)$cards_pageviews),
  #   create_cards(bounce_rate(web_data)$cards_bounce_rate),
  #   create_cards(session_duration(web_data))
  # ),
  #
  # br(),
  # br(),
  #
  # div(
  #   id = "placeholder-cards,"
  # ),
  #
  # div(
  #   id = "placeholder"
  # ),
  # shiny::uiOutput(
  #   outputId = "first"
  # ),
  # shiny::uiOutput(
  #   outputId = "second"
  # ),
  shiny::includeScript("www/script.js")

)

# Define server logic required to draw a histogram
server <- function(input, output, session) {


  shiny::observeEvent(input$go, {

    print(input$all_present_vizs)

  })

  router$server(input, output, session)
  sidebar_server(id = "sidebar")

  shiny::observeEvent(input$toggle_date, {
    shinyjs::toggle(id = "data_go", anim = TRUE)
  })

  x <- c(`Visitor Map` = "c", `Bounce Rate` = "e",
         `Week Day Sessions` = "f", `Channels` = "g")
  output$first <- shiny::renderUI({

      purrr::map2(
        .x = x, .y = names(x),
        ~ google_analytics_viz(
          title = .y,
          viz = .y,
          btn_id = .x,
          class_all = "delete",
          class_specific = paste0("class_", .x),
          color = "danger"
        )
      ) %>%
      shiny::isolate()

  })


  shiny::observeEvent(input$add_btn_clicked, {

    panel <- input$add_btn_clicked
    panel_plot_item <-
      google_analytics_viz(
        title = input$header,
        viz = input$header,
        btn_id = panel,
        class_all = "delete",
        class_specific = paste0("class_", panel),
        color = "danger"
      )

    css_selector <- ifelse(input$last_panel == "#placeholder",
                           "#placeholder",
                           paste0(".", input$last_panel))

    shiny::insertUI(
      selector = css_selector,
      "afterEnd",
      ui = panel_plot_item
    )

  })

}

# Run the application
shinyApp(ui = ui, server = server)
