Functional Programming
========================================================
author: Alejandro Schuler,  based on R for Data Science by Hadley Wickham
date: July 2021
transition: none
width: 1680
height: 1050



- write and test your own functions
- write code that evaluates conditionally
- create, manipulate, and inspect lists
- iterate functions over lists of arguments
- iterate in parallel

Writing functions
============================================================
type: section

Motivation
===
- It's handy to be able to reuse your code and automate repetitive tasks
- Writing your own functions allows you to do that 
- When you write your code as functions, you can
  - name the function something evocative and readable
  - update the code in a single place instead of many
  - reduce the chance of making mistakes while copy-pasting
  - make your code shorter overall
  
Example
===
What does this code do? (recall that `df$col` is the same as `df %>% pull(col)`)

```r
df <- tibble(
  a = rnorm(10), # 10 random numbers from a normal distribution
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)
```

```r
df$a = (df$a - min(df$a, na.rm = TRUE)) / 
  (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))
df$b = (df$b - min(df$b, na.rm = TRUE)) / 
  (max(df$b, na.rm = TRUE) - min(df$a, na.rm = TRUE))
df$c = (df$c - min(df$c, na.rm = TRUE)) / 
  (max(df$c, na.rm = TRUE) - min(df$c, na.rm = TRUE))
df$d = (df$d - min(df$d, na.rm = TRUE)) / 
  (max(df$d, na.rm = TRUE) - min(df$d, na.rm = TRUE))
```

Example
===
(recall that `df$col` is the same as `df %>% pull(col)`)

```r
df$a = (df$a - min(df$a, na.rm = TRUE)) / 
  (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))
df$b = (df$b - min(df$b, na.rm = TRUE)) / 
  (max(df$b, na.rm = TRUE) - min(df$a, na.rm = TRUE))
df$c = (df$c - min(df$c, na.rm = TRUE)) / 
  (max(df$c, na.rm = TRUE) - min(df$c, na.rm = TRUE))
df$d = (df$d - min(df$d, na.rm = TRUE)) / 
  (max(df$d, na.rm = TRUE) - min(df$d, na.rm = TRUE))
```
- It looks like we're standardizing all the variables by their range so that they fall between 0 and 1
- But did you spot the mistake? The code runs with no errors...

Example
===

```r
rescale_0_1 = function(vec) {
  (vec - min(vec))/(max(vec) - min(vec))
}

df2 = df %>%
  mutate(
    a= rescale_0_1(a),
    b= rescale_0_1(b),
    c= rescale_0_1(c),
    d= rescale_0_1(d),
  )
```
- Much improved!
- The last two lines clearly say: replace all the columns with their rescaled versions
  - This is because the function name `rescale_0_1()` is informative and communicates what it does
  - If a user (or you a few weeks later) is curious about the specifics, they can check the function body

Example
===

```r
rescale_0_1 = function(vec) {
  (vec - min(vec))/(max(vec) - min(vec))
}

df2 = df %>%
  mutate(
    across(a:d, rescale_0_1)
  ) # see ?across
```
- Even better.
- ... now we notice that `min()` is being computed twice in the function body, which is inefficient
- We are also not accounting for NAs

Example
===

```r
rescale_0_1 = function(vec) {
  vec_rng = range(vec, na.rm=T) # same as c(min(vec,na.rm=T), max(vec,na.rm=T))
  (vec - vec_rng[1])/(vec_rng[2] - vec_rng[1])
}

df2 = df %>%
  mutate(across(a:d, rescale_0_1))
```
- Since we have a function, we can make the change in a single place and improve the efficiency of multiple parts of our code
- Bonus question: why use `range()` instead of getting and saving the results of `min()` and `max()` separately?

Example
===
We can also test our function in cases where we know what the output should be to make sure it works as intended before we let it loose on the real data

```r
rescale_0_1(c(0,0,0,0,0,1))
[1] 0 0 0 0 0 1
rescale_0_1(0:10)
 [1] 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
rescale_0_1(-10:0)
 [1] 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
x = c(0,1,runif(100))
all(x == rescale_0_1(x))
[1] TRUE
```
- These tests are a critical part of writing good code! It is helpful to save your tests in a separate file and organize them as you go

Function syntax
===
To write a function, just wrap your code in some special syntax that tells it what variables will be passed in and what will be returned

```r
rescale_0_1 = function(x) {
  x_rng = range(x, na.rm=T) 
  (x - x_rng[1])/(x_rng[2] - x_rng[1])
}

rescale_0_1(c(0,0,0,0,0,1))
[1] 0 0 0 0 0 1
rescale_0_1(0:10)
 [1] 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
```
- The syntax is `FUNCTION_NAME <- function(ARGUMENTS...) { CODE }`
- Just like assigning a variable, except what you put into `FUNCTION_NAME` now isn't a data frame, vector, etc, it's a function object that gets created by the `function(..) {...}` syntax
- At any point in the body you can `return()` the value, or R will automatically return the result of the last line of code in the body that gets run

Function syntax
===
To add a named argument, add an `=` after you declare it as a variable and write in the default value that you would like that variable to take

```r
rescale_0_1 = function(x, na.rm=TRUE) {
  x_rng = range(x, na.rm=na.rm) 
  (x - x_rng[1])/(x_rng[2] - x_rng[1])
}

rescale_0_1(c(0,0,0,0,0,1))
[1] 0 0 0 0 0 1
rescale_0_1(0:10)
 [1] 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
```
- All named arguments must go after positional arguments in the function declaration

Exercise: NAs in two vectors
===
type: prompt
- Write a function called both_na() that takes two vectors of the same length and returns the total number of positions that have an NA in both vectors
- Make a few vectors and test out your code

Note: functions are objects just like variables are
===

```r
rescale_0_1
function(x, na.rm=TRUE) {
  x_rng = range(x, na.rm=na.rm) 
  (x - x_rng[1])/(x_rng[2] - x_rng[1])
}
<bytecode: 0x119fc7150>
```
- As we've seen, they themselves can be passed as arguments to other functions

```r
df2 = df %>% mutate(across(a:d, rescale_0_1))
```
- This is what **functional programming** means. The functions themselves are can be treated as regular objects like variables
- The name of the function is just what you call the "box" that the function (the code) lives in, just like variables names are names for "boxes" that contain data

Exercise: function factory
===
type: prompt
Without running this code, predict what the output will be:

```r
f = function(x) {
  y = x
  function(y) {
    y + x
  }
}
f(1)(2)
```

Exercise: exponent function factory
===
type: prompt
Write a function called `power()` that takes an argument `n` and returns a function that takes an argument x and computes `x^n`

- Example use:

```r
square = power(2)
cube = power(3)
square(2)
[1] 4
cube(2)
[1] 8
```

Function operators
===
- As we've seen, functions can also take other functions as arguments
- We can use this to write functions that take functions, modify them, and return the modified function

```r
set_na.rm = function(f, na.rm) {
  function(x) {
    f(x, na.rm=na.rm)
  }
}
mean_na.rm = set_na.rm(mean, na.rm=T)

x = c(rnorm(100), NA)
mean_na.rm(x)
[1] -0.1533181
```

Functional programming
===
We've discussed a number of **higher-order functions** that either take functions as inputs, return functions as outputs, or both. 
<div align="center">
<img src="https://d33wubrfki0l68.cloudfront.net/1dff819e743f280bbab1c55f8f063e60b6a0d2fb/2269e/diagrams/fp.png">
</div>
- `mean()` is a "regular function". It takes data and returns data
- the `power()` function we made as an exercise is a "function factory". It takes data and returns a function (e.g. `square()` or `cube()`)
- `mutate(across(...))` are "functional". They take a function (and data) and return data
- the `set_na.rm` function we made as an exercise is a "function operator": it takes a function and returns a function

These categories are not explicit constructs that exist in R, they are just a way to think about the power of higher order functions. 

Tidyverse + Functions
===
type: section

Passing column names to tidyverse within functions
===
- Consider this function, which shuffles the `number` column in the passed-in dataframe



```r
data = tibble(
  number = c(1,2,3),
  label = c('a','b','c')
)

shuffle_col_named_number = function(df) {
  df %>% 
    mutate(number = sample(number, nrow(df)))
}

data %>% shuffle_col_named_number()
# A tibble: 3 × 2
  number label
   <dbl> <chr>
1      3 a    
2      1 b    
3      2 c    
```

- What if we wanted to modify it so that `number` weren't hard-coded? Intuitively, we should write something like this:

```r
shuffle_col = function(data, col) {
  data %>% 
    mutate(col = sample(col, nrow(data)))
}
```

Passing column names to tidyverse within functions
===

```r
shuffle_col = function(data, col) {
  data %>% 
    mutate(col = sample(
      col, 
      nrow(data)
    ))
}
```
- Unfortunately, this doesn't work:


```r
data %>% shuffle_col(number)
Error in `mutate()`:
ℹ In argument: `col = sample(col, nrow(data))`.
Caused by error:
! object 'number' not found
```
- The problem is that R doesn't know that `number` should refer to a column in the data, not to an object in the global environment. 

***

- The fix is to use the `{{...}}` syntax to surround the passed in variable name where it gets used in the function. 


```r
shuffle_col = function(data, col) {
  data %>% 
    mutate(new_col = sample(
      {{col}}, 
      nrow(data)
    ))
}

data %>% shuffle_col(number)
# A tibble: 3 × 3
  number label new_col
   <dbl> <chr>   <dbl>
1      1 a           3
2      2 b           2
3      3 c           1
```
- This tells R not to look for that object in the global environment.
- Called "embracing"
- More on this: see https://dplyr.tidyverse.org/articles/programming.html
- It gets complicated but this is the price to be paid for nice tidyverse syntax

Conditional Evaluation
=== 
type: section 

Conditional Evaluation
=== 
- An if statement allows you to conditionally execute code. It looks like this:

```
if (condition) {
  # code executed when condition is TRUE
} else {
  # code executed when condition is FALSE
}
```

- The condition is code that evaluates to TRUE or FALSE

```r
absolute_value = function(x) {
    if (x>0) {
        x
    } else {
        -x
    }
}
absolute_value(2)
[1] 2
absolute_value(-2)
[1] 2
```


Conditional Evaluation
=== 
- if_else is a function that condenses an if-else statement and is good when the condition and bodies of code are very short
- the first argument is the conditon, the second is what it returns when the condition is true, the third is what it returns when the condition is false

```r
absolute_value = function(x) {
    if_else(x>0, x, -x)
}
absolute_value(2)
[1] 2
absolute_value(-2)
[1] 2
```

Multiple conditions 
===

- You can evaluate multiple conditions with if...  else if... else

```r
valence = function(x) {
    if (x>0) {
        "positive"
    } else if (x<0) {
        "negative"
    } else {
        "zero"
    }
}
valence(-12)
[1] "negative"
valence(99)
[1] "positive"
valence(0)
[1] "zero"
```

Exercise: greeting
===
type: prompt
Write a function that takes a vector as input and returns whether or not it has at least 5 elements in it.


Conditions
===
- Conditions can be anything that evaluates to a single `TRUE` or `FALSE`

```r
in_0_1 = function(number) {
  if (0 <= number & number <=1) {
      "in [0,1]"
  } else {
      "not in [0,1]"
  }
}
in_0_1(0.3)
[1] "in [0,1]"
in_0_1(-1.1)
[1] "not in [0,1]"
```
- but not a logical vector or an NA

```r
in_0_1(
  c(0.3, -1.1)
)
Error in if (0 <= number & number <= 1) {: the condition has length > 1
```

if_else
===
- `if_else` is a vectorized if-else statement

```r
in_0_1 = function(x) if_else(0<=x & x<=1, "in [0,1]", "not in [0,1]")
```


```r
in_0_1(
  c(0.3, -1.1)
)
[1] "in [0,1]"     "not in [0,1]"
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

Seeing into lists
===
- Use `str()` to dig into nested lists and other complicated objects

```r
nested_list = list(a_list, 4, gtex_data)
Error in eval(expr, envir, enclos): object 'gtex_data' not found
str(nested_list)
Error in eval(expr, envir, enclos): object 'nested_list' not found
```

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
- and then retrieve elements by name or position or using the tidyverse-friendly `pluck()`

```r
a_list$a_string  # returns the element named "thrid_number"
[1] "hello"
a_list[[3]] # returns the 3rd element
[1] "hello"
a_list[3] # subsets the list, so returns a list of length 1 that contains a single element (the third)
$a_string
[1] "hello"
a_list %>%
  pluck("a_string")
[1] "hello"
```

Using elements in list
===
- If you use the `magrittr` package, you can operate on items in lists with the `%$%` operator (fun fact: the `%>%` operator originally came from `magrittr`)

```r
library(magrittr)
list(a=5, b=6) %$%
  rnorm(10, mean=a, sd=b)
 [1] 12.902410 -3.716592  1.609360 15.113924  4.323319  6.272638  9.270736
 [8] 21.246447  4.848733 10.744141
```
- `%$%` makes the elements of the list on the left-hand side accessible in bare-name form to the expression on the right-hand side so you don't have to type extra dollar signs:

```r
x =  list(a=5, b=6)
rnorm(10, mean=x$a, sd=x$b)
 [1] 11.0099634  5.4482640  0.7418732  7.3853485 16.3768914  6.8653181
 [7] -9.8723235  0.8039850 -0.4716639 -3.2606346
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

Functions returning multiple values
===
- A function can only return a single object
- Often, however, it makes sense to group the calculation of two or more things you want to return within a single function
- You can put all of that into a list and then retrun a single list

```r
min_max = function(x) {
  x_sorted = sort(x)
  list(
    min = x_sorted[1],
    max = x_sorted[length(x)]
  )
}
```
- Why might this code be preferable to running `min()` and then `max()`?

Functions returning multiple values
===
- If you use the `zeallot` package, you can assign multiple values out of a list at once using the `c(...) %<-% ...` syntax

```r
min_max = function(x) {
  x_sorted = sort(x)
  list(
    min = x_sorted[1],
    max = x_sorted[length(x)]
  )
}

library(zeallot)
Error in library(zeallot): there is no package called 'zeallot'
c(min_x, max_x) %<-% min_max(rnorm(10))
Error in c(min_x, max_x) %<-% min_max(rnorm(10)): could not find function "%<-%"
min_x
Error in eval(expr, envir, enclos): object 'min_x' not found
max_x
Error in eval(expr, envir, enclos): object 'max_x' not found
```

Dots
===
- Besides positional and named arguments, functions in R can also be written to take a variable number of arguments!

```r
sum(1)
[1] 1
sum(1,2,3,6) # pass in as many as you want and it still works
[1] 12
```
- Obviously there aren't an infinite number of `sum()` functions to work with all the possible different numbers of arguments
- To write functions like this, use the dots `...` syntax

```r
space_text = function(...) {
  dots = list(...)
  str_c(dots, collapse=" ")
} 

space_text("hello", "there,", "how", "are", "you")
[1] "hello there, how are you"
space_text("fine,", "thanks")
[1] "fine, thanks"
```
- You can get whatever is passed to the function and save it as a (possibly named) list using `list(...)`

Dots
===
- This is useful when you want to pass on a bunch of arbitrary named arguments to another function, but hardcode one or more of them

```r
mean_no_na = function(...) {
  mean(..., na.rm=T)
}
x = c(rnorm(100), NA)
mean(x)
[1] NA
mean_no_na(x)
[1] 0.01344655
mean_no_na(x, trim=0.5)
[1] 0.01756683
mean(x, trim=0.5, na.rm=T)
[1] 0.01756683
```
- Note how `trim` gets passed through as an argument to `mean()` even though it is not specified as an argument in the function declaration of `mean_no_na()`

Exercise: ggplot with 
===
type: prompt
- Use the dots to create a fully-featured function (call it `ggplot_redpoint()`), that works exactly like `ggplot()` except that it automatically adds a geom with red points.
- Test it out using data of your choice


Example: 

```r
# similarity between expression of genes in blood and lung 
gtex_data %>%
  filter(Ind=="GTEX-11DXZ") %>% # look at one person
ggplot_redpoint(aes(Blood, Lung)) 
Error in eval(expr, envir, enclos): object 'gtex_data' not found
```

Iteration
===
type:section

Map
===
- Map is a function that takes a list (or vector) as its first argument and a function as its second argument
- Recall that functions are objects just like anything else so you can pass them around to other functions
- Map then runs that function on each element of the first argument, slaps 
the results together into a list, and returns that

```r
numbers = rnorm(3)
map(numbers, in_0_1)
[[1]]
[1] "in [0,1]"

[[2]]
[1] "not in [0,1]"

[[3]]
[1] "not in [0,1]"
```
- Equivalently:

```r
numbers %>%
  map(in_0_1)
[[1]]
[1] "in [0,1]"

[[2]]
[1] "not in [0,1]"

[[3]]
[1] "not in [0,1]"
```
- this is really only useful when your function isn't already vectorized

```r
in_0_1(numbers)
[1] "in [0,1]"     "not in [0,1]" "not in [0,1]"
```

Map 
===
- for example, let's say you want to read in multiple files:

```r
url_start = "https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/summer-2023/data/gtex_metadata/"
files = list(
  samples = "gtex_samples_time.csv",
  tissues = "gtex_tissue_month_year.csv",
  dates = "gtex_dates_clean.csv"
)

urls = str_c(url_start, files)
```


```r
data_frames = urls %>%
  map(read_csv)
```

Names are preserved through map
===
- If the input list (or vector) has names, the output will have elements with the same names

```r
read_gtex = function(file) {
  str_c(url_start, file) %>%
    read_csv()
}

data_frames = files %>%
  map(read_gtex)

names(data_frames)
[1] "samples" "tissues" "dates"  
```


Returning other data types
===
- `map()` typically returns a list (why?)
- But there are variants that return different data types


```r
data_frames %>%
  map_dbl(nrow)
samples tissues   dates 
     66    1475    1234 
```


```r
count_rc = function(df) {
  tibble(
    n_rows = nrow(df),
    n_cols = ncol(df)
  )
}

data_frames %>%
  map_df(count_rc)
# A tibble: 3 × 2
  n_rows n_cols
   <int>  <int>
1     66      3
2   1475      4
3   1234      6
```

Anonymous function syntax
===
- up until now we had to define our functions outside of map and then pass them in as an argument:

```r
count_rc = function(df) {
  tibble(
    n_rows = nrow(df),
    n_cols = ncol(df)
  )
}

data_frames %>%
  map_df(count_rc)
```

***
- Instead, we can define a function inside of another function call.
- These functions are "anonymous" because they are never assigned a name and will not be used again


```r
data_frames %>%
  map_df(\(df) tibble(
    n_rows = nrow(df),
    n_cols = ncol(df)
  ))
```

- the syntax is `\(ARGUMENTS) BODY`
- just an abbreviation for `function(ARGUMENTS) {BODY}`

Exercise: map practice
===
type: prompt
- Determine the type of each column in `gtex_data` (`?typeof`). Return the result as a vector of strings (note: a data frame is a list of columns)
- For each value of x in [1, 5, 10] Generate 10 random numbers between 0 and x (see: `?runif`).

Mapping over multiple inputs
===
- So far we’ve mapped along a single input. But often you have multiple related inputs that you need iterate along in parallel. That’s the job of `pmap()`. For example, imagine you want to draw a random numbers between `a` and `b` as both of those vary:

```r
a = c(1,2,3)
b = c(2,3,4)

runif(1, a[1], b[1])
[1] 1.378294
runif(1, a[2], b[2])
[1] 2.636525
runif(1, a[3], b[3])
[1] 3.607102
```

***
- `pmap` makes this easier:

```r
list(
  a = c(1,2,3),
  b = c(2,3,4)
) %>% pmap(
  \(a,b) runif(1,a,b)
)
[[1]]
[1] 1.276116

[[2]]
[1] 2.998924

[[3]]
[1] 3.008604
```


<div align="center">
<img src="https://dcl-prog.stanford.edu/images/pmap-flipped.png">
</div>

Creating a grid of values
=== 
- `expand_grid()` gives you every combination of the items in the list you pass it

```r
expand_grid(
    a = c(1,2,3),
    b = c(10,11)
  )
# A tibble: 6 × 2
      a     b
  <dbl> <dbl>
1     1    10
2     1    11
3     2    10
4     2    11
5     3    10
6     3    11
```

Exercise: reading files in multiple directories 
===
type: prompt
My collaborator has an online folder of experimental results named `results` that can be found at `"https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/summer-2023/data/results"`. In that folder, there are 20 sub-folders that represent the results of each repetition of her experiment. These sub-folders are each named `rep_n`, so, e.g. `results/rep_14` would be one sub-folder. Within each sub-folder, there are 3 csv files called `a.csv`, `b.csv` `c.csv` that contain different kinds of measurements. Thus, a full path to one of these files might be `results/rep_14/c.csv`.

1. write code to read these all into one long list of data frames. `str_c()` or `glue()` will be helpful.


2. Unfortunately, that wasn't helpful because now you don't know what data frames are what results. Consider just the `a` files. Write code that reads in all of the `a` files and concatenates them into one data frame. Include a column in this data frame that indicates which experimental repetition each row of the data frame came from.


3. Turn your code from above into a function that takes as input the file name (`'a'`, for example) and returns the single concatenated file. Iterate that function over the different file names to output three master data frames corresponding to the file types `'a'`, `'b'`, and `'c'`.


Why not for loops?
===
- R also provides something called a `for` loop, which is common to many other languages as well. It looks like this:

```r
data_frames = list(NA, NA, NA)
for (i in 1:3) {
  data_frames[[i]] = read_csv(urls[[i]])
}
```
- The `for` loop is very flexible and you can do a lot with it
- `for` loops are unavoidable when the result of one iteration depends on the result of the last iteration

***

- Compare to the `map()`-style solution:

```r
data_frames = urls %>%
  map(read_csv)
```
- Compared to the `for` loop, the `map()` syntax is much more concise and eliminates much of the "admin" code in the loop (setting up indices, initializing the list that will be filled in, indexing into the data structures)
- The `map()` syntax also encourages you to write a function for whatever is happening inside the loop. This means you have something that's reusable and easily testable, and your code will look cleaner
- Loops in R can be catastrophically slow due to the complexities of [copy-on-modify semantics](https://adv-r.hadley.nz/names-values.html). 

purrr Cheatsheet
===
<div align="center">
<img src="https://rstudio.com/wp-content/uploads/2018/08/purrr.png"
</div>

