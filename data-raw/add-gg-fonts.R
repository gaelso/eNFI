
## Download Google fonts for ggplot text and graphs

font_names <- c("Lora", "Shadows Into Light")
font_path <- "inst/fonts"

dir.create(font_path, showWarnings = F)

purrr::walk(font_names, function(x){
  
  ## Download and extract font
  if (!dir.exists(file.path(tempdir(), x))) {
    download.file(
      url = paste0("https://fonts.google.com/download?family=", x), 
      destfile = file.path(tempdir(), paste0(x, ".zip")), 
      mode = "wb"
    )
    unzip(
      zipfile = file.path(tempdir(), paste0(x, ".zip")), 
      exdir = file.path(tempdir(), x)
      )
    unlink(file.path(tempdir(), paste0(x, ".zip")))
  } ## End if download font
  
}) ## End walk

file.rename(file.path(tempdir(), "Lora/static/Lora-Regular.ttf"), file.path(font_path, "Lora-Regular.ttf"))
file.rename(file.path(tempdir(), "Lora/static/Lora-Italic.ttf"), file.path(font_path, "Lora-Italic.ttf"))
file.rename(file.path(tempdir(), "Shadows Into Light/ShadowsIntoLight-Regular.ttf"), file.path(font_path, "ShadowsIntoLight-Regular.ttf"))

unlink(tempdir())
