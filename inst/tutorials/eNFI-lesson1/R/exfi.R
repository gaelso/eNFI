
## Creating data for the small inventory from first exploration crew

## Load raw data 
# library(eNFIrawdata)
# library(dplyr)
# library(sf)
# 
# load("data/louland_lc.Rda")
# load("data/louland_param.Rda")

t1 <- Sys.time()
  
## Take randomly 10 plots
plot_init <- eNFIrawdata::raw_plot %>% 
  dplyr::filter(lu_factor == "Evergreen") %>% 
  dplyr::pull(plot_id)

set.seed(100)
plot_select <- sample(1:length(plot_init), 10)

plot_select <- plot_init[plot_select]

exfi_plot <- eNFIrawdata::raw_plot %>% dplyr::filter(plot_id %in% plot_select)
exfi_tree <- eNFIrawdata::raw_tree %>% dplyr::filter(plot_id %in% plot_select)

set.seed(100)
sf_exfi <- st_sample(x = louland_lc %>% filter(id == 405), size = 10) %>% 
  st_as_sf() %>%
  mutate(
    id = 1:10,
    plot_id = exfi_plot$plot_id
    )

rm(plot_init, plot_select)

t2 <- Sys.time()
print(t2 - t1)

## Pre-calculate AGB per ha from the 10 plots 
plot_radius    <- 20
subplot_radius <- 5

exfi_tagb <- exfi_tree %>%
  left_join(exfi_plot, by = "plot_id") %>%
  left_join(eNFIrawdata::raw_species, by = "sp_id") %>%
  left_join(eNFIrawdata::raw_wdsp, by = "sp_name") %>%
  left_join(eNFIrawdata::raw_wdgn, by = "genus") %>%
  mutate(
    plot_area    = round(if_else(tree_dbh < 20, pi * subplot_radius^2, pi * plot_radius^2) / 10000, 3),
    scale_factor = round(1 / plot_area),
    tree_height_chave  = exp(0.893 - envir_stress + 0.760 * log(tree_dbh) - 0.0340 * (log(tree_dbh))^2),
    tree_height_ci     = 0.243 * tree_height_chave * 1.96,
    tree_height_valid  = if_else(abs(tree_height_chave - tree_height_top) < tree_height_ci, 1, 0),
    tree_height_cor    = if_else(tree_height_valid != 1 | is.na(tree_height_top), tree_height_chave, tree_height_top),
    tree_height_origin = if_else(tree_height_valid != 1 | is.na(tree_height_top), "model", "data"),
    tree_wd            = case_when(
      !is.na(wd_avg)  ~ wd_avg,
      !is.na(wd_avg2) ~ wd_avg2,
      TRUE ~ 0.57
    ),
    wd_level = case_when(
      !is.na(wd_avg)  ~ "species",
      !is.na(wd_avg2) ~ "genus",
      TRUE ~ "global avg"
    ),
    tree_agb = 0.0673 * (tree_wd * tree_dbh^2 * tree_height_cor)^0.976 / 10^3,
    tree_ba  = pi * (tree_dbh / 200)^2
  ) %>%
  filter(tree_health <= 2)

exfi_pagb <- exfi_tagb %>%
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
# library(tmap)
# tmap_options(check.and.fix = TRUE)
# tmap_mode("view")
# tm_shape(louland_lc) + tm_polygons(col = "lc", palette = louland_param$hex, popup.vars = c("lc", "id"), border.alpha = 0) +
# tm_shape(sf_exfi) + tm_dots(size = 0.1)
