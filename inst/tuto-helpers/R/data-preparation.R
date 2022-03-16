
## Prepare data

## Load data
load(system.file("extdata/louland_lc.Rda", package = "eNFI"))
load(system.file("extdata/louland_admin.Rda", package = "eNFI"))
load(system.file("extdata/sf_exfi.Rda", package = "eNFI"))


## fixed profile - more profiles to be implemented in V2.0
newland_name <- "Louland"

sf_lc <- louland_lc %>%
  left_join(tibble(lc_id = 0:6, lc_name = c("Water", "Non-forest", "Woodland", "Deciduous", "Mixed-deciduous", "Evergreen", "Mangrove")), by = "lc_id") %>%
  mutate(lc_name = fct_reorder(lc_name, lc_id))
sf_admin <- louland_admin
pal <- louland_param$hex
nb_ft <- 4

## Exercises corrections
exfi_pagb <- exfi_tree %>%
  group_by(plot_id) %>%
  summarise(
    count_tree = sum(scale_factor),
    plot_ba    = sum(tree_ba * scale_factor),
    plot_agb   = sum(tree_agb * scale_factor)
  )

exfi_agb2 <- exfi_agb <- exfi_pagb %>%
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

area_lc <- sf_lc %>%
  mutate(
    area_m2 = st_area(.),
    area_ha = units::set_units(area_m2, value = ha)
  ) %>%
  as_tibble() %>% 
  group_by(lc) %>%
  summarise(area_ha = sum(area_ha))

area_tot <- sf_lc %>%
  mutate(
    area_m2 = st_area(.),
    area_ha = units::set_units(area_m2, value = ha)
  ) %>%
  as_tibble() %>% 
  summarise(area_ha = sum(area_ha))