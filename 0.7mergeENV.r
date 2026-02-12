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
# Merges all environmental predictors into a single raster
# stack. 
#
# Order in pipeline: setup 7 (environment preparation)
############################################################


for (i in c("terra")) {
  if (!require(i, character.only = TRUE)) {
    stop("Run script 0.5setup.r first")
  }
}


# creates one file with all environmental layers
rgeo = rast("Data/rgeo.tif")
rgeo = rgeo[[order(names(rgeo))]]
# removing other
removeGeo = "other"
rgeo = rgeo[[!(names(rgeo) %in% removeGeo)]]
rsoil = rast("Data/rsoil.tif")
# Maria's email 240130
removeSoils = c("Gleysols", "Histosols", "Solonetz", "Alisols", "rock", "water", "Unknown")
rsoil = rsoil[[!(names(rsoil) %in% removeSoils)]]
rsoil = rsoil[[order(names(rsoil))]]
grass = rast("Data/Copernicus/grassland.tif")
names(grass) = "Grassland"
imp = rast("Data/Copernicus/imperviousness.tif")
names(imp) = "Imperviousness"
trees = rast("Data/Copernicus/treeCover.tif")
names(trees) = "Tree cover"
elevation = rast("Data/Copernicus/elevation.tif")
names(elevation) = "Elevation"
dah = rast("Data/Copernicus/DAH.tif")
names(dah) = "Diurnal anisotropic heat"
# aspects in percent
aspects = rast("Data/Copernicus/aspects.tif") * 100
names(aspects) = c("Aspect N", "Aspect E", "Aspect S", "Aspect W")
slopes = rast("Data/Copernicus/slope.tif")
names(slopes) = "Slope"
klima = rast("Data/Worldclim/bioclim.tif")
names(klima) = paste0("bio", formatC(1:19, width = 2, flag = 0))
cropland = rast("Data/Copernicus/Periodically herbaceous.tif")
names(cropland) = "Periodically herbaceous"
water = rast("Data/water.tif")
names(water) = "Water bodies"



env = c(grass, cropland, trees, imp, water, elevation, dah, aspects, slopes, rgeo, rsoil, klima)

writeRaster(env, filename = "Data/env.tif", overwrite = T)

res = 150

png("Results/env.png", res = res, height = 7*res, width = 8*(res+70))
par(mar = c(3,3,2,0)+.2)
plot(env, maxnl = 56, cex.main = .6)
dev.off()