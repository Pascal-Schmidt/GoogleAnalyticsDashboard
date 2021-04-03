df <- readr::read_csv("web_data.csv")

df <- time_series_pageviews(df)[[2]]

test_that("Page Views has right icon", {
  expect_equal(df$icon_2[1], "eye")
})

test_that("Dates are one day apart", {
  expect_equal(as.numeric(cards_page_view$date[2] - cards_page_view$date[1]), 1)
})

test_that("Percentages are calculated correctly for col 1", {
  expect_equal(round((cards_page_view$col_1[2]-cards_page_view$col_1[1])/cards_page_view$col_1[1], 4)*100,
               cards_page_view$col_2[2])
})

test_that("Percentages are calculated correctly for col 2", {
  expect_equal(round((cards_page_view$col_4[2]-cards_page_view$col_4[1])/cards_page_view$col_4[1], 4)*100,
               cards_page_view$col_5[2])
})

