input <- tibble::tribble(
  ~USUBJID, ~VISIT, ~PARAMCD, ~AVAL, ~AVALC, ~EXSTDTC, ~EXENDTC,
  "01-701-1015", "BASELINE", "DOSE", 80, NA, "2020-07-01", "2020-07-14",
  "01-701-1015", "WEEK 2", "DOSE", 80, NA, "2020-07-15", "2020-09-23",
  "01-701-1015", "WEEK 12", "DOSE", 65, NA, "2020-09-24", "2020-12-16",
  "01-701-1015", "WEEK 24", "DOSE", 65, NA, "2020-12-17", "2021-06-02",
  "01-701-1015", "BASELINE", "ADJ", NA, NA, "2020-07-01", "2020-07-14",
  "01-701-1015", "WEEK 2", "ADJ", NA, "Y", "2020-07-15", "2020-09-23",
  "01-701-1015", "WEEK 12", "ADJ", NA, "Y", "2020-09-24", "2020-12-16",
  "01-701-1015", "WEEK 24", "ADJ", NA, NA, "2020-12-17", "2021-06-02",
  "01-701-1281", "BASELINE", "DOSE", 80, NA, "2020-07-03", "2020-07-18",
  "01-701-1281", "WEEK 2", "DOSE", 80, NA, "2020-07-19", "2020-10-01",
  "01-701-1281", "WEEK 12", "DOSE", 82, NA, "2020-10-02", "2020-12-01",
  "01-701-1281", "BASELINE", "ADJ", NA, NA, "2020-07-03", "2020-07-18",
  "01-701-1281", "WEEK 2", "ADJ", NA, NA, "2020-07-19", "2020-10-01",
  "01-701-1281", "WEEK 12", "ADJ", NA, NA, "2020-10-02", "2020-12-01"
) %>%
  mutate(
    ASTDTM = ymd_hms(paste(EXSTDTC, "T00:00:00")),
    ASTDT = date(ASTDTM),
    AENDTM = ymd_hms(paste(EXENDTC, "T00:00:00")),
    AENDT = date(AENDTM)
  )

input_no_dtm <- input %>%
  select(-ASTDTM, -AENDTM)

# ---- derive_param_exposure, test 1: New observations are derived correctly ----
# ---- for AVAL ----
test_that("derive_param_exposure Test 1: New observations are derived correctly
          for AVAL", {
  new_obs1 <- input %>%
    filter(PARAMCD == "DOSE") %>%
    group_by(USUBJID) %>%
    summarise(
      AVAL = sum(AVAL, na.rm = TRUE),
      ASTDTM = min(ASTDTM, na.rm = TRUE),
      AENDTM = max(AENDTM, na.rm = TRUE)
    ) %>%
    mutate(PARAMCD = "TDOSE", PARCAT1 = "OVERALL", ASTDT = date(ASTDTM), AENDT = date(AENDTM))

  new_obs2 <- input %>%
    filter(PARAMCD == "DOSE") %>%
    group_by(USUBJID) %>%
    summarise(
      AVAL = mean(AVAL, na.rm = TRUE),
      ASTDTM = min(ASTDTM, na.rm = TRUE),
      AENDTM = max(AENDTM, na.rm = TRUE)
    ) %>%
    mutate(PARAMCD = "AVDOSE", PARCAT1 = "OVERALL", ASTDT = date(ASTDTM), AENDT = date(AENDTM))

  new_obs3 <- input %>%
    filter(PARAMCD == "ADJ") %>%
    group_by(USUBJID) %>%
    summarise(
      AVALC = if_else(sum(!is.na(AVALC)) > 0, "Y", NA_character_),
      ASTDTM = min(ASTDTM, na.rm = TRUE),
      AENDTM = max(AENDTM, na.rm = TRUE)
    ) %>%
    mutate(PARAMCD = "TADJ", PARCAT1 = "OVERALL", ASTDT = date(ASTDTM), AENDT = date(AENDTM))

  expected_output <- bind_rows(input, new_obs1, new_obs2, new_obs3)

  actual_output <- input %>%
    derive_param_exposure(
      by_vars = vars(USUBJID),
      input_code = "DOSE",
      analysis_var = AVAL,
      summary_fun = function(x) sum(x, na.rm = TRUE),
      set_values_to = vars(PARAMCD = "TDOSE", PARCAT1 = "OVERALL")
    ) %>%
    derive_param_exposure(
      by_vars = vars(USUBJID),
      input_code = "DOSE",
      analysis_var = AVAL,
      summary_fun = function(x) mean(x, na.rm = TRUE),
      set_values_to = vars(PARAMCD = "AVDOSE", PARCAT1 = "OVERALL")
    ) %>%
    derive_param_exposure(
      by_vars = vars(USUBJID),
      input_code = "ADJ",
      analysis_var = AVALC,
      summary_fun = function(x) if_else(sum(!is.na(x)) > 0, "Y", NA_character_),
      set_values_to = vars(PARAMCD = "TADJ", PARCAT1 = "OVERALL")
    )

  expect_dfs_equal(
    actual_output,
    expected_output,
    keys = c("USUBJID", "VISIT", "PARAMCD")
  )
})

# ---- derive_param_exposure, test 2:  New observations are derived correctly ----
# ---- for AVAL, when the input dataset only contains AxxDT variables ----
test_that("derive_param_exposure Test 2: New observations are derived correctly
          for AVAL, when the input dataset only contains AxxDT variables", {
  new_obs1 <- input_no_dtm %>%
    filter(PARAMCD == "DOSE") %>%
    group_by(USUBJID) %>%
    summarise(
      AVAL = sum(AVAL, na.rm = TRUE),
      ASTDT = min(ASTDT, na.rm = TRUE),
      AENDT = max(AENDT, na.rm = TRUE)
    ) %>%
    mutate(PARAMCD = "TDOSE", PARCAT1 = "OVERALL")

  new_obs2 <- input_no_dtm %>%
    filter(PARAMCD == "DOSE") %>%
    group_by(USUBJID) %>%
    summarise(
      AVAL = mean(AVAL, na.rm = TRUE),
      ASTDT = min(ASTDT, na.rm = TRUE),
      AENDT = max(AENDT, na.rm = TRUE)
    ) %>%
    mutate(PARAMCD = "AVDOSE", PARCAT1 = "OVERALL")

  new_obs3 <- input_no_dtm %>%
    filter(PARAMCD == "ADJ") %>%
    group_by(USUBJID) %>%
    summarise(
      AVALC = if_else(sum(!is.na(AVALC)) > 0, "Y", NA_character_),
      ASTDT = min(ASTDT, na.rm = TRUE),
      AENDT = max(AENDT, na.rm = TRUE)
    ) %>%
    mutate(PARAMCD = "TADJ", PARCAT1 = "OVERALL")

  expected_output <- bind_rows(input_no_dtm, new_obs1, new_obs2, new_obs3)

  actual_output <- input_no_dtm %>%
    derive_param_exposure(
      by_vars = vars(USUBJID),
      input_code = "DOSE",
      analysis_var = AVAL,
      summary_fun = function(x) sum(x, na.rm = TRUE),
      set_values_to = vars(PARAMCD = "TDOSE", PARCAT1 = "OVERALL")
    ) %>%
    derive_param_exposure(
      by_vars = vars(USUBJID),
      input_code = "DOSE",
      analysis_var = AVAL,
      summary_fun = function(x) mean(x, na.rm = TRUE),
      set_values_to = vars(PARAMCD = "AVDOSE", PARCAT1 = "OVERALL")
    ) %>%
    derive_param_exposure(
      by_vars = vars(USUBJID),
      input_code = "ADJ",
      analysis_var = AVALC,
      summary_fun = function(x) if_else(sum(!is.na(x)) > 0, "Y", NA_character_),
      set_values_to = vars(PARAMCD = "TADJ", PARCAT1 = "OVERALL")
    )

  expect_dfs_equal(
    actual_output,
    expected_output,
    keys = c("USUBJID", "VISIT", "PARAMCD")
  )
})

# ---- derive_param_exposure, test 3: Errors ----
test_that("derive_param_exposure, test 3: Errors", {
  # PARAMCD must be specified
  expect_error(
    input <- input %>%
      derive_param_exposure(
        by_vars = vars(USUBJID),
        input_code = "DOSE",
        analysis_var = AVAL,
        summary_fun = function(x) mean(x, na.rm = TRUE),
        set_values_to = vars(PARCAT1 = "OVERALL")
      ),
    regexp = paste("The following required elements are missing in `set_values_to`: 'PARAMCD'")
  )
  # input code must be present
  expect_error(
    input <- input %>%
      derive_param_exposure(
        by_vars = vars(USUBJID),
        input_code = "DOSED",
        analysis_var = AVAL,
        summary_fun = function(x) mean(x, na.rm = TRUE),
        set_values_to = vars(PARAMCD = "TDOSE", PARCAT1 = "OVERALL")
      ),
    regexp = paste(
      "`input_code` contains invalid values:\n`DOSED`\nValid",
      "values:\n`DOSE` and `ADJ`"
    )
  )

  # ASTDTM/AENDTM or ASTDT/AENDT must be present
  expect_error(
    input <- input %>%
      select(-starts_with("AST"), -starts_with("AEN")) %>%
      derive_param_exposure(
        by_vars = vars(USUBJID),
        input_code = "DOSE",
        analysis_var = AVAL,
        summary_fun = function(x) mean(x, na.rm = TRUE),
        set_values_to = vars(PARCAT1 = "OVERALL")
      ),
    regexp = paste("Required variables `ASTDT` and `AENDT` are missing")
  )
})
