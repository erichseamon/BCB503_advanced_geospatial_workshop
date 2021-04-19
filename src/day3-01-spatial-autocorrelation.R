#Title: day3-01-spatial-autocorrelation.R
#BCB503 Geospatial Workshop, April 20th, 22nd, 27th, and 29th, 2021
#University of Idaho
#Data Carpentry Advanced Geospatial Analysis
#Instructors: Erich Seamon, University of Idaho - Li Huang, University of Idaho

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

##01:OLS and spatial dependency of residuals
library(spdep)
library(maptools)

# Set working directory
datafolder <- "data/Puerto-Rico-Farm/"

# Read shapefile and spatial neighbor file
pr <- readShapePoly(paste0(datafolder, "PuertoRico_SPCS.shp", sep=""))

#Use readOGR as an alternative to deprecated maptools
#pr <- rgdal::readOGR(dsn=datafolder, layer="PuertoRico_SPCS")

pr.nb <- read.gal(paste0(datafolder, "PuertoRico.gal", sep=""))

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

#li additions end




# Define data folder
dataFolder<-"data/GWR/"
COUNTY<-shapefile(paste0(dataFolder,"COUNTY_ATLANTIC.shp"))
state<-shapefile(paste0(dataFolder,"STATE_ATLANTIC.shp"))
df<-read.csv(paste0(dataFolder,"data_atlantic_1998_2012.csv"), header=T)


df[6] <- lapply(df[6], as.numeric) # Rate data to numeric
SPDF<-merge(COUNTY,df, by="FIPS")
names(SPDF)

neighbourhood <- poly2nb(SPDF, queen=TRUE)

{
  par(mar=c(0,0,0,0))
  plot(SPDF,
       border="grey")
  plot(neighbourhood,
       coords=coordinates(SPDF),
       col="red",
       add=T)
}

neighbourhood_weights_list <- nb2listw(neighbourhood, style="W", zero.policy=TRUE)


moran.test(SPDF$Rate,neighbourhood_weights_list)

gobal.moran.mc <- moran.mc(SPDF$Rate,
                           neighbourhood_weights_list,
                           nsim=599)

# View results (including p-value)
gobal.moran.mc

par(mar=c(6,3,3,3))

# Plot the distribution (note that this is a density plot instead of a histogram)
plot(gobal.moran.mc, main="", las=1)

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

geary.test(SPDF$Rate,neighbourhood_weights_list)

gobal.geary.mc <- geary.mc(SPDF$Rate,
                           neighbourhood_weights_list,
                           nsim=599)

# View results (including p-value)
gobal.geary.mc

wr <- poly2nb(SPDF, row.names=SPDF$FIPS, queen=FALSE)
lstw <- nb2listw(wr, style='B')
Gi <- localG(SPDF$Rate, lstw)
head(Gi)


par(mfrow=c(1,2)) 

Gcuts <- cut(Gi, 5)
Gcutsi <- as.integer(Gcuts)
cols <- rev(gray(seq(0,1,.2)))
plot(SPDF, col=cols[Gcutsi])
legend('bottomright', levels(Gcuts), fill=cols)

ws <- include.self(wr)
lstws <- nb2listw(ws, style='B')
Gis <- localG(SPDF$Rate, lstws)
Gscuts <- cut(Gis, 5)
Gscutsi <- as.integer(Gscuts)
cols <- rev(gray(seq(0,1,.2)))
plot(SPDF, col=cols[Gscutsi])
legend('bottomright', levels(Gscuts), fill=cols)
