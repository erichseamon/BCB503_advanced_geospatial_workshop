#Title: rv-01-raster-structure.R
#BCB503 Geospatial Workshop, April 23 and 24th, 2020
#University of Idaho
#Data Carpentry Geospatial Analysis
#Instructors: Erich Seamon, University of Idaho - Travis Seaborn, University of Idaho

library(raster)
library(rgdal)
library(ggplot2)
library(dplyr)


#In this episode, we will introduce the fundamental principles, 
#packages and metadata/raster attributes that are needed to work 
#with raster data in R. We will discuss some of the core metadata 
#elements that we need to understand to work with rasters in R, 
#including CRS and resolution. We will also explore missing and 
#bad data values as stored in a raster and how R handles these elements.

#We will continue to work with the `dplyr` and `ggplot2` packages 
#that were introduced previously. We will use two additional packages 
#in this episode to work with raster data - the `raster` and `rgdal` 
#packages. Make sure that you have these packages loaded.

library(raster)
library(rgdal)

## Introduce the Data

## View Raster File Attributes

#We will be working with a series of GeoTIFF files in this lesson. 
#The GeoTIFF format contains a set of embedded tags with metadata 
#about the raster data. We can use the function `GDALinfo()` to get 
#information about our raster data before we read that data into R. 
#It is ideal to do this before importing your data.


GDALinfo("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")

#If you wish to store this information in R, you can do the following:

HARV_dsmCrop_info <- capture.output(
  GDALinfo("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")
)


#Each line of text that was printed to the console is now stored as 
#an element of the character vector `HARV_dsmCrop_info`. We will be 
#exploring this data throughout this episode. By the end of this 
#episode, you will be able to explain and understand the output above.

## Open a Raster in R

#Now that we've previewed the metadata for our GeoTIFF, let's import 
#this raster dataset into R and explore its metadata more closely. We 
#can use the `raster()` function to open a raster in R.

## Data Tip - Object names

#To improve code readability, file and object names should be used 
#that make it clear what is in the file. The data for this episode 
#were collected from Harvard Forest so we'll use a naming convention 
#of `datatype_HARV`.

#First we will load our raster file into R and view the data structure.


DSM_HARV <- 
  raster("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")

DSM_HARV


#The information above includes a report of min and max values, 
#but no other data range statistics. Similar to other R data structures 
#like vectors and data frame columns, descriptive statistics for raster 
#data can be retrieved:


summary(DSM_HARV)


#but note the warning - unless you force R to calculate these statistics 
#using every cell in the raster, it will take a random sample of 100,000 
#cells and calculate from that instead. To force calculation on more, or 
#even all values, you can use the parameter #`maxsamp`:


summary(DSM_HARV, maxsamp = ncell(DSM_HARV))

#You may not see major differences in summary stats as `maxsamp` increases, 
#except with very large rasters.

#To visualise this data in R using `ggplot2`, we need to convert it to a dataframe. 


DSM_HARV_df <- as.data.frame(DSM_HARV, xy = TRUE)


#Now when we view the structure of our data, we will see a standard 
#dataframe format.

str(DSM_HARV_df)


#We can use `ggplot()` to plot this data. We will set the color scale 
#to `scale_fill_viridis_c` which is a color-blindness friendly color scale.
#We will also use the `coord_quickmap()` function to use an approximate 
#Mercator projection for our plots. This approximation is suitable for 
#small areas that are not too close to the poles. Other coordinate 
#systems are available in ggplot2 if needed, you can learn about them 
#at their help page `?coord_map`.


ggplot() +
    geom_raster(data = DSM_HARV_df , aes(x = x, y = y, fill = HARV_dsmCrop)) +
    scale_fill_viridis_c() +
    coord_quickmap()

## Plotting Tip
#For faster, simpler plots, you can use the `plot` function from the `raster` package.

plot(DSM_HARV)


#This map shows the elevation of our study site in Harvard Forest. 
#From the legend, we can see that the maximum elevation is ~400, but 
#we can't tell whether this is 400 feet or 400 meters because the 
#legend doesn't show us the units. We can look at the metadata of 
#our object to see what the units are. Much of the metadata that 
#we're interested in is part of the CRS. We introduced the concept of a CRS earlier.

#Now we will see how features of the CRS appear in our data file 
#and what meanings they have.

### View Raster Coordinate Reference System (CRS) in R
#We can view the CRS string associated with our R object using the`crs()` function.

crs(DSM_HARV)

## Challenge
#What units are our data in?

## Answers
#`+units=m` tells us that our data is in meters.

## Understanding CRS in Proj4 Format

#The CRS for our data is given to us by R in `proj4` format. 
#Let's break down the pieces of `proj4` string. The string 
#contains all of the individual CRS elements that R or another 
#GIS might need. Each element is specified with a `+` sign, 
#similar to how a `.csv` file is delimited or broken up by a `,`. 
#After each `+` we see the CRS element being defined. For example 
#projection (`proj=`) and datum (`datum=`).

### UTM Proj4 String

#Our projection string for `DSM_HARV` specifies the UTM projection as follows:

#`+proj=utm +zone=18 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0`

#**proj=utm:** the projection is UTM, UTM has several zones.
#**zone=18:** the zone is 18
#**datum=WGS84:** the datum is WGS84 (the datum refers to the  0,0 
#reference for the coordinate system used in the projection)
#**units=m:** the units for the coordinates are in meters
#**ellps=WGS84:** the ellipsoid (how the earth's  roundness is calculated) 
#for the data is WGS84.Note that the zone is unique to the UTM projection. 
#Not all CRSs will have a zone. 

## Calculate Raster Min and Max Values

#It is useful to know the minimum or maximum values of a raster 
#dataset. In this case, given we are working with elevation data, 
#these values represent the min/max elevation range at our site.

#Raster statistics are often calculated and embedded in a GeoTIFF 
#for us. We can view these values:

minValue(DSM_HARV)

maxValue(DSM_HARV)

## Data Tip - Set min and max values
#If the minimum and maximum values haven't already been calculated, 
#we can calculate them using the
#`setMinMax()` function.

DSM_HARV <- setMinMax(DSM_HARV)

#We can see that the elevation at our site ranges from `r minValue(DSM_HARV)`m 
#to `r maxValue(DSM_HARV)`m.

## Raster Bands

#The Digital Surface Model object (`DSM_HARV`) that we've been working 
#with is a single band raster. This means that there is only one dataset 
#stored in the raster: surface elevation in meters for one time period.

#A raster dataset can contain one or more bands. We can use the `raster()` 
#function to import one single band from a single or multi-band raster. We 
#can view the number of bands in a raster using the `nlayers()` function.

nlayers(DSM_HARV)

#However, raster data can also be multi-band, meaning that one raster file 
#contains data for more than one variable or time period for each cell. By 
#default the `raster()` function only imports the first band in a raster 
#regardless of whether it has one or more bands. Jump to a later episode 
#in this series for information on working with multi-band rasters:

## Dealing with Missing Data

#Raster data often has a `NoDataValue` associated with it. This is a 
#value assigned to pixels where data is missing or no data were collected.

#By default the shape of a raster is always rectangular. So if we have  
#a dataset that has a shape that isn't rectangular, some pixels at the 
#edge of the raster will have `NoDataValue`s. This often happens when 
#the data were collected by an airplane which only flew over some part 
#of a defined region.

#In the image below, the pixels that are black have `NoDataValue`s. 
#The camera did not collect data in these areas.


# Use stack function to read in all bands

RGB_stack <-
  stack("data/NEON-DS-Airborne-Remote-Sensing/HARV/RGB_Imagery/HARV_RGB_Ortho.tif")

# aggregate cells from 0.25m to 2m for plotting to speed up the lesson and 
# save memory

RGB_2m <- raster::aggregate(RGB_stack, fact = 8, fun = median)

# fix data values back to integer datatype

values(RGB_2m) <- as.integer(round(values(RGB_2m)))

# convert to a df for plotting using raster's built-in method

RGB_2m_df  <- as.data.frame(RGB_2m, xy = TRUE)

# make colnames easy to ref

names(RGB_2m_df) <- c('x', 'y', 'red', 'green', 'blue')

ggplot() +
 geom_raster(data = RGB_2m_df , aes(x = x, y = y, fill = red),
             show.legend = FALSE) +
  scale_fill_gradient(low = 'black', high = "red") +
  ggtitle("Orthographic Imagery", subtitle = 'Red Band') +
  coord_quickmap()


# demonstration code - not being taught

RGB_2m_df_nd <- RGB_2m_df

# convert the three rgb values to hex codes

RGB_2m_df_nd$hex <- rgb(RGB_2m_df_nd$red,
                        RGB_2m_df_nd$green,
                        RGB_2m_df_nd$blue, maxColorValue = 255)
                        
# set black hex code to NA

RGB_2m_df_nd$hex[RGB_2m_df_nd$hex == '#000000'] <- NA_character_ 

ggplot() +
  geom_raster(data = RGB_2m_df_nd, aes(x = x, y = y, fill = hex)) +
  scale_fill_identity() +
  ggtitle("Orthographic Imagery", subtitle = "All bands") +
  coord_quickmap()



#If your raster already has `NA` values set correctly but you aren't 
#sure where they are, you can deliberately plot them in a particular 
#colour. This can be useful when checking a dataset's coverage. For 
#instance, sometimes data can be missing where a sensor could not 
#'see' its target data, and you may wish to locate that missing data and fill it in.

#To highlight `NA` values in ggplot, alter the `scale_fill_*()` 
#layer to contain a colour instruction for `NA` values, like 
#`scale_fill_viridis_c(na.value = 'deeppink')`

# demonstration code
# function to replace 0 with NA where all three values are 0 only

RGB_2m_nas <- calc(RGB_2m, 
                   fun = function(x) {
                           x[rowSums(x == 0) == 3, ] <- rep(NA, nlayers(RGB_2m))
                           x
                   })
RGB_2m_nas <- as.data.frame(RGB_2m_nas, xy = TRUE)

ggplot() +
  geom_raster(data = RGB_2m_nas, aes(x = x, y = y, fill = HARV_RGB_Ortho.3)) + 
  scale_fill_gradient(low = 'grey90', high = 'blue', na.value = 'deeppink') +
  ggtitle("Orthographic Imagery", subtitle = "Blue band, with NA highlighted") +
  coord_quickmap()

# memory saving
rm(RGB_2m, RGB_stack, RGB_2m_df_nd, RGB_2m_df, RGB_2m_nas)


#The value that is conventionally used to take note of missing data 
#(the `NoDataValue` value) varies by the raster data type. For 
#floating-point rasters, the figure `-3.4e+38` is a common default, 
#and for integers, `-9999` is common. Some disciplines have specific 
#conventions that vary from these common values.

#In some cases, other `NA` values may be more appropriate. 
#An `NA` value should be a) outside the range of valid values, and b) 
#a value that fits the data type in use. For instance, if your data 
#ranges continuously from -20 to 100, 0 is not an acceptable 
#`NA` value! Or, for categories that number 1-15, 0 might be fine for 
#`NA`, but using -.000003 will force you to save the GeoTIFF on disk 
#as a floating point raster, resulting in a bigger file.

#If we are lucky, our GeoTIFF file has a tag that tells us what is 
#the `NoDataValue`. If we are less lucky, we can find that information 
#in the raster's metadata. If a `NoDataValue` was stored in the GeoTIFF 
#tag, when R opens up the raster, it will assign each instance of the 
#value to `NA`. Values of `NA` will be ignored by R as demonstrated above.

## Challenge

#Use the output from the `GDALinfo()` function to find out what 
#`NoDataValue` is used for our `DSM_HARV` dataset.

## Answers

GDALinfo("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")

#`NoDataValue` are encoded as -9999.

## Bad Data Values in Rasters

#Bad data values are different from `NoDataValue`s. Bad data values 
#are values that fall outside of the applicable range of a dataset.

#Examples of Bad Data Values:

#* The normalized difference vegetation index (NDVI), which is a measure of
#greenness, has a valid range of -1 to 1. Any value outside of that range would
#be considered a "bad" or miscalculated value.
#* Reflectance data in an image will often range from 0-1 or 0-10,000 depending
#upon how the data are scaled. Thus a value greater than 1 or greater than 10,000
#is likely caused by an error in either data collection or processing.

### Find Bad Data Values

#Sometimes a raster metadata will tell us the range of expected values 
#for a raster. Values outside of this range are suspect and we need to consider that
#when we analyze the data. Sometimes, we need to use some common sense and
#scientific insight as we examine the data - just as we would for field data to
#identify questionable values.

#Plotting data with appropriate highlighting can help reveal patterns in bad
#values and may suggest a solution. Below, reclassification is used to highlight
#elevation values over 400m with a contrasting colour.

# reclassify raster to ok/not ok
DSM_highvals <- reclassify(DSM_HARV, rcl = c(0, 400, NA_integer_, 400, 420, 1L), include.lowest = TRUE)
DSM_highvals <- as.data.frame(DSM_highvals, xy = TRUE)
DSM_highvals <- DSM_highvals[!is.na(DSM_highvals$HARV_dsmCrop), ]

ggplot() +
  geom_raster(data = DSM_HARV_df, aes(x = x, y = y, fill = HARV_dsmCrop)) + 
  scale_fill_viridis_c() + 
  # use reclassified raster data as an annotation
  annotate(geom = 'raster', x = DSM_highvals$x, y = DSM_highvals$y, fill = scales::colour_ramp('deeppink')(DSM_highvals$HARV_dsmCrop)) +
  ggtitle("Elevation Data", subtitle = "Highlighting values > 400m") +
  coord_quickmap()

# memory saving
rm(DSM_highvals)


## Create A Histogram of Raster Values

#We can explore the distribution of values contained within our raster using the
#`geom_histogram()` function which produces a histogram. Histograms are often
#useful in identifying outliers and bad data values in our raster data.

ggplot() +
    geom_histogram(data = DSM_HARV_df, aes(HARV_dsmCrop))


#Notice that a warning message is thrown when R creates the histogram.

#`stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

#This warning is caused by a default setting in `geom_histogram` enforcing that there are
#30 bins for the data. We can define the number of bins we want in the histogram
#by using the `bins` value in the `geom_histogram()` function.


ggplot() +
    geom_histogram(data = DSM_HARV_df, aes(HARV_dsmCrop), bins = 40)



#Note that the shape of this histogram looks similar to the previous one that
#was created using the default of 30 bins. The distribution of elevation values
#for our `Digital Surface Model (DSM)` looks reasonable. It is likely there are
#no bad data values in this particular raster.

## Challenge: Explore Raster Metadata

#Use `GDALinfo()` to determine the following about the `NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif` file:

#1. Does this file have the same CRS as `DSM_HARV`?
#2. What is the `NoDataValue`?
#3. What is resolution of the raster data?
#4. How large would a 5x5 pixel area be on the Earth's surface?
#5. Is the file a multi- or single-band raster?

#Notice: this file is a hillshade. We will learn about hillshades in the [Working with
#Multi-band Rasters in R]({{ site.baseurl }}/05-raster-multi-band-in-r/)  episode.

## Answers

GDALinfo("data/NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_DSMhill.tif")


#1. If this file has the same CRS as DSM_HARV?  Yes: UTM Zone 18, WGS84, meters.
#2. What format `NoDataValues` take?  -9999
#3. The resolution of the raster data? 1x1
#4. How large a 5x5 pixel area would be? 5mx5m How? We are given resolution of 1x1 and units in meters, therefore resolution of 5x5 means 5x5m.
#5. Is the file a multi- or single-band raster?  Single.


