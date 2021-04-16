#Title: intro-04-structures-part2.R
#BCB503 Geospatial Workshop, April 23 and 24th, 2020
#University of Idaho
#Data Carpentry Geospatial Analysis
#Instructors: Erich Seamon, University of Idaho - Travis Seaborn, University of Idaho


#So far, you have seen the basics of manipulating data frames with our nordic data; now let’s use those skills to digest a more extensive dataset. Let’s read in the gapminder dataset that we downloaded previously:

gapminder <- read.csv("../data/gapminder_data.csv")


#Files can also be downloaded directly from the Internet into a local folder
#of your choice onto your computer using the `download.file` function. The
#`read.csv` function can then be executed to read the downloaded file from the
#download location, for example,


download.file("https://raw.githubusercontent.com/datacarpentry/r-intro-geospatial/master/_episodes_rmd/data/gapminder_data.csv",
              destfile = "../data/gapminder_data.csv")
gapminder <- read.csv("../data/gapminder_data.csv")


#Alternatively, you can also read in files directly into R

gapminder <- read.csv("https://raw.githubusercontent.com/datacarpentry/r-intro-geospatial/master/_episodes_rmd/data/gapminder_data.csv")

#You can read directly from excel spreadsheets without
#converting them to plain text first by using the readxl package.


#Let's investigate the `gapminder` data frame a bit; the first thing we should
#always do is check out what the data looks like with `str`:

str(gapminder)


#We can also examine individual columns of the data frame with our `class` function:


class(gapminder$year)
class(gapminder$country)
str(gapminder$country)


#We can also interrogate the data frame for information about its dimensions;
#remembering that `str(gapminder)` said there were 1704 observations of 6
#variables in gapminder, what do you think the following will produce, and why?

length(gapminder)


#A fair guess would have been to say that the length of a data frame would be the
#number of rows it has (1704), but this is not the case; it gives us the number of columns.

class(gapminder)


#To get the number of rows and columns in our dataset, try:


nrow(gapminder)
ncol(gapminder)


#Or, both at once:


dim(gapminder)


#We'll also likely want to know what the titles of all the columns are, so we can
#ask for them later:

colnames(gapminder)

#At this stage, it's important to ask ourselves if the structure R is reporting
#matches our intuition or expectations; do the basic data types reported for each
#column make sense? If not, we need to sort any problems out now before they turn
#into bad surprises down the road, using what we've learned about how R
#interprets data, and the importance of *strict consistency* in how we record our
#data.

#Once we're happy that the data types and structures seem reasonable, it's time
#to start digging into our data proper. Check out the first few lines:

head(gapminder)


## Challenge 1

#It's good practice to also check the last few lines of your data and some in
#the middle. How would you do this?

#Searching for ones specifically in the middle isn't too hard but we could
#simply ask for a few lines at random. How would you code this?

## Solution to Challenge 1

#To check the last few lines it's relatively simple as R already has a
#function for this:

tail(gapminder)
tail(gapminder, n = 15)

#What about a few arbitrary rows just for sanity (or insanity depending on
#your view)?

#There are several ways to achieve this.

#The solution here presents one form using nested functions. i.e. a function
#passed as an argument to another function. This might sound like a new
#concept but you are already using it in fact.

#Remember `my_dataframe[rows, cols]` will print to screen your data frame
#with the number of rows and columns you asked for (although you might 
#have asked for a range or named columns for example). How would you get the
#last row if you don't know how many rows your data frame has? R has a
#function for this. What about getting a (pseudorandom) sample? R also has a
#function for this.

gapminder[sample(nrow(gapminder), 5), ]


## Challenge 2

#Read the output of `str(gapminder)` again; this time, use what you've learned
#about factors and vectors, as well as the output of functions like `colnames`
#and `dim` to explain what everything that `str` prints out for `gapminder`
#means. If there are any parts you can't interpret, discuss with your
#neighbors!

## Solution to Challenge 2

#The object `gapminder` is a data frame with columns

#`country` and `continent` are factors.
#`year` is an integer vector.
#`pop`, `lifeExp`, and `gdpPercap` are numeric vectors.


## Adding columns and rows in data frames

#We would like to create a new column to hold information on whether the life expectancy is below the world average life expectancy (70.5) or above:


below_average <- gapminder$lifeExp < 70.5
head(gapminder)


#We can then add this as a column via:

cbind(gapminder, below_average)


head(cbind(gapminder, below_average))


#We probably don't want to print the entire dataframe each time, so
#let's put our `cbind` command within a call to `head` to return
#only the first six lines of the output.

head(cbind(gapminder, below_average))


#Note that if we tried to add a vector of `below_average` with a different number of entries than the number of rows in the dataframe, it would fail:


below_average <- c(TRUE, TRUE, TRUE, TRUE, TRUE)
head(cbind(gapminder, below_average))


#Why didn't this work? R wants to see one element in our new column
#for every row in the table:


nrow(gapminder)
length(below_average)


#So for it to work we need either to have `nrow(gapminder)` = `length(below_average)` or `nrow(gapminder)` to be a multiple of `length(below_average)`: 


below_average <- c(TRUE, TRUE, FALSE)
head(cbind(gapminder, below_average))

#The sequence `TRUE,TRUE,FALSE` is repeated over all the gapminder rows.

#Let's overwite the content of gapminder with our new data frame.


below_average <-  as.logical(gapminder$lifeExp<70.5)
gapminder <- cbind(gapminder, below_average)


#Now how about adding rows? The rows of a data frame are lists:


new_row <- list('Norway', 2016, 5000000, 'Nordic', 80.3, 49400.0, FALSE)
gapminder_norway <- rbind(gapminder, new_row)
tail(gapminder_norway)


#To understand why R is giving us a warning when we try to add this row, let's learn a little more about factors.

## Factors

#Here is another thing to look out for: in a `factor`, each different value
#represents what is called a `level`. In our case, the `factor` "continent" has 5
#levels: "Africa", "Americas", "Asia", "Europe" and "Oceania". R will only accept
#values that match one of the levels. If you add a new value, it will become
#`NA`.

#The warning is telling us that we unsuccessfully added "Nordic" to our
#*continent* factor, but 2016 (a numeric), 5000000 (a numeric), 80.3 (a numeric),
#49400.0 (a numeric) and `FALSE` (a logical) were successfully added to
#*country*, *year*, *pop*, *lifeExp*, *gdpPercap* and *below_average*
#respectively, since those variables are not factors. 'Norway' was also
#successfully added since it corresponds to an existing level. To successfully
#add a gapminder row with a "Nordic" *continent*, add "Nordic" as a *level* of
#the factor:


levels(gapminder$continent)
levels(gapminder$continent) <- c(levels(gapminder$continent), "Nordic")
gapminder_norway  <- rbind(gapminder,
                           list('Norway', 2016, 5000000, 'Nordic', 80.3,49400.0, FALSE))
tail(gapminder_norway)


#Alternatively, we can change a factor into a character vector; we lose the handy
#categories of the factor, but we can subsequently add any word we want to the
#column without babysitting the factor levels:


str(gapminder)
gapminder$continent <- as.character(gapminder$continent)
str(gapminder)


## Appending to a data frame

#The key to remember when adding data to a data frame is that *columns are
#vectors and rows are lists.* We can also glue two data frames together with
#`rbind`:


gapminder <- rbind(gapminder, gapminder)
tail(gapminder, n=3)

#But now the row names are unnecessarily complicated (not consecutive numbers).
#We can remove the rownames, and R will automatically re-name them sequentially:


rownames(gapminder) <- NULL
head(gapminder)


## Challenge 3

#You can create a new data frame right from within R with the following syntax:

df <- data.frame(id = c("a", "b", "c"),
                 x = 1:3,
                  y = c(TRUE, TRUE, FALSE),
                 stringsAsFactors = FALSE)


 #Make a data frame that holds the following information for yourself:

# - first name
# - last name
# - lucky number

 #Then use `rbind` to add an entry for the people sitting beside you. Finally,
 #use `cbind` to add a column with each person's answer to the question, "Is it
 #time for coffee break?"

## Solution to Challenge 3



df <- data.frame(first = c("Grace"),
                  last = c("Hopper"),
                 lucky_number = c(0),
                  stringsAsFactors = FALSE)
df <- rbind(df, list("Marie", "Curie", 238) )
df <- cbind(df, coffeetime = c(TRUE, TRUE))


