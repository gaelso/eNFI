
## Creating Louland land cover and admin vectors

library(stars)
library(sf)
library(smoothr)
library(tidyverse)
library(eNFIrawdata)

## Data preparation
louland_lc90m <- stars::read_stars(system.file("extdata/louland_lc90m.tif", package = "eNFIrawdata", mustWork = T))

## Create shapefiles
t1 <- Sys.time()
sf_lc <- louland_lc90m %>%
  sf::st_as_sf(., as_points = FALSE, merge = TRUE) %>%
  sf::st_set_crs(st_crs(32727)) %>%
  dplyr::rename(lc = louland_lc90m.tif) %>%
  dplyr::left_join(louland_param %>% dplyr::select(lc_id, lc), by = "lc") %>%
  dplyr::mutate(
    id = 1:nrow(.),
    lc = forcats::fct_reorder(lc, lc_id)
  ) %>%
  #sf::st_cast("MULTIPOLYGON") %>%
  sf::st_make_valid() %>%
  dplyr::filter(lc != "WA" | id == 145)

bkp_warn <- getOption("warn")
options(warn = -1)

louland_lc <- sf_lc %>%
  smoothr::smooth(method = "ksmooth", smoothness = 2.2) %>%
  dplyr::mutate(id = 1:nrow(.)) %>%
  st_make_valid() %>%
  st_cast("POLYGON")

options(warn = bkp_warn)

t2 <- Sys.time()
print(t2 - t1)

rm(sf_lc)

louland_admin <- louland_lc %>%
  sf::st_buffer(100) %>%
  sf::st_union(by_feature = FALSE) %>%
  sf::st_as_sf()

save(louland_lc, file = "inst/extdata/louland_lc.Rda", compress = "xz")
save(louland_admin, file = "inst/extdata/louland_admin.Rda", compress = "xz")

