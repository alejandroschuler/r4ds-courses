Programming Basics
========================================================
author: Alejandro Schuler, adapted from Steve Bagley and based on R for Data Science by Hadley Wickham
date: 2022
transition: none
width: 1680
height: 1050

Learning Goals:

- save values to variables
- find and call R functions with multiple arguments by position and name
- recognize and index vectors and lists
- recognize, import, and inspect data frames
- issue commands to R using the Rstudio script pane


<style>
.small-code pre code {
  font-size: 0.5em;
}
</style>

Programming Basics
========================================================
- We've seen code like


```r
genes = read_csv("https://tinyurl.com/cjkuecnc")
```

- We know this reads a .csv from a file and creates something called a "data frame" 
- We've been using this data frame in code like

```r
ggplot(genes) + 
  geom_bar(aes(x = ancestry, fill = phenotype))
```
- But what does this syntax really mean? Is it useful outside of making plots?

Assignment
===
type: section

Assignment
========================================================

- To do complex computations, we need to be able to give
names to things.

```r
genes = read_csv("https://tinyurl.com/cjkuecnc")
```
- This code *assigns* the result of running `read_csv("https://tinyurl.com/cjkuecnc")` to the name `gene`

***

- You can do this with any values and/or functions

```r
x = 1
```
- R prints no result from this assignment, but what you entered
causes a side effect: R has stored the association between
x and the result of this expression (look at the Environment pane.)

![](https://github.com/alejandroschuler/r4ds-courses/blob/summer-2023/figures/x_gets_1.png?raw=true)

Using the value of a variable
========================================================

```r
x
[1] 1
x / 5
[1] 0.2
```
- When R sees the name of a variable, it uses the stored value of
that variable in the calculation.
- We can break complex calculations into named parts. This is a
simple, but very useful kind of abstraction.

![](https://github.com/alejandroschuler/r4ds-courses/blob/summer-2023/figures/x_is_1.jpg?raw=true)

Two ways to assign
========================================================
In R, there are (unfortunately) two assignment operators. They have
subtly different meanings (more details later).
- `<-` requires that you type two characters. Don't put a
space between `<` and `-`. (What would happen?)
- RStudio hint: Use "`Option -`" (Mac) or "`Alt -`" (PC)
to type this using one key combination.
- `=` is easier to type.
- You will see both used throughout R and user code.


```r
x <- 10
x
[1] 10
x = 20
x
[1] 20
```

Assignment has no undo
========================================================

```r
x = 10
x
[1] 10
x = x + 1
x
[1] 11
```
- If you assign to a name with an existing value, that value is overwritten.
- There is no way to undo an assignment, so be careful in reusing variable names.

Naming variables
========================================================
- It is important to pick meaningful variable names.
- Names can be too short, so don't use `x` and `y` everywhere.
- Names can be too long (`Main.database.first.object.header.length`).
- Avoid silly names.
- Pick names that will make sense to someone else (including the
person you will be in six months).
- ADVANCED: See `?make.names` for the complete rules on
what can be a name.

More about naming
========================================================
There are different conventions for constructing compound names. Warning:
disputes over the right way to do this can get heated.

```r
stringlength
string.length
StringLength
stringLength
string_length (underbar)
string-length (hyphen)
```
- To be consistent with the packages we will use, I recommend snake_case where you separate lowercase words with _
- Note that R itself uses several of these conventions.
- One of these won't work. Which one and why?

Naming rules
========================================================

```r
a = 1
A # this causes an error because A does not have a value
```
```
Error: object 'A' not found
```
- R cares about upper and lower case in names.
- names can't start with numbers


```r
for = 7 # this causes an error
```
- `for` is a reserved word in R. (It is used in loop control.)
- ADVANCED: see `?Reserved` for the complete rules.

Exercise: birth year
===
type: prompt

- Make a variable that represents the age you will be at the end of this year
- Make a variable that represents the current year
- Use them to compute the year of your birth and save that as a variable
- Print the value of that variable

Functions
========================================================
type: section

Calling built-in functions
========================================================
- To call a function, type the function name, then the argument or
arguments in parentheses. (Use a comma to separate the arguments, if
                           more than one.)

```r
sqrt(2)
[1] 1.414214
```


Functions and variable assignment
========================================================

```r
x = 2
x^2
[1] 4
x
[1] 2
```
- What do you observe?

Functions and variable assignment
========================================================

```r
x = 2
x^2
[1] 4
x
[1] 2
```
- What do you observe?

![](https://github.com/alejandroschuler/r4ds-courses/blob/summer-2023/figures/x_squared.png?raw=true)

Functions and variable assignment
========================================================

```r
y = x
y
[1] 2
x = 1
y
[1] 2
```
- What do you observe?

Functions and variable assignment
========================================================

```r
y = x
y
[1] 1
x = 10
y
[1] 1
```
- What do you observe?

***

![](https://github.com/alejandroschuler/r4ds-courses/blob/summer-2023/figures/y_gets_x.png?raw=true)

![](https://github.com/alejandroschuler/r4ds-courses/blob/summer-2023/figures/x_changes.png?raw=true)

Functions and variable assignment
========================================================
- functions generally do not affect the variables you pass to them (`x` remains the same after `sqrt(x)`)
- Once a variable has been assigned (`y`), it keeps its value until updated, even if you change other variables (`x`) that went into the original assignment of that variable

Function arguments
========================================================

- Functions transform inputs to outputs
- internally, however, they have an environment just like the one you see in your workspace
- when you call a function, you tell it how to connect the variables in your environment to the ones it expects to have so that it can do its job
- the names the function calls these inputs inside itself will be different than what you call them on the outside

```
aes(x=EIF3L, y=VAPA)
```

![](https://github.com/alejandroschuler/r4ds-courses/blob/summer-2023/figures/call.png?raw=true)


Arguments by name vs. position
========================================================


- Arguments can be supplied **by name** using the syntax
variable `=` value.
- you can see the names of the arguments in the help page for each function
- When using names, the order of the named arguments
does not matter.

```r
ggplot(data=genes) + 
  geom_point(mapping=aes(y=EIF3L, x=VAPA))
```

![plot of chunk unnamed-chunk-19](2-r-basics-figure/unnamed-chunk-19-1.png)

***

- If you leave the names off, R defaults to a **positional** order that is specific to each function (e.g. for `aes()`, `x` comes first, then `y`)
- you can see the default order of the arguments in the help page for each function

```r
ggplot(genes) + 
  geom_point(aes(VAPA, EIF3L))
```

![plot of chunk unnamed-chunk-20](2-r-basics-figure/unnamed-chunk-20-1.png)

Optional arguments
===
- Many R functions have arguments that you don't always have to specify. For example:

```r
file_name = "https://tinyurl.com/cjkuecnc"
genes_10 = read_csv(file_name, n_max=10) # only read in 10 rows
genes = read_csv(file_name) 
```
- `n_max` tells `read_csv()` to only read the first 10 rows of the dataset. 
- If you don't specify it, it defaults to infinity (i.e. R reads until there are no more lines in the file).

Exercise
========================================================
type: prompt

Why does this code generate errors?


```r
ggplot(the_data=genes) + 
  geom_point(mapping=aes(y_axis=EIF3L, x_axis=VAPA))
Warning in geom_point(mapping = aes(y_axis = EIF3L, x_axis = VAPA)): Ignoring
unknown aesthetics: y_axis and x_axis
Error in `geom_point()`:
! Problem while computing aesthetics.
ℹ Error occurred in the 1st layer.
Caused by error:
! object 'EIF3L' not found
```

Exercise
========================================================
type: prompt

I'm trying to generate this plot:

![plot of chunk unnamed-chunk-22](2-r-basics-figure/unnamed-chunk-22-1.png)

***

But when I use this code, I get:


```r
ggplot(data=genes) + 
  geom_point(aes(VAPA, EIF3L))
```

![plot of chunk unnamed-chunk-23](2-r-basics-figure/unnamed-chunk-23-1.png)

What am I doing wrong?

Finding the names of a function's arguments
========================================================
incremental: true
type: prompt

What does the optional `na` argument do in `read_csv()`? Ask ChatGPT to give you some examples of how you would use it.

How can you use `read_csv` to only read in the *last* 5 rows of a data frame?

Vectors
========================================================
type: section

Repetitive calculations
========================================================

```r
x1 = 1
x2 = 2
x3 = 3
```

Let's say I have these variables and I want to add 1 to all of them and save the result.


```r
y1 = 1 + x1
y2 = 1 + x2
y3 = 1 + x3
```

This does the trick but it's a lot of copy-paste

Vectors
====
- Vectors solve the problem

```r
x = c(1,2,3)
y = x + 1
y
[1] 2 3 4
```
- A vector is a one-dimensional sequence of zero or more values
- Vectors are created by wrapping the values separated by commas with the `c(` `)` function, which is short for "combine"
- Many R functions and operators (like `+`) automatically work with
multi-element vector arguments.

Elementwise operations on a vector
========================================================
- This multiplies each element of `1:10` by the corresponding element of `1:10`, that is, it squares each element.

```r
c(1,2,3) * c(4,5,6)
[1]  4 10 18
```
- Many basic R functions operate on multi-element vectors as
easily as on vectors containing a single number.

```r
sqrt(c(1,2,3))
[1] 1.000000 1.414214 1.732051
c(1,2,3)^3
[1]  1  8 27
log(c(1,2,3))
[1] 0.0000000 0.6931472 1.0986123
```

Some functions operate on vectors and give back a single number
========================================================

```r
numbers <- c(9, 12, 6, 10, 10, 16, 8, 4)
numbers
[1]  9 12  6 10 10 16  8  4
sum(numbers)
[1] 75
sum(numbers)/length(numbers)
[1] 9.375
mean(numbers)
[1] 9.375
```


Exercise: subtract the mean
========================================================
type: prompt


```r
x = c(7, 3, 1, 9)
```
- Subtract the mean of `x` from `x`, and then `sum` the result.

Exercise: a vector of variables
===
type: prompt

- Predict the output of the following code:

```r
a = 1
b = 2
x = c(a,b)

a = 3
print(x)
```

Ranges
===

```r
1:50
 [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
[26] 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50
```
- The colon `:` is a handy shortcut to create a vector that is
a sequence of integers from the first number to the second number
(inclusive).
- Long vectors wrap around. (Your screen may have a different width than what is shown here.)
- Look at the `[ ]` notation. The second output line starts
with 23, which is the 24^th element of the vector.
- This notation will help you figure out where you are in a long vector.


Indexing
========================================================

```r
x
[1] 7 3 1 9
x[1] # same as x[c(1)] since 1 is already a vector (of length 1)
[1] 7
x[2:4]
[1] 3 1 9
x[c(3, 1)]
[1] 1 7
x[c(1,1,1,1,1,1,4)]
[1] 7 7 7 7 7 7 9
```
- Indexing returns a subsequence of the vector. It does not change
the original vector. Assign the result to a new variable to save it if you neeed it later.
- R starts counting vector indices from 1.
- You can index using a multi-element index vector.
- You can repeat index positions

Exercise
===
type:prompt
What does this code do?

```r
x = ... # some vector
x[length(x):1]
```

Hints:
- assign `x` some values and try it to see!
- read inside out: first figure out what `length(x)` does, then think about what the output of `length(x):1` should do, and then finally `x[length(x):1]`

Changing values with indexing
========================================================
- you can assign _into_ an indexed position


```r
x
[1] 7 3 1 9
x[1] = 100
x
[1] 100   3   1   9
```

- or multiple


```r
x
[1] 100   3   1   9
x[c(1,2)] = c(100, 200)
x
[1] 100 200   1   9
x[c(1,2)] = -1
x
[1] -1 -1  1  9
```

Data Types
========================================================
type: section

Strings
===
- text data in R is called a "string"

```r
my_string = "hello"
```
- when using data that is text in R, you have to refer to it using quotation marks (why?)

```r
my_string = hello # what does this code do?
```
- you can have a vector of strings, and functions can operate on these too:

```r
words = c("hello", "how", "are", "you", "?")
paste(words, collapse=" ")
[1] "hello how are you ?"
```

Factors
===

```r
library(forcats)
```
- factors represent categorical data

```r
seasons_str = c("spring", "summer", "fall", "winter") # string vector
seasons_str
[1] "spring" "summer" "fall"   "winter"
```

```r
seasons_fct = fct(seasons_str) # factor vector
seasons_fct
[1] spring summer fall   winter
Levels: spring summer fall winter
```

- this is useful to tightly control data and prevent accidents

```r
seasons_str[1] = "Jan"
```

```r
seasons_fct[1] = "Jan"
Warning in `[<-.factor`(`*tmp*`, 1, value = "Jan"): invalid factor level, NA
generated
```

Logicals
========================================================

```r
c(-2, -1, 0, 1, 2) > 0
[1] FALSE FALSE FALSE  TRUE  TRUE
c(TRUE, TRUE, FALSE)
[1]  TRUE  TRUE FALSE
```
- logical vectors can only be `TRUE` or `FALSE`
- we'll see more about this later

Coercion
===
- If you try to do something to a vector of the wrong data type, R will often do its best to "make it work" by converting to another type

```r
TRUE + 2
[1] 3
```


```r
numbers = c(1,2,3)
numbers[1] = '5'
numbers + 2
Error in numbers + 2: non-numeric argument to binary operator
```
- this is a frequent source of unexpected errors!

Exercise: data types
========================================================
type: prompt

What types are each of the following vectors? Are they all fundamentally the same, or are they different?


```r
v1 = c(0,1)
v2 = c(FALSE, TRUE)
v3 = c("FALSE", "TRUE")
v4 = fct(v3)
```

Which of these lines of code will run and which will produce an error?

```r
v1 + 1
v2 + 1
v3 + 1
v4 + 1
```

NA
===
- R has a special value that represents missing data- it's called `NA`

```r
c(1,2,NA,4)
[1]  1  2 NA  4
```
- NA can appear anywhere that R would expect some other kind of data
- NA usually ruins computations:

```r
1 + NA + 3
[1] NA
```
- The result makes sense because if I don't know what I'm adding together, I don't know the result either
- some functions have options to ignore the missing values in vectors:

```r
mean(c(1,2,NA,4), na.rm=TRUE)
[1] 2.333333
```

Lists
===
type: section

Lists
===
- A `list` is like an atomic vector, except the elements don't have to be the same type of thing

```r
a_vector = c(1,2,4,5)
maybe_a_vector = c(1,2,"hello",5,TRUE)
maybe_a_vector # R converted all of these things to strings!
[1] "1"     "2"     "hello" "5"     "TRUE" 
```
- You make them with list() and you can index them like vectors

```r
a_list = list(1,2,"hello",5,TRUE)
a_list[3:5]
[[1]]
[1] "hello"

[[2]]
[1] 5

[[3]]
[1] TRUE
```
- Anything can go in lists, including vectors, other lists, data frames, etc.
- In fact, a data frame (or tibble) is actually just a list of named column vectors with an enforced constraint that all of the vectors have to be of the same length. That's why the `df$col` syntax works for data frames.

Getting elements from a list
===
- You can also name the elements in a list

```r
a_list = list(
    first_number = 1,
    second_number = 2,
    a_string = "hello",
    third_number = 5,
    some_logical = TRUE)
```
- and then retrieve elements by name or position 

```r
a_list$a_string  # returns the element named "thrid_number"
[1] "hello"
a_list[[3]] # returns the 3rd element
[1] "hello"
a_list[3] # subsets the list, so returns a list of length 1 that contains a single element (the third)
$a_string
[1] "hello"
```

Exercise: getting things out of a list
===
type:prompt
Create this list in your workspace and write code to extract the element `"b"`.

```r
x = list(
  list("a", "b", "c"), 
  "d", 
  "e", 
  6
)
```


Seeing into lists
===
- Use `str()` to dig into nested lists and other complicated objects

```r
nested_list = lm(hp ~ ., mtcars)
str(nested_list)
List of 12
 $ coefficients : Named num [1:11] 79.048 -2.063 8.204 0.439 -4.619 ...
  ..- attr(*, "names")= chr [1:11] "(Intercept)" "mpg" "cyl" "disp" ...
 $ residuals    : Named num [1:32] -38.68 -30.63 13.01 -15.75 -8.22 ...
  ..- attr(*, "names")= chr [1:32] "Mazda RX4" "Mazda RX4 Wag" "Datsun 710" "Hornet 4 Drive" ...
 $ effects      : Named num [1:32] -829.8 296.3 124.8 -19.6 90.3 ...
  ..- attr(*, "names")= chr [1:32] "(Intercept)" "mpg" "cyl" "disp" ...
 $ rank         : int 11
 $ fitted.values: Named num [1:32] 149 141 80 126 183 ...
  ..- attr(*, "names")= chr [1:32] "Mazda RX4" "Mazda RX4 Wag" "Datsun 710" "Hornet 4 Drive" ...
 $ assign       : int [1:11] 0 1 2 3 4 5 6 7 8 9 ...
 $ qr           :List of 5
  ..$ qr   : num [1:32, 1:11] -5.657 0.177 0.177 0.177 0.177 ...
  .. ..- attr(*, "dimnames")=List of 2
  .. .. ..$ : chr [1:32] "Mazda RX4" "Mazda RX4 Wag" "Datsun 710" "Hornet 4 Drive" ...
  .. .. ..$ : chr [1:11] "(Intercept)" "mpg" "cyl" "disp" ...
  .. ..- attr(*, "assign")= int [1:11] 0 1 2 3 4 5 6 7 8 9 ...
  ..$ qraux: num [1:11] 1.18 1.02 1.29 1.19 1.05 ...
  ..$ pivot: int [1:11] 1 2 3 4 5 6 7 8 9 10 ...
  ..$ tol  : num 1e-07
  ..$ rank : int 11
  ..- attr(*, "class")= chr "qr"
 $ df.residual  : int 21
 $ xlevels      : Named list()
 $ call         : language lm(formula = hp ~ ., data = mtcars)
 $ terms        :Classes 'terms', 'formula'  language hp ~ mpg + cyl + disp + drat + wt + qsec + vs + am + gear + carb
  .. ..- attr(*, "variables")= language list(hp, mpg, cyl, disp, drat, wt, qsec, vs, am, gear, carb)
  .. ..- attr(*, "factors")= int [1:11, 1:10] 0 1 0 0 0 0 0 0 0 0 ...
  .. .. ..- attr(*, "dimnames")=List of 2
  .. .. .. ..$ : chr [1:11] "hp" "mpg" "cyl" "disp" ...
  .. .. .. ..$ : chr [1:10] "mpg" "cyl" "disp" "drat" ...
  .. ..- attr(*, "term.labels")= chr [1:10] "mpg" "cyl" "disp" "drat" ...
  .. ..- attr(*, "order")= int [1:10] 1 1 1 1 1 1 1 1 1 1
  .. ..- attr(*, "intercept")= int 1
  .. ..- attr(*, "response")= int 1
  .. ..- attr(*, ".Environment")=<environment: R_GlobalEnv> 
  .. ..- attr(*, "predvars")= language list(hp, mpg, cyl, disp, drat, wt, qsec, vs, am, gear, carb)
  .. ..- attr(*, "dataClasses")= Named chr [1:11] "numeric" "numeric" "numeric" "numeric" ...
  .. .. ..- attr(*, "names")= chr [1:11] "hp" "mpg" "cyl" "disp" ...
 $ model        :'data.frame':	32 obs. of  11 variables:
  ..$ hp  : num [1:32] 110 110 93 110 175 105 245 62 95 123 ...
  ..$ mpg : num [1:32] 21 21 22.8 21.4 18.7 18.1 14.3 24.4 22.8 19.2 ...
  ..$ cyl : num [1:32] 6 6 4 6 8 6 8 4 4 6 ...
  ..$ disp: num [1:32] 160 160 108 258 360 ...
  ..$ drat: num [1:32] 3.9 3.9 3.85 3.08 3.15 2.76 3.21 3.69 3.92 3.92 ...
  ..$ wt  : num [1:32] 2.62 2.88 2.32 3.21 3.44 ...
  ..$ qsec: num [1:32] 16.5 17 18.6 19.4 17 ...
  ..$ vs  : num [1:32] 0 0 1 1 0 1 0 1 1 1 ...
  ..$ am  : num [1:32] 1 1 1 0 0 0 0 0 0 0 ...
  ..$ gear: num [1:32] 4 4 4 3 3 3 3 4 4 4 ...
  ..$ carb: num [1:32] 4 4 1 1 2 1 4 2 2 4 ...
  ..- attr(*, "terms")=Classes 'terms', 'formula'  language hp ~ mpg + cyl + disp + drat + wt + qsec + vs + am + gear + carb
  .. .. ..- attr(*, "variables")= language list(hp, mpg, cyl, disp, drat, wt, qsec, vs, am, gear, carb)
  .. .. ..- attr(*, "factors")= int [1:11, 1:10] 0 1 0 0 0 0 0 0 0 0 ...
  .. .. .. ..- attr(*, "dimnames")=List of 2
  .. .. .. .. ..$ : chr [1:11] "hp" "mpg" "cyl" "disp" ...
  .. .. .. .. ..$ : chr [1:10] "mpg" "cyl" "disp" "drat" ...
  .. .. ..- attr(*, "term.labels")= chr [1:10] "mpg" "cyl" "disp" "drat" ...
  .. .. ..- attr(*, "order")= int [1:10] 1 1 1 1 1 1 1 1 1 1
  .. .. ..- attr(*, "intercept")= int 1
  .. .. ..- attr(*, "response")= int 1
  .. .. ..- attr(*, ".Environment")=<environment: R_GlobalEnv> 
  .. .. ..- attr(*, "predvars")= language list(hp, mpg, cyl, disp, drat, wt, qsec, vs, am, gear, carb)
  .. .. ..- attr(*, "dataClasses")= Named chr [1:11] "numeric" "numeric" "numeric" "numeric" ...
  .. .. .. ..- attr(*, "names")= chr [1:11] "hp" "mpg" "cyl" "disp" ...
 - attr(*, "class")= chr "lm"
```


Data Frames
===
type:section

Making data frames
========================================================
- use `tibble()` to make your own data frames from scratch in R

```r
my_data = tibble(
  person = c("carlos", "nathalie", "christina", "alejandro"),
  age = c(33, 48, 8, 29)
)
my_data
# A tibble: 4 × 2
  person      age
  <chr>     <dbl>
1 carlos       33
2 nathalie     48
3 christina     8
4 alejandro    29
```

Data frame properties
========================================================
- `dim()` gives the dimensions of the data frame. `ncol()` and `nrow()` give you the number of columns and the number of rows, respectively.

```r
dim(my_data)
[1] 4 2
ncol(my_data)
[1] 2
nrow(my_data)
[1] 4
```

- `names()` gives you the names of the columns (a vector)

```r
names(my_data)
[1] "person" "age"   
```

Data frame properties
========================================================
- `glimpse()` shows you a lot of information, `head()` returns the first `n` rows

```r
glimpse(my_data)
Rows: 4
Columns: 2
$ person <chr> "carlos", "nathalie", "christina", "alejandro"
$ age    <dbl> 33, 48, 8, 29

head(my_data, n=2)
# A tibble: 2 × 2
  person     age
  <chr>    <dbl>
1 carlos      33
2 nathalie    48
```

Writing data frames
===

```r
write_csv(my_data, "~/Desktop/my_data.csv")
```
- after running this, you'll see a new file called `my_data.csv` (or whatever you chose to name it) appear in the specified location on your computer (e.g. `Desktop`)
- you can read and write `.csv` files in lots of programs (e.g. google sheets)
- to read and write other formats look at documentation and use google + chatGPT!

readr cheat sheet
===
<div align="center">
<img src="https://www.rstudio.com/wp-content/uploads/2018/08/data-import.png", height=1000, width=1400>
</div>

Scripts
============================================================
type: section

Using the script pane
============================================================
- Writing a series of expressions in the console rapidly gets
messy and confusing.
- The console window gets reset when you restart RStudio.
- It is better (and easier) to write expressions and functions
in the script pane (upper left), building up your analysis.
- There, you can enter expressions, evaluate them, and save the
contents to a .R file for later use.
- Look at the RStudio ``Code'' menu for some useful keyboard
commands.

***

- Create a script pane: File > New File > R Script
- Put your cursor in the script pane.
- Type: `1:10^2`
- Then hit `Command-RETURN` (Mac), or `Ctrl-ENTER` (Windows).
- That line is copied to the console pane and evaluated.
- You can save the script to a file.
- Explore the RStudio Code menu for other commands.

Adding comments
========================================================

```r
## In this section, we make a vector and reverse its order
x = 1:3 * 10                # make a vector [10, 20 ... ]
x_reversed = x[length(x):1] # reverse its order
```
- Use a `#` to start a comment.
- A comment extends to the end of the
line and is ignored by R.
- comments are complemented by good code style!


RStudio Pro-tip: scrolling and multicursors
===

- You should also be aware of `cmd-<arrow>` and `alt-<arrow>` for moving the cursor (by line and by word)
- and `cmd-shift-<arrow>` and `alt-shift-<arrow>` for selecting text (by line and by word)
- RStudio's script pane supports multi-cursors! Hold `alt` and drag your mouse up and down 
- You can also set a keyboard shortcut for `quick add next`
- These features make it much easier to rename variables, etc.




Exercise: Plotting a parabola
===
type: prompt

Write an R script that starts with:


```r
A = 1
B = 2
C = 3
```

In the rest of the script, do the following:

- generate an evenly-spaced sequence of 100 values between -5 and 5 (find an R function that does this). Call this `x`
- generate the corresponding y-values `y` by computing the formula y = Ax^2 + Bx + C
- create a data frame with `x` and `y` as columns
- use ggplot to create a line plot of `x` vs `y`

Run your script to see the generated plot. Try changing the values of `A`, `B`, and `C` at the top of the script and re-running to see how the plot changes.

***

Your result should look like:

![plot of chunk unnamed-chunk-66](2-r-basics-figure/unnamed-chunk-66-1.png)
