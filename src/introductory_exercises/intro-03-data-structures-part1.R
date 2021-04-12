#Title: intro-03-data-structures-part1.R
#BCB503 Geospatial Workshop, April 23 and 24th, 2020
#University of Idaho
#Data Carpentry Geospatial Analysis
#Instructors: Erich Seamon, University of Idaho - Travis Seaborn, University of Idaho


#load the nordic-data csv.  

nordic <- read.csv("../data/nordic-data.csv")


#We can begin exploring our dataset right away, pulling out columns by specifying
#them using the `$` operator:


nordic$country
nordic$lifeExp


#We can do other operations on the columns. For example, if we discovered that the life expectancy is two years higher: 

nordic$lifeExp + 2

#But what about:

nordic$lifeExp + nordic$country


#Understanding what happened here is key to successfully analyzing data in R.

## Data Types

#If you guessed that the last command will return an error because `77.2` plus
#`"Denmark"` is nonsense, you're right - and you already have some intuition for an
#important concept in programming called *data classes*. We can ask what class of
#data something is:


class(nordic$lifeExp)


#There are 6 main types: `numeric`, `integer`, `complex`, `logical`, `character`, and `factor`.


class(3.14)
class(1L) # The L suffix forces the number to be an integer, since by default R uses float numbers
class(1+1i)
class(TRUE)
class('banana')
class(factor('banana'))


#Load the new nordic data as `nordic_2`, and check what class of data we find in the
#`lifeExp` column:


nordic_2 <- read.csv("../data/nordic-data-2.csv")
class(nordic_2$lifeExp)


#Oh no, our life expectancy lifeExp aren't the numeric type anymore! If we try to do the same math
#we did on them before, we run into trouble:


nordic_2$lifeExp + 2


#What happened? When R reads a csv file into one of these tables, it insists that
#everything in a column be the same class; if it can't understand
#*everything* in the column as numeric, then *nothing* in the column gets to be numeric. The table that R loaded our nordic data into is something called a
#dataframe, and it is our first example of something called a *data
#structure* - that is, a structure which R knows how to build out of the basic
#data types.

#We can see that it is a dataframe by calling the `class()` function on it:

class(nordic)

#In order to successfully use our data in R, we need to understand what the basic
#data structures are, and how they behave. 

## Vectors and Type Coercion

#To better understand this behavior, let's meet another of the data structures:
#the vector.


my_vector <- vector(length = 3)
my_vector


#A vector in R is essentially an ordered list of things, with the special
#condition that everything in the vector must be the same basic data type. If
#you don't choose the data type, it'll default to `logical`; or, you can declare
#an empty vector of whatever type you like.


another_vector <- vector(mode = 'character', length = 3)
another_vector


#You can check if something is a vector:


str(another_vector)


#The somewhat cryptic output from this command indicates the basic data type
#found in this vector - in this case `chr`, character; an indication of the
#number of things in the vector - actually, the indexes of the vector, in this
#case `[1:3]`; and a few examples of what's actually in the vector - in this case
#empty character strings. If we similarly do


str(nordic$lifeExp)


#You can also make vectors with explicit contents with the combine function:

combine_vector <- c(2, 6, 3)
combine_vector


#Given what we've learned so far, what do you think the following will produce?


quiz_vector <- c(2, 6, '3')


#This is something called *type coercion*, and it is the source of many surprises
#and the reason why we need to be aware of the basic data types and how R will
#interpret them. When R encounters a mix of types (here numeric and character) to
#be combined into a single vector, it will force them all to be the same
#type. Consider:

coercion_vector <- c('a', TRUE)
coercion_vector
another_coercion_vector <- c(0, TRUE)
another_coercion_vector


#The coercion rules go: `logical` -> `integer` -> `numeric` -> `complex` ->
#`character`, where -> can be read as *are transformed into*. You can try to
#force coercion against this flow using the `as.` functions:


character_vector_example <- c('0', '2', '4')
character_vector_example
character_coerced_to_numeric <- as.numeric(character_vector_example)
character_coerced_to_numeric
numeric_coerced_to_logical <- as.logical(character_coerced_to_numeric)
numeric_coerced_to_logical


#As you can see, some surprising things can happen when R forces one basic data
#type into another! Nitty-gritty of type coercion aside, the point is: if your
#data doesn't look like what you thought it was going to look like, type coercion
#may well be to blame; make sure everything is the same type in your vectors and
#your columns of data frames, or you will get nasty surprises!

## Challenge 1
 
#Given what you now know about type conversion, look at the class of
#data in `nordic_2$lifeExp` and compare it with `nordic$lifeExp`. Why are
#these columns different classes? 

## Solution

str(nordic_2$lifeExp)
str(nordic$lifeExp)


#The data in `nordic_2$lifeExp` is stored as factors rather than 
#numeric. This is because of the "or" character string in the third 
#data point. "Factor" is R's special term for categorical data. 
#We will be working more with factor data later in this workshop.

#The combine function, `c()`, will also append things to an existing vector:


ab_vector <- c('a', 'b')
ab_vector
combine_example <- c(ab_vector, 'DC')
combine_example


#You can also make series of numbers:


my_series <- 1:10
my_series
seq(10)
seq(1,10, by = 0.1)


#We can ask a few questions about vectors:


sequence_example <- seq(10)
head(sequence_example,n = 2)
tail(sequence_example, n = 4)
length(sequence_example)
class(sequence_example)


#Finally, you can give names to elements in your vector:


my_example <- 5:8
names(my_example) <- c("a", "b", "c", "d")
my_example
names(my_example)


## Challenge 2

#Start by making a vector with the numbers 1 through 26.
#Multiply the vector by 2, and give the resulting vector
#names A through Z (hint: there is a built in vector called `LETTERS`)

## Solution to Challenge 2


x <- 1:26
x <- x * 2
names(x) <- LETTERS


## Factors

#We said that columns in data frames were vectors:


str(nordic$lifeExp)
str(nordic$year)


#These make sense. But what about


str(nordic$country)


#Another important data structure is called a factor. Factors look like character
#data, but are used to represent categorical information. For example, let's make
#a vector of strings labeling nordic countries for all the countries in our
#study:


nordic_countries <- c('Norway', 'Finland', 'Denmark', 'Iceland', 'Sweden')
nordic_countries
str(nordic_countries)


#We can turn a vector into a factor like so:


categories <- factor(nordic_countries)
class(categories)
str(categories)


#Now R has noticed that there are 5 possible categories in our data - but it
#also did something surprising; instead of printing out the strings we gave it,
#we got a bunch of numbers instead. R has replaced our human-readable categories
#with numbered indices under the hood, this is necessary as many statistical
#calculations utilise such numerical representations for categorical data:


class(nordic_countries)
class(categories)


## Challenge

#Can you guess why these numbers are used to represent these countries?

## Solution
 
#They are sorted in alphabetical order

## Challenge 3

#Is there a factor in our `nordic` data frame? what is its name? Try using
#`?read.csv` to figure out how to keep text columns as character vectors
#instead of factors; then write a command or two to show that the factor in
#`nordic` is actually a character vector when loaded in this way.

## Solution to Challenge 3

#One solution is use the argument `stringAsFactors`:


nordic <- read.csv(file = "data/nordic-data.csv", stringsAsFactors = FALSE)
str(nordic$country)


#Another solution is use the argument `colClasses`
#that allow finer control.


nordic <- read.csv(file="data/nordic-data.csv", colClasses=c(NA, NA, "character"))
str(nordic$country)


#Note: new students find the help files difficult to understand; make sure to let them know
#that this is typical, and encourage them to take their best guess based on semantic meaning,
#even if they aren't sure.

#When doing statistical modelling, it's important to know what the baseline
#levels are. This is assumed to be the first factor, but by default factors are
#labeled in alphabetical order. You can change this by specifying the levels:

mydata <- c("case", "control", "control", "case")
factor_ordering_example <- factor(mydata, levels = c("control", "case"))
str(factor_ordering_example)


#In this case, we've explicitly told R that "control" should represented by 1,
#and "case" by 2. This designation can be very important for interpreting the
#results of statistical models!

## Lists

#Another data structure you'll want in your bag of tricks is the `list`. A list
#is simpler in some ways than the other types, because you can put anything you
#want in it:


list_example <- list(1, "a", TRUE, c(2, 6, 7))
list_example
another_list <- list(title = "Numbers", numbers = 1:10, data = TRUE )
another_list


#We can now understand something a bit surprising in our data frame; what happens if we compare `str(nordic)` and `str(another_list)`:


str(nordic)
str(another_list)


#We see that the output for these two objects look very similar. It is because
#data frames are lists 'under the hood'. Data frames are a special case of lists where each element (the columns of the data frame) have the same lengths.

#In our `nordic` example, we have an integer, a double and a logical variable. As
#we have seen already, each column of data frame is a vector.

nordic$country
nordic[, 1]
class(nordic[, 1])
str(nordic[, 1])


#Each row is an *observation* of different variables, itself a data frame, and
#thus can be composed of elements of different types.

nordic[1, ]
class(nordic[1, ])
str(nordic[1, ])


## Challenge 4

#There are several subtly different ways to call variables, observations and
#elements from data frames:

nordic[1]
nordic[[1]]
nordic$country
nordic["country"]
nordic[1, 1]
nordic[, 1]
nordic[1, ]

#Try out these examples and explain what is returned by each one.

#*Hint:* Use the function `class()` to examine what is returned in each case.

## Solution to Challenge 4

nordic[1]

#We can think of a data frame as a list of vectors. The single brace `[1]`
#returns the first slice of the list, as another list. In this case it is the
#first column of the data frame.

nordic[[1]]

#The double brace `[[1]]` returns the contents of the list item. In this case
#it is the contents of the first column, a _vector_ of type _factor_.

nordic$country

#This example uses the `$` character to address items by name. _coat_ is the
#first column of the data frame, again a _vector_ of type _factor_.

nordic["country"]


#Here we are using a single brace `["country"]` replacing the index number
#with the column name. Like example 1, the returned object is a _list_.

nordic[1, 1]

#This example uses a single brace, but this time we provide row and column
#coordinates. The returned object is the value in row 1, column 1. The object
#is an _integer_ but because it is part of a _vector_ of type _factor_, R
#displays the label "Denmark" associated with the integer value.

nordic[, 1]

#Like the previous example we use single braces and provide row and column
#coordinates. The row coordinate is not specified, R interprets this missing
#value as all the elements in this _column_ _vector_.

nordic[1, ]

#Again we use the single brace with row and column coordinates. The column
#coordinate is not specified. The return value is a _list_ containing all the
#values in the first row.

