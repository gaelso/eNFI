
## Creating data for the small inventory from first exploration crew

## Libs
library(eNFIrawdata)
library(tidyverse)
library(sf)
library(tmap)

## Load data
load("inst/extdata/louland_lc.Rda")

t1 <- Sys.time()
  
## Take randomly 10 plots
plot_init <- eNFIrawdata::raw_plot %>% 
  dplyr::filter(lu_factor == "Evergreen") %>% 
  dplyr::pull(plot_id)

set.seed(100)
plot_select <- sample(1:length(plot_init), 10)

plot_select <- plot_init[plot_select]

exfi_plot <- eNFIrawdata::raw_plot %>% dplyr::filter(plot_id %in% plot_select)

set.seed(100)
sf_exfi <- st_sample(x = louland_lc %>% filter(id == 405), size = 10) %>% 
  st_as_sf() %>%
  mutate(
    id = 1:10,
    plot_id = exfi_plot$plot_id
    )

t2 <- Sys.time()
print(t2 - t1)

## Pre-calculate AGB per ha from the 10 plots 
plot_radius    <- 20
subplot_radius <- 5

exfi_tree <- eNFIrawdata::raw_tree %>% 
  dplyr::filter(plot_id %in% plot_select) %>%
  left_join(exfi_plot, by = "plot_id") %>%
  left_join(eNFIrawdata::raw_species, by = "sp_id") %>%
  left_join(eNFIrawdata::raw_wdsp, by = "sp_name") %>%
  left_join(eNFIrawdata::raw_wdgn, by = "genus") %>%
  mutate(
    plot_area    = round(if_else(tree_dbh < 20, pi * subplot_radius^2, pi * plot_radius^2) / 10000, 3),
    scale_factor = round(1 / plot_area),
    tree_height_chave  = exp(0.893 - envir_stress + 0.760 * log(tree_dbh) - 0.0340 * (log(tree_dbh))^2),
    tree_height_top = round((tree_height_top + tree_height_chave)/2),
    tree_wd            = case_when(
      !is.na(wd_avg)  ~ wd_avg,
      !is.na(wd_avg2) ~ wd_avg2,
      TRUE ~ 0.57
    ),
    tree_agb = 0.0673 * (tree_wd * tree_dbh^2 * tree_height_top)^0.976 / 10^3,
    tree_ba  = pi * (tree_dbh / 200)^2
  ) %>%
  filter(tree_health <= 2) %>%
  select(plot_id, tree_id, tree_no, tree_dbh, tree_pom, tree_height_top, 
         tree_dist, tree_azimuth, tree_health, sp_name, genus, tree_wd, 
         scale_factor, tree_ba, tree_agb)

usethis::use_data(exfi_tree, overwrite = T)
usethis::use_data(exfi_plot, overwrite = T)
save(sf_exfi, file = "inst/extdata/sf_exfi.Rda", compress = "xz")

rm(plot_init, plot_select)


# exfi_pagb <- exfi_tree %>%
#   group_by(plot_id) %>%
#   summarise(
#     count_tree = sum(scale_factor),
#     plot_ba    = sum(tree_ba * scale_factor),
#     plot_agb   = sum(tree_agb * scale_factor)
#   )
# 
# exfi_agb <- exfi_pagb %>%
#   summarise(
#     n_plot   = n(),
#     n_tree   = mean(count_tree),
#     mean_ba  = mean(plot_ba),
#     sd_ba    = sd(plot_ba),
#     mean_agb = mean(plot_agb),
#     sd_agb   = sd(plot_agb)
#   ) %>%
#   mutate(
#     ci      = sd_agb / sqrt(n_plot) * 1.96,
#     ci_perc = round(ci / mean_agb * 100, 0)
#   )



## Check
# library(tmap)
# tmap_options(check.and.fix = TRUE)
# tmap_mode("view")
# tm_shape(louland_lc) + tm_polygons(col = "lc", palette = louland_param$hex, popup.vars = c("lc", "id"), border.alpha = 0) +
# tm_shape(sf_exfi) + tm_dots(size = 0.1)
