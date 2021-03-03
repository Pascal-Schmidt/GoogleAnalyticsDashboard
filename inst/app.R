library(shiny)
library(tidyverse)
library(googleAnalyticsR)
library(searchConsoleR)
library(googleAuthR)
library(here)

# ## First, authenticate with our client OAUTH credentials from step 5 of the blog post.
# googleAuthR::gar_set_client(json = here::here("credentials/client_id.json"))
#
# ## Now, provide the service account email and private key
# googleAnalyticsR::ga_auth(email = "thatdatatho-analysis@vast-operator-306204.iam.gserviceaccount.com",
#                           json_file = here::here("credentials/thatdatatho.json"))
#
# my_accounts <- ga_account_list()
# my_id <- my_accounts$viewId
#
# web_data <- google_analytics(my_id,
#                              date_range = c("2018-01-15", "today"),
#                              metrics = c("sessions","pageviews",
#                                          "entrances","bounces", "bounceRate", "sessionDuration"),
#                              dimensions = c("date","deviceCategory", "hour", "dayOfWeekName",
#                                             "channelGrouping", "source", "keyword", "pagePath"),
#                              anti_sample = TRUE)

# https://blog.rstudio.com/2020/11/27/google-analytics-part1/


# searchConsoleR::scr_auth()
# website <- "https://thatdatatho.com/"
# x <- searchConsoleR::search_analytics(website,
#                                  start = "2020-01-15", end = "2020-01-20",
#                                  dimensions = c("page", "query", "country", "date"),
#                                  rowLimit = 5000) -> web_data
#
# p <- ggplot(web_data %>%
#          dplyr::group_by(date) %>%
#          dplyr::summarise(n = sum(pageviews)), aes(x = date, y = n)) +
#   geom_line()
#
# plotly::ggplotly(p)
# Define UI for application that draws a histogram

google_analytics_viz <- function(title = NULL, viz = NULL, btn_id,
                                 class_all, class_specific, color) {

  shiny::tagList(
    div(
      class = class_specific,
      div(
        class = "col-md-6",
        div(
          class = "panel panel-default",
          div(
            class = "panel-heading clearfix",
            tags$h2(title, class = "panel-title pull-left"),
            div(
              class = "pull-right",
              shiny::actionButton(
                inputId = btn_id,
                label   = "",
                class   = stringr::str_glue("btn-{color} {class_all}"),
                icon    = shiny::icon("minus")
              )
            )
          ),
          div(
            class = "panel-body",
            viz
          )
        )
      )
    )
  )

}

ui <- fluidPage(

  div(
    id = "placeholder"
  ),
  shiny::uiOutput(
    outputId = "first"
  ),
  shiny::uiOutput(
    outputId = "second"
  ),
  shiny::includeScript("www/script.js")

)

# Define server logic required to draw a histogram
server <- function(input, output) {

  x <- c(a = "map", b = "bar", c = "line")
  output$first <- shiny::renderUI({

      purrr::map2(
        .x = x, .y = names(x),
        ~ google_analytics_viz(
          title = .y,
          viz = plotly::plot_ly(x = rnorm(10), y = rnorm(10)),
          btn_id = paste0("id_", .x),
          class_all = "delete",
          class_specific = paste0("class_", .x),
          color = "danger"
        )
      ) %>%
      shiny::isolate()

  })

  output$second <- shiny::renderUI({

    x <- c(d = "density", e = "scatter", f = "violin")
    purrr::map2(
      .x = x, .y = names(x),
      ~ div(
        class = paste0("added_", .x),
        p(.y),
        actionButton(
          inputId = paste0("add_", .x),
          label = "",
          icon = shiny::icon("plus"),
          class = "btn-success added_btn"
        )
      )
    ) %>%
      shiny::isolate()

  })

  shiny::observeEvent(input$add_btn_clicked, {

    panel <- stringr::str_split(input$add_btn_clicked, pattern = "_")[[1]][2]

    panel_plot_item <-
      google_analytics_viz(
        title = input$header,
        viz = plotly::plot_ly(x = rnorm(10), y = rnorm(10)),
        btn_id = paste0("id_", panel),
        class_all = "delete",
        class_specific = paste0("class_", panel),
        color = "danger"
      )

    print(input$header)
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
