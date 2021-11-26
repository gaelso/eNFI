
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
library(eNFIrawdata)

## Make package
usethis::create_package("D:/github-repos/eNFI")

## Make lessons
usethis::use_tutorial("eNFI-lesson1", "Overview of the preliminary data", open = interactive())
usethis::use_tutorial("eNFI-lesson2.1", "Simple sampling for carbon - Design", open = interactive())

## Add dependencies
usethis::use_package("dplyr")
usethis::use_package("ggplot2")
usethis::use_package("tibble")
usethis::use_package("forcats")
usethis::use_package("purrr")
usethis::use_package("sf")
usethis::use_package("tmap")
usethis::use_package("ggspatial")
usethis::use_package("units")
usethis::use_package("learnr")

usethis::use_dev_package("gradethis")
usethis::use_dev_package("eNFIrawdata")

## Create data for the training module
usethis::use_data_raw()



## Install
devtools::install()

## Launch lesson
learnr::run_tutorial("eNFI-lesson1", "eNFI")

## Create data files
source("R/00-libs.R", local = TRUE)
source("R/01-read-data.R", local = TRUE)

