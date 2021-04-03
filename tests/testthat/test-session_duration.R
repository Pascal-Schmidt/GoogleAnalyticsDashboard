df <- readr::read_csv("web_data.csv")

df <- session_duration(df)

test_that("Dates are one day apart", {
  expect_equal(as.numeric(df$date[2] - df$date[1]), 1)
})

test_that("Percentage Calculations are correct", {
  expect_equal(round((readr::parse_number(df$col_1[2]) - readr::parse_number(df$col_1[1]))/readr::parse_number(df$col_1[1])*100, 2),
               df$col_2[2])
})
