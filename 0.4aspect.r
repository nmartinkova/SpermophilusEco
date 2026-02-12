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
# Computes and preprocesses aspect-related variables.
# Aligns outputs to environmental grid.
#
# Order in pipeline: setup 4 (environment preparation)
############################################################


require(terra)

aspect = rast("Data/Copernicus/aspect.tif")
names(aspect) = "Aspect"
slopes = rast("Data/Copernicus/slope.tif")
names(slopes) = "Slope"


# function to calculate relative aspect with respect to the direct S, N, W, E
asp = function(x, stred){
	x = ifelse(stred == 0 & x > 270, abs(x - 360), x)
	
	res = 1 - abs((x - stred) / 90)
	res = ifelse(res < 0, 0, res)
	return(res)
}

 aspectN = app(aspect, fun = asp, stred = 0)
 aspectE = app(aspect, fun = asp, stred = 90)
 aspectS = app(aspect, fun = asp, stred = 180)
 aspectW = app(aspect, fun = asp, stred = 270)
 
aspects = c(aspectN, aspectE, aspectS, aspectW)
writeRaster(aspects, filename = "Data/Copernicus/aspects.tif", overwrite = T)
 
 
 png("Results/aspect.png", width = 4*560, height = 420)
 	par(mfrow =c(1,4))
 	plot(aspectN, main = "Aspect north")
 	plot(aspectE, main = "Aspect east")
 	plot(aspectS, main = "Aspect south")
 	plot(aspectW, main = "Aspect west")
 dev.off()


# Diurnal Anisotropic Heat
# https://saga-gis.sourceforge.io/saga_tool_doc/7.6.1/ta_morphometry_12.html
# Eq 4.2 in https://doi.org/10.1016/S0166-2481(08)00008-1

dah = function(x, amax = 202.5 * (pi/180)){
	x = x * (pi/180)
	res = cos(amax - x[[1]]) * atan(x[[2]])
	return(res)
}

ha = app(c(aspect, slopes), fun = dah)
names(ha) = "Diurnal anisotropic heat"
writeRaster(ha, filename = "Data/Copernicus/DAH.tif")

# path to original Yordan's DAH that is in different resolution and projection
yordan = rast("../../Data/Kachamakova240312/Diurnal_anisotropic_heating/di_an_heat.asc")

 png("Results/DAH.png", width = 2*560, height = 420)
	par(mfrow = c(1,2))
	plot(yordan, main = "Yordan's DAH")
	plot(ha, main = "Calculated")
dev.off()