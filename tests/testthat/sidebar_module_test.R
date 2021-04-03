all_visualizations <- c(
  `Visitor Map` = "c", `Bounce Rate` = "e",
  `Week Day Sessions` = "f", `Channels` = "g",
  `Time Series Graph` = "a", `Most Popular Posts` = "b",
  `Device Category` = "h", `CTR By Position` = "i"
)

test_that("reactive output value x has the right names and classes/ids", {

  # define reactive values in module
  db_viz <- shiny::reactiveVal()
  data_btn <- shiny::reactiveVal()
  auth <- shiny::reactiveVal()

  # testing function
  shiny::testServer(sidebar_server, args = list(
    auth = auth, db_viz = db_viz, data_btn = data_btn), {

      # first test
      auth(TRUE)
      db_viz(c("a", "b", "c", "e"))
      data_btn(1)

      expect_equal(names(sidebar_plots()),
                   c("Week Day Sessions", "Channels",
                     "Device Category", "CTR By Position"))
      expect_equal(unname(sidebar_plots()),
                   c("f", "g",
                     "h", "i"))

      # second test
      auth(TRUE)
      db_viz(c("d", "g"))
      data_btn(1)

      session$flushReact()

      expect_equal(names(sidebar_plots()),
                   c("Visitor Map", "Bounce Rate",
                     "Week Day Sessions", "Time Series Graph",
                     "Most Popular Posts", "Device Category",
                     "CTR By Position"))
      expect_equal(unname(sidebar_plots()),
                   c("c", "e", "f", "a", "b", "h", "i"))


    })

})
