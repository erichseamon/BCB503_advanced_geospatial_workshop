#dyn.load("/opt/modules/climatology/gdal/3.0.2/lib/libgdal.so")
#usePackage(sf, lib="/mnt/lfs2/erichs/R/x86_64-pc-linux-gnu-usePackage/3.6/")
usePackage <- function(p) {
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE, repos = "http://cran.us.r-project.org")
  require(p, character.only = TRUE)
}

usePackage("sf")
usePackage("raster")
usePackage("rgdal")
usePackage("ggplot2")
usePackage("dplyr")
usePackage("sp")           ## Data management
usePackage("spdep")        ## Spatial autocorrelation
usePackage("gstat")        ## Geostatistics
usePackage("splancs")      ## Kernel Density
usePackage("spatstat")     ## Geostatistics
usePackage("pgirmess")     ## Spatial autocorrelation
usePackage("RColorBrewer") ## Visualization
usePackage("classInt")     ## Class intervals
usePackage("broom")        # contains the tidy function which now replaces the fortify function for ggplot
usePackage("viridis")      # For nicer ggplot colours
usePackage("gridExtra")    # Multiple plot
usePackage("spatialreg")
usePackage("maptools")
usePackage("plyr")
usePackage("dpylr")
usePackage("gstat")
usePackage("car")
usePackage("RStoolbox")
usePackage("caret")
usePackage("caretEnsemble")
usePackage("doParallel")
usePackage("randomForest") # Random Forest
usePackage("GWmodel")      ### GW models
usePackage("gtable")
usePackage("SpatialML")    # Geographically weighted regression
