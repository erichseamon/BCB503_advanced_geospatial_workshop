#Title: intro-05-data-subsetting.R
#BCB503 Geospatial Workshop, April 20th, 22nd, 27th, and 29th, 2021
#University of Idaho
#Data Carpentry Advanced Geospatial Analysis
#Instructors: Erich Seamon, University of Idaho - Li Huang, University of Idaho


# Silently load in the data so the rest of the lesson works
gapminder <- read.csv("data/gapminder_data.csv", header=TRUE)



#Let's start with the workhorse of R: a simple numeric vector.


x <- c(5.4, 6.2, 7.1, 4.8, 7.5)
names(x) <- c('a', 'b', 'c', 'd', 'e')
x



#In R, simple vectors containing character strings, numbers, or logical values
#are called *atomic* vectors because they can't be further simplified.


#So now that we've created a dummy vector to play with, how do we get at its
#contents?

## Accessing elements using their indices

#To extract elements of a vector we can give their corresponding index, starting
#from one:

x[1]


x[4]

#It may look different, but the square brackets operator is a function. For vectors
#(and matrices), it means "get me the nth element".

#We can ask for multiple elements at once:

x[c(1, 3)]


#Or slices of the vector:

x[1:4]


#the `:` operator creates a sequence of numbers from the left element to the right.

1:4
c(1, 2, 3, 4)



#We can ask for the same element multiple times:

x[c(1, 1, 3)]

#If we ask for an index beyond the length of the vector, R will return a missing value:

x[6]


#This is a vector of length one containing an `NA`, whose name is also `NA`.

#If we ask for the 0th element, we get an empty vector:


x[0]


## Vector numbering in R starts at 1

#In many programming languages (C and Python, for example), the first
#element of a vector has an index of 0. In R, the first element is 1.

## Skipping and removing elements

#If we use a negative number as the index of a vector, R will return
#every element *except* for the one specified:


x[-2]


#We can skip multiple elements:


x[c(-1, -5)]  # or x[-c(1,5)]


## Tip: Order of operations

#A common trip up for novices occurs when trying to skip
#slices of a vector. It's natural to to try to negate a
#sequence like so:

x[-1:3]


#This gives a somewhat cryptic error:

x[-1:3]


#But remember the order of operations. `:` is really a function.
#It takes its first argument as -1, and its second as 3,
#so generates the sequence of numbers: `c(-1, 0, 1, 2, 3)`.

#The correct solution is to wrap that function call in brackets, so
#that the `-` operator applies to the result:


x[-(1:3)]




#To remove elements from a vector, we need to assign the result back
#into the variable:


x <- x[-4]
x


## Challenge 1

#Given the following code:


x <- c(5.4, 6.2, 7.1, 4.8, 7.5)
names(x) <- c('a', 'b', 'c', 'd', 'e')
print(x)


#Come up with at least 3 different commands that will produce the following output:

x[2:4]


#After you find 3 different commands, compare notes with your neighbour. Did you have different strategies?

## Solution to challenge 1


x[2:4]



x[-c(1,5)]



x[c("b", "c", "d")]



x[c(2,3,4)]



## Subsetting by name

#We can extract elements by using their name, instead of extracting by index:


x <- c(a = 5.4, b = 6.2, c = 7.1, d = 4.8, e = 7.5) # we can name a vector 'on the fly'
x[c("a", "c")]


#This is usually a much more reliable way to subset objects: the
#position of various elements can often change when chaining together
#subsetting operations, but the names will always remain the same!

## Subsetting through other logical operations

#We can also use any logical vector to subset:


x[c(FALSE, FALSE, TRUE, FALSE, TRUE)]


#Since comparison operators (e.g. `>`, `<`, `==`) evaluate to logical vectors, we can also
#use them to succinctly subset vectors: the following statement gives
#the same result as the previous one.


x[x > 7]


#Breaking it down, this statement first evaluates `x>7`, generating
#a logical vector `c(FALSE, FALSE, TRUE, FALSE, TRUE)`, and then
#selects the elements of `x` corresponding to the `TRUE` values.

#We can use `==` to mimic the previous method of indexing by name
#(remember you have to use `==` rather than `=` for comparisons):


x[names(x) == "a"]


## Tip: Combining logical conditions

#We often want to combine multiple logical
#criteria. For example, we might want to find all the countries that are
#located in Asia **or** Europe **and** have life expectancies within a certain
#range. Several operations for combining logical vectors exist in R


## Challenge 2

#Given the following code:


x <- c(5.4, 6.2, 7.1, 4.8, 7.5)
names(x) <- c('a', 'b', 'c', 'd', 'e')
print(x)


#Write a subsetting command to return the values in x that are greater than 4 and less than 7.

## Solution to challenge 2


x_subset <- x[x<7 & x>4]
print(x_subset)



## Tip: Getting help for operators

#Remember you can search for help on operators by wrapping them in quotes:
#`help("%in%")` or `?"%in%"`.


## Handling special values
#At some point you will encounter functions in R that cannot handle missing, infinite,
#or undefined data.

#There are a number of special functions you can use to filter out this data:

#* `is.na` will return all positions in a vector, matrix, or data frame
#  containing `NA` (or `NaN`)
#* likewise, `is.nan`, and `is.infinite` will do the same for `NaN` and `Inf`.
#* `is.finite` will return all positions in a vector, matrix, or data.frame
#  that do not contain `NA`, `NaN` or `Inf`.
#* `na.omit` will filter out all missing values from a vector


## Data frames

#Remember the data frames are lists underneath the hood, so similar rules
#apply. However they are also two dimensional objects:

#`[` with one argument will act the same way as for lists, where each list
#element corresponds to a column. The resulting object will be a data frame:


head(gapminder[3])


#Similarly, `[[` will act to extract *a single column*:


head(gapminder[["lifeExp"]])


#And `$` provides a convenient shorthand to extract columns by name:


head(gapminder$year)


#To select specific rows and/or columns, you can provide two arguments to `[` 


gapminder[1:3, ]


#If we subset a single row, the result will be a data frame (because
#the elements are mixed types):


gapminder[3, ]


#But for a single column the result will be a vector (this can be changed with
#the third argument, `drop = F0ALSE`).

## Challenge 3

#Fix each of the following common data frame subsetting errors:

#1. Extract observations collected for the year 1957


gapminder[gapminder$year = 1957, ]


#2. Extract all columns except 1 through to 4


gapminder[, -1:4]


#3. Extract the rows where the life expectancy is longer the 80 years


gapminder[gapminder$lifeExp > 80]


#4. Extract the first row, and the fourth and fifth columns
#  (`lifeExp` and `gdpPercap`).


gapminder[1, 4, 5]

#5. Advanced: extract rows that contain information for the years 2002
#    and 2007


gapminder[gapminder$year == 2002 | 2007,]


## Solution to challenge 3

#Fix each of the following common data frame subsetting errors:

#1. Extract observations collected for the year 1957


# gapminder[gapminder$year = 1957, ]
gapminder[gapminder$year == 1957, ]


#2. Extract all columns except 1 through to 4


# gapminder[, -1:4]
gapminder[,-c(1:4)]


#3. Extract the rows where the life expectancy is longer the 80 years


# gapminder[gapminder$lifeExp > 80]
gapminder[gapminder$lifeExp > 80,]


#4. Extract the first row, and the fourth and fifth columns
#(`lifeExp` and `gdpPercap`).


# gapminder[1, 4, 5]
gapminder[1, c(4, 5)]


#5. Advanced: extract rows that contain information for the years 2002
#and 2007


# gapminder[gapminder$year == 2002 | 2007,]
gapminder[gapminder$year == 2002 | gapminder$year == 2007,]
gapminder[gapminder$year %in% c(2002, 2007),]



## Challenge 4

#1. Why does `gapminder[1:20]` return an error? How does it differ from
#  `gapminder[1:20, ]`?

#2. Create a new `data.frame` called `gapminder_small` that only contains rows
#1 through 9 and 19 through 23. You can do this in one or two steps.

## Solution to challenge 4

#1.  `gapminder` is a data.frame so needs to be subsetted on two dimensions. `gapminder[1:20, ]` subsets the data to give the first 20 rows and all columns.

#2.


gapminder_small <- gapminder[c(1:9, 19:23),]


