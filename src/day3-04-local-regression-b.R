#One short example with California precipitation data
if (!require("rspatial")) devtools::install_github('rspatial/rspatial')
library(rspatial)
counties <- sp_data('counties')
p <- sp_data('precipitation')
head(p)
plot(counties)
points(p[,c('LONG', 'LAT')], col='red', pch=20)

#Compute annual average precipitation
p$pan <- rowSums(p[,6:17])

#Global regression model
m <- lm(pan ~ ALT, data=p)
m

#Create Spatial* objects with a planar crs.
alb <- CRS("+proj=aea +lat_1=34 +lat_2=40.5 +lat_0=0 +lon_0=-120 +x_0=0 +y_0=-4000000 +ellps=GRS80 +datum=NAD83 +units=m +no_defs")
sp <- p
coordinates(sp) = ~ LONG + LAT
crs(sp) <- "+proj=longlat +datum=NAD83"
spt <- spTransform(sp, alb)
ctst <- spTransform(counties, alb)

#Get the optimal bandwidth
library( spgwr )
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
slope <- r
intercept <- r
slope[!is.na(slope)] <- g$SDF$ALT
intercept[!is.na(intercept)] <- g$SDF$'(Intercept)'
s <- stack(intercept, slope)
names(s) <- c('intercept', 'slope')
plot(s)