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
# Imports and processes Copernicus land cover data.
# Selects layers and aligns to modelling resolution.
#
# Order in pipeline: setup 5 (environment preparation)
############################################################


for(i in c("terra", "sf")){
  if(!require(i, character.only = TRUE)){
    install.packages(i, dependencies = TRUE)
    library(i, character.only = TRUE)
  }
}


if(!dir.exists("Results")) dir.create("Results")

paleta = "Pastel 1"
farby = hcl.colors(2, paleta)


land_mask = rast("Data/landMask.tif")


# joins mosaic of tiles from the high-res Copernicus data
# needs to be uncommented one variable at the time
# adresar is a path to the directory with tile rasters

# https://rspatial.github.io/terra/reference/mosaic.html

# adresar = "../../Data/Copernicus/TCD_2018_010m_bg_03035_v020/DATA"
# adresar = "../../Data/Copernicus/GRA_2018_010m_bg_03035_v010/DATA"
#CLC
 adresar = "../../Data/Copernicus/IMD_2018_010m_bg_03035_v020/DATA"
# adresar = "../../Data/Copernicus/WAW_2018_010m_bg_03035_v020/DATA"

# subory = dir(adresar, full.names = T)
# subory = subory[!grepl("tfw|vat", subory)]
# 
# 
# for(i in 1:length(subory)){
# 	assign(paste0("b",i), rast(subory[i])) 
# }
# 
# bg = mosaic(b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,
# 			b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,
# 			b21, filename = "Data/IMD_2018_010m_bg_03035_v020.tif")
#

# https://land.copernicus.eu/en/products/high-resolution-layer-grassland/grassland-change-2015-2018#download
# gra = rast("Data/GRA_2018_010m_bg_03035_v010.tif")
# gra = project(gra, land_mask, method = "near")
# gra = mask(gra, land_mask)
# writeRaster(gra, filename = "Data/Copernicus/grassland.tif", overwrite = T)
# png("Results/grassland.png", width = 560, height = 420)
# 	plot(gra)
# dev.off()
# 
# 
# imp = rast("Data/IMD_2018_010m_bg_03035_v020.tif")
# imp = project(imp, land_mask, method = "bilinear")
# imp = mask(imp, land_mask)
# writeRaster(imp, filename = "Data/Copernicus/imperviousness.tif", overwrite = T)
# png("Results/imperviousness.png", width = 560, height = 420)
# 	plot(imp)
# dev.off()
# 
 
# tcd = rast("Data/TCD_2018_010m_bg_03035_v020.tif")
# tcd = project(tcd, land_mask, method = "bilinear")
# tcd = mask(tcd, land_mask)
# writeRaster(tcd, filename = "Data/Copernicus/treeCover.tif", overwrite = T)
# png("Results/treeCover.png", width = 560, height = 420)
# 	plot(tcd)
# dev.off()


#  waw = rast("Data/WAW_2018_010m_bg_03035_v020.tif")
#  waw = project(waw, land_mask, method = "near")
#  waw = mask(waw, land_mask)
#  writeRaster(waw, filename = "Data/Copernicus/water.tif", overwrite = T)
#  png("Results/water.png", width = 560, height = 420)
#  plot(waw)
#  dev.off()


# splits Corine Land Covers into separate variables
 clc = rast("../../Data/Copernicus/clcResults/CLMS_CLCplus_RASTER_2018_010m_eu_03035_V1_1/Data/CLMS_CLCplus_RASTER_2018_010m_eu_03035_V1_1.tif")
 clc = project(clc, land_mask, method = "near")
 clc = mask(clc, land_mask)
 writeRaster(clc, filename = "Data/Copernicus/CLC.tif", overwrite = T)
 	png(paste0("Results/CLC.png"), height = 420, width = 560)
 		plot(clc)
 	dev.off()
# 
# 
# clcnames = c("Sealed", "needle leaved trees", "Broadleaved deciduous trees", 
# 	"Broadleaved evergreen trees", "shrubs", "Permanent herbaceous", "Periodically herbaceous",
# 	"Lichens and mosses", "sparsely-vegetated", "Water", "Snow and ice")
clcnames = "Periodically herbaceous"
# 
 # https://stackoverflow.com/a/77899411/5967807
 for(i in clcnames){
 	ktore = cats(clc)[[1]]$Value[which(grepl(i, cats(clc)[[1]]$Class_name))]
 	temp = app(clc, fun = \(x) x %in% ktore)
 	temp = mask(temp, land_mask)
 	writeRaster(temp, filename = paste0("Data/CLC/", i, ".tif"), overwrite = TRUE)
 	png(paste0("Results/Copernicus/", i, ".png"), height = 420, width = 560)
 		plot(temp)
 	dev.off()
 }
