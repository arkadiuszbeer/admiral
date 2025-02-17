% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/derive_vars_aage.R
\name{derive_var_age_years}
\alias{derive_var_age_years}
\title{Derive Age in Years}
\usage{
derive_var_age_years(dataset, age_var, age_unit = NULL, new_var)
}
\arguments{
\item{dataset}{Input dataset.}

\item{age_var}{AGE variable.}

\item{age_unit}{AGE unit variable.

The AGE unit variable is used to convert AGE to 'years' so that grouping can occur.
This is only used when the age_var variable does not have a corresponding unit in the dataset.

Default: NULL

Permitted Values: 'years', 'months', 'weeks', 'days', 'hours', 'minutes', 'seconds'}

\item{new_var}{New AGE variable to be created in years.}
}
\value{
The input dataset with new_var parameter added in years.
}
\description{
Derive Age in Years
}
\details{
This function is used to convert age variables into years.
These can then be used to create age groups.
}
\examples{

library(dplyr, warn.conflicts = FALSE)

data <- data.frame(
  AGE = c(27, 24, 3, 4, 1),
  AGEU = c("days", "months", "years", "weeks", "years")
)

data \%>\%
  derive_var_age_years(., AGE, new_var = AAGE)

data.frame(AGE = c(12, 24, 36, 48)) \%>\%
  derive_var_age_years(., AGE, age_unit = "months", new_var = AAGE)
}
\seealso{
ADSL Functions that returns variable appended to dataset: 
\code{\link{derive_var_disposition_status}()},
\code{\link{derive_var_dthcaus}()},
\code{\link{derive_var_extreme_dtm}()},
\code{\link{derive_var_extreme_dt}()},
\code{\link{derive_vars_aage}()},
\code{\link{derive_vars_disposition_reason}()},
\code{\link{derive_vars_period}()}
}
\author{
Michael Thorpe
}
\concept{der_adsl}
\keyword{der_adsl}
