
## Creating Louland land cover and admin vectors

library(raster)
library(stars)
library(sf)
library(smoothr)
library(tidyverse)

## Data preparation
#louland_lc90m <- stars::read_stars(system.file("extdata/louland_lc90m.tif", package = "eNFI", mustWork = T))
louland_lc90m <- stars::read_stars("inst/extdata/louland_lc90m.tif")
load("inst/extdata/louland_param.rda")

plot(louland_lc90m)

## Fonts for mapping
sysfonts::font_add("Lora", "inst/fonts/lora-v23-latin-italic.ttf")
showtext::showtext_auto()



## Create shapefiles
t1 <- Sys.time()
sf_lc <- louland_lc90m %>%
  sf::st_as_sf(., as_points = FALSE, merge = TRUE) %>%
  sf::st_set_crs(st_crs(32727)) %>%
  dplyr::rename(lc = louland_lc90m.tif) %>%
  dplyr::left_join(louland_param %>% dplyr::select(lc_id, lc, lc_name), by = "lc") %>%
  dplyr::mutate(
    id = 1:nrow(.),
    lc = forcats::fct_reorder(lc, lc_id)
  ) %>%
  #sf::st_cast("MULTIPOLYGON") %>%
  sf::st_make_valid() %>%
  dplyr::filter(lc != "WA" | id == 145)

bkp_warn <- getOption("warn")
options(warn = -1)

sf_lc2 <- sf_lc %>%
  smoothr::smooth(method = "ksmooth", smoothness = 2.2) %>%
  dplyr::mutate(id = 1:nrow(.)) %>%
  st_make_valid() %>%
  st_cast("POLYGON")

options(warn = bkp_warn)

t2 <- Sys.time()
print(t2 - t1)

louland_admin <- sf_lc2 %>%
  sf::st_buffer(100) %>%
  sf::st_union(by_feature = FALSE) %>%
  sf::st_as_sf()

louland_lc <- sf_lc2

save(louland_lc, file = "inst/extdata/louland_lc.Rda", compress = "xz")
save(louland_admin, file = "inst/extdata/louland_admin.Rda", compress = "xz")

#rm(sf_lc, sf_lc2)

## Create maps
sf_lc <- louland_lc
sf_admin <- louland_admin
pal <- louland_param$hex
#nb_ft <- 4


gr_map <- ggplot() +
  geom_sf(data = sf_lc, aes(fill = lc_name), col= NA) +
  scale_fill_manual(values = pal) +
  geom_sf(data = sf_admin, fill = NA, size = 1, color = "black") +
  theme_bw() +
  theme(
    panel.background = element_rect(fill = "#73c2fb"),
    text = element_text(family = "Lora", face = "italic", size = 16),
  ) +
  labs(fill = "") +
  coord_sf(xlim = c(-20.5, -19.5), ylim = c(-0.8, 0.2), expand = FALSE, crs = st_crs(4326)) +
  ggspatial::annotation_scale(
    location = "tr",
    bar_cols = c("grey60", "white"),
    text_family = "Lora",
    text_face = "italic"
  ) +
  ggspatial::annotation_north_arrow(
    location = "tr", 
    which_north = "true",
    pad_x = unit(0.2, "in"), 
    pad_y = unit(0.3, "in"),
    style = ggspatial::north_arrow_nautical(
      fill = c("grey40", "white"),
      line_col = "grey20",
      text_family = "Lora",
      text_face = "italic"
    )
  )
gr_map 

## Save maps to inst/tuto-helpers/images
ggsave(
  plot = gr_map, 
  filename = "inst/tuto-helpers/images/louland-map.png", 
  width = 800, height = 600, units = "px", dpi = 72
  )
ggsave(
  plot = gr_map + theme(legend.position = "none"),
  filename = "inst/tuto-helpers/images/louland-img.png", 
  width = 600, height = 600, units = "px", dpi = 72
  )

