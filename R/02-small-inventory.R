
## Interactive training modules on National Forest Inventory data analysis - handbook with solutions
## NFI-modules-2021-bookdown
## Gael Sola, FAO
## October 2021


## Select 10 plots for initial carbon stock

table(plot$lu_factor)

plot_init <- plot %>% filter(lu_factor == "Evergreen") %>% pull(plot_id)

set.seed(100)
plot_select <- sample(1:length(plot_init), 10)

plot_select <- plot_init[plot_select]

exfi_plot <- plot %>% filter(plot_id %in% plot_select)


## Plot and subplot size
plot_radius    <- 20
subplot_radius <- 5

## Filter trees and calc agb
exfi_tree <- tree %>% filter(plot_id %in% plot_select)

exfi_tagb<- exfi_tree %>%
  left_join(exfi_plot, by = "plot_id") %>%
  left_join(species_list, by = "sp_id") %>%
  left_join(wd_species, by = "sp_name") %>%
  left_join(wd_genus, by = "genus") %>%
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

# gr_h <- fi_tagb %>% 
#   ggplot(aes(x = tree_dbh)) +
#   geom_point(aes(y = tree_height_top), shape = 1, size = 2) +
#   geom_point(aes(y = tree_height_cor), col = "darkred", shape = 3, size = 2) +
#   facet_wrap(~plot_id) +
#   theme_bw()
# print(gr_h)
# 
# gr_tagb <- fi_tagb %>% 
#   ggplot(aes(x = tree_dbh, y = tree_agb, fill = plot_id)) +
#   scale_fill_viridis_d(direction = -1) +
#   geom_point(pch = 21, alpha = 0.5, size = 2) +
#   facet_wrap(~ plot_id) +
#   theme_bw()
# print(gr_tagb)

exfi_pagb <- exfi_tagb %>%
  group_by(plot_id) %>%
  summarise(
    count_tree = sum(scale_factor),
    plot_ba    = sum(tree_ba * scale_factor),
    plot_agb   = sum(tree_agb * scale_factor)
  )

# gr_pagb <- fi_pagb %>%
#   ggplot(aes(x = plot_ba, y = plot_agb)) +
#   geom_point(aes(color = plot_id), size = 3) +
#   theme_bw()
# print(gr_pagb)  

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

## FI plot location
set.seed(100)
sf_exfi <- st_sample(x = sf_lc1 %>% filter(id == 406), size = 10) %>% 
  st_as_sf() %>%
  mutate(id = 1:10) %>%
  bind_cols(exfi_pagb)

# tmap_mode("view")
# tm_shape(sf_lc1) + tm_polygons(col = "lc", palette = palette1, popup.vars = c("lc", "id"), border.alpha = 0) +
# tm_shape(sf_exfi) + tm_dots(col = "plot_agb", size = 0.1)
