% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/times.R
\docType{methods}
\name{dyears}
\alias{dNA}
\alias{dNA,ANY-method}
\alias{dday}
\alias{dhour}
\alias{dmonth}
\alias{dmonths}
\alias{dmonths,numeric-method}
\alias{dsecond}
\alias{dweek}
\alias{dweeks}
\alias{dweeks,numeric-method}
\alias{dyear}
\alias{dyears}
\alias{dyears,numeric-method}
\title{SpaDES time units}
\usage{
dyears(x)

\S4method{dyears}{numeric}(x)

dmonths(x)

\S4method{dmonths}{numeric}(x)

dweeks(x)

\S4method{dweeks}{numeric}(x)

dweek(x)

dmonth(x)

dyear(x)

dsecond(x)

dday(x)

dhour(x)

dNA(x)

\S4method{dNA}{ANY}(x)
}
\arguments{
\item{x}{numeric. Number of the desired units}
}
\value{
Number of seconds within each unit
}
\description{
\code{SpaDES} modules commonly use approximate durations that divide with no
remainder among themselves.
For example, models that simulate based on a "week" timestep, will likely
want to fall in lock step with a second module that is a "year" timestep.
Since, weeks, months, years don't really have this behaviour because of:
leap years, leap seconds, not quite 52 weeks in a year, months that are of
different duration, etc.
We have generated a set of units that work well together that are based on
the astronomical or "Julian" year.
In an astronomical year, leap years are added within each year with an extra
1/4 day, (i.e., 1 year == 365.25 days); months are defined as year/12, and
weeks as year/52.
}
\details{
When these units are not correct, a module developer can create their own
time unit using, and create a function to calculate the number of seconds
in that unit using the "d" prefix (for duration), following the
\code{lubridate} package standard:
\code{dfortNight <- function(x) lubridate::duration(dday(14))}.
Then the module developer can use "fortNight" as the module's time unit.
}
\author{
Eliot McIntire
}

