# derive_vars_joined ----
## Test 1: no by_vars, no order, no new_vars ----
test_that("derive_vars_joined Test 1: no by_vars, no order, no new_vars", {
  expected <- tibble::tribble(
    ~USUBJID, ~ADY, ~AVISIT,    ~AWLO, ~AWHI,
    "1",        -2, "BASELINE",   -30,     1,
    "1",         3, "WEEK 1",       2,     7,
    "1",        24, "WEEK 4",      23,    30,
    "2",        NA, NA,            NA,    NA
  )

  windows <- tibble::tribble(
    ~AVISIT,    ~AWLO, ~AWHI,
    "BASELINE",   -30,     1,
    "WEEK 1",       2,     7,
    "WEEK 2",       8,    15,
    "WEEK 3",      16,    22,
    "WEEK 4",      23,    30
  )

  expect_dfs_equal(
    base = expected,
    comp = derive_vars_joined(
      select(expected, USUBJID, ADY),
      dataset_add = windows,
      join_vars = vars(AWHI, AWLO),
      filter_join = AWLO <= ADY & ADY <= AWHI
    ),
    keys = c("USUBJID", "ADY")
  )
})

## Test 2: new_vars with rename ----
test_that("derive_vars_joined Test 2: new_vars with rename", {
  expected <- tibble::tribble(
    ~USUBJID, ~ADY, ~AVAL, ~NADIR,
    "1",        -7,    10,     NA,
    "1",         1,    12,     NA,
    "1",         8,    11,     12,
    "1",        15,     9,     11,
    "1",        20,    14,      9,
    "1",        24,    12,      9,
    "2",        13,     8,     NA
  )

  adbds <- select(expected, -NADIR)

  expect_dfs_equal(
    base = expected,
    comp = derive_vars_joined(
      adbds,
      dataset_add = adbds,
      by_vars = vars(USUBJID),
      order = vars(AVAL),
      new_vars = vars(NADIR = AVAL),
      join_vars = vars(ADY),
      filter_add = ADY > 0,
      filter_join = ADY.join < ADY,
      mode = "first",
      check_type = "none"
    ),
    keys = c("USUBJID", "ADY")
  )
})

## Test 3: by_vars with rename ----
test_that("derive_vars_joined Test 3: by_vars with rename", {
  adae <- tibble::tribble(
    ~AEGRPID,
    "1",
    "2"
  ) %>%
    mutate(
      TRTSDTM = ymd_hms("2020-01-06T12:00:00")
    )

  faae <- tibble::tribble(
    ~FAGRPID, ~FADT,        ~FAORRES,
    "1",      "2020-01-01", "1",
    "1",      "2020-01-03", "2",
    "1",      "2020-01-05", "3",
    "1",      "2020-01-08", "4"
  ) %>%
    mutate(FADT = ymd(FADT))
  expect_dfs_equal(
    base = mutate(adae, ATOXGR_pre = c("3", NA)),
    comp = derive_vars_joined(
      adae,
      dataset_add = faae,
      by_vars = vars(AEGRPID = FAGRPID),
      order = vars(FADT),
      new_vars = vars(ATOXGR_pre = FAORRES),
      join_vars = vars(FADT),
      filter_join = FADT < TRTSDTM,
      mode = "last"
    ),
    keys = c("AEGRPID")
  )
})

## Test 4: no join_vars, no filter_join ----
test_that("derive_vars_joined Test 4: no join_vars, no filter_join", {
  adae <- tibble::tribble(
    ~AEGRPID,
    "1",
    "2"
  ) %>%
    mutate(
      TRTSDTM = ymd_hms("2020-01-06T12:00:00")
    )

  faae <- tibble::tribble(
    ~FAGRPID, ~FADT,        ~FAORRES,
    "1",      "2020-01-01", "1",
    "1",      "2020-01-03", "2",
    "1",      "2020-01-05", "3",
    "1",      "2020-01-08", "4"
  ) %>%
    mutate(FADT = ymd(FADT))
  expect_dfs_equal(
    base = mutate(adae, ATOXGR_pre = c("1", NA)),
    comp = derive_vars_joined(
      adae,
      dataset_add = faae,
      by_vars = vars(AEGRPID = FAGRPID),
      order = vars(FAORRES),
      new_vars = vars(ATOXGR_pre = FAORRES),
      mode = "first"
    ),
    keys = c("AEGRPID")
  )
})
