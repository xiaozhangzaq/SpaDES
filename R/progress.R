#' @importFrom stats na.omit
doEvent.progress = function(sim, eventTime, eventType, debug = FALSE) {
  if (eventType == "init") {
    if (interactive()) {
      tu <- timeunit(sim)
      defaults <- list(type = "text", interval = (end(sim, tu) - start(sim, tu))/(end(sim, tu)-start(sim,tu)))

      # Check whether a .progress is specified in the simList
      if ( is.null(P(sim, ".progress")$type) &&
             is.null(P(sim, ".progress")$interval) ) {
        params(sim)[[".progress"]] = defaults
      } else {
        ids <- na.omit(match(names(P(sim, ".progress")), c("type", "interval")))
        params(sim)[[".progress"]][names(defaults)[-ids]] <- defaults[-ids]
      }
    } else {
      # don't use progress bar when non-interactive (this is already set during simInit)
      params(sim)[[".progress"]] <- list(type = NA, interval = NA_real_)
    }

    # if NA then don't use progress bar
    if (any(!is.na(P(sim, ".progress")))) {
      newProgressBar(sim)
      sim <- scheduleEvent(sim, start(sim, tu), "progress", "set", .last())
      sim <- scheduleEvent(sim, end(sim, tu), "progress", "set", .last())
    }
  } else if (eventType == "set") {
      # update progress bar
      setProgressBar(sim)

      # schedule the next save
      timeNextUpdate <- time(sim, timeunit(sim)) + P(sim, ".progress")$interval

      sim <- scheduleEvent(sim, timeNextUpdate, "progress", "set", .last())
  } else {
    warning(paste(
      "Undefined event type: \'", current(sim)[1, "eventType", with = FALSE],
      "\' in module \'", current(sim)[1, "moduleName", with = FALSE], "\'", sep = ""
    ))
  }
  return(invisible(sim))
}

################################################################################
#' Progress bar
#'
#' Shows a progress bar that is scaled to simulation end time.
#'
#' The progress bar object is stored in a separate environment,
#' \code{.spadesEnv}.
#'
#' @param sim A \code{simList} simulation object.
#'
#' @author Alex Chubaty
#' @author Eliot McIntire
#' @importFrom tcltk tkProgressBar
# @importFrom utils txtProgressBar winProgressBar
#' @include environment.R
#' @export
#' @docType methods
#' @rdname newProgressBar
newProgressBar <- function(sim) {
  if (exists(".pb", envir = .spadesEnv)) {
    close(get(".pb", envir = .spadesEnv))
    # rm(.pb, envir = .spadeEnv)
  }
  tu <- timeunit(sim)
  OS <- tolower(Sys.info()["sysname"])
  if (P(sim, ".progress")$type == "graphical") {
    if (OS == "windows") {
      pb <- winProgressBar(min = start(sim, tu), max = end(sim, tu),
                           initial = start(sim, tu))
    } else {
      pb <- tkProgressBar(min = start(sim, tu), max = end(sim, tu),
                          initial = start(sim, tu))
    }
  } else if (P(sim, ".progress")$type == "shiny"){
    ## see http://shiny.rstudio.com/articles/progress.html
    stop("shiny progress bar not yet implemented")
  } else  if (P(sim, ".progress")$type == "text") {
    pb <- txtProgressBar(min = start(sim, tu), max = end(sim, tu),
                         initial = start(sim, tu), char = ".", style = 3)
  }
  assign(".pb", pb, envir = .spadesEnv)
}

#' @importFrom tcltk setTkProgressBar
# @importFrom utils setTxtProgressBar setWinProgressBar
setProgressBar <- function(sim) {
  OS <- tolower(Sys.info()["sysname"])
  tu <- timeunit(sim)
  pb <- get(".pb", envir = .spadesEnv)
  if (P(sim, ".progress")$type == "graphical") {
    if (OS == "windows") {
      utils::setWinProgressBar(
        pb, time(sim, tu),
        title = paste("Current simulation time:", tu, round(time(sim, tu), 3),
                      "of total", end(sim, tu))
      )
    } else {
      setTkProgressBar(pb, time(sim, tu),
                       title = paste("Current simulation time:", tu,
                                     round(time(sim, tu), 3),
                                     "of total", end(sim, tu)))
    }
  } else if (P(sim, ".progress")$type == "shiny") {
    ## see http://shiny.rstudio.com/articles/progress.html
    stop("shiny progress bar not yet implemented")
  } else if (P(sim, ".progress")$type == "text") {
    setTxtProgressBar(pb, round(time(sim, tu), 3))
  }
  assign(".pb", pb, envir = .spadesEnv)
}
