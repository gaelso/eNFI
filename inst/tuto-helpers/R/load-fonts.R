

## Load fonts for ggplot annotation

if (!require(sysfonts)) stop("package 'sysfonts' missing, it is required in 'tutorials/R/load-fonts.R'")
if (!require(showtext)) stop("package 'showtext' missing, it is required in 'tutorials/R/load-fonts.R'")

sysfonts::font_add("Lora", system.file("fonts/lora-v23-latin-italic.ttf", package = "eNFI", mustWork = T))
sysfonts::font_add("Shadow", system.file("fonts/shadows-into-light-v14-latin-regular.ttf", package = "eNFI", mustWork = T))
showtext::showtext_auto()