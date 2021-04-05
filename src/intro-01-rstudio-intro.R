#Title: intro-01-rstudio-intro.R
#BCB503 Geospatial Workshop, April 23 and 24th, 2020
#University of Idaho
#Data Carpentry Geospatial Analysis
#Instructors: Erich Seamon, University of Idaho - Travis Seaborn, University of Idaho




## Using R as a calculator

##The simplest thing you could do with R is do arithmetic:


1 + 100


#From highest to lowest precedence:

# * Parentheses: `(`, `)`
# * Exponents: `^` or `**`
# * Divide: `/`
# * Multiply: `*`
# * Add: `+`
# * Subtract: `-`

3 + 5 * 2

#Use parentheses to group operations in order to force the order of
#evaluation if it differs from the default, or to make clear what you
#intend.

(3 + 5) * 2

#This can get unwieldy when not needed, but  clarifies your intentions.
#Remember that others may later read your code.

(3 + (5 * (2 ^ 2))) # hard to read
3 + 5 * 2 ^ 2       # clear, if you remember the rules
3 + 5 * (2 ^ 2)     # if you forget some rules, this might help



#`#` is ignored by R when it executes code.

#Really small or large numbers get a scientific notation:

2/10000

#Which is shorthand for "multiplied by `10^XX`". So `2e-4`
#is shorthand for `2 * 10^(-4)`.

#You can write numbers in scientific notation too:

5e3  # Note the lack of minus here

## Comparing things

#We can also do comparison in R:


1 == 1  # equality (note two equals signs, read as "is equal to")



1 != 2  # inequality (read as "is not equal to")


1 < 2  # less than


1 <= 1  # less than or equal to


1 > 0  # greater than


1 >= -9 # greater than or equal to


## Variables and assignment

#We can store values in variables using the assignment operator `<-`, like this:

x <- 1/40


#Notice that assignment does not print a value. Instead, we stored it for later
#in something called a **variable**. `x` now contains the **value** `0.025`:

x

#More precisely, the stored value is a *decimal approximation* of
#this fraction called a floating point number

#Look for the `Environment` tab in one of the panes of RStudio, and you will see that `x` and its value
#have appeared. Our variable `x` can be used in place of a number in any calculation that expects a number:

log(x)


#Notice also that variables can be reassigned:

x <- 100

#`x` used to contain the value 0.025 and and now it has the value 100.

#Assignment values can contain the variable being assigned to:


x <- x + 1 #notice how RStudio updates its description of x on the top right tab
y <- x * 2


#The right hand side of the assignment can be any valid R expression.
#The right hand side is *fully evaluated* before the assignment occurs.

## Challenge 1

#What will be the value of each  variable  after each
#statement in the following program?

mass <- 47.5
age <- 122
mass <- mass * 2.3
age <- age - 20

## Solution to challenge 1

#This will give a value of `r mass` for the variable mass

mass <- 47.5

#This will give a value of `r age` for the variable age

age <- 122

#This will multiply the existing value of `r mass/2.3` by 2.3 to give a new value of
#`r mass` to the variable mass.

mass <- mass * 2.3

#This will subtract 20 from the existing value of `r age + 20 ` to give a new value
#of `r age` to the variable age.

age <- age - 20


## Challenge 2

#Run the code from the previous challenge, and write a command to
#compare mass to age. Is mass larger than age?

## Solution to challenge 2

#One way of answering this question in R is to use the `>` to set up the following:

#This should yield a boolean value of TRUE since `r mass` is greater than `r age`.

mass > age


#It is also possible to use the `=` operator for assignment:


x = 1/40

#the recommendation is to use `<-`.


## Challenge 3

#Which of the following are valid R variable names?

#min_height
#max.height
#_age
#.mass
#MaxLength
#min-length
#2widths
#celsius2kelvin


##  Solution to challenge 3


#min_height
#max.height
#MaxLength
#celsius2kelvin


# The following creates a hidden variable:

#.mass


#We won't be discussing hidden variables in this lesson. We recommend not using a period at the
#beginning of variable names unless you intend your variables to be hidden.

# The following will not be able to be used to create a variable

#_age
#min-length
#2widths

