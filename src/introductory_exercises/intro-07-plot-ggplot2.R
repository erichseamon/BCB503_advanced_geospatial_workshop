#Title: intro-07-ggplot2.R
#BCB503 Geospatial Workshop, April 20th, 22nd, 27th, and 29th, 2021
#University of Idaho
#Data Carpentry Advanced Geospatial Analysis
#Instructors: Erich Seamon, University of Idaho - Li Huang, University of Idaho


# Silently load in the data so the rest of the lesson works

gapminder <- read.csv("data/gapminder_data.csv", header = TRUE)

# load libraries that learners will already have
# loaded from previous episodes

library(dplyr)



ggplot(data = gapminder, aes(x = lifeExp)) +   
  geom_histogram()

#By itself, the call to `ggplot` isn't enough to draw a figure:


ggplot(data = gapminder, aes(x = lifeExp))


#We need to tell `ggplot` how we want to visually represent the data, which we
#do by adding a geom layer. In our example, we used `geom_histogram()`, which
#tells `ggplot` we want to visually represent the
#distribution of one variable (in our case "lifeExp"):

ggplot(data = gapminder, aes(x = lifeExp)) +   
  geom_histogram()

## Challenge 1

#Modify the example so that the figure shows the 
#distribution of gdp per capita, rather than life 
#expectancy:

## Solution to challenge 1

ggplot(data = gapminder, aes(x = gdpPercap)) +   
  geom_histogram()



#The histogram is a useful tool for visualizing the 
#distribution of a single categorical variable. What if
#we want to compare the gdp per capita of the countries in 
#our dataset? We can use a bar (or column) plot. 
#To simplify our plot, let's look at data only from the most 
#recent year and only
#from countries in the Americas.

gapminder_small <- filter(gapminder, year == 2007, continent == "Americas")


#This time, we will use the `geom_col()` function as our geometry. 
#We will plot countries on the x-axis (listed in alphabetic order
#by default) and gdp per capita on the y-axis.

ggplot(data = gapminder_small, aes(x = country, y = gdpPercap)) + 
  geom_col()


#With this many bars plotted, it's impossible to read all of the 
#x-axis labels. A quick fix to this is the add the `coord_flip()` 
#function to the end of our plot code.

ggplot(data = gapminder_small, aes(x = country, y = gdpPercap)) + 
  geom_col() +
  coord_flip()


#There are more sophisticated ways of modifying axis
#labels. We will be learning some of those methods
#later in this workshop.

## Challenge 2

#In the previous examples and challenge we've used the `aes` function to tell
#the `geom_histogram()` and `geom_col()` functions which columns 
#of the 
#data set to plot.
#Another aesthetic property we can modify is the
#color. Create a new bar (column) plot showing the gdp per capita
#of all countries in the Americas for the years 1952 and 2007, 
#color coded by year.

## Solution to challenge 2

#First we create a new object with 
#our filtered data: 
 
gapminder_small_2 <- gapminder %>%
                        filter(continent == "Americas",
                               year %in% c(1952, 2007))


#Then we plot that data using the `geom_col()`
#geom function. We color bars using the `fill`
#parameter within the `aes()` function. 
#Since there are multiple bars for each 
#country, we use the `position` parameter
#to "dodge" them so they appear side-by-side. 
#The default behavior for `postion` in `geom_col()`
#is "stack".
 
ggplot(gapminder_small_2, 
        aes(x = country, y = gdpPercap, 
        fill = as.factor(year))) +
    geom_col(position = "dodge") + 
    coord_flip()

