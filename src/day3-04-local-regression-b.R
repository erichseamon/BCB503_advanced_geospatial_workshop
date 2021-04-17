#One short example with California precipitation data
#if (!require("rspatial")) devtools::install_github('rspatial/rspatial')
#library(rspatial)

library( spgwr )


datafolder <- "data/GWR/"
counties <- readShapePoly(paste0(datafolder, "counties.shp", sep=""))
p <- read.csv(paste0(datafolder, "precipitation.csv", sep=""))

head(p)
plot(counties)
points(p[,c('LONG', 'LAT')], col='red', pch=20)

#Compute annual average precipitation
p$pan <- rowSums(p[,7:18])

#Global regression model
m <- lm(pan ~ ALT, data=p)
m

#Create Spatial* objects with a planar crs.
alb <- CRS("+proj=aea +lat_1=34 +lat_2=40.5 +lat_0=0 +lon_0=-120 +x_0=0 +y_0=-4000000 +ellps=GRS80 +datum=NAD83 +units=m +no_defs")
sp <- p
coordinates(sp) = ~ LONG + LAT
crs(sp) <- "+proj=longlat +datum=NAD83"
crs(counties) <- "+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0 "
spt <- spTransform(sp, alb)
ctst <- spTransform(counties, alb)

#Get the optimal bandwidth
## NOTE: This package does not constitute approval of GWR
## as a method of spatial analysis; see example(gwr)
bw <- gwr.sel(pan ~ ALT, data=spt)
bw

#Create a regular set of points to estimate parameters for.
r <- raster(ctst, res=10000)
r <- rasterize(ctst, r)
newpts <- rasterToPoints(r)

#Run the gwr function
g <- gwr(pan ~ ALT, data=spt, bandwidth=bw, fit.points=newpts[, 1:2])
g

#Link the results back to the raster
coef_slope <- r
intercept <- r
coef_slope[!is.na(coef_slope)] <- g$SDF$ALT
intercept[!is.na(intercept)] <- g$SDF$'(Intercept)'
s <- stack(coef_slope, intercept)
names(s) <- c('slope of coefficient', 'intercept')
plot(s)
