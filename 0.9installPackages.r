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
# Installs SDM software versions required in winter 2023/24. 
#
# Order in pipeline: setup 8 (environment preparation)
############################################################



for(i in c("devtools", "terra", "tidysdm", "pastclim", "EFA.dimensions", "rnaturalearth", "sf", "xgboost", "mgcv", "ranger")){
  if(!require(i, character.only = TRUE)){
    if(i %in% c("tidysdm", "terra", "pastclim")){
      switch(i,  
             # dev versions required 
             # https://evolecolgroup.github.io/tidysdm/index.html
             tidysdm = devtools::install_github("EvolEcolGroup/tidysdm"),
             terra = install.packages('terra', repos='https://rspatial.r-universe.dev'),
             pastclim = devtools::install_github("EvolEcolGroup/pastclim", ref="dev")
      )
    } else {
      install.packages(i, dependencies = TRUE)
    }
    library(i, character.only = TRUE)
  }
}

