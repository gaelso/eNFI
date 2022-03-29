## create-louland

## Libraries
library(rayshader)
library(rgl)
library(sp)
library(raster)
library(scales)
library(tidyverse)

## Load helper functions
source("data-raw/helper-louland-NLMR.R", local=T)
source("data-raw/helper-louland-3D.R", local=T)
#source("data-raw/create-louland-shp.R", local=T)

louland <- create_newland(.seed = 11, .alt = 2000, .sea = 0.2, .mg = T)

plot(louland$lc_map, col = louland$param$hex)

## Save raster data (ON HOLD - ONLY VECTORS SAVED TO DATA) 
# louland_topo30m <- louland$topo
# louland_topo90m <- louland$topo_map
# louland_lc30m   <- louland$lc
louland_lc90m   <- louland$lc_map
louland_param   <- louland$param %>% 
  left_join(
    tibble(
      lc_id = 0:6, 
      lc_name = c("Water", "Non-forest", "Woodland", "Deciduous", "Mixed-deciduous", "Evergreen", "Mangrove")
      ), 
    by = "lc_id"
    ) %>%
  mutate(lc_name = fct_reorder(lc_name, lc_id)) %>%
  dplyr::select(lc_id, lc, lc_name, everything())

## Save louland_param in inst/extdata/
save(louland_param, file = "inst/extdata/louland_param.Rda", compress = "xz")

## Save raster file in inst/extdata/
raster::writeRaster(louland_lc90m, "inst/extdata/louland_lc90m.tif", overwrite = T)
#save(louland_lc90m, file = "inst/extdata/louland_lc90m.Rda", compress = "xz")

## Create images and save in tuto-helpers
png(filename = "inst/tuto-helpers/images/louland.png", width = 250, height = 250)
make_3d(.newland = louland)
render_snapshot()
dev.off()
render_movie(filename = "inst/tuto-helpers/images/louland.gif")
rgl::rgl.close()

