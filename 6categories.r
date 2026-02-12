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
# Converts continuous suitability maps into categorical habitat
# classes based on selected thresholds.
#
# Order in pipeline: 8
############################################################


for (i in c("terra", "classInt")) {
  if (!require(i, character.only = TRUE)) {
    stop("Run script 0.5setup.r first")
  }
}

paleta <- "Inferno"

farby <- hcl.colors(2, paleta)

# PCA done, 11 PCs are informative, starting PCA prediction in Results/analysisLog.txt
npcs <- 11

if (!file.exists("Results/Scitellus-SDMpredictionClasses.tif")) {
  # result from scripts 3 if successful, or 3.5
  predikcia <- rast("Results/Spermophilus_citellus-SDMprediction.tif")

  # Maria's email 241220
  # We will finally keep 5 classes distributed according to the Jenk histogram:
  # - 0.00 - 0.08
  # - 0.08 - 0.20
  # - 0.20 - 0.34
  # - 0.34 - 0.52
  # - 0.52 - 1

  classes <- matrix(c(
    0.00, 0.08, 0,
    0.08, 0.20, 1,
    0.20, 0.34, 2,
    0.34, 0.52, 3,
    0.52, 1, 4
  ), ncol = 3, byrow = T)




  pred2 <- classify(predikcia, classes)

  # save SDM prediction for the species
  writeRaster(pred2, filename = paste0("Results/Scitellus-SDMpredictionClasses.tif"), overwrite = TRUE)

  pdf(paste0("Results/Scitellus-SDMpredictionClasses.pdf"), height = 4.8, width = 7.5)
  layout(matrix(c(rep(1, 5), 2), nrow = 1))
  plot(pred2,
    pax = list(retro = TRUE), las = 1, col = rev(hcl.colors(5, paleta)),
    legend = F, mar = c(3.1, 4.1, 2.1, 1.1)
  )
  par(mar = c(10.2, .2, 10.2, rep(7.2, 1)))
  image(1, 1:5, matrix(1:5, nrow = 1),
    col = rev(hcl.colors(5, paleta)), axes = F,
    xlim = c(1, 1.5), ylab = "", xlab = ""
  )
  text(1.6, c(1, 5), labels = c("unsuitable", "suitable"), xpd = NA, adj = 0)
  dev.off()
} else {
  pred2 <- rast("Results/Scitellus-SDMpredictionClasses.tif")
}

km0 <- cellSize(pred2, unit = "km")
km0 <- mask(km0, pred2)
cat("Total area studied: ", plocha <- global(km0, "sum", na.rm = T)[1, 1], "km2\n",
	"Total number of cells: ", n <- global(not.na(pred2), "sum")[1,1],
  file = "Results/area.txt", append = F
)
for(i in 0:4){
	bi = ifel(pred2 == i, 1, NA)
	km = mask(km0, bi)
	cat("Area with suitability ",i, ":", a1 <- global(km, "sum", na.rm = T)[1, 1], "km2 (", 
	round(100* (a1 / plocha), 1), "%)\n",
	"Number of cells with ", i, ":", n1 <- global(not.na(km), "sum")[1,1], "(",
	round(100* (n1 / n), 1), "%)\n\n",
  file = "Results/area.txt", append = T
)

}


# Jenks 
rm(list = ls())

pred = rast("Results/Spermophilus_citellus-SDMprediction.tif")

x = values(pred)
x0 = is.finite(x)
rm(pred)

cat("######  Jenks' 10x resampled  ######\n\n", file = "Results/Jenks.txt", append = F)

for(i in 1:10){
	y = sample(x, 1e6)
	capture.output(
		classIntervals(y[!is.na(y)], 5, style = "jenks", largeN = 1e4),
		file = "Results/Jenks.txt", append = T
	)

}


# remove small patches

pred2 <- rast("Results/Scitellus-SDMpredictionClasses.tif")
pred2 = as.factor(pred2 + 1)

# oblasti = patches(pred2, directions = 8, filename = "Results/pred2oblasti.tif")


# elevation

altitude = rast("Data/Copernicus/elevation.tif")

pdf("Results/boxplotAltitude.pdf", width = 4.5, height = 3.5)
par(mar = c(4,4,0,0)+.2)
boxplot(altitude, pred2, col = rev(hcl.colors(5, paleta)),
	range = 0, xlab = "Habitat suitability class", ylab = "Elevation (m a.s.l.)", las = 1)
dev.off()


altClasses <- classify(altitude, rcl = matrix(c(-50, 600, 1, 
                                                600, 1500, 2, 
                                                1500, 3000, 3), 
                                              ncol = 3, byrow = TRUE))
altClasses = as.factor(altClasses)

km2 = cellSize(altitude, mask = T, unit = "km")


res = zonal(km2, c(altClasses, pred2), fun = "sum", na.rm= T)

write.table(res, file = "Results/altClasses.txt")

pdf("Results/altClasses.pdf", width = 6, height = 4)
par(mar = c(4,4.2,0,0) + .3)
	barplot(t(as.matrix(res[,2:6])), beside = T, names.arg = c("0-600", "601-1500", "1501-2925"), 
		xlab = "Elevation (m a.s.l.)", las = 1, ylab = expression("Area (km"^2 * ")"), 
		col = hcl.colors(5, "Inferno", rev = T), ylim = c(0, max(res[, 2:6]) + 500))
	box()
	legend("topright", legend = 1:5, fill = hcl.colors(5, "Inferno", rev = T), border = NA, y.intersp=.7, cex = 1.2,
		title = "Suitability ", title.adj = 0, bty = "n")

dev.off()