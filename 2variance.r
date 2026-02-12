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
# Draws bootstrap samples from the background and calculates
# predictor variance sampled from the background.
#
# Order in pipeline: 3
############################################################


for (i in c("terra", "sf")) {
  if (!require(i, character.only = TRUE)) {
    stop("Run script 0.5setup.r first")
  }
}


# load environmental data and samp[led points
x = rast("Results/envPCA.tif")
dat = readRDS("Results/presencePseudoabsence.rds")

# to sample background, omit buffer around presences (because they are not random)
omitPresence = buffer(vect(dat[dat$class == "presence",]), width = 700)
x = mask(x, omitPresence, inverse = T, touches = F)


iter = 100
 
# n (pseudoabsences): 6390 in the Results/analysisLog.txt
n = 6390 

# check whether to continue from a failed analysis
if(file.exists("sampledVariance.txt")){
	res = read.table("sampledVariance.txt", sep = "\t", header = T)
} else {
	res = data.frame(matrix(NA, ncol = dim(x)[3], nrow = iter))
}

for(i in which(is.na(res[,1]))){
	cat(i)
	temp = spatSample(x, size = n, na.rm = T, replace = T)
	cat(" spatSample done\n")
	# calculates environmental variance in a random subset of points
	res[i, ] = apply(temp, MARGIN = 2, FUN = var, na.rm = T)
	write.table(res, file = "sampledVariance.txt", sep = "\t")
#	rm(temp)
#	gc()
}
write.table(res, file = "sampledVariance.txt", sep = "\t")
