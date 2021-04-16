library(caret)        # machine laerning
library(randomForest) # Random Forest
library(rgdal)        # spatial data processing
library(raster)       # raster processing
library(plyr)         # data manipulation 
library(dplyr)        # data manipulation 
library(RStoolbox)    # ploting spatial data 
library(RColorBrewer) # color
library(ggplot2)      # ploting
library(sp)           # spatial data
library(doParallel)   # Parallel processing

# Define data folder

dataFolder<-"data/"

train.df<-read.csv(paste0(dataFolder,"Sentinel2/train_data.csv"), header = T)
test.df<-read.csv(paste0(dataFolder,"Sentinel2/test_data.csv"), header = T)

mc <- makeCluster(detectCores())
registerDoParallel(mc)

myControl <- trainControl(method="repeatedcv", 
                          number=3, 
                          repeats=2,
                          returnResamp='all', 
                          allowParallel=TRUE)

set.seed(849)

fit.rf <- train(as.factor(Landuse)~B2+B3+B4+B4+B6+B7+B8+B8A+B11+B12, 
                data=train.df,
                method = "rf",
                metric= "Accuracy",
                preProc = c("center", "scale"), 
                trControl = myControl
)


fit.rf 

stopCluster(mc)
p1<-predict(fit.rf, train.df, type = "raw")
confusionMatrix(p1, train.df$Landuse)

p2<-predict(fit.rf, test.df, type = "raw")
confusionMatrix(p2, test.df$Landuse)

# read grid CSV file
grid.df<-read.csv(paste0(dataFolder,"Sentinel2/prediction_grid_data.csv"), header = T) 
# Preddict at grid location
p3<-as.data.frame(predict(fit.rf, grid.df, type = "raw"))
# Extract predicted landuse class
grid.df$Landuse<-p3$predict  
# Import lnaduse ID file 
ID<-read.csv(paste0(dataFolder,"Sentinel2/Landuse_ID.csv"), header=T)
# Join landuse ID
grid.new<-join(grid.df, ID, by="Landuse", type="inner") 
# Omit missing values
grid.new.na<-na.omit(grid.new)   


x<-SpatialPointsDataFrame(as.data.frame(grid.new.na)[, c("x", "y")], data = grid.new.na)
r <- rasterFromXYZ(as.data.frame(x)[, c("x", "y", "Class_ID")])


# Color Palette
myPalette <- colorRampPalette(c("light grey","burlywood4", "forestgreen","light green", "dodgerblue"))
# Plot Map
LU<-spplot(r,"Class_ID", main="Supervised Image Classification: Random Forest" , 
           colorkey = list(space="right",tick.number=1,height=1, width=1.5,
                           labels = list(at = seq(1,4.8,length=5),cex=1.0,
                                         lab = c("Road/parking/pavement" ,"Building", "Tree/buses", "Grass", "Water"))),
           col.regions=myPalette,cut=4)
LU


# writeRaster(r, filename = paste0(dataFolder,".\\Sentinel_2\\RF_Landuse.tiff"), "GTiff", overwrite=T)