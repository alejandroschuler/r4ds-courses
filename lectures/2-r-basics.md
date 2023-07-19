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
- recognize vectors and vectorized functions
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
genes = read_csv("https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/advance-2020/data/lupusGenes.csv")
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
mpg = read_csv("https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/advance-2020/data/mpg.csv")
```
- This code *assigns* the result of running `read_csv("https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/advance-2020/data/mpg.csv")` to the name `mpg`
- You can do this with any values and/or functions

```r
x = (13 + 7)/2
```
- R prints no result from this assignment, but what you entered
causes a side effect: R has stored the association between
x and the result of this expression (look at the Environment pane.)

Using the value of a variable
========================================================

```r
x
[1] 10
x / 5
[1] 2
```
- When R sees the name of a variable, it uses the stored value of
that variable in the calculation.
- Here R uses the value of x, which is 10.
- We can break complex calculations into named parts. This is a
simple, but very useful kind of abstraction.

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

Case matters for names in R
========================================================

```r
a = 1
A # this causes an error because A does not have a value
```
```
Error: object 'A' not found
```
- R cares about upper and lower case in names.
- We also see that some error messages in R are a bit obscure.

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

R saves some names for itself
========================================================

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
x = 4
sqrt(x)
[1] 2
x
[1] 4
y = sqrt(x)
y
[1] 2
x = 10
y
[1] 2
```
- What do you observe?

Functions and variable assignment
========================================================
- functions generally do not affect the variables you pass to them (`x` remains the same after `sqrt(x)`)
- The results of a function call will simply be printed out if you do not save the result to a variable
- Saving the result to a variable lets you use it later, like any other variable you define manually
- Once a variable has been assigned (`y`), it keeps its value until updated, even if you change other variables (`x`) that went into the original assignment of that variable

Arguments by position vs. name
========================================================
- Arguments can be specified by position, with one supplied
argument for each name in the function parameter list, and in the
same order

```r
ggplot(genes) + 
  geom_point(aes(VAPA, EIF3L))
```

![plot of chunk unnamed-chunk-16](2-r-basics-figure/unnamed-chunk-16-1.png)

***

- Sometimes, arguments can be supplied by name using the syntax,
variable `=` value.
- When using names, the order of the named arguments
does not matter.

```r
ggplot(data=genes) + 
  geom_point(mapping=aes(y=EIF3L, x=VAPA))
```

![plot of chunk unnamed-chunk-17](2-r-basics-figure/unnamed-chunk-17-1.png)

Optional arguments
===
- Many R functions have arguments that you don't always have to specify. For example:

```r
file_name = "https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/advance-2020/data/lupusGenes.csv"
genes_10 = read_csv(file_name, n_max=10) # only read in 10 rows
genes = read_csv(file_name) 
```
- `n_max` tells `read_csv()` to only read the first 10 rows of the dataset. 
- If you don't specify it, it defaults to infinity (i.e. R reads until there are no more lines in the file).

Why?
========================================================
- What are the benefits/drawbacks of using positional vs. named arguments?

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

![plot of chunk unnamed-chunk-19](2-r-basics-figure/unnamed-chunk-19-1.png)

***

But when I use this code, I get:


```r
ggplot(data=genes) + 
  geom_point(aes(VAPA, EIF3L))
```

![plot of chunk unnamed-chunk-20](2-r-basics-figure/unnamed-chunk-20-1.png)

What am I doing wrong?

Finding the names of a function's arguments
========================================================
incremental: true
type: prompt

`read_csv()` takes a number of optional named arguments. What are some of them?


Calling functions from a package
============================================================
- Sometimes packages introduce name conflicts, which is when the pacakge loads a function that is named the same thing as a function that's already in the environment
- Typically, the package being loaded will take precedence over what is already loaded.
- For instance:

```r
?filter # returns documentation for a function called filter in the stats package
library(dplyr)
?filter # now returns documentation for a function called filter in the dplyr package!
```
- You can tell R which function you want by specifying the package name and then `::` before the function name

```r
?stats::filter
?dplyr::filter
```

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
y2 = 2 + x2
y3 = 3 + x3
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

Elementwise operations on a vector
========================================================
- This multiplies each element of `1:10` by the corresponding element of `1:10`, that is, it squares each element.

```r
(1:10)*(1:10)
 [1]   1   4   9  16  25  36  49  64  81 100
```
- Equivalently, we could use exponentiation:

```r
(1:10)^2
 [1]   1   4   9  16  25  36  49  64  81 100
```
- Many basic R functions operate on multi-element vectors as
easily as on vectors containing a single number.

```r
sqrt(0:10)
 [1] 0.000000 1.000000 1.414214 1.732051 2.000000 2.236068 2.449490 2.645751
 [9] 2.828427 3.000000 3.162278
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

Indexing
========================================================

```r
x
[1] 1 2 3
x[1] # same as x[c(1)] since 1 is already a vector (of length 1)
[1] 1
x[2:4]
[1]  2  3 NA
x[c(3, 1)]
[1] 3 1
x[c(1,1,1,1,1,1,4)]
[1]  1  1  1  1  1  1 NA
```
- Indexing returns a subsequence of the vector. It does not change
the original vector. Assign the result to a new variable to save it if you neeed it later.
- R starts counting vector indices from 1.
- You can index using a multi-element index vector.
- You can repeat index positions



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
1:10 %% 3 == 0
 [1] FALSE FALSE  TRUE FALSE FALSE  TRUE FALSE FALSE  TRUE FALSE
c(TRUE, TRUE, FALSE, NA)
[1]  TRUE  TRUE FALSE    NA
```
- logical vectors can only be one of three values: `TRUE`, `FALSE`, or `NA`.
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

Exercise: subtract the mean
========================================================
type: prompt


```r
x = c(7, 3, 1, 9)
```
- Subtract the mean of `x` from `x`, and then `sum` the result.

Exercise: a vector of variables
===

- Predict the output of the following code:

```r
a = 1
b = 2
x = c(a,b)

a = 3
print(x)
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


Data import
===
type:section

Rationale
===
- Sometimes R fails to read in the data from a file
- Or you will read data into R and find strange errors when you try to manipulate it
- This is often caused by type mismatches- e.g. you expected a column to have been read in as a factor, but it was actually read in as a logical.

```r
file = readr_example("challenge.csv")
challenge = read_csv(file)
Rows: 2000 Columns: 2
── Column specification ────────────────────────────────────────────────────────
Delimiter: ","
dbl  (1): x
date (1): y

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

Diagnosing intake errors
===
- Use `readr::problems()` on the returned object to learn more about the errors

```r
problems(challenge)
# A tibble: 0 × 5
# ℹ 5 variables: row <int>, col <int>, expected <chr>, actual <chr>, file <chr>
```
- This tells us that `read_csv()` was expecting the `y` column to be logical, but when we look at what was actually in the file at rows 1001+, there are what appear to be dates!
- This happens because `read_csv()` does not know what type of data are in the file- you haven't told it, so it has to guess. 
- The way it guesses is by checking the first 1000 rows of each column and picking the most likely data type.
- You can tell `read_csv()` to check more rows before guessing by using the `guess_max` argument

Specifying data types
===
- In general, you may already know what types the columns should be, so you can provide those to `read_csv()`. 

```r
challenge = read_csv(file,
   col_types = cols(
     y = col_date()
   ))
head(challenge)
# A tibble: 6 × 2
      x y     
  <dbl> <date>
1   404 NA    
2  4172 NA    
3  3004 NA    
4   787 NA    
5    37 NA    
6  2332 NA    
```
- This is a more robust solution than using more rows to guess
- Now we see that the problem was caused because the first 1000 rows of `y` are NAs
- Column types are provided to read_csv as named arguments to `cols()`, which itself is a named argument to `col_types`. 
- You do not need to specify all columns (here we let it guess what `x` is) but it is often good practice to do so if possible


Specifying data types
===
- Factors can be read in with a high level of control

```r
df = readr_example("mtcars.csv")  %>%
read_csv(col_types = cols(
  cyl = col_factor(levels=c("4", "6", "8"))
))
```
- This will let you catch unexpected factor levels and set the proper order up-front! 
- To allow all levels, don't use the `levels` argument

```r
df = readr_example("mtcars.csv")  %>%
read_csv(col_types = cols(
  cyl = col_factor()
))
```
- There are many more options and choices, see the documentation and cheat sheet!

Non-csv flat files
===
- Besides .csv, you may find data in .tsv (tab-separated values) and other more exotic formats. 
- Many of these are still delimited text files ("flat files"), which means that the data are stored as text with special characters between new lines and columns. This is an exmaple .csv:

```r
toy_csv = "1,2,3\n4,5,6"
```
- This is an example .tsv

```r
toy_tsv = "1\t2\t3\n4\t5\t6"
```
- The only difference is the **delimiter** which is the character that breaks up columns. 

Non-csv flat files
===
- Both can be read in using `read_delim()`

```r
read_delim("1,2,3\n4,5,6", delim=",", col_names = c("x","y","z"))
Rows: 2 Columns: 3
── Column specification ────────────────────────────────────────────────────────
Delimiter: ","
dbl (3): x, y, z

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
# A tibble: 2 × 3
      x     y     z
  <dbl> <dbl> <dbl>
1     1     2     3
2     4     5     6
read_delim("1\t2\t3\n4\t5\t6", delim="\t", col_names = c("x","y","z"))
Rows: 2 Columns: 3
── Column specification ────────────────────────────────────────────────────────
Delimiter: "\t"
dbl (3): x, y, z

ℹ Use `spec()` to retrieve the full column specification for this data.
ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
# A tibble: 2 × 3
      x     y     z
  <dbl> <dbl> <dbl>
1     1     2     3
2     4     5     6
```
- `read_csv()` is just a shortcut to `read_delim()` that has `delim=","` hardcoded in.

Non-flat files
===
- There are also other packages that let you read in from other formats
  - `haven` reads in SPSS, Stata, and SAS files
  - `readxl` reads in `.xls` and `.xlsx`
  - `DBI` with a database backend (e.g. `odbc`) reads in from databases
  - `jsonlite` and `xml2` for heirarchical data
  - `rio` for more esoteric formats
  
Writing files
===

```r
write_csv(challenge, "/Users/c242587/Desktop/challenge.csv")
```
- metadata about column types is lost when writing to .csv
- use `write_rds()` (and `read_rds()`) to save to a binary R format that preserves column types

```r
write_rds(challenge, "/Users/c242587/Desktop/challenge.rds")
```

Exercise: Reading a file
===
type: prompt

Identify what is wrong with each of the following inline CSV files. What happens when you run the code?

```r
read_csv("a,b\n1,2,3\n4,5,6")
read_csv("a,b,c\n1,2\n1,2,3,4")
read_csv("a,b\n\"1")
read_csv("a,b\n1,2\na,b")
read_csv("a;b\n1;3")
```

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

Script pane example
============================================================
- Create a script pane: File > New File > R Script
- Put your cursor in the script pane.
- Type: `factorial(1:10)`
- Then hit `Command-RETURN` (Mac), or `Ctrl-ENTER` (Windows).
- That line is copied to the console pane and evaluated.
- You can save the script to a file.
- Explore the RStudio Code menu for other commands.

Adding comments
========================================================

```r
## This is a comment
1 + 2 # add some numbers
[1] 3
```
- Use a `#` to start a comment.
- A comment extends to the end of the
line and is ignored by R.

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

RStudio Pro-tip: multicursors
===

- RStudio's script pane supports multi-cursors! Hold `alt` and drag your mouse up and down 
- You can also set a keyboard shortcut for `quick add next`
- These features make it much easier to rename variables, etc.
- You should also be aware of `cmd-<arrow>` and `alt-<arrow>` for moving the cursor (by line and by word)
- and `cmd-shift-<arrow>` and `alt-shift-<arrow>` for selecting text (by line and by word)

