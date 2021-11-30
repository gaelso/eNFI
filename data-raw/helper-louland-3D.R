## Function for developing 3D visualizations for outputs of create_newland()
## Considering moving the function to the package but keeping it out for now


## For testing
# .newland = create_newland(.seed = 11, .alt = 2000, .sea = 0.2, .mg = T)
##

## Function
#' 3D visualization for outputs of create_newland()
#'
#' @description 
#' TBD. Based on the package `rayshader`. 
#' 
#' @param .newland output of the function `create_newland()`.
#' @param .width width of the visualization in px.
#' @param .height height of the visualization in px.
#'
#' @return
#' TBD a rayshader object that can be saved as image or gif/movie.
#' 
#' @examples
#' ## Create a new land
#' tt <- create_newland(.seed = NULL, .alt = 2000, .sea = 0.1, .mg = TRUE)
#' 
#' ## Create visualization
#' ## --- Create image
#' png(filename ="<path_to_file>.png", width = 250, height = 250)
#' make_3d(.country = tt, .width = 250, .height = 250)
#' rayshader::render_snapshot()
#' dev.off()
#' 
#' ## --- Create video
#' rayshader::render_movie(filename = paste0("results/louland/newland.gif"))
#' rgl::rgl.close()
#' 
#' @export
make_3d <- function(.newland, .width = 250, .height = 250){
  
  topo <- .newland$topo_map
  lc   <- .newland$lc_map 
  
  lc_param <- .newland$param %>% 
    dplyr::bind_cols(tibble::as_tibble(t(col2rgb(.$hex)), .name_repair = ~c("r", "g", "b")))
  
  rr <- tibble::tibble(id = as.vector(raster::flip(lc))) %>%
    dplyr::left_join(lc_param %>% dplyr::select(id = lc_id, r), by = "id") %>%
    dplyr::pull(r) %>%
    matrix(., ncol = ncol(lc))
  
  gg <- tibble::tibble(id = as.vector(raster::flip(lc))) %>%
    dplyr::left_join(lc_param %>% dplyr::select(id = lc_id, g), by = "id") %>%
    dplyr::pull(g) %>%
    matrix(., ncol = ncol(lc))
  
  bb <- tibble::tibble(id = as.vector(raster::flip(lc))) %>%
    dplyr::left_join(lc_param %>% dplyr::select(id = lc_id, b), by = "id") %>%
    dplyr::pull(b) %>%
    matrix(., ncol = ncol(lc))
  
  rgb_array <- array(0, dim = c(nrow(.newland$lc_map), ncol(.newland$lc_map), 3))
  rgb_array[,,1] <- rr/255
  rgb_array[,,2] <- gg/255
  rgb_array[,,3] <- bb/255
  rgb_array <- aperm(rgb_array, c(1,2,3))
  
  ray    <- raster::as.matrix(raster::flip(topo))
  #shadow <- ray_shade(ray, zscale=1, lambert=FALSE)
  #amb    <- ambient_shade(ray, zscale=1, sunbreaks = 15, maxsearch = 100)
  
  ## Close opened rgl device
  if (length(rgl::rgl.dev.list()) != 0) rgl::rgl.close() 
  
  t1 <- Sys.time()
  ray %>%
    rayshader::sphere_shade(texture = "imhof1") %>%
    #rayshader::add_water(detect_water(ray, min_area = 100)) %>%
    rayshader::add_overlay(rgb_array) %>%
    #rayshader::add_shadow(ray_shade(ray, zscale=1, lambert=FALSE), 0.7) %>%
    #rayshader::add_shadow(ambient_shade(ray, zscale=1, sunbreaks = 15, maxsearch = 100)) %>%
    rayshader::add_shadow(rayshader::lamb_shade(ray)) %>%
    # rayshader::plot_3d(
    #   ray,
    #   zscale=10, fov=0, theta=-45, phi=45, windowsize=c(.width, .height), zoom=0.8,
    #   water=TRUE, wateralpha = 0.8, watercolor = "#73c2fb", waterlinecolor = "white",
    #   waterlinealpha = 0.3, solid = FALSE
    # )
    rayshader::plot_3d(
      ray,
      zscale=10, fov=0, theta=-45, phi=45, windowsize=c(.width, .height), zoom=0.8,
      water=TRUE, wateralpha = 0.8, watercolor = "#73c2fb", waterlinecolor = "white",
      waterlinealpha = 0.3, solid = FALSE
    )
  
  t2 <- Sys.time()
  dt    <- round(as.numeric(t2-t1, units = "secs"))
  message(paste0("Made 3D render of the new land in ", dt, " sec."))
  message(" ")
  
} ## End make_3d



