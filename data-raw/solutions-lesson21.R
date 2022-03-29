

## Solutions lesson 2.1

## Libs
library(tidyverse)
library(sf)

## Load data
load("inst/extdata/louland_lc.Rda")
load("data/exfi_tree.Rda")


offset <- st_bbox(sf_lc)[c("xmin", "ymin")] + c(-1000, -1000)

sf_g <- st_make_grid(sf_lc, cellsize = c(10000, 10000), what = "polygons", offset = offset) %>%
  st_intersection(sf_admin)

sf_p <- st_make_grid(sf_lc, cellsize = c(10000, 10000), what = "centers", offset = offset) %>%
  st_intersection(sf_admin) %>%
  st_as_sf() %>%
  st_join(sf_lc) %>%
  mutate(lc = fct_reorder(lc, lc_id)) %>%
  filter(!is.na(lc))

gr_grid10 <- ggplot() +
  geom_sf(data = sf_lc, aes(fill = lc), col= NA) +
  scale_fill_manual(values = pal) +
  geom_sf(data = sf_p, aes(fill = lc), shape = 21) +
  geom_sf(data = sf_g, fill = NA, col = "red", size = 0.1) +
  geom_sf(data = sf_admin, fill = NA, size = 0.6, color = "black") +
  theme_bw() +
  theme(
    panel.background = element_rect(fill = "#73c2fb"),
    text = element_text(family = "LoraIt"),
    legend.position = "none"
  ) +
  labs(fill = "", color = "AGB (ton/ha)") +
  coord_sf(xlim = c(-20.5, -19.5), ylim = c(-0.8, 0.2), expand = FALSE, crs = st_crs(4326)) +
  ggspatial::annotation_scale(
    location = "tr",
    bar_cols = c("grey60", "white"),
    text_family = "LoraIt"
  ) +
  ggspatial::annotation_north_arrow(
    location = "tr", 
    which_north = "true",
    pad_x = unit(0.2, "in"), 
    pad_y = unit(0.3, "in"),
    style = ggspatial::north_arrow_nautical(
      fill = c("grey40", "white"),
      line_col = "grey20",
      text_family = "LoraIt"
    )
  )

gr_grid10
ggsave(plot = gr_grid10, filename = "data/louland/lc-grid10-image.png", width = 15, height = 15, dpi = 100, units = "cm")
rm(gr_grid10)