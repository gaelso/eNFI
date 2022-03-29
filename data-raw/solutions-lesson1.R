
## Solutions lesson 1

## Libs
library(tidyverse)
library(sf)

## Load data
load("inst/extdata/louland_lc.Rda")
load("data/exfi_tree.Rda")

sf_lc <- louland_lc

## Solutions
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

## Save files in inst/extdata/
save(exfi_pagb, exfi_agb, exfi_agb2, area_lc, area_tot, file = "inst/extdata/solutions-lesson1.Rda")
