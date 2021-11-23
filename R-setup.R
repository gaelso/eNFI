
## Interactive training modules on National Forest Inventory data analysis
## Gael Sola, FAO
## October 2021

## Setup package development for lessons
## https://education.rstudio.com/blog/2020/09/delivering-learnr-tutorials-in-a-package/


## Libs
#install.packages(c("devtools", "roxygen2", "learnr"))
library(devtools)
library(usethis)
library(roxygen2)
library(learnr)

## Make package
usethis::create_package("D:/github-repos/eNFI")

## Make lessons
usethis::use_tutorial("eNFI-lesson1", "Overview of the preliminary data", open = interactive())
usethis::use_tutorial("eNFI-lesson2.1", "Simple sampling for carbon - Design", open = interactive())

## Install
devtools::install()

## Launch lesson
learnr::run_tutorial("eNFI-lesson1", "eNFI")

## Create data files
source("R/00-libs.R", local = TRUE)
source("R/01-read-data.R", local = TRUE)

