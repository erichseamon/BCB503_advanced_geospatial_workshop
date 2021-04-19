#Title: intro-08-writing-data.R
#BCB503 Geospatial Workshop, April 20th, 22nd, 27th, and 29th, 2021
#University of Idaho
#Data Carpentry Advanced Geospatial Analysis
#Instructors: Erich Seamon, University of Idaho - Li Huang, University of Idaho


# Silently load in the data so the rest of the lesson works

library(ggplot2)
library(dplyr)

gapminder <- read.csv("data/gapminder_data.csv", header=TRUE)

# load data that learners created in previous episode

gapminder_small_2 <- filter(gapminder, continent == "Americas", year %in% c(1952, 2007))

# Temporarily create a cleaned-data directory so that the writing examples work
# The students should have created this in topic 2.

dir.create("cleaned-data")


## Saving plots


pdf("Distribution-of-gdpPercap.pdf", width=12, height=4)
ggplot(data = gapminder, aes(x = gdpPercap)) +   
  geom_histogram()

#You then have to make sure to turn off the pdf device!

dev.off()


#Open up this document and have a look.

## Challenge 1

#Rewrite your 'pdf' command to print a second
#page in the pdf, showing the side-by-side bar
#plot of gdp per capita in countries in the Americas
#in the years 1952 and 2007 that you created in the 
#previous episode. 

## Solution to challenge 1

pdf("Distribution-of-gdpPercap.pdf", width = 12, height = 4)
ggplot(data = gapminder, aes(x = gdpPercap)) + 
geom_histogram()
 
ggplot(data = gapminder_small_2, aes(x = country, y = gdpPercap, fill = as.factor(year))) +
geom_col(position = "dodge") + coord_flip()
 
dev.off()




#The commands `jpeg`, `png` etc. are used similarly to produce
#documents in different formats.

## Writing data

#At some point, you'll also want to write out data from R.

#We can use the `write.csv` function for this, which is
#very similar to `read.csv` from before.

#Let's create a data-cleaning script, for this analysis, we
#only want to focus on the gapminder data for Australia:

aust_subset <- filter(gapminder, country == "Australia")

write.csv(aust_subset,
  file="cleaned-data/gapminder-aus.csv"
)


#Let's look at the help file to work out how to change this
#behaviour.

?write.csv


#By default R will write out the row and
#column names when writing data to a file.
#To over write this behavior, we can do the following:

write.csv(
  aust_subset,
  file="cleaned-data/gapminder-aus.csv",
  row.names=FALSE
)


## Challenge 2

#Subset the gapminder
#data to include only data points collected since 1990. Write out the new subset to a file
#in the `cleaned-data/` directory.

## Solution to challenge 2


gapminder_after_1990 <- filter(gapminder, year > 1990)
 
write.csv(gapminder_after_1990,
 file = "cleaned-data/gapminder-after-1990.csv",
   row.names = FALSE)


# We remove after rendering the lesson, because we don't want this in the lesson
# repository

unlink("cleaned-data", recursive=TRUE)

