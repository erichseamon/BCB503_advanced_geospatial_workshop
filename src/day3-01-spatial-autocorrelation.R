#Title: day3-01-spatial-autocorrelation.R
#BCB503 Geospatial Workshop, April 20th, 22nd, 27th, and 29th, 2021
#University of Idaho
#Data Carpentry Advanced Geospatial Analysis
#Instructors: Erich Seamon, University of Idaho - Li Huang, University of Idaho

#dyn.load("/opt/modules/climatology/gdal/3.0.2/lib/libgdal.so")
#library(sf, lib="/mnt/ceph/erichs/R/x86_64-pc-linux-gnu-library/4.0/")

library(sp)           ## Data management
library(spdep)        ## Spatial autocorrelation
library(gstat)        ## Geostatistics
library(splancs)      ## Kernel Density
library(spatstat)     ## Geostatistics
library(pgirmess)     ## Spatial autocorrelation
library(RColorBrewer) ## Visualization
library(classInt)     ## Class intervals
library(raster)       ## spatial data
library(broom)        # contains the tidy function which now replaces the fortify function for ggplot
library(viridis)      # For nicer ggplot colours
library(gridExtra)    # Multiple plot
library(ggplot2)      # Multiple plot
library(raster)       # raster
library(rgdal)       # raster


#li additions---
# 
# ##01:OLS and spatial dependency of residuals
# library(spdep)
# library(maptools)
# 
# # Set working directory
# datafolder <- "data/Puerto-Rico-Farm/"
# 
# # Read shapefile and spatial neighbor file
# pr <- readShapePoly(paste0(datafolder, "PuertoRico_SPCS.shp", sep=""))
# 
# #Use readOGR as an alternative to deprecated maptools
# #pr <- rgdal::readOGR(dsn=datafolder, layer="PuertoRico_SPCS")
# 
# pr.nb <- read.gal(paste0(datafolder, "PuertoRico.gal", sep=""))
# 
# # Create a listw object for binary type spatial weights
# pr.listw <- nb2listw(pr.nb, style="B")
# 
# # Calculate farm density in 2007
# farm.den07 <- pr$nofarms_07/pr$area
# 
# # Spatial autocorrelation tests by Moran's I and Geary's C
# moran.test(farm.den07, pr.listw)
# geary.test(farm.den07, pr.listw)
# 
# # Moran Scatterplot
# moran.plot(farm.den07, pr.listw, pch=20)
# 
# # Calculate farm density in 2007
# farm.den02 <- pr$nofarms_02/pr$area
# 
# # Run a regression model of farm density in 2007 
# # by farm density in 2002
# lm.farm <- lm(farm.den07 ~ farm.den02)
# summary(lm.farm)
# 
# # Test spatial autocorrelation among the regression residuals
# lm.morantest(lm.farm, pr.listw)
# 
# #li additions end




# Define data folder
dataFolder<-"data/GWR/"
COUNTY<-shapefile(paste0(dataFolder,"COUNTY_ATLANTIC.shp"))
state<-shapefile(paste0(dataFolder,"STATE_ATLANTIC.shp"))
df<-read.csv(paste0(dataFolder,"data_atlantic_1998_2012.csv"), header=T)








df[6] <- lapply(df[6], as.numeric) # Rate data to numeric
SPDF<-merge(COUNTY,df, by="FIPS")
names(SPDF)

col.palette.1<-colorRampPalette(c("blue","sky blue", "yellow", "yellow3","orange", "red", "red3"),space="rgb",interpolate = "linear")

mortality <-spplot(SPDF, "Rate", main="Mortality Rate", 
           col.regions=col.palette.1(100))

NO2 <-spplot(SPDF, "NO2", main="NO2", 
                   col.regions=col.palette.1(100))

SO2 <-spplot(SPDF, "SO2", main="SO2", 
             col.regions=col.palette.1(100))

SMOKING <-spplot(SPDF, "SMOK", main="SMOKING", 
             col.regions=col.palette.1(100))

PM25 <-spplot(SPDF, "PM25", main="PM25", 
                 col.regions=col.palette.1(100))


#calculate a basic variogram from the direct Rate data
SPDF_df <- as.data.frame(SPDF)
dists <- dist(SPDF_df[,3:4]) 
summary(dists) 

options(scipen=999)
v.glm<-variogram(SPDF$Rate ~ 1, data = SPDF)
plot(v.glm)

# 
# poly2nb(pl, row.names = NULL, snap=sqrt(.Machine$double.eps),
#         queen=TRUE, useC=TRUE, foundInBox=NULL, small_n=500)

#create our weights


# The first step in a Moran’s I analysis requires that we define “neighboring” polygons. 
# This could refer to contiguous polygons, polygons within a certain distance, or it 
# could be non-spatial in nature and defined by social, political or cultural “neighbors”.

neighbourhood <- poly2nb(SPDF, queen=TRUE)
summary.nb(neighbourhood)
#diffnb generates differences between neighbor lists
#queen, bishop, rook - are methods for determining how shared associations are made




  par(mar=c(0,0,0,0))
  plot(SPDF,
       border="grey")
  plot(neighbourhood,
       coords=coordinates(SPDF),
       col="red",
       add=T)
  
# 
#   nb2listw(neighbours, glist=NULL, style="W", zero.policy=NULL)
#   The nb2listw function supplements a neighbours list with spatial 
#   weights for the chosen coding scheme. The can.be.simmed helper 
#   function checks whether a spatial weights object is similar to 
#   symmetric and can be so transformed to yield real eigenvalues or 
#   for Cholesky decomposition.
  
# B is the basic binary coding, 
# W is row standardised (sums over all links to n), 
# C is globally standardised (sums over all links to n), 
# U is equal to C divided by the number of neighbours (sums over all links to unity), while 
# S is the variance-stabilizing coding scheme proposed by Tiefelsdorf et al. 1999 (sums over all links to n).

# The “minmax” style is based on Kelejian and Prucha (2010), 
# and divides the weights by the minimum of the maximum row 
# sums and maximum column sums of the input weights. It is 
# similar to the C and U styles; it is also available in Stata.
  
  
# 
# If zero policy is set to TRUE, weights vectors of zero length are 
# inserted for regions without neighbour in the neighbours list.
# 
  
  # Next, we need to assign weights to each neighboring polygon. In this example, each 
  # neighboring polygon will be assigned equal weight when computing the 
  # neighboring mean rate values.
  
neighbourhood_weights_list <- nb2listw(neighbourhood, style="W", zero.policy=TRUE)

#check the weights for a single county
neighbourhood_weights_list$weights[1]

#totals to one
sum(as.data.frame(neighbourhood_weights_list$weights[1]))


#Manual calc of Morans I

# This isnt necessary, but if you want, you can plot the relationship between the Rate 
# and its spatially lagged counterpart as follows. The fitted blue line added to the plot 
# is the result of an OLS regression model.

SPDF_lag <- lag.listw(neighbourhood_weights_list, SPDF$Rate)
plot(SPDF_lag ~ SPDF$Rate, pch=16, asp=1)
M1 <- lm(SPDF_lag ~ SPDF$Rate)
abline(M1, col="blue")

# The slope of the line is the Moran’s I coefficient. 
# You can extract its value from the model object M1 as follows

coef(M1)[2]



#Now do a global moran test using moran.test, using the weights

moran.test(SPDF$Rate,neighbourhood_weights_list)



#permutation test for Morans I

# The analytical approach to the Moran’s I analysis benefits from being fast. 
# But it may be sensitive to irregularly distributed polygons. A safer approach to 
# hypothesis testing is to run an MC simulation using the moran.mc() function. 
# The moran.mc function takes an extra argument n, the number of simulations.

gobal.moran.mc <- moran.mc(SPDF$Rate,
                           neighbourhood_weights_list,
                           nsim=599)

# View results (including p-value)

gobal.moran.mc


#now plot the distribution of the MC permutation

par(mar=c(6,3,3,3))

# Plot the distribution (note that this is a density plot instead of a histogram)
plot(gobal.moran.mc, main="", las=1)


# The curve shows the distribution of Moran I values we could expect had the 
# rates been randomly distributed across the counties. Note that our observed statistic, 
# 0.547, falls way to the right of the distribution suggesting that the rate values 
# are clustered (a positive Moran’s I value suggests clustering whereas a negative 
# Moran’s I value suggests dispersion).



#now lets look at local Morans I

# The local spatial statistic Moran's I is calculated for each zone based 
# on the spatial weights object used. The values returned include a 
# Z-value, and may be used as a diagnostic tool. 

local.moran.results <- localmoran(SPDF$Rate,
                                  neighbourhood_weights_list,
                                  p.adjust.method="bonferroni",
                                  na.action=na.exclude,
                                  zero.policy=TRUE)

summary(local.moran.results)

# add moran's I results back to the shapefile
SPDF@data$lmoran_i <- local.moran.results[,1]
SPDF@data$lmoran_p <- local.moran.results[,5]
SPDF@data$lmoran_sig <- local.moran.results[,5]<0.05



col.palette.1<-colorRampPalette(c("blue","sky blue", "yellow", "yellow3","orange", "red", "red3"),space="rgb",interpolate = "linear")
col.palette.2<-colorRampPalette(c("blue","sky blue", "yellow", "orange"),space="rgb",interpolate = "linear")
col.palette.3<-colorRampPalette(c("yellow", "blue"),space="rgb")
p1<-spplot(SPDF, "lmoran_i", main="Local Moran's I", 
           col.regions=col.palette.1(100))
p2<-spplot(SPDF, "lmoran_p", main="P-values", 
           col.regions=col.palette.2(100))
p3<-spplot(SPDF, "lmoran_sig", main="P-values < 0.05", 
           cut=2,col.regions=col.palette.3(3))

p4 <- grid.arrange(p1, p2, p3, ncol=3)

p4




#now lets run GearyC

geary.test(SPDF$Rate,neighbourhood_weights_list)

gobal.geary.mc <- geary.mc(SPDF$Rate,
                           neighbourhood_weights_list,
                           nsim=599)

# View results (including p-value)
gobal.geary.mc


#now Getis Ord G

#The local spatial statistic G is calculated for each zone based on the 
# spatial weights object used. The value returned is a Z-value, and may 
# be used as a diagnostic tool. High positive values indicate the possibility 
# of a local cluster of high values of the variable being analysed, very 
# low relative values a similar cluster of low values. For inference, a 
# Bonferroni-type test is suggested in the references, where tables of 
# critical values may be found (see also details below).



wr <- poly2nb(SPDF, queen=FALSE)
lstw <- nb2listw(wr, style='B')

Gi <- localG(SPDF$Rate, lstw)
head(Gi)


par(mfrow=c(1,2)) 

Gcuts <- cut(Gi, 5)
Gcutsi <- as.integer(Gcuts)
cols <- rev(gray(seq(0,1,.2)))
plot(SPDF, col=cols[Gcutsi])
legend('bottomright', levels(Gcuts), fill=cols)

ws <- include.self(wr) #include the region itself in its own list of neighbors
lstws <- nb2listw(ws, style='B')
Gis <- localG(SPDF$Rate, lstws)
Gscuts <- cut(Gis, 5)
Gscutsi <- as.integer(Gscuts)
cols <- rev(gray(seq(0,1,.2)))
plot(SPDF, col=cols[Gscutsi])
legend('bottomright', levels(Gscuts), fill=cols)
