df <- readr::read_csv("web_data.csv")

page_view_df <- df %>%
  group_by(date) %>%
  dplyr::summarise(col_1 = sum(pageviews),
                   col_4 = sum(sessions))

cards_page_view <- page_view_df %>%
  dplyr::filter(date == max(date) - 1 | date == max(date) - 2) %>%
  dplyr::arrange(date) %>%
  dplyr::mutate(col_2 = round((diff(c(NA, col_1)) / .$col_1[1]) * 100, 2),
                col_3 = "Page Views",
                icon = "user",
                col_5 = round((diff(c(NA, col_4)) / .$col_4[1]) * 100, 2),
                col_6 = "Sessions",
                icon_2 = "eye")


test_that("Info cards are build properly", {
  expect_snapshot(create_cards(cards_page_view))
})

test_that("Test that arrow points in right direction", {
  expect_equal(
    create_cards(cards_page_view) %>%
      as.character() %>%
      stringr::str_extract("arrow-up"),
    "arrow-up"
  )
})

test_that("Color is the right color for arrow", {
  expect_equal(
    create_cards(cards_page_view) %>%
      as.character() %>%
      stringr::str_extract("color: green"),
    "color: green"
  )
})

cards_page_view <- page_view_df %>%
  dplyr::filter(date == max(date) - 3 | date == max(date) - 4) %>%
  dplyr::arrange(date) %>%
  dplyr::mutate(col_2 = round((diff(c(NA, col_1)) / .$col_1[1]) * 100, 2),
                col_3 = "Page Views",
                icon = "user",
                col_5 = round((diff(c(NA, col_4)) / .$col_4[1]) * 100, 2),
                col_6 = "Sessions",
                icon_2 = "eye")

test_that("Test that arrow points in right direction", {
  expect_equal(
    create_cards(cards_page_view) %>%
      as.character() %>%
      stringr::str_extract("arrow-down"),
    "arrow-down"
  )
})

test_that("Color is the right color for arrow", {
  expect_equal(
    create_cards(cards_page_view) %>%
      as.character() %>%
      stringr::str_extract("color: red"),
    "color: red"
  )
})

df <- readr::read_csv("web_data.csv")
df <- bounce_rate(df)[[2]]
test_that("Arrow is other way around higher bounce rate -> bad", {
  expect_equal(
    create_cards(df) %>%
      as.character() %>%
      stringr::str_extract("arrow-down"),
    "arrow-down"
  )
})

test_that("Color is the right color for arrow", {
  expect_equal(
    create_cards(df) %>%
      as.character() %>%
      stringr::str_extract("color: red"),
    "color: red"
  )
})

