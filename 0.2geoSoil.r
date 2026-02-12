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
# Processes geological and soil variables. Crops, aligns,
# and exports rasters for environmental predictor stack.
#
# Order in pipeline: setup 2 (environment preparation)
############################################################



for(i in c("sf", "terra")){
  if(!require(i, character.only = TRUE)){
    install.packages(i, dependencies = TRUE)
    library(i, character.only = TRUE)
  }
}

if(!dir.exists("Results")) dir.create("Results")

paleta = "Pastel 1"
farby = hcl.colors(2, paleta)


# WGS84 projection
prj <- 4326


# land mask from script 0.1
land_mask <- rast("Data/landMask.tif")


##################################
##  Maria's environmental data  ##
##################################

# Updated geology and soil layers
vrstvy = read.table("../../Data/Kachamakova240120/invariantColumns.txt", sep = "\t", header = T)

# Geology layers
geo = st_read("../../Data/Kachamakova231120/bg_geology_soils/", layer = "bg_geology")
geo <- st_transform(geo, crs = prj)
geo = geo[st_is_valid(geo),]
geo$Name <- vrstvy$New.category[match(geo$Name, vrstvy$layer)]
cat(gvrstvy <- sort(unique(geo$Name)), file = "Results/geology-types.txt", sep = "\n")


rgeo = rasterize(vect(geo[geo$Name == gvrstvy[1],]), land_mask, background = 0)

for(i in 2:length(gvrstvy)){
	add(rgeo) <- rasterize(vect(geo[geo$Name == gvrstvy[i],]), land_mask, background = 0)
}

names(rgeo) <- gvrstvy

writeRaster(rgeo, filename = "Data/rgeo.tif", overwrite = TRUE)


# Soil layers
soil = st_read("../../Data/Kachamakova231120/bg_geology_soils/", layer = "bg_soils")
soil <- st_transform(soil, crs = prj)
soil = soil[st_is_valid(soil),]
soil$Name_en <- vrstvy$New.category[match(soil$Name_en, vrstvy$layer)]
cat(svrstvy <- sort(unique(soil$Name_en)), file = "Results/soil-types.txt", sep = "\n")


rsoil = rasterize(vect(soil[soil$Name_en == svrstvy[1],]), land_mask, background = 0)


for(i in 2:length(svrstvy)){
	add(rsoil) <- rasterize(vect(soil[soil$Name_en == svrstvy[i],]), land_mask, background = 0)
}

names(rsoil) <- svrstvy

writeRaster(rsoil, filename = "Data/rsoil.tif", overwrite = TRUE)

