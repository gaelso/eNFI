

## Solutions lesson 2.1

## Libs
library(tidyverse)
library(sf)
library(units)

## Load data
load("inst/extdata/louland_lc.Rda")
load("inst/extdata/louland_admin.Rda")
load("inst/extdata/louland_param.Rda")
load("data/exfi_tree.Rda")

sf_lc <- louland_lc
sf_admin <- louland_admin
pal <- louland_param$hex

## Fonts for mapping
sysfonts::font_add("Lora", "inst/fonts/lora-v23-latin-italic.ttf")
showtext::showtext_auto()

## Image map with grid 10 km for cover
offset <- st_bbox(sf_lc)[c("xmin", "ymin")] + c(-2000, -2000)

sf_g <- st_make_grid(sf_lc, cellsize = c(10000, 10000), what = "polygons", offset = offset) %>%
  st_intersection(sf_admin)

sf_p <- st_make_grid(sf_lc, cellsize = c(10000, 10000), what = "centers", offset = offset) %>%
  st_intersection(sf_admin) %>%
  st_as_sf() %>%
  st_join(sf_lc) %>%
  mutate(lc_name = fct_reorder(lc_name, lc_id)) %>%
  filter(!is.na(lc_name))

gr_grid10 <- ggplot() +
  geom_sf(data = sf_lc, aes(fill = lc_name), col= NA) +
  scale_fill_manual(values = pal) +
  geom_sf(data = sf_p, aes(fill = lc_name), shape = 21) +
  geom_sf(data = sf_g, fill = NA, col = "red", size = 0.1) +
  geom_sf(data = sf_admin, fill = NA, size = 0.8, color = "black") +
  theme_bw() +
  theme(
    panel.background = element_rect(fill = "#73c2fb"),
    text = element_text(family = "Lora")
  ) +
  labs(fill = "", color = "AGB (ton/ha)") +
  coord_sf(xlim = c(-20.5, -19.5), ylim = c(-0.8, 0.2), expand = FALSE, crs = st_crs(4326)) +
  ggspatial::annotation_scale(
    location = "tr",
    bar_cols = c("grey60", "white"),
    text_family = "Lora"
  ) +
  ggspatial::annotation_north_arrow(
    location = "tr", 
    which_north = "true",
    pad_x = unit(0.2, "in"), 
    pad_y = unit(0.3, "in"),
    style = ggspatial::north_arrow_nautical(
      fill = c("grey40", "white"),
      line_col = "grey20",
      text_family = "Lora"
    )
  )

gr_grid10
ggsave(
  plot = gr_grid10, 
  filename = "inst/tuto-helpers/images/louland-grid10-legend.png", 
  width = 800, height = 600, units = "px", dpi = 72
)
ggsave(
  plot = gr_grid10 + theme(legend.position = "none"),
  filename = "inst/tuto-helpers/images/louland-grid10.png", 
  width = 600, height = 600, units = "px", dpi = 72
)

#rm(gr_grid10)


## Recalculate exfi_agb
exfi_pagb <- exfi_tree %>%
  group_by(plot_id) %>%
  summarise(
    count_tree = sum(scale_factor),
    plot_ba    = sum(tree_ba * scale_factor),
    plot_agb   = sum(tree_agb * scale_factor)
  )

exfi_agb <- exfi_pagb %>%
  summarise(
    n_plot   = n(),
    n_tree   = mean(count_tree),
    mean_ba  = mean(plot_ba),
    sd_ba    = sd(plot_ba),
    mean_agb = mean(plot_agb),
    sd_agb   = sd(plot_agb)
  ) %>%
  mutate(
    ci      = sd_agb / sqrt(n_plot) * 1.96,
    ci_perc = round(ci / mean_agb * 100, 0)
  )

## Check
# exfi_tree %>%
#   ggplot(aes(x = tree_dbh, y  = tree_height_top)) +
#   geom_point()
  


## Number of plots
n05 <- round(((exfi_agb$sd_agb / exfi_agb$mean_agb * 100) * 1.96 / 5)^2)

n10 <- round(((exfi_agb$sd_agb / exfi_agb$mean_agb * 100) * 1.96 / 10)^2)

n15 <- round(((exfi_agb$sd_agb / exfi_agb$mean_agb * 100) * 1.96 / 15)^2)

n20 <- round(((exfi_agb$sd_agb / exfi_agb$mean_agb * 100) * 1.96 / 20)^2)


## Systematic sampling
area_lc <- sf_lc %>%
  mutate(
    area_m2 = st_area(.),
    area_ha = units::set_units(area_m2, value = ha)
  ) %>%
  as_tibble() %>% 
  group_by(lc) %>%
  summarise(area_ha = sum(area_ha))

area_forest <- area_lc %>%
  filter(lc %in% c("EV", "MD", "DD", "MG", "WL")) %>%
  pull(area_ha) %>%
  sum()

area_forest_km2 <- as.numeric(set_units(area_forest, value = km2))

grid_spacing <- round(sqrt(area_forest_km2 / n10), 3)

set.seed(10)
random_x <- sample(500:2000, size = 1)
random_y <- sample(500:2000, size = 1)
offset <- st_bbox(sf_lc)[c("xmin", "ymin")] + c(-random_x, -random_y)

sf_grid5 <- st_make_grid(sf_lc, cellsize = c(5000, 5000), what = "polygons", offset = offset) %>%
  st_intersection(sf_admin) %>%
  st_as_sf()

sf_grid4 <- st_make_grid(sf_lc, cellsize = c(4000, 4000), what = "polygons", offset = offset) %>%
  st_intersection(sf_admin) %>%
  st_as_sf()

## ---

sf_points5 <- st_make_grid(sf_lc, cellsize = c(5000, 5000), what = "centers", offset = offset) %>%
  st_intersection(sf_admin) %>%
  st_as_sf()

sf_points4 <- st_make_grid(sf_lc, cellsize = c(4000, 4000), what = "centers", offset = offset) %>%
  st_intersection(sf_admin) %>%
  st_as_sf()

## ---

sf_plot5 <- sf_points5 %>%
  st_join(sf_lc) %>%
  mutate(lc = fct_reorder(lc, lc_id)) %>%
  filter(!is.na(lc))

sf_plot4 <- sf_points4 %>%
  st_join(sf_lc) %>%
  mutate(lc = fct_reorder(lc, lc_id)) %>%
  filter(!is.na(lc))

## ---

gr_grid5 <- ggplot() +
  geom_sf(data = sf_lc, aes(fill = lc_name), color = NA) +
  geom_sf(data = sf_plot5, aes(fill = lc_name), shape = 21) +
  geom_sf(data = sf_grid5, fill = NA, col = "red", size = 0.1) +
  geom_sf(data = sf_admin, fill= NA) +
  scale_fill_manual(values = pal) +
  labs(fill = "", color = "") +
  theme_void()

gr_grid5

ggsave(
  plot = gr_grid5, 
  filename = "inst/tuto-helpers/images/louland-grid5-legend.png", 
  width = 800, height = 600, units = "px", dpi = 72
)

gr_grid4 <- ggplot() +
  geom_sf(data = sf_lc, aes(fill = lc_name), color = NA) +
  geom_sf(data = sf_plot4, aes(fill = lc_name), shape = 21) +
  geom_sf(data = sf_grid4, fill = NA, col = "red", size = 0.1) +
  geom_sf(data = sf_admin, fill= NA) +
  scale_fill_manual(values = pal) +
  labs(fill = "", color = "") +
  theme_void()

gr_grid4

ggsave(
  plot = gr_grid4,
  filename = "inst/tuto-helpers/images/louland-grid4-legend.png",
  width = 800, height = 600, units = "px", dpi = 72
)

nplot5 <- sf_plot5 %>%
  as_tibble() %>%
  group_by(lc) %>%
  summarise(n = n())

nplot4 <- sf_plot4 %>%
  as_tibble() %>%
  group_by(lc) %>%
  summarise(n = n())

nplot5_total <- nplot5 %>%
  filter(!(lc %in% c("WA", "NF"))) %>%
  summarise(n = sum(n))

nplot4_total <- nplot4 %>%
  filter(!(lc %in% c("WA", "NF"))) %>%
  summarise(n = sum(n))

## Save files in inst/extdata/
save(exfi_pagb, exfi_agb, 
     n05, n10, n15, n20, 
     area_lc, area_forest, area_forest_km2, grid_spacing,
     random_x, random_y, offset, 
     sf_grid5, sf_grid4,
     sf_points5, sf_points4, 
     sf_plot5, sf_plot4, 
     nplot5, nplot4,
     nplot5_total, nplot4_total,
     file = "inst/extdata/solutions-lesson21.Rda")

