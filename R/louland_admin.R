#' Fictional island simple feature
#' 
#' Fictional island created in the middle of the Atlantic Ocean. This simple 
#' feature represents the island's overall boundaries.
#' 
#' @format Simple feature of type POLYGON with 1 feature and 0 fields
#' \describe{
#'   \item{x}{Polygon geometry}
#' 
#' @source Created with `NLMR` and `terra`.
#' 
#' @examples
#' library(ggplot)
#' library(sf)
#' 
#' ggplot(louland_admin) +
#'   geom_sf()
#' 
"louland_admin"