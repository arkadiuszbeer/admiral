% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/restrict_derivation.R
\name{restrict_derivation}
\alias{restrict_derivation}
\title{Execute a Derivation on a Subset of the Input Dataset}
\usage{
restrict_derivation(dataset, derivation, args = NULL, filter)
}
\arguments{
\item{dataset}{Input dataset}

\item{derivation}{Derivation}

\item{args}{Arguments of the derivation

A \code{params()} object is expected.}

\item{filter}{Filter condition}
}
\description{
Execute a derivation on a subset of the input dataset.
}
\examples{

library(tibble)
library(magrittr)
adlb <- tribble(
  ~USUBJID, ~AVISITN, ~AVAL, ~ABLFL,
  "1",            -1,   113, NA_character_,
  "1",             0,   113, "Y",
  "1",             3,   117, NA_character_,
  "2",             0,    95, "Y",
  "3",             0,   111, "Y",
  "3",             1,   101, NA_character_,
  "3",             2,   123, NA_character_
)

# Derive BASE for post-baseline records only (derive_var_base() can not be used in this case
# as it requires the baseline observation to be in the input dataset)
restrict_derivation(
  adlb,
  derivation = derive_vars_merged,
  args = params(
    by_vars = vars(USUBJID),
    dataset_add = adlb,
    filter_add = ABLFL == "Y",
    new_vars = vars(BASE = AVAL)
  ),
  filter = AVISITN > 0
)

# Derive BASE for baseline and post-baseline records only
restrict_derivation(
  adlb,
  derivation = derive_var_base,
  args = params(
    by_vars = vars(USUBJID)
  ),
  filter = AVISITN >= 0
) \%>\%
  # Derive CHG for post-baseline records only
  restrict_derivation(
    derivation = derive_var_chg,
    filter = AVISITN > 0
  )
}
\seealso{
\code{\link[=params]{params()}} \code{\link[=slice_derivation]{slice_derivation()}}

Higher Order Functions: 
\code{\link{call_derivation}()},
\code{\link{derivation_slice}()},
\code{\link{slice_derivation}()}
}
\author{
Stefan Bundfuss
}
\concept{high_order_function}
\keyword{high_order_function}
