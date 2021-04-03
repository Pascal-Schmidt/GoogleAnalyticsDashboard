df <- readr::read_csv("web_data.csv")
df <- bounce_rate(df)[[2]]

test_that("Percentages are calculated correctly for col 2", {
  expect_equal(round((df$col_1[2]-df$col_1[1])/df$col_1[1], 4)*100,
               -df$col_2[2])
})
