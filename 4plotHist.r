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
# Plots bootstrapped variance in environmental predictors 
# and assesses whether the sampled variance is representative
# of the background.
#
# Order in pipeline: 6
############################################################


paleta = "Inferno"
farby = hcl.colors(3, paleta)

# plots observed variance in the sampled pseudoabsences compared to bootstrapped variance

obs = read.table("Results/observedVariance.txt", sep = "\t", header= T)

smp = read.table("Results/sampledVariance.txt", sep = "\t", header= T)
print(sum(!is.na(smp[,1])))

if(!dir.exists("Results")) dir.create("Results")

pdf(paste0("Results/sampledVariance",sum(!is.na(smp[,1])), ".pdf"), width = 4*2, height = 3*2)
par(mfrow = c(4,3), mar = c(5.8,6,0.2,0.2))

for(i in 1:ncol(obs)){
	hist(smp[,i], xlab = paste0("PC", i), ylab = "", main = "", las = 1, col = farby[3], border = NA)
	segments(x0 = obs[1,i], y0=0, y1 = par("usr")[4], col = farby[1], lwd = 3)
	segments(x0 = quantile(smp[,i], prob = c(.025, .975), na.rm = T), y0=0, y1 = par("usr")[4], 
		col = farby[2], lwd = 2, lty = 2)
	box()
}
mtext("Frequency", side = 2, outer = T, line = -2)
mtext("Sampled variance in environmental predictors", side = 1, outer = T, line = -1.3)


dev.off()