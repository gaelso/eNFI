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
louland_param   <- louland$param

## Save louland_param in data/ and documentation in R/
usethis::use_data(louland_param, overwrite = T)

## Save raster file in inst/extdata/
dir.create("inst", showWarnings = F)
dir.create("inst/extdata", showWarnings = F)
raster::writeRaster(louland_lc90m, "inst/extdata/louland_lc90m.tif", overwrite = T)
#save(louland_lc90m, file = "inst/extdata/louland_lc90m.Rda", compress = "xz")

## Create images and save in tuto-helpers
dir.create("inst/tuto-helpers")
dir.create("inst/tuto-helpers/images", showWarnings = F)
png(filename = "inst/tuto-helpers/images/louland.png", width = 250, height = 250)
make_3d(.newland = louland)
render_snapshot()
dev.off()
render_movie(filename = "inst/tuto-helpers/images/louland.gif")
rgl::rgl.close()

