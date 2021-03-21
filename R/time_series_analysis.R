# web_data <- readr::read_csv("web_data.csv")
#
# library(timetk)
# library(modeltime)
# library(tidyverse)
# library(tidymodels)
#
# df <- web_data %>%
#   dplyr::group_by(date) %>%
#   dplyr::summarise(page_views = sum(pageviews))
#
# df %>%
#   timetk::plot_time_series(.date_var = date,
#                            .value = page_views)
#
# horizon <- 7*8
# rolling_periods <- c(7, 14, 28, horizon)
#
# df_1 <- df %>%
#   dplyr::bind_rows(
#     timetk::future_frame(.data = ., .date_var = date, .length_out = horizon)
#   )
#
# df_2 <- df_1 %>%
#   timetk::tk_augment_lags(.value = page_views, .lags = horizon) %>%
#   timetk::tk_augment_slidify(
#     .value = !!sym(paste0("page_views_lag", horizon)),
#     .f     = mean,
#     .period = rolling_periods,
#     .align = "center",
#     .partial = TRUE
#   )
#
# validation <- df_1 %>%
#   dplyr::filter(is.na(page_views))
#
# training_testing <- df %>%
#   dplyr::filter(!is.na(page_views))
#
# splits <- training_testing %>%
#   timetk::time_series_split(date_var = date,
#                             assess = horizon,
#                             cumulative = TRUE)
#
# splits %>%
#   timetk::tk_time_series_cv_plan() %>%
#   timetk::plot_time_series_cv_plan(.date_var = date,
#                                    .value = page_views)
#
# library(doFuture)
# registerDoFuture()
# n_cores <- parallel::detectCores()
#
# plan(
#   strategy = cluster,
#   workers = parallel::makeCluster(n_cores)
# )
#
# recipes_base <- recipes::recipe(page_views ~., data = rsample::training(splits))
# ### GLM Net ###
# remove_vars <- c("date_year", "date_year", "date_month", "date_month.xts",
#                  "date_hour", "date_minute", "date_second", "date_hour12",
#                  "date_am.pm", "date_wday.xts", "date_qday", "date_yday",
#                  "date_mweek", "date_week.iso", "date_week2", "date_week3",
#                  "date_week4", "date_mday7", "date_year.iso")
# recipes_glmnet <- recipes_base %>%
#   recipes::step_naomit(contains("lag"), skip = TRUE) %>%
#   timetk::step_timeseries_signature(date) %>%
#   timetk::step_fourier(date, period = c(7, 30), K = 2) %>%
#   recipes::step_rm(date) %>%
#   recipes::step_rm(!!!syms(remove_vars)) %>%
#   recipes::step_normalize(all_numeric(), -all_outcomes()) %>%
#   recipes::step_dummy(recipes::all_nominal(), one_hot = TRUE) %>%
#   recipes::step_nzv(all_predictors())
# model_spec_glmnet <- parsnip::linear_reg(penalty =  tune::tune(), mixture = tune::tune()) %>%
#   parsnip::set_engine("glmnet")
# # recipes_glmnet %>% prep() %>% juice() %>% tail()
#
# set.seed(123)
# resamples_kfold <- rsample::vfold_cv(
#   rsample::training(splits),
#   v = 10
# )
#
# grid_spec_glmnet <-
#   dials::grid_latin_hypercube(dials::parameters(model_spec_glmnet),
#                               size = 100)
#
# tune_results_glmnet_kfold <- workflows::workflow() %>%
#   workflows::add_recipe(recipes_glmnet) %>%
#   workflows::add_model(model_spec_glmnet) %>%
#
#   tune::tune_grid(
#     resamples = resamples_kfold,
#     grid      = grid_spec_glmnet,
#     metrics   = modeltime::default_forecast_accuracy_metric_set(),
#     control   = tune::control_grid(verbose = FALSE, save_pred = TRUE)
#   )
#
# tune_results_glmnet_kfold %>%
#   tune::show_best()
#
# workflow_fit_glmnet_kfold <- workflows::workflow() %>%
#   workflows::add_recipe(recipes_glmnet) %>%
#   workflows::add_model(model_spec_glmnet) %>%
#   tune::finalize_workflow(
#     tune_results_glmnet_kfold %>%
#       tune::show_best(metric = "mae") %>%
#       dplyr::slice(1)
#   ) %>%
#   parsnip::fit(rsample::training(splits))
#
#
# remove_vars <- c("date_year", "date_year", "date_month", "date_month.xts",
#                  "date_hour", "date_minute", "date_second", "date_hour12",
#                  "date_am.pm", "date_wday.xts", "date_qday", "date_yday",
#                  "date_mweek", "date_week.iso", "date_week2", "date_week3",
#                  "date_week4", "date_mday7", "date_year.iso")
# recipes_rf <-  recipes_base %>%
#   recipes::step_naomit(contains("lag"), skip = TRUE) %>%
#   timetk::step_timeseries_signature(date) %>%
#   timetk::step_fourier(date, period = c(7, 30), K = 2) %>%
#   recipes::step_rm(date) %>%
#   recipes::step_rm(!!!syms(remove_vars)) %>%
#   recipes::step_normalize(all_numeric(), -all_outcomes()) %>%
#   recipes::step_dummy(recipes::all_nominal(), one_hot = TRUE) %>%
#   step_nzv(all_predictors())
# model_spec_rf <- parsnip::boost_tree(mode = "regression",
#                                      mtry = tune::tune(),
#                                      trees = tune::tune(),
#                                      min_n = tune::tune(),
#                                      learn_rate = tune::tune(),
#                                      loss_reduction = tune::tune(),
#                                      tree_depth = tune::tune()) %>%
#   parsnip::set_engine("xgboost")
# df_rf <- recipes_rf %>% prep() %>% juice()
#
# set.seed(123)
# resamples_kfold <- rsample::vfold_cv(
#   rsample::training(splits),
#   v = 10
# )
#
# grid_spec_rf <-
#   dials::grid_latin_hypercube(dials::parameters(model_spec_rf) %>%
#                                 update(
#                                   mtry = dials::mtry(range = c(1, ncol(df_rf) - 1))
#                                 ),
#                               size = 25)
#
# tune_results_rf_kfold <- workflows::workflow() %>%
#   workflows::add_recipe(recipes_rf) %>%
#   workflows::add_model(model_spec_rf) %>%
#
#   tune::tune_grid(
#     resamples = resamples_kfold,
#     grid      = grid_spec_rf,
#     metrics   = modeltime::default_forecast_accuracy_metric_set(),
#     control   = tune::control_grid(verbose = FALSE, save_pred = TRUE)
#   )
#
# tune_results_rf_kfold %>%
#   tune::show_best()
# g <- tune_results_rf_kfold %>%
#   autoplot() +
#   geom_smooth(se = F)
# plotly::ggplotly(g)
#
# grid_spec_rf <-
#   dials::grid_latin_hypercube(
#     dials::mtry(range = c(1, ncol(df_rf) - 1)),
#     min_n(),
#     trees(),
#     tree_depth(),
#     learn_rate(range = c(-2.5, -0.5)),
#     loss_reduction(),
#     size = 50
#   )
#
# tune_results_rf_kfold <- workflows::workflow() %>%
#   workflows::add_recipe(recipes_rf) %>%
#   workflows::add_model(model_spec_rf) %>%
#
#   tune::tune_grid(
#     resamples = resamples_kfold,
#     grid      = grid_spec_rf,
#     metrics   = modeltime::default_forecast_accuracy_metric_set(),
#     control   = tune::control_grid(verbose = FALSE, save_pred = TRUE)
#   )
#
# tune_results_rf_kfold %>%
#   tune::show_best()
# g <- tune_results_rf_kfold %>%
#   autoplot() +
#   geom_smooth(se = F)
# plotly::ggplotly(g)
#
# workflow_fit_rf_kfold <- workflows::workflow() %>%
#   workflows::add_recipe(recipes_rf) %>%
#   workflows::add_model(model_spec_rf) %>%
#   tune::finalize_workflow(
#     tune_results_rf_kfold %>%
#       tune::show_best(metric = "mae") %>%
#       dplyr::slice(1)
#   ) %>%
#   parsnip::fit(rsample::training(splits))
#
# calibration_tbl <- modeltime::modeltime_table(
#   workflow_fit_glmnet_kfold,
#   workflow_fit_rf_kfold
#   # workflow_fit_prophet,
#   # workflow_fit_arima,
#   # workflow_fit_prophet_xgboost_kfold
# ) %>%
#   modeltime::modeltime_calibrate(
#     new_data = na.omit(rsample::testing(splits))
#   )
#
# x <- calibration_tbl$.calibration_data
# 1 - (sum(x[[1]]$.prediction) / sum(x[[1]]$.actual))
#
# calibration_tbl %>%
#   modeltime::modeltime_forecast(
#     new_data = rsample::testing(splits),
#     actual_data = training_testing
#   ) %>%
#   modeltime::plot_modeltime_forecast(.legend_show = FALSE,
#                                      .plotly_slider = FALSE)
#
# calibration_tbl %>%
#   modeltime::modeltime_accuracy()
#
# refit_tbl <- calibration_tbl %>%
#   modeltime::modeltime_refit(
#     data = training_testing
#   )
#
# refit_tbl[, 1:3] %>%
#   modeltime::modeltime_calibrate(
#     new_data = na.omit(rsample::testing(splits))
#   ) %>%
#   modeltime::modeltime_accuracy()
#
# readr::write_rds(refit_tbl, "data/model_data/refit_tbl.rds")
# readr::write_csv(validation, "data/csv_data/validation.csv")
#
#
# refit_tbl %>%
#   modeltime::modeltime_forecast(
#     new_data = validation,
#     actual_data = df
#   ) %>%
#   modeltime::plot_modeltime_forecast(
#     .legend_show = FALSE,
#     .conf_interval_show = FALSE
#     )
#
