# libraries
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
library(promises)
library(future)
library(tidymodels)
library(modeltime)
library(timetk)
library(DT)
library(shinyauthr)
library(mongolite)
library(config)
library(shinycustomloader)
library(testthat)

# get configs
config <- config::get(file = here::here("credentials/config.yml"))

# read in all files
here::here("R") %>%
  list.files() %>%
  here::here("R", .) %>%
  purrr::walk(~ source(.))

refit_tbl <- readr::read_rds(here::here("data/model_data/refit_tbl.rds"))
validation <- readr::read_csv(here::here("data/csv_data/validation.csv"))

# read in geo data for map
geo <- geojsonsf::geojson_sf("https://raw.githubusercontent.com/eparker12/nCoV_tracker/master/input_data/50m.geojson") %>%
  as.data.frame()

# all visualizations names and ids
all_visualizations <- c(
  `Visitor Map` = "c", `Bounce Rate` = "e",
  `Week Day Sessions` = "f", `Channels` = "g",
  `Time Series Graph` = "a", `Most Popular Posts` = "b",
  `Device Category` = "h", `CTR By Position` = "i"
)

# all visualizations and corresponding data source
what_df <- c(
  `Visitor Map` = "sc", `Bounce Rate` = "ga",
  `Week Day Sessions` = "ga", `Channels` = "ga",
  `Time Series Graph` = "ga", `Most Popular Posts` = "ga",
  `Device Category` = "ga", `CTR By Position` = "sc"
)


# connect to google analytics and google search console and set scopes

# ------------------------------------------------------------------------------
email <- config$email

options(
  "googleAuthR.scopes.selected" = c(
    "https://www.googleapis.com/auth/webmasters",
    "https://www.googleapis.com/auth/webmasters.readonly",
    "https://www.googleapis.com/auth/analytics",
    "https://www.googleapis.com/auth/analytics.readonly",
    "https://www.googleapis.com/auth/analytics.edit",
    "https://www.googleapis.com/auth/analytics.manage.users",
    "https://www.googleapis.com/auth/analytics.user.deletion"
  )
)

googleAuthR::gar_auth_service(json_file = here::here("credentials/search_console_r_key.json"))
website <- "https://thatdatatho.com/"

googleAuthR::gar_set_client(json = here::here("credentials/client_id.json"))
googleAnalyticsR::ga_auth(email = email,
                          json_file = here::here("credentials/thatdatatho.json"))

my_accounts <- googleAnalyticsR::ga_account_list()
my_id <- my_accounts$viewId
# ------------------------------------------------------------------------------


# mongo connections

#-------------------------------------------------------------------------------
# user_base <- dplyr::tibble(
#   user = c("user1", "pascal"),
#   password = c("pass1", "xxxxxxxx"),
#   date = c(7, 7),
#   viz = list(
#     c("c", "e", "f", "g") ,
#     c("c", "e", "f", "g")
#   )
# )

user <- config$user
password <- config$password
cluster <- config$cluster
collection <- config$collection
db_connect_str <- stringr::str_glue("mongodb+srv://{user}:{password}@{cluster}/{collection}?retryWrites=true&w=majority")

con <- mongolite::mongo(
  collection = "ga_dashboard",
  url = db_connect_str
)

user_base <- con$find() %>%
  dplyr::tibble()

# con$insert()
# con$insert(
#   user_base
# )
# con$drop()


#-------------------------------------------------------------------------------
