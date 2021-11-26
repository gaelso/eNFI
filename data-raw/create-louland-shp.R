## Function for converting land cover raster to shapefile and simplifying
## Considering moving the function to the package but keeping it out for now

## TO BE MOVED TO usethis::use_package() when making this a package function
## Libs
library(tidyverse)
library(terra)
library(raster)
library(stars)
library(smoothr)
library(sf)

## For testing
.newland <- create_newland(.seed = 11, .alt = 2000, .sea = 0.2, .mg = T)
.lc      <- .newland$lc_map
.param   <- .newland$param
##

## Function
#' Convert land cover raster object to `sf` and simplify its polygon boundaries
#'
#' @description 
#' TBD. Combines `stars`, `sf` and `smoothr` to create simplified vector 
#' object out of a categorical SpatRaster object. 
#' 
#' @param .lc lc_map output of the function `create_newland()`.
#' @param .param param output of the function `create_newland()`.
#' @param .smoothness passed on to `smoothr::smooth()`.
#'
#' @return
#' simplified vector MULTIPOLYGON `sf` object.
#' 
#' @examples
#' ## Create a new land
#' tt <- create_newland(.seed = NULL, .alt = 2000, .sea = 0.1, .mg = TRUE)
#' 
#' ## vectorize and simplify
#' sf_vec <- create_shp(.lc = tt$lc_map, .param = tt$param, .smoothness = 2.2)
#' 
#' @export
make_shp <- function(.lc, .param, .smoothness = 2.2){
  
  ## Create land cover shapefile
  sf_lc <- stars::st_as_stars(.lc) %>%
    sf::st_as_sf(., as_points = FALSE, merge = TRUE) %>%
    sf::st_set_crs(st_crs(32727)) %>%
    dplyr::rename(lc_id = lc) %>%
    dplyr::left_join(.param %>% dplyr::select(lc_id, lc), by = "lc_id") %>%
    dplyr::mutate(
      id = 1:nrow(.),
      lc = forcats::fct_reorder(lc, lc_id)
    ) %>%
    #sf::st_cast("MULTIPOLYGON") %>%
    sf::st_make_valid() %>%
    dplyr::filter(lc != "WA" | id == 145)
  
  ## Check
  # ggplot() +
  #   geom_sf(data = sf_lc, aes(fill = lc)) +
  #   scale_fill_manual(values = .param$hex) +
  #   theme_bw()
  # 
  # table(st_is_valid(sf_lc))
  # sf::st_is_valid(sf_lc, reason = TRUE)
  
  
  sf_lc2 <- sf_lc %>%
    smoothr::smooth(method = "ksmooth", smoothness = .smoothness) %>%
    dplyr::mutate(id = 1:nrow(.))
  
  ## Checks
  # ggplot() +
  #   geom_sf(data = sf_lc2, aes(fill = lc)) +
  #   scale_fill_manual(values = .param$hex) +
  #   theme_bw()
  # 
  # table(st_is_valid(sf_lc2))
  # st_is_valid(sf_lc2, reason = TRUE)
  
  sf_lc3 <- sf_lc2 %>%
    st_make_valid() %>%
    st_cast("POLYGON")
  
  return(sf_lc3)
  
} ## End make_3d



