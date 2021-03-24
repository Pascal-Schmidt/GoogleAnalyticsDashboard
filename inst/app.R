source(here::here("inst/global.R"))

# first page
page_1 <- div(

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
  main_viz_ui(id = "main_viz")
)

# page 2
page_2 <- div(
  ui_time_series(id = "forecast")
)

# router
router <- make_router(
  route("/", page_1),
  route("page_2", page_2)
)

# ui
ui <- fluidPage(

  shinyjs::useShinyjs(),
  shiny::includeCSS(here::here("inst/www/styles.css")),

  loginUI(id = "login"),
  div(
    id = "display_content",
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
    router$ui
  ) %>% hidden(),

  shiny::includeScript(here::here("inst/www/script.js"))

)

# server
server <- function(input, output, session) {

  logout_init <- callModule(
    shinyauthr::logout,
    id = "logout",
    active = reactive(credentials()$user_auth)
  )

  # call login module supplying data frame, user and password cols
  # and reactive trigger
  credentials <- callModule(
    shinyauthr::login,
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    log_out = reactive(logout_init())
  )

  shiny::observe({
    req(credentials()$user_auth)
    shinyjs::show(id = "display_content")
  })

  viz_vec <- shiny::reactive({

    req(credentials()$user_auth)
    value_vec <- credentials()$info$viz[[1]]
    return(value_vec)

  })

  router$server(input, output, session)
  sidebar_server(id = "sidebar")
  new_data <- data_server(id = "refresh_data")

  cards_server(
    id = "value_cards",
    df = new_data$new_ga,
    btn = new_data$new_data_btn
  )

  main_viz_server(
    id = "main_viz",
    auth        = shiny::reactive(credentials()$user_auth),
    data_btn    = new_data$new_data_btn,
    ga          = new_data$new_ga,
    sc          = new_data$new_sc,
    js_btn      = shiny::reactive(input$add_btn_clicked),
    what_viz    = shiny::reactive(input$header),
    last_panel  = shiny::reactive(input$last_panel),
    get_current_viz = shiny::reactive(input$all_present_vizs),
    db_viz      = shiny::reactive(viz_vec())
  )

  server_time_series(
    id = "forecast",
    df = new_data$new_ga
  )

}

# Run the application
shinyApp(ui = ui, server = server)
