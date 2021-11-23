
## Interactive training modules on National Forest Inventory data analysis - handbook with solutions
## NFI-modules-2021-bookdown
## Gael Sola, FAO
## October 2021



##
## Read NFI data ############################################################
##

#list.files(file.path(path_proj, "data/mock-data"))

mock_plot <- read_csv("data/mock-data/mock_plot.csv", show_col_types = F)
mock_tree <- read_csv("data/mock-data/mock_tree.csv", show_col_types = F)

mock_species <- read_csv("data/mock-data/mock_species.csv", show_col_types = F)

mock_wdsp <- read_csv("data/mock-data/mock_wdsp.csv", show_col_types = F)
mock_wdgn <- read_csv("data/mock-data/mock_wdgn.csv", show_col_types = F)

usethis::use_data(mock_plot, mock_tree, mock_species, mock_wdsp, mock_wdgn, overwrite = T)

##
## Read spatial data ########################################################
##

## --- Louland --------------------------------------------------------------

rs_path <- file.path(path_proj, "data/louland") 

## Recall land features
nb_ft <- 4
mg    <- T
alt   <- 2000
sea   <-  0.2

## Recall land cover parameters
param1 <- tibble(
  id_lc = c(   5,    4,    3,    2),
  lc    = c("EV", "MD", "DD", "PL"),
  w     = c(0.11, 0.23, 0.08, 0.21)
  ) %>%
  bind_rows(list(id_lc = 1, lc = "NF", w = 1 - sum(.$w))) %>%
  mutate(hex = c("#00743f", "#379683", "#5cdb95", "#ffcb9a", "#edf5e1")) %>% 
  bind_rows(list(id_lc = c(0, 6), lc = c("WA", "MG"), w = c(0, 0), hex = c("#73c2fb", "#012172"))) %>%
  arrange(id_lc)

# ## Load raster
# tmp <- list.files(rs_path, pattern = ".tif", full.names = T)
# tmp2 <- list.files(rs_path, pattern = ".tif.aux", full.names = T)
# tmp <- setdiff(tmp, tmp2)
# 
# louland <- map(tmp, function(x){
#   read_stars(x)
# })
# names(louland) <- tmp %>% str_remove(".tif") %>% str_remove(".*/")

## Load Shafiles
sf_adm1<- st_read(file.path(rs_path, "adm/adm.shp"), crs = st_crs(32727))

sf_lc1 <- st_read(file.path(rs_path, "lc/lc.shp"), crs = st_crs(32727)) %>%
  mutate(lc = forcats::fct_reorder(lc, lc_id))

sf_topo1 <- st_read(file.path(rs_path, "topo/topo.shp"), crs = st_crs(32727))

## Check
palette1 <- param1$hex

gr_lc <- ggplot() +
  geom_sf(data = sf_lc1, aes(fill = lc), col = NA) +
  geom_sf(data = sf_topo1, fill = NA, size = 0.2) +
  scale_fill_manual(values = palette1) +
  theme_void() +
  labs(fill = "")
print(gr_lc)

# tmap_mode("view")
# tmap_options(check.and.fix = TRUE)
# tm_shape(sf_lc1) + tm_polygons(col = "lc", palette = palette1, popup.vars = c("lc", "id"))

