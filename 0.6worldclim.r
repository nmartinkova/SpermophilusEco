############################################################
# Project: High-resolution SDM and ecological niche model 
#          of European ground squirrel in its ancestral land
#
# Authors (paper):
# Natália Martínková
# Maria Kachamakova
# Jordan Tzvetkov
# Yordan Koshev
#
# Script author: NM
#
# Description:
# Downloads and preprocesses WorldClim bioclimatic variables.
# Crops, resamples, and prepares climatic predictors.
#
# Order in pipeline: setup 6 (environment preparation)
############################################################


for(i in c("geodata", "terra")){
  if(!require(i, character.only = TRUE)){
    install.packages(i, dependencies = TRUE)
    library(i, character.only = TRUE)
  }
}

# create folders for results
if(!dir.exists("Results")) dir.create("Results")
if(!dir.exists("Data/Worldclim")) dir.create("Data/Worldclim")
if(!dir.exists("Results/Worldclim")) dir.create("Results/Worldclim")




# land mask 
land_mask <- rast("Data/landMask.tif")

# uncomment to download the data
# geodata::worldclim_country("BGR", var = "bio", res = .5, path = "../../Data/Worldclim")

# if data has been downloaded previously, use only this line forward
klima = rast("../../Data/Worldclim/BGR_wc2.1_30s_bio.tif")

klima = project(klima, land_mask, method = "bilinear")
klima = mask(klima, land_mask)
 writeRaster(klima, filename = "Data/Worldclim/bioclim.tif", overwrite = T)
 
 png("Results/Worldclim/bioclim.png", width = 560, height = 420)
	plot(klima)
dev.off()