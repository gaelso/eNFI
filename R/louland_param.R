#' Anonymized plot level information for 862 plots in Tropical Forests.
#'
#' A dataset containing pot level information for 862 plots in Tropical 
#' Forests. This data has been heavily edited to ensure minimum disclosure 
#' of sensitive information and should be used for educational purposes only.  
#'
#' @format A data frame with 862 rows and 6 variables:
#' \describe{
#'   \item{plot_id}{Unique identifier of the forest plots where trees were 
#'     measured.}
#'   \item{gez_name}{name of FAO Global Ecological Zone 2010 at the original 
#'     plot location.}
#'   \item{gez_code}{code of FAO Global Ecological Zone 2010 at the original 
#'     plot location.}
#'   \item{lu_factor}{Harmonized land use at the original plot location.}
#'   \item{lu_code}{Harmonized land use code at the original plot location.}
#'   \item{envir_stress}{Environmental stress at the original plot location 
#'     based on Chave et al 2014.}
#' }
#' 
#' @source Anonymized tropical forest inventories.
#' 
#' @examples
#'   raw_plot
"raw_plot"