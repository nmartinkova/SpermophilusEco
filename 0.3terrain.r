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
# Derives terrain variables (elevation-derived predictors),
# and exports rasters for environmental predictor stack.
#
# Order in pipeline: setup 3 (environment preparation)
############################################################

for(i in c("terra")){
  if(!require(i, character.only = TRUE)){
    install.packages(i, dependencies = TRUE)
    library(i, character.only = TRUE)
  }
}


if(!dir.exists("Results")) dir.create("Results")
if(!dir.exists("Results/Copernicus")) dir.create("Results/Copernicus")
if(!dir.exists("Data/Copernicus")) dir.create("Data/Copernicus")


paleta = "Pastel 1"
farby = hcl.colors(2, paleta)




land_mask = rast("Data/landMask.tif")

# Elevation layer
bg = rast("../../Data/Copernicus/DEM_COP30.tif")

 bg = project(bg, land_mask, method = "bilinear")
 bg = mask(bg, land_mask)
 writeRaster(bg, filename = "Data/Copernicus/elevation.tif", overwrite = T)

png("Results/Copernicus/elevation.png", width = 560, height = 420)
	plot(bg)
dev.off()


# Slope and aspect layers
svah = terrain(bg, v = "slope", filename = "Data/Copernicus/slope.tif", overwrite = T)
png("Results/Copernicus/slope.png", width = 560, height = 420)
	plot(svah)
dev.off()

sklon = terrain(bg, v = "aspect", filename = "Data/Copernicus/aspect.tif", overwrite = T)
png("Results/Copernicus/aspect.png", width = 560, height = 420)
	plot(sklon)
dev.off()

