
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

## --- geospatial
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

## Create raw data template
usethis::use_data_raw()

## Create Louland spatial data
source("data-raw/create-louland.R", local = TRUE)
source("data-raw/create-louland-shp.R", local = TRUE)

## Create exfi data
source("data-raw/create-exfi.R", local = TRUE)

## Check
devtools::check()

## Convert Roxygen data and function description to .Rd files in man/
devtools::document()

## Install
devtools::install()

## Launch lesson
learnr::run_tutorial("eNFI-lesson1", "eNFI")

