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
# Creates tiles for the SDM prediction. Attempts to predict,
# but does not include checks. Run script 3 if this one 
# fails.
#
# Order in pipeline: 2
############################################################


library(terra)
library(tidysdm)

# creates tiles from the environmental data modified by the PCA to use for SDM predictions
# if this file fails for predict_raster, DO NOT RUN again, but proceed to 3SDMpredict

if(!dir.exists("Results/tiles")) dir.create("Results/tiles")
if(!dir.exists("Results/SDMtiles")) dir.create("Results/SDMtiles")

env.pca = rast("Results/envPCA.tif")


# if the prediction runs out of memory, reduce to y = 2000 or 1800
makeTiles(env.pca, y = 2200, filename = paste0("Results/tiles/", ".tif"), overwrite = TRUE)

# load modely_spojene - SDM models ensemble
load("Results/Spermophilus_citellus-SDMmodel.RData")

paleta = "Inferno"
druh = "Spermophilus_citellus"

subory = dir("Results/tiles", full.names = TRUE)
for(i in subory){
	x = rast(i)
	meno = sub("tiles", "SDMtiles", i)
	# checks whether the tile is in Bulgaria
	if(any(!is.na(values(x[[1]])))){
		mala.predikcia <- predict_raster(modely_spojene, x, metric_thresh = c("roc_auc", .75))
		writeRaster(mala.predikcia, filename = meno, overwrite = TRUE)
	} else {
		writeRaster(x[[1]], filename = meno, overwrite = TRUE)
	}
}

subory = dir("SDMtiles", full.names = T)
predikcia = sprc(subory)
predikcia = merge(predikcia)

writeRaster(predikcia, filename = paste0("Results", druh, "-SDMprediction.tif"), overwrite = TRUE)
