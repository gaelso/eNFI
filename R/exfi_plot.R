#' Plot level information for 10 plots in Tropical Forests.
#'
#' A dataset containing land cover, global ecological zone and environmental 
#' stress information for 10 forest plots in the Tropical global ecological 
#' zone. This data is aligned with the tree data in real forest inventories, 
#' but anonymized and edited for educational purposes. For more information, 
#' see the `eNFIrawdata` package. These 10 plots' data were selected randomly 
#' for creating a fictional exploration forest inventory for the `eNFI` 
#' practice lessons.
#'
#' @format A data frame with 10 rows and 6 variables:
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
#'   exfi_plot
"exfi_plot"