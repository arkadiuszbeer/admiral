
adsl <- tibble::tribble(
  ~USUBJID, ~SEX, ~COUNTRY,
  "ST42-1", "F",  "AUT",
  "ST42-2", "M",  "MWI",
  "ST42-3", "M",  "NOR",
  "ST42-4", "F",  "UGA"
) %>% mutate(STUDYID = "ST42")

advs <- tibble::tribble(
  ~USUBJID, ~PARAMCD, ~AVISIT,    ~AVAL,
  "ST42-1", "WEIGHT", "BASELINE", 66,
  "ST42-1", "WEIGHT", "Week 2",   68,
  "ST42-2", "WEIGHT", "BASELINE", 88,
  "ST42-3", "WEIGHT", "Week 2",   55,
  "ST42-3", "WEIGHT", "Week 4",   50
) %>% mutate(STUDYID = "ST42")

ex <- tibble::tribble(
  ~USUBJID, ~EXSTDTC,
  "ST42-1", "2020-12-07",
  "ST42-1", "2020-12-14",
  "ST42-2", "2021-01-12T12:00:00",
  "ST42-2", "2021-01-26T13:21",
  "ST42-3", "2021-03-02"
) %>% mutate(STUDYID = "ST42")

vs <- tibble::tribble(
  ~USUBJID, ~VSTESTCD, ~VSTEST, ~VSORRES, ~VSSEQ,
  "ST42-1", "DIABP", "Diastolic Blood Pressure", 64, 1,
  "ST42-1", "DIABP", "Diastolic Blood Pressure", 83, 2,
  "ST42-1", "WEIGHT", "Weight", 120, 3,
  "ST42-2", "WEIGHT", "Weight", 110, 1,
  "ST42-2", "HEIGHT", "Height", 58, 2
) %>% mutate(STUDYID = "ST42")


## Test 1: merge all variables
test_that("derive_vars_merged, Test 1: merge all variables", {
  actual <- derive_vars_merged(advs,
    dataset_add = adsl,
    by_vars = vars(STUDYID, USUBJID)
  )

  expected <- left_join(advs, adsl, by = c("STUDYID", "USUBJID"))

  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = c("USUBJID", "AVISIT")
  )
})

## Test 2: merge selected variables
test_that("derive_vars_merged Test 2: merge selected variables", {
  actual <- derive_vars_merged(advs,
    dataset_add = adsl,
    by_vars = vars(USUBJID),
    new_vars = vars(SEX)
  )

  expected <- left_join(advs, select(adsl, USUBJID, SEX), by = "USUBJID")

  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = c("USUBJID", "AVISIT")
  )
})

## Test 3: merge last value and 7 flag matched by groups
test_that("derive_vars_merged Test 3: merge last value and 7 flag matched by
          groups", {
  actual <- derive_vars_merged(adsl,
    dataset_add = advs,
    order = vars(AVAL),
    by_vars = vars(STUDYID, USUBJID),
    new_vars = vars(WEIGHTBL = AVAL),
    mode = "last",
    match_flag = matched
  )
  expected <- adsl %>% mutate(
    WEIGHTBL = c(68, 88, 55, NA),
    matched = c(TRUE, TRUE, TRUE, NA)
  )

  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = c("USUBJID")
  )
})

## Test 4: error if variable in both datasets
test_that("derive_vars_merged Test 4: error if variable in both datasets", {
  expect_error(derive_vars_merged(advs,
    dataset_add = adsl,
    by_vars = vars(USUBJID)
  ),
  regexp = ""
  )
})

## Test 5: merge first date
test_that("derive_vars_merged_dt Test 5: merge first date", {
  suppress_warning(
    actual <- derive_vars_merged_dt(
      adsl,
      dataset_add = ex,
      order = vars(TRTSDT),
      flag_imputation = "date",
      by_vars = vars(STUDYID, USUBJID),
      dtc = EXSTDTC,
      new_vars_prefix = "TRTS",
      mode = "first"
    ),
    "deprecated"
  )
  expected <-
    adsl %>% mutate(
      TRTSDT = ymd(c(
        "2020-12-07", "2021-01-12", "2021-03-02", NA
      )),
      TRTSDTF = NA_character_
    )

  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = c("USUBJID")
  )
})

## Test 6: merge first date
test_that("derive_vars_merged_dtm Test 6: merge first date", {
  suppress_warning(
    actual <- derive_vars_merged_dtm(
      adsl,
      dataset_add = ex,
      order = vars(TRTSDTM),
      by_vars = vars(STUDYID, USUBJID),
      dtc = EXSTDTC,
      new_vars_prefix = "TRTS",
      time_imputation = "first",
      mode = "first"
    ),
    "deprecated"
  )
  expected <-
    adsl %>% mutate(
      TRTSDTM = ymd_hms(
        c(
          "2020-12-07T00:00:00",
          "2021-01-12T12:00:00",
          "2021-03-02T00:00:00",
          NA
        )
      ),
      TRTSTMF = c("H", NA, "H", NA)
    )

  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = c("USUBJID")
  )
})

## Test 7: merge categorized variable
test_that("derive_vars_merged_cat Test 7: merge categorized variable", {
  get_region <- function(x) {
    if_else(x %in% c("AUT", "NOR"), "EUROPE", "AFRICA")
  }

  actual <- derive_var_merged_cat(
    advs,
    dataset_add = adsl,
    by_vars = vars(USUBJID),
    new_var = REGION,
    source_var = COUNTRY,
    cat_fun = get_region
  )

  expected <- left_join(advs, select(adsl, USUBJID, COUNTRY), by = "USUBJID") %>%
    mutate(REGION = get_region(COUNTRY)) %>%
    select(-COUNTRY)


  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = c("USUBJID", "AVISIT")
  )
})

## Test 8: define value for non-matched by groups
test_that("derive_vars_merged_cat Test 8: define value for non-matched by
          groups", {
  get_vscat <- function(x) {
    if_else(x == "BASELINE", "BASELINE", "POST-BASELINE")
  }

  actual <- derive_var_merged_cat(
    adsl,
    dataset_add = advs,
    by_vars = vars(USUBJID),
    new_var = LSTVSCAT,
    source_var = AVISIT,
    cat_fun = get_vscat,
    order = vars(AVISIT),
    mode = "last",
    missing_value = "MISSING"
  )

  expected <-
    mutate(adsl,
      LSTVSCAT = c("POST-BASELINE", "BASELINE", "POST-BASELINE", "MISSING")
    )

  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = c("USUBJID")
  )
})

## Test 9: merge existence flag
test_that("derive_vars_merged_exist_flag Test 9: merge existence flag", {
  actual <- derive_var_merged_exist_flag(
    adsl,
    dataset_add = advs,
    by_vars = vars(USUBJID),
    new_var = VSEVALFL,
    condition = AVISIT == "BASELINE"
  )

  expected <-
    mutate(adsl, VSEVALFL = c("Y", "Y", NA_character_, NA_character_))


  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = "USUBJID"
  )
})

## Test 10: merge character variable, no transformation
test_that("derive_var_merged_character Test 10: merge character variable,
          no transformation", {
  actual <- derive_var_merged_character(
    adsl,
    dataset_add = advs,
    by_vars = vars(USUBJID),
    order = vars(AVISIT),
    new_var = LASTVIS,
    source_var = AVISIT,
    mode = "last"
  )

  expected <-
    mutate(adsl, LASTVIS = c("Week 2", "BASELINE", "Week 4", NA_character_))


  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = "USUBJID"
  )
})

## Test 11: merge character variable, upper case
test_that("derive_var_merged_character Test 11: merge character variable,
          upper case", {
  actual <- derive_var_merged_character(
    adsl,
    dataset_add = advs,
    by_vars = vars(USUBJID),
    order = vars(AVISIT),
    new_var = LASTVIS,
    source_var = AVISIT,
    mode = "last",
    case = "upper",
    missing_value = "UNKNOWN"
  )

  expected <-
    mutate(adsl, LASTVIS = c("WEEK 2", "BASELINE", "WEEK 4", "UNKNOWN"))


  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = "USUBJID"
  )
})

## Test 12: merge character variable, lower case
test_that("derive_var_merged_character Test 12: merge character variable,
          lower case", {
  actual <- derive_var_merged_character(
    adsl,
    dataset_add = advs,
    by_vars = vars(USUBJID),
    order = vars(AVISIT),
    new_var = LASTVIS,
    source_var = AVISIT,
    mode = "last",
    case = "lower"
  )

  expected <-
    mutate(adsl, LASTVIS = c("week 2", "baseline", "week 4", NA_character_))


  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = "USUBJID"
  )
})

## Test 13: merge character variable, title case
test_that("derive_var_merged_character Test 13: merge character variable,
          title case", {
  actual <- derive_var_merged_character(
    adsl,
    dataset_add = advs,
    by_vars = vars(USUBJID),
    order = vars(AVISIT),
    new_var = LASTVIS,
    source_var = AVISIT,
    mode = "last",
    case = "title"
  )

  expected <-
    mutate(adsl, LASTVIS = c("Week 2", "Baseline", "Week 4", NA_character_))


  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = "USUBJID"
  )
})

## Test 14: merge lookup table
test_that("derive_vars_merged_lookup Test 14: merge lookup table", {
  param_lookup <- tibble::tribble(
    ~VSTESTCD, ~VSTEST, ~PARAMCD, ~DESCRIPTION,
    "WEIGHT", "Weight", "WEIGHT", "Weight (kg)",
    "HEIGHT", "Height", "HEIGHT", "Height (cm)",
    "BMI", "Body Mass Index", "BMI", "Body Mass Index(kg/m^2)"
  )

  attr(param_lookup$VSTESTCD, "label") <- "Vital Signs Test Short Name"
  attr(param_lookup$VSTEST, "label") <- "Vital Signs Test Name"


  actual <- derive_vars_merged_lookup(
    vs,
    dataset_add = param_lookup,
    by_vars = vars(VSTESTCD, VSTEST),
    new_var = vars(PARAMCD, PARAM = DESCRIPTION),
    print_not_mapped = TRUE
  )

  expected <-
    left_join(vs, param_lookup, by = c("VSTESTCD", "VSTEST")) %>%
    rename(PARAM = DESCRIPTION)


  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = c("USUBJID", "VSSEQ", "VSTESTCD")
  )
})



## Test 15: merge lookup table when all by_vars have corresponding records in
## the lookup table
test_that("derive_merged Test 15: merge lookup table when all
          by_vars have corresponding records in the lookup table", {
  param_lookup <- tibble::tribble(
    ~VSTESTCD, ~VSTEST, ~PARAMCD, ~DESCRIPTION,
    "WEIGHT", "Weight", "WEIGHT", "Weight (kg)",
    "HEIGHT", "Height", "HEIGHT", "Height (cm)",
    "BMI", "Body Mass Index", "BMI", "Body Mass Index(kg/m^2)",
    "DIABP", "Diastolic Blood Pressure", "DIABP", "Diastolic Blood Pressure (mmHg)"
  )

  attr(param_lookup$VSTESTCD, "label") <- "Vital Signs Test Short Name"
  attr(param_lookup$VSTEST, "label") <- "Vital Signs Test Name"


  actual <- derive_vars_merged_lookup(
    vs,
    dataset_add = param_lookup,
    by_vars = vars(VSTESTCD, VSTEST),
    new_var = vars(PARAMCD, PARAM = DESCRIPTION),
    print_not_mapped = TRUE
  )

  expected <-
    left_join(vs, param_lookup, by = c("VSTESTCD", "VSTEST")) %>%
    rename(PARAM = DESCRIPTION)


  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = c("USUBJID", "VSSEQ", "VSTESTCD")
  )
})



## Test16: get not mapped when not all by_vars have corresponding records
## in the lookup table
# ---- derive_merged, test 16: NA ----
test_that("derive_merged Test 16: get not mapped when not all by_vars have
          corresponding records in the lookup table", {
  param_lookup <- tibble::tribble(
    ~VSTESTCD, ~VSTEST, ~PARAMCD, ~DESCRIPTION,
    "WEIGHT", "Weight", "WEIGHT", "Weight (kg)",
    "HEIGHT", "Height", "HEIGHT", "Height (cm)",
    "BMI", "Body Mass Index", "BMI", "Body Mass Index(kg/m^2)"
  )

  attr(param_lookup$VSTESTCD, "label") <- "Vital Signs Test Short Name"
  attr(param_lookup$VSTEST, "label") <- "Vital Signs Test Name"


  act_vs_param <- derive_vars_merged_lookup(
    vs,
    dataset_add = param_lookup,
    by_vars = vars(VSTESTCD, VSTEST),
    new_var = vars(PARAMCD, PARAM = DESCRIPTION),
    print_not_mapped = TRUE
  )

  actual <- get_not_mapped()

  expected <- left_join(vs, param_lookup, by = c("VSTESTCD", "VSTEST")) %>%
    rename(PARAM = DESCRIPTION) %>%
    filter(is.na(PARAMCD)) %>%
    select(VSTESTCD, VSTEST) %>%
    distinct()

  expect_dfs_equal(
    base = expected,
    compare = actual,
    keys = c("VSTESTCD", "VSTEST")
  )
})
