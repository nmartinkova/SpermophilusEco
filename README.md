# European ground squirrel SDM pipeline

**High-resolution species distribution and ecological niche modelling of the European ground squirrel in its ancestral range.**


Authors: Natália Martínková, Maria Kachamakova, Jordan Tzvetkov, Yordan Koshev

*Script author: Natália Martínková*

---

## Overview

This repository contains the full R pipeline used to:

* prepare environmental predictors
* harmonise spatial layers
* build and evaluate SDMs
* generate spatial predictions
* analyse environmental variance
* produce response curves and categorical habitat maps

Scripts are designed to run in numerical order.

---

## Important

The pipeline **does not download raw data**.

You must:

1. Download all environmental and occurrence data manually.
2. Store them locally.
3. Update file paths in each script before running.

If paths are not updated, the workflow will fail.

---

## Script order

### 0 – Environmental data preparation

* `0.1land_mask.r` – land mask and study extent
* `0.2geoSoil.r` – geology and soil layers
* `0.3terrain.r` – terrain derivatives
* `0.4aspect.r` – aspect variables
* `0.5copernicus.r` – Copernicus land cover
* `0.6worldclim.r` – WorldClim bioclimatic variables
* `0.7mergeENV.r` – predictors
* `0.9installPackages.r` – install required R packages

### 1 – Modelling

* `1sdm.r` – SDM fitting and evaluation
* `1.5tiles.r` – spatial tiles for SDM prediction

### 2 – Environmental variance

* `2variance.r` – quantify environmental variation from bootstrap resampling

### 3 – Prediction

* `3SDMpredict.r` – generate spatial predictions from tiles
* `3.5tempMerge.r` – intermediate merging

### 4 – Visualisation

* `4plotHist.r` – histograms of bootstrapped predictors
* `5response.r` – response curves

### 6 – Categorisation

* `6categories.r` – classify suitability into habitat categories

---

## Requirements

* R ≥ 4.0
* Packages listed in `0.9installPackages.r`
* All rasters must share CRS, extent, and resolution before modelling

---


