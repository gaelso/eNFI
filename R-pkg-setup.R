
## Interactive training modules on National Forest Inventory data analysis
## Gael Sola, FAO
## October 2021

## Setup package development for lessons
## https://education.rstudio.com/blog/2020/09/delivering-learnr-tutorials-in-a-package/


## Libs
#install.packages(c("devtools", "roxygen2", "learnr"))
#devtools::install_github("gaelso/eNFIrawdata")
library(devtools)
library(usethis)
library(roxygen2)
library(learnr)

## Make package
usethis::create_package("D:/github-repos/eNFI")

## Make lessons
usethis::use_tutorial("eNFI-lesson1", "Overview of the preliminary data", open = interactive())
usethis::use_tutorial("eNFI-lesson2.1", "Simple sampling for carbon - Design", open = interactive())
usethis::use_tutorial("eNFI-lesson2.2", "Simple sampling for carbon - Analysis", open = interactive())
## Add dependencies

## --- Tidyverse
usethis::use_package("dplyr")
usethis::use_package("ggplot2")
usethis::use_package("tibble")
usethis::use_package("forcats")
usethis::use_package("purrr")
usethis::use_package("tidyverse", type = "depends")

## --- Geospatial
usethis::use_package("sf")
usethis::use_package("tmap")
usethis::use_package("units")

## --- Tutos
usethis::use_package("learnr")
usethis::use_dev_package("gradethis")
usethis::use_dev_package("eNFIrawdata")
usethis::use_package("ggspatial")
usethis::use_package("sysfonts")
usethis::use_package("showtext")


## RAW DATA 
## --- Created by R scripts in data-raw/
## --- Data stored in inst/extdata/
## --- called with system.file()
## --- See: https://r-pkgs.org/data.html#data
## PACKAGE DATA
## --- Created by R-script in data-raw/
## --- Documentation created in R/
## --- Data stored in data/

## Create raw data template
usethis::use_data_raw()

## Create inst subfolders
dir.create("inst", showWarnings = F)
dir.create("inst/extdata", showWarnings = F)
dir.create("inst/tuto-helpers", showWarnings = F)
dir.create("inst/tuto-helpers/images", showWarnings = F)


## --- Create Louland spatial data

## Create inst/extdata/louland_lc90m.tif 
## Create data/louland_param.Rda and R/louland_param.R
source("data-raw/create-louland.R", local = TRUE)

## Create inst/extdata/louland_lc.Rda
## Create inst/extdata/louland_admin.Rda
## Create inst/tuto-helpers/images/louland-map.png
## Create inst/tuto-helpers/images/louland-map-nolegend.png
source("data-raw/create-louland-shp.R", local = TRUE)


## --- Create exploratory crew forest inventory data

## Create data/exfi_plot.Rda and data/exfi_plot.R
## Create data/exfi_tree.Rda and data/exfi_tree.R
## Create inst/extdata/sf_exfi.Rda
source("data-raw/create-exfi.R", local = TRUE)


## Create solutions for Lesson 1
source("data-raw/solutions-lesson1.R", local = TRUE)

## Copy images from tuto-helpers to tutos
images <- list.files("inst/tuto-helpers/images", full.names = T)
images

file.copy(images, "inst/tutorials/eNFI-lesson1/images")



## Create Solutions for Lesson 1
source("data-raw/lesson1-sol.R", local = TRUE)




## Check
devtools::check()

## Convert Roxygen data and function description to .Rd files in man/
devtools::document()

## Install
devtools::install()

## Launch lesson
learnr::run_tutorial("eNFI-lesson1", "eNFI")

