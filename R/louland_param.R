#' Parameters for the fictional island Louland
#' 
#' Louland is a fictional island created in the middle of the Atlantic Ocean 
#' and designed for practicing National Forest Inventory sampling and data 
#' analysis. This table contains Louland's land cover codes, their area 
#' weight and color code for mapping. The land cover codes represent:
#' EV:Evergreen Forest, MD:Mixed-Deciduous Forest, DD:Deciduous Forest, 
#' WL: Other Woodlands, MG:Mangrove, NF:Non-Forest, and WA:Water.
#' For more information see: 
#' https://www.fao.org/national-forest-monitoring/areas-of-work/nfi/modules/en/
#' 
#' @format A table with 7 rows and 4 columns.
#' \describe{
#'   \item{lc_id}{Land cover ID.}
#'   \item{lc}{Land cover code.}
#'   \item{w}{Land cover area weight.}
#'   \item{hex}{Land cover mapping colors.}
#' }
#' 
#' @source Created with `NLMR`, `terra`, `stars` and `smoothr`.
#' 
#' @examples
#' louland_param
"louland_param"