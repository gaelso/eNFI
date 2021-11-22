
## Interactive training modules on National Forest Inventory data analysis - handbook with solutions
## NFI-modules-2021-bookdown
## Gael Sola, FAO
## October 2021


## Raster and shapefile
# library(raster)
# library(stars)
# library(smoothr)
library(sf)
library(tmap)
library(ggspatial)
library(units)

tmap_options(check.and.fix = TRUE)

## Bookdown visualizations


## Tidy data
library(tidyverse)


## Add fonts
library(extrafont)

dir.create("fonts", showWarnings = F)

# ## Load Windows fonts and add Computer modern if missing -- for Windows
# if (Sys.info()['sysname'] == "Windows") {
#   
#   if (!("CMU Serif"  %in% names(windowsFonts()))) {
#     download.file(
#       url = "https://www.fontsquirrel.com/fonts/download/computer-modern", 
#       destfile = "fonts/computer-modern.zip", 
#       mode = "wb"
#     )
#     unzip(zipfile = "fonts/computer-modern.zip", exdir = "fonts/computer-modern")
#     extrafont::font_import(paths = "fonts", recursive = T, pattern = "cmu*", prompt = FALSE)
#     extrafont::loadfonts(device = "win")
#   } ## END IF check font CMU
#   
# } ## END IF check OS


## Add google fonts
font_names <- c("Lora", "Shadows Into Light")

dir.create("fonts", showWarnings = F)

purrr::walk(font_names, function(x){
  
  ## Download and extract font
  if (!dir.exists(file.path("fonts", x))) {
    download.file(
      url = paste0("https://fonts.google.com/download?family=", x), 
      destfile = paste0("fonts/", x, ".zip"), 
      mode = "wb"
    )
    unzip(zipfile = paste0("fonts/", x, ".zip"), exdir = file.path("fonts", x))
    unlink(paste0("fonts/", x, ".zip"))
  } ## End if download font
  
  ## Import fonts to R sysfonts
  if (!(x %in% names(windowsFonts()))) {
    extrafont::font_import(paths = "fonts", recursive = T, pattern = str_remove_all(x, " "), prompt = F)
    extrafont::loadfonts(device = "win")
  } ## End if add to R sysfonts
  
}) ## End walk



## Make font easy to use
library(showtext)
font_add("Lora", "fonts/Lora/static/Lora-Regular.ttf")
font_add("LoraIt", "fonts/Lora/static/Lora-Italic.ttf")
font_add("Shadow", "fonts/Shadows Into Light/ShadowsIntoLight-Regular.ttf")
showtext_auto()





