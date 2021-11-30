#' Measurements of 174 trees in Tropical Forests.
#'
#' A dataset containing the measurement of 174 trees from 10 forest plots 
#' in the Tropical global ecological zone. The tree data measurements come 
#' from real forest inventories in the Tropics, anonymized and edited for 
#' educational purposes. For more information, see the `eNFIrawdata` package. 
#' These measurements were selected randomly for creating a fictional 
#' exploration forest inventory for the `eNFI` practice lessons. The 
#' aboveground biomass `tree_agb` was calculated with Chave et al. 2014 
#' pantropical allometric equation.
#'   
#' @format A data frame with 174 rows and 15 variables:
#' \describe{
#'   \item{plot_id}{Unique identifier of the forest plots where trees were 
#'     measured.}
#'   \item{tree_id}{Unique identifier of the trees in the table.}
#'   \item{tree_no}{Tree number in the plot.}
#'   \item{tree_dbh}{Tree diameter at breast height in cm.}
#'   \item{tree_pom}{Tree point of measurement in m.}
#'   \item{tree_height_top}{Tree total height in m.}
#'   \item{tree_dist}{Tree distance to the plot center point in m.}
#'   \item{tree_azimuth}{Tree azimuth from the plot center in degrees (0 to 
#'     360).}
#'   \item{tree_health}{Tree health noted 0, 1 or 2 for healthy, slightly 
#'     affected or severely affected.}
#'   \item{sp_name}{Binomial mock species name.}
#'   \item{genus}{Mock genus name.}
#'   \item{tree_wd}{Wood density at species or genus level.}
#'   \item{scale_factor}{Wood density at species or genus level.}
#'   \item{tree_ba}{Wood density at species or genus level.}
#'   \item{tree_agb}{Wood density at species or genus level.}
#' }
#' 
#' @source Anonymized tropical forest inventories.
#' 
#' @examples
#'   exfi_tree
"exfi_tree"