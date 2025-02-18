#' Creates a queries dataset as input dataset to the `dataset_queries` argument in
#' `derive_vars_query()`
#'
#' Creates a queries dataset as input dataset to the `dataset_queries` argument
#' in the `derive_vars_query()` function as defined in the [Queries Dataset
#' Documentation](../articles/queries_dataset.html).
#'
#' @param queries List of queries
#'
#'   A list of `query()` objects is expected.
#'
#' @param meddra_version MedDRA version
#'
#'   The MedDRA version used for coding the terms in the AE dataset should be
#'   specified. If any of the queries is a SMQ or a customized query including a
#'   SMQ, the parameter needs to be specified.
#'
#'   *Permitted Values*: A character string (the expected format is
#'   company-specific)
#'
#' @param whodd_version WHO Drug Dictionary version
#'
#'   The version of the WHO Drug Dictionary used for coding the terms in the CM
#'   dataset should be specified. If any of the queries is a SDG, the parameter
#'   needs to be specified.
#'
#'   *Permitted Values*: A character string (the expected format is
#'   company-specific)
#'
#' @param get_smq_fun Function which returns the terms of an SMQ
#'
#'   For each query specified for the `queries` parameter which refers to an SMQ
#'   (i.e., those where the `definition` field is set to a `smq_select()` object
#'   or a list which contains at least one `smq_select()` object) the specified
#'   function is called to retrieve the terms defining the query. This function
#'   is not provided by admiral as it is company specific, i.e., it has to be
#'   implemented at company level.
#'
#'   The function must return a dataset with all the terms defining the SMQ. The
#'   output dataset must contain the following variables.
#'
#'   - `TERM_LEVEL`: the variable to be used for defining a term of the SMQ, e.g.,
#'   `AEDECOD`
#'   - `TERM_NAME`: the name of the term if the variable `TERM_LEVEL` is
#'   referring to is character
#'   - `TERM_ID` the numeric id of the term if the variable `TERM_LEVEL` is
#'   referring to is numeric
#'   - `QUERY_NAME`: the name of the SMQ. The values must be the same for all
#'   observations.
#'
#'   The function must provide the following parameters
#'
#'   - `smq_select`: A `smq_select()` object.
#'   - `version`: The MedDRA version. The value specified for the
#'   `meddra_version` in the `create_query_data()` call is passed to this
#'   parameter.
#'   - `keep_id`: If set to `TRUE`, the output dataset must contain the
#'   `QUERY_ID` variable. The variable must be set to the numeric id of the SMQ.
#'   - `temp_env`: A temporary environment is passed to this parameter. It can
#'   be used to store data which is used for all SMQs in the
#'   `create_query_data()` call. For example if the SMQs need to be read from a
#'   database all SMQs can be read and stored in the environment when the first
#'   SMQ is handled. For the other SMQs the terms can be retrieved from the
#'   environment instead of accessing the database again.
#'
#' @param get_sdg_fun Function which returns the terms of an SDG
#'
#'   For each query specified for the `queries` parameter which refers to an SDG
#'   the specified function is called to retrieve the terms defining the query.
#'   This function is not provided by admiral as it is company specific, i.e.,
#'   it has to be implemented at company level.
#'
#'   The function must return a dataset with all the terms defining the SDG. The
#'   output dataset must contain the following variables.
#'
#'   - `TERM_LEVEL`: the variable to be used for defining a term of the SDG, e.g.,
#'   `CMDECOD`
#'   - `TERM_NAME`: the name of the term if the variable `TERM_LEVEL` is
#'   referring to is character
#'   - `TERM_ID` the numeric id of the term if the variable `TERM_LEVEL` is
#'   referring to is numeric
#'   - `QUERY_NAME`: the name of the SDG. The values must be the same for all
#'   observations.
#'
#'   The function must provide the following parameters
#'
#'   - `sdg_select`: A `sdg_select()` object.
#'   - `version`: The WHO drug dictionary version. The value specified for the
#'   `whodd_version` in the `create_query_data()` call is passed to this
#'   parameter.
#'   - `keep_id`: If set to `TRUE`, the output dataset must contain the
#'   `QUERY_ID` variable. The variable must be set to the numeric id of the SDG.
#'   - `temp_env`: A temporary environment is passed to this parameter. It can
#'   be used to store data which is used for all SDGs in the
#'   `create_query_data()` call. For example if the SDGs need to be read from a
#'   database all SDGs can be read and stored in the environment when the first
#'   SDG is handled. For the other SDGs the terms can be retrieved from the
#'   environment instead of accessing the database again.
#'
#' @details
#'
#'   For each `query()` object listed in the `queries` argument, the terms belonging
#'   to the query (`TERM_LEVEL`, `TERM_NAME`, `TERM_ID`) are determined with respect
#'   to the `definition` field of the query: if the definition field of the
#'   `query()` object is
#'
#'   * an `smq_select()` object, the terms are read from the SMQ
#'   database by calling the function specified for the `get_smq_fun` parameter.
#'   * an `sdg_select()` object, the terms are read from the SDG
#'   database by calling the function specified for the `get_sdg_fun` parameter.
#'   * a data frame, the terms stored in the data frame are used.
#'   * a list of data frames and `smq_select()` objects, all terms from
#'   the data frames and all terms read from the SMQ database referenced by the
#'   `smq_select()` objects are collated.
#'
#' The following variables (as described in [Queries Dataset
#' Documentation](../articles/queries_dataset.html)) are created:
#'
#'   * `VAR_PREFIX`: Prefix of the variables to be created by
#'   `derive_vars_query()` as specified by the `prefix` element.
#'   * `QUERY_NAME`: Name of the query as specified by the `name` element.
#'   * `QUERY_ID`: Id of the query as specified by the `id` element. If the `id`
#'   element is not specified for a query, the variable is set to `NA`. If the
#'   `id` element is not specified for any query, the variable is not created.
#'   * `QUERY_SCOPE`: scope of the query as specified by the `scope` element of
#'   the `smq_select()` object. For queries not defined by a `smq_select()`
#'   object, the variable is set to `NA`. If none of the queries is defined by a
#'   `smq_select()` object, the variable is not created.
#'   * `QUERY_SCOPE_NUM`: numeric scope of the query. It is set to `1` if the
#'   scope is broad. Otherwise it is set to '2'. If the `add_scope_num` element
#'   equals `FALSE`, the variable is set to `NA`. If the `add_scope_num` element
#'   equals `FALSE` for all SMQs or none of the queries is an SMQ , the variable
#'   is not created.
#'   * `TERM_LEVEL`: Name of the variable used to identify the terms.
#'   * `TERM_NAME`: Value of the term variable if it is a character variable.
#'   * `TERM_ID`: Value of the term variable if it is a numeric variable.
#'
#' @author Stefan Bundfuss
#'
#' @return A dataset to be used as input dataset to the `dataset_queries`
#'   argument in `derive_vars_query()`
#'
#' @family create_aux
#' @keywords create_aux
#'
#' @seealso [derive_vars_query()], [query()], [smq_select()], [sdg_select()], [Queries Dataset
#' Documentation](../articles/queries_dataset.html)
#'
#' @export
#'
#' @examples
#' library(tibble)
#' library(magrittr, warn.conflicts = FALSE)
#' library(dplyr, warn.conflicts = FALSE)
#' library(admiral.test)
#' library(admiral)
#'
#' # creating a query dataset for a customized query
#' cqterms <- tribble(
#'   ~TERM_NAME, ~TERM_ID,
#'   "APPLICATION SITE ERYTHEMA", 10003041L,
#'   "APPLICATION SITE PRURITUS", 10003053L
#' ) %>%
#'   mutate(TERM_LEVEL = "AEDECOD")
#'
#' cq <- query(
#'   prefix = "CQ01",
#'   name = "Application Site Issues",
#'   definition = cqterms
#' )
#'
#' create_query_data(queries = list(cq))
#'
#' # create a query dataset for SMQs
#' pregsmq <- query(
#'   prefix = "SMQ02",
#'   id = auto,
#'   definition = smq_select(
#'     name = "Pregnancy and neonatal topics (SMQ)",
#'     scope = "NARROW"
#'   )
#' )
#'
#' bilismq <- query(
#'   prefix = "SMQ04",
#'   definition = smq_select(
#'     id = 20000121L,
#'     scope = "BROAD"
#'   )
#' )
#'
#' # The get_smq_terms function from admiral.test is used for this example.
#' # In a real application a company-specific function must be used.
#' create_query_data(
#'   queries = list(pregsmq, bilismq),
#'   get_smq_fun = admiral.test:::get_smq_terms,
#'   meddra_version = "20.1"
#' )
#'
#' # create a query dataset for SDGs
#' sdg <- query(
#'   prefix = "SDG01",
#'   id = auto,
#'   definition = sdg_select(
#'     name = "5-aminosalicylates for ulcerative colitis"
#'   )
#' )
#'
#' # The get_sdg_terms function from admiral.test is used for this example.
#' # In a real application a company-specific function must be used.
#' create_query_data(
#'   queries = list(sdg),
#'   get_sdg_fun = admiral.test:::get_sdg_terms,
#'   whodd_version = "2019-09"
#' )
#'
#' # creating a query dataset for a customized query including SMQs
#' # The get_smq_terms function from admiral.test is used for this example.
#' # In a real application a company-specific function must be used.
#' create_query_data(
#'   queries = list(
#'     query(
#'       prefix = "CQ03",
#'       name = "Special issues of interest",
#'       definition = list(
#'         smq_select(
#'           name = "Pregnancy and neonatal topics (SMQ)",
#'           scope = "NARROW"
#'         ),
#'         cqterms
#'       )
#'     )
#'   ),
#'   get_smq_fun = admiral.test:::get_smq_terms,
#'   meddra_version = "20.1"
#' )
create_query_data <- function(queries,
                              meddra_version = NULL,
                              whodd_version = NULL,
                              get_smq_fun = NULL,
                              get_sdg_fun = NULL) {
  # check parameters
  assert_character_scalar(meddra_version, optional = TRUE)
  assert_character_scalar(whodd_version, optional = TRUE)
  assert_function(get_smq_fun,
    params = c("smq_select", "version", "keep_id", "temp_env"),
    optional = TRUE
  )
  assert_function(get_sdg_fun,
    params = c("sdg_select", "version", "keep_id", "temp_env"),
    optional = TRUE
  )

  walk(queries, validate_query)

  # read queries
  temp_env <- new.env(parent = emptyenv())
  query_data <- vector("list", length(queries))
  for (i in seq_along(queries)) {
    # get term names and term variable
    if (inherits(queries[[i]]$definition, "smq_select")) {
      # query is a SMQ
      query_data[[i]] <- get_terms_from_db(
        version = meddra_version,
        fun = get_smq_fun,
        queries = queries,
        definition = queries[[i]]$definition,
        expect_query_name = TRUE,
        expect_query_id = !is.null(queries[[i]]$id),
        i = i,
        temp_env = temp_env,
        type = "SMQ"
      )
      query_data[[i]] <- mutate(query_data[[i]],
        QUERY_SCOPE = queries[[i]]$definition$scope
      )
      if (queries[[i]]$add_scope_num) {
        query_data[[i]] <-
          mutate(query_data[[i]],
            QUERY_SCOPE_NUM = if_else(QUERY_SCOPE == "BROAD", 1, 2)
          )
      }
    } else if (inherits(queries[[i]]$definition, "sdg_select")) {
      # query is a SDG
      query_data[[i]] <- get_terms_from_db(
        version = whodd_version,
        fun = get_sdg_fun,
        queries = queries,
        definition = queries[[i]]$definition,
        expect_query_name = TRUE,
        expect_query_id = !is.null(queries[[i]]$id),
        i = i,
        temp_env = temp_env,
        type = "SDG"
      )
    } else if (is.data.frame(queries[[i]]$definition)) {
      # query is a customized query
      query_data[[i]] <- queries[[i]]$definition
    } else if (is.list(queries[[i]]$definition)) {
      # query is defined by customized queries and SMQs
      definition <- queries[[i]]$definition
      terms <- vector("list", length(definition))
      for (j in seq_along(definition)) {
        if (is.data.frame(definition[[j]])) {
          terms[[j]] <- definition[[j]]
        } else {
          terms[[j]] <- get_terms_from_db(
            version = meddra_version,
            fun = get_smq_fun,
            queries = queries,
            definition = definition[[j]],
            i = i,
            temp_env = temp_env,
            type = "SMQ"
          )
        }
      }
      query_data[[i]] <- bind_rows(terms)
    }

    # add mandatory variables
    query_data[[i]] <- mutate(query_data[[i]],
      VAR_PREFIX = queries[[i]]$prefix
    )

    if (!is_auto(queries[[i]]$name)) {
      query_data[[i]] <- mutate(query_data[[i]],
        QUERY_NAME = queries[[i]]$name
      )
    }

    # add optional variables
    if (!is.null(queries[[i]]$id) && !is_auto(queries[[i]]$id)) {
      query_data[[i]] <- mutate(query_data[[i]],
        QUERY_ID = queries[[i]]$id
      )
    }
  }
  bind_rows(query_data)
}

#' Get Terms from the Queries Database
#'
#' The function checks if all requirements to access the database are fulfilled
#' (version and access function are available, see `assert_db_requirements()`),
#' reads the terms from the database, and checks if the dataset with the terms
#' is in the expected format (see `assert_terms()`).
#'
#' @param version Version
#'
#'   The version must be non null. Otherwise, an error is issued. The value is
#'   passed to the access function (`fun`).
#'
#' @param fun Access function
#'
#'   The access function must be non null. Otherwise, an error is issued. The
#'   function is called to retrieve the terms.
#'
#' @param queries Queries
#'
#'   List of all queries passed to `create_query_data()`. It is used for error
#'   messages.
#'
#' @param definition Definition of the query
#'
#'   The definition is passed to the access function. It defines which terms are
#'   returned.
#'
#' @param expect_query_name Is `QUERY_NAME` expected in the output dataset?
#'
#' @param expect_query_id Is `QUERY_ID` expected in the output dataset?
#'
#' @param i Index of `definition` in `queries`
#'
#'   The value is used for error messages.
#'
#' @param temp_env Temporary environment
#'
#'   The value is passed to the access function.
#'
#' @param type Type of query
#'
#'   *Permitted Values*: `"smq"`, `"sdg"`
#'
#' @family der_occds
#' @keywords der_occds
#'
#' @return Output dataset of the access function
#'
#' @author Stefan Bundfuss
get_terms_from_db <- function(version,
                              fun,
                              queries,
                              definition,
                              expect_query_name = FALSE,
                              expect_query_id = FALSE,
                              i,
                              temp_env,
                              type) {
  assert_db_requirements(
    version = version,
    version_arg_name = arg_name(substitute(version)),
    fun = fun,
    fun_arg_name = arg_name(substitute(fun)),
    queries = queries,
    i = i,
    type = type
  )
  select <- rlang::parse_expr(paste0(str_to_lower(type), "_select = definition"))
  fun_call <- quo(fun(
    !!select,
    version = version,
    keep_id = expect_query_id,
    temp_env = temp_env
  ))
  terms <- call_user_fun(fun_call)
  assert_terms(
    terms,
    expect_query_name = expect_query_name,
    expect_query_id = expect_query_id,
    source_text = paste0(
      "object returned by calling get_",
      str_to_lower(type),
      "_fun(",
      str_to_lower(type),
      "_select = ",
      format(definition),
      ", version = ",
      dquote(version),
      ", keep_id = ",
      expect_query_id,
      ")"
    )
  )
  terms
}

#' Check required parameters for SMQ/SDG
#'
#' If SMQs or SDGs are requested, the version and a function to access the
#' database must be provided. The function checks these requirements.
#'
#' @param version Version provided by user
#'
#' @param version_arg_name Name of the argument providing the version
#'
#' @param fun Function provided by user
#'
#' @param fun_arg_name Name of the argument providing the function
#'
#' @param queries Queries provide by user
#'
#' @param i Index of query being checked
#'
#' @param type Type of query
#'
#' Should be `"SMQ`" or `"SDG"`.
#'
#' @keywords source_specifications
#' @family source_specifications
#'
#' @return An error is issued if `version` or `fun` is null.
#'
#' @author Stefan Bundfuss
assert_db_requirements <- function(version, version_arg_name, fun, fun_arg_name, queries, i, type) {
  if (is.null(fun)) {
    msg <-
      paste0(
        fun_arg_name,
        " is not specified. This is expected for ",
        type,
        "s.\n",
        "A ", type, " is requested by query ",
        i,
        ":\n",
        paste(capture.output(str(queries[[i]])),
          collapse = "\n"
        )
      )
    abort(msg)
  }
  if (is.null(version)) {
    msg <-
      paste0(
        version_arg_name,
        " is not specified. This is expected for ",
        type,
        "s.\n",
        "A ",
        type,
        " is requested by query ",
        i,
        ":\n",
        paste(capture.output(str(queries[[i]])),
          collapse = "\n"
        )
      )
    abort(msg)
  }
}

#' Create an `query` object
#'
#' A `query` object defines a query, e.g., a Standard MedDRA Query (SMQ), a
#' Standardized Drug Grouping (SDG), or a customized query (CQ). It is used
#' as input to `create_query_data()`.
#'
#' @param prefix The value is used to populate `VAR_PREFIX` in the output
#'   dataset of `create_query_data()`, e.g., `"SMQ03"`
#'
#' @param name The value is used to populate `QUERY_NAME` in the output dataset
#'   of `create_query_data()`. If the `auto` keyword is specified, the variable
#'   is set to the name of the query in the SMQ/SDG database.
#'
#'   *Permitted Values*: A character scalar or the `auto` keyword. The `auto`
#'   keyword is permitted only for queries which are defined by an
#'   `smq_select()` or `sdg_select()` object.
#'
#' @param id The value is used to populate `QUERY_ID` in the output dataset of
#'   `create_query_data()`. If the `auto` keyword is specified, the variable is
#'   set to the id of the query in the SMQ/SDG database.
#'
#'   *Permitted Values*: A integer scalar or the `auto` keyword. The `auto`
#'   keyword is permitted only for queries which are defined by an
#'   `smq_select()` or `sdg_select()` object.
#'
#' @param add_scope_num Determines if  `QUERY_SCOPE_NUM` in the output dataset
#'   of `create_query_data()` is populated
#'
#'   If the parameter is set to `TRUE`, the definition must be an `smq_select()`
#'   object.
#'
#'   *Default*: `FALSE`
#'
#'   *Permitted Values*: `TRUE`, `FALSE`
#'
#' @param definition Definition of terms belonging to the query
#'
#'   There are four different ways to define the terms:
#'
#'   * An `smq_select()` object is specified to select a query from the SMQ
#'     database.
#'
#'   * An `sdg_select()` object is specified to select a query from the SDG
#'     database.
#'
#'   * A data frame with columns `TERM_LEVEL` and `TERM_NAME` or `TERM_ID` can
#'     be specified to define the terms of a customized query. The `TERM_LEVEL`
#'     should be set to the name of the variable which should be used to select
#'     the terms, e.g., `"AEDECOD"` or `"AELLTCD"`. `TERM_LEVEL` does not need
#'     to be constant within a query. For example a query can be based on
#'     `AEDECOD` and `AELLT`.
#'
#'     If `TERM_LEVEL` refers to a character variable, `TERM_NAME` should be set
#'     to the value the variable. If it refers to a numeric variable, `TERM_ID`
#'     should be set to the value of the variable. If only character variables
#'     or only numeric variables are used, `TERM_ID` or `TERM_NAME` respectively
#'     can be omitted.
#'
#'   * A list of data frames and `smq_select()` objects can be specified to
#'   define a customized query based on custom terms and SMQs. The data frames
#'   must have the same structure as described for the previous item.
#'
#'   *Permitted Values*: an `smq_select()` object, an `sdg_select()` object, a
#'   data frame, or a list of data frames and `smq_select()` objects.
#'
#' @author Stefan Bundfuss
#'
#' @seealso [create_query_data()], [smq_select()], [sdg_select()], [Queries Dataset
#' Documentation](../articles/queries_dataset.html)
#'
#' @family source_specifications
#' @keywords source_specifications
#'
#' @export
#'
#' @return An object of class `query`.
#'
#' @examples
#'
#' # create a query for an SMQ
#' library(tibble)
#' library(magrittr, warn.conflicts = FALSE)
#' library(dplyr, warn.conflicts = FALSE)
#'
#' query(
#'   prefix = "SMQ02",
#'   id = auto,
#'   definition = smq_select(
#'     name = "Pregnancy and neonatal topics (SMQ)",
#'     scope = "NARROW"
#'   )
#' )
#'
#' # create a query for an SDG
#' query(
#'   prefix = "SDG01",
#'   id = auto,
#'   definition = sdg_select(
#'     name = "5-aminosalicylates for ulcerative colitis"
#'   )
#' )
#'
#' # creating a query for a customized query
#' cqterms <- tribble(
#'   ~TERM_NAME, ~TERM_ID,
#'   "APPLICATION SITE ERYTHEMA", 10003041L,
#'   "APPLICATION SITE PRURITUS", 10003053L
#' ) %>%
#'   mutate(TERM_LEVEL = "AEDECOD")
#'
#' query(
#'   prefix = "CQ01",
#'   name = "Application Site Issues",
#'   definition = cqterms
#' )
#'
#' # creating a customized query based on SMQs and additional terms
#' query(
#'   prefix = "CQ03",
#'   name = "Special issues of interest",
#'   definition = list(
#'     cqterms,
#'     smq_select(
#'       name = "Pregnancy and neonatal topics (SMQ)",
#'       scope = "NARROW"
#'     ),
#'     smq_select(
#'       id = 8050L,
#'       scope = "BROAD"
#'     )
#'   )
#' )
query <- function(prefix,
                  name = auto,
                  id = NULL,
                  add_scope_num = FALSE,
                  definition = NULL) {
  out <- list(
    prefix = prefix,
    name = enquo(name),
    id = enquo(id),
    add_scope_num = add_scope_num,
    definition = definition
  )
  # evaluate to ensure that name contains the quoted symbol auto or a character
  # string
  if (!is_auto(out$name) && !quo_is_missing(out$name)) {
    out$name <- eval_tidy(out$name)
  }
  # evaluate to ensure that id contains the quoted symbol auto or a number
  if (!is_auto(out$id)) {
    out$id <- eval_tidy(out$id)
  }
  class(out) <- c("query", "source", "list")
  validate_query(out)
}

#' Validate an object is indeed a `query` object
#'
#' @param obj An object to be validated.
#'
#' @author Stefan Bundfuss
#'
#' @keywords source_specifications
#' @family source_specifications
#'
#' @seealso [query()]
#'
#' @export
#'
#' @return The original object.
validate_query <- function(obj) {
  assert_s3_class(obj, "query")
  values <- unclass(obj)
  prefix <- values$prefix
  assert_character_scalar(prefix)

  if (!is_auto(values$name)) {
    name <- values$name
    assert_character_scalar(name)
  }

  if (!is_auto(values$id)) {
    id <- values$id
    assert_integer_scalar(id, optional = TRUE)
  }

  scope <- values$scope
  assert_character_scalar(scope,
    values = c("BROAD", "NARROW"),
    optional = TRUE
  )

  add_scope_num <- values$add_scope_num
  assert_logical_scalar(add_scope_num,
    optional = TRUE
  )
  if (add_scope_num && !inherits(values$definition, "smq_select")) {
    abort("`add_scope_num == TRUE` must be used for SMQs only.")
  }

  if (inherits(values$definition, "smq_select")) {
    validate_smq_select(values$definition)
  } else if (inherits(values$definition, "sdg_select")) {
    validate_sdg_select(values$definition)
  } else if (is.data.frame(values$definition) || is.list(values$definition)) {
    if (is_auto(values$name)) {
      abort(
        paste0(
          "The auto keyword can be used for SMQs and SDGs only.\n",
          "It was provided for the name element."
        )
      )
    }
    if (is_auto(values$id)) {
      abort(
        paste0(
          "The auto keyword can be used for SMQs and SDGs only.\n",
          "It was provided for the id element."
        )
      )
    }
    if (is.data.frame(values$definition)) {
      assert_terms(
        terms = values$definition,
        source_text = "the data frame provided for the `definition` element"
      )
    } else {
      is_valid <-
        map_lgl(values$definition, is.data.frame) |
          map_lgl(values$definition, inherits, "smq_select")
      if (!all(is_valid)) {
        info_msg <- paste(sprintf(
          "\u2716 Element %s is %s",
          which(!is_valid),
          map_chr(values$definition[!is_valid], what_is_it)
        ),
        collapse = "\n"
        )
        err_msg <- sprintf(
          paste(
            "Each element of the list in the definition field must be a data frame",
            "or an object of class `smq_select` but the following are not:\n%s"
          ),
          info_msg
        )
        abort(err_msg)
      }

      for (i in seq_along(values$definition)) {
        if (is.data.frame(values$definition[[i]])) {
          assert_terms(
            terms = values$definition[[i]],
            source_text = paste0("the ", i, "th element of the definition field")
          )
        }
      }
    }
  } else {
    abort(
      paste0(
        "`definition` expects a `smq_select` or `sdg_select` object, a data frame,",
        " or a list of data frames and `smq_select` objects.\n",
        "An object of the following class was provided: ",
        class(values$definition)
      )
    )
  }
  obj
}

#' Asserts Requirements for Terms for Queries
#'
#' The function checks the requirements for terms for queries provided by the
#' user. The terms could have been provided directly in the query definition or
#' via a user provided function for accessing a SMQ or SDG database.
#'
#' @param terms Terms provided by user
#'
#' @param expect_query_name Is the `QUERY_NAME` column expected?
#'
#' @param expect_query_id Is the `QUERY_ID` column expected?
#'
#' @param source_text Text describing the source of the terms, e.g., `"the data
#'   frame provided for the `definition` element"`.
#'
#' @return An error is issued if
#'
#' - `terms` is not a data frame,
#' - `terms` has zero observations,
#' - the `TERM_LEVEL` variable is not in `terms`,
#' - neither the `TERM_NAME` nor the `TERM_ID` variable is in `terms`,
#' - `expect_query_name == TRUE` and the `QUERY_NAME` variable is not in `terms`,
#' - `expect_query_id == TRUE` and the `QUERY_ID` variable is not in `terms`,
#'
#' @examples
#'
#' try(
#'   assert_terms(
#'     terms = 42,
#'     source_text = "object provided by the `definition` element"
#'   )
#' )
#' @export
#'
#' @seealso [create_query_data()], [query()]
#'
#' @keywords source_specifications
#' @family source_specifications
#'
#' @author Stefan Bundfuss
assert_terms <- function(terms,
                         expect_query_name = FALSE,
                         expect_query_id = FALSE,
                         source_text) {
  if (!is.data.frame(terms)) {
    abort(paste0(
      source_text,
      " is not a data frame but ",
      what_is_it(terms),
      "."
    ))
  }

  if (nrow(terms) == 0) {
    abort(paste0(
      source_text,
      " does not contain any observations."
    ))
  }

  vars <- names(terms)
  if (!"TERM_LEVEL" %in% vars) {
    abort(
      paste0(
        "Required variable `TERM_LEVEL` is missing in ",
        source_text,
        "."
      )
    )
  }
  if (expect_query_name) {
    if (!"QUERY_NAME" %in% vars) {
      abort(
        paste0(
          "Required variable `QUERY_NAME` is missing in ",
          source_text,
          "."
        )
      )
    }
  }
  if (expect_query_id) {
    if (!"QUERY_ID" %in% vars) {
      abort(
        paste0(
          "Required variable `QUERY_ID` is missing in ",
          source_text,
          "."
        )
      )
    }
  }
  if (!"TERM_NAME" %in% vars & !"TERM_ID" %in% vars) {
    abort(
      paste0(
        "Variable `TERM_NAME` or `TERM_ID` is required.\n",
        "None of them is in ",
        source_text,
        ".\n",
        "Provided variables: ",
        enumerate(vars)
      )
    )
  }
}

#' Create an `smq_select` object
#'
#' @param name Name of the query used to select the definition of the query from
#'   the company database.
#'
#' @param id Identifier of the query used to select the definition of the query
#'   from the company database.
#'
#' @param scope Scope of the query used to select the definition of the query
#'   from the company database.
#'
#'   *Permitted Values*: `"BROAD"`, `"NARROW"`
#'
#' @details Exactly one of `name` or `id` must be specified.
#'
#' @return An object of class `smq_select`.
#'
#' @author Stefan Bundfuss
#'
#' @seealso [create_query_data()], [query()]
#'
#' @family source_specifications
#' @keywords source_specifications
#'
#' @export
smq_select <- function(name = NULL,
                       id = NULL,
                       scope = NULL) {
  out <- list(
    name = name,
    id = id,
    scope = scope
  )
  class(out) <- c("smq_select", "source", "list")
  validate_smq_select(out)
}

#' Validate an object is indeed a `smq_select` object
#'
#' @param obj An object to be validated.
#'
#' @seealso [smq_select()]
#'
#' @keywords source_specifications
#' @family source_specifications
#'
#' @author Stefan Bundfuss
#'
#' @export
#'
#' @return The original object.
validate_smq_select <- function(obj) {
  assert_s3_class(obj, "smq_select")
  values <- unclass(obj)
  name <- values$name
  assert_character_scalar(name,
    optional = TRUE
  )
  id <- values$id
  assert_integer_scalar(id,
    optional = TRUE
  )
  scope <- values$scope
  assert_character_scalar(scope,
    values = c("BROAD", "NARROW")
  )

  if (is.null(values$id) && is.null(values$name)) {
    abort("Either id or name has to be non null.")
  }
  if (!is.null(values$id) && !is.null(values$name)) {
    abort("Either id or name has to be null.")
  }
  obj
}

#' Returns a Character Representation of a `smq_select()` Object
#'
#' The function returns a character representation of a `smq_select()` object.
#' It can be used for error messages for example.
#'
#' @param x A `smq_select()` object
#'
#' @param ... Not used
#'
#' @return A character representation of the `smq_select()` object
#'
#' @author Stefan Bundfuss
#'
#' @seealso [smq_select()]
#'
#' @keywords source_specifications
#' @family source_specifications
#'
#' @export
#'
#' @examples
#'
#' format(smq_select(id = 42, scope = "NARROW"))
format.smq_select <- function(x, ...) {
  paste0(
    "smq_select(name = ",
    dquote(x$name),
    ", id = ",
    format(x$id),
    ", scope = ",
    dquote(x$scope),
    ")"
  )
}

#' Create an `sdg_select` object
#'
#' @param name Name of the query used to select the definition of the query
#'   from the company database.
#'
#' @param id Identifier of the query used to select the definition of the query
#'   from the company database.
#'
#' @details Exactly one `name` or `id` must be specified.
#'
#' @return An object of class `sdg_select`.
#'
#' @author Stefan Bundfuss
#'
#' @seealso [create_query_data()], [query()]
#'
#' @family source_specifications
#' @keywords source_specifications
#'
#' @export
sdg_select <- function(name = NULL,
                       id = NULL) {
  out <- list(
    name = name,
    id = id
  )
  class(out) <- c("sdg_select", "source", "list")
  validate_sdg_select(out)
}

#' Validate an object is indeed a `sdg_select` object
#'
#' @param obj An object to be validated.
#'
#' @author Stefan Bundfuss
#'
#' @seealso [sdg_select()]
#'
#' @keywords source_specifications
#' @family source_specifications
#'
#' @export
#'
#' @return The original object.
validate_sdg_select <- function(obj) {
  assert_s3_class(obj, "sdg_select")
  values <- unclass(obj)
  name <- values$name
  assert_character_scalar(name,
    optional = TRUE
  )
  id <- values$id
  assert_integer_scalar(id,
    optional = TRUE
  )
  if (is.null(values$id) && is.null(values$name)) {
    abort("Either id or name has to be non null.")
  }
  if (!is.null(values$id) && !is.null(values$name)) {
    abort("Either id or name has to be null.")
  }
  obj
}

#' Returns a Character Representation of a `sdg_select()` Object
#'
#' The function returns a character representation of a `sdg_select()` object.
#' It can be used for error messages for example.
#'
#' @param x A `sdg_select()` object
#'
#' @param ... Not used
#'
#' @return A character representation of the `sdg_select()` object
#'
#' @author Stefan Bundfuss
#'
#' @seealso [sdg_select()]
#'
#' @keywords source_specifications
#' @family source_specifications
#'
#' @export
#'
#' @examples
#'
#' format(
#'   sdg_select(
#'     name = "5-aminosalicylates for ulcerative colitis"
#'   )
#' )
format.sdg_select <- function(x, ...) {
  paste0(
    "sdg_select(name = ",
    dquote(x$name),
    ", id = ",
    format(x$id),
    ")"
  )
}
