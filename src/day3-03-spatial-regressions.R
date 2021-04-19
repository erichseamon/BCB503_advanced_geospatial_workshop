#Title: day3-03-spatial-regressions.R
#BCB503 Geospatial Workshop, April 20th, 22nd, 27th, and 29th, 2021
#University of Idaho
#Data Carpentry Advanced Geospatial Analysis
#Instructors: Erich Seamon, University of Idaho - Li Huang, University of Idaho


##02:spatial lag model, spatial error model, and model selection
library(spdep)
library(spatialreg)
library(maptools)

# Set working directory
#setwd(file.path(Sys.getenv("USERPROFILE"),"Desktop\\d3-sr\\data"))
setwd("/mnt/lfs2/erichs/git/BCB503_advanced_geospatial_workshop/data/Puerto-Rico-Farm/")
dataFolder<-"data/Puerto-Rico-Farm/"

# Read Puerto Rico farm data
pr.f <- read.csv(file=paste0(dataFolder, "PR-farm-data.csv"))


# Calculate irrigated farm density in 2007
ifarm.den07 <- pr.f$irr_farms_07/pr.f$area
# Transform the density to normal distribution
y <- log(ifarm.den07 + 0.04)
# Get mean rainfall
rain <- pr.f$rain_mean

# Read spatial neighbor information
pr.nb <- spdep::read.gal("PuertoRico.gal")
# Generate listw object with W and B styles
pr.listw <- nb2listw(pr.nb, style="W")
pr.listb <- nb2listw(pr.nb, style="B")

# Run linear regression and summarize the results
if.lm <- lm(y ~ rain)
summary(if.lm)
# Conduct a normality test
shapiro.test(resid(if.lm))
# Test spatial autocorrelation among the regression residuals
lm.morantest(if.lm, pr.listw)

# Run a spatial lag model and summarize the results
if.sar <- spatialreg::lagsarlm(y ~ rain, listw = pr.listw)
#if.sar <- lagsarlm(y ~ rain, listw = pr.listw)
summary(if.sar)
# Get residuals and conduct normality test
if.sar.res <- residuals(if.sar)
shapiro.test(if.sar.res)
# Test spatial autocorrelation among the regression residuals
moran.test(if.sar.res, pr.listw)
#lm.morantest(if.sar, pr.listw)

# Run a spatial error model and summarize the results
if.sem <- spatialreg::errorsarlm(y ~ rain, listw = pr.listw)
#if.sem <- errorsarlm(y ~ rain, listw = pr.listw)
summary(if.sem)
# Get residuals and conduct normality test
if.sem.res <- residuals(if.sem)
shapiro.test(if.sem.res)
# Test spatial autocorrelation among the regression residuals
moran.test(if.sem.res, pr.listw)
#lm.morantest(if.sem, pr.listw)

# Model selection by Lagrange Multiplier test
lm.LMtests(if.lm, pr.listw, test = "all")

