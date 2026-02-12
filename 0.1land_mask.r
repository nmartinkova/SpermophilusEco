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
# Creates land mask for study area. Removes non-terrestrial
# areas and harmonizes spatial extent and resolution.
#
# Order in pipeline: setup 1 (environment preparation)
############################################################


for(i in c("terra", "sf", "rnaturalearth")){
  if(!require(i, character.only = TRUE)){
    install.packages(i, dependencies = TRUE)
    library(i, character.only = TRUE)
  }
}


if(!dir.exists("Data")) dir.create("Data")
if(!dir.exists("Results")) dir.create("Results")

# Bulgarian border = Kachamakova240912
bg = read_sf("../../Data/Kachamakova240912/bgr_adm_unicef_20221012_shp/bgr_admbnda_adm0_unicef_20221012.shp")
bg$value = 1
bg = vect(bg["value"])
bg1 = rast(bg, res = 0.0001078567)
bg2 = rasterize(bg, bg1)

writeRaster(bg2, filename = "Data/landMask.tif", overwrite = TRUE)


# Water layer
water = st_read("../../Data/Kachamakova240912/Water_BG_PhBlocks_2023_corrected/Water_BG_PhBlocks_2023_corrected.shp")
water$value = 1
water = st_transform(water, crs = 4326)
water = vect(water["value"])
water = rasterize(water, bg2, background = 0)

writeRaster(water, filename = "Data/water.tif", overwrite = T)
 
png("Results/water.png", width = 560, height = 420)
	plot(water)
dev.off()
