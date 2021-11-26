## Function for creating Louland from scratch
## Considering moving the function to the package but keeping it out for now

## TO BE MOVED TO usethis::use_package() when making this a package function
## Libs
#remotes::install_version("NLMR", "0.4")
library(tidyverse)
library(NLMR)
library(landscapetools)
library(raster)
library(terra)

## Function
#' Create a new land
#'
#' @description 
#' `create_newland()` generate a fictional island in the middle of the 
#' Atlantic ocean based on a 90 x 90 km square. The function generate land 
#' cover and topographic SpatRaster (`terra` package) with both 1000 pixels 
#' size and 90m resolution and 3000 pixels size and 30m resolution. The 
#' underlying functions come from the packages `NLMR` and `landscapetools`.
#' 
#' In the current version the land cover raster contains 4 forest types: 
#' EV: Evergreen, MD: Mixed-deciduous, DD: Deciduous, WL: Other Woodland; 2 
#' other non-forest land cover: WA: water, NF: Non-forest. Finally, Mangrove 
#' forest (MG) canbe opted in. 
#' 
#' 
#' @param .seed Numerical. Passed on to set.seed() for the random `NLMR` functions 
#'   (default 11, tested and looks good).
#' @param .alt Integer. Max altitude of the new land in meters.
#' @param .sea Numerical, between 0 and 0.5. Ratio of pixels of the defined 
#'   proportion will have elevation below 0.
#' @param .mg Boolean. Add mangrove? Default TRUE. All lands with elevation 
#'   in [-10:20] are considered mangrove in one sector of the map. Optimized 
#'   for seed 11, but works in most cases
#'
#' @return
#'  A list of 4 SpatRaster objects: `topo` and `topo_map` respectively the 
#'  30 and 90 meters resolution topographic raster products, `lc` and `lc_map` 
#'  respectively the 30 and 90 meters resoltion land cover raster products, 
#'  and `param` the land cover parameters (color, codes and weights).
#' 
#' @examples
#' ## Create a new land
#' tt <- create_newland(.seed = NULL, .alt = 2000, .sea = 0.1, .mg = TRUE)
#' 
#' plot(tt$lc_map, col = tt$param$hex, legend = FALSE, axes = F)
#' legend("bottomleft",
#'       legend = tt$param$lc,
#'        fill = tt$param$hex)
#'
#' @export
create_newland <- function(.seed = 11, .alt = 2000, .sea = 0.2, .mg = T){
  
  message("Initiating data creation...")
  
  ## Validation Rules #######################################################
  
  ## --- Valid numeric values ----------------------------------------------- 
  # if (!is.numeric(unlist(as.list(environment())))) stop("input variables not all numeric!")
  if (!(is.numeric(.seed)& .seed == round(.seed)))                       stop(".seed must be an integer value.")
  if (!(is.numeric(.alt) & .alt == round(.alt)))                         stop(".alt must be an integer value.")
  if (!(is.numeric(.sea) & .sea >= 0 & .sea <= 0.5))                     stop(".sea must be a numeric value between 0 and 0.5.")
  
  ## --- Valid booleans -----------------------------------------------------
  if (!is.logical(.mg)) stop(".mg must be a boolean TRUE or FALSE")
  
  
  ## Setup ##################################################################
  
  ## --- Sizes -------------------------------------------------------------- 
  length <- 90              ## End results length in km
  res    <- 90              ## End results resolution in m
  ll     <- length * 10^3   ## Conversion km to m
  pp     <- round(ll / res) ## End results pixels number
  mp     <- 1000            ## Map pixels number
  ff     <- round(pp/mp)    ## Aggregation/disaggregation factor
  rr     <- res * ff        ## map resolution in m
  
  ## --- Country location setting (Middle of Atlantic Ocean) ----------------
  country_loc <- list(
    crs = "+proj=utm +zone=27 +south +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0", 
    xmin = 560363, 
    ymin = 9919901
  )
  
  ## --- Forest types parameters --------------------------------------------
  ft_param <- tibble(
    lc_id = c(   5,    4,    3,    2),
    lc    = c("EV", "MD", "DD", "WL"),
    w     = c(0.11, 0.23, 0.08, 0.21),
  ) %>%
    bind_rows(list(lc_id = 1, lc = "NF", w = 1 - sum(.$w))) %>%
    arrange(lc_id) %>%
    mutate(
      hex = c("#edf5e1", "#ffcb9a", "#5cdb95", "#379683", "#00743f")
    )
  
  ## --- Land cover parameters extension ------------------------------------
  lc_param <- ft_param %>% 
    bind_rows(list(lc_id = c(0, 6), lc = c("WA", "MG"), w = c(0, 0), hex = c("#73c2fb", "#012172"))) %>%
    arrange(lc_id) %>%
    { if (!.mg) dplyr::filter(., lc_id != 6) else .}
  
  #scales::show_col(lc_param$hex)
  
  
  
  ## Make Topo Raster #######################################################
  
  time1 <- Sys.time()
  
  ## --- Make base layers ---------------------------------------------------
  if (!is.null(.seed)) set.seed(.seed)
  topo_mpd <- NLMR::nlm_mpd(nrow = mp+5,  ncol = mp+5, resolution = rr, roughness = 0.4, rescale = T, verbose = F)
  topo_mpd <- terra::crop(terra::rast(topo_mpd), terra::ext(0, ll, 0, ll))
  # topo_mpd
  # plot(topo_mpd)
  
  ## --- Apply sea ratio and max altitude -----------------------------------
  ## --- Translate a percentage of the pixels equal to .sea below 0
  ## With the raster package:
  ## topo_calc <- topo_mpd - raster::quantile(raster::raster(topo_mpd), probs = .sea)
  topo_calc <- topo_mpd - as.numeric(terra::global(x = topo_mpd, quantile, probs = .sea))
  
  ## --- Apply different max altitude to sea bottom and mountain top
  ## With the raster package:
  ## z_min <- raster::cellStats(raster::raster(topo_calc), "min")
  ## z_max <- raster::cellStats(raster::raster(topo_calc), "max")
  z_min <- as.numeric(terra::global(topo_calc, "min"))
  z_max <- as.numeric(terra::global(topo_calc, "max"))
  
  ## With the raster package:
  ## topo_calc[topo_calc <= 0] <- round(topo_calc[topo_calc <= 0] / abs(z_min) * (.alt / 4))
  ## topo_calc[topo_calc >  0] <- round(topo_calc[topo_calc >  0] / z_max * (.alt))
  topo_calc[topo_calc <= 0] <- round(topo_calc / abs(z_min) * (.alt / 4))
  topo_calc[topo_calc >  0] <- round(topo_calc / z_max * (.alt))
  
  ## --- Make smoother topo -------------------------------------------------
  ## With the raster package
  ## topo <- raster::focal(topo_calc, w = matrix(1/31^2, nc=31, nr=31), pad = T, padValue = 0) ## Supposed to be faster
  topo <- terra::focal(x = topo_calc, w = matrix(1, 31, 31), fun = "mean", fillvalue = 0)
  
  ## Add location
  terra::crs(topo)    <- country_loc$crs
  terra::ext(topo) <- c(country_loc$xmin, country_loc$xmin + ll, country_loc$ymin, country_loc$ymin + ll)
  
  ## Test
  # plot(topo)
  
  ## --- Sea mask -------------------------------------------------------------
  sea_mask <- topo
  sea_mask[sea_mask >  0] <- NA
  sea_mask[sea_mask <= 0] <- 1
  
  ## Test 
  # plot(sea_mask)
  
  
  ## Message topo
  time2 <- Sys.time()
  dt <- round(as.numeric(time2-time1, units = "secs"))
  message(paste0("...Topography created", " - ", dt, " Sec."))
  
  
  
  ## Make Land Cover Raster #################################################
  
  time1 <- Sys.time()
  
  ## --- Make base layers at 100 row and cols rasters -----------------------
  if (!is.null(.seed)) set.seed(.seed)
  ft_mpd <- NLMR::nlm_mpd(nrow = mp+5,  ncol = mp+5, resolution = rr, roughness = 0.7, rescale = T, verbose = F)
  ft_mpd <- terra::crop(terra::rast(ft_mpd), terra::ext(0, ll, 0, ll))
  ft_mpd <- terra::aggregate(ft_mpd, fact = 10, fun = "mean") 
  
  bkp_warn <- getOption("warn")
  options(warn = -1)
  ft_ne <- NLMR::nlm_neigh(nrow = mp/10,  ncol = mp/10, resolution = rr*10, 
                     p_neigh = 0.7, p_empty = 0.1,
                     categories = 5, proportions = ft_param$w, neighbourhood = 8)
  options(warn = bkp_warn)
  ## Need raster package for util_* functions
  ft_res <- landscapetools::util_merge(raster::raster(ft_mpd), ft_ne, scalingfactor = 0.1)
  
  # Test
  # landscapetools::show_landscape(list("mpd" = ft_mpd, "ne" = ft_ne, "res" = ft_res), n_col = 1)
  
  ## Disaggregate
  ft <- raster::disaggregate(ft_res, fact = 10, method = 'bilinear')
  ft <- landscapetools::util_classify(ft, weighting = ft_param$w, level_names = ft_param$id)
  
  ## Convert to SpatRaster
  ft <- terra::rast(ft)
  
  ## Add location
  terra::crs(ft)    <- country_loc$crs
  terra::ext(ft) <- c(country_loc$xmin, country_loc$xmin + ll, country_loc$ymin, country_loc$ymin + ll)
  
  ## Message Forest type
  time2 <- Sys.time()
  dt <- round(as.numeric(time2-time1, units = "secs"))
  message(paste0("...Forest types created", " - ", dt, " Sec."))
  
  
  
  ## Mangrove mask ##########################################################
  
  if (.mg) {
    
    time1 <- Sys.time()
    
    mg <- topo
    mg[mg <  -10 | mg >  20] <- NA
    mg[mg >= -10 & mg <= 20] <- 1
    mg[,1:600]    <- NA
    mg[700:1000,] <- NA
    
    ## Test
    # plot(mg)
    
    ## Message mangroves
    time2 <- Sys.time()
    dt <- round(as.numeric(time2-time1, units = "secs"))
    message(paste0("...Mangroves added", " - ", dt, " Sec."))
    
  } ## END IF .mg
  
  
  
  ## Combine all land covers ################################################
  
  time1 <- Sys.time()
  
  ## Added land covers based on masks
  lc <- ft
  
  ## With raster package, changing levels requires ratify()
  ## lc <- ratify(lc)
  
  ## Update levels
  levels(lc) <- lc_param %>% dplyr::select(ID = lc_id, lc) %>% as.data.frame() 
  
  ## Add sea and mangrove
  lc[sea_mask == 1] <- 0 ## LC code for water
  if (.mg) lc[mg == 1] <- 6  ## Code for mangroves
  
  ## Test
  # plot(lc, col = lc_param$hex, legend = FALSE, axes = F)
  # legend("bottomleft",
  #        legend = lc_param$lc,
  #        fill = lc_param$hex)

  
  ## Message LC done
  time2 <- Sys.time()
  dt <- round(as.numeric(time2-time1, units = "secs"))
  message(paste0("...Land cover finalized", " - ", dt, " Sec."))
  
  ## Make raster at 30m res
  topo_map <- topo 
  lc_map <- lc
  
  topo <- terra::disagg(topo, fact = 3, method = "near")
  lc   <- terra::disagg(lc, fact = 3, method = "near")
  levels(lc) <- lc_param %>% dplyr::select(ID = lc_id, lc) %>% as.data.frame() 
  
  
  ## Outputs ################################################################
  return(list(param = lc_param, topo = topo, lc = lc, topo_map = topo_map, lc_map = lc_map))
  
} ## End make_topo





