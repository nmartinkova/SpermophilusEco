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
# Helper to visualise progress when script 3 fails.
#
# Order in pipeline: (optional) 5 if script 3 failed and
# needs to be restarted.
############################################################


require(terra)

paleta = "Inferno"
druh = "Spermophilus_citellus"

# shows progress of SDM prediction on a map
# useful when 3SDMprediction tends to fail

subory = dir("Results/SDMtiles", full.names = T)
predikcia = sprc(subory)
predikcia = merge(predikcia)

  pdf(paste0("Results/", druh, "-SDMprediction.pdf"), height = 4.7, width = 7.5)
    plot(predikcia, pax = list(retro = TRUE), las = 1, col = rev(hcl.colors(50, paleta)))
  dev.off()

writeRaster(predikcia, filename = paste0("Results/", druh, "-SDMprediction.tif"), overwrite = TRUE)
