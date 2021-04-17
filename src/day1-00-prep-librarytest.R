#dyn.load("/opt/modules/climatology/gdal/3.0.2/lib/libgdal.so")
#library(sf, lib="/mnt/lfs2/erichs/R/x86_64-pc-linux-gnu-library/3.6/")

library(sf)
library(raster)
library(rgdal)
library(ggplot2)
library(dplyr)
library(sp)           ## Data management
library(spdep)        ## Spatial autocorrelation
library(gstat)        ## Geostatistics
library(splancs)      ## Kernel Density
library(spatstat)     ## Geostatistics
library(pgirmess)     ## Spatial autocorrelation
library(RColorBrewer) ## Visualization
library(classInt)     ## Class intervals
library(broom)        # contains the tidy function which now replaces the fortify function for ggplot
library(viridis)      # For nicer ggplot colours
library(gridExtra)    # Multiple plot
library(spatialreg)
library(maptools)
library(plyr)
library(gstat)
library(car)
library(RStoolbox)
library(caret)
library(caretEnsemble)
library(doParallel)
library(randomForest) # Random Forest
library(GWmodel)      ### GW models
library(gtable)
library(SpatialML)    # Geographically weighted regression
