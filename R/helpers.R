################################################################################
#' Blank (template) event list
#'
#' Internal function called from \code{spades}, returning an empty event list.
#'
#' Event lists are sorted (keyed) first by time, second by priority.
#' Each event is represented by a \code{\link{data.table}} row consisting of:
#' \tabular{ll}{
#'   \code{eventTime} \tab The time the event is to occur.\cr
#'   \code{moduleName} \tab The module from which the event is taken.\cr
#'   \code{eventType} \tab A character string for the programmer-defined event type.\cr
#'   \code{eventPriority} \tab The priority given to the event. \cr
#' }
#'
#' @param eventTime      The time the event is to occur.
#' @param moduleName     The module from which the event is taken.
#' @param eventType      A character string for the programmer-defined event type.
#' @param eventPriority  The priority given to the event.
#'
#' @return Returns an empty event list.
#'
#' @importFrom data.table data.table
#' @keywords internal
#' @docType methods
#' @rdname emptyEventList
#'
#' @author Alex Chubaty
setGeneric(".emptyEventList", function(eventTime, moduleName, eventType, eventPriority) {
  standardGeneric(".emptyEventList")
})

#' @rdname emptyEventList
#' @importFrom data.table data.table
.emptyEventListDT <- data.table(eventTime = integer(0L), moduleName = character(0L),
                                eventType = character(0L), eventPriority = numeric(0L))

#' @rdname emptyEventList
#' @importFrom data.table data.table
.singleEventListDT <- data.table(eventTime = integer(1L), moduleName = character(1L),
                                 eventType = character(1L), eventPriority = numeric(1L))

#' @rdname emptyEventList
#' @importFrom data.table set copy
setMethod(
  ".emptyEventList",
  signature(eventTime = "numeric", moduleName = "character",
            eventType = "character", eventPriority = "numeric"),
  definition = function(eventTime, moduleName, eventType, eventPriority) {
    # This is faster than direct call to new data.table
    eeldt <- data.table::copy(.singleEventListDT)
    data.table::set(eeldt, , "eventTime", eventTime)
    data.table::set(eeldt, , "moduleName", moduleName)
    data.table::set(eeldt, , "eventType", eventType)
    data.table::set(eeldt, , "eventPriority", eventPriority)
    # data.table(eventTime = eventTime, moduleName = moduleName,
    #           eventType = eventType, eventPriority = eventPriority)
    eeldt
    # don't set key because it is set later when used
})

#' @rdname emptyEventList
setMethod(
  ".emptyEventList",
  signature(eventTime = "missing", moduleName = "missing",
            eventType = "missing", eventPriority = "missing"),
  definition = function() {
    data.table::copy(.emptyEventListDT)
    #data.table(eventTime = numeric(0L), moduleName = character(0L),
    #           eventType = character(0L), eventPriority = numeric(0L))
})

#' @rdname emptyEventList
.emptyEventListCols <- colnames(.emptyEventList())

#' @rdname emptyEventList
.emptyEventListObj <- .emptyEventList()

#' @rdname emptyEventList
.emptyEventListNA <- .emptyEventList(NA_integer_, NA_character_, NA_character_, NA_integer_)


################################################################################
#' Default (empty) metadata
#'
#' Internal use only.
#' Default values to use for metadata elements when not otherwise supplied.
#'
#' @param x  Not used. Should be missing.
#'
#' @importFrom raster extent
#' @keywords internal
#' @include simList-class.R
#' @docType methods
#' @rdname emptyMetadata
#' @author Alex Chubaty
#'
setGeneric(".emptyMetadata", function(x) {
  standardGeneric(".emptyMetadata")
})

#' @rdname emptyMetadata
setMethod(
  ".emptyMetadata",
  signature(x = "missing"),
  definition = function() {
    out <- list(
      name = character(0),
      description = character(0),
      keywords = character(0),
      childModules = character(0),
      authors = person("unknown"),
      version = numeric_version(NULL),
      spatialExtent = raster::extent(rep(NA_real_, 4)),
      timeframe = as.POSIXlt(c(NA, NA)),
      timeunit = NA_character_,
      citation = list(),
      documentation = list(),
      reqdPkgs = list(),
      parameters = defineParameter(),
      inputObjects = .inputObjects(),
      outputObjects = .outputObjects()
    )
    return(out)
})

#' Find objects if passed as character strings
#'
#' Objects are passed into simList via \code{simInit} call or \code{objects(simList)}
#' assignment. This function is an internal helper to find those objects from their
#' environments by searching the call stack.
#'
#' @param objects A character vector of object names
#' @param functionCall A character string identifying the function name to be
#' searched in the call stack. Default is "simInit"
#'
#' @docType methods
#' @rdname findObjects
#' @name findObjects
#' @author Eliot McIntire
.findObjects <- function(objects, functionCall = "simInit") {
  scalls <- sys.calls()
  grep1 <- grep(as.character(scalls), pattern = functionCall)
  grep1 <- pmax(min(grep1[sapply(scalls[grep1], function(x) {
    tryCatch(
      is(parse(text = x), "expression"),
      error = function(y) { NA })
  })], na.rm = TRUE)-1, 1)
  # Convert character strings to their objects
  lapply(objects, function(x) get(x, envir = sys.frames()[[grep1]]))
}


