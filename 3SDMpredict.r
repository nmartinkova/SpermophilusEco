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
# Projects fitted SDM models across the full study area.
# Produces continuous habitat suitability map. Can be 
# restarted to continue where it had failed.
#
# Order in pipeline: (optional) 4 if script 1.5 failed
############################################################

# predict SDM
for (i in c("terra", "tidysdm")) {
  if (!require(i, character.only = TRUE)) {
    stop("Run script 0.5setup.r first")
  }
}

# predicts SDM
# frequently fails due to memory, but is able to restart where it failed

# load SDM model
load("Results/Spermophilus_citellus-SDMmodel.RData")

paleta = "Inferno"
druh = "Spermophilus_citellus"

# checks what predictions are done and skips those
subory = dir("Results/tiles")
hotove = dir("Results/SDMtiles")
ktore = !(subory %in% hotove)
subory = dir("Results/tiles", full.names = T)[ktore]

cat(format(Sys.time(), "%Y-%m-%d %H:%M"), "Starting independent prediction from saved tiles\n",
	file = "Results/analysisLog.txt", append = T)

for(i in subory){
	x = rast(i)
	meno = sub("tiles", "SDMtiles", i)
	if(any(!is.na(values(x[[1]])))){
		mala.predikcia <- predict_raster(modely_spojene, x, metric_thresh = c("roc_auc", .75))
		writeRaster(mala.predikcia, filename = meno, overwrite = T)
	} else {
		writeRaster(x[[1]], filename = meno, overwrite = T)
	}
	# memory clean-up; causes problems on computational network, works well on a PC
	rm(x, mala.predikcia)
	gc()
}

# final merge of the predicted tiles
# to view progress, when this script failed, run 3.5tempMerge
subory = dir("Results/SDMtiles", full.names = T)
predikcia = sprc(subory)
cat(format(Sys.time(), "%Y-%m-%d %H:%M"), "Merging predicted tiles\n",
	file = "Results/analysisLog.txt", append = T)
predikcia = merge(predikcia)


cat(format(Sys.time(), "%Y-%m-%d %H:%M"), "Prediction for ", druh, " done. Writing final file\n",
	file = "Results/analysisLog.txt", append = T)

# save SDM prediction for the species
writeRaster(predikcia, filename = paste0("Results/", druh, "-SDMprediction.tif"), overwrite = TRUE)

  pdf(paste0("Results/", druh, "-SDMprediction.pdf"), height = 4.8, width = 7.5)
    plot(predikcia, pax = list(retro = TRUE), las = 1, col = rev(hcl.colors(50, paleta)))
  dev.off()


