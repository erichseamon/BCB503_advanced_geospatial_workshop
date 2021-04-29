#Title: day4-03-geographically-weighted-random-forest.R
#BCB503 Geospatial Workshop, April 20th, 22nd, 27th, and 29th, 2021
#University of Idaho
#Data Carpentry Advanced Geospatial Analysis
#Instructors: Erich Seamon, University of Idaho - Li Huang, University of Idaho
 
# Geographically Weighted Random Forest Regression (GWRFR)

# Geographical Random Forest (GRF) is a spatial analysis method using a local version of the Random Forest Regresson Model. 
# It allows for the investigation of the existence of spatial non-stationarity, in the relationship between a dependent and 
# a set of independent variables. The latter is possible by fitting a sub-model for each observation in space, taking into 
# account the neighbouring observations. This technique adopts the idea of the Geographically Weighted Regression, 
# Kalogirou (2003). The main difference between a tradition (linear) GWR and GRF is that we can model non-stationarity 
# coupled with a flexible non-linear model which is very hard to overfit due to its bootstrapping nature, thus relaxing 
# the assumptions of traditional Gaussian statistics. Essentially it was designed to be a bridge between machine learning 
# and geographical models, combining inferential and explanatory power. Additionally, it is suited for datasets with 
# numerous predictors, due to the robust nature of the random forest algorithm in high dimensionality.
#   
#   
# Geographical Weighted Random Forest (GRF) is  based on the concept of spatially varying coefficient models 
# (Fotheringham et al. 2003) where a global process becomes a decomposition of several local sub-models and 
# can be used as a predictive and/or explanatory tool 
# [(Geogoans et al, 2018)](https://www.tandfonline.com/doi/full/10.1080/10106049.2019.1595177).
#   
#   
# To implement the GRF we use a recently developed R package **SpatialML** (Kalogirou and Georganos 2018; “SpatialML.” 
# R Foundation for Statistical Computing) 
#   

##### Load R packages
#dyn.load("/opt/modules/climatology/gdal/3.0.2/lib/libgdal.so")
#library(sf, lib="/mnt/lfs2/erichs/R/x86_64-pc-linux-gnu-library/3.6/")

library(GWmodel)      ### GW models
library(sp)           ## Data management
library(spdep)        ## Spatial autocorrelation
library(RColorBrewer) ## Visualization
library(classInt)     ## Class intervals
library(raster)       ## spatial data
library(grid)         # plot
library(gridExtra)    # Multiple plot
library(ggplot2)      # Multiple plot
library(gtable)
library(SpatialML)    # Geographically weigted regression

#### Load Data


# Define data folder
dataFolder<-"data/GWR/"
county<-shapefile(paste0(dataFolder,"COUNTY_ATLANTIC.shp"))
state<-shapefile(paste0(dataFolder,"STATE_ATLANTIC.shp"))
df<-read.csv(paste0(dataFolder,"data_atlantic_1998_2012.csv"), header=T)


#### Scale co-variates

df[, 5:9] = scale(df[, 5:9])



### Cross validation of bandwidth for Geographically weighted RF regression

#The local model of random forest uses same syntax used in the randomForest function of the R package randomForest. This is a string that is passed to the sub-models randomForest function. For more details look at the class formula.

Coords<-df[ ,2:3]
grf.model <- grf(Rate ~ POV+SMOK+PM25+NO2+SO2, 
                 dframe=df, 
                 bw=40,              # a positive number, in the case of an "adaptive kernel" or a real in the case of a "fixed kernel".
                 ntree=500,          # n integer referring to the number of trees to grow for each of the local random forests.
                 kernel="adaptive",  # the kernel to be used in the regression. Options are "adaptive" or "fixed".
                 forests = TRUE,     # a option to save and export (TRUE) or not (FALSE) all the local forests
                 coords=Coords)      # a numeric matrix or data frame of two columns giving the X,Y coordinates of the observations



### Global Variable Importnace


grf.model$Global.Model$importance 



### Global Mean MSE of 500 tree

mean(grf.model$Global.Model$mse)

### Global Mean R2 of 500 tree

mean(grf.model$Global.Model$rsq)


### Local Model Summary and goodness of fit statistics (training and OOB) 

grf.model$LocalModelSummary

### Local feature importance (IncMSE)

county@data$incMSE.SMOK=grf.model$Local.Pc.IncMSE$SMOK
county@data$incMSE.POV=grf.model$Local.Pc.IncMSE$POV
county@data$incMSE.PM25=grf.model$Local.Pc.IncMSE$PM25
county@data$incMSE.NO2=grf.model$Local.Pc.IncMSE$NO2
county@data$incMSE.SO2=grf.model$Local.Pc.IncMSE$SO2



#### Plot  local feature importance (IncMSE)

polys<- list("sp.lines", as(state, "SpatialLines"), col="grey", lwd=.8,lty=1)
col.palette<-colorRampPalette(c("blue",  "sky blue", "green","yellow", "red"),space="rgb",interpolate = "linear")



col.palette.t<-colorRampPalette(c("blue",  "sky blue", "green","yellow","pink", "red"),space="rgb",interpolate = "linear") 

smok<-spplot(county,"incMSE.SMOK", main = "Smoking", 
             sp.layout=list(polys),
             col="transparent",
             col.regions=rev(col.palette.t(100)))

pov<-spplot(county,"incMSE.POV", main = "Poverty", 
            sp.layout=list(polys),
            col="transparent",
            col.regions=rev(col.palette.t(100)))

pm25<-spplot(county,"incMSE.PM25", main = "PM25", 
             sp.layout=list(polys),
             col="transparent",
             col.regions=rev(col.palette.t(100)))

no2<-spplot(county,"incMSE.NO2", main = "NO2", 
            sp.layout=list(polys),
            col="transparent",
            col.regions=rev(col.palette.t(100)))

so2<-spplot(county,"incMSE.NO2", main = "SO2", 
            sp.layout=list(polys),
            col="transparent",
            col.regions=rev(col.palette.t(100)))



plotrf <- grid.arrange(smok, pov,pm25,no2, so2,ncol=5, heights = c(30,6), top = textGrob("Local Feature Importance (IncMSE)",gp=gpar(fontsize=25)))

plotrf

### Local goodness of fit 

county@data$loc_R2=grf.model$LGofFit$LM_Rsq100


myPaletteRes <- colorRampPalette(c("lightseagreen","lightsteelblue1", "moccasin","hotpink", "red"))
local_r2<-spplot(county,"loc_R2", main = "Local R2 (%)", 
                 sp.layout=list(polys),
                 col="transparent",
                 col.regions=myPaletteRes(100))
#windows(width=4, height=3.5)
#tiff( file="FIG_GWRP_Std_Residuals.tif", 
#      width=4, height=3.5,units = "in", pointsize = 12, res=1600,
#      restoreConsole = T,bg="transparent")
print(local_r2)


#dev.off() 



