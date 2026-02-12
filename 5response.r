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
# Computes and plots model response curves for environmental
# predictors.
#
# Order in pipeline: 7
############################################################



for (i in c("terra", "sf", "mgcv", "tidysdm")) {
  if (!require(i, character.only = TRUE)) {
    stop("Run script 0.9installPackages.r first")
  }
}

paleta = "Inferno"

farby = hcl.colors(2, paleta)

# PCA done, 11 PCs are informative, starting PCA prediction in Results/analysisLog.txt
npcs = 11

# result from SDM prediction from scripts 3 if successful, or 3.5
predikcia = rast("Results/Spermophilus_citellus-SDMprediction.tif")

# Sampled points
dat = readRDS("Results/presencePseudoabsence.rds")

# PCA model of environmental data
load("Results/Spermophilus_citellus-PCAmodel.RData")

# environmental predictors
env = rast("Data/env.tif")

# predict PCA for sampled points
dat <- bind_cols(dat, predict(pca, as.data.frame(dat)))
dat <- dat %>% select(all_of(c(paste0("PC", 1:npcs), "class")))
dat = dat[dat$class == "presence",]

# predictor importance in the SDM model
vars = read.table("Results/SDM-varImportance.txt", header = T, sep = "\t")
PCs = order(vars$mean, decreasing = T)

# expract predictions for sampled points
sdm = terra::extract(predikcia, as.data.frame(st_coordinates(dat)), ID = F)
dat$sdm = sdm$mean

cat("###  Generalized additive models for predicted response to the PCs  ###\n\n",
	file = "Results/SDMresponse.txt", append = F)


# shape of the figure; modify 3x4 to be used now on the next two rows to what fits best
pdf("Results/SDMresponse.pdf", width = 4*2.5, height = 3*2)
par(mfrow = c(3,4), mar = c(5.8,6,0.2,0.2))

for(i in PCs){
fit = gam(formula(paste0("sdm ~ s(PC",i,", k = 3)")), data = dat, method = "REML")
sfit <- summary(fit)

cat("\n\n######   PC",i, "   ######\n\n", sep = "",
	file = "Results/SDMresponse.txt", append = T)
capture.output(print(sfit),
	file = "Results/SDMresponse.txt", append = T)


newdat = data.frame(PC = seq(min(dat[[i]]), max(dat[[i]]), length.out = 100))
colnames(newdat) = paste0("PC", i)

pred = predict(fit, newdata = newdat,
		type = "response", se.fit = T)

plot(dat[[i]], dat$sdm, 
	xlab = paste0("PC", i, " (", round(sfit$dev.expl*100, 1), "%)"), ylab = "", las = 1, type = "n")

polygon(x = c(newdat[,1], rev(newdat[,1])), 
		y = c(pred$fit + 1.96 * pred$se.fit, rev(pred$fit - 1.96 * pred$se.fit)), 
		border = NA, col = farby[2], density = NA)
		
lines(newdat[,1], pred$fit, col = farby[1], lwd = 2)
}
mtext("Predicted response", side = 2, outer = T, line = -2)
mtext("Environmental predictor", side = 1, outer = T, line = -1.3)
dev.off()