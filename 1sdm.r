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
# Fits species distribution models using prepared environmental
# predictors and occurrence data. Produces model objects and
# evaluation metrics for downstream prediction.
#
# Inputs:
# - occurrence data
# - environmental raster stack prepared in the setup workflow
#
# Outputs:
# - fitted SDM models
# - evaluation statistics
# - saved model objects
#
# Order in pipeline: 1
############################################################


for (i in c("terra", "tidysdm", "sf", "EFA.dimensions", "rnaturalearth")) {
  if (!require(i, character.only = TRUE)) {
    stop("Run script 0.9installPackages.r first")
  }
}

# debugging controls, TRUE recommended
verbose <- TRUE

# which data to recalculate
calculateGlobalRanges = TRUE



paleta = "Inferno"

# create folders for results
if (!dir.exists("Results")) dir.create("Results")

# if script "0.9" was run before, need to return the spherical geometry
sf::sf_use_s2(TRUE)

druh <- c("Spermophilus_citellus")

cat(format(Sys.time(), "%Y-%m-%d %H:%M"), "Loading environmental layers\n", file = "Results/analysisLog.txt", append = F)
# land mask with lakes
land_mask <- rast("Data/landMask.tif")

# load environmental layers
# env = rast("Data/env.tif")
cat(names(env), "\n", sep = "\n", file = "Results/analysisLog.txt", append = T)

# global ranges of environmental variables
if(calculateGlobalRanges){
 cat(format(Sys.time(), "%Y-%m-%d %H:%M"), "Calculating global ranges of environmental variables\n\n", file = "Results/analysisLog.txt", append = T)
 x = global(env, fun = "range", na.rm = T)
 write.table(round(x, 2), file = "Results/summaryVariables.txt", sep = "\t")
}


# SDM from climatic and landscape parameters

cat(format(Sys.time(), "%Y-%m-%d %H:%M"), "Starting", druh, "data thinning\n", file = "Results/analysisLog.txt", append = T)

# species occurrence records to be included in the analysis
nalezyMaria = read.table("../../Data/Kachamakova240205/s.citellus_locations_YK_MK_20240204NM.csv", header = T, sep = ",")
nalezyMaria$decimalLongitude = as.numeric(nalezyMaria$longitude)
nalezyMaria$decimalLatitude = as.numeric(nalezyMaria$latitude)
nalezyMaria$year = as.numeric(substr(nalezyMaria$observationDate, nchar(nalezyMaria$observationDate)-3, nchar(nalezyMaria$observationDate)))
nalezy <- nalezyMaria[complete.cases(nalezyMaria[, c("decimalLongitude", "decimalLatitude", "year")]), c("decimalLongitude", "decimalLatitude", "year")]
nalezy <- st_as_sf(nalezy, coords = 1:2, crs = 4326)


# separate data by collection date and within the country
# only data from 2004 onwards from Bulgaria
nalezy = nalezy[nalezy$year > 2004, ]
bulgaria <- read_sf("../../Data/Kachamakova240912/bgr_adm_unicef_20221012_shp/bgr_admbnda_adm0_unicef_20221012.shp")
nalezy = st_intersection(nalezy, st_geometry(bulgaria))
png("Results/dataSince2004.png", height = 380, width = 560)
	par(mar=c(0,0,0,0)+.2)
	plot(st_geometry(nalezy), pch = 20, cex = .6, col = hcl.colors(1, paleta), key.pos = NULL)
	plot(st_geometry(bulgaria), add = T)

dev.off()

# records thinning (stochastic process; fix seed for debugging)
# 700m between occurrence records - Maria 240101
nalezy <- thin_by_dist(nalezy, dist_min = km2m(.7))


# coordinates for background points (stochastic process; fix seed for debugging)
k <- ifelse(nrow(nalezy) < 500, 6, 5)
pozadie <- sample_pseudoabs(nalezy,
  n = k * nrow(nalezy),
  raster = land_mask, method = c("dist_min", km2m(.7))
)
pozadie <- st_transform(pozadie, crs = crs(env))
cat(format(Sys.time(), "%Y-%m-%d %H:%M"), "Pseudoabsences chosen, ", nrow(pozadie), "rows for ", nrow(nalezy), " retained occurrence points\n", file = "Results/analysisLog.txt", append = T)
png("Results/dataThinnedAbsences.png", height = 2*370, width = 2*600)
	par(mar=c(6,8,0,0)+.2)
	plot(land_mask, col = "grey97", legend = F, pax = list(retro = T, cex.axis = 2), las = 1)
	plot(pozadie[nrow(pozadie):1,], pch = 20, cex = .6, pal = hcl.colors(4, paleta)[c(1,3)],  add = T)
dev.off()



# environmental data for background points
cat(format(Sys.time(), "%Y-%m-%d %H:%M"), "Extracting environmental data for the sampled data points\n", file = "Results/analysisLog.txt", append = T)
dat <- pozadie %>% bind_cols(terra::extract(env, pozadie, ID = FALSE))
ktore = complete.cases(as.data.frame(st_drop_geometry(dat)))
dat = dat[ktore, ]
cat("\nn (occurrence points):", nrow(nalezyMaria),
	"\nn (thinned data):", nrow(nalezy),
	"\nn (added background):", nrow(dat),
	"\n   n (presence):", sum(dat$class == "presence"),
	"\n   n (pseudoabsences):", sum(dat$class == "pseudoabs"),"\n\n", 
	file = "Results/analysisLog.txt", append = T)
cat(format(Sys.time(), "%Y-%m-%d %H:%M"), "Background done.", sum(!ktore), "rows removed due to missing data\n",
	file = "Results/analysisLog.txt", append = T)

# remove columns with invariant data (selected data points do not have that soil/geology type)
cat("Removed", abs(sum((invariant <- colSums(as.data.frame(st_drop_geometry(dat[, -c(1:2)]))))) < 2), "invariant columns\n",
	file = "Results/analysisLog.txt", append = T)

if(sum(abs(invariant) < 2) > 0){
	dat = dat[, -unname(2 + which(abs(invariant) < 2))]
}
premenne = names(dat)[-(1:2)]
saveRDS(dat, "Results/presencePseudoabsence.rds")


# PCA from background AND occurrence environmental variables
pca <- prcomp(as.data.frame(dat)[, premenne], scale = TRUE)
  save(pca, file = paste0("Results/", druh, "-PCAmodel.RData"))
capture.output(summary(pca), file = "Results/summaryPCA.txt")

# Velicer's minimum average partial (MAP) test
# number of PCs to retain in SDM
npcs <- MAP(as.data.frame(dat)[, premenne],
  "spearman",
  verbose = F
)$NfactorsMAP4
cat("\n",format(Sys.time(), "%Y-%m-%d %H:%M"), "PCA done,", npcs, "PCs are informative, starting PCA prediction\n",
	file = "Results/analysisLog.txt", append = T)


# predict PC loadings in dat (for work with models) and env (for work with predictions)
dat <- bind_cols(dat, predict(pca, as.data.frame(dat)))
env.pca <- predict(env, pca)
writeRaster(env.pca[[1:npcs]], filename = "Results/envPCA.tif", overwrite = TRUE)
cat(format(Sys.time(), "%Y-%m-%d %H:%M"), "PCA prediction done\n",
	file = "Results/analysisLog.txt", append = T)

rm(env)

# keep only informative PCs
dat <- dat %>% select(all_of(c(paste0("PC", 1:npcs), "class")))
cat(format(Sys.time(), "%Y-%m-%d %H:%M"), "Informative PCs selected. Go to calculate sampleVariance on Metacentrum now\n\n",
	file = "Results/analysisLog.txt", append = T)

# calculate observed variance in the datapoints used to model the SDM	
write.table(t(apply(as.data.frame(dat)[dat$class != "presence", 1:npcs], 2, var, na.rm = T)), 
	file = "Results/observedVariance.txt", sep = "\t")

# scheme for SDM models
env_recipe <- recipe(dat, formula = class ~ .)
env_modely <- workflow_set(
  preproc = list(default = env_recipe),
  models = list(
    glm = sdm_spec_glm(),
    maxent = sdm_spec_maxent(),
    rf = sdm_spec_rf() %>%
      set_engine("ranger", importance = "impurity"),
    gbm = sdm_spec_boost_tree()
  ),
  cross = TRUE
) %>% option_add(control = control_ensemble_grid())

# scheme for spatial cross-validation
env_cv <- spatial_block_cv(dat, v = 5)
cat(format(Sys.time(), "%Y-%m-%d %H:%M"), "CV blocks done. Starting fitting SDMs\n",
	file = "Results/analysisLog.txt", append = T)

# run SDM
env_modely <- env_modely %>% workflow_map("tune_grid",
  resamples = env_cv,
  grid = 5, metrics = sdm_metric_set(), verbose = TRUE
)

# select tuned models for each method based on AUC
modely_spojene <- simple_ensemble() %>% add_member(env_modely, metric = "roc_auc")
cat(format(Sys.time(), "%Y-%m-%d %H:%M"), "Best models selected. Starting PCA plots\n",
	file = "Results/analysisLog.txt", append = T)
save(modely_spojene, file = paste0("Results/", druh, "-SDMmodel.RData"))


# SDM prediction 

# save PCA interpretation, model performance and pdf of SDM prediction
  
  capture.output(modely_spojene$metrics, file = paste0("Results/", druh, "-modelPerformance.txt"))



  # variable importance in SDM
  model1 <- summary(modely_spojene$workflow[[1]]$fit$fit$fit)

  # https://stats.stackexchange.com/a/211396/139563
  standardizedCoefs <- (model1$coefficients[, 1] * model1$coefficients[, 2])[-1]

  relative.importance <- standardizedCoefs / sum(abs(standardizedCoefs)) * 100
  relative.importance <- data.frame(matrix(relative.importance, ncol = 1, dimnames = list(names(relative.importance), "glm")))

  model2 <- modely_spojene$workflow[[2]]$fit$fit$fit$betas
  model2 <- model2[names(model2) %in% rownames(relative.importance)]

  relative.importance$maxent <- NA
  relative.importance[names(model2), "maxent"] <- model2 / sum(abs(model2)) * 100


  model3 <- importance(modely_spojene$workflow[[3]]$fit$fit$fit)

  relative.importance$rt <- NA
  relative.importance[names(model3), "rt"] <- model3 / sum(model3) * 100


  model4 <- xgb.importance(model = modely_spojene$workflow[[4]]$fit$fit$fit)

  relative.importance$boosted_tree <- NA
  relative.importance[model4$Feature, "boosted_tree"] <- model4$Gain * 100


  relative.importance$mean <- round(rowMeans(abs(relative.importance[, 1:4]), na.rm = T), 1)
  relative.importance$sd <- round(apply(abs(relative.importance[, 1:4]), 1, sd, na.rm = T), 1)

  write.table(relative.importance, file = "Results/SDM-varImportance.txt", sep = "\t")

  poradie <- order(relative.importance$mean, decreasing = TRUE)


# plot PCA interpretation
pdf(paste0("Results/", druh, "-PCAinterpretation.pdf"), height = 4, width = 11)

  layout(matrix(c(rep(1, 20), 2), nrow = 1))
  par(mar = c(16, 4, 0, 0) + .1)
  image(1:(nrow(pca$rotation) + 1), 1:(npcs + 1), abs(pca$rotation[, poradie]),
    axes = F, xlab = "", ylab = ""
  )
  for (i in 1:nrow(pca$rotation)) {
    axis(1,
      at = i + .5, labels = sub("_", " ", rownames(pca$rotation)[i]), las = 2 
    )
  }
  axis(2, at = 1.5:(npcs + .5), labels = colnames(pca$rotation)[poradie], las = 1)
  for (i in 1:nrow(pca$rotation)) {
    for (j in 1:length(poradie)) {
      if (pca$rotation[i, poradie[j]] > 0) {
        segments(i, j, i + 1, j + 1, col = "grey")
      } else {
        segments(i + 1, j, i, j + 1, col = "grey")
      }
    }
  }
  box()

  par(mar = c(10, 0.3, 0, 2.5) + .1)
  cisla <- seq(0, max(abs(pca$rotation[, poradie])), length.out = 100)
  image(1, cisla, matrix(cisla, nrow = 1),
    axes = F, col = rev(hcl.colors(100, "YlOrBr")),
    xlab = "", ylab = ""
  )
  axis(4, las = 1)
  box()

dev.off()


