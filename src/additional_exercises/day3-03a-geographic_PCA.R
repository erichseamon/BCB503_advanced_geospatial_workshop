#Title: day3-03a-geographic_PCA.R
#BCB503 Geospatial Workshop, April 20th, 22nd, 27th, and 29th, 2021
#University of Idaho
#Data Carpentry Advanced Geospatial Analysis
#Instructors: Erich Seamon, University of Idaho - Li Huang, University of Idaho


library(GWmodel)      ### GW models
library(sp)           ## Data management
library(spdep)        ## Spatial autocorrelation
library(gstat)        ## Geostatistics
library(RColorBrewer) ## Visualization
library(classInt)     ## Class intervals
library(raster)       ## spatial data
library(gridExtra)    # Multiple plot
library(ggplot2)      # Multiple plot


# Define data folder
dataFolder<-"data/GWR/"
COUNTY<-shapefile(paste0(dataFolder,"COUNTY_ATLANTIC.shp"))
state<-shapefile(paste0(dataFolder,"STATE_ATLANTIC.shp"))
df<-read.csv(paste0(dataFolder,"data_atlantic_1998_2012.csv"), header=T)


SPDF<-merge(COUNTY,df, by="FIPS")
names(SPDF)

mf <- SPDF[, c(16:20)] 
names(mf)

data.scaled <- scale(as.matrix(mf@data[, 1:5]))
pca <- princomp(data.scaled, cor = FALSE)
pca2 <- (pca$sdev^2 / sum(pca$sdev^2)) * 100
barplot(pca2)
biplot(pca)

pca$loadings

coords <- as.matrix(cbind(SPDF$x.x, SPDF$y.y))
scaled.spdf <- SpatialPointsDataFrame(coords, as.data.frame(data.scaled ))

bw.gw.pca <- bw.gwpca(scaled.spdf, 
                      vars = colnames(scaled.spdf@data),
                      k = 5,
                      robust = FALSE, 
                      adaptive = TRUE)

bw.gw.pca

gw.pca<- gwpca(scaled.spdf, 
               vars = colnames(scaled.spdf@data), 
               bw=bw.gw.pca,
               k = 5, 
               robust = FALSE, 
               adaptive = TRUE)

# function for calculation pproportion of variance 
prop.var <- function(gwpca.obj, n.components) {
  return((rowSums(gwpca.obj$var[, 1:n.components]) /rowSums(gwpca.obj$var)) * 100)
}

var.gwpca <- prop.var(gw.pca, 3)
mf$var.gwpca <- var.gwpca

polys<- list("sp.lines", as(state, "SpatialLines"), col="grey", lwd=.8,lty=1)
col.palette<-colorRampPalette(c("blue",  "sky blue", "green","yellow", "red"),space="rgb",interpolate = "linear")

mypalette.4 <- brewer.pal(8, "YlGnBu")
spplot(mf, "var.gwpca", key.space = "right",
       col.regions = mypalette.4, cuts = 7, 
       sp.layout =list(polys),
       col="transparent",
       main = "Percent Total Variation for Local components 1 to 3")

loadings.pc1 <- gw.pca$loadings[, , 1]
win.item = max.col(abs(loadings.pc1))
mf$win.item <- win.item

mypalette.4 <- c("lightpink", "blue", "grey", "purple",  "green")
spplot(mf, "win.item", key.space = "right",
       col.regions = mypalette.4, at = c(1, 2, 3, 4, 5),
       main = "Winning variable: highest \n abs. loading on local Comp.1",
       sp.layout =list(polys))


