#Title: day4-01-rf-supervised-classification.R
#BCB503 Geospatial Workshop, April 20th, 22nd, 27th, and 29th, 2021
#University of Idaho
#Data Carpentry Advanced Geospatial Analysis
#Instructors: Erich Seamon, University of Idaho - Li Huang, University of Idaho

#dyn.load("/opt/modules/climatology/gdal/3.0.2/lib/libgdal.so")
#library(sf, lib="/mnt/lfs2/erichs/R/x86_64-pc-linux-gnu-library/3.6/")
library(caret)        # machine laerning
library(randomForest) # Random Forest
library(rgdal)        # spatial data processing
library(raster)       # raster processing
library(plyr)         # data manipulation 
library(dplyr)        # data manipulation 
#library(RStoolbox)    # ploting spatial data 
library(RColorBrewer) # color
library(ggplot2)      # ploting
library(sp)           # spatial data
library(doParallel)   # Parallel processing

# Define data folder

dataFolder<-"data/"

train.df<-read.csv(paste0(dataFolder,"Sentinel2/train_data.csv"), header = T)
test.df<-read.csv(paste0(dataFolder,"Sentinel2/test_data.csv"), header = T)

train.df$Landuse <- as.factor(train.df$Landuse)
test.df$Landuse <- as.factor(test.df$Landuse)


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

# 
# Cohen’s kappa statistic is a measure that 
# can handle both multi-class and imbalanced class problems.


fit.rf 

importance <- varImp(fit.rf, scale=FALSE)
plot(importance)

#another interesting method - recursive feature elimination

control <- rfeControl(functions=rfFuncs, method="cv", number=10)
# run the RFE algorithm
results <- rfe(train.df[,3:12], as.factor(train.df[,14]), sizes=c(1:9), rfeControl=control)

# RFE is a wrapper-type feature selection algorithm. This means that 
# a different machine learning algorithm is given and used in the 
# core of the method, is wrapped by RFE, and used to help select 
# features. This is in contrast to filter-based feature selections 
# that score each feature and select those features with the largest 
# (or smallest) score.



stopCluster(mc)
p1<-predict(fit.rf, train.df, type = "raw")
confusionMatrix(p1, train.df$Landuse)

p2<-predict(fit.rf, test.df, type = "raw")
confusionMatrix(p2, test.df$Landuse)

# read grid CSV file
grid.df<-read.csv(paste0(dataFolder,"Sentinel2/prediction_grid_data.csv"), header = T) 
# Predict at grid location
p3<-as.data.frame(predict(fit.rf, grid.df, type = "raw"))
#evaluate the probability of the classification
p4 <- predict(fit.rf, newdata = grid.df, type = "prob")

# Extract predicted landuse class
grid.df$Landuse<-p3$predict  
# Import landuse ID file 
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