##01:OLS and spatial dependency of residuals
library(spdep)
library(maptools)

# Set working directory
setwd(file.path(Sys.getenv("USERPROFILE"),"Desktop\\d3-sr\\data"))

# Read shapefile and spatial neighbor file
pr <- readShapePoly("PuertoRico_SPCS.shp")
pr.nb <- read.gal("PuertoRico.GAL")

# Create a listw object for binary type spatial weights
pr.listw <- nb2listw(pr.nb, style="B")

# Calculate farm density in 2007
farm.den07 <- pr$nofarms_07/pr$area

# Spatial autocorrelation tests by Moran's I and Geary's C
moran.test(farm.den07, pr.listw)
geary.test(farm.den07, pr.listw)

# Moran Scatterplot
moran.plot(farm.den07, pr.listw, pch=20)

# Calculate farm density in 2007
farm.den02 <- pr$nofarms_02/pr$area

# Run a regression model of farm density in 2007 
# by farm density in 2002
lm.farm <- lm(farm.den07 ~ farm.den02)
summary(lm.farm)

# Test spatial autocorrelation among the regression residuals
lm.morantest(lm.farm, pr.listw)