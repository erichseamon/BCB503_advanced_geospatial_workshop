##03: Fit several models, one for each location, by geographically weighted regression (GWR)
library(spgwr)

# Set working directory
setwd(file.path(Sys.getenv("USERPROFILE"),"Desktop\\d3-sr\\data"))

# Read Puerto Rico farm data
pr.f <- read.csv(file="PR-farm-data.csv")

# Calculate irrigated farm density in 2007
ifarm.den07 <- pr.f$irr_farms_07/pr.f$area
# Transform the density to normal distribution
y <- log(ifarm.den07 + 0.04)
# Get mean rainfall
rain <- pr.f$rain_mean
# Append variables into data
pr.f$y <- y
pr.f$rain <- rain

# Find a global fixed bandwidth for GWR by cross-validation
bw <- gwr.sel(y ~ rain, data=pr.f, coords=cbind(pr.f$long, pr.f$lat), 
              adapt=FALSE, gweight=gwr.Gauss, method="cv")
#bw <- gwr.sel(y ~ rain, data=pr.f, coords=cbind(pr.f$long, pr.f$lat), 
#              adapt=FALSE, gweight = gwr.bisquare, method = "aic")
bw

# Run GWR
gauss <- gwr(y ~ rain, data=pr.f, coords=cbind(pr.f$long, pr.f$lat), 
             bandwidth = bw, gweight = gwr.Gauss, hatmatrix = TRUE)
#gauss <- gwr(y ~ rain, data=pr.f, coords=cbind(pr.f$long, pr.f$lat), 
#             bandwidth = bw, gweight = gwr.bisquare, hatmatrix = TRUE)
gauss

# Find adaptive bandwith for GWR
adapt.gauss <- gwr.sel(y ~ rain, data=pr.f, coords=cbind(pr.f$long, pr.f$lat), 
                       adapt=TRUE, gweight=gwr.Gauss, method="cv")
adapt.gauss

# Run GWR
res.adapt <- gwr(y ~ rain, data=pr.f, coords=cbind(pr.f$long, pr.f$lat), adapt=adapt.gauss)
res.adapt
