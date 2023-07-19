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
<bytecode: 0x107079510>
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
[1] 0.02698975
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
My collaborator has an online folder of experimental results named `results` that can be found at . In that folder, there are 100 sub-folders that represent the results of each repetition of her experiment. These sub-folders are each named `rep_n`, so, e.g. `results/rep_22` would be one sub-folder. Within each sub-folder, there are 6 csv files called `a.csv`, `b.csv` ... `f.csv` that contain different kinds of measurements. Thus, a full path to one of these files might be `results/rep_22/c.csv`.


```r
data_dir = '~/Desktop/results'
dir.create(data_dir)

reps = 1:100
files = c('a','b','c','d','e','f')

reps %>%
  walk(~dir.create(str_c(data_dir,'/rep_',.)))

gen_file = function(r,f,p) {
  n = sample.int(100, size=1)
  
  runif(n*p) %>%
    matrix(n,p) %>%
    as_tibble() %>%
    write_csv(
      str_c(data_dir,'/rep_',r,'/',f,'.csv')
    )
}

files %>%
  map(\(f){
    p = sample.int(10,size=1)
    
    reps %>%
      map(gen_file, f, p)
  })
Warning: The `x` argument of `as_tibble.matrix()` must have unique column names if
`.name_repair` is omitted as of tibble 2.0.0.
ℹ Using compatibility `.name_repair`.
This warning is displayed once every 8 hours.
Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
generated.
[[1]]
[[1]][[1]]
# A tibble: 80 × 8
        V1     V2    V3     V4     V5    V6    V7    V8
     <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>
 1 0.748   0.316  0.410 0.178  0.994  0.892 0.393 0.297
 2 0.119   0.133  0.255 0.152  0.0591 0.191 0.623 0.346
 3 0.167   0.276  0.400 0.249  0.619  0.803 0.893 0.388
 4 0.00486 0.244  0.884 0.823  0.0383 0.490 0.829 0.132
 5 0.0241  0.0120 0.981 0.0260 0.253  0.208 0.144 0.479
 6 0.555   0.514  0.315 0.111  0.561  0.294 0.359 0.534
 7 0.279   0.954  0.943 0.548  0.525  0.356 0.970 0.526
 8 0.920   0.0345 0.978 0.0230 0.960  0.330 0.761 0.249
 9 0.834   0.529  0.149 0.897  0.117  0.868 0.121 0.281
10 0.944   0.0396 0.398 0.925  0.840  0.369 0.685 0.531
# ℹ 70 more rows

[[1]][[2]]
# A tibble: 9 × 8
       V1    V2    V3    V4     V5    V6     V7    V8
    <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl>
1 0.147   0.206 0.716 0.505 0.165  0.845 0.315  0.273
2 0.232   0.881 0.784 0.873 0.116  0.507 0.0485 0.294
3 0.792   0.625 0.828 0.272 0.243  0.663 0.172  0.363
4 0.859   0.394 0.666 0.211 0.643  0.547 0.0655 0.796
5 0.694   0.166 0.421 0.920 0.365  0.907 0.453  0.156
6 0.930   0.418 0.744 0.378 0.242  0.534 0.623  0.505
7 0.280   0.350 0.366 0.264 0.0243 0.852 0.407  0.327
8 0.00565 0.196 0.227 0.698 0.335  0.975 0.0289 0.810
9 0.362   0.486 0.252 0.191 0.628  0.257 0.679  0.807

[[1]][[3]]
# A tibble: 70 × 8
       V1    V2     V3     V4    V5     V6      V7     V8
    <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl>   <dbl>  <dbl>
 1 0.532  0.809 0.676  0.750  0.512 0.944  0.264   0.295 
 2 0.0895 0.104 0.197  0.0528 0.743 0.327  0.110   0.0990
 3 0.253  0.293 0.345  0.107  0.669 0.457  0.661   0.561 
 4 0.690  0.116 0.582  0.760  0.393 0.953  0.944   0.911 
 5 0.457  0.577 0.879  0.291  0.308 0.770  0.713   0.244 
 6 0.504  0.299 0.0535 0.517  1.00  0.180  0.00392 0.708 
 7 0.683  0.655 0.191  0.774  0.675 0.469  0.311   0.0978
 8 0.461  0.225 0.0548 0.540  0.539 0.0490 0.190   0.961 
 9 0.201  0.552 0.714  0.0349 0.648 0.634  0.823   0.198 
10 0.0336 0.869 0.863  0.995  0.904 0.834  0.392   0.337 
# ℹ 60 more rows

[[1]][[4]]
# A tibble: 55 × 8
        V1     V2    V3    V4     V5     V6     V7     V8
     <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.571   0.163  0.237 0.625 0.840  0.315  0.591  0.628 
 2 0.154   0.669  0.143 0.821 0.952  0.354  0.400  0.880 
 3 0.718   0.0669 0.992 0.301 0.645  0.373  0.115  0.331 
 4 0.614   0.975  0.329 0.647 0.0299 0.836  0.867  0.183 
 5 0.880   0.336  0.644 0.811 0.144  0.0484 0.851  0.716 
 6 0.975   0.100  0.266 0.830 0.459  0.837  0.0318 0.563 
 7 0.951   0.154  0.939 0.291 0.778  0.690  0.493  0.899 
 8 0.506   0.0662 0.791 0.746 0.499  0.504  0.942  0.556 
 9 0.565   0.266  0.143 0.361 0.300  0.345  0.875  0.0305
10 0.00769 0.250  0.735 0.210 0.334  0.721  0.507  0.897 
# ℹ 45 more rows

[[1]][[5]]
# A tibble: 16 × 8
      V1     V2     V3     V4      V5      V6    V7     V8
   <dbl>  <dbl>  <dbl>  <dbl>   <dbl>   <dbl> <dbl>  <dbl>
 1 0.405 0.469  0.248  0.684  0.320   0.680   0.534 0.405 
 2 0.568 0.731  0.261  0.821  0.00271 0.0139  0.282 0.753 
 3 0.614 0.723  0.475  0.290  0.0174  0.280   0.132 0.994 
 4 0.341 0.0780 0.643  0.478  0.697   0.500   0.895 0.376 
 5 0.634 0.831  0.951  0.292  0.876   0.202   0.928 0.543 
 6 0.253 0.614  0.0399 0.618  0.218   0.779   0.137 0.919 
 7 0.656 0.570  0.424  0.790  0.572   0.901   0.281 0.940 
 8 0.721 0.895  0.597  0.712  0.400   0.451   0.912 0.781 
 9 0.534 0.954  0.409  0.505  0.384   0.112   0.849 0.686 
10 0.569 0.895  0.988  0.892  0.191   0.903   0.559 0.366 
11 0.242 0.0889 0.553  0.805  0.156   0.492   0.634 0.648 
12 0.138 0.285  0.710  0.600  0.161   0.304   0.290 0.299 
13 0.651 0.859  0.651  0.0415 0.206   0.840   0.821 0.775 
14 0.702 0.201  0.742  0.777  0.921   0.247   0.532 0.609 
15 0.905 0.324  0.440  0.236  0.260   0.00552 0.491 0.0128
16 0.896 0.540  0.357  0.455  0.973   0.910   0.950 0.962 

[[1]][[6]]
# A tibble: 18 × 8
      V1     V2     V3     V4      V5       V6     V7     V8
   <dbl>  <dbl>  <dbl>  <dbl>   <dbl>    <dbl>  <dbl>  <dbl>
 1 0.565 0.947  0.0316 0.0963 0.237   0.920    0.623  0.0478
 2 0.798 0.677  0.382  0.338  0.337   0.129    0.625  0.872 
 3 0.157 0.317  0.544  0.595  0.549   0.386    0.285  0.818 
 4 0.662 0.361  0.951  0.603  0.986   0.273    0.594  0.604 
 5 0.332 0.0719 0.615  0.538  0.438   0.156    0.205  0.747 
 6 0.797 0.855  0.0724 0.777  0.490   0.458    0.171  0.109 
 7 0.545 0.0904 0.0905 0.665  0.157   0.581    0.631  0.168 
 8 0.216 0.856  0.245  0.501  0.00125 0.0302   0.512  0.769 
 9 0.375 0.531  0.789  0.171  0.369   0.0620   0.351  0.488 
10 0.691 0.255  0.758  0.613  0.109   0.714    0.729  0.673 
11 0.955 0.242  0.894  0.217  0.705   0.354    0.117  0.541 
12 0.631 0.495  0.313  0.385  0.836   0.000530 0.164  0.843 
13 0.739 0.219  0.0475 0.669  0.533   0.774    0.0160 0.302 
14 0.990 0.900  0.581  0.905  0.377   0.228    0.456  0.332 
15 0.512 0.928  0.457  0.689  0.0836  0.423    0.579  0.0767
16 0.100 0.215  0.701  0.831  0.998   0.285    0.441  0.828 
17 0.714 0.463  0.387  0.806  0.305   0.346    0.731  0.118 
18 0.787 0.152  0.634  0.868  0.401   0.566    0.320  0.174 

[[1]][[7]]
# A tibble: 52 × 8
       V1    V2     V3    V4    V5     V6    V7     V8
    <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.328  0.338 0.210  0.307 0.347 0.0527 0.132 0.528 
 2 0.208  0.390 0.791  0.527 0.542 0.366  0.313 0.862 
 3 0.968  0.991 0.652  0.366 0.559 0.0658 0.379 0.0816
 4 0.167  0.296 0.312  0.854 0.758 0.682  0.879 0.882 
 5 0.728  0.813 0.0282 0.280 0.207 0.864  0.601 0.573 
 6 0.682  0.873 0.965  0.552 0.900 0.594  0.883 0.763 
 7 0.799  0.777 0.755  0.455 0.107 0.0179 0.474 0.281 
 8 0.165  0.987 0.868  0.506 0.610 0.959  0.754 0.726 
 9 0.0712 0.626 0.335  0.693 0.111 0.644  0.245 0.0783
10 0.473  0.555 0.721  0.413 0.247 0.486  0.102 0.369 
# ℹ 42 more rows

[[1]][[8]]
# A tibble: 52 × 8
       V1    V2     V3     V4     V5    V6    V7     V8
    <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.548  0.139 0.0748 0.684  0.334  0.119 0.192 0.376 
 2 0.456  0.234 0.0939 0.234  0.450  0.886 0.452 0.885 
 3 0.541  0.928 0.860  0.122  0.576  0.320 0.465 0.705 
 4 0.380  0.934 0.460  0.389  0.886  0.247 0.544 0.918 
 5 0.846  0.689 0.654  0.292  0.892  0.837 0.353 0.105 
 6 0.0842 0.699 0.191  0.585  0.987  0.395 0.743 0.832 
 7 0.133  0.598 0.666  0.930  0.193  0.265 0.506 0.0654
 8 0.0807 0.711 0.0211 0.102  0.571  0.525 0.455 0.657 
 9 0.391  0.632 0.290  0.947  0.0636 0.365 0.817 0.615 
10 0.657  0.276 0.964  0.0904 0.785  0.506 0.485 0.271 
# ℹ 42 more rows

[[1]][[9]]
# A tibble: 39 × 8
      V1     V2    V3    V4     V5    V6     V7     V8
   <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.707 0.478  0.845 0.234 0.868  0.230 0.0496 0.213 
 2 0.970 0.323  0.259 0.347 0.550  0.358 0.856  0.489 
 3 0.303 0.648  0.592 0.773 0.886  0.301 0.728  0.616 
 4 0.611 0.266  0.639 0.454 0.215  0.467 0.743  0.176 
 5 0.307 0.0333 0.237 0.169 0.969  0.153 0.339  0.591 
 6 0.256 0.943  0.328 0.777 0.995  0.874 0.823  0.362 
 7 0.774 0.926  0.139 0.297 0.736  0.746 0.386  0.0672
 8 0.629 0.122  0.681 0.456 0.451  0.449 0.608  0.531 
 9 0.779 0.0570 0.208 0.808 0.0466 0.374 0.845  0.428 
10 0.762 0.0502 0.630 0.416 0.765  0.482 0.296  0.792 
# ℹ 29 more rows

[[1]][[10]]
# A tibble: 75 × 8
      V1     V2    V3      V4    V5     V6     V7     V8
   <dbl>  <dbl> <dbl>   <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.189 0.498  0.486 0.233   0.468 0.834  0.0315 0.712 
 2 0.782 0.0471 0.909 0.425   0.151 0.288  0.413  0.863 
 3 0.304 0.392  0.505 0.384   0.853 0.0958 0.235  0.600 
 4 0.726 0.768  0.418 0.604   0.258 0.258  0.256  0.688 
 5 0.817 0.899  0.462 0.0523  0.797 0.241  0.540  0.978 
 6 0.320 0.826  0.116 0.296   0.846 0.593  0.966  0.938 
 7 0.938 0.996  0.640 0.704   0.308 0.998  0.549  0.0804
 8 0.906 0.575  0.862 0.00559 0.814 0.109  0.510  0.561 
 9 0.484 0.731  0.978 0.459   0.145 0.906  0.950  0.739 
10 0.640 0.440  0.206 0.274   0.155 0.631  0.675  0.232 
# ℹ 65 more rows

[[1]][[11]]
# A tibble: 44 × 8
       V1      V2     V3    V4     V5    V6    V7     V8
    <dbl>   <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.520  0.366   0.690  0.106 0.483  0.714 0.332 0.745 
 2 0.563  0.283   0.360  0.286 0.357  0.158 0.826 0.836 
 3 0.864  0.824   0.772  0.787 0.289  0.432 0.557 0.0358
 4 0.725  0.982   0.795  0.329 0.827  0.184 0.236 0.0469
 5 0.420  0.320   0.603  0.883 0.0132 0.860 0.843 0.393 
 6 0.205  0.00434 0.777  0.617 0.692  0.362 0.555 0.747 
 7 0.334  0.456   0.792  0.341 0.943  0.231 0.179 0.107 
 8 0.969  0.132   0.0471 0.922 0.255  0.692 0.949 0.705 
 9 0.334  0.196   0.200  0.769 0.786  0.808 0.986 0.466 
10 0.0299 0.594   0.570  0.925 0.398  0.872 0.219 0.149 
# ℹ 34 more rows

[[1]][[12]]
# A tibble: 73 × 8
       V1     V2    V3     V4         V5    V6      V7     V8
    <dbl>  <dbl> <dbl>  <dbl>      <dbl> <dbl>   <dbl>  <dbl>
 1 0.604  0.136  0.667 0.579  0.390      0.350 0.383   0.655 
 2 0.887  0.861  0.454 0.205  0.950      0.899 0.0958  0.599 
 3 0.0466 0.765  0.720 0.467  0.00000930 0.923 0.232   0.309 
 4 0.819  0.0143 0.889 0.0795 0.378      0.494 0.863   0.0134
 5 0.151  0.949  0.110 0.347  0.588      0.682 0.501   0.854 
 6 0.919  0.724  0.364 0.770  0.941      0.566 0.935   0.409 
 7 0.222  0.228  0.186 0.208  0.576      0.321 0.964   0.962 
 8 0.0283 0.156  0.392 0.426  0.314      0.551 0.386   0.608 
 9 0.387  0.0479 0.772 0.521  0.613      0.534 0.226   0.631 
10 0.104  0.0842 0.894 0.277  0.472      0.791 0.00594 0.371 
# ℹ 63 more rows

[[1]][[13]]
# A tibble: 94 × 8
      V1      V2     V3     V4    V5     V6    V7     V8
   <dbl>   <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.972 0.241   0.0366 0.247  0.886 0.606  0.433 0.303 
 2 0.980 0.00591 0.941  0.195  0.274 0.553  0.241 0.661 
 3 0.897 0.0603  0.989  0.261  0.581 0.185  0.102 0.336 
 4 0.875 0.0779  0.680  0.202  0.989 0.421  0.210 0.0150
 5 0.767 0.441   0.252  0.620  0.392 0.0167 0.761 0.398 
 6 0.361 0.120   0.0693 0.771  0.874 0.0251 0.705 0.231 
 7 0.558 0.186   0.507  0.472  0.179 0.0692 0.355 0.666 
 8 0.442 0.793   0.930  0.625  0.252 0.978  0.870 0.460 
 9 0.485 0.953   0.657  0.0922 0.822 0.350  0.493 0.702 
10 0.669 0.0793  0.111  0.128  0.310 0.611  0.845 0.974 
# ℹ 84 more rows

[[1]][[14]]
# A tibble: 95 × 8
      V1     V2    V3     V4    V5     V6    V7     V8
   <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.913 0.813  0.638 0.948  0.863 0.0550 0.179 0.234 
 2 0.304 0.807  0.560 0.372  0.659 0.734  0.469 0.660 
 3 0.813 0.611  0.743 0.416  0.270 0.369  0.411 0.805 
 4 0.799 0.771  0.602 0.260  0.501 0.772  0.968 0.478 
 5 0.749 0.0432 0.323 0.597  0.741 0.595  0.915 0.0431
 6 0.766 0.790  0.958 0.161  0.653 0.0199 0.529 0.361 
 7 0.773 0.244  0.778 0.787  0.841 0.726  0.338 0.626 
 8 0.381 0.847  0.238 0.571  0.760 0.664  0.972 0.979 
 9 0.229 0.541  0.361 0.130  0.426 0.592  0.250 0.815 
10 0.777 0.331  0.229 0.0924 0.839 0.386  0.199 0.594 
# ℹ 85 more rows

[[1]][[15]]
# A tibble: 46 × 8
       V1     V2    V3     V4    V5     V6      V7    V8
    <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>   <dbl> <dbl>
 1 0.150  0.863  0.352 0.908  0.460 0.0323 0.392   0.366
 2 0.768  0.778  0.128 0.0278 0.830 0.784  0.618   0.675
 3 0.0103 0.306  0.366 0.988  0.610 0.532  0.498   0.844
 4 0.202  0.820  0.660 0.675  0.211 0.443  0.437   0.334
 5 0.292  0.892  0.997 0.931  0.731 0.977  0.0513  0.812
 6 0.513  0.356  0.196 0.140  0.983 0.569  0.0933  0.758
 7 0.805  0.819  0.134 0.375  0.965 0.739  0.500   0.914
 8 0.321  0.597  0.803 0.243  0.688 0.192  0.00704 0.802
 9 0.748  0.631  0.602 0.0649 0.406 0.775  0.440   0.661
10 0.310  0.0930 0.536 0.0731 0.791 0.845  0.668   0.466
# ℹ 36 more rows

[[1]][[16]]
# A tibble: 16 × 8
       V1      V2     V3      V4    V5     V6     V7     V8
    <dbl>   <dbl>  <dbl>   <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.444  0.308   0.934  0.379   0.425 0.126  0.342  0.177 
 2 0.642  0.454   0.403  0.170   0.379 0.930  0.697  0.786 
 3 0.106  0.371   0.0296 0.631   0.978 0.705  0.0500 0.995 
 4 0.212  0.0254  0.757  0.423   0.881 0.355  0.330  0.353 
 5 0.444  0.969   0.725  0.0156  0.257 0.777  0.612  0.748 
 6 0.334  0.646   0.333  0.858   0.966 0.338  0.372  0.441 
 7 0.0996 0.619   0.708  0.999   0.558 0.768  0.570  0.332 
 8 0.684  0.625   0.563  0.449   0.261 0.310  0.915  0.921 
 9 0.723  0.438   0.335  0.806   0.596 0.231  0.514  0.759 
10 0.123  0.175   0.465  0.529   0.726 0.602  0.901  0.459 
11 0.664  0.00426 0.298  0.637   0.930 0.0662 0.0451 0.0280
12 0.858  0.902   0.193  0.626   0.397 0.713  0.947  0.155 
13 0.0541 0.486   0.288  0.180   0.697 0.163  0.652  0.189 
14 0.851  0.719   0.579  0.00242 0.394 0.505  0.411  0.502 
15 0.543  0.0741  0.171  0.138   0.801 0.402  0.804  0.508 
16 0.0631 0.749   0.341  0.728   0.122 0.0136 0.867  0.246 

[[1]][[17]]
# A tibble: 8 × 8
       V1     V2     V3    V4     V5     V6    V7     V8
    <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl>
1 0.578   0.678  0.241  0.508 0.489  0.629  0.793 0.258 
2 0.479   0.167  0.0368 0.381 0.0632 0.532  0.356 0.742 
3 0.546   0.828  0.592  0.784 0.249  0.805  0.609 0.843 
4 0.530   0.771  0.115  0.182 0.0398 0.506  0.750 0.808 
5 0.696   0.195  0.314  0.647 0.352  0.986  0.947 0.0347
6 0.00156 0.739  0.886  0.312 0.322  0.800  0.726 0.171 
7 0.112   0.947  0.874  0.232 0.197  0.0846 0.142 0.232 
8 0.620   0.0413 0.849  0.110 0.305  0.718  0.180 0.595 

[[1]][[18]]
# A tibble: 17 × 8
       V1     V2    V3    V4     V5    V6     V7       V8
    <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>    <dbl>
 1 0.486  0.974  0.362 0.424 0.103  0.475 0.101  0.183   
 2 0.586  0.970  0.695 0.951 0.499  0.832 0.117  0.270   
 3 0.763  0.210  0.716 0.666 0.0103 0.332 0.941  0.000499
 4 0.335  0.281  0.954 0.845 0.174  0.902 0.681  0.816   
 5 0.484  0.723  0.530 0.320 0.864  0.603 0.576  0.596   
 6 0.413  0.344  0.816 0.434 0.793  0.727 0.299  0.131   
 7 0.277  0.424  0.646 0.893 0.659  0.397 0.664  0.884   
 8 0.285  0.434  0.105 0.515 0.148  0.587 0.308  0.491   
 9 0.537  0.482  0.139 0.685 0.142  0.796 0.0940 0.959   
10 0.341  0.0405 0.696 0.304 0.822  0.759 0.770  0.170   
11 0.151  0.261  0.470 0.982 0.147  0.757 0.830  0.173   
12 0.0814 0.850  0.268 0.557 0.232  0.806 0.708  0.743   
13 0.945  0.970  0.814 0.292 0.388  0.219 0.707  0.321   
14 0.820  0.625  0.192 0.175 0.275  0.242 0.130  0.960   
15 0.697  0.562  0.945 0.406 0.306  0.542 0.905  0.518   
16 0.353  0.0454 0.789 0.409 0.473  0.921 0.963  0.689   
17 0.0484 0.356  0.905 0.630 0.364  0.507 0.979  0.642   

[[1]][[19]]
# A tibble: 40 × 8
       V1     V2     V3    V4     V5    V6     V7     V8
    <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.932  0.950  0.683  0.188 0.0475 0.865 0.135  0.602 
 2 0.717  0.0420 0.687  0.954 0.526  0.353 0.358  0.0710
 3 0.626  0.745  0.396  0.228 0.0239 0.163 0.0275 0.562 
 4 0.592  0.997  0.157  0.523 0.596  0.997 0.187  0.890 
 5 0.844  0.875  0.772  0.116 0.435  0.175 0.268  0.599 
 6 0.801  0.659  0.406  0.285 0.467  0.411 0.956  0.988 
 7 0.829  0.440  0.879  0.338 0.0453 0.974 0.245  0.404 
 8 0.888  0.356  0.0338 0.292 0.655  0.685 0.302  0.788 
 9 0.912  0.690  0.998  0.935 0.626  0.630 0.495  0.454 
10 0.0588 0.0809 0.625  0.250 0.644  0.525 0.450  0.429 
# ℹ 30 more rows

[[1]][[20]]
# A tibble: 31 × 8
       V1    V2      V3    V4      V5     V6     V7     V8
    <dbl> <dbl>   <dbl> <dbl>   <dbl>  <dbl>  <dbl>  <dbl>
 1 0.743  0.134 0.297   0.839 0.296   0.104  0.630  0.0608
 2 0.0369 0.328 0.512   0.477 0.826   0.827  0.727  0.191 
 3 0.266  0.238 0.00731 0.317 0.834   0.614  0.573  0.0626
 4 0.108  0.325 0.0229  0.166 0.858   0.183  0.689  0.659 
 5 0.623  0.288 0.232   0.714 0.915   0.187  0.450  0.611 
 6 0.338  0.823 0.423   0.577 0.188   0.978  0.177  0.742 
 7 0.547  0.467 0.588   0.385 0.219   0.684  0.818  0.0647
 8 0.781  0.445 0.574   0.263 0.865   0.0796 0.0668 0.215 
 9 0.187  0.762 0.570   0.948 0.450   0.558  0.576  0.790 
10 0.514  0.221 0.592   0.425 0.00171 0.836  0.391  0.269 
# ℹ 21 more rows

[[1]][[21]]
# A tibble: 7 × 8
      V1      V2    V3     V4     V5     V6    V7     V8
   <dbl>   <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
1 0.867  0.343   0.335 0.476  0.600  0.228  0.401 0.609 
2 0.839  0.842   0.224 0.595  0.279  0.0519 0.442 0.307 
3 0.0596 0.00917 0.459 0.353  0.532  0.436  0.387 0.832 
4 0.395  0.382   0.874 0.166  0.0543 0.634  0.156 0.512 
5 0.300  0.632   0.393 0.0971 0.520  0.325  0.867 0.0779
6 0.409  0.874   0.878 0.184  0.535  0.255  0.475 0.913 
7 0.852  0.378   0.457 0.507  0.0807 0.192  0.214 0.799 

[[1]][[22]]
# A tibble: 16 × 8
      V1     V2     V3     V4     V5     V6     V7     V8
   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.368 0.540  0.370  0.329  0.406  0.119  0.406  0.0806
 2 0.794 0.535  0.973  0.857  0.148  0.661  0.260  0.880 
 3 0.387 0.0420 0.0639 0.135  0.257  0.495  0.294  0.885 
 4 0.787 0.0104 0.678  0.794  0.0922 0.635  0.0830 0.484 
 5 0.373 0.111  0.0996 0.848  0.179  0.248  0.498  0.537 
 6 0.737 0.0729 0.522  0.241  0.288  0.179  0.515  0.842 
 7 0.526 0.204  0.946  0.659  0.742  0.931  0.855  0.369 
 8 0.983 0.646  0.827  0.931  0.926  0.886  0.534  0.925 
 9 0.894 0.112  0.912  0.0116 0.249  0.439  0.175  0.596 
10 0.397 0.600  0.582  0.467  0.386  0.485  0.354  0.532 
11 0.344 0.590  0.968  0.894  0.832  0.0932 0.963  0.153 
12 0.161 0.540  0.222  0.842  0.698  0.536  0.655  0.490 
13 0.704 0.220  0.682  0.565  0.565  0.790  0.292  0.695 
14 0.670 0.401  0.0510 0.847  0.511  0.331  0.739  0.822 
15 0.444 0.724  0.469  0.502  0.157  0.0423 0.0464 0.510 
16 0.229 0.339  0.891  0.488  0.596  0.421  0.534  0.797 

[[1]][[23]]
# A tibble: 47 × 8
       V1     V2     V3     V4      V5     V6      V7     V8
    <dbl>  <dbl>  <dbl>  <dbl>   <dbl>  <dbl>   <dbl>  <dbl>
 1 0.317  0.0285 0.285  0.703  0.00443 0.374  0.819   0.676 
 2 0.738  0.123  0.877  0.541  0.432   0.634  0.303   0.0455
 3 0.167  0.530  0.668  0.0595 0.800   0.630  0.927   0.998 
 4 0.417  0.686  0.124  0.0509 0.675   0.266  0.559   0.319 
 5 0.928  0.798  0.452  0.208  0.0197  0.961  0.774   0.626 
 6 0.411  0.610  0.0835 0.636  0.341   0.918  0.454   0.984 
 7 0.0403 0.497  0.345  0.593  0.644   0.0825 0.731   0.459 
 8 0.0937 0.887  0.703  0.726  0.499   0.837  0.0567  0.160 
 9 0.407  0.863  0.361  0.959  0.243   0.989  0.00831 0.967 
10 0.983  0.0710 0.757  0.272  0.701   0.601  0.288   0.0422
# ℹ 37 more rows

[[1]][[24]]
# A tibble: 80 × 8
      V1     V2    V3     V4     V5     V6     V7     V8
   <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.606 0.814  0.805 0.0205 0.720  0.317  0.976  0.625 
 2 0.369 0.347  0.726 0.0262 0.635  0.683  0.272  0.283 
 3 0.336 0.822  0.668 0.706  0.743  0.0757 0.515  0.694 
 4 0.126 0.408  0.966 0.430  0.799  0.115  0.0639 0.447 
 5 0.304 0.685  0.644 0.312  0.702  0.942  0.756  0.0827
 6 0.557 0.170  0.326 0.235  0.917  0.979  0.495  0.685 
 7 0.340 0.962  0.278 0.772  0.882  0.112  0.623  0.255 
 8 0.400 0.0159 0.446 0.299  0.0318 0.345  0.942  0.0683
 9 0.536 0.313  0.967 0.107  0.424  0.491  0.0150 0.874 
10 0.527 0.566  0.522 0.159  0.643  0.576  0.710  0.163 
# ℹ 70 more rows

[[1]][[25]]
# A tibble: 13 × 8
       V1    V2      V3    V4     V5     V6      V7     V8
    <dbl> <dbl>   <dbl> <dbl>  <dbl>  <dbl>   <dbl>  <dbl>
 1 0.316  0.630 0.861   0.247 0.387  0.175  0.977   0.904 
 2 0.150  0.451 0.414   0.699 0.802  0.170  0.672   0.951 
 3 0.676  0.767 0.00466 0.649 0.799  0.787  0.199   0.205 
 4 0.919  0.645 0.275   0.707 0.205  0.0827 0.760   0.996 
 5 0.817  0.235 0.825   0.776 0.868  0.298  0.659   0.275 
 6 0.693  0.409 0.0856  0.705 0.290  0.263  0.545   0.426 
 7 0.573  0.189 0.201   0.540 0.863  0.0682 0.214   0.767 
 8 0.800  0.182 0.591   0.815 0.373  0.145  0.00454 0.188 
 9 0.154  0.994 0.0918  0.564 0.576  0.861  0.621   0.0705
10 0.869  0.791 0.793   0.656 0.554  0.161  0.898   0.991 
11 0.450  0.705 0.247   0.199 0.625  0.0746 0.198   0.994 
12 0.495  0.300 0.528   0.141 0.0349 0.169  0.660   0.138 
13 0.0160 0.626 0.792   0.223 0.478  0.406  0.703   0.583 

[[1]][[26]]
# A tibble: 71 × 8
      V1    V2    V3    V4    V5     V6     V7     V8
   <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.316 0.441 0.948 0.382 0.993 0.879  0.0922 0.561 
 2 0.682 0.507 0.488 0.241 0.527 0.770  0.0346 0.237 
 3 0.568 0.660 0.865 0.600 0.947 0.0352 0.549  0.379 
 4 0.820 0.115 0.553 0.709 0.973 0.578  0.791  0.0266
 5 0.722 0.111 0.704 0.192 0.117 0.546  0.131  0.644 
 6 0.190 0.527 0.784 0.377 0.693 0.657  0.629  0.175 
 7 0.634 0.878 0.557 0.515 0.829 0.691  0.350  0.852 
 8 0.424 0.425 0.874 0.680 0.737 0.205  0.812  0.494 
 9 0.695 0.679 0.373 0.101 0.629 0.616  0.487  0.837 
10 0.135 0.938 0.485 0.504 0.276 0.447  0.437  0.539 
# ℹ 61 more rows

[[1]][[27]]
# A tibble: 5 × 8
      V1    V2    V3    V4    V5     V6     V7     V8
   <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>
1 0.425  0.829 0.920 0.149 0.736 0.219  0.558  0.529 
2 0.929  0.695 0.402 0.297 0.846 0.965  0.915  0.733 
3 0.628  0.929 0.870 0.468 0.138 0.0594 0.0758 0.0397
4 0.887  0.571 0.891 0.559 0.228 0.0600 0.0658 0.566 
5 0.0812 0.125 0.698 0.851 0.602 0.674  0.953  0.170 

[[1]][[28]]
# A tibble: 16 × 8
        V1     V2      V3     V4     V5     V6    V7     V8
     <dbl>  <dbl>   <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.231   0.0769 0.00116 0.963  0.803  0.960  0.832 0.0105
 2 0.152   0.312  0.540   0.205  0.837  0.165  0.508 0.926 
 3 0.295   0.473  0.191   0.619  0.258  0.894  0.831 0.0827
 4 0.820   0.135  0.832   0.0990 0.993  0.120  0.167 0.538 
 5 0.628   0.194  0.469   0.243  0.471  0.508  0.586 0.525 
 6 0.296   0.731  0.450   0.457  0.182  0.110  0.952 0.119 
 7 0.0362  0.811  0.769   0.0837 0.721  0.976  0.891 0.902 
 8 0.380   0.407  0.272   0.922  0.773  0.443  0.617 0.370 
 9 0.609   0.402  0.648   0.511  0.0339 0.408  0.229 0.708 
10 0.299   0.114  0.0718  0.293  0.299  0.484  0.811 0.335 
11 0.214   0.559  0.962   0.317  0.616  0.0634 0.566 0.687 
12 0.222   0.198  0.977   0.957  0.753  0.303  0.399 0.312 
13 0.803   0.582  0.551   0.330  0.938  0.133  0.466 0.706 
14 0.00701 0.586  0.0742  0.831  0.271  0.410  0.926 0.680 
15 0.480   0.737  0.663   0.924  0.834  0.433  0.300 0.181 
16 0.225   0.926  0.345   0.928  0.687  0.358  0.998 0.0172

[[1]][[29]]
# A tibble: 76 × 8
        V1    V2     V3    V4     V5    V6     V7    V8
     <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.184   0.219 0.520  0.507 0.800  0.695 0.489  0.365
 2 0.369   0.924 0.0474 0.220 0.163  0.567 0.873  0.256
 3 0.395   0.178 0.190  0.439 0.0139 0.512 0.968  0.240
 4 0.836   0.480 0.437  0.531 0.822  0.378 0.190  0.815
 5 0.918   0.868 0.422  0.887 0.0455 0.610 0.393  0.153
 6 0.0916  0.961 0.651  0.496 0.504  0.687 0.207  0.924
 7 0.144   0.847 0.938  0.636 0.878  0.938 0.152  0.943
 8 0.0456  0.746 0.352  0.177 0.0475 0.964 0.518  0.627
 9 0.941   0.677 0.585  0.920 0.830  0.325 0.250  0.726
10 0.00425 0.355 0.976  0.334 0.610  0.657 0.0384 0.691
# ℹ 66 more rows

[[1]][[30]]
# A tibble: 64 × 8
      V1      V2     V3    V4    V5    V6    V7     V8
   <dbl>   <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>
 1 0.436 0.833   0.816  0.691 0.991 0.772 0.635 0.360 
 2 0.331 0.00986 0.743  0.301 0.860 0.618 0.651 0.0685
 3 0.528 0.682   0.105  0.687 0.860 0.777 0.533 0.729 
 4 0.881 0.895   0.144  0.849 0.984 0.651 0.849 0.0515
 5 0.345 0.919   0.0441 0.280 0.681 0.464 0.215 0.328 
 6 0.184 0.741   0.901  0.299 0.251 0.842 0.271 0.138 
 7 0.482 0.378   0.765  0.535 0.178 0.559 0.288 0.195 
 8 0.224 0.551   0.235  0.132 0.518 0.907 0.471 0.541 
 9 0.694 0.772   0.0860 0.987 0.442 0.531 0.403 0.664 
10 0.455 0.189   0.302  0.439 0.415 0.249 0.355 0.996 
# ℹ 54 more rows

[[1]][[31]]
# A tibble: 75 × 8
       V1     V2     V3     V4     V5    V6     V7    V8
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.0316 0.361  0.646  0.892  0.439  0.427 0.0192 0.839
 2 0.502  0.174  0.0485 0.769  0.844  0.476 0.0682 0.342
 3 0.474  0.0656 0.783  0.741  0.217  0.863 0.496  0.163
 4 0.406  0.189  0.824  0.549  0.322  0.656 0.986  0.835
 5 0.428  0.755  0.294  0.915  0.606  0.977 0.496  0.324
 6 0.203  0.591  0.176  0.647  0.531  0.951 0.709  0.151
 7 0.925  0.0792 0.183  0.0831 0.0551 0.622 0.699  0.883
 8 0.647  0.320  0.388  0.247  0.772  0.493 0.641  0.155
 9 0.792  0.527  0.664  0.639  0.515  0.825 0.996  0.338
10 0.989  0.933  0.561  0.431  0.789  0.558 0.762  0.653
# ℹ 65 more rows

[[1]][[32]]
# A tibble: 41 × 8
       V1     V2      V3     V4     V5      V6     V7     V8
    <dbl>  <dbl>   <dbl>  <dbl>  <dbl>   <dbl>  <dbl>  <dbl>
 1 0.0945 0.343  0.383   0.520  0.441  0.329   0.891  0.688 
 2 0.945  0.474  0.402   0.975  0.920  0.972   0.279  0.760 
 3 0.336  0.0556 0.160   0.567  0.701  0.292   0.339  0.0579
 4 0.379  0.862  0.142   0.936  0.997  0.00382 0.235  0.956 
 5 0.232  0.876  0.398   0.0523 0.235  0.123   0.667  0.650 
 6 0.146  0.888  0.624   0.769  0.210  0.640   0.970  0.540 
 7 0.339  0.905  0.0234  0.499  0.393  0.122   0.988  0.112 
 8 0.437  0.967  0.171   0.274  0.0816 0.109   0.0921 0.915 
 9 0.952  0.482  0.597   0.0761 0.0293 0.522   0.519  0.698 
10 0.354  0.241  0.00301 0.808  0.670  0.269   0.987  0.0803
# ℹ 31 more rows

[[1]][[33]]
# A tibble: 18 × 8
       V1     V2     V3     V4    V5     V6     V7     V8
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.109  0.317  0.298  0.382  0.355 0.746  0.749  0.441 
 2 0.991  0.354  0.248  0.552  0.929 0.306  0.812  0.255 
 3 0.574  0.0276 0.865  0.122  0.131 0.352  0.274  0.225 
 4 0.246  0.882  0.153  0.242  0.453 0.442  0.388  0.512 
 5 0.133  0.364  0.239  0.853  0.640 0.556  0.837  0.411 
 6 0.439  0.164  0.753  0.313  0.498 0.962  0.901  0.818 
 7 0.0481 0.440  0.0147 0.664  0.411 0.452  0.505  0.565 
 8 0.710  0.903  0.659  0.265  0.172 0.0188 0.622  0.0760
 9 0.613  0.531  0.0899 0.900  0.318 0.683  0.0223 0.297 
10 0.281  0.518  0.879  0.475  0.737 0.408  0.521  0.339 
11 0.341  0.983  0.0340 0.121  0.265 0.733  0.152  0.166 
12 0.382  0.0891 0.588  0.416  0.151 0.0970 0.296  0.210 
13 0.736  0.379  0.880  0.538  0.989 0.328  0.415  0.855 
14 0.447  0.221  0.202  0.0349 0.587 0.790  0.233  0.674 
15 0.916  0.933  0.706  0.968  0.925 0.708  0.0889 0.298 
16 0.403  0.759  0.525  0.710  0.510 0.0270 0.195  0.673 
17 0.352  0.937  0.435  0.0969 0.581 0.787  0.431  0.658 
18 0.619  0.999  0.213  0.0864 0.858 0.981  0.785  0.661 

[[1]][[34]]
# A tibble: 66 × 8
      V1     V2     V3     V4     V5     V6    V7     V8
   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.118 0.0386 0.775  0.261  0.543  0.765  0.167 0.892 
 2 0.639 0.916  0.0982 0.232  0.594  0.0860 0.594 0.637 
 3 0.198 0.510  0.318  0.865  0.879  0.222  0.687 0.0645
 4 0.835 0.252  0.341  0.210  0.624  0.659  0.598 0.891 
 5 0.137 0.755  0.633  0.772  0.846  0.138  0.175 0.949 
 6 0.791 0.585  0.305  0.588  0.0760 0.883  0.697 0.267 
 7 0.288 0.721  0.288  0.687  0.322  0.523  0.564 0.679 
 8 0.743 0.782  0.226  0.0464 0.736  0.408  0.853 0.725 
 9 0.284 0.0866 0.617  0.825  0.0437 0.451  0.696 0.399 
10 0.883 0.199  0.407  0.660  0.0463 0.343  0.521 0.991 
# ℹ 56 more rows

[[1]][[35]]
# A tibble: 81 × 8
      V1     V2     V3    V4     V5    V6    V7    V8
   <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
 1 0.223 0.246  0.647  0.303 0.734  0.494 0.749 0.994
 2 0.511 0.642  0.889  0.254 0.0316 0.213 0.219 0.177
 3 0.240 0.700  0.0623 0.290 0.204  0.437 0.932 0.375
 4 0.120 0.765  0.956  0.601 0.646  0.254 0.324 0.956
 5 0.207 0.287  0.0387 0.501 0.766  0.474 0.231 0.647
 6 0.276 0.0578 0.485  0.664 0.399  0.194 0.501 0.940
 7 0.770 0.0268 0.685  0.948 0.722  0.413 0.479 0.724
 8 0.299 0.211  0.0733 0.586 0.453  0.530 0.515 0.715
 9 0.688 0.359  0.181  0.758 0.239  0.709 0.885 0.629
10 0.553 0.928  0.607  0.582 0.141  0.849 0.976 0.950
# ℹ 71 more rows

[[1]][[36]]
# A tibble: 81 × 8
      V1    V2     V3    V4     V5     V6     V7    V8
   <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.955 0.765 0.937  0.525 0.0369 0.604  0.109  0.131
 2 0.846 0.147 0.598  0.133 0.688  0.784  0.237  0.105
 3 0.833 0.321 0.937  0.771 0.435  0.757  0.218  0.967
 4 0.155 0.345 0.792  0.994 0.847  0.0734 0.689  0.830
 5 0.734 0.984 0.794  0.487 0.759  0.744  0.305  0.181
 6 0.905 0.363 0.246  0.964 0.905  0.357  0.289  0.390
 7 0.420 0.513 0.557  0.993 0.594  0.796  0.0514 0.889
 8 0.982 0.799 0.0928 0.882 0.578  0.523  0.357  0.114
 9 0.129 0.416 0.168  0.982 0.0221 0.890  0.831  0.213
10 0.965 0.861 0.571  0.846 0.715  0.778  0.680  0.587
# ℹ 71 more rows

[[1]][[37]]
# A tibble: 83 × 8
       V1     V2     V3     V4     V5     V6     V7      V8
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>   <dbl>
 1 0.387  0.0465 0.581  0.375  0.268  0.508  0.830  0.737  
 2 0.200  0.197  0.895  0.612  0.417  0.605  0.856  0.481  
 3 0.119  0.630  0.174  0.191  0.0297 0.771  0.862  0.293  
 4 0.225  0.906  0.416  0.619  0.972  0.226  0.389  0.939  
 5 0.495  0.519  0.578  0.0514 0.185  0.382  0.0704 0.0994 
 6 0.679  0.913  0.0976 0.537  0.842  0.0370 0.461  0.246  
 7 0.153  0.740  0.728  0.402  0.409  0.953  0.942  0.00214
 8 0.197  0.260  0.930  0.321  0.270  0.0984 0.623  0.511  
 9 0.841  0.545  0.0447 0.537  0.877  0.448  0.694  0.313  
10 0.0381 0.236  0.389  0.412  0.0850 0.0970 0.0299 0.666  
# ℹ 73 more rows

[[1]][[38]]
# A tibble: 55 × 8
        V1    V2    V3     V4     V5    V6     V7    V8
     <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.762   0.573 0.486 0.343  0.272  0.825 0.559  0.544
 2 0.155   0.650 0.273 0.0456 0.345  0.427 0.387  0.457
 3 0.00363 0.520 0.964 0.109  0.0538 0.650 0.256  0.213
 4 0.871   0.339 0.124 0.515  0.319  0.772 0.114  0.317
 5 0.473   0.349 0.369 0.221  0.662  0.394 0.0427 0.393
 6 0.0222  0.309 0.175 0.683  0.486  0.245 0.725  0.308
 7 0.573   0.710 0.729 0.729  0.989  0.252 0.119  0.970
 8 0.382   0.862 0.324 0.168  0.100  0.944 0.489  0.747
 9 0.725   0.201 0.796 0.701  0.929  0.949 0.385  0.970
10 0.0302  0.106 0.898 0.825  0.977  0.415 0.332  0.844
# ℹ 45 more rows

[[1]][[39]]
# A tibble: 78 × 8
      V1     V2     V3     V4     V5     V6     V7    V8
   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.435 0.0465 0.117  0.582  0.630  0.122  0.726  0.557
 2 0.466 0.794  0.153  0.920  0.120  0.0362 0.801  0.606
 3 0.264 0.886  0.338  0.724  0.282  0.107  0.924  0.437
 4 0.594 0.0448 0.166  0.874  0.0841 0.813  0.796  0.307
 5 0.654 0.961  0.237  0.270  0.614  0.688  0.189  0.543
 6 0.105 0.778  0.974  0.702  0.312  0.500  0.926  0.951
 7 0.100 0.850  0.587  0.830  0.856  0.885  0.298  0.678
 8 0.777 0.425  0.418  0.300  0.0916 0.972  0.245  0.480
 9 0.246 0.105  0.0949 0.0455 0.0156 0.782  0.0479 0.307
10 0.377 0.404  0.512  0.320  0.842  0.0651 0.829  0.652
# ℹ 68 more rows

[[1]][[40]]
# A tibble: 94 × 8
       V1     V2     V3     V4     V5     V6    V7    V8
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.654  0.247  0.990  0.169  0.442  0.0690 0.180 0.426
 2 0.396  0.366  0.0220 0.301  0.303  0.527  0.502 0.365
 3 0.0436 0.207  0.405  0.167  0.346  0.283  0.843 0.233
 4 0.691  0.564  0.947  0.731  0.982  0.932  0.371 0.549
 5 0.0458 0.0425 0.201  0.364  0.0294 0.113  0.847 0.698
 6 0.266  0.693  0.230  0.0833 0.689  0.354  0.823 0.343
 7 0.694  0.0860 0.327  0.489  0.693  0.209  0.580 0.616
 8 0.170  0.368  0.125  0.788  0.236  0.768  0.764 0.282
 9 0.389  0.882  0.272  0.739  0.807  0.673  0.360 0.276
10 0.382  0.896  0.537  0.901  0.376  0.861  0.772 0.550
# ℹ 84 more rows

[[1]][[41]]
# A tibble: 93 × 8
       V1      V2      V3     V4    V5     V6    V7    V8
    <dbl>   <dbl>   <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl>
 1 0.494  0.602   0.250   0.800  0.714 0.771  0.814 0.775
 2 0.234  0.00425 0.967   0.691  0.380 0.0211 0.829 0.223
 3 0.0318 0.703   0.00172 0.404  0.562 0.618  0.822 0.510
 4 0.498  0.977   0.506   0.0769 0.944 0.290  0.236 0.297
 5 0.407  0.580   0.363   0.839  0.379 0.386  0.967 0.682
 6 0.721  0.923   0.964   0.247  0.666 0.100  0.797 0.880
 7 0.0393 0.102   0.192   0.334  0.961 0.754  0.710 0.777
 8 0.947  0.609   0.385   0.0705 0.227 0.774  0.232 0.302
 9 0.301  0.561   0.471   0.586  0.860 0.235  0.702 0.393
10 0.487  0.423   0.545   0.157  0.931 0.269  0.989 0.685
# ℹ 83 more rows

[[1]][[42]]
# A tibble: 20 × 8
       V1      V2     V3     V4     V5      V6     V7     V8
    <dbl>   <dbl>  <dbl>  <dbl>  <dbl>   <dbl>  <dbl>  <dbl>
 1 0.700  0.803   0.109  0.314  0.366  0.888   0.208  0.0279
 2 0.622  0.782   0.434  0.563  0.883  0.908   0.428  0.800 
 3 0.790  0.944   0.618  0.867  0.883  0.00369 0.793  0.567 
 4 0.689  0.703   0.262  0.676  0.273  0.567   0.407  0.490 
 5 0.896  0.565   0.648  0.763  0.815  0.949   0.704  0.141 
 6 0.583  0.853   0.309  0.141  0.498  0.497   0.793  0.993 
 7 0.250  0.519   0.196  0.0940 0.991  0.908   0.537  0.0199
 8 0.778  0.955   0.818  0.264  0.841  0.724   0.700  0.548 
 9 0.759  0.00642 0.168  0.480  0.680  0.220   0.578  0.669 
10 0.774  0.424   0.322  0.521  0.136  0.147   0.508  0.102 
11 0.714  0.447   0.0360 0.222  0.0607 0.838   0.524  0.484 
12 0.134  0.534   0.469  0.786  0.509  0.455   0.350  0.466 
13 0.122  0.123   0.126  0.308  0.894  0.0160  0.813  0.560 
14 0.0345 0.223   0.893  0.282  0.266  0.406   0.603  0.669 
15 0.468  0.870   0.0571 0.603  0.430  0.897   0.569  0.892 
16 0.233  0.417   0.773  0.605  0.614  0.0837  0.338  0.650 
17 0.827  0.507   0.774  0.189  0.342  0.351   0.0133 0.193 
18 0.707  0.190   0.958  0.0796 0.0254 0.365   0.282  0.642 
19 0.783  0.218   0.668  0.407  0.113  0.340   0.734  0.340 
20 0.771  0.0815  0.788  0.227  0.295  0.425   0.304  0.802 

[[1]][[43]]
# A tibble: 9 × 8
     V1    V2     V3     V4    V5    V6    V7      V8
  <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>   <dbl>
1 0.717 0.930 0.883  0.944  0.645 0.986 0.947 0.264  
2 0.244 0.828 0.0710 0.451  0.555 0.407 0.542 0.236  
3 0.867 0.429 0.513  0.0103 0.429 0.608 0.464 0.313  
4 0.605 0.694 0.0913 0.524  0.142 0.804 0.458 0.937  
5 0.565 0.524 0.828  0.769  0.602 0.150 0.659 0.543  
6 0.771 0.566 0.851  0.974  0.846 0.493 0.837 0.253  
7 0.903 0.657 0.994  0.180  0.563 0.441 0.978 0.946  
8 0.579 0.675 0.435  0.443  0.795 0.298 0.978 0.00690
9 0.631 0.902 0.629  0.905  0.472 0.764 0.289 0.329  

[[1]][[44]]
# A tibble: 16 × 8
       V1     V2     V3     V4     V5     V6    V7    V8
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.754  0.564  0.915  0.404  0.304  0.258  0.280 0.197
 2 0.708  0.177  0.470  0.609  0.987  0.0436 0.333 0.774
 3 0.334  0.255  0.854  0.497  0.451  0.393  0.339 0.157
 4 0.772  0.979  0.230  0.528  0.515  0.900  0.183 0.610
 5 0.800  0.140  0.370  0.300  0.489  0.571  0.127 0.161
 6 0.976  0.390  0.0240 0.0777 0.830  0.901  0.759 0.567
 7 0.0378 0.0976 0.860  0.700  0.948  0.0611 0.985 0.151
 8 0.689  0.893  0.309  0.261  0.843  0.441  0.553 0.464
 9 0.115  0.211  0.558  0.605  0.295  0.284  0.869 0.141
10 0.734  0.535  0.0898 0.338  0.600  0.621  0.636 0.858
11 0.374  0.596  0.206  0.558  0.0975 0.358  0.105 0.166
12 0.972  0.742  0.928  0.952  0.475  0.153  0.167 0.231
13 0.556  0.611  0.339  0.311  0.970  0.746  0.528 0.730
14 0.557  0.552  0.841  0.544  0.279  0.552  0.247 0.171
15 0.305  0.0630 0.888  0.0861 0.537  0.871  0.240 0.908
16 0.248  0.358  0.655  0.102  0.147  0.251  0.580 0.763

[[1]][[45]]
# A tibble: 34 × 8
      V1    V2       V3    V4     V5    V6    V7     V8
   <dbl> <dbl>    <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.247 0.996 0.726    0.535 0.166  0.370 0.677 0.955 
 2 0.860 0.691 0.000390 0.648 0.0114 0.526 0.932 0.655 
 3 0.883 0.821 0.255    0.882 0.646  0.225 0.896 0.831 
 4 0.139 0.967 0.409    0.460 0.857  0.545 0.915 0.0368
 5 0.407 0.144 0.0225   0.400 0.451  0.459 0.738 0.938 
 6 0.243 0.305 0.715    0.875 0.208  0.256 0.497 0.580 
 7 0.264 0.357 0.293    0.886 0.443  0.524 0.387 0.770 
 8 0.319 0.346 0.496    0.506 0.0176 0.179 0.434 0.312 
 9 0.770 0.287 0.933    0.383 0.327  0.638 0.164 0.685 
10 0.697 0.582 0.672    0.804 0.491  0.658 0.917 0.0735
# ℹ 24 more rows

[[1]][[46]]
# A tibble: 26 × 8
       V1     V2     V3     V4    V5    V6     V7    V8
    <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl>
 1 0.0423 0.0551 0.836  0.934  0.743 0.425 0.654  0.493
 2 0.767  0.389  0.320  0.0153 0.283 0.638 0.995  0.217
 3 0.713  0.729  0.388  0.671  0.102 0.229 0.200  0.634
 4 0.660  0.560  0.342  0.255  0.254 0.643 0.0309 0.952
 5 0.751  0.908  0.880  0.392  0.384 0.761 0.756  0.522
 6 0.0251 0.866  0.0160 0.334  0.794 0.735 0.0856 0.363
 7 0.794  0.777  0.0368 0.0287 0.711 0.269 0.337  0.602
 8 0.711  0.168  0.157  0.975  0.232 0.776 0.693  0.828
 9 0.961  0.829  0.261  0.0258 0.460 0.813 0.872  0.220
10 0.966  0.535  0.886  0.792  0.660 0.696 0.155  0.794
# ℹ 16 more rows

[[1]][[47]]
# A tibble: 46 × 8
      V1     V2     V3     V4     V5    V6     V7    V8
   <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.221 0.478  0.809  0.804  0.825  0.170 0.573  0.245
 2 0.516 0.749  0.197  0.370  0.323  0.137 0.751  0.568
 3 0.390 0.867  0.0246 0.188  0.311  0.997 0.784  0.195
 4 0.669 0.712  0.339  0.372  0.427  0.506 0.0129 0.517
 5 0.896 0.206  0.691  0.0737 0.151  0.972 0.344  0.741
 6 0.190 0.217  0.779  0.301  0.518  0.543 0.800  0.166
 7 0.739 0.299  0.674  0.223  0.293  0.330 0.149  0.944
 8 0.922 0.0439 0.839  0.205  0.660  0.565 0.230  0.389
 9 0.676 0.455  0.0258 0.272  0.0211 0.861 0.926  0.819
10 0.186 0.619  0.0822 0.0585 0.992  0.880 0.322  0.508
# ℹ 36 more rows

[[1]][[48]]
# A tibble: 25 × 8
       V1     V2     V3     V4     V5     V6    V7    V8
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.152  0.268  0.634  0.191  0.820  0.429  0.429 0.856
 2 0.745  0.909  0.147  0.402  0.828  0.340  0.735 0.811
 3 0.0268 0.841  0.394  0.273  0.648  0.678  0.474 0.150
 4 0.963  0.0630 0.854  0.490  0.262  0.849  0.534 0.387
 5 0.0435 0.782  0.424  0.281  0.225  0.739  0.551 0.184
 6 0.521  0.400  0.924  0.963  0.981  0.295  0.758 0.957
 7 0.291  0.258  0.378  0.702  0.166  0.0867 0.167 0.187
 8 0.722  0.275  0.890  0.233  0.0463 0.749  0.374 0.576
 9 0.877  0.266  0.554  0.845  0.981  0.584  0.970 0.332
10 0.774  0.121  0.0756 0.0376 0.327  0.567  0.227 0.800
# ℹ 15 more rows

[[1]][[49]]
# A tibble: 55 × 8
      V1    V2     V3     V4     V5     V6     V7     V8
   <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.202 0.870 0.772  0.906  0.697  0.104  0.0440 0.564 
 2 0.590 0.527 0.731  0.312  0.507  0.516  0.940  0.965 
 3 0.828 0.769 0.341  0.0167 0.729  0.440  0.904  0.113 
 4 0.879 0.191 0.931  0.388  0.180  0.228  0.584  0.709 
 5 0.730 0.564 0.145  0.209  0.0499 0.139  0.475  0.898 
 6 0.771 0.273 0.591  0.661  0.595  0.0476 0.797  0.0296
 7 0.614 0.581 0.304  0.853  0.816  0.305  0.0797 0.0696
 8 0.504 0.562 0.466  0.0838 0.494  0.796  0.156  0.219 
 9 0.484 0.465 0.731  0.763  0.715  0.163  0.447  0.559 
10 0.314 0.122 0.0545 0.573  0.254  0.508  0.537  0.239 
# ℹ 45 more rows

[[1]][[50]]
# A tibble: 17 × 8
        V1      V2     V3     V4      V5     V6     V7    V8
     <dbl>   <dbl>  <dbl>  <dbl>   <dbl>  <dbl>  <dbl> <dbl>
 1 0.217   0.0916  0.691  0.222  0.665   0.156  0.0195 0.602
 2 0.215   0.723   0.991  0.691  0.171   0.0293 0.656  0.550
 3 0.499   0.387   0.648  0.454  0.00212 0.363  0.829  0.131
 4 0.898   0.804   0.0523 0.165  0.501   0.848  0.747  0.610
 5 0.0257  0.708   0.950  0.518  0.417   0.957  0.861  0.793
 6 0.00724 0.125   0.415  0.589  0.0609  0.432  0.205  0.526
 7 0.951   0.340   0.383  0.354  0.121   0.349  0.0657 0.419
 8 0.911   0.289   0.683  0.215  0.845   0.286  0.891  0.723
 9 0.592   0.272   0.803  0.957  0.944   0.738  0.908  0.889
10 0.538   0.958   0.281  0.0787 0.270   0.750  0.667  0.652
11 0.560   0.360   0.377  0.915  0.276   0.966  0.716  0.824
12 0.383   0.490   0.0432 0.151  0.585   0.858  0.995  0.465
13 0.709   0.00953 0.441  0.122  0.985   0.660  0.174  0.427
14 0.817   0.523   0.234  0.730  0.888   0.825  0.804  0.723
15 0.664   0.402   0.800  0.749  0.339   0.453  0.950  0.483
16 0.247   0.451   0.566  0.366  0.783   0.484  0.103  0.863
17 0.278   0.802   0.0273 0.543  0.956   0.274  0.465  0.398

[[1]][[51]]
# A tibble: 72 × 8
       V1     V2     V3    V4     V5    V6     V7     V8
    <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.0873 0.753  0.792  0.892 0.565  0.281 0.237  0.228 
 2 0.325  0.0288 0.418  0.231 0.215  0.223 0.204  0.0242
 3 0.188  0.321  0.915  0.283 0.0815 0.828 0.637  0.186 
 4 0.552  0.136  0.328  0.455 0.269  0.284 0.492  0.428 
 5 0.492  0.470  0.0440 0.645 0.335  0.251 0.240  0.784 
 6 0.0720 0.765  0.904  0.845 0.810  0.627 0.792  0.640 
 7 0.537  0.908  0.729  0.470 0.644  0.794 0.456  0.379 
 8 0.0616 0.157  0.203  0.796 0.921  0.284 0.837  0.744 
 9 0.400  0.414  0.514  0.711 0.588  0.661 0.0208 0.690 
10 0.248  0.295  0.718  0.250 0.105  0.288 0.184  0.835 
# ℹ 62 more rows

[[1]][[52]]
# A tibble: 53 × 8
       V1     V2     V3    V4    V5    V6      V7     V8
    <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>   <dbl>  <dbl>
 1 0.836  0.320  0.457  0.954 0.593 0.887 0.636   0.480 
 2 0.680  0.960  0.545  0.907 0.340 0.219 0.178   0.725 
 3 0.830  0.315  0.515  0.717 0.728 0.333 0.945   0.597 
 4 0.0573 0.438  0.880  0.250 0.623 0.593 0.465   0.0310
 5 0.345  0.666  0.916  0.131 0.281 0.628 0.431   0.983 
 6 0.916  0.573  0.0382 0.761 0.688 0.297 0.798   0.481 
 7 0.251  0.368  0.0823 0.395 0.978 0.900 0.151   0.794 
 8 0.260  0.0888 0.389  0.983 0.490 0.347 0.00492 0.458 
 9 0.107  0.200  0.768  0.727 0.876 0.814 0.368   0.971 
10 0.980  0.969  0.463  0.583 0.847 0.489 0.159   0.723 
# ℹ 43 more rows

[[1]][[53]]
# A tibble: 62 × 8
      V1     V2      V3     V4    V5      V6     V7    V8
   <dbl>  <dbl>   <dbl>  <dbl> <dbl>   <dbl>  <dbl> <dbl>
 1 0.830 0.375  0.723   0.0261 0.883 0.00432 0.933  0.188
 2 0.691 0.384  0.300   0.665  0.799 0.368   0.428  0.637
 3 0.379 0.330  0.568   0.124  0.837 0.978   0.561  0.392
 4 0.451 0.723  0.0303  0.295  0.764 0.680   0.359  0.297
 5 0.110 0.0518 0.00612 0.374  0.462 0.279   0.457  0.539
 6 0.623 0.917  0.641   0.0773 0.955 0.399   0.986  0.665
 7 0.260 0.638  0.873   0.0127 0.226 0.561   0.514  0.738
 8 0.655 0.877  0.916   0.379  0.842 0.0763  0.105  0.893
 9 0.302 0.914  0.883   0.922  0.761 0.929   0.158  0.939
10 0.954 0.224  0.700   0.800  0.319 0.121   0.0589 0.734
# ℹ 52 more rows

[[1]][[54]]
# A tibble: 12 × 8
       V1     V2    V3     V4     V5     V6     V7     V8
    <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.0289 0.710  0.452 0.370  0.0653 0.890  0.0470 0.819 
 2 0.956  0.313  0.269 0.580  0.963  0.369  0.191  0.541 
 3 0.825  0.810  0.847 0.986  0.630  0.956  0.0936 0.303 
 4 0.493  0.165  0.501 0.439  0.458  0.623  0.114  0.654 
 5 0.490  0.427  0.787 0.825  0.553  0.354  0.0491 0.488 
 6 0.833  0.555  0.363 0.893  0.528  0.653  0.518  0.0948
 7 0.474  0.0201 0.263 0.0427 0.275  0.496  0.518  0.985 
 8 0.787  0.281  0.484 0.226  0.489  0.614  0.685  0.162 
 9 0.218  0.362  0.388 0.903  0.266  0.618  0.640  0.862 
10 0.136  0.903  0.513 0.156  0.577  0.755  0.508  0.494 
11 0.793  0.566  0.882 0.280  0.668  0.0972 0.825  0.347 
12 0.625  0.288  0.172 0.0935 0.383  0.825  0.635  0.227 

[[1]][[55]]
# A tibble: 88 × 8
        V1     V2     V3     V4     V5     V6     V7    V8
     <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.676   0.0130 0.0526 0.134  0.337  0.500  0.124  0.610
 2 0.0671  0.601  0.233  0.692  0.0272 0.814  0.339  0.927
 3 0.477   0.761  0.629  0.588  0.924  0.450  0.373  0.652
 4 0.228   0.435  0.0864 0.957  0.813  0.0218 0.729  0.914
 5 0.567   0.108  0.350  0.513  0.832  0.277  0.0143 0.116
 6 0.592   0.816  0.942  0.0175 0.682  0.915  0.0547 0.350
 7 0.702   0.174  0.951  0.802  0.429  0.0403 0.620  0.693
 8 0.0762  0.268  0.176  0.304  0.643  0.571  0.476  0.673
 9 0.559   0.706  0.396  0.501  0.952  0.0747 0.558  0.857
10 0.00645 0.509  0.350  0.662  0.761  0.439  0.587  0.405
# ℹ 78 more rows

[[1]][[56]]
# A tibble: 57 × 8
       V1     V2     V3     V4    V5     V6    V7     V8
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.604  0.441  0.132  0.115  0.747 0.198  0.941 0.952 
 2 0.0822 0.0490 0.962  0.856  0.801 0.738  0.624 0.310 
 3 0.421  0.178  0.980  0.836  0.899 0.0169 0.469 0.315 
 4 0.306  0.336  0.459  0.133  0.318 0.373  0.371 0.437 
 5 0.0722 0.913  0.556  0.723  0.629 0.597  0.159 0.0407
 6 0.770  0.613  0.294  0.378  0.982 0.228  0.942 0.971 
 7 0.984  0.168  0.709  0.422  0.679 0.460  0.432 0.919 
 8 0.546  0.100  0.273  0.0944 0.772 0.929  0.455 0.372 
 9 0.313  0.416  0.472  0.157  0.486 0.200  0.849 0.937 
10 0.115  0.356  0.0487 0.429  0.805 0.283  0.718 0.363 
# ℹ 47 more rows

[[1]][[57]]
# A tibble: 58 × 8
      V1     V2     V3       V4     V5    V6     V7     V8
   <dbl>  <dbl>  <dbl>    <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.701 0.795  0.0895 0.405    0.308  0.486 0.220  0.0460
 2 0.301 0.136  0.482  0.000237 0.180  0.812 0.0763 0.373 
 3 0.954 0.0687 0.581  0.0319   0.588  0.213 0.0346 0.401 
 4 0.376 0.701  0.294  0.550    0.863  0.906 0.879  0.918 
 5 0.234 0.493  0.164  0.0487   0.168  0.256 0.0131 0.479 
 6 0.800 0.393  0.0856 0.768    0.0625 0.298 0.392  0.159 
 7 0.382 0.529  0.209  0.0697   0.0549 0.812 0.639  0.331 
 8 0.481 0.221  0.106  0.109    0.268  0.344 0.816  0.521 
 9 0.595 0.925  0.955  0.0625   0.965  0.582 0.107  0.891 
10 0.579 0.598  0.841  0.295    0.699  0.930 0.210  0.791 
# ℹ 48 more rows

[[1]][[58]]
# A tibble: 38 × 8
      V1    V2    V3    V4     V5     V6     V7      V8
   <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>   <dbl>
 1 0.669 0.138 0.947 0.167 0.130  0.207  0.633  0.338  
 2 0.623 0.908 0.231 0.265 0.374  0.276  0.844  0.0787 
 3 0.209 0.729 0.293 0.940 0.249  0.442  0.930  0.926  
 4 0.327 0.990 0.853 0.411 0.488  0.226  0.0925 0.00382
 5 0.616 0.122 0.568 0.902 0.117  0.272  0.770  0.903  
 6 0.421 0.991 0.931 0.202 0.711  0.162  0.0346 0.839  
 7 0.861 0.243 0.142 0.311 0.283  0.0631 0.853  0.114  
 8 0.575 0.338 0.430 0.953 0.0777 0.980  0.193  0.896  
 9 0.334 0.831 0.386 0.727 0.390  0.974  0.337  0.600  
10 0.819 0.239 0.840 0.586 0.921  0.271  0.464  0.401  
# ℹ 28 more rows

[[1]][[59]]
# A tibble: 78 × 8
       V1    V2    V3     V4    V5     V6    V7    V8
    <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl>
 1 0.384  0.858 0.405 0.517  0.207 0.213  0.845 0.912
 2 0.735  0.144 0.415 0.828  0.577 0.247  0.929 0.223
 3 0.985  0.479 0.746 0.655  0.648 0.675  0.441 0.999
 4 0.0198 0.607 0.644 0.114  0.550 0.396  0.628 0.423
 5 0.997  0.302 0.606 0.183  0.461 0.563  0.965 0.554
 6 0.0362 0.816 0.620 0.0128 0.784 0.0803 0.921 0.101
 7 0.872  0.854 0.597 0.845  0.759 0.226  0.365 0.400
 8 0.960  0.236 0.696 0.780  0.876 0.696  0.523 0.623
 9 0.0414 0.634 0.967 0.921  0.572 0.402  0.747 0.256
10 0.922  0.929 0.335 0.161  0.517 0.473  0.415 0.662
# ℹ 68 more rows

[[1]][[60]]
# A tibble: 96 × 8
      V1       V2     V3     V4    V5    V6    V7    V8
   <dbl>    <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>
 1 0.483 0.974    0.0943 0.662  0.151 0.766 0.707 0.984
 2 0.495 0.511    0.0431 0.638  0.678 0.531 0.620 0.784
 3 0.498 0.820    0.764  0.638  0.618 0.650 0.129 0.102
 4 0.226 0.174    0.167  0.684  0.648 0.818 0.400 0.422
 5 0.818 0.812    0.616  0.522  0.784 0.970 0.466 0.420
 6 0.586 0.180    0.282  0.551  0.649 0.837 0.424 0.855
 7 0.307 0.965    0.821  0.508  0.647 0.899 0.661 0.658
 8 0.161 0.772    0.294  0.516  0.179 0.386 0.369 0.713
 9 0.248 0.725    0.768  0.449  0.415 0.700 0.895 0.187
10 0.409 0.000199 0.606  0.0800 0.227 0.865 0.166 0.829
# ℹ 86 more rows

[[1]][[61]]
# A tibble: 54 × 8
       V1    V2     V3    V4     V5    V6     V7    V8
    <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.813  0.484 0.966  0.180 0.773  0.588 0.0593 0.447
 2 0.854  0.118 0.483  0.323 0.840  0.907 0.0875 0.776
 3 0.591  0.704 0.499  0.802 0.713  0.438 0.337  0.966
 4 0.147  0.538 0.500  0.698 0.154  0.640 0.575  0.487
 5 0.115  0.534 0.523  0.326 0.786  0.944 0.913  0.959
 6 0.309  0.521 0.0608 0.956 0.357  0.124 0.491  0.895
 7 0.133  0.225 0.0437 0.168 0.0843 0.736 0.445  0.926
 8 0.443  0.526 0.0473 0.632 0.667  0.119 0.183  0.389
 9 0.679  0.334 0.576  0.909 0.321  0.837 0.142  0.992
10 0.0297 0.912 0.246  0.289 0.114  0.463 0.698  0.462
# ℹ 44 more rows

[[1]][[62]]
# A tibble: 38 × 8
      V1    V2     V3     V4     V5    V6    V7    V8
   <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>
 1 0.177 0.811 0.968  0.683  0.626  0.493 0.302 0.482
 2 0.643 0.181 0.485  0.737  0.977  0.732 0.248 0.601
 3 0.179 0.960 0.562  0.882  0.641  0.113 0.686 0.330
 4 0.764 0.271 0.750  0.0575 0.924  0.566 0.217 0.901
 5 0.713 0.876 0.0531 0.781  0.889  0.386 0.603 0.775
 6 0.253 0.630 0.172  0.747  0.778  0.980 0.816 0.584
 7 0.381 0.457 0.453  0.789  0.222  0.494 0.607 0.874
 8 0.953 0.879 0.132  0.260  0.552  0.186 0.564 0.669
 9 0.720 0.779 0.559  0.0924 0.887  0.813 0.746 0.669
10 0.366 0.648 0.708  0.431  0.0994 0.518 0.535 0.497
# ℹ 28 more rows

[[1]][[63]]
# A tibble: 46 × 8
       V1     V2    V3    V4      V5    V6    V7    V8
    <dbl>  <dbl> <dbl> <dbl>   <dbl> <dbl> <dbl> <dbl>
 1 0.634  0.448  0.437 0.279 0.436   0.104 0.106 0.660
 2 0.742  0.202  0.901 0.612 0.589   0.974 0.248 0.934
 3 0.682  0.684  0.870 0.785 0.114   0.447 0.986 0.898
 4 0.954  0.640  0.635 0.242 0.0614  0.941 0.238 0.342
 5 0.870  0.516  0.343 0.494 0.834   0.920 0.932 0.571
 6 0.384  0.513  0.796 0.106 0.250   0.360 0.301 0.617
 7 0.768  0.950  0.859 0.550 0.672   0.715 0.952 0.475
 8 0.0183 0.471  0.961 0.326 0.00913 0.686 0.761 0.958
 9 0.164  0.0908 0.862 0.918 0.0253  0.275 0.262 0.375
10 0.301  0.0335 0.944 0.193 0.754   0.263 0.559 0.296
# ℹ 36 more rows

[[1]][[64]]
# A tibble: 73 × 8
        V1    V2      V3    V4     V5     V6     V7     V8
     <dbl> <dbl>   <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.723   0.213 0.742   0.529 0.449  0.166  0.194  0.862 
 2 0.931   0.355 0.214   0.811 0.794  0.281  0.641  0.0163
 3 0.601   0.538 0.458   0.370 0.238  0.395  0.682  0.346 
 4 0.117   0.436 0.489   0.761 0.142  0.0680 0.0357 0.981 
 5 0.00267 0.917 0.264   0.911 0.854  0.322  0.994  0.267 
 6 0.109   0.294 0.144   0.869 0.772  0.824  0.728  0.750 
 7 0.315   0.291 0.203   0.491 0.767  0.239  0.972  0.0602
 8 0.763   0.877 0.00865 0.235 0.686  0.532  0.555  0.382 
 9 0.814   0.325 0.809   0.557 0.831  0.748  0.222  0.0441
10 0.230   0.213 0.194   0.312 0.0799 0.561  0.122  0.454 
# ℹ 63 more rows

[[1]][[65]]
# A tibble: 10 × 8
        V1     V2     V3     V4    V5    V6     V7    V8
     <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl>
 1 0.0789  0.0702 0.491  0.185  0.470 0.128 0.0436 0.276
 2 0.0313  0.0135 0.206  0.796  0.521 0.102 0.860  0.843
 3 0.423   0.187  0.993  0.869  0.287 0.178 0.360  0.444
 4 0.821   0.651  0.192  0.420  0.486 0.655 0.337  0.658
 5 0.294   0.726  0.823  0.195  0.118 0.214 0.368  0.588
 6 0.423   0.649  0.733  0.0579 0.895 0.946 0.324  0.894
 7 0.549   0.411  0.806  0.458  0.704 0.704 0.686  0.777
 8 0.00327 0.700  0.617  0.828  0.188 0.621 0.767  0.624
 9 0.632   0.803  0.0361 0.575  0.645 0.818 0.164  0.534
10 0.716   0.861  0.583  0.631  0.378 0.364 0.761  0.801

[[1]][[66]]
# A tibble: 41 × 8
        V1    V2     V3    V4    V5     V6     V7    V8
     <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.318   0.379 0.612  0.276 0.936 0.597  0.799  0.716
 2 0.105   0.129 0.869  0.254 0.595 0.690  0.421  0.976
 3 0.300   0.711 0.886  0.764 0.535 0.462  0.0849 0.314
 4 0.827   0.542 0.507  0.246 0.331 0.835  0.333  0.555
 5 0.185   0.996 0.524  0.264 0.261 0.525  0.648  0.906
 6 0.342   0.857 0.0233 0.689 0.604 0.206  0.340  0.463
 7 0.356   0.183 0.394  0.782 0.837 0.460  0.174  0.633
 8 0.844   0.833 0.790  0.117 0.125 0.0867 0.908  0.370
 9 0.0179  0.591 0.0706 0.495 0.763 0.446  0.343  0.595
10 0.00500 0.466 0.495  0.501 0.904 0.339  0.392  0.621
# ℹ 31 more rows

[[1]][[67]]
# A tibble: 78 × 8
      V1    V2    V3    V4     V5    V6    V7    V8
   <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
 1 0.779 0.445 0.604 0.379 0.471  0.169 0.949 0.133
 2 0.147 0.901 0.835 0.702 0.323  0.788 0.134 0.144
 3 0.890 0.977 0.397 0.541 0.511  0.968 0.758 0.102
 4 0.256 0.107 0.766 0.973 0.0806 0.225 0.111 0.474
 5 0.477 0.711 0.870 0.621 0.672  0.584 0.647 0.914
 6 0.546 0.707 0.145 0.284 0.193  0.269 0.288 0.273
 7 0.105 0.802 0.596 0.366 0.474  0.702 0.557 0.595
 8 0.574 0.772 0.892 0.423 0.780  0.464 0.619 0.536
 9 0.477 0.836 0.298 0.192 0.110  0.744 0.141 0.154
10 0.365 0.190 0.791 0.854 0.0201 0.858 0.617 0.283
# ℹ 68 more rows

[[1]][[68]]
# A tibble: 61 × 8
      V1    V2      V3     V4     V5    V6     V7    V8
   <dbl> <dbl>   <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.916 0.147 0.648   0.451  0.0227 0.385 0.0327 0.623
 2 0.958 0.421 0.136   0.142  0.419  0.246 0.705  0.566
 3 0.840 0.875 0.00794 0.218  0.350  0.438 0.475  0.572
 4 0.991 0.797 0.706   0.123  0.972  0.344 0.477  0.456
 5 0.209 0.344 0.585   0.796  0.711  0.156 0.824  0.444
 6 0.799 0.283 0.103   0.879  0.247  0.356 0.106  0.589
 7 0.692 0.257 0.580   0.957  0.284  0.483 0.408  0.797
 8 0.672 0.553 0.00416 0.0523 0.956  0.886 0.659  0.933
 9 0.143 0.360 0.640   0.527  0.144  0.834 0.0431 0.287
10 0.360 0.858 0.846   0.882  0.0842 0.945 0.357  0.915
# ℹ 51 more rows

[[1]][[69]]
# A tibble: 13 × 8
      V1     V2     V3     V4     V5     V6     V7     V8
   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.992 0.325  0.889  0.675  0.0601 0.503  0.696  0.158 
 2 0.522 0.305  0.966  0.264  0.908  0.697  0.924  0.853 
 3 0.236 0.609  0.581  0.146  0.174  0.506  0.807  0.610 
 4 0.272 0.308  0.197  0.335  0.967  0.464  0.694  0.0632
 5 0.846 0.750  0.495  0.166  0.749  0.382  0.587  0.606 
 6 0.814 0.0204 0.0769 0.231  0.365  0.613  0.283  0.280 
 7 0.279 0.401  0.749  0.182  0.168  0.0456 0.217  0.882 
 8 0.217 0.966  0.160  0.850  0.406  0.281  0.165  0.238 
 9 0.562 0.370  0.500  0.277  0.0428 0.309  0.437  0.631 
10 0.896 0.563  0.173  0.570  0.389  0.614  0.383  0.441 
11 0.602 0.794  0.0173 0.0675 0.282  0.327  0.0143 0.601 
12 0.937 0.286  0.359  0.175  0.462  0.981  0.919  0.905 
13 0.115 0.541  0.989  0.228  0.803  0.179  0.556  0.0507

[[1]][[70]]
# A tibble: 14 × 8
       V1     V2     V3      V4      V5      V6     V7     V8
    <dbl>  <dbl>  <dbl>   <dbl>   <dbl>   <dbl>  <dbl>  <dbl>
 1 0.490  0.963  0.622  0.720   0.350   0.00990 0.415  0.0195
 2 0.163  0.0825 0.232  0.492   0.207   0.779   0.547  0.106 
 3 0.830  0.206  0.675  0.0898  0.397   0.979   0.0149 0.295 
 4 0.0189 0.270  0.909  0.715   0.00798 0.993   0.117  0.166 
 5 0.172  0.192  0.395  0.107   0.0426  0.845   0.530  0.483 
 6 0.382  0.959  0.0371 0.256   0.159   0.619   0.113  0.0949
 7 0.975  0.680  0.874  0.894   0.921   0.905   0.465  0.528 
 8 0.642  0.746  0.414  0.471   0.760   0.331   0.200  0.212 
 9 0.181  0.245  0.518  0.00803 0.980   0.0652  0.574  0.501 
10 0.170  0.888  0.738  0.921   0.606   0.612   0.336  0.432 
11 0.934  0.532  0.948  0.303   0.178   0.120   0.541  0.806 
12 0.561  0.0360 0.818  0.353   0.600   0.564   0.421  0.965 
13 0.883  0.499  0.801  0.815   0.933   0.341   0.264  0.503 
14 0.637  0.220  0.749  0.738   0.528   0.0450  0.372  0.347 

[[1]][[71]]
# A tibble: 78 × 8
       V1    V2      V3     V4    V5    V6    V7    V8
    <dbl> <dbl>   <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>
 1 0.0583 0.615 0.747   0.450  0.820 0.421 0.932 0.394
 2 0.855  0.378 0.286   0.303  0.532 0.249 0.736 0.862
 3 0.715  0.181 0.0596  0.483  0.758 0.448 0.537 0.916
 4 0.283  0.408 0.175   0.112  0.244 0.463 0.901 0.560
 5 0.195  0.495 0.194   0.0688 0.687 0.977 0.430 0.578
 6 0.692  0.913 0.328   0.790  0.852 0.409 0.530 0.353
 7 0.688  0.170 0.184   0.239  0.757 0.827 0.422 0.193
 8 0.657  0.301 0.852   0.115  0.252 0.378 0.487 0.131
 9 0.0944 0.144 0.118   0.0567 0.288 0.654 0.835 0.971
10 0.413  0.268 0.00898 0.927  0.265 0.752 0.412 0.706
# ℹ 68 more rows

[[1]][[72]]
# A tibble: 76 × 8
         V1    V2    V3     V4    V5     V6    V7     V8
      <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.0994   0.926 0.590 0.136  0.181 0.688  0.357 0.940 
 2 0.360    0.156 0.908 0.994  0.208 0.554  0.115 0.0331
 3 0.117    0.990 0.769 0.611  0.108 0.377  0.574 0.765 
 4 0.000641 0.548 0.910 0.680  0.399 0.280  0.884 0.499 
 5 0.965    0.614 0.706 0.0947 0.522 0.140  0.300 0.347 
 6 0.357    0.669 0.195 0.0993 0.308 0.312  0.363 0.542 
 7 0.825    0.607 0.419 0.480  0.353 0.401  0.992 0.392 
 8 0.123    0.133 0.977 0.964  0.185 0.870  0.163 0.328 
 9 0.327    0.374 0.786 0.675  0.999 0.768  0.714 0.638 
10 0.577    0.240 0.404 0.241  0.253 0.0720 0.130 0.999 
# ℹ 66 more rows

[[1]][[73]]
# A tibble: 5 × 8
      V1     V2    V3    V4     V5      V6    V7    V8
   <dbl>  <dbl> <dbl> <dbl>  <dbl>   <dbl> <dbl> <dbl>
1 0.743  0.647  0.154 0.796 0.578  0.172   0.944 0.909
2 0.671  0.245  0.726 0.315 0.0648 0.795   0.796 0.179
3 0.0981 0.482  0.681 0.155 0.682  0.00423 0.153 0.672
4 0.952  0.0944 0.591 0.574 0.496  0.0597  0.423 0.640
5 0.449  0.170  0.347 0.339 0.225  0.717   0.670 0.801

[[1]][[74]]
# A tibble: 21 × 8
       V1      V2       V3     V4     V5     V6      V7    V8
    <dbl>   <dbl>    <dbl>  <dbl>  <dbl>  <dbl>   <dbl> <dbl>
 1 0.688  0.386   0.957    0.365  0.988  0.864  0.555   0.972
 2 0.752  0.155   0.276    0.0451 0.515  0.667  0.841   0.893
 3 0.182  0.999   0.297    0.931  0.539  0.0348 0.942   0.838
 4 0.335  0.352   0.000868 0.427  0.774  0.701  0.789   0.352
 5 0.798  0.357   0.218    0.299  0.286  0.994  0.00697 0.488
 6 0.0153 0.664   0.982    0.754  0.885  0.988  0.135   0.114
 7 0.346  0.661   0.119    0.0732 0.802  0.714  0.705   0.339
 8 0.269  0.00400 0.851    0.0596 0.201  0.642  0.893   0.914
 9 0.274  0.521   0.410    0.712  0.0149 0.151  0.134   0.356
10 0.414  0.990   0.523    0.785  0.960  0.867  0.222   0.765
# ℹ 11 more rows

[[1]][[75]]
# A tibble: 90 × 8
      V1    V2    V3    V4     V5     V6     V7    V8
   <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.182 0.639 0.153 0.685 0.337  0.150  0.0371 0.871
 2 0.814 0.328 0.149 0.959 0.336  0.815  0.162  0.370
 3 0.287 0.865 0.649 0.331 0.726  0.325  0.146  0.537
 4 0.967 0.521 0.483 0.611 0.653  0.519  0.287  0.535
 5 0.893 0.531 0.702 0.607 0.732  0.664  0.887  0.949
 6 0.548 0.588 0.560 0.486 0.944  0.646  0.727  0.106
 7 0.785 0.856 0.744 0.797 0.249  0.564  0.744  0.993
 8 0.477 0.949 0.281 0.531 0.223  0.0867 0.973  0.564
 9 0.262 0.921 0.384 0.960 0.977  0.0660 0.825  0.214
10 0.125 0.121 0.437 0.108 0.0938 0.919  0.862  0.858
# ℹ 80 more rows

[[1]][[76]]
# A tibble: 4 × 8
     V1    V2    V3    V4     V5    V6    V7    V8
  <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
1 0.385 0.817 0.520 0.596 0.553  0.399 0.571 0.871
2 0.354 0.905 0.108 0.476 0.840  0.803 0.330 0.659
3 0.538 0.128 0.565 0.460 0.313  0.331 0.538 0.810
4 0.788 0.811 0.621 0.293 0.0335 0.865 0.451 0.936

[[1]][[77]]
# A tibble: 99 × 8
       V1    V2     V3    V4    V5    V6     V7    V8
    <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl>
 1 0.795  0.876 0.0803 0.706 0.520 0.134 0.698  0.753
 2 0.0335 0.273 0.0140 0.257 0.697 0.986 0.326  0.130
 3 0.596  0.431 0.745  0.895 0.756 0.165 0.556  0.624
 4 0.117  0.431 0.657  0.746 0.893 0.751 0.420  0.581
 5 0.344  0.845 0.973  0.250 0.560 0.128 0.793  0.342
 6 0.283  0.195 0.199  0.523 0.785 0.167 0.272  0.618
 7 0.918  0.620 0.975  0.717 0.628 0.155 0.0113 0.236
 8 0.907  0.107 0.890  0.711 0.909 0.357 0.919  0.957
 9 0.967  0.611 0.565  0.270 0.211 0.665 0.465  0.593
10 0.577  0.526 0.959  0.644 0.388 0.757 0.267  0.214
# ℹ 89 more rows

[[1]][[78]]
# A tibble: 6 × 8
      V1     V2    V3     V4     V5     V6    V7    V8
   <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>
1 0.716  0.176  0.144 0.969  0.0751 0.917  0.958 0.403
2 0.661  0.272  0.469 0.995  0.337  0.659  0.974 0.206
3 0.843  0.313  0.849 0.288  0.0864 0.958  0.216 0.240
4 0.538  0.0444 0.486 0.525  0.943  0.0635 0.583 0.725
5 0.775  0.146  0.660 0.0258 0.194  0.817  0.798 0.405
6 0.0638 0.673  0.295 0.758  0.637  0.173  0.545 0.320

[[1]][[79]]
# A tibble: 71 × 8
      V1      V2    V3     V4     V5    V6    V7      V8
   <dbl>   <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl>   <dbl>
 1 0.558 0.341   0.948 0.689  0.167  0.526 0.735 0.497  
 2 0.154 0.223   0.237 0.992  0.173  0.119 0.490 0.393  
 3 0.778 0.472   0.792 0.323  0.314  0.551 0.915 0.425  
 4 0.430 0.113   0.522 0.699  0.244  0.469 0.668 0.749  
 5 0.900 0.168   0.788 0.0516 0.765  0.708 0.901 0.140  
 6 0.263 0.00287 0.886 0.380  0.398  0.581 0.858 0.103  
 7 0.782 0.775   0.411 0.979  0.289  0.621 0.202 0.00880
 8 0.261 0.528   0.343 0.183  0.0836 0.415 0.884 0.437  
 9 0.947 0.290   0.140 0.535  0.533  0.330 0.957 0.963  
10 0.980 0.296   0.975 0.380  0.140  0.188 0.748 0.422  
# ℹ 61 more rows

[[1]][[80]]
# A tibble: 29 × 8
       V1     V2      V3     V4     V5     V6     V7    V8
    <dbl>  <dbl>   <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.882  0.937  0.0131  0.233  0.350  0.416  0.597  0.577
 2 0.406  0.899  0.436   0.863  0.660  0.500  0.993  0.377
 3 0.328  0.288  0.256   0.981  0.0458 0.933  0.861  0.641
 4 0.562  0.0249 0.00431 0.852  0.558  0.385  0.126  0.486
 5 0.413  0.424  0.676   0.424  0.912  0.796  0.0855 0.551
 6 0.442  0.0644 0.554   0.718  0.832  0.860  0.635  0.288
 7 0.546  0.558  0.675   0.0471 0.546  0.0152 0.141  0.335
 8 0.0672 0.0101 0.685   0.635  0.335  0.845  0.545  0.517
 9 0.0877 0.867  0.438   0.444  0.771  0.681  0.875  0.963
10 0.452  0.340  0.607   0.826  0.537  0.987  0.0773 0.944
# ℹ 19 more rows

[[1]][[81]]
# A tibble: 80 × 8
      V1      V2     V3    V4     V5    V6    V7    V8
   <dbl>   <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
 1 0.852 0.201   0.683  0.642 0.851  0.615 0.291 0.853
 2 0.363 0.711   0.0816 0.649 0.377  0.242 0.905 0.839
 3 0.197 0.982   0.554  0.267 0.0836 0.858 0.639 0.952
 4 0.687 0.522   0.507  0.260 0.162  0.359 0.833 0.886
 5 0.804 0.682   0.764  0.835 0.789  0.633 0.552 0.443
 6 0.718 0.328   0.465  0.737 0.0532 0.708 0.483 0.279
 7 0.311 0.202   0.848  0.682 0.417  0.494 0.240 0.443
 8 0.485 0.00571 0.441  0.923 0.616  0.434 0.210 0.628
 9 0.797 0.709   0.307  0.145 0.326  0.519 0.908 0.577
10 0.247 0.115   0.304  0.668 0.350  0.576 0.955 0.492
# ℹ 70 more rows

[[1]][[82]]
# A tibble: 53 × 8
       V1     V2     V3    V4     V5      V6     V7     V8
    <dbl>  <dbl>  <dbl> <dbl>  <dbl>   <dbl>  <dbl>  <dbl>
 1 0.197  0.517  0.909  0.269 0.687  0.189   0.615  0.0582
 2 0.964  0.0826 0.754  0.125 0.901  0.550   0.804  0.896 
 3 0.268  0.441  0.652  0.788 0.0477 0.158   0.598  0.193 
 4 0.604  0.381  0.875  0.104 0.323  0.603   0.775  0.911 
 5 0.303  0.775  0.423  0.515 0.352  0.776   0.115  0.500 
 6 0.992  0.206  0.0320 0.705 0.730  0.176   0.792  0.231 
 7 0.837  0.813  0.569  0.828 0.128  0.297   0.0536 0.192 
 8 0.392  0.944  0.0188 0.281 0.471  0.00338 0.320  0.180 
 9 0.0422 0.446  0.724  0.962 0.140  0.534   0.233  0.972 
10 0.513  0.567  0.531  0.282 0.0327 0.983   0.132  0.855 
# ℹ 43 more rows

[[1]][[83]]
# A tibble: 88 × 8
       V1     V2    V3     V4     V5     V6    V7     V8
    <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.236  0.140  0.729 0.223  0.0590 0.263  0.251 0.800 
 2 0.653  0.946  0.924 0.610  0.502  0.0405 0.883 0.119 
 3 0.695  0.360  0.595 0.843  0.737  0.783  0.881 0.333 
 4 0.0148 0.699  0.692 0.0435 0.858  0.462  0.887 0.187 
 5 0.915  0.805  0.469 0.986  0.849  0.195  0.997 0.290 
 6 0.845  0.289  0.228 0.567  0.187  0.261  0.636 0.859 
 7 0.684  0.0432 0.427 0.987  0.839  0.604  0.155 0.191 
 8 0.149  0.759  0.432 0.919  0.776  0.819  0.368 0.279 
 9 0.697  0.390  0.972 0.0264 0.480  0.196  0.330 0.995 
10 0.888  0.784  0.227 0.327  0.896  0.314  0.963 0.0783
# ℹ 78 more rows

[[1]][[84]]
# A tibble: 14 × 8
       V1     V2    V3     V4    V5     V6    V7    V8
    <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl>
 1 0.260  0.913  0.632 0.606  0.281 0.988  0.250 0.238
 2 0.982  0.0522 0.633 0.227  0.716 0.610  0.148 0.595
 3 0.828  0.341  0.857 0.628  0.718 0.533  0.145 0.163
 4 0.889  0.288  0.948 0.741  0.555 0.0198 0.830 0.957
 5 0.961  0.838  0.524 0.878  0.896 0.101  0.293 0.779
 6 0.493  0.882  0.460 0.900  0.262 0.803  0.633 0.187
 7 0.311  0.0880 0.378 0.467  0.357 0.441  0.510 0.312
 8 0.228  0.443  0.246 0.158  0.923 0.542  0.687 0.832
 9 0.361  0.184  0.267 0.834  0.857 0.160  0.352 0.956
10 0.712  0.323  0.590 0.0949 0.704 0.168  0.522 0.204
11 0.401  0.0531 0.291 0.511  0.844 0.274  0.439 0.768
12 0.757  0.957  0.168 0.625  0.667 0.601  0.243 0.997
13 0.256  0.0115 0.671 0.355  0.379 0.314  0.594 0.182
14 0.0740 0.984  0.148 0.686  0.684 0.723  0.838 0.296

[[1]][[85]]
# A tibble: 75 × 8
      V1     V2    V3     V4    V5    V6     V7     V8
   <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl>
 1 0.302 0.0871 0.296 0.625  0.858 0.492 0.979  0.602 
 2 0.644 0.349  0.588 0.657  0.365 0.944 0.0525 0.0110
 3 0.355 0.314  0.195 0.198  0.574 0.358 0.950  0.847 
 4 0.341 0.146  0.554 0.175  0.595 0.385 0.703  0.549 
 5 0.847 0.328  0.923 0.619  0.298 0.133 0.602  0.237 
 6 0.633 0.222  0.444 0.205  0.181 0.738 0.746  0.192 
 7 0.787 0.804  0.353 0.701  0.486 0.362 0.124  0.0944
 8 0.971 0.500  0.256 0.0667 0.344 0.527 0.550  0.0393
 9 0.911 0.298  0.154 0.416  0.295 0.300 0.698  0.373 
10 0.907 0.307  0.983 0.0367 0.575 0.723 0.548  0.992 
# ℹ 65 more rows

[[1]][[86]]
# A tibble: 61 × 8
       V1     V2     V3     V4    V5     V6     V7     V8
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.156  0.886  0.0188 0.829  0.921 0.306  0.602  0.958 
 2 0.597  0.0990 0.390  0.983  0.403 0.0424 0.884  0.443 
 3 0.0165 0.256  0.484  0.455  0.419 0.434  0.825  0.802 
 4 0.270  0.599  0.473  0.454  0.974 0.879  0.985  0.0709
 5 0.543  0.174  0.921  0.0793 0.467 0.896  0.314  0.208 
 6 0.115  0.0357 0.621  0.205  0.466 0.531  0.855  0.434 
 7 0.833  0.112  0.866  0.189  0.413 0.688  0.136  0.689 
 8 0.909  0.916  0.375  0.350  0.886 0.281  0.0228 0.707 
 9 0.546  0.736  0.324  0.509  0.856 0.190  0.984  0.829 
10 0.241  0.350  0.744  0.798  0.322 0.625  0.495  0.0823
# ℹ 51 more rows

[[1]][[87]]
# A tibble: 42 × 8
       V1    V2       V3    V4     V5     V6      V7     V8
    <dbl> <dbl>    <dbl> <dbl>  <dbl>  <dbl>   <dbl>  <dbl>
 1 0.0107 0.229 0.899    0.986 0.431  0.0125 0.847   0.473 
 2 0.599  0.209 0.818    0.642 0.0927 0.675  0.893   0.638 
 3 0.889  0.730 0.956    0.573 0.528  0.499  0.706   0.546 
 4 0.697  0.333 0.995    0.759 0.539  0.532  0.757   0.638 
 5 0.881  0.139 0.605    0.932 0.133  0.615  0.660   0.636 
 6 0.341  0.793 0.000894 0.300 0.646  0.995  0.0700  0.0741
 7 0.185  0.799 0.229    0.607 0.503  0.906  0.650   0.0993
 8 0.0504 0.569 0.692    0.256 0.464  0.247  0.0472  0.209 
 9 0.603  0.586 0.128    0.598 0.370  0.428  0.221   0.0138
10 0.402  0.562 0.372    0.945 0.912  0.147  0.00895 0.239 
# ℹ 32 more rows

[[1]][[88]]
# A tibble: 47 × 8
       V1      V2      V3       V4    V5    V6     V7    V8
    <dbl>   <dbl>   <dbl>    <dbl> <dbl> <dbl>  <dbl> <dbl>
 1 0.712  0.807   0.0242  0.545    0.750 0.761 0.0865 0.172
 2 0.727  0.190   0.596   0.560    0.640 0.681 0.427  0.546
 3 0.671  0.888   0.834   0.455    0.719 0.685 0.889  0.350
 4 0.0230 0.703   0.534   0.176    0.246 0.406 0.985  0.200
 5 0.121  0.459   0.0393  0.893    0.408 0.430 0.0676 0.109
 6 0.779  0.390   0.352   0.116    0.692 0.352 0.897  0.482
 7 0.409  0.215   0.192   0.101    0.360 0.534 0.0363 0.573
 8 0.881  0.401   0.0883  0.254    0.211 0.773 0.444  0.232
 9 0.970  0.231   0.00127 0.000156 0.871 0.554 0.271  0.542
10 0.335  0.00594 0.417   0.367    0.908 0.829 0.484  0.377
# ℹ 37 more rows

[[1]][[89]]
# A tibble: 45 × 8
       V1    V2     V3     V4     V5     V6     V7     V8
    <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.890  0.276 0.150  0.335  0.703  0.597  0.933  0.962 
 2 0.937  0.176 0.0957 0.0233 0.749  0.942  0.334  0.682 
 3 0.0172 0.898 0.816  0.671  0.708  0.0858 0.0299 0.976 
 4 0.495  0.230 0.255  0.332  0.522  0.818  0.444  0.972 
 5 0.598  0.569 0.868  0.231  0.137  0.556  0.758  0.254 
 6 0.452  0.287 0.249  0.730  0.970  0.0860 0.0107 0.368 
 7 0.416  0.237 0.612  0.788  0.0544 0.715  0.200  0.562 
 8 0.285  0.461 0.277  0.582  0.319  0.681  0.722  0.998 
 9 0.761  0.878 0.857  0.720  0.846  0.361  0.0847 0.802 
10 0.0632 0.402 0.477  0.441  0.964  0.513  0.913  0.0138
# ℹ 35 more rows

[[1]][[90]]
# A tibble: 80 × 8
      V1      V2    V3     V4     V5     V6    V7    V8
   <dbl>   <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.895 0.427   0.844 0.175  0.999  0.0165 0.446 0.836
 2 0.978 0.625   0.783 0.925  0.837  0.391  0.206 0.479
 3 0.752 0.905   0.859 0.134  0.0427 0.464  0.890 0.819
 4 0.515 0.603   0.342 0.181  0.853  0.217  0.647 0.204
 5 0.533 0.918   0.747 0.252  0.575  0.0526 0.869 0.357
 6 0.295 0.627   0.644 0.435  0.741  0.250  0.546 0.557
 7 0.208 0.486   0.781 0.0557 0.484  0.224  0.129 0.906
 8 0.738 0.912   0.425 0.170  0.287  0.717  0.451 0.593
 9 0.558 0.00274 0.917 0.517  0.525  0.268  0.278 0.479
10 0.197 0.108   0.258 0.174  0.571  0.146  0.741 0.936
# ℹ 70 more rows

[[1]][[91]]
# A tibble: 2 × 8
      V1    V2    V3      V4    V5     V6    V7    V8
   <dbl> <dbl> <dbl>   <dbl> <dbl>  <dbl> <dbl> <dbl>
1 0.777  0.913 0.488 0.00787 0.736 0.492  0.590 0.406
2 0.0566 0.969 0.487 0.415   0.192 0.0697 0.904 0.312

[[1]][[92]]
# A tibble: 73 × 8
       V1    V2     V3     V4     V5      V6    V7     V8
    <dbl> <dbl>  <dbl>  <dbl>  <dbl>   <dbl> <dbl>  <dbl>
 1 0.968  0.804 0.240  0.425  0.936  0.00421 0.508 0.448 
 2 0.616  0.967 0.444  0.180  0.904  0.831   0.140 0.182 
 3 0.814  0.165 0.376  0.0616 0.334  0.335   0.531 0.497 
 4 0.0837 0.533 0.424  0.746  0.903  0.997   0.758 0.104 
 5 0.661  0.890 0.495  0.222  0.176  0.366   0.134 0.644 
 6 0.582  0.185 0.334  0.617  0.194  0.434   0.578 0.0873
 7 0.201  0.974 0.524  0.248  0.0792 0.392   0.130 0.569 
 8 0.0488 0.919 0.686  0.245  0.410  0.243   0.783 0.318 
 9 0.542  0.135 0.955  0.954  0.0576 0.858   0.246 0.987 
10 0.908  0.568 0.0193 0.843  0.823  0.151   0.505 0.738 
# ℹ 63 more rows

[[1]][[93]]
# A tibble: 1 × 8
      V1    V2    V3    V4    V5    V6    V7     V8
   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>
1 0.0696 0.946 0.918 0.658 0.906 0.692 0.513 0.0802

[[1]][[94]]
# A tibble: 49 × 8
       V1    V2     V3     V4    V5     V6     V7    V8
    <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.313  0.430 0.671  0.690  0.287 0.793  0.809  0.203
 2 0.752  0.698 0.254  0.459  0.315 0.632  0.337  0.756
 3 0.436  0.522 0.942  0.887  0.197 0.0405 0.352  0.822
 4 0.869  0.949 0.472  0.558  0.917 0.799  0.672  0.747
 5 0.113  0.320 0.801  0.156  0.563 0.976  0.0332 0.325
 6 0.510  0.558 0.106  0.146  0.846 0.142  0.0705 0.101
 7 0.0942 0.118 0.312  0.0592 0.190 0.718  0.574  0.186
 8 0.626  0.622 0.890  0.391  0.329 0.174  0.0825 0.753
 9 0.624  0.800 0.0465 0.256  0.887 0.400  0.398  0.212
10 0.724  0.863 0.0200 0.305  0.930 0.535  0.466  0.499
# ℹ 39 more rows

[[1]][[95]]
# A tibble: 79 × 8
      V1    V2    V3     V4     V5     V6    V7     V8
   <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.663 0.348 0.147 0.468  0.686  0.164  0.687 0.103 
 2 0.526 0.719 0.191 0.897  0.982  0.139  0.250 0.893 
 3 0.234 0.358 0.531 0.680  0.240  0.947  0.576 0.0885
 4 0.105 0.712 0.300 0.124  0.632  0.260  0.356 0.839 
 5 0.800 0.241 0.117 0.368  0.270  0.515  0.130 0.569 
 6 0.602 0.913 0.425 0.362  0.586  0.181  0.773 0.163 
 7 0.250 0.175 0.447 0.160  0.0646 0.646  0.326 0.134 
 8 0.477 0.655 0.321 0.942  0.602  0.991  0.117 0.936 
 9 0.847 0.327 0.401 0.474  0.552  0.0609 0.782 0.0359
10 0.943 0.881 0.633 0.0956 0.711  0.0963 0.854 0.613 
# ℹ 69 more rows

[[1]][[96]]
# A tibble: 16 × 8
       V1     V2     V3     V4      V5      V6    V7      V8
    <dbl>  <dbl>  <dbl>  <dbl>   <dbl>   <dbl> <dbl>   <dbl>
 1 0.345  0.488  0.814  0.990  0.822   0.00113 0.419 0.138  
 2 0.825  0.413  0.427  0.700  0.893   0.0939  0.841 0.0256 
 3 0.232  0.378  0.706  0.570  0.473   0.402   0.155 0.871  
 4 0.492  0.742  0.283  0.0422 0.417   0.135   0.297 0.894  
 5 0.655  0.810  0.617  0.188  0.617   0.0583  0.202 0.153  
 6 0.276  0.888  0.802  0.770  0.00217 0.676   0.577 0.790  
 7 0.365  0.306  0.439  0.462  0.290   0.443   0.617 0.430  
 8 0.0870 0.479  0.142  0.923  0.260   0.355   0.756 0.00434
 9 0.552  0.866  0.116  0.842  0.227   0.178   0.165 0.347  
10 0.411  0.661  0.0533 0.385  0.111   0.894   0.660 0.286  
11 0.908  0.0458 0.852  0.348  0.426   0.869   0.482 0.116  
12 0.775  0.436  0.0696 0.862  0.0304  0.436   0.137 0.201  
13 0.720  0.384  0.141  0.994  0.211   0.0369  0.122 0.569  
14 0.780  0.215  0.883  0.621  0.559   0.875   0.129 0.962  
15 0.801  0.908  0.464  0.135  0.436   0.969   0.511 0.259  
16 0.695  0.496  0.259  0.665  0.392   0.593   0.728 0.154  

[[1]][[97]]
# A tibble: 39 × 8
       V1     V2    V3    V4      V5     V6    V7    V8
    <dbl>  <dbl> <dbl> <dbl>   <dbl>  <dbl> <dbl> <dbl>
 1 0.244  0.117  0.328 0.598 0.00283 0.212  0.504 0.942
 2 0.441  0.719  0.176 0.903 0.922   0.604  0.197 0.724
 3 0.0786 0.792  0.188 0.201 0.593   0.981  0.613 0.923
 4 0.195  0.164  0.553 0.592 0.749   0.373  0.194 0.300
 5 0.377  0.184  0.620 0.591 0.348   0.253  0.381 0.304
 6 0.499  0.596  0.792 0.378 0.132   0.788  0.885 0.561
 7 0.939  0.157  0.343 0.346 0.314   0.207  0.659 0.834
 8 0.930  0.330  0.851 0.816 0.127   0.712  0.482 0.846
 9 0.920  0.465  0.154 0.980 0.0408  0.0420 0.115 0.465
10 0.878  0.0887 0.542 0.903 0.166   0.818  0.830 0.120
# ℹ 29 more rows

[[1]][[98]]
# A tibble: 71 × 8
      V1     V2     V3    V4     V5    V6     V7     V8
   <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.354 0.704  0.294  0.631 0.778  0.332 0.145  0.920 
 2 0.357 0.791  0.891  0.463 0.903  0.640 0.192  0.487 
 3 0.678 0.344  0.113  0.661 0.853  0.700 0.446  0.710 
 4 0.266 0.0721 0.968  0.609 0.116  0.773 0.658  0.559 
 5 0.872 0.160  0.904  0.542 0.603  0.640 0.593  0.0816
 6 0.275 0.451  0.585  0.878 0.0277 0.491 0.224  0.577 
 7 0.411 0.408  0.840  0.567 0.180  0.459 0.179  0.700 
 8 0.739 0.0277 0.987  0.308 0.745  0.282 0.0735 0.571 
 9 0.910 0.563  0.0410 0.485 0.992  0.868 0.557  0.0275
10 0.868 0.805  0.805  0.816 0.708  0.737 0.667  0.335 
# ℹ 61 more rows

[[1]][[99]]
# A tibble: 4 × 8
     V1     V2    V3     V4     V5    V6    V7      V8
  <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl>   <dbl>
1 0.897 0.659  0.791 0.279  0.563  0.755 0.255 0.00891
2 0.983 0.0152 0.688 0.459  0.863  0.611 0.585 0.471  
3 0.636 0.735  0.338 0.141  0.0363 0.619 0.754 0.860  
4 0.269 0.0321 0.131 0.0302 0.875  0.982 0.473 0.872  

[[1]][[100]]
# A tibble: 44 × 8
       V1     V2    V3      V4     V5     V6    V7     V8
    <dbl>  <dbl> <dbl>   <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.736  0.904  0.964 0.638   0.931  0.128  0.602 0.993 
 2 0.178  0.138  0.224 0.107   0.322  0.0135 0.527 0.631 
 3 0.0566 0.170  0.912 0.145   0.967  0.133  0.672 0.610 
 4 0.988  0.936  0.207 0.832   0.0511 0.265  0.565 0.265 
 5 0.635  0.787  0.785 0.911   0.429  0.115  0.840 0.720 
 6 0.0808 0.0100 0.895 0.0590  0.140  0.158  0.433 0.730 
 7 0.661  0.718  0.763 0.274   0.943  0.329  0.822 0.0557
 8 0.397  0.163  0.976 0.142   0.806  0.738  0.539 0.709 
 9 0.531  0.0825 0.717 0.00555 0.408  0.295  0.102 0.434 
10 0.481  0.0213 0.853 0.722   0.296  0.814  0.684 0.536 
# ℹ 34 more rows


[[2]]
[[2]][[1]]
# A tibble: 93 × 5
       V1     V2      V3    V4    V5
    <dbl>  <dbl>   <dbl> <dbl> <dbl>
 1 0.929  0.883  0.139   0.690 0.589
 2 0.0883 0.640  0.0295  0.308 0.147
 3 0.0248 0.810  0.00352 0.867 0.799
 4 0.259  0.418  0.753   0.865 0.170
 5 0.948  0.934  0.864   0.463 0.139
 6 0.352  0.0102 0.548   0.328 0.567
 7 0.607  0.543  0.291   0.815 0.633
 8 0.461  0.197  0.117   0.789 0.425
 9 0.389  0.191  0.972   0.230 0.142
10 0.421  0.889  0.395   0.317 0.350
# ℹ 83 more rows

[[2]][[2]]
# A tibble: 8 × 5
     V1    V2     V3     V4     V5
  <dbl> <dbl>  <dbl>  <dbl>  <dbl>
1 0.213 0.940 0.428  0.889  0.841 
2 0.204 0.250 0.497  0.615  0.755 
3 0.694 0.649 0.976  0.119  0.973 
4 0.619 0.519 0.230  0.666  0.0444
5 0.631 0.569 0.806  0.166  0.405 
6 0.649 0.316 0.0848 0.398  0.685 
7 0.459 0.900 0.0527 0.0136 0.805 
8 0.903 0.901 0.817  0.631  0.679 

[[2]][[3]]
# A tibble: 82 × 5
      V1    V2    V3    V4    V5
   <dbl> <dbl> <dbl> <dbl> <dbl>
 1 0.690 0.329 0.727 0.481 0.123
 2 0.715 0.828 0.916 0.650 0.229
 3 0.447 0.218 0.180 0.658 0.108
 4 0.666 0.312 0.810 0.635 0.963
 5 0.446 0.306 0.568 0.673 0.725
 6 0.694 0.423 0.619 0.517 0.191
 7 0.284 0.256 0.817 0.528 0.632
 8 0.557 0.963 0.547 0.429 0.475
 9 0.945 0.444 0.440 0.903 0.761
10 0.731 0.489 0.399 0.579 0.341
# ℹ 72 more rows

[[2]][[4]]
# A tibble: 97 × 5
        V1     V2     V3    V4     V5
     <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.298   0.295  0.340  0.737 0.790 
 2 0.101   0.130  0.373  0.252 0.300 
 3 0.231   0.737  0.138  0.446 0.686 
 4 0.00484 0.122  0.179  0.203 0.398 
 5 0.781   0.632  0.0133 0.330 0.358 
 6 0.530   0.0498 0.440  0.112 0.217 
 7 0.621   0.108  0.181  0.857 0.400 
 8 0.868   0.805  0.896  0.470 0.867 
 9 0.515   0.967  0.326  0.427 0.759 
10 0.673   0.741  0.134  0.655 0.0644
# ℹ 87 more rows

[[2]][[5]]
# A tibble: 92 × 5
      V1      V2    V3     V4     V5
   <dbl>   <dbl> <dbl>  <dbl>  <dbl>
 1 0.476 0.671   0.346 0.621  0.632 
 2 0.519 0.283   0.448 0.923  0.638 
 3 0.932 0.00863 0.427 0.0694 0.0995
 4 0.415 0.823   0.672 0.0948 0.555 
 5 0.226 0.277   0.321 0.316  0.0410
 6 0.658 0.439   0.615 0.606  0.697 
 7 0.531 0.725   0.881 0.0423 0.912 
 8 0.561 0.740   0.330 0.231  0.107 
 9 0.536 0.619   0.285 0.783  0.531 
10 0.550 0.864   0.731 0.476  0.614 
# ℹ 82 more rows

[[2]][[6]]
# A tibble: 16 × 5
        V1     V2     V3     V4      V5
     <dbl>  <dbl>  <dbl>  <dbl>   <dbl>
 1 0.232   0.263  0.767  0.788  0.00573
 2 0.953   0.651  0.734  0.666  0.332  
 3 0.576   0.148  0.0195 0.607  0.704  
 4 0.483   0.825  0.716  0.294  0.246  
 5 0.523   0.692  0.889  0.0358 0.890  
 6 0.146   0.526  0.376  0.224  0.674  
 7 0.392   0.0447 0.222  0.617  0.722  
 8 0.865   0.502  0.176  0.140  0.644  
 9 0.345   0.660  0.224  0.843  0.0542 
10 0.899   0.250  0.439  0.927  0.412  
11 0.428   0.923  0.939  0.0468 0.272  
12 0.171   0.210  0.678  0.809  0.167  
13 0.141   0.581  0.455  0.638  0.586  
14 0.907   0.463  0.152  0.0913 0.102  
15 0.00888 0.375  0.260  0.406  0.270  
16 0.738   0.944  0.176  0.328  0.655  

[[2]][[7]]
# A tibble: 21 × 5
       V1     V2     V3    V4    V5
    <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.300  0.902  0.329  0.898 0.563
 2 0.380  0.0368 0.271  0.769 0.279
 3 0.126  0.653  0.0336 0.940 0.636
 4 0.367  0.417  0.443  0.635 0.565
 5 0.395  0.133  0.812  0.328 0.205
 6 0.826  0.281  0.0105 0.405 0.882
 7 0.407  0.881  0.0769 0.221 0.629
 8 0.537  0.256  0.384  0.939 0.435
 9 0.245  0.293  0.216  0.187 0.627
10 0.0435 0.652  0.667  0.419 0.663
# ℹ 11 more rows

[[2]][[8]]
# A tibble: 62 × 5
       V1     V2      V3     V4    V5
    <dbl>  <dbl>   <dbl>  <dbl> <dbl>
 1 0.627  0.603  0.561   0.509  0.972
 2 0.132  0.417  0.590   0.814  0.944
 3 0.958  0.621  0.633   0.557  0.527
 4 0.0924 0.0775 0.0882  0.396  0.987
 5 0.296  0.363  0.247   0.0210 0.260
 6 0.877  0.810  0.00242 0.0772 0.453
 7 0.970  0.235  0.459   0.398  0.112
 8 0.153  0.376  0.0870  0.0423 0.255
 9 0.109  0.237  0.192   0.564  0.384
10 0.834  0.708  0.580   0.419  0.361
# ℹ 52 more rows

[[2]][[9]]
# A tibble: 51 × 5
       V1    V2     V3    V4    V5
    <dbl> <dbl>  <dbl> <dbl> <dbl>
 1 0.270  0.110 0.431  0.983 0.350
 2 0.571  0.600 0.337  0.288 0.491
 3 0.186  0.119 0.996  0.628 0.688
 4 0.0894 0.143 0.0179 0.909 0.417
 5 0.0809 0.514 0.406  0.165 0.497
 6 0.340  0.421 0.587  0.667 0.960
 7 0.0838 0.310 0.649  0.612 0.681
 8 0.0719 0.105 0.153  0.154 0.462
 9 0.648  0.437 0.590  0.424 0.693
10 0.145  0.435 0.961  0.851 0.219
# ℹ 41 more rows

[[2]][[10]]
# A tibble: 82 × 5
       V1     V2     V3     V4    V5
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.942  0.545  0.277  0.746  0.433
 2 0.246  0.513  0.968  0.0425 0.770
 3 0.445  0.693  0.367  0.0547 0.316
 4 0.977  0.0709 0.398  0.966  0.533
 5 0.113  0.247  0.905  0.930  0.695
 6 0.0564 0.122  0.524  0.132  0.692
 7 0.719  0.273  0.198  0.403  0.232
 8 0.940  0.842  0.760  0.739  0.562
 9 0.817  0.353  0.0830 0.319  0.150
10 0.763  0.432  0.837  0.813  0.560
# ℹ 72 more rows

[[2]][[11]]
# A tibble: 70 × 5
       V1    V2    V3     V4     V5
    <dbl> <dbl> <dbl>  <dbl>  <dbl>
 1 0.685  0.920 0.902 0.649  0.0689
 2 0.527  0.997 0.161 0.648  0.229 
 3 0.325  0.310 0.763 0.139  0.490 
 4 0.222  0.223 0.291 0.730  0.385 
 5 0.848  0.911 0.406 0.293  0.150 
 6 0.0984 0.504 0.288 0.0986 0.201 
 7 0.526  0.364 0.746 0.0133 0.468 
 8 0.445  0.605 0.909 0.376  0.0678
 9 0.391  0.972 0.795 0.831  0.988 
10 0.615  0.214 0.591 0.718  0.722 
# ℹ 60 more rows

[[2]][[12]]
# A tibble: 85 × 5
       V1     V2     V3    V4     V5
    <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.330  0.836  0.307  0.230 0.0517
 2 0.0474 0.0496 0.190  0.490 0.143 
 3 0.0733 0.654  0.603  0.522 0.615 
 4 0.839  0.891  0.917  0.222 0.885 
 5 0.830  0.456  0.558  0.922 0.207 
 6 0.811  0.0807 0.405  0.412 0.740 
 7 0.0307 0.631  0.156  0.132 0.0325
 8 0.103  0.777  0.852  0.302 0.508 
 9 0.645  0.400  0.879  0.339 0.472 
10 0.516  0.232  0.0317 0.704 0.160 
# ℹ 75 more rows

[[2]][[13]]
# A tibble: 43 × 5
      V1    V2     V3     V4    V5
   <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.662 0.225 0.990  0.346  0.640
 2 0.301 0.453 0.392  0.821  0.996
 3 0.145 0.443 0.340  0.0606 0.484
 4 0.828 0.635 0.437  0.946  0.885
 5 0.942 0.966 0.253  0.0883 0.590
 6 0.420 0.545 0.280  0.147  0.895
 7 0.668 0.157 0.425  0.452  0.914
 8 0.617 0.682 0.0609 0.670  0.115
 9 0.257 0.360 0.711  0.882  0.707
10 0.794 0.155 0.717  0.177  0.973
# ℹ 33 more rows

[[2]][[14]]
# A tibble: 48 × 5
      V1    V2     V3     V4     V5
   <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.496 0.223 0.752  0.554  0.0333
 2 0.580 0.504 0.0623 0.0904 0.957 
 3 0.363 0.171 0.250  0.236  0.0994
 4 0.843 0.742 0.486  0.990  0.0201
 5 0.110 0.411 0.0813 0.361  0.849 
 6 0.116 0.916 0.508  0.590  0.599 
 7 0.130 0.804 0.264  0.148  0.523 
 8 0.705 0.171 0.754  0.243  0.800 
 9 0.104 0.305 0.734  0.0299 0.197 
10 0.631 0.260 0.972  0.584  0.859 
# ℹ 38 more rows

[[2]][[15]]
# A tibble: 20 × 5
        V1      V2      V3     V4    V5
     <dbl>   <dbl>   <dbl>  <dbl> <dbl>
 1 0.108   0.385   0.222   0.447  0.959
 2 0.0205  0.00496 0.625   0.243  0.147
 3 0.00568 0.201   0.956   0.951  0.152
 4 0.565   0.307   0.689   0.0509 0.446
 5 0.629   0.898   0.142   0.302  0.968
 6 0.927   0.553   0.677   0.457  0.241
 7 0.877   0.982   0.0695  0.643  0.404
 8 0.829   0.530   0.127   0.937  0.754
 9 0.676   0.331   0.413   0.369  0.523
10 0.862   0.275   0.809   0.840  0.262
11 0.480   0.609   0.00918 0.304  0.118
12 0.649   0.643   0.0351  0.975  0.295
13 0.355   0.612   0.0886  0.585  0.695
14 0.421   0.897   0.703   0.734  0.567
15 0.110   0.107   0.723   0.318  0.895
16 0.329   0.343   0.230   0.379  0.279
17 0.940   0.252   0.323   0.407  0.832
18 0.332   0.964   0.513   0.501  0.509
19 0.647   0.707   0.0352  0.821  0.930
20 0.363   0.778   0.698   0.715  0.523

[[2]][[16]]
# A tibble: 34 × 5
      V1     V2     V3    V4    V5
   <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.550 0.881  0.266  0.534 0.455
 2 0.951 0.0551 0.988  0.974 0.650
 3 0.501 0.400  0.693  0.823 0.414
 4 0.723 0.153  0.488  0.250 0.322
 5 0.486 0.485  0.0147 0.298 0.700
 6 0.631 0.0359 0.990  0.306 0.210
 7 0.361 0.917  0.759  0.445 0.391
 8 0.151 0.875  0.153  0.503 0.359
 9 0.693 0.157  0.612  0.861 0.829
10 0.842 0.949  0.337  0.956 0.315
# ℹ 24 more rows

[[2]][[17]]
# A tibble: 23 × 5
      V1    V2    V3     V4    V5
   <dbl> <dbl> <dbl>  <dbl> <dbl>
 1 0.830 0.789 0.665 0.589  0.202
 2 0.437 0.777 0.917 0.732  0.593
 3 0.571 0.625 0.467 0.0394 0.314
 4 0.578 0.157 0.707 0.629  0.925
 5 0.451 0.182 0.988 0.326  0.931
 6 0.879 0.138 0.606 0.116  0.591
 7 0.923 0.269 0.687 0.101  0.941
 8 0.518 0.228 0.427 0.668  0.190
 9 0.252 0.762 0.579 0.470  0.854
10 0.958 0.852 0.871 0.0145 0.447
# ℹ 13 more rows

[[2]][[18]]
# A tibble: 32 × 5
       V1    V2    V3    V4     V5
    <dbl> <dbl> <dbl> <dbl>  <dbl>
 1 0.522  0.216 0.177 0.520 0.844 
 2 0.603  0.935 0.952 0.864 0.953 
 3 0.583  0.654 0.578 0.740 0.963 
 4 0.881  0.331 0.144 0.498 0.150 
 5 0.0205 0.748 0.117 0.532 0.0983
 6 0.130  0.410 0.358 0.300 0.0780
 7 0.872  0.798 0.472 0.796 0.364 
 8 0.164  0.288 0.163 0.981 0.412 
 9 0.405  0.202 0.565 0.104 0.570 
10 0.291  0.724 0.313 0.841 0.462 
# ℹ 22 more rows

[[2]][[19]]
# A tibble: 49 × 5
      V1     V2    V3    V4     V5
   <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.469 0.283  0.341 0.175 0.714 
 2 0.449 0.238  0.696 0.935 0.916 
 3 0.269 0.237  0.335 0.379 0.999 
 4 0.902 0.430  0.419 0.775 0.935 
 5 0.909 0.401  0.662 0.664 0.0405
 6 0.827 0.955  0.753 0.886 0.684 
 7 0.348 0.304  0.104 0.785 0.508 
 8 0.510 0.942  0.305 0.409 0.534 
 9 0.600 0.0233 0.939 0.671 0.895 
10 0.776 0.208  0.433 0.866 0.902 
# ℹ 39 more rows

[[2]][[20]]
# A tibble: 35 × 5
       V1    V2      V3     V4     V5
    <dbl> <dbl>   <dbl>  <dbl>  <dbl>
 1 0.664  0.205 0.114   0.787  0.125 
 2 0.884  0.656 0.620   0.977  0.0472
 3 0.263  0.915 0.791   0.870  0.0326
 4 0.212  0.208 0.195   0.820  0.331 
 5 0.323  0.740 0.00393 0.178  0.0707
 6 0.575  0.662 0.406   0.633  0.166 
 7 0.0844 0.906 0.705   0.219  0.571 
 8 0.668  0.115 0.557   0.907  0.306 
 9 0.371  0.691 0.524   0.0797 0.698 
10 0.710  0.818 0.335   0.272  0.640 
# ℹ 25 more rows

[[2]][[21]]
# A tibble: 22 × 5
       V1    V2    V3    V4    V5
    <dbl> <dbl> <dbl> <dbl> <dbl>
 1 0.265  0.103 0.657 0.717 0.976
 2 0.826  0.957 0.279 0.544 0.443
 3 0.616  0.289 0.716 0.528 0.956
 4 0.0332 0.451 0.426 0.141 0.307
 5 0.480  0.537 0.823 0.293 0.762
 6 0.919  0.191 0.748 0.153 0.715
 7 0.562  0.911 0.386 0.452 0.139
 8 0.193  0.469 0.570 0.930 0.502
 9 0.758  0.145 0.171 0.954 0.899
10 0.477  0.799 0.845 0.997 0.580
# ℹ 12 more rows

[[2]][[22]]
# A tibble: 42 × 5
      V1     V2     V3     V4     V5
   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.238 0.623  0.0977 0.489  0.0623
 2 0.849 0.539  0.980  0.646  0.813 
 3 0.881 0.373  0.836  0.818  0.210 
 4 0.935 0.440  0.482  0.943  0.453 
 5 0.211 0.419  0.392  0.572  0.621 
 6 0.674 0.394  0.730  0.0906 0.929 
 7 0.521 0.221  0.671  0.645  0.264 
 8 0.142 0.819  0.408  0.290  0.951 
 9 0.267 0.0287 0.0417 0.917  0.696 
10 0.925 0.322  0.0216 0.403  0.970 
# ℹ 32 more rows

[[2]][[23]]
# A tibble: 65 × 5
        V1     V2    V3     V4     V5
     <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.667   0.931  0.967 0.0401 0.634 
 2 0.935   0.120  0.735 0.184  0.0200
 3 0.167   0.178  0.579 0.168  0.210 
 4 0.0496  0.925  0.985 0.935  0.567 
 5 0.00312 0.733  0.782 0.903  0.665 
 6 0.996   0.567  0.923 0.149  0.0794
 7 0.461   0.0923 0.953 0.238  0.496 
 8 0.0850  0.610  0.370 0.0914 0.444 
 9 0.740   0.245  0.222 0.997  0.116 
10 0.614   0.417  0.352 0.241  0.814 
# ℹ 55 more rows

[[2]][[24]]
# A tibble: 49 × 5
       V1    V2    V3     V4     V5
    <dbl> <dbl> <dbl>  <dbl>  <dbl>
 1 0.0383 0.163 0.981 0.0816 0.315 
 2 0.492  0.362 0.278 0.698  0.447 
 3 0.517  0.138 0.627 0.936  0.413 
 4 0.590  0.150 0.978 0.699  0.644 
 5 0.308  0.156 0.518 0.930  0.386 
 6 0.905  0.643 0.690 0.755  0.0435
 7 0.557  0.758 0.451 0.499  0.214 
 8 0.552  0.848 0.955 0.285  0.703 
 9 0.495  0.294 0.314 0.407  0.104 
10 0.913  0.225 0.131 0.388  0.0765
# ℹ 39 more rows

[[2]][[25]]
# A tibble: 95 × 5
      V1    V2      V3     V4     V5
   <dbl> <dbl>   <dbl>  <dbl>  <dbl>
 1 0.880 0.865 0.911   0.395  0.152 
 2 0.183 0.764 0.103   0.109  0.108 
 3 0.902 0.114 0.117   0.755  0.339 
 4 0.614 0.871 0.309   0.311  0.0662
 5 0.563 0.167 0.560   0.462  0.102 
 6 0.190 0.120 0.152   0.802  0.189 
 7 0.503 0.571 0.726   0.293  0.196 
 8 0.590 0.421 0.811   0.415  0.807 
 9 0.981 0.269 0.00852 0.0258 0.512 
10 0.532 0.535 0.834   0.677  0.190 
# ℹ 85 more rows

[[2]][[26]]
# A tibble: 21 × 5
        V1    V2     V3      V4     V5
     <dbl> <dbl>  <dbl>   <dbl>  <dbl>
 1 0.0628  0.659 0.549  0.225   0.861 
 2 0.388   0.283 0.187  0.860   0.110 
 3 0.901   0.519 0.801  0.672   0.0642
 4 0.155   0.205 0.621  0.0967  0.543 
 5 0.00659 0.113 0.755  0.433   0.399 
 6 0.856   0.195 0.0415 0.633   0.370 
 7 0.294   0.393 0.988  0.0550  0.683 
 8 0.457   0.844 0.690  0.00957 0.763 
 9 0.354   0.470 0.681  0.720   0.943 
10 0.905   0.178 0.731  0.490   0.597 
# ℹ 11 more rows

[[2]][[27]]
# A tibble: 66 × 5
       V1      V2     V3    V4     V5
    <dbl>   <dbl>  <dbl> <dbl>  <dbl>
 1 0.633  0.00515 0.153  0.942 0.526 
 2 0.562  0.0111  0.841  0.692 0.189 
 3 0.783  0.570   0.0491 0.782 0.161 
 4 0.777  0.900   0.621  0.367 0.0622
 5 0.246  0.646   0.714  0.391 0.363 
 6 0.852  0.975   0.903  0.255 0.297 
 7 0.353  0.483   0.339  0.142 0.577 
 8 0.749  0.242   0.476  0.964 0.417 
 9 0.0721 0.818   0.283  0.930 0.0695
10 0.884  0.806   0.556  0.124 0.633 
# ℹ 56 more rows

[[2]][[28]]
# A tibble: 48 × 5
      V1     V2     V3     V4     V5
   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.705 0.0536 0.191  0.179  0.450 
 2 0.283 0.0634 0.366  0.0359 0.178 
 3 0.772 0.383  0.720  0.337  0.0262
 4 0.994 0.854  0.555  0.467  0.166 
 5 0.640 0.219  0.533  0.515  0.308 
 6 0.986 0.794  0.790  0.515  0.223 
 7 0.473 0.840  0.324  0.572  0.937 
 8 0.434 0.443  0.774  0.603  0.849 
 9 0.180 0.833  0.663  0.196  0.0845
10 0.452 0.771  0.0423 0.111  0.613 
# ℹ 38 more rows

[[2]][[29]]
# A tibble: 61 × 5
      V1     V2     V3     V4    V5
   <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.383 0.0729 0.500  0.840  0.752
 2 0.455 0.394  0.136  0.0947 0.540
 3 0.811 0.475  0.684  0.332  0.468
 4 0.381 0.251  0.439  0.653  0.839
 5 0.998 0.804  0.344  0.872  0.244
 6 0.116 0.846  0.425  0.819  0.376
 7 0.457 0.472  0.0774 0.470  0.190
 8 0.227 0.227  0.109  0.339  0.738
 9 0.170 0.830  0.487  0.601  0.407
10 0.400 0.550  0.0844 0.874  0.839
# ℹ 51 more rows

[[2]][[30]]
# A tibble: 74 × 5
       V1     V2     V3    V4    V5
    <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.0776 0.0188 0.503  0.795 0.739
 2 0.602  0.0793 0.734  0.595 0.888
 3 0.627  0.500  0.142  0.315 0.842
 4 0.813  0.0345 0.547  0.810 0.283
 5 0.0656 0.281  0.835  0.235 0.290
 6 0.0783 0.700  0.584  0.643 0.400
 7 0.980  0.419  0.560  0.697 0.967
 8 0.713  0.536  0.121  0.361 0.778
 9 0.665  0.175  0.460  0.299 0.141
10 0.613  0.655  0.0267 0.971 0.488
# ℹ 64 more rows

[[2]][[31]]
# A tibble: 49 × 5
      V1     V2     V3    V4     V5
   <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.291 0.0570 0.0461 0.636 0.871 
 2 0.713 0.573  0.262  0.572 0.634 
 3 0.221 0.606  0.344  0.241 0.0306
 4 0.825 0.742  0.902  0.220 0.0616
 5 0.613 0.537  0.914  0.637 0.809 
 6 0.143 0.355  0.0954 0.111 0.135 
 7 0.748 0.950  0.407  0.498 0.261 
 8 0.589 0.544  0.0641 0.209 0.154 
 9 0.509 0.554  0.0384 0.973 0.863 
10 0.192 0.366  0.971  0.437 0.589 
# ℹ 39 more rows

[[2]][[32]]
# A tibble: 1 × 5
     V1    V2    V3    V4    V5
  <dbl> <dbl> <dbl> <dbl> <dbl>
1 0.790 0.724 0.488 0.619 0.403

[[2]][[33]]
# A tibble: 70 × 5
        V1     V2    V3     V4     V5
     <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.00474 0.957  0.504 0.272  0.312 
 2 0.170   0.378  0.869 0.595  0.668 
 3 0.758   0.253  0.166 0.532  0.833 
 4 0.600   0.132  0.624 0.490  0.441 
 5 0.476   0.707  0.297 0.382  0.871 
 6 0.687   0.992  0.211 0.707  0.0829
 7 0.406   0.0632 0.608 0.620  0.292 
 8 0.696   0.787  0.508 0.0257 0.242 
 9 0.290   0.423  0.322 0.754  0.901 
10 0.284   0.934  0.220 0.898  0.760 
# ℹ 60 more rows

[[2]][[34]]
# A tibble: 55 × 5
      V1     V2     V3      V4      V5
   <dbl>  <dbl>  <dbl>   <dbl>   <dbl>
 1 0.570 0.0767 0.273  0.301   0.280  
 2 0.507 0.144  0.0792 0.00459 0.385  
 3 0.913 0.0127 0.983  0.606   0.325  
 4 0.521 0.651  0.452  0.807   0.00738
 5 0.631 0.542  0.801  0.861   0.215  
 6 0.608 0.0562 0.387  0.470   0.487  
 7 0.775 0.524  0.369  0.203   0.453  
 8 0.903 0.547  0.532  0.283   0.0804 
 9 0.825 0.768  0.314  0.667   0.113  
10 0.304 0.147  0.244  0.503   0.168  
# ℹ 45 more rows

[[2]][[35]]
# A tibble: 3 × 5
     V1     V2    V3     V4     V5
  <dbl>  <dbl> <dbl>  <dbl>  <dbl>
1 0.852 0.419  0.650 0.0366 0.0663
2 0.376 0.0746 0.709 0.114  0.511 
3 0.627 0.961  0.787 0.343  0.286 

[[2]][[36]]
# A tibble: 44 × 5
       V1     V2    V3     V4      V5
    <dbl>  <dbl> <dbl>  <dbl>   <dbl>
 1 0.857  0.456  0.156 0.0427 0.780  
 2 0.690  0.226  0.984 0.0686 0.00848
 3 0.0963 0.504  0.134 0.225  0.824  
 4 0.810  0.658  0.382 0.519  0.151  
 5 0.404  0.0963 0.724 0.839  0.447  
 6 0.103  0.726  0.963 0.767  0.680  
 7 0.771  0.671  0.763 0.165  0.862  
 8 0.842  0.421  0.134 0.262  0.266  
 9 0.344  0.0234 0.866 0.957  0.614  
10 0.828  0.778  0.636 0.995  0.888  
# ℹ 34 more rows

[[2]][[37]]
# A tibble: 27 × 5
      V1    V2      V3    V4     V5
   <dbl> <dbl>   <dbl> <dbl>  <dbl>
 1 0.372 0.915 0.196   0.601 0.433 
 2 0.904 0.279 0.930   0.863 0.309 
 3 0.824 0.752 0.0292  0.663 0.684 
 4 0.105 0.887 0.824   0.150 0.153 
 5 0.463 0.253 0.528   0.404 0.289 
 6 0.391 0.197 0.998   0.659 0.888 
 7 0.676 0.108 0.00274 0.574 0.780 
 8 0.877 0.893 0.135   0.124 0.489 
 9 0.241 0.766 0.751   0.827 0.889 
10 0.170 0.893 0.779   0.667 0.0528
# ℹ 17 more rows

[[2]][[38]]
# A tibble: 58 × 5
      V1     V2    V3     V4    V5
   <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.429 0.491  0.433 0.709  0.187
 2 0.913 0.918  0.626 0.207  0.183
 3 0.998 0.177  0.404 0.218  0.382
 4 0.101 0.0493 0.190 0.425  0.789
 5 0.272 0.536  0.118 0.867  0.571
 6 0.855 0.510  0.112 0.958  0.517
 7 0.896 0.223  0.715 0.0134 0.551
 8 0.476 0.505  0.963 0.293  0.470
 9 0.903 0.258  0.941 0.140  0.970
10 0.491 0.136  0.935 0.416  0.677
# ℹ 48 more rows

[[2]][[39]]
# A tibble: 31 × 5
       V1    V2     V3     V4     V5
    <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.933  0.860 0.0787 0.552  0.129 
 2 0.679  0.554 0.840  0.727  0.150 
 3 0.700  0.501 0.0915 0.521  0.105 
 4 0.574  0.553 0.934  0.131  0.124 
 5 0.861  0.639 0.160  0.413  0.939 
 6 0.574  0.546 0.219  0.941  0.111 
 7 0.558  0.698 0.760  0.0419 0.0839
 8 0.233  0.374 0.835  0.239  0.0649
 9 0.0772 0.409 0.355  0.196  0.249 
10 0.637  0.607 0.901  0.703  0.201 
# ℹ 21 more rows

[[2]][[40]]
# A tibble: 48 × 5
       V1     V2     V3     V4     V5
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.837  0.654  0.0994 0.352  0.552 
 2 0.925  0.309  0.963  0.393  0.642 
 3 0.661  0.0770 0.263  0.549  0.421 
 4 0.973  0.626  0.0789 0.0210 0.0911
 5 0.437  0.0373 0.921  0.215  0.769 
 6 0.0919 0.330  0.0630 0.818  0.760 
 7 0.361  0.517  0.757  0.179  0.444 
 8 0.636  0.445  0.613  0.320  0.381 
 9 0.631  0.793  0.564  0.140  0.535 
10 0.536  0.581  0.564  0.526  0.0497
# ℹ 38 more rows

[[2]][[41]]
# A tibble: 54 × 5
       V1    V2      V3     V4    V5
    <dbl> <dbl>   <dbl>  <dbl> <dbl>
 1 0.0449 0.758 0.778   0.430  0.537
 2 0.574  0.214 0.265   0.264  0.364
 3 0.234  0.949 0.262   0.639  0.657
 4 0.179  0.351 0.00756 0.758  0.487
 5 0.126  0.760 0.546   0.839  0.195
 6 0.791  0.525 0.405   0.883  0.970
 7 0.646  0.368 0.239   0.0678 0.611
 8 0.229  0.703 0.723   0.973  0.419
 9 0.177  0.119 0.0883  0.105  0.852
10 0.442  0.906 0.723   0.672  0.175
# ℹ 44 more rows

[[2]][[42]]
# A tibble: 67 × 5
       V1     V2     V3    V4      V5
    <dbl>  <dbl>  <dbl> <dbl>   <dbl>
 1 0.250  0.925  0.710  0.306 0.974  
 2 0.837  0.401  0.156  0.812 0.165  
 3 0.480  0.387  0.109  0.477 0.00231
 4 0.0985 0.980  0.306  0.159 0.780  
 5 0.250  0.114  0.947  0.135 0.333  
 6 0.107  0.849  0.225  0.394 0.999  
 7 0.662  0.120  0.131  0.584 0.685  
 8 0.264  0.0319 0.0256 0.570 0.165  
 9 0.586  0.640  0.355  0.689 0.139  
10 0.829  0.746  0.456  0.169 0.0675 
# ℹ 57 more rows

[[2]][[43]]
# A tibble: 35 × 5
        V1     V2     V3     V4     V5
     <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.791   0.342  0.383  0.677  0.529 
 2 0.879   0.192  0.0357 0.973  0.863 
 3 0.869   0.692  0.0552 0.519  0.0155
 4 0.778   0.0283 0.478  0.351  0.339 
 5 0.107   0.802  0.368  0.442  0.188 
 6 0.631   0.210  0.967  0.0853 0.0292
 7 0.00430 0.322  0.707  0.647  0.977 
 8 0.366   0.0759 0.0636 0.717  0.921 
 9 0.276   0.204  0.533  0.180  0.766 
10 0.767   0.110  0.539  0.561  0.0936
# ℹ 25 more rows

[[2]][[44]]
# A tibble: 23 × 5
       V1     V2     V3    V4    V5
    <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.0718 0.0546 0.374  0.294 0.430
 2 0.544  0.984  0.267  0.585 0.323
 3 0.907  0.0249 0.0828 0.803 0.123
 4 0.634  0.513  0.486  0.827 0.666
 5 0.808  0.634  0.680  0.908 0.842
 6 0.549  0.590  0.194  0.790 0.190
 7 0.517  0.327  0.0891 0.901 0.853
 8 0.216  0.148  0.632  0.380 0.414
 9 0.140  0.561  0.235  0.286 0.218
10 0.416  0.665  0.189  0.488 0.500
# ℹ 13 more rows

[[2]][[45]]
# A tibble: 5 × 5
     V1    V2     V3    V4    V5
  <dbl> <dbl>  <dbl> <dbl> <dbl>
1 0.839 0.259 0.799  0.405 0.511
2 0.272 0.988 0.0621 0.957 0.768
3 0.839 0.739 0.110  0.634 0.163
4 0.206 0.679 0.922  0.231 0.970
5 0.176 0.448 0.0499 0.486 0.948

[[2]][[46]]
# A tibble: 9 × 5
      V1     V2    V3      V4      V5
   <dbl>  <dbl> <dbl>   <dbl>   <dbl>
1 0.321  0.390  0.227 0.105   0.0788 
2 0.0548 0.429  0.451 0.299   0.00826
3 0.328  0.245  0.267 0.478   0.367  
4 0.628  0.0377 0.291 0.00221 0.624  
5 0.557  0.826  0.599 0.788   0.270  
6 0.175  0.683  0.773 0.0337  0.458  
7 0.348  0.804  0.259 0.619   0.668  
8 0.133  0.807  0.421 0.478   0.573  
9 0.0347 0.513  0.424 0.607   0.236  

[[2]][[47]]
# A tibble: 43 × 5
      V1     V2    V3    V4    V5
   <dbl>  <dbl> <dbl> <dbl> <dbl>
 1 0.672 0.633  0.746 0.215 0.236
 2 0.655 0.111  0.347 0.923 0.205
 3 0.753 0.0794 0.404 0.967 0.273
 4 0.897 0.485  0.688 0.455 0.258
 5 0.575 0.986  0.471 0.170 0.922
 6 0.469 0.639  0.595 0.912 0.618
 7 0.798 0.980  0.840 0.572 0.800
 8 0.326 0.477  0.660 0.797 0.865
 9 0.644 0.957  0.895 0.156 0.706
10 0.133 0.578  0.212 0.919 0.474
# ℹ 33 more rows

[[2]][[48]]
# A tibble: 66 × 5
      V1     V2     V3     V4     V5
   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.136 0.586  0.195  0.418  0.697 
 2 0.305 0.771  0.611  0.337  0.589 
 3 0.661 0.778  0.0429 0.607  0.951 
 4 0.805 0.0147 0.823  0.409  0.0625
 5 0.111 0.891  0.704  0.881  0.295 
 6 0.506 0.959  0.818  0.132  0.977 
 7 0.147 0.565  0.890  0.453  0.779 
 8 0.752 0.263  0.663  0.193  0.221 
 9 0.214 0.601  0.665  0.0855 0.413 
10 0.334 0.606  0.289  0.909  0.549 
# ℹ 56 more rows

[[2]][[49]]
# A tibble: 32 × 5
       V1    V2    V3    V4     V5
    <dbl> <dbl> <dbl> <dbl>  <dbl>
 1 0.0395 0.747 0.596 0.745 0.440 
 2 0.366  0.275 0.829 0.419 0.285 
 3 0.331  0.931 0.640 0.933 0.0199
 4 0.949  0.435 0.619 0.754 0.804 
 5 0.322  0.646 0.752 0.830 0.996 
 6 0.314  0.885 0.699 0.110 0.199 
 7 0.518  0.886 0.455 0.624 0.470 
 8 0.751  0.335 0.335 0.260 0.661 
 9 0.251  0.374 0.142 0.307 0.378 
10 0.881  0.637 0.437 0.813 0.0503
# ℹ 22 more rows

[[2]][[50]]
# A tibble: 82 × 5
        V1        V2      V3    V4      V5
     <dbl>     <dbl>   <dbl> <dbl>   <dbl>
 1 0.566   0.306     0.102   0.835 0.220  
 2 0.820   0.194     0.253   0.172 0.644  
 3 0.425   0.775     0.357   0.701 0.609  
 4 0.0928  0.260     0.981   0.876 0.834  
 5 0.0138  0.0000335 0.131   0.798 0.517  
 6 0.827   0.406     0.459   0.561 0.441  
 7 0.00751 0.160     0.979   0.199 0.425  
 8 0.676   0.512     0.00176 0.646 0.00132
 9 0.895   0.142     0.103   0.919 0.203  
10 0.815   0.694     0.718   0.776 0.233  
# ℹ 72 more rows

[[2]][[51]]
# A tibble: 70 × 5
       V1      V2     V3     V4     V5
    <dbl>   <dbl>  <dbl>  <dbl>  <dbl>
 1 0.343  0.396   0.689  0.358  0.0156
 2 0.952  0.00864 0.771  0.648  0.851 
 3 0.287  0.0629  0.0533 0.141  0.0749
 4 0.554  0.755   0.102  0.976  0.726 
 5 0.275  0.0881  0.904  0.880  0.942 
 6 0.723  0.173   0.546  0.572  0.637 
 7 0.482  0.484   0.947  0.265  0.999 
 8 0.245  0.247   0.791  0.0949 0.741 
 9 0.0158 0.754   0.699  0.879  0.864 
10 0.341  0.479   0.713  0.775  0.296 
# ℹ 60 more rows

[[2]][[52]]
# A tibble: 41 × 5
       V1    V2    V3     V4     V5
    <dbl> <dbl> <dbl>  <dbl>  <dbl>
 1 0.611  0.163 0.173 0.0649 0.364 
 2 0.214  0.448 0.679 0.0405 0.568 
 3 0.480  0.349 0.949 0.291  0.393 
 4 0.141  0.982 0.960 0.764  0.479 
 5 0.205  0.928 0.937 0.424  0.104 
 6 0.0597 0.831 0.191 0.321  0.450 
 7 0.433  0.609 0.283 0.462  0.0664
 8 0.882  0.762 0.405 0.285  0.379 
 9 0.975  0.824 0.168 0.281  0.343 
10 0.161  0.381 0.965 0.0114 0.638 
# ℹ 31 more rows

[[2]][[53]]
# A tibble: 4 × 5
       V1    V2    V3    V4    V5
    <dbl> <dbl> <dbl> <dbl> <dbl>
1 0.930   0.621 0.885 0.153 0.574
2 0.103   0.923 0.939 0.632 0.605
3 0.00912 0.840 0.699 0.837 0.579
4 0.909   0.516 0.563 0.616 0.140

[[2]][[54]]
# A tibble: 55 × 5
       V1    V2     V3    V4     V5
    <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.562  0.161 0.889  0.394 0.565 
 2 0.0482 0.504 0.784  0.729 0.0662
 3 0.224  0.117 0.485  0.383 0.218 
 4 0.0569 0.761 0.338  0.799 0.833 
 5 0.498  0.226 0.422  0.426 0.610 
 6 0.209  0.775 0.527  0.876 0.338 
 7 0.801  0.111 0.0353 0.615 0.553 
 8 0.942  0.674 0.436  0.413 0.647 
 9 0.449  0.960 0.683  0.890 0.821 
10 0.0782 0.470 0.995  0.415 0.600 
# ℹ 45 more rows

[[2]][[55]]
# A tibble: 15 × 5
       V1     V2     V3     V4     V5
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.802  0.627  0.0218 0.980  0.258 
 2 0.484  0.439  0.421  0.240  0.0590
 3 0.148  0.486  0.335  0.213  0.410 
 4 0.592  0.998  0.304  0.280  0.460 
 5 0.650  0.806  0.0482 0.429  0.768 
 6 0.591  0.453  0.193  0.323  0.550 
 7 0.352  0.0926 0.676  0.0660 0.266 
 8 0.155  0.798  0.797  0.382  0.445 
 9 0.815  0.794  0.788  0.119  0.907 
10 0.976  0.183  0.612  0.827  0.129 
11 0.905  0.984  0.469  0.0510 0.227 
12 0.672  0.907  0.463  0.780  0.139 
13 0.256  0.988  0.609  0.489  0.608 
14 0.894  0.785  0.775  0.234  0.438 
15 0.0478 0.814  0.840  0.985  0.367 

[[2]][[56]]
# A tibble: 67 × 5
      V1      V2     V3     V4     V5
   <dbl>   <dbl>  <dbl>  <dbl>  <dbl>
 1 0.738 0.901   0.423  0.282  0.179 
 2 0.721 0.492   0.756  0.568  0.875 
 3 0.629 0.0785  0.958  0.258  0.371 
 4 0.234 0.666   0.447  0.495  0.410 
 5 0.655 0.134   0.404  0.373  0.508 
 6 0.469 0.741   0.709  0.693  0.0951
 7 0.232 0.00631 0.537  0.708  0.787 
 8 0.450 0.541   0.0419 0.481  0.319 
 9 0.342 0.408   0.899  0.0873 0.215 
10 0.849 0.176   0.644  0.403  0.766 
# ℹ 57 more rows

[[2]][[57]]
# A tibble: 95 × 5
       V1     V2    V3    V4     V5
    <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.554  0.0885 0.883 0.181 0.429 
 2 0.421  0.722  0.585 0.106 0.320 
 3 0.185  0.950  0.127 0.155 0.754 
 4 0.568  0.490  0.614 0.920 0.169 
 5 0.0502 0.382  0.871 0.955 0.143 
 6 0.436  0.300  0.825 0.796 0.342 
 7 0.840  0.801  0.146 0.744 0.0534
 8 0.611  0.561  0.720 0.951 0.0430
 9 0.850  0.989  0.665 0.714 0.424 
10 0.358  0.839  0.515 0.908 0.346 
# ℹ 85 more rows

[[2]][[58]]
# A tibble: 75 × 5
      V1    V2     V3     V4     V5
   <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.407 0.785 0.990  0.521  0.0253
 2 0.547 0.607 0.0560 0.655  0.329 
 3 0.437 0.991 0.535  0.784  0.237 
 4 0.109 0.862 0.375  0.0567 0.993 
 5 0.984 0.306 0.139  0.617  0.506 
 6 0.174 0.413 0.553  0.483  0.533 
 7 0.346 0.300 0.537  0.0352 0.698 
 8 0.594 0.815 0.208  0.338  0.615 
 9 0.165 0.256 0.499  0.0650 0.723 
10 0.898 0.736 0.390  0.367  0.654 
# ℹ 65 more rows

[[2]][[59]]
# A tibble: 10 × 5
       V1     V2     V3     V4    V5
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.326  0.0317 0.671  0.274  0.482
 2 0.364  0.539  0.853  0.551  0.154
 3 0.926  0.954  0.0215 0.644  0.188
 4 0.950  0.487  0.703  0.330  0.762
 5 0.130  0.163  0.194  0.220  0.881
 6 0.521  0.0583 0.625  0.0861 0.229
 7 0.0953 0.372  0.107  0.124  0.610
 8 0.498  0.754  0.513  0.576  0.646
 9 0.583  0.826  0.919  0.0682 0.546
10 0.987  0.312  0.200  0.556  0.723

[[2]][[60]]
# A tibble: 45 × 5
       V1     V2     V3       V4       V5
    <dbl>  <dbl>  <dbl>    <dbl>    <dbl>
 1 0.330  0.840  0.765  0.000577 0.276   
 2 0.952  0.645  0.788  0.535    0.752   
 3 0.316  0.288  0.852  0.315    0.146   
 4 0.533  0.609  0.272  0.920    0.433   
 5 0.0189 0.263  0.595  0.606    0.000277
 6 0.762  0.373  0.221  0.340    0.237   
 7 0.0663 0.506  0.772  0.400    0.802   
 8 0.698  0.0507 0.251  0.626    0.483   
 9 0.842  0.361  0.674  0.754    0.549   
10 0.426  0.368  0.0850 0.804    0.260   
# ℹ 35 more rows

[[2]][[61]]
# A tibble: 8 × 5
     V1     V2    V3      V4    V5
  <dbl>  <dbl> <dbl>   <dbl> <dbl>
1 0.752 0.824  0.838 0.731   0.442
2 0.550 0.456  0.952 0.915   0.112
3 0.667 0.561  0.300 0.00755 0.380
4 0.896 0.917  0.719 0.899   0.532
5 0.518 0.0184 0.527 0.682   0.668
6 0.670 0.0334 0.784 0.0746  0.768
7 0.610 0.0797 0.157 0.982   0.173
8 0.386 0.545  0.489 0.759   0.594

[[2]][[62]]
# A tibble: 32 × 5
      V1      V2    V3     V4     V5
   <dbl>   <dbl> <dbl>  <dbl>  <dbl>
 1 0.679 0.994   0.500 0.0438 0.726 
 2 0.826 0.125   0.776 0.922  0.762 
 3 0.616 0.355   0.806 0.557  0.545 
 4 0.994 0.00539 0.359 0.155  0.377 
 5 0.892 0.514   0.308 0.811  0.661 
 6 0.777 0.587   0.316 0.114  0.148 
 7 0.620 0.969   0.325 0.545  0.0658
 8 0.951 0.714   0.667 0.370  0.429 
 9 0.803 0.447   0.241 0.245  0.694 
10 0.508 0.184   0.218 0.712  0.902 
# ℹ 22 more rows

[[2]][[63]]
# A tibble: 12 × 5
       V1     V2    V3     V4    V5
    <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.788  0.986  0.580 0.878  0.779
 2 0.0448 0.575  0.803 0.639  0.436
 3 0.970  0.724  0.881 0.859  0.249
 4 0.633  0.0395 0.380 0.619  0.201
 5 0.674  0.245  0.148 0.608  0.511
 6 0.192  0.843  0.635 0.189  0.664
 7 0.964  0.133  0.428 0.112  0.372
 8 0.995  0.178  0.713 0.381  0.262
 9 0.529  0.405  0.740 0.980  0.609
10 0.257  0.535  0.439 0.0286 0.598
11 0.698  0.0473 0.133 0.729  0.327
12 0.203  0.101  0.894 0.433  0.115

[[2]][[64]]
# A tibble: 29 × 5
      V1     V2      V3     V4     V5
   <dbl>  <dbl>   <dbl>  <dbl>  <dbl>
 1 0.736 0.761  0.439   0.265  0.159 
 2 0.589 0.403  0.825   0.898  0.637 
 3 0.699 0.472  0.867   0.558  0.400 
 4 0.666 0.0948 0.370   0.0341 0.903 
 5 0.983 0.932  0.791   0.394  0.141 
 6 0.623 0.788  0.00135 0.147  0.0985
 7 0.773 0.723  0.288   0.518  0.427 
 8 0.950 0.0122 0.620   0.401  0.718 
 9 0.647 0.278  0.717   0.823  0.695 
10 0.214 0.485  0.916   0.141  0.782 
# ℹ 19 more rows

[[2]][[65]]
# A tibble: 56 × 5
      V1    V2     V3     V4    V5
   <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.320 0.228 0.948  0.807  0.473
 2 0.241 0.420 0.761  0.0457 0.863
 3 0.734 0.797 0.504  0.582  0.756
 4 0.808 0.877 0.878  0.417  0.839
 5 0.505 0.262 0.197  0.752  0.572
 6 0.936 0.756 0.0432 0.666  0.598
 7 0.332 0.743 0.258  0.165  0.739
 8 0.203 0.425 0.629  0.953  0.308
 9 0.760 0.113 0.863  0.890  0.547
10 0.146 0.425 0.764  0.926  0.332
# ℹ 46 more rows

[[2]][[66]]
# A tibble: 27 × 5
      V1    V2     V3    V4     V5
   <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.944 0.315 0.957  0.516 0.127 
 2 0.374 0.696 0.359  0.701 0.418 
 3 0.913 0.551 0.307  0.533 0.0113
 4 0.125 0.364 0.353  0.911 0.410 
 5 0.344 0.487 0.0367 0.442 0.532 
 6 0.911 0.576 0.528  0.312 0.721 
 7 0.381 0.872 0.884  0.364 0.194 
 8 0.308 0.516 0.290  0.570 0.389 
 9 0.807 0.627 0.588  0.611 0.751 
10 0.981 0.551 0.649  0.169 0.969 
# ℹ 17 more rows

[[2]][[67]]
# A tibble: 29 × 5
      V1     V2      V3    V4    V5
   <dbl>  <dbl>   <dbl> <dbl> <dbl>
 1 0.882 0.0368 0.715   0.749 0.303
 2 0.785 0.941  0.255   0.349 0.777
 3 0.459 0.494  0.399   0.517 0.399
 4 0.266 0.150  0.0841  0.497 0.869
 5 0.554 0.313  0.403   0.410 0.584
 6 0.904 0.421  0.668   0.693 0.173
 7 0.685 0.172  0.710   0.660 0.758
 8 0.588 0.549  0.00137 0.196 0.462
 9 0.290 0.976  0.772   0.988 0.880
10 0.283 0.448  0.0875  0.575 0.469
# ℹ 19 more rows

[[2]][[68]]
# A tibble: 97 × 5
        V1     V2     V3    V4     V5
     <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.860   0.0808 0.518  0.893 0.160 
 2 0.129   0.960  0.161  0.891 0.851 
 3 0.00107 0.961  0.358  0.909 0.533 
 4 0.0905  0.623  0.624  0.205 0.931 
 5 0.399   0.146  0.966  0.126 0.738 
 6 0.0744  0.273  0.661  0.430 0.375 
 7 0.878   0.470  0.0994 0.816 0.0757
 8 0.878   0.836  0.389  0.940 0.172 
 9 0.696   0.194  0.0960 0.419 0.0298
10 0.503   0.183  0.301  0.573 0.601 
# ℹ 87 more rows

[[2]][[69]]
# A tibble: 29 × 5
      V1     V2     V3    V4    V5
   <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.313 0.0425 0.838  0.273 0.996
 2 0.258 0.630  0.817  0.880 0.886
 3 0.854 0.544  0.818  0.202 0.803
 4 0.818 0.651  0.858  0.716 0.384
 5 0.706 0.921  0.881  0.269 0.910
 6 0.860 0.553  0.0642 0.114 0.260
 7 0.656 0.500  0.686  0.663 0.909
 8 0.936 0.508  0.524  0.268 0.920
 9 0.952 0.0517 0.341  0.923 0.661
10 0.909 0.348  0.655  0.921 0.121
# ℹ 19 more rows

[[2]][[70]]
# A tibble: 37 × 5
      V1     V2     V3      V4     V5
   <dbl>  <dbl>  <dbl>   <dbl>  <dbl>
 1 0.766 0.700  0.871  0.681   0.827 
 2 0.207 0.783  0.229  0.0137  0.283 
 3 0.335 0.790  0.453  0.239   0.361 
 4 0.908 0.825  0.853  0.0669  0.0290
 5 0.127 0.122  0.0987 0.544   0.167 
 6 0.390 0.744  0.378  0.00621 0.466 
 7 0.927 0.0639 0.724  0.437   0.727 
 8 0.208 0.342  0.245  0.958   0.726 
 9 0.961 0.458  0.219  0.144   0.807 
10 0.173 0.933  0.361  0.810   0.292 
# ℹ 27 more rows

[[2]][[71]]
# A tibble: 23 × 5
      V1     V2    V3     V4     V5
   <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.669 0.808  0.958 0.529  0.0906
 2 0.656 0.0162 0.749 0.892  0.284 
 3 0.232 0.782  0.601 0.664  0.384 
 4 0.264 0.560  0.630 0.394  0.128 
 5 0.994 0.202  0.932 0.0681 0.360 
 6 0.731 0.476  0.738 0.595  0.155 
 7 0.787 0.488  0.975 0.268  0.566 
 8 0.168 0.683  0.190 0.798  0.594 
 9 0.806 0.746  0.107 0.551  0.525 
10 0.492 0.861  0.472 0.240  0.923 
# ℹ 13 more rows

[[2]][[72]]
# A tibble: 34 × 5
       V1     V2    V3    V4     V5
    <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.210  0.775  0.439 0.784 0.0788
 2 0.634  0.0298 0.839 0.888 0.831 
 3 0.617  0.0818 0.870 0.156 0.687 
 4 0.672  0.775  0.283 0.153 0.885 
 5 0.191  0.403  0.170 0.418 0.824 
 6 0.0850 0.610  0.545 0.429 0.479 
 7 0.161  0.0190 0.801 0.659 0.195 
 8 0.0207 0.640  0.723 0.602 0.870 
 9 0.167  0.770  0.656 0.555 0.955 
10 0.762  0.374  0.940 0.644 0.908 
# ℹ 24 more rows

[[2]][[73]]
# A tibble: 90 × 5
      V1     V2    V3     V4    V5
   <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.745 0.646  0.301 0.476  0.825
 2 0.518 0.299  0.837 0.663  0.251
 3 0.186 0.549  0.662 0.969  0.463
 4 0.634 0.132  0.200 0.616  0.375
 5 0.928 0.0137 0.739 0.160  0.167
 6 0.538 0.115  0.552 0.591  0.307
 7 0.643 0.212  0.492 0.483  0.300
 8 0.425 0.773  0.502 0.674  0.840
 9 0.855 0.784  0.353 0.707  0.879
10 0.206 0.920  0.879 0.0707 0.827
# ℹ 80 more rows

[[2]][[74]]
# A tibble: 86 × 5
      V1     V2     V3    V4     V5
   <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.289 0.187  0.557  0.901 0.634 
 2 0.674 0.781  0.650  0.470 0.589 
 3 0.824 0.0309 0.622  0.315 0.725 
 4 0.810 0.714  0.545  0.252 0.288 
 5 0.245 0.849  0.0332 0.438 0.277 
 6 0.957 0.627  0.624  0.980 0.714 
 7 0.936 0.176  0.810  0.294 0.470 
 8 0.691 0.0267 0.0546 0.282 0.143 
 9 0.900 0.714  0.254  0.209 0.788 
10 0.422 0.798  0.623  0.693 0.0914
# ℹ 76 more rows

[[2]][[75]]
# A tibble: 95 × 5
       V1    V2     V3    V4     V5
    <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.482  0.290 0.0767 0.636 0.942 
 2 0.764  0.581 0.920  0.926 0.0229
 3 0.821  0.229 0.360  0.215 0.408 
 4 0.680  0.887 0.119  0.861 0.773 
 5 0.974  0.877 0.242  0.521 0.637 
 6 0.0443 0.200 0.303  0.335 0.107 
 7 0.636  0.744 0.109  0.471 0.529 
 8 0.816  0.249 0.469  0.139 0.440 
 9 0.870  0.994 0.870  0.347 0.121 
10 0.203  0.543 0.961  0.786 0.0673
# ℹ 85 more rows

[[2]][[76]]
# A tibble: 30 × 5
      V1     V2      V3     V4    V5
   <dbl>  <dbl>   <dbl>  <dbl> <dbl>
 1 0.136 0.950  0.234   0.399  0.856
 2 0.798 0.701  0.676   0.274  0.671
 3 0.662 0.0394 0.166   0.0906 0.242
 4 0.183 0.988  0.777   0.983  0.270
 5 0.317 0.921  0.268   0.824  0.193
 6 0.279 0.259  0.449   0.358  0.609
 7 0.249 0.811  0.121   0.0110 0.146
 8 0.707 0.0220 0.0880  0.636  0.406
 9 0.588 0.195  0.842   0.150  0.263
10 0.932 0.0116 0.00442 0.853  0.795
# ℹ 20 more rows

[[2]][[77]]
# A tibble: 70 × 5
       V1     V2     V3     V4     V5
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.363  0.573  0.160  0.568  0.242 
 2 0.103  0.428  0.0738 0.151  0.591 
 3 0.564  0.0886 0.920  0.0619 0.909 
 4 0.355  0.809  0.901  0.563  0.581 
 5 0.0514 0.121  0.343  0.101  0.0338
 6 0.877  0.918  0.704  0.396  0.746 
 7 0.476  0.938  0.581  0.194  0.564 
 8 0.501  0.651  0.719  0.0324 0.0425
 9 0.198  0.900  0.429  0.0963 0.371 
10 0.910  0.958  0.440  0.805  0.850 
# ℹ 60 more rows

[[2]][[78]]
# A tibble: 68 × 5
       V1     V2    V3     V4     V5
    <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.139  0.314  0.206 0.421  0.186 
 2 0.505  0.406  0.237 0.944  0.0840
 3 0.0468 0.882  0.829 0.771  0.771 
 4 0.491  0.910  0.499 0.493  0.360 
 5 0.201  0.165  0.810 0.983  0.745 
 6 0.948  0.898  0.682 0.0406 0.319 
 7 0.362  0.429  0.282 0.254  0.468 
 8 0.862  0.719  0.164 0.219  0.393 
 9 0.364  0.452  0.292 0.0574 0.374 
10 0.139  0.0122 0.386 0.112  0.985 
# ℹ 58 more rows

[[2]][[79]]
# A tibble: 50 × 5
      V1     V2    V3     V4     V5
   <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.949 0.0644 0.514 0.157  0.622 
 2 0.642 0.0876 0.116 0.0521 0.917 
 3 0.426 0.344  0.655 0.258  0.778 
 4 0.564 0.525  0.821 0.495  0.426 
 5 0.561 0.294  0.854 0.107  0.760 
 6 0.182 0.797  0.376 0.114  0.285 
 7 0.710 0.101  0.257 0.810  0.685 
 8 0.697 0.489  0.527 0.856  0.743 
 9 0.917 0.122  0.810 0.802  0.0460
10 0.268 0.659  0.512 0.0974 0.0677
# ℹ 40 more rows

[[2]][[80]]
# A tibble: 3 × 5
     V1    V2    V3    V4    V5
  <dbl> <dbl> <dbl> <dbl> <dbl>
1 0.573 0.289 0.282 0.364 0.390
2 0.688 0.301 0.384 0.329 0.876
3 0.853 0.498 0.224 0.382 0.499

[[2]][[81]]
# A tibble: 34 × 5
      V1     V2     V3     V4     V5
   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.465 0.382  0.844  0.962  0.707 
 2 0.203 0.0337 0.626  0.743  0.0852
 3 0.930 0.313  0.463  0.696  0.769 
 4 0.381 0.583  0.775  0.0534 0.654 
 5 0.824 0.946  0.341  0.500  0.690 
 6 0.795 0.618  0.266  0.858  0.208 
 7 0.263 0.844  0.0565 0.742  0.626 
 8 0.907 0.937  0.813  0.301  0.0835
 9 0.241 0.869  0.0248 0.291  0.400 
10 0.287 0.348  0.521  0.470  0.0114
# ℹ 24 more rows

[[2]][[82]]
# A tibble: 52 × 5
      V1     V2     V3     V4     V5
   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.687 0.590  0.224  0.808  0.171 
 2 0.192 0.301  0.964  0.242  0.0811
 3 0.797 0.654  0.281  0.0697 0.0555
 4 0.314 0.322  0.739  0.158  0.833 
 5 0.471 0.551  0.136  0.526  0.883 
 6 0.379 0.936  0.132  0.868  0.937 
 7 0.896 0.0494 0.0219 0.683  0.954 
 8 0.907 0.803  0.709  0.401  0.426 
 9 0.325 0.150  0.448  0.457  0.591 
10 0.833 0.121  0.950  0.177  0.985 
# ℹ 42 more rows

[[2]][[83]]
# A tibble: 73 × 5
       V1    V2     V3      V4      V5
    <dbl> <dbl>  <dbl>   <dbl>   <dbl>
 1 0.273  0.356 0.290  0.624   0.894  
 2 0.109  0.411 0.445  0.669   0.908  
 3 0.759  0.185 0.810  0.109   0.689  
 4 0.462  0.539 0.480  0.343   0.473  
 5 0.353  0.216 0.0998 0.667   0.755  
 6 0.119  0.414 0.315  0.106   0.866  
 7 0.277  0.913 0.170  0.00874 0.495  
 8 0.0284 0.764 0.730  0.325   0.480  
 9 0.464  0.145 0.340  0.965   0.225  
10 0.602  0.677 0.734  0.146   0.00762
# ℹ 63 more rows

[[2]][[84]]
# A tibble: 96 × 5
       V1    V2      V3    V4     V5
    <dbl> <dbl>   <dbl> <dbl>  <dbl>
 1 0.678  0.325 0.00520 0.929 0.559 
 2 0.706  0.586 0.875   0.708 0.407 
 3 0.605  0.919 0.0954  0.533 0.830 
 4 0.356  0.321 0.892   0.680 0.482 
 5 0.996  0.437 0.817   0.731 0.535 
 6 0.0568 0.789 0.175   0.472 0.598 
 7 0.327  0.999 0.437   0.472 0.0530
 8 0.364  0.585 0.496   0.928 0.350 
 9 0.395  0.437 0.923   0.955 0.923 
10 0.906  0.750 0.965   0.583 0.198 
# ℹ 86 more rows

[[2]][[85]]
# A tibble: 73 × 5
       V1    V2     V3     V4    V5
    <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.208  0.940 0.357  0.664  0.146
 2 0.475  0.535 0.331  0.885  0.827
 3 0.260  0.283 0.979  0.876  0.879
 4 0.563  0.295 0.496  0.266  0.693
 5 0.233  0.390 0.695  0.659  0.350
 6 0.580  0.931 0.0396 0.435  0.239
 7 0.0928 0.621 0.313  0.276  0.911
 8 0.998  0.626 0.557  0.185  0.884
 9 0.778  0.507 0.507  0.284  0.399
10 0.598  0.941 0.0748 0.0353 0.720
# ℹ 63 more rows

[[2]][[86]]
# A tibble: 64 × 5
      V1     V2     V3      V4    V5
   <dbl>  <dbl>  <dbl>   <dbl> <dbl>
 1 0.603 0.0840 0.356  0.279   0.512
 2 0.453 0.169  0.172  0.00203 0.880
 3 0.975 0.0907 0.0918 0.541   0.191
 4 0.490 0.666  0.754  0.792   0.113
 5 0.979 0.880  0.183  0.526   0.894
 6 0.310 0.487  0.376  0.300   0.855
 7 0.578 0.879  0.984  0.126   0.656
 8 0.583 0.930  0.861  0.746   0.247
 9 0.425 0.667  0.971  0.472   0.960
10 0.343 0.499  0.453  0.874   0.949
# ℹ 54 more rows

[[2]][[87]]
# A tibble: 51 × 5
       V1     V2     V3    V4     V5
    <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.537  0.345  0.613  0.169 0.0943
 2 0.182  0.145  0.152  0.310 0.463 
 3 0.142  0.337  0.0700 0.485 0.292 
 4 0.765  0.320  0.786  0.957 0.0308
 5 0.364  0.820  0.939  0.366 0.935 
 6 0.613  0.191  0.190  0.372 0.0685
 7 0.0204 0.324  0.558  0.188 0.228 
 8 0.148  0.974  0.243  0.664 0.382 
 9 0.262  0.961  0.478  0.158 0.293 
10 0.0803 0.0840 0.293  0.816 0.162 
# ℹ 41 more rows

[[2]][[88]]
# A tibble: 37 × 5
       V1    V2     V3    V4     V5
    <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.379  0.982 0.0635 0.858 0.835 
 2 0.658  0.610 0.683  0.747 0.265 
 3 0.164  0.664 0.663  0.234 0.919 
 4 0.693  0.474 0.633  0.200 0.146 
 5 0.726  0.494 0.723  0.960 0.140 
 6 0.405  0.837 0.347  0.698 0.567 
 7 0.0584 0.549 0.443  0.927 0.0945
 8 0.602  0.272 0.716  0.328 0.402 
 9 0.462  0.153 0.500  0.206 0.984 
10 0.394  0.357 0.370  0.243 0.905 
# ℹ 27 more rows

[[2]][[89]]
# A tibble: 65 × 5
      V1     V2    V3     V4    V5
   <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.451 0.423  0.396 0.750  0.169
 2 0.985 0.638  0.556 0.0723 0.610
 3 0.165 0.533  0.554 0.364  0.607
 4 0.169 0.863  0.791 0.332  0.923
 5 0.568 0.0122 0.135 0.649  0.940
 6 0.583 0.0786 0.972 0.851  0.360
 7 0.146 0.421  0.847 0.846  0.115
 8 0.759 0.417  0.504 0.582  0.139
 9 0.547 0.120  0.466 0.733  0.961
10 0.360 0.899  0.148 0.353  0.778
# ℹ 55 more rows

[[2]][[90]]
# A tibble: 29 × 5
       V1    V2     V3    V4     V5
    <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.144  0.276 0.120  0.859 0.831 
 2 0.444  0.783 0.126  0.887 0.388 
 3 0.394  0.302 0.320  0.409 0.493 
 4 0.413  0.310 0.927  0.248 0.653 
 5 0.224  0.574 0.0567 0.492 0.0670
 6 0.730  0.973 0.489  0.283 0.975 
 7 0.0107 0.313 0.651  0.623 0.247 
 8 0.793  0.357 0.0255 0.237 0.651 
 9 0.689  0.694 0.810  0.633 0.805 
10 0.999  0.289 0.701  0.483 0.885 
# ℹ 19 more rows

[[2]][[91]]
# A tibble: 71 × 5
       V1    V2     V3     V4    V5
    <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.724  0.258 0.0963 0.449  0.938
 2 0.297  0.520 0.697  0.113  0.327
 3 0.0496 0.645 0.990  0.0690 0.491
 4 0.468  0.473 0.708  0.531  0.527
 5 0.962  0.620 0.239  0.248  0.497
 6 0.242  0.344 0.996  0.743  0.436
 7 0.784  0.363 0.429  0.290  0.577
 8 0.949  0.663 0.688  0.323  0.578
 9 0.689  0.341 0.868  0.838  0.359
10 0.891  0.567 0.965  0.0216 0.588
# ℹ 61 more rows

[[2]][[92]]
# A tibble: 97 × 5
       V1     V2    V3    V4     V5
    <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.980  0.0871 0.107 0.585 0.288 
 2 0.181  0.715  0.351 0.645 0.341 
 3 0.333  0.612  0.362 0.752 0.449 
 4 0.341  0.743  0.275 0.310 0.364 
 5 0.563  0.868  0.861 0.888 0.797 
 6 0.482  0.624  0.276 0.790 0.641 
 7 0.0846 0.349  0.556 0.694 0.150 
 8 0.809  0.908  0.899 0.476 0.993 
 9 0.547  0.207  0.228 0.256 0.315 
10 0.185  0.945  0.690 0.109 0.0258
# ℹ 87 more rows

[[2]][[93]]
# A tibble: 15 × 5
       V1      V2     V3      V4     V5
    <dbl>   <dbl>  <dbl>   <dbl>  <dbl>
 1 0.672  0.620   0.750  0.416   0.376 
 2 0.428  0.658   0.481  0.731   0.455 
 3 0.642  0.0920  0.373  0.861   0.268 
 4 0.322  0.922   0.483  0.0449  0.890 
 5 0.987  0.711   0.749  1.00    0.0284
 6 0.188  0.113   0.965  0.0175  0.364 
 7 0.591  0.210   0.336  0.223   0.129 
 8 0.378  0.323   0.523  0.707   0.469 
 9 0.878  0.260   0.205  0.747   0.199 
10 0.0775 0.837   0.877  0.771   0.743 
11 0.124  0.00748 0.419  0.0110  0.758 
12 0.567  0.133   0.0859 0.791   0.726 
13 0.102  0.857   0.900  0.589   0.664 
14 0.493  0.375   0.435  0.00773 0.549 
15 0.683  0.375   0.565  0.489   0.803 

[[2]][[94]]
# A tibble: 46 × 5
        V1    V2     V3     V4     V5
     <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.983   0.105 0.232  0.303  0.434 
 2 0.591   0.738 0.188  0.249  0.0825
 3 0.318   0.869 0.219  0.288  0.922 
 4 0.0972  0.749 0.447  0.290  0.333 
 5 0.534   0.241 0.306  0.333  0.173 
 6 0.337   0.594 0.273  0.0279 0.998 
 7 0.00387 0.608 0.125  0.656  0.491 
 8 0.405   0.213 0.0342 0.448  0.154 
 9 0.715   0.727 0.855  0.684  0.653 
10 0.614   0.282 0.487  0.834  0.271 
# ℹ 36 more rows

[[2]][[95]]
# A tibble: 62 × 5
       V1    V2     V3    V4     V5
    <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.237  0.678 0.769  0.828 0.616 
 2 0.180  0.334 0.941  0.127 0.440 
 3 0.848  0.614 0.223  0.612 0.182 
 4 0.0868 0.239 0.0688 0.913 0.0408
 5 0.338  0.972 0.511  0.340 0.145 
 6 0.0727 0.727 0.435  0.941 0.603 
 7 0.445  0.977 0.293  0.311 0.940 
 8 0.654  0.193 0.515  0.470 0.0488
 9 0.929  0.777 0.362  0.749 0.222 
10 0.149  0.967 0.847  0.979 0.807 
# ℹ 52 more rows

[[2]][[96]]
# A tibble: 76 × 5
      V1     V2     V3     V4     V5
   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.681 0.0480 0.180  0.943  0.717 
 2 0.769 0.336  0.326  0.550  0.384 
 3 0.531 0.0668 0.0658 0.0107 0.969 
 4 0.421 0.999  0.368  0.103  0.662 
 5 0.221 0.394  0.964  0.174  0.478 
 6 0.412 0.937  0.206  0.0112 0.561 
 7 0.933 0.551  0.332  0.847  0.0215
 8 0.711 0.190  0.429  0.973  0.373 
 9 0.821 0.336  0.653  0.917  0.468 
10 0.632 0.624  0.210  0.0129 0.324 
# ℹ 66 more rows

[[2]][[97]]
# A tibble: 92 × 5
       V1     V2     V3    V4     V5
    <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.412  0.761  0.103  0.734 0.320 
 2 0.751  0.478  0.966  0.672 0.665 
 3 0.0454 0.570  0.133  0.407 0.473 
 4 0.539  0.107  0.871  0.758 0.0438
 5 0.437  0.837  0.361  0.928 0.131 
 6 0.868  1.00   0.862  0.956 0.530 
 7 0.329  0.840  0.397  0.337 0.628 
 8 0.829  0.228  0.0495 0.814 0.487 
 9 0.234  0.0627 0.0129 0.755 0.149 
10 0.0467 0.406  0.857  0.302 0.999 
# ℹ 82 more rows

[[2]][[98]]
# A tibble: 53 × 5
       V1     V2    V3     V4    V5
    <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.609  0.994  0.857 0.684  0.663
 2 0.895  0.288  0.594 0.644  0.239
 3 0.701  0.953  0.770 0.536  0.747
 4 0.466  0.0125 0.667 0.498  0.193
 5 0.776  0.354  0.654 0.0259 0.506
 6 0.347  0.461  0.545 0.482  0.288
 7 0.835  0.282  0.938 0.638  0.852
 8 0.0704 0.625  0.240 0.780  0.592
 9 0.324  0.0326 0.945 0.478  0.824
10 0.425  0.535  0.710 0.934  0.168
# ℹ 43 more rows

[[2]][[99]]
# A tibble: 10 × 5
      V1     V2    V3     V4    V5
   <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.668 0.816  0.957 0.492  0.700
 2 0.995 0.480  0.673 0.241  0.862
 3 0.490 0.401  0.792 0.0208 0.405
 4 0.366 0.358  0.148 0.229  0.461
 5 0.306 0.130  0.351 0.871  0.417
 6 0.341 0.0982 0.696 0.664  0.280
 7 0.177 0.468  0.979 0.393  0.354
 8 0.975 0.174  0.375 0.641  0.673
 9 0.759 0.676  0.149 0.0698 0.648
10 0.859 0.970  0.325 0.611  0.663

[[2]][[100]]
# A tibble: 74 × 5
       V1    V2     V3     V4     V5
    <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.597  0.597 0.896  0.501  0.513 
 2 0.324  0.496 0.387  0.0524 0.0855
 3 0.663  0.858 0.929  0.160  0.830 
 4 0.962  0.982 0.671  0.866  0.981 
 5 0.343  0.692 0.164  0.259  0.898 
 6 0.0509 0.190 0.846  0.459  0.329 
 7 0.573  0.125 0.851  0.980  0.947 
 8 0.525  0.472 0.330  0.420  0.679 
 9 0.541  0.900 0.0433 0.663  0.466 
10 0.474  0.108 0.924  0.823  0.232 
# ℹ 64 more rows


[[3]]
[[3]][[1]]
# A tibble: 68 × 7
      V1     V2     V3    V4     V5    V6      V7
   <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>   <dbl>
 1 0.885 0.580  0.577  0.496 0.599  0.682 0.308  
 2 0.796 0.763  0.832  0.347 0.691  0.704 0.786  
 3 0.284 0.573  0.191  0.561 0.778  0.283 0.0964 
 4 0.953 0.893  0.0150 0.201 0.0228 0.127 0.631  
 5 0.917 0.446  0.714  0.717 0.103  0.354 0.438  
 6 0.307 0.0733 0.580  0.450 0.427  0.122 0.168  
 7 0.142 0.363  0.323  0.333 0.831  0.267 0.00919
 8 0.173 0.851  0.659  0.901 0.816  0.281 0.956  
 9 0.212 0.461  0.661  0.357 0.401  0.572 0.666  
10 0.421 0.296  0.0229 0.966 0.782  0.513 0.858  
# ℹ 58 more rows

[[3]][[2]]
# A tibble: 26 × 7
       V1     V2    V3       V4     V5     V6    V7
    <dbl>  <dbl> <dbl>    <dbl>  <dbl>  <dbl> <dbl>
 1 0.465  0.0475 0.389 0.507    0.790  0.630  0.988
 2 0.0306 0.983  0.511 0.416    0.969  0.894  0.398
 3 0.208  0.154  0.251 0.000964 0.800  0.240  0.881
 4 0.952  0.783  0.435 0.528    0.197  0.549  0.601
 5 0.821  0.837  0.728 0.188    0.0502 0.868  0.161
 6 0.0179 0.644  0.668 0.905    0.191  0.518  0.189
 7 0.263  0.0723 0.862 0.0246   0.607  0.0449 0.887
 8 0.465  0.297  0.789 0.173    0.532  0.231  0.679
 9 0.447  0.0478 0.899 0.331    0.433  0.981  0.639
10 0.246  0.375  0.294 0.572    0.403  0.449  0.334
# ℹ 16 more rows

[[3]][[3]]
# A tibble: 33 × 7
       V1    V2    V3     V4    V5     V6     V7
    <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.726  0.454 0.883 0.248  0.124 0.850  0.0596
 2 0.0586 0.682 0.843 0.655  0.889 0.751  0.355 
 3 0.172  0.856 0.443 0.0917 0.357 0.0734 0.552 
 4 0.679  0.923 0.770 0.440  0.972 0.544  0.294 
 5 0.161  0.282 0.429 0.632  0.918 0.830  0.509 
 6 0.0316 0.160 0.472 0.423  0.989 0.0596 0.0313
 7 0.446  0.372 0.190 0.323  0.859 0.432  0.361 
 8 0.893  0.975 0.164 0.397  0.107 0.845  0.568 
 9 0.408  0.529 0.542 0.234  0.220 0.305  0.578 
10 0.0390 0.442 0.182 0.302  0.112 0.258  0.117 
# ℹ 23 more rows

[[3]][[4]]
# A tibble: 57 × 7
        V1     V2    V3     V4     V5    V6     V7
     <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.00839 0.987  0.286 0.476  0.934  0.232 0.718 
 2 0.780   0.215  0.777 0.570  0.0870 0.384 0.608 
 3 0.209   0.806  0.176 0.597  0.597  0.775 0.666 
 4 0.670   0.525  0.620 0.383  0.623  0.903 0.200 
 5 0.862   0.261  0.119 0.156  0.958  0.265 0.0177
 6 0.131   0.0600 0.142 0.577  0.660  0.960 0.529 
 7 0.557   0.639  0.380 0.392  0.124  0.198 0.342 
 8 0.902   0.980  0.808 0.0818 0.721  0.102 0.0105
 9 0.0799  0.708  0.661 0.113  0.485  0.585 0.878 
10 0.760   0.842  0.850 0.0526 0.111  0.749 0.457 
# ℹ 47 more rows

[[3]][[5]]
# A tibble: 13 × 7
      V1    V2    V3    V4      V5    V6     V7
   <dbl> <dbl> <dbl> <dbl>   <dbl> <dbl>  <dbl>
 1 0.514 0.746 0.841 0.457 0.623   0.715 0.715 
 2 0.482 0.253 0.480 0.293 0.00624 0.396 0.756 
 3 0.152 0.537 0.972 0.408 0.830   0.876 0.976 
 4 0.636 0.604 0.970 0.732 0.818   0.498 0.310 
 5 0.596 0.943 0.481 0.936 0.940   0.434 0.0542
 6 0.559 0.427 0.992 0.862 0.864   0.664 0.278 
 7 0.431 0.274 0.840 0.102 0.737   0.754 0.761 
 8 0.752 0.194 0.361 0.530 0.344   0.712 0.0960
 9 0.905 0.881 0.423 0.608 0.932   0.312 0.315 
10 0.294 0.835 0.846 0.855 0.387   0.660 0.655 
11 0.749 0.348 0.108 0.102 0.784   0.386 0.788 
12 0.167 0.228 0.909 0.518 0.567   0.198 0.154 
13 0.790 0.832 0.322 0.354 0.323   0.340 0.600 

[[3]][[6]]
# A tibble: 37 × 7
      V1     V2     V3     V4       V5     V6     V7
   <dbl>  <dbl>  <dbl>  <dbl>    <dbl>  <dbl>  <dbl>
 1 0.113 0.888  0.170  0.886  0.379    0.352  0.855 
 2 0.152 0.760  0.547  0.0258 0.153    0.816  0.803 
 3 0.298 0.975  0.168  0.805  0.143    0.129  0.191 
 4 0.929 0.159  0.340  0.589  0.287    0.832  0.789 
 5 0.733 0.107  0.948  0.844  0.414    0.0109 0.460 
 6 0.683 0.324  0.922  0.0410 0.502    0.294  0.785 
 7 0.468 0.374  0.0577 0.204  0.451    0.506  0.428 
 8 0.259 0.296  0.818  0.934  0.238    0.645  0.0238
 9 0.585 0.0341 0.953  0.508  0.000175 0.390  0.467 
10 0.457 0.595  0.895  0.561  0.759    0.743  0.819 
# ℹ 27 more rows

[[3]][[7]]
# A tibble: 5 × 7
       V1    V2    V3     V4    V5    V6    V7
    <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
1 0.769   0.421 0.638 0.0514 0.922 0.593 0.915
2 0.622   0.455 0.395 0.464  0.673 0.475 0.863
3 0.00896 0.912 0.499 0.383  0.164 0.890 0.767
4 0.918   0.773 0.261 0.0582 0.960 0.527 0.723
5 0.675   0.611 0.735 0.225  0.781 0.703 0.283

[[3]][[8]]
# A tibble: 24 × 7
       V1     V2     V3     V4    V5     V6     V7
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.823  0.448  0.279  0.164  0.488 0.0616 0.984 
 2 0.809  0.776  0.0301 0.556  0.932 0.632  0.805 
 3 0.375  0.374  0.527  0.269  0.973 0.533  0.0583
 4 0.657  0.755  0.950  0.680  0.617 0.452  0.394 
 5 0.344  0.933  0.572  0.389  0.998 0.717  0.748 
 6 0.299  0.587  0.320  0.0512 0.182 0.688  0.106 
 7 0.290  0.0304 0.0511 0.747  0.306 0.818  0.938 
 8 0.0689 0.374  0.673  0.991  0.989 0.711  0.725 
 9 0.625  0.209  0.779  0.760  0.967 0.671  0.663 
10 0.452  0.389  0.159  0.456  0.565 0.434  0.320 
# ℹ 14 more rows

[[3]][[9]]
# A tibble: 43 × 7
       V1     V2    V3     V4    V5    V6     V7
    <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.439  0.440  0.826 0.180  0.721 0.395 0.0875
 2 0.182  0.0135 0.373 0.947  0.129 0.210 0.456 
 3 0.225  0.934  0.872 0.622  0.777 0.549 0.177 
 4 0.909  0.657  0.913 0.897  0.920 0.901 0.244 
 5 0.464  0.389  0.280 0.387  0.896 0.523 0.355 
 6 0.693  0.422  0.357 0.792  0.914 0.273 0.512 
 7 0.164  0.659  0.759 0.792  0.505 0.289 0.191 
 8 0.520  0.745  0.610 0.605  0.625 0.962 0.946 
 9 0.263  0.469  0.489 0.207  0.620 0.371 0.211 
10 0.0690 0.471  0.987 0.0159 0.451 0.986 0.425 
# ℹ 33 more rows

[[3]][[10]]
# A tibble: 10 × 7
       V1     V2     V3    V4    V5     V6    V7
    <dbl>  <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl>
 1 0.704  0.694  0.0727 0.383 0.125 0.714  0.728
 2 0.0566 0.906  0.705  0.535 0.310 0.239  0.541
 3 0.405  0.0116 0.949  0.261 0.248 0.283  0.681
 4 0.595  0.977  0.677  0.660 0.119 0.644  0.648
 5 0.0192 0.817  0.396  0.367 0.820 0.403  0.273
 6 0.773  0.0896 0.451  0.740 0.695 0.0522 0.976
 7 0.629  0.559  0.970  0.695 0.276 0.133  0.565
 8 0.403  0.416  0.269  0.309 0.885 0.424  0.842
 9 0.0367 0.0338 0.289  0.133 0.754 0.708  0.702
10 0.756  0.586  0.638  0.249 0.390 0.109  0.558

[[3]][[11]]
# A tibble: 2 × 7
     V1    V2    V3    V4    V5    V6    V7
  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
1 0.423 0.392 0.163 0.937 0.519 0.800 0.863
2 0.173 0.843 0.176 0.929 0.871 0.666 0.799

[[3]][[12]]
# A tibble: 83 × 7
      V1    V2      V3     V4    V5    V6     V7
   <dbl> <dbl>   <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.171 0.141 0.966   0.844  0.350 0.719 0.764 
 2 0.647 0.608 0.00151 0.201  0.781 0.894 0.462 
 3 0.500 0.905 0.773   0.750  0.541 0.481 0.728 
 4 0.846 0.767 0.709   0.615  0.901 0.427 0.0822
 5 0.467 0.138 0.728   0.648  0.694 0.189 0.432 
 6 0.846 0.770 0.198   0.0966 0.470 0.803 0.180 
 7 0.489 0.771 0.626   0.880  0.101 0.726 0.339 
 8 0.210 0.255 0.0882  0.907  0.175 0.568 0.288 
 9 0.883 0.604 0.930   0.197  0.875 0.968 0.249 
10 0.856 0.102 0.303   0.588  0.804 0.393 0.139 
# ℹ 73 more rows

[[3]][[13]]
# A tibble: 6 × 7
     V1    V2    V3    V4    V5    V6     V7
  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>
1 0.285 0.230 0.811 0.957 0.723 0.797 0.376 
2 0.857 0.841 0.375 0.417 0.397 0.193 0.0617
3 0.121 0.409 0.648 0.515 0.119 0.184 0.119 
4 0.420 0.956 0.377 0.194 0.905 0.352 0.929 
5 0.674 0.494 0.195 0.430 0.717 0.757 0.124 
6 0.625 0.795 0.587 0.142 0.604 0.882 0.920 

[[3]][[14]]
# A tibble: 91 × 7
       V1     V2     V3     V4    V5     V6     V7
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.0345 0.0239 0.304  0.560  0.431 0.861  0.334 
 2 0.520  0.468  0.347  0.398  0.408 0.0775 0.0987
 3 0.926  0.972  0.0669 0.943  0.540 0.0582 0.335 
 4 0.557  0.521  0.389  0.190  0.101 0.800  0.547 
 5 0.473  0.142  0.382  0.466  0.439 0.574  0.958 
 6 0.920  0.501  0.0119 0.176  0.592 0.497  0.601 
 7 0.670  0.881  0.366  0.0944 0.574 0.569  0.605 
 8 0.107  0.195  0.206  0.238  0.863 0.346  0.604 
 9 0.286  0.244  0.127  0.795  0.529 0.447  0.553 
10 0.744  0.967  0.614  0.879  0.240 0.419  0.877 
# ℹ 81 more rows

[[3]][[15]]
# A tibble: 19 × 7
       V1    V2    V3    V4     V5      V6    V7
    <dbl> <dbl> <dbl> <dbl>  <dbl>   <dbl> <dbl>
 1 0.0516 0.620 0.775 0.530 0.0459 0.170   0.872
 2 0.113  0.667 0.984 0.169 0.0590 0.980   0.263
 3 0.475  0.531 0.265 0.107 0.641  0.602   0.166
 4 0.572  0.106 0.399 0.701 0.0934 0.705   0.782
 5 0.0261 0.698 0.595 0.558 0.659  0.991   0.837
 6 0.888  0.729 0.434 0.973 0.764  0.764   0.221
 7 0.305  0.221 0.136 0.568 0.114  0.774   0.507
 8 0.0479 0.789 0.206 0.554 0.301  0.389   0.657
 9 0.639  0.488 0.243 0.515 0.0332 0.911   0.241
10 0.231  0.760 0.963 0.136 0.0182 0.490   0.469
11 0.548  0.546 0.588 0.516 0.198  0.647   0.763
12 0.943  0.446 0.969 0.494 0.736  0.871   0.506
13 0.949  0.653 0.749 0.230 0.602  0.542   0.776
14 0.801  0.810 0.999 0.384 0.972  0.928   0.222
15 0.541  0.638 0.639 0.306 0.0974 0.0807  0.224
16 0.367  0.831 0.569 0.103 0.821  0.295   0.674
17 0.787  0.197 0.854 0.619 0.632  0.00536 0.775
18 0.833  0.511 0.839 0.462 0.850  0.987   0.594
19 0.853  0.585 0.960 0.359 0.466  0.00158 0.159

[[3]][[16]]
# A tibble: 16 × 7
      V1     V2     V3    V4     V5     V6    V7
   <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.138 0.580  0.0581 0.181 0.335  0.855  0.403
 2 0.430 0.391  0.485  0.192 0.630  0.386  0.431
 3 0.174 0.905  0.784  0.692 0.463  0.543  0.867
 4 0.193 0.583  0.241  0.453 0.496  0.238  0.975
 5 0.602 0.914  0.722  0.871 0.384  0.333  0.875
 6 0.960 0.949  0.0779 0.363 0.951  0.471  0.270
 7 0.164 0.0582 0.296  0.337 0.522  0.399  0.333
 8 0.943 0.882  0.952  0.164 0.347  0.940  0.114
 9 0.356 0.983  0.729  0.660 0.160  0.608  0.543
10 0.231 0.153  0.165  0.240 0.632  0.249  0.332
11 0.797 0.918  0.0850 0.885 0.813  0.588  0.481
12 0.303 0.545  0.803  0.963 0.0924 0.0797 0.172
13 0.697 0.0168 0.263  0.635 0.378  0.250  0.652
14 0.636 0.207  0.837  0.171 0.215  0.922  0.183
15 0.161 0.409  0.377  0.820 0.689  0.871  0.584
16 0.285 0.357  0.817  0.227 0.617  0.651  0.428

[[3]][[17]]
# A tibble: 60 × 7
      V1    V2    V3     V4    V5    V6    V7
   <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
 1 0.314 0.273 0.292 0.466  0.172 0.161 0.166
 2 0.528 0.430 0.680 0.869  0.931 0.413 0.532
 3 0.870 0.906 0.660 0.195  0.313 0.547 0.327
 4 0.366 0.237 0.912 0.977  0.363 0.366 0.698
 5 0.880 0.770 0.613 0.526  0.705 0.742 0.573
 6 0.148 0.315 0.536 0.321  0.409 0.860 0.856
 7 0.448 0.858 0.805 0.864  0.786 0.899 0.197
 8 0.960 0.272 0.252 0.794  0.306 0.703 0.553
 9 0.860 0.503 0.846 0.696  0.813 0.798 0.268
10 0.887 0.420 0.855 0.0556 0.568 0.231 0.110
# ℹ 50 more rows

[[3]][[18]]
# A tibble: 1 × 7
     V1    V2    V3    V4    V5     V6    V7
  <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl>
1 0.793 0.215 0.411 0.451 0.823 0.0777 0.384

[[3]][[19]]
# A tibble: 55 × 7
       V1     V2     V3     V4    V5     V6      V7
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>   <dbl>
 1 0.559  0.615  0.790  0.605  0.302 0.253  0.173  
 2 0.834  0.727  0.776  0.757  0.322 0.0583 0.573  
 3 0.680  0.199  0.133  0.900  0.445 0.803  0.169  
 4 0.988  0.810  0.743  0.844  0.237 0.940  0.751  
 5 0.576  0.170  0.428  0.479  0.489 0.542  0.328  
 6 0.885  0.0369 0.0668 0.959  0.118 0.0230 0.338  
 7 0.882  0.418  0.728  0.966  0.564 0.0642 0.772  
 8 0.217  0.326  0.224  0.0781 0.988 0.881  0.918  
 9 0.0972 0.663  0.301  0.356  0.518 0.555  0.00766
10 0.980  0.658  0.906  0.980  0.159 0.629  0.158  
# ℹ 45 more rows

[[3]][[20]]
# A tibble: 57 × 7
       V1     V2     V3    V4     V5     V6     V7
    <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.160  0.0654 0.182  0.731 0.977  0.355  0.0378
 2 0.835  0.0523 0.354  0.377 0.674  0.851  0.403 
 3 0.483  0.680  0.386  0.963 0.589  0.0129 0.334 
 4 0.917  0.995  0.841  0.225 0.359  0.431  0.493 
 5 0.0753 0.325  0.933  0.278 0.580  0.541  0.859 
 6 0.135  0.215  1.00   0.211 0.619  0.943  0.695 
 7 0.260  0.0277 0.0661 0.450 0.572  0.216  0.765 
 8 0.500  0.272  0.202  0.799 0.490  0.491  0.540 
 9 0.292  0.927  0.884  0.489 0.172  0.130  0.214 
10 0.915  0.764  0.457  0.296 0.0458 0.0494 0.643 
# ℹ 47 more rows

[[3]][[21]]
# A tibble: 84 × 7
       V1    V2    V3     V4    V5     V6     V7
    <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.803  0.612 0.810 0.929  0.357 0.365  0.0759
 2 0.524  0.432 0.866 0.417  0.927 0.159  0.164 
 3 0.0622 0.608 0.517 0.673  0.586 0.473  0.898 
 4 0.725  0.997 0.472 0.163  0.861 0.0861 0.535 
 5 0.292  0.314 0.654 0.990  0.704 0.436  0.0413
 6 0.594  0.312 0.102 0.150  0.460 0.271  0.196 
 7 0.686  0.808 0.540 0.0118 0.773 0.847  0.179 
 8 0.215  0.451 0.431 0.466  0.576 0.679  0.885 
 9 0.260  0.287 0.841 0.825  0.374 0.491  0.170 
10 0.911  0.554 0.490 0.0700 0.225 0.977  0.0844
# ℹ 74 more rows

[[3]][[22]]
# A tibble: 37 × 7
        V1    V2    V3     V4     V5    V6    V7
     <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.378   0.383 0.350 0.292  0.455  0.112 0.574
 2 0.954   0.337 0.262 0.205  0.314  0.383 0.797
 3 0.140   0.547 0.182 0.581  0.657  0.373 0.859
 4 0.00901 0.680 0.434 0.905  0.0456 0.425 0.571
 5 0.260   0.750 0.540 0.770  0.469  0.901 0.284
 6 0.476   0.513 0.942 0.449  0.303  0.743 0.885
 7 0.302   0.684 0.612 0.423  0.296  0.968 0.794
 8 0.387   0.128 0.482 0.842  0.990  0.827 0.715
 9 0.865   0.594 0.626 0.0900 0.248  0.580 0.949
10 0.733   0.653 0.469 0.979  0.191  0.147 0.480
# ℹ 27 more rows

[[3]][[23]]
# A tibble: 18 × 7
       V1     V2     V3     V4    V5     V6     V7
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.916  0.196  0.265  0.608  0.782 0.198  0.362 
 2 0.0806 0.965  0.192  0.532  0.242 0.666  0.509 
 3 0.0660 0.972  0.433  0.720  0.563 0.0854 0.718 
 4 0.624  0.362  0.131  0.752  0.532 0.412  0.750 
 5 0.247  0.432  0.598  0.764  0.211 0.125  0.213 
 6 0.395  0.510  0.200  0.965  0.465 0.248  0.472 
 7 0.0635 0.956  0.743  0.706  0.287 0.872  0.516 
 8 0.557  0.968  0.433  0.166  0.856 0.690  0.975 
 9 0.286  0.225  0.143  0.920  0.825 0.693  0.486 
10 0.0145 0.916  0.117  0.764  0.912 0.392  0.197 
11 0.0610 0.0101 0.164  0.472  0.563 0.670  0.435 
12 0.0812 0.102  0.503  0.0626 0.384 0.0265 0.0159
13 0.608  0.413  0.587  0.125  0.498 0.193  0.401 
14 0.222  0.357  0.742  0.600  0.259 0.631  0.113 
15 0.0755 0.0307 0.0531 0.0199 0.923 0.216  0.678 
16 0.0103 0.773  0.795  0.622  0.184 0.547  0.461 
17 0.542  0.835  0.330  0.826  0.720 0.399  0.223 
18 0.791  0.118  0.302  0.406  0.463 0.0664 0.783 

[[3]][[24]]
# A tibble: 94 × 7
       V1     V2    V3     V4     V5     V6     V7
    <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.751  0.368  0.267 0.540  0.957  0.661  0.420 
 2 0.623  0.277  0.815 0.880  0.408  0.642  0.546 
 3 0.349  0.756  0.165 0.708  0.0813 0.513  0.396 
 4 0.652  0.917  0.808 0.0574 0.826  0.0205 0.0184
 5 0.0561 0.262  0.878 0.634  0.792  0.189  0.891 
 6 0.177  0.666  0.146 0.335  0.913  0.542  0.381 
 7 0.311  0.0231 0.198 0.479  0.334  0.532  0.128 
 8 0.185  0.339  0.466 0.894  0.386  0.942  0.315 
 9 0.488  0.931  0.761 0.708  0.0994 0.661  0.414 
10 0.0268 0.530  0.132 0.196  0.586  0.922  0.916 
# ℹ 84 more rows

[[3]][[25]]
# A tibble: 49 × 7
       V1     V2     V3     V4     V5    V6     V7
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.0541 0.0169 0.685  0.620  0.0261 0.514 0.579 
 2 0.105  0.164  0.660  0.864  0.105  0.565 0.914 
 3 0.486  0.194  0.774  0.572  0.827  0.712 0.0609
 4 0.448  0.413  0.408  0.291  0.0997 0.309 0.977 
 5 0.707  0.736  0.679  0.0730 0.0851 0.826 0.841 
 6 0.658  0.734  0.0155 0.321  0.127  0.736 0.285 
 7 0.239  0.993  0.424  0.165  0.329  0.703 0.600 
 8 0.0987 0.204  0.964  0.0544 0.620  0.335 0.205 
 9 0.858  0.812  0.969  0.645  0.640  0.152 0.155 
10 0.0517 0.468  0.875  0.640  0.939  0.179 0.0117
# ℹ 39 more rows

[[3]][[26]]
# A tibble: 56 × 7
       V1    V2     V3    V4    V5     V6     V7
    <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl>
 1 0.895  0.913 0.505  0.517 0.739 0.675  0.858 
 2 0.397  0.898 0.126  0.457 0.536 0.409  0.669 
 3 0.962  0.673 0.335  0.682 0.437 0.382  0.744 
 4 0.548  0.187 0.264  0.153 0.916 0.564  0.832 
 5 0.505  0.694 0.962  0.909 0.257 0.893  0.0130
 6 0.776  0.777 0.549  0.736 0.348 0.919  0.941 
 7 0.702  0.991 0.176  0.423 0.870 0.916  0.257 
 8 0.360  0.788 0.0821 0.685 0.609 0.0826 0.478 
 9 0.0866 0.378 0.0717 0.644 0.925 0.450  0.762 
10 0.345  0.767 0.272  0.417 0.951 0.121  0.567 
# ℹ 46 more rows

[[3]][[27]]
# A tibble: 59 × 7
      V1     V2    V3     V4     V5     V6     V7
   <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.745 0.183  0.215 0.827  0.476  0.893  0.431 
 2 0.482 0.755  0.251 0.0209 0.609  0.186  0.854 
 3 0.222 0.439  0.818 0.769  0.645  0.419  0.620 
 4 0.821 0.861  0.849 0.527  0.703  0.716  0.294 
 5 0.764 0.508  0.103 0.993  0.0608 0.962  0.0113
 6 0.216 0.164  0.883 0.206  0.223  0.404  0.942 
 7 0.442 0.383  0.419 0.253  0.0664 0.283  0.603 
 8 0.739 0.0742 0.861 0.704  0.553  0.571  0.262 
 9 0.226 0.286  0.560 0.812  0.368  0.0904 0.739 
10 0.267 0.469  0.173 0.374  0.375  0.169  0.918 
# ℹ 49 more rows

[[3]][[28]]
# A tibble: 71 × 7
      V1     V2     V3     V4     V5    V6     V7
   <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.553 0.144  0.290  0.0152 0.133  1.00  0.0118
 2 0.400 0.351  0.866  0.0498 0.930  0.102 0.502 
 3 0.966 0.678  0.0363 0.684  0.0407 0.228 0.718 
 4 0.151 0.0856 0.0905 0.104  0.195  0.466 0.314 
 5 0.843 0.328  0.310  0.476  0.0734 0.663 0.489 
 6 0.425 0.859  0.713  0.575  0.0390 0.603 0.487 
 7 0.819 0.256  0.406  0.330  0.882  0.295 0.793 
 8 0.221 0.462  0.491  0.877  0.280  0.752 0.571 
 9 0.278 0.851  0.780  0.605  0.980  0.735 0.352 
10 0.544 0.397  0.726  0.153  0.109  0.400 0.669 
# ℹ 61 more rows

[[3]][[29]]
# A tibble: 33 × 7
       V1     V2     V3     V4     V5    V6    V7
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.945  0.148  0.375  0.125  0.577  0.611 0.393
 2 0.321  0.219  0.943  0.632  0.144  0.101 0.395
 3 0.940  0.218  0.802  0.198  0.665  0.693 0.941
 4 0.737  0.0525 0.603  0.423  0.363  0.608 0.589
 5 0.0640 0.891  0.400  0.383  0.0276 0.328 0.403
 6 0.405  0.197  0.0511 0.0106 0.714  0.798 0.727
 7 0.220  0.495  0.180  0.311  0.166  0.488 0.380
 8 0.609  0.637  0.0293 0.0407 0.570  0.762 0.906
 9 0.329  0.514  0.268  0.0277 0.382  0.200 0.395
10 0.446  0.586  0.273  0.111  0.755  0.894 0.581
# ℹ 23 more rows

[[3]][[30]]
# A tibble: 63 × 7
       V1     V2     V3     V4    V5     V6    V7
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.251  0.608  0.0311 0.187  0.843 0.920  0.896
 2 0.136  0.929  0.252  0.0620 0.711 0.385  0.660
 3 0.415  0.681  0.632  0.573  0.184 0.978  0.289
 4 0.110  0.424  0.408  0.134  0.780 0.518  0.175
 5 0.365  0.362  0.133  0.719  0.428 0.946  0.625
 6 0.0936 0.443  0.522  0.799  0.263 0.119  0.517
 7 0.120  0.502  0.556  0.640  0.539 0.654  0.669
 8 0.291  0.912  0.959  0.421  0.940 0.0400 0.935
 9 0.349  0.994  0.987  0.356  0.213 0.505  0.263
10 0.0496 0.0578 0.506  0.0446 0.301 0.999  0.738
# ℹ 53 more rows

[[3]][[31]]
# A tibble: 70 × 7
       V1    V2    V3     V4     V5     V6     V7
    <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.0751 0.191 0.866 0.699  0.330  0.411  0.332 
 2 0.0701 0.276 0.363 0.687  0.621  0.610  0.216 
 3 0.257  0.103 0.685 0.632  0.253  0.447  0.738 
 4 0.871  0.182 0.281 0.449  0.407  0.332  0.594 
 5 0.131  0.782 0.586 0.287  0.0611 0.146  0.300 
 6 0.571  0.893 0.977 0.648  0.142  0.517  0.858 
 7 0.0308 0.600 0.952 0.526  0.202  0.934  0.585 
 8 0.947  0.560 0.700 0.0283 0.151  0.0173 0.625 
 9 0.453  0.577 0.732 0.502  0.770  0.654  0.383 
10 0.175  0.370 0.883 0.331  0.454  0.909  0.0940
# ℹ 60 more rows

[[3]][[32]]
# A tibble: 36 × 7
       V1     V2     V3     V4    V5     V6    V7
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.0318 0.550  0.399  0.292  0.671 0.795  0.818
 2 0.734  0.407  0.777  0.339  0.653 0.400  0.166
 3 0.740  0.628  0.0256 0.482  0.402 0.554  0.133
 4 0.897  0.776  0.925  0.155  0.348 0.470  0.361
 5 0.845  0.144  0.746  0.385  0.803 0.260  0.838
 6 0.113  0.281  0.405  0.0508 0.921 0.401  0.415
 7 0.574  0.161  0.275  0.185  0.289 0.681  0.511
 8 0.880  0.0613 0.498  0.434  0.710 0.637  0.575
 9 0.745  0.788  0.432  0.429  0.597 0.769  0.886
10 0.133  0.314  0.535  0.816  0.896 0.0559 0.483
# ℹ 26 more rows

[[3]][[33]]
# A tibble: 29 × 7
       V1     V2     V3     V4     V5    V6     V7
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.816  0.354  0.0272 0.153  0.293  0.886 0.388 
 2 0.0967 0.0734 0.644  0.569  0.772  0.609 0.168 
 3 0.960  0.978  0.847  0.0607 0.797  0.643 0.216 
 4 0.700  0.676  0.973  0.136  0.909  0.588 0.580 
 5 0.891  0.848  0.255  0.570  0.0216 0.147 0.167 
 6 0.508  0.411  0.559  0.0552 0.941  0.461 0.744 
 7 0.493  0.237  0.599  0.136  0.844  0.445 0.238 
 8 0.634  0.706  0.257  0.604  0.673  0.213 0.0816
 9 0.331  0.493  0.243  0.978  0.884  0.762 0.601 
10 0.417  0.712  0.589  0.868  0.972  0.839 0.704 
# ℹ 19 more rows

[[3]][[34]]
# A tibble: 91 × 7
       V1     V2     V3     V4    V5     V6     V7
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.254  0.0980 0.745  0.576  0.311 0.941  0.436 
 2 0.791  0.417  0.714  0.869  0.136 0.209  0.292 
 3 0.0563 0.500  0.0683 0.351  0.449 0.176  0.679 
 4 0.566  0.591  0.812  0.0351 0.392 0.953  0.912 
 5 0.769  0.690  0.955  0.0574 0.899 0.455  0.0820
 6 0.999  0.532  0.124  0.687  0.672 0.768  0.0848
 7 0.0741 0.318  0.953  0.747  0.528 0.633  0.0185
 8 0.588  0.228  0.997  0.479  0.473 0.325  0.460 
 9 0.609  0.155  0.567  0.645  0.530 0.478  0.609 
10 0.928  0.916  0.179  0.668  0.477 0.0305 0.508 
# ℹ 81 more rows

[[3]][[35]]
# A tibble: 72 × 7
      V1     V2    V3     V4    V5     V6     V7
   <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.280 0.167  0.276 0.715  0.305 0.912  0.519 
 2 0.103 0.308  0.187 0.901  0.961 0.327  0.293 
 3 0.410 0.269  0.411 0.714  0.509 0.0267 0.220 
 4 0.878 0.0633 0.810 0.117  0.875 0.313  0.806 
 5 0.960 0.582  0.179 0.326  0.909 0.909  0.0602
 6 0.472 0.843  0.795 0.886  0.250 0.583  0.116 
 7 0.915 0.321  0.463 0.510  0.719 0.872  0.458 
 8 0.531 0.590  0.374 0.747  0.237 0.437  0.255 
 9 0.795 0.650  0.682 0.968  0.470 0.494  0.906 
10 0.241 0.628  0.119 0.0790 0.394 0.247  0.767 
# ℹ 62 more rows

[[3]][[36]]
# A tibble: 77 × 7
       V1    V2    V3     V4    V5    V6     V7
    <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.275  0.326 0.213 0.934  0.579 0.626 0.431 
 2 0.0769 0.818 0.591 0.840  0.462 0.662 0.991 
 3 0.594  0.260 0.789 0.289  0.277 0.978 0.613 
 4 0.900  0.945 0.191 0.289  0.807 0.664 0.678 
 5 0.904  0.196 0.275 0.718  1.00  0.889 0.252 
 6 0.881  0.258 0.683 0.0706 0.779 0.118 0.254 
 7 0.724  0.785 0.531 0.360  0.405 0.424 0.765 
 8 0.946  0.927 0.267 0.406  0.146 0.661 0.0624
 9 0.373  0.418 0.449 0.0721 0.500 0.280 0.377 
10 0.484  0.617 0.683 0.0995 0.243 0.200 0.397 
# ℹ 67 more rows

[[3]][[37]]
# A tibble: 33 × 7
       V1     V2     V3     V4     V5    V6     V7
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.347  0.826  0.232  0.511  0.500  0.929 0.543 
 2 0.0247 0.915  0.669  0.766  0.173  0.599 0.691 
 3 0.560  0.827  0.0155 0.231  0.177  0.992 0.0885
 4 0.991  0.740  0.945  0.726  0.580  0.331 0.108 
 5 0.0778 0.0339 0.849  0.986  0.850  0.514 0.829 
 6 0.620  0.196  0.949  0.480  0.537  0.996 0.166 
 7 0.876  0.949  0.265  0.340  0.0546 0.778 0.851 
 8 0.992  0.275  0.898  0.109  0.614  0.897 0.744 
 9 0.568  0.575  0.774  0.567  0.422  0.852 0.272 
10 0.895  0.329  0.771  0.0519 0.376  0.501 0.601 
# ℹ 23 more rows

[[3]][[38]]
# A tibble: 74 × 7
        V1     V2     V3      V4    V5    V6    V7
     <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl> <dbl>
 1 0.942   0.895  0.542  0.256   0.908 0.377 0.712
 2 0.00155 0.994  0.327  0.137   0.615 0.207 0.679
 3 0.198   0.0436 0.0220 0.480   0.924 0.692 0.523
 4 0.343   0.626  0.869  0.0409  0.231 0.814 0.968
 5 0.770   0.270  0.416  0.00647 0.136 0.827 0.599
 6 0.770   0.344  0.906  0.0952  0.686 0.966 0.861
 7 0.196   0.797  0.898  0.402   0.772 0.144 0.186
 8 0.426   0.142  0.332  0.233   0.252 0.996 0.431
 9 0.210   0.500  0.434  0.167   0.412 0.299 0.240
10 0.640   0.703  0.494  0.590   0.863 0.413 0.593
# ℹ 64 more rows

[[3]][[39]]
# A tibble: 6 × 7
     V1    V2     V3     V4    V5     V6    V7
  <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>
1 0.922 0.629 0.0405 0.0952 0.354 0.0956 0.231
2 0.362 0.956 0.803  0.470  0.821 0.0369 0.928
3 0.368 0.122 0.431  0.739  0.619 0.124  0.970
4 0.606 0.976 0.177  0.669  0.288 0.542  0.169
5 0.100 0.204 0.722  0.594  0.809 0.489  0.869
6 0.108 0.837 0.864  0.252  0.814 0.674  0.797

[[3]][[40]]
# A tibble: 84 × 7
      V1     V2     V3      V4     V5    V6     V7
   <dbl>  <dbl>  <dbl>   <dbl>  <dbl> <dbl>  <dbl>
 1 0.644 0.0578 0.379  0.522   0.637  0.582 0.588 
 2 0.105 0.872  0.973  0.00825 0.386  0.345 0.221 
 3 0.576 0.0511 0.799  0.502   0.207  0.701 0.580 
 4 0.751 0.0345 0.144  0.343   0.188  0.379 0.460 
 5 0.683 0.280  0.572  0.334   0.711  0.675 0.653 
 6 0.425 0.360  0.550  0.0714  0.0772 0.650 0.338 
 7 0.179 0.0754 0.0885 0.859   0.392  0.846 0.0960
 8 0.457 0.136  0.745  0.777   0.563  0.181 0.218 
 9 0.242 0.462  0.416  0.570   0.125  0.318 0.956 
10 0.337 0.855  0.0819 0.249   0.251  0.784 0.764 
# ℹ 74 more rows

[[3]][[41]]
# A tibble: 12 × 7
       V1     V2       V3     V4      V5     V6     V7
    <dbl>  <dbl>    <dbl>  <dbl>   <dbl>  <dbl>  <dbl>
 1 0.103  0.676  0.407    0.577  0.00813 0.299  0.969 
 2 0.180  0.765  0.770    0.0222 0.266   0.509  0.848 
 3 0.662  0.731  0.602    0.0387 0.314   0.274  0.496 
 4 0.783  0.458  0.429    0.564  0.315   0.156  0.668 
 5 0.144  0.616  0.000866 0.583  0.0900  0.923  0.593 
 6 0.899  0.447  0.235    0.493  0.834   0.0318 0.414 
 7 0.242  0.444  0.317    0.678  0.479   0.572  0.351 
 8 0.0339 0.465  0.313    0.450  0.973   0.518  0.348 
 9 0.155  0.0849 0.0596   0.976  0.731   0.143  0.480 
10 0.849  0.371  0.670    0.209  0.676   0.0958 0.726 
11 0.801  0.508  0.0771   0.157  0.358   0.719  0.423 
12 0.955  0.808  0.191    0.396  0.709   0.260  0.0282

[[3]][[42]]
# A tibble: 70 × 7
      V1    V2     V3     V4     V5     V6     V7
   <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.544 0.137 0.550  0.875  0.793  0.176  0.0663
 2 0.227 0.458 0.242  0.0343 0.774  0.847  0.0365
 3 0.686 0.678 1.00   0.346  0.497  0.974  0.202 
 4 0.835 0.370 0.0182 0.499  0.0308 0.534  0.689 
 5 0.186 0.631 0.0207 0.748  0.0537 0.508  0.341 
 6 0.694 0.267 0.989  0.922  0.399  0.699  0.638 
 7 0.724 0.218 0.384  0.689  0.812  0.0835 0.185 
 8 0.111 0.990 0.517  0.287  0.592  0.605  0.357 
 9 0.744 0.648 0.881  0.780  0.0906 0.398  0.826 
10 0.913 0.453 0.644  0.257  0.702  0.331  0.621 
# ℹ 60 more rows

[[3]][[43]]
# A tibble: 80 × 7
       V1     V2     V3     V4      V5    V6    V7
    <dbl>  <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl>
 1 0.605  0.0993 0.749  0.779  0.366   0.724 0.344
 2 0.758  0.604  0.154  0.752  0.470   0.491 0.262
 3 0.0917 0.240  0.616  0.696  0.616   0.674 0.754
 4 0.0384 0.820  0.212  0.0182 0.860   0.647 0.835
 5 0.972  0.0560 0.905  0.633  0.443   0.130 0.929
 6 0.238  0.223  0.245  0.0959 0.284   0.699 0.344
 7 0.662  0.479  0.503  0.0505 0.533   0.281 0.661
 8 0.712  0.492  0.682  0.188  0.625   0.990 0.166
 9 0.760  0.104  0.487  0.630  0.142   0.212 0.479
10 0.644  0.381  0.0510 0.965  0.00364 0.919 0.860
# ℹ 70 more rows

[[3]][[44]]
# A tibble: 38 × 7
        V1    V2     V3     V4     V5    V6     V7
     <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.635   0.447 0.974  0.318  0.620  0.587 0.771 
 2 0.274   0.266 0.490  0.488  0.703  0.936 0.722 
 3 0.132   0.635 0.0198 0.842  0.619  0.456 0.129 
 4 0.648   0.936 0.150  0.186  0.406  0.615 0.724 
 5 0.808   0.145 0.337  0.158  0.529  0.640 0.0808
 6 0.00429 0.325 0.265  0.486  0.702  0.194 0.0392
 7 0.526   0.955 0.619  0.784  0.382  0.451 0.742 
 8 0.0721  0.179 0.380  0.274  0.0722 0.381 0.751 
 9 0.266   0.474 0.469  0.415  0.993  0.974 0.551 
10 0.573   0.692 0.165  0.0552 0.363  0.262 0.0885
# ℹ 28 more rows

[[3]][[45]]
# A tibble: 57 × 7
       V1      V2      V3    V4     V5    V6    V7
    <dbl>   <dbl>   <dbl> <dbl>  <dbl> <dbl> <dbl>
 1 0.356  0.601   0.325   0.717 0.172  0.112 0.154
 2 0.408  0.348   0.327   0.533 0.235  0.209 0.808
 3 0.957  0.00709 0.00908 0.452 0.199  0.605 0.514
 4 0.0635 0.211   0.506   0.768 0.414  0.224 0.618
 5 0.916  0.920   0.833   0.681 0.900  0.349 0.825
 6 0.443  0.135   0.898   0.323 0.670  0.160 0.440
 7 0.925  0.746   0.811   0.895 0.512  0.145 0.633
 8 0.724  0.781   0.833   0.305 0.187  0.562 0.842
 9 0.299  0.0682  0.605   0.995 0.0476 0.329 0.368
10 0.781  0.672   0.313   0.671 0.721  0.134 0.168
# ℹ 47 more rows

[[3]][[46]]
# A tibble: 90 × 7
        V1     V2    V3    V4     V5     V6     V7
     <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.824   0.934  0.174 0.896 0.0664 0.515  0.0715
 2 0.641   0.355  0.230 0.616 0.424  0.292  0.0749
 3 0.800   0.165  0.653 0.890 0.940  0.416  0.929 
 4 0.0147  0.901  0.751 0.715 0.229  0.939  0.187 
 5 0.00810 0.291  0.682 0.184 0.823  0.414  0.193 
 6 0.255   0.539  0.490 0.602 0.540  0.608  0.367 
 7 0.948   0.896  0.884 0.131 0.229  0.974  0.962 
 8 0.476   0.601  0.634 0.767 0.332  0.358  0.543 
 9 0.587   0.0352 0.201 0.517 0.548  0.0463 0.215 
10 0.625   0.600  0.786 0.961 0.198  0.473  0.561 
# ℹ 80 more rows

[[3]][[47]]
# A tibble: 3 × 7
      V1    V2     V3    V4    V5     V6     V7
   <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl>
1 0.0337 0.643 0.711  0.433 0.548 0.0729 0.0691
2 0.985  0.591 0.0485 0.449 0.456 0.0924 0.960 
3 0.124  0.960 0.349  0.195 0.612 0.157  0.619 

[[3]][[48]]
# A tibble: 27 × 7
       V1     V2     V3    V4    V5    V6    V7
    <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>
 1 0.167  0.692  0.801  0.188 0.136 0.181 0.285
 2 0.276  0.197  0.144  0.194 0.636 0.439 0.658
 3 0.807  0.712  0.673  0.570 0.484 0.977 0.367
 4 0.963  0.345  0.357  0.159 0.636 0.404 0.988
 5 0.625  0.822  0.0551 0.315 0.394 0.398 0.720
 6 0.287  0.235  0.118  0.593 0.841 0.514 0.377
 7 0.651  0.675  0.212  0.143 0.917 0.604 0.328
 8 0.0268 0.131  0.451  0.754 0.498 0.807 0.677
 9 0.0913 0.0392 0.592  0.362 0.416 0.928 0.803
10 0.0498 0.937  0.505  0.698 0.666 0.502 0.469
# ℹ 17 more rows

[[3]][[49]]
# A tibble: 67 × 7
       V1    V2    V3    V4      V5     V6      V7
    <dbl> <dbl> <dbl> <dbl>   <dbl>  <dbl>   <dbl>
 1 0.193  0.910 0.317 0.441 0.291   0.0353 0.976  
 2 0.425  0.995 0.678 0.313 0.301   0.555  0.837  
 3 0.497  0.488 0.955 0.794 0.0527  0.991  0.245  
 4 0.0186 0.383 0.793 0.597 0.906   0.427  0.0951 
 5 0.449  0.179 0.287 0.176 0.875   0.963  0.844  
 6 0.739  0.610 0.689 0.392 0.0316  0.411  0.00969
 7 0.184  0.206 0.291 0.147 0.00354 0.814  0.155  
 8 0.950  0.220 0.854 0.937 0.682   0.304  0.356  
 9 0.978  0.558 0.105 0.140 0.802   0.150  0.846  
10 0.876  0.682 0.421 0.828 0.749   0.376  0.824  
# ℹ 57 more rows

[[3]][[50]]
# A tibble: 96 × 7
       V1    V2      V3     V4     V5     V6    V7
    <dbl> <dbl>   <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.960  0.478 0.182   0.142  0.437  0.536  0.751
 2 0.450  0.918 0.969   0.302  0.0597 0.583  0.689
 3 0.978  0.317 0.937   0.287  0.565  0.929  0.877
 4 0.469  0.329 0.231   0.897  0.781  0.737  0.474
 5 0.537  0.712 0.584   0.888  0.306  0.0488 0.494
 6 0.200  0.906 0.00535 0.0466 0.639  0.126  0.427
 7 0.0241 0.931 0.138   0.905  0.726  0.841  0.590
 8 0.0617 0.638 0.0782  0.0616 0.890  0.426  0.782
 9 0.390  0.290 0.366   0.395  0.284  0.0961 0.455
10 0.0266 0.185 0.478   0.925  0.520  0.354  0.260
# ℹ 86 more rows

[[3]][[51]]
# A tibble: 96 × 7
       V1     V2    V3    V4     V5     V6    V7
    <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.231  0.0126 0.275 0.542 0.149  0.605  0.368
 2 0.0825 0.873  0.118 0.874 0.890  0.956  0.322
 3 0.382  0.545  0.666 0.448 0.838  0.0962 0.641
 4 0.684  0.509  0.286 0.975 0.296  0.526  0.645
 5 0.103  0.726  0.454 0.162 0.697  0.588  0.221
 6 0.959  0.0703 0.604 0.801 0.386  0.104  0.188
 7 0.0519 0.225  0.396 0.972 0.338  0.644  0.911
 8 0.400  0.532  0.675 0.464 0.738  0.661  0.785
 9 0.930  0.273  0.195 0.517 0.0505 0.494  0.107
10 0.320  0.925  0.983 0.466 0.470  0.423  0.536
# ℹ 86 more rows

[[3]][[52]]
# A tibble: 86 × 7
       V1    V2    V3     V4     V5     V6     V7
    <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.919  0.982 0.109 0.448  0.0642 0.712  0.232 
 2 0.684  0.398 0.384 0.922  0.316  0.323  0.0730
 3 0.242  0.232 0.543 0.897  0.778  0.355  0.822 
 4 0.783  0.775 0.585 0.185  0.419  0.943  0.484 
 5 0.276  0.425 0.452 0.115  0.448  0.490  0.772 
 6 0.974  0.528 0.611 0.0967 0.655  0.724  0.968 
 7 0.0803 0.114 0.711 0.377  0.246  0.169  0.0486
 8 0.643  0.290 0.816 0.0588 0.429  0.960  0.440 
 9 0.360  0.904 0.788 0.525  0.922  0.0306 0.946 
10 0.209  0.426 0.757 0.178  0.931  0.669  0.480 
# ℹ 76 more rows

[[3]][[53]]
# A tibble: 38 × 7
       V1     V2     V3    V4     V5     V6     V7
    <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.206  0.492  0.221  0.259 0.467  0.407  0.537 
 2 0.0759 0.848  0.0829 0.550 0.283  0.0442 0.461 
 3 0.791  0.0799 0.675  0.768 0.485  0.989  0.788 
 4 0.957  0.195  0.793  0.829 0.0916 0.0447 0.362 
 5 0.352  0.689  0.503  0.408 0.989  0.663  0.572 
 6 0.231  0.396  0.329  0.390 0.965  0.0128 0.0674
 7 0.266  0.791  0.313  0.321 0.529  0.148  0.483 
 8 0.445  0.403  0.415  0.154 0.877  0.617  0.326 
 9 0.0477 0.692  0.311  0.840 0.529  0.834  0.887 
10 0.880  0.804  0.571  0.338 0.144  0.533  0.741 
# ℹ 28 more rows

[[3]][[54]]
# A tibble: 16 × 7
       V1    V2     V3       V4    V5     V6    V7
    <dbl> <dbl>  <dbl>    <dbl> <dbl>  <dbl> <dbl>
 1 0.693  0.706 0.898  0.144    0.784 0.119  0.388
 2 0.613  0.652 0.136  0.385    0.556 0.289  0.250
 3 0.200  0.547 0.636  0.0870   0.233 0.852  0.115
 4 0.254  0.319 0.586  0.444    0.602 0.632  0.152
 5 0.411  0.170 0.763  0.423    0.549 0.0341 0.189
 6 0.416  0.287 0.730  0.153    0.718 0.688  0.151
 7 0.0266 0.872 0.384  0.000735 0.567 0.805  0.341
 8 0.902  0.711 0.264  0.689    0.388 0.819  0.892
 9 0.533  0.315 0.556  0.456    0.908 0.672  0.731
10 0.0777 0.353 0.110  0.961    0.107 0.164  0.115
11 0.909  0.817 0.478  0.688    0.598 0.480  0.556
12 0.667  0.698 0.0724 0.0679   0.352 0.205  0.265
13 0.783  0.986 0.641  0.926    0.633 0.900  0.642
14 0.571  0.776 0.589  0.219    0.427 0.692  0.243
15 0.894  0.511 0.156  0.408    0.416 0.498  0.636
16 0.0826 0.653 0.887  0.126    0.232 0.354  0.195

[[3]][[55]]
# A tibble: 58 × 7
      V1     V2     V3    V4     V5    V6     V7
   <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.902 0.803  0.158  0.583 0.0607 0.337 0.891 
 2 0.783 0.312  0.295  0.846 0.477  0.913 0.767 
 3 0.575 0.0914 0.292  0.941 0.822  0.996 0.378 
 4 0.962 0.665  0.833  0.911 0.549  0.481 0.317 
 5 0.120 0.204  0.343  0.789 0.451  0.193 0.952 
 6 0.184 0.481  0.0980 0.644 0.891  0.507 0.130 
 7 0.929 0.974  0.734  0.792 0.167  0.213 0.175 
 8 0.762 0.595  0.730  0.149 0.354  0.446 0.838 
 9 0.817 0.417  0.677  0.558 0.346  0.213 0.0609
10 0.956 0.755  0.262  0.325 0.664  0.240 0.877 
# ℹ 48 more rows

[[3]][[56]]
# A tibble: 14 × 7
       V1     V2     V3      V4     V5    V6    V7
    <dbl>  <dbl>  <dbl>   <dbl>  <dbl> <dbl> <dbl>
 1 0.117  0.742  0.861  0.538   0.285  0.352 0.733
 2 0.312  0.251  0.529  0.400   0.820  0.716 0.499
 3 0.860  0.685  0.459  0.528   0.105  0.590 0.637
 4 0.742  0.246  0.144  0.00969 0.805  0.479 0.380
 5 0.383  0.750  0.725  0.786   0.377  0.554 0.391
 6 0.361  0.0314 0.933  0.614   0.466  0.121 0.258
 7 0.201  0.279  0.222  0.820   0.0259 0.583 0.894
 8 0.0176 0.135  0.338  0.0902  0.727  0.189 0.701
 9 0.468  0.452  0.0916 0.213   0.349  0.784 0.440
10 0.873  0.799  0.952  0.114   0.746  0.752 0.783
11 0.0610 0.310  0.558  0.340   0.802  0.751 0.339
12 0.701  0.347  0.558  0.640   0.374  0.685 0.850
13 0.306  0.253  0.956  0.751   0.173  0.810 0.114
14 0.481  0.997  0.370  0.416   0.738  0.299 0.340

[[3]][[57]]
# A tibble: 92 × 7
       V1    V2     V3    V4     V5     V6     V7
    <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.376  0.891 0.968  0.539 0.458  0.165  0.880 
 2 0.761  0.897 0.965  0.326 0.921  0.536  0.342 
 3 0.446  0.856 0.274  0.698 0.189  0.250  0.0639
 4 0.836  0.121 0.0198 0.520 0.0575 0.554  0.985 
 5 0.0107 0.804 0.413  0.134 0.958  0.454  0.893 
 6 0.340  0.619 0.771  0.145 0.550  0.142  0.389 
 7 0.394  0.542 0.539  0.952 0.419  0.793  0.494 
 8 0.196  0.504 0.397  0.296 0.662  0.510  0.254 
 9 0.0496 0.611 0.161  0.127 0.266  0.0408 0.529 
10 0.443  0.955 0.720  0.990 0.768  0.0305 0.695 
# ℹ 82 more rows

[[3]][[58]]
# A tibble: 16 × 7
       V1     V2     V3    V4      V5     V6     V7
    <dbl>  <dbl>  <dbl> <dbl>   <dbl>  <dbl>  <dbl>
 1 0.358  0.990  0.281  0.124 0.759   0.499  0.880 
 2 0.257  0.618  0.650  0.585 0.427   0.652  0.785 
 3 0.139  0.696  0.898  0.362 0.00711 0.353  0.300 
 4 0.943  0.869  0.700  0.967 0.830   0.437  0.459 
 5 0.344  0.928  0.907  0.928 0.358   0.931  0.920 
 6 0.236  0.639  0.0708 0.391 0.415   0.0380 0.418 
 7 0.252  0.417  0.787  0.489 0.984   0.686  0.395 
 8 0.448  0.0561 0.332  0.126 0.679   0.649  0.0766
 9 0.503  0.493  0.0641 0.268 0.960   0.743  0.117 
10 0.263  0.252  0.974  0.693 0.842   0.823  0.477 
11 0.0838 0.293  0.998  0.741 0.332   0.309  0.237 
12 0.218  0.856  0.804  0.780 0.285   0.0692 0.0259
13 0.0383 0.0457 0.841  0.226 0.960   0.291  0.864 
14 0.0598 0.505  0.878  0.400 0.829   0.559  0.941 
15 0.728  0.0329 0.515  0.313 0.455   0.464  0.492 
16 0.727  0.460  0.821  0.880 0.425   0.752  0.289 

[[3]][[59]]
# A tibble: 53 × 7
       V1     V2    V3     V4      V5    V6    V7
    <dbl>  <dbl> <dbl>  <dbl>   <dbl> <dbl> <dbl>
 1 0.380  0.802  0.656 0.236  0.482   0.198 0.307
 2 0.163  0.223  0.273 0.404  0.845   0.410 0.206
 3 0.307  0.0334 0.393 0.809  0.00375 0.603 0.527
 4 0.602  0.862  0.873 0.412  0.344   0.107 0.423
 5 0.0806 0.876  0.522 0.729  0.695   0.724 0.706
 6 0.563  0.208  0.641 0.291  0.00256 0.302 0.383
 7 0.845  0.116  0.937 0.918  0.688   0.319 0.662
 8 0.366  0.185  0.584 0.0940 0.377   0.784 0.524
 9 0.499  0.686  0.932 0.721  0.859   0.798 0.507
10 0.185  0.120  0.315 0.185  0.0456  0.691 0.253
# ℹ 43 more rows

[[3]][[60]]
# A tibble: 48 × 7
       V1     V2     V3     V4     V5     V6     V7
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.763  0.300  0.0676 0.971  0.166  0.698  0.536 
 2 0.529  0.0157 0.706  0.673  0.286  0.133  0.0431
 3 0.980  0.639  0.631  0.897  0.508  0.255  0.341 
 4 0.805  0.354  0.0675 0.336  0.677  0.110  0.0589
 5 0.667  0.661  0.480  0.588  0.931  0.781  0.197 
 6 0.328  0.683  0.185  0.871  0.347  0.0181 0.876 
 7 0.0417 0.329  0.575  0.172  0.0387 0.883  0.262 
 8 0.774  0.769  0.892  0.994  0.321  0.103  0.507 
 9 0.247  0.761  0.376  0.0140 0.362  0.282  0.933 
10 0.705  0.748  0.550  0.808  0.544  0.989  0.502 
# ℹ 38 more rows

[[3]][[61]]
# A tibble: 10 × 7
        V1    V2      V3      V4    V5     V6    V7
     <dbl> <dbl>   <dbl>   <dbl> <dbl>  <dbl> <dbl>
 1 0.181   0.212 0.980   0.773   0.595 0.611  0.304
 2 0.960   0.322 0.675   0.0426  0.589 0.0454 0.161
 3 0.854   0.782 0.833   0.707   0.577 0.832  0.309
 4 0.584   0.413 0.325   0.294   0.841 0.826  0.396
 5 0.764   0.639 0.417   0.00374 0.364 0.234  0.622
 6 0.650   0.377 0.934   0.484   0.739 0.587  0.763
 7 0.00666 0.719 0.691   0.724   0.168 0.0673 0.374
 8 0.789   0.668 0.00826 0.550   0.694 0.299  0.750
 9 0.217   0.413 0.431   0.510   0.499 0.296  0.138
10 0.980   0.879 0.766   0.296   0.912 0.144  0.155

[[3]][[62]]
# A tibble: 85 × 7
       V1     V2      V3     V4     V5      V6    V7
    <dbl>  <dbl>   <dbl>  <dbl>  <dbl>   <dbl> <dbl>
 1 0.885  0.210  0.326   0.381  0.0258 0.0389  0.290
 2 0.517  0.572  0.113   0.442  0.0938 0.653   0.610
 3 0.243  0.467  0.0731  0.350  0.703  0.682   0.803
 4 0.758  0.0402 0.413   0.668  0.222  0.716   0.421
 5 0.769  0.920  0.990   0.0455 0.804  0.637   0.319
 6 0.0929 0.534  0.00577 0.826  0.713  0.00871 0.944
 7 0.440  0.607  0.968   0.0628 0.761  0.319   0.462
 8 0.331  0.912  0.401   0.879  0.886  0.611   0.737
 9 0.499  0.247  0.0247  0.579  0.796  0.985   0.447
10 0.340  0.764  0.531   0.116  0.894  0.100   0.831
# ℹ 75 more rows

[[3]][[63]]
# A tibble: 98 × 7
        V1     V2        V3    V4     V5      V6     V7
     <dbl>  <dbl>     <dbl> <dbl>  <dbl>   <dbl>  <dbl>
 1 0.850   0.976  0.284     0.583 0.846  0.590   0.239 
 2 0.469   0.131  0.318     0.666 0.777  0.559   0.0859
 3 0.539   0.0416 0.190     0.171 0.821  0.473   0.575 
 4 0.369   0.936  0.665     0.159 0.496  0.310   0.823 
 5 0.577   0.561  0.839     0.654 0.294  0.954   0.666 
 6 0.0785  0.391  0.265     0.135 0.0909 0.0928  0.408 
 7 0.619   0.0727 0.634     0.592 0.461  0.883   0.236 
 8 0.718   0.809  0.575     0.944 0.321  0.313   0.900 
 9 0.00337 0.0975 0.0000613 0.501 0.419  0.589   0.628 
10 0.567   0.152  0.720     0.539 0.496  0.00459 0.626 
# ℹ 88 more rows

[[3]][[64]]
# A tibble: 23 × 7
       V1    V2     V3    V4    V5     V6     V7
    <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl>
 1 0.679  0.516 0.763  0.856 0.878 0.604  0.872 
 2 0.696  0.517 0.928  0.786 0.719 0.771  0.947 
 3 0.523  0.574 0.0920 0.554 0.734 0.956  0.288 
 4 0.384  0.797 0.718  0.373 0.269 0.328  0.0135
 5 0.511  0.475 0.810  0.175 0.916 0.508  0.803 
 6 0.334  0.743 0.197  0.262 0.640 0.502  0.638 
 7 0.517  0.878 0.181  0.467 0.274 0.0902 0.535 
 8 0.208  0.223 0.759  0.969 0.796 0.977  0.979 
 9 0.226  0.220 0.824  0.469 0.897 0.543  0.973 
10 0.0813 0.963 0.294  0.407 0.699 0.222  0.517 
# ℹ 13 more rows

[[3]][[65]]
# A tibble: 50 × 7
       V1    V2     V3    V4    V5     V6     V7
    <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl>
 1 0.232  0.727 0.409  0.387 0.321 0.598  0.658 
 2 0.846  0.351 0.0988 0.849 0.447 0.817  0.0418
 3 0.858  0.753 0.253  0.586 0.954 0.883  0.513 
 4 0.243  0.848 0.581  0.286 0.314 0.644  0.0980
 5 0.883  0.525 0.681  0.185 0.810 0.997  0.816 
 6 0.251  0.950 1.00   0.768 0.225 0.258  0.0520
 7 0.0453 0.290 0.441  0.198 0.891 0.0502 0.250 
 8 0.243  0.159 0.229  0.353 0.545 0.228  0.957 
 9 0.283  0.589 0.204  0.807 0.998 0.409  0.533 
10 0.796  0.855 0.334  0.525 0.687 0.872  0.125 
# ℹ 40 more rows

[[3]][[66]]
# A tibble: 41 × 7
       V1    V2    V3    V4    V5     V6     V7
    <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>
 1 0.833  0.163 0.378 0.483 0.757 0.708  0.717 
 2 0.0758 0.622 0.869 0.757 0.211 0.755  0.236 
 3 0.926  0.670 0.240 0.549 0.996 0.323  0.174 
 4 0.134  0.246 0.276 0.392 0.656 0.756  0.731 
 5 0.615  0.515 0.574 0.147 0.187 0.529  0.998 
 6 0.846  0.456 0.546 0.952 0.166 0.240  0.532 
 7 0.850  0.417 0.679 0.721 0.571 0.259  0.447 
 8 0.464  0.295 0.674 0.683 0.393 0.297  0.374 
 9 0.0791 0.918 0.707 0.253 0.854 0.381  0.791 
10 0.756  0.936 0.114 0.238 0.515 0.0948 0.0887
# ℹ 31 more rows

[[3]][[67]]
# A tibble: 68 × 7
        V1     V2    V3    V4     V5    V6     V7
     <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.184   0.248  0.890 0.285 0.413  0.195 0.500 
 2 0.745   0.817  0.405 0.142 0.956  0.690 0.613 
 3 0.947   0.283  0.356 0.121 0.638  0.451 0.0626
 4 0.999   0.0308 0.110 0.815 0.913  0.173 0.296 
 5 0.00293 0.432  0.153 0.331 0.524  0.190 0.532 
 6 0.568   0.195  0.681 0.346 0.998  0.369 0.919 
 7 0.0162  0.858  0.362 0.105 0.0578 0.276 0.681 
 8 0.869   0.805  0.136 0.271 0.649  0.261 0.0764
 9 0.0385  0.263  0.404 0.177 0.634  0.990 0.0381
10 0.950   0.776  0.947 0.369 0.301  0.631 0.560 
# ℹ 58 more rows

[[3]][[68]]
# A tibble: 31 × 7
       V1    V2      V3     V4     V5    V6    V7
    <dbl> <dbl>   <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.985  0.489 0.527   0.0628 0.639  0.730 0.142
 2 0.779  0.708 0.416   0.805  0.645  0.847 0.791
 3 0.883  0.705 0.147   0.828  0.730  0.968 0.530
 4 0.289  0.394 0.473   0.479  0.820  0.992 0.751
 5 0.308  0.949 0.968   0.594  0.973  0.612 0.392
 6 0.0456 0.584 0.465   0.0172 0.113  0.957 0.729
 7 0.577  0.720 0.432   0.218  0.429  0.753 0.368
 8 0.445  0.624 0.334   0.280  0.0915 0.921 0.460
 9 0.551  0.899 0.355   0.820  0.979  0.317 0.124
10 0.0961 0.645 0.00962 0.437  0.303  0.107 0.476
# ℹ 21 more rows

[[3]][[69]]
# A tibble: 44 × 7
       V1     V2      V3    V4    V5    V6     V7
    <dbl>  <dbl>   <dbl> <dbl> <dbl> <dbl>  <dbl>
 1 0.240  0.864  0.662   0.641 0.602 0.450 0.153 
 2 0.0178 0.316  0.903   0.202 0.180 0.344 0.152 
 3 0.378  0.136  0.0981  0.540 0.593 0.686 0.338 
 4 0.171  0.522  0.692   0.842 0.807 0.420 0.995 
 5 0.686  0.752  0.915   0.339 0.775 0.952 0.825 
 6 0.592  0.776  0.249   0.270 0.325 0.704 0.0841
 7 0.594  0.738  0.964   0.506 0.298 0.570 0.211 
 8 0.577  0.428  0.342   0.793 0.400 0.894 0.207 
 9 0.233  0.836  0.370   0.124 0.358 0.766 0.440 
10 0.325  0.0502 0.00207 0.332 0.661 0.974 0.184 
# ℹ 34 more rows

[[3]][[70]]
# A tibble: 7 × 7
     V1     V2    V3     V4     V5      V6    V7
  <dbl>  <dbl> <dbl>  <dbl>  <dbl>   <dbl> <dbl>
1 0.848 0.273  0.835 0.0199 0.667  0.870   0.974
2 0.928 0.585  0.162 0.490  0.426  0.934   0.318
3 0.432 0.525  0.156 0.729  0.374  0.00864 0.923
4 0.917 0.440  0.748 0.439  0.485  0.334   0.702
5 0.228 0.259  0.373 0.184  0.125  0.131   0.327
6 0.179 0.435  0.142 0.578  0.0917 0.645   0.904
7 0.973 0.0734 0.375 0.109  0.133  0.507   0.626

[[3]][[71]]
# A tibble: 55 × 7
       V1     V2    V3      V4     V5    V6      V7
    <dbl>  <dbl> <dbl>   <dbl>  <dbl> <dbl>   <dbl>
 1 0.910  0.0862 0.102 0.832   0.0581 0.453 0.0327 
 2 0.559  0.426  0.627 0.840   0.958  0.775 0.00986
 3 0.481  0.798  0.519 0.822   0.541  0.697 0.159  
 4 0.869  0.858  0.881 0.190   0.0512 0.856 0.422  
 5 0.692  0.0746 0.282 0.00503 0.392  0.483 0.686  
 6 0.292  0.740  0.929 0.396   0.0698 0.120 0.0811 
 7 0.880  0.118  0.843 0.633   0.768  0.494 0.812  
 8 0.819  0.641  0.308 0.686   0.986  0.790 0.299  
 9 0.0146 0.143  0.167 0.750   0.231  0.608 0.288  
10 0.333  0.466  0.853 0.185   0.599  0.537 0.384  
# ℹ 45 more rows

[[3]][[72]]
# A tibble: 54 × 7
      V1     V2     V3      V4     V5     V6    V7
   <dbl>  <dbl>  <dbl>   <dbl>  <dbl>  <dbl> <dbl>
 1 0.746 0.764  0.387  0.661   0.906  0.635  0.961
 2 0.455 0.965  0.981  0.0477  0.533  0.875  0.450
 3 0.124 0.188  0.992  0.768   0.0908 0.424  0.956
 4 0.366 0.439  0.0319 0.00919 0.411  0.639  0.586
 5 0.223 0.754  0.116  0.943   0.709  0.0182 0.715
 6 0.323 0.838  0.369  0.650   0.243  0.193  0.526
 7 0.475 0.317  0.212  0.605   0.936  0.466  0.767
 8 0.419 0.423  0.340  0.0400  0.148  0.388  0.938
 9 0.663 0.653  0.611  0.345   0.0541 0.373  0.956
10 0.606 0.0494 0.459  0.491   0.319  0.661  0.515
# ℹ 44 more rows

[[3]][[73]]
# A tibble: 48 × 7
       V1     V2    V3     V4    V5     V6     V7
    <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>
 1 0.827  0.834  0.646 0.0678 0.784 0.0239 0.0928
 2 0.730  0.454  0.205 0.367  0.320 0.726  0.803 
 3 0.999  0.514  0.218 0.491  0.802 0.417  0.988 
 4 0.0327 0.789  0.189 0.642  0.502 0.749  0.405 
 5 0.722  0.529  0.779 0.676  0.132 0.800  0.217 
 6 0.845  0.975  0.357 0.818  0.716 0.616  0.350 
 7 0.266  0.0770 0.310 0.293  0.375 0.962  0.567 
 8 0.235  0.815  0.490 0.875  0.379 0.435  0.135 
 9 0.246  0.190  0.925 0.700  0.968 0.788  0.290 
10 0.442  0.481  0.937 0.120  0.593 0.129  0.313 
# ℹ 38 more rows

[[3]][[74]]
# A tibble: 12 × 7
       V1     V2     V3     V4     V5     V6     V7
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.534  0.396  0.530  0.335  0.740  0.733  0.118 
 2 0.589  0.744  0.0352 0.0976 0.936  0.670  0.164 
 3 0.731  0.956  0.490  0.581  0.591  0.582  0.0512
 4 0.419  0.818  0.818  0.819  0.0895 0.0240 0.243 
 5 0.349  0.278  0.510  0.222  0.126  0.505  0.676 
 6 0.294  0.738  0.607  0.193  0.799  0.343  0.225 
 7 0.202  0.0165 0.981  0.906  0.751  0.525  0.991 
 8 0.792  0.565  0.256  0.890  0.312  0.356  0.722 
 9 0.236  0.729  0.759  0.867  0.237  0.303  0.278 
10 0.751  0.149  0.496  0.303  0.510  0.209  0.467 
11 0.0471 0.143  0.343  0.533  0.411  0.0799 0.163 
12 0.497  0.748  0.271  0.452  0.336  0.527  0.250 

[[3]][[75]]
# A tibble: 29 × 7
       V1      V2     V3    V4    V5       V6    V7
    <dbl>   <dbl>  <dbl> <dbl> <dbl>    <dbl> <dbl>
 1 0.570  0.710   0.205  0.812 0.153 0.891    0.493
 2 0.662  0.706   0.0447 0.929 0.528 0.312    0.450
 3 0.848  0.198   0.561  0.460 0.373 0.470    0.770
 4 0.696  0.106   0.820  0.560 0.396 0.000230 0.103
 5 0.351  0.948   0.413  0.671 0.316 0.908    0.649
 6 0.495  0.597   0.844  0.818 0.851 0.268    0.190
 7 0.881  0.286   0.704  0.570 0.932 0.153    0.102
 8 0.889  0.00218 0.852  0.656 0.918 0.878    0.481
 9 0.354  0.110   0.137  0.368 0.170 0.431    0.171
10 0.0617 0.0539  0.990  0.629 0.813 0.600    0.751
# ℹ 19 more rows

[[3]][[76]]
# A tibble: 98 × 7
       V1      V2    V3    V4     V5     V6     V7
    <dbl>   <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.778  0.876   0.530 0.988 0.424  0.902  0.875 
 2 0.509  0.0521  0.734 0.900 0.575  0.828  0.133 
 3 0.118  0.594   0.116 0.103 0.106  0.290  0.0234
 4 0.0614 0.199   0.250 0.969 0.203  0.0900 0.583 
 5 0.268  0.175   0.847 0.739 0.0722 0.0602 0.822 
 6 0.639  0.249   0.775 0.222 0.250  0.254  0.134 
 7 0.208  0.664   0.859 0.316 0.0975 0.939  0.734 
 8 0.113  0.00568 0.307 0.961 0.0757 0.489  0.903 
 9 0.951  0.703   0.801 0.743 0.0292 0.796  0.956 
10 0.195  0.630   0.308 0.348 0.398  0.659  0.0806
# ℹ 88 more rows

[[3]][[77]]
# A tibble: 1 × 7
     V1    V2    V3    V4    V5    V6    V7
  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
1 0.830 0.274 0.556 0.971 0.159 0.537 0.522

[[3]][[78]]
# A tibble: 70 × 7
       V1    V2    V3     V4    V5    V6    V7
    <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
 1 0.534  0.425 0.830 0.701  0.172 0.874 0.706
 2 0.950  0.378 0.659 0.906  0.443 0.538 0.580
 3 0.980  0.241 0.340 0.0906 0.648 0.373 0.326
 4 0.137  0.239 0.143 0.343  0.771 0.204 0.383
 5 0.363  0.397 0.518 0.413  0.814 0.846 0.961
 6 0.0161 0.413 0.474 0.0949 0.646 0.129 0.651
 7 0.417  0.942 0.687 0.513  0.735 0.195 0.178
 8 0.631  0.479 0.106 0.848  0.824 0.322 0.116
 9 0.576  0.532 0.938 0.275  0.507 0.408 0.131
10 0.688  0.788 0.356 0.417  0.935 0.317 0.626
# ℹ 60 more rows

[[3]][[79]]
# A tibble: 33 × 7
      V1        V2     V3    V4    V5    V6     V7
   <dbl>     <dbl>  <dbl> <dbl> <dbl> <dbl>  <dbl>
 1 0.161 0.156     0.879  0.463 0.136 0.536 0.142 
 2 0.264 0.426     0.155  0.119 0.588 0.922 0.638 
 3 0.577 0.0918    0.678  0.488 0.535 0.263 0.667 
 4 0.397 0.927     0.883  0.527 0.530 0.305 0.204 
 5 0.456 0.134     0.0463 0.213 0.198 0.149 0.284 
 6 0.222 0.0938    0.482  0.152 0.581 0.497 0.510 
 7 0.663 0.969     0.841  0.646 0.160 0.952 0.743 
 8 0.425 1.00      0.937  0.208 0.988 0.735 0.697 
 9 0.723 0.0000492 0.384  0.938 0.913 0.234 0.873 
10 0.332 0.425     0.793  0.124 0.278 0.607 0.0714
# ℹ 23 more rows

[[3]][[80]]
# A tibble: 87 × 7
        V1      V2      V3     V4     V5     V6    V7
     <dbl>   <dbl>   <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.913   0.603   0.302   0.965  0.476  0.812  0.683
 2 0.346   0.793   0.830   0.143  0.0439 0.745  0.239
 3 0.914   0.667   0.605   0.494  0.0291 0.576  0.726
 4 0.854   0.00558 0.00215 0.407  0.556  0.768  0.385
 5 0.669   0.0408  0.559   0.0693 0.817  0.0456 0.374
 6 0.541   0.443   0.711   0.286  0.195  0.747  0.707
 7 0.767   0.239   0.681   0.477  0.778  0.475  0.972
 8 0.0606  0.298   0.624   0.454  0.829  0.238  0.582
 9 0.00863 0.305   0.338   0.144  0.213  0.915  0.752
10 0.587   0.413   0.648   0.588  0.843  0.144  0.129
# ℹ 77 more rows

[[3]][[81]]
# A tibble: 15 × 7
       V1     V2      V3    V4     V5     V6    V7
    <dbl>  <dbl>   <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.928  0.285  0.592   0.379 0.276  0.548  0.398
 2 0.298  0.332  0.916   0.972 0.766  0.800  0.848
 3 0.450  0.577  0.766   0.254 0.842  0.324  0.696
 4 0.459  0.245  0.511   0.843 0.532  0.569  0.168
 5 0.473  0.996  0.458   0.533 0.814  0.950  0.283
 6 0.497  0.956  0.201   0.256 0.544  0.0322 0.123
 7 0.596  0.222  0.507   0.328 0.0674 0.760  0.960
 8 0.262  0.660  0.212   0.478 0.370  0.0872 0.381
 9 0.383  0.525  0.513   0.283 0.622  0.730  0.757
10 0.280  0.309  0.00166 0.212 0.940  0.289  0.972
11 0.744  0.435  0.742   0.219 0.214  0.728  0.393
12 0.939  0.0426 0.966   0.554 0.323  0.620  0.708
13 0.0489 0.210  0.629   0.405 0.442  0.791  0.898
14 0.410  0.349  0.688   0.300 0.423  0.842  0.776
15 0.997  0.604  0.768   0.635 0.883  0.209  0.767

[[3]][[82]]
# A tibble: 92 × 7
      V1    V2    V3    V4    V5    V6     V7
   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>
 1 0.674 0.197 0.227 0.405 0.863 0.786 0.0285
 2 0.474 0.467 0.732 0.629 0.287 0.109 0.340 
 3 0.397 0.448 0.143 0.745 0.285 0.996 0.426 
 4 0.476 0.434 0.324 0.398 0.990 0.145 0.470 
 5 0.968 0.370 0.299 0.610 0.503 0.134 0.669 
 6 0.255 0.286 0.127 0.803 0.895 0.927 0.992 
 7 0.977 0.408 0.698 0.957 0.652 0.699 0.652 
 8 0.339 0.891 0.391 0.989 0.158 0.934 0.0446
 9 0.658 0.109 0.473 0.726 0.930 0.830 0.608 
10 0.241 0.683 0.229 0.697 0.897 0.661 0.822 
# ℹ 82 more rows

[[3]][[83]]
# A tibble: 20 × 7
       V1      V2     V3     V4     V5      V6    V7
    <dbl>   <dbl>  <dbl>  <dbl>  <dbl>   <dbl> <dbl>
 1 0.807  0.106   0.0544 0.426  0.837  0.111   0.242
 2 0.0795 0.800   0.789  0.530  0.876  0.313   0.732
 3 0.360  0.115   0.0830 0.0651 0.273  0.673   0.170
 4 0.778  0.00376 0.955  0.979  0.0495 0.189   0.353
 5 0.123  0.463   0.854  0.738  0.823  0.908   0.432
 6 0.504  0.615   0.488  0.520  0.907  0.806   0.669
 7 0.341  0.206   0.706  0.618  0.466  0.943   0.287
 8 0.575  0.345   0.614  0.0702 0.928  0.957   0.827
 9 0.0733 0.917   0.745  0.268  0.269  0.0494  0.584
10 0.0212 0.570   0.195  0.323  0.210  0.297   0.282
11 0.336  0.128   0.133  0.195  0.579  0.878   0.805
12 0.524  0.958   0.0862 0.655  0.0579 0.0187  0.466
13 0.223  0.0995  0.515  0.153  0.306  0.226   0.957
14 0.638  0.579   0.291  0.936  0.0745 0.370   0.727
15 0.887  0.436   0.744  0.864  0.597  0.617   0.771
16 0.678  0.704   0.638  0.750  0.895  0.0395  0.230
17 0.292  0.800   0.0656 0.101  0.884  0.569   0.581
18 0.968  0.606   0.487  0.659  0.182  0.00929 0.495
19 0.695  0.816   0.725  0.341  0.326  0.882   0.755
20 0.350  0.0550  0.0231 0.0351 0.0395 0.0951  0.935

[[3]][[84]]
# A tibble: 66 × 7
      V1    V2     V3    V4    V5    V6     V7
   <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>  <dbl>
 1 0.302 0.224 0.523  0.805 0.406 0.995 0.680 
 2 0.718 0.697 0.935  0.852 0.652 0.406 0.401 
 3 0.783 0.255 0.794  0.365 0.571 0.505 0.499 
 4 0.612 0.567 0.0698 0.638 0.929 0.328 0.273 
 5 0.744 0.293 0.0732 0.859 0.884 0.834 0.854 
 6 0.533 0.732 0.0706 0.444 0.989 0.193 0.575 
 7 0.821 0.593 0.665  0.543 0.615 0.325 0.602 
 8 0.421 0.916 0.889  0.759 0.215 0.673 0.200 
 9 0.804 0.854 0.518  0.533 0.467 0.818 0.0642
10 0.942 0.769 0.714  0.173 0.716 0.103 0.304 
# ℹ 56 more rows

[[3]][[85]]
# A tibble: 57 × 7
       V1     V2     V3     V4    V5     V6    V7
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.880  0.530  0.486  0.0682 0.159 0.689  0.502
 2 0.171  0.158  0.748  0.880  0.113 0.223  0.453
 3 0.712  0.627  0.312  0.313  0.323 0.714  0.550
 4 0.524  0.904  0.0930 0.0454 0.326 0.243  0.621
 5 0.132  0.599  0.341  0.633  0.202 0.682  0.805
 6 0.827  0.245  0.737  0.480  0.829 0.404  0.855
 7 0.550  0.0722 0.224  0.653  0.236 0.384  0.849
 8 0.0873 0.789  0.324  0.508  0.252 0.0110 0.349
 9 0.420  0.513  0.0528 0.235  0.274 0.624  0.963
10 0.835  0.698  0.183  0.895  0.133 0.694  0.945
# ℹ 47 more rows

[[3]][[86]]
# A tibble: 76 × 7
      V1     V2    V3    V4    V5     V6     V7
   <dbl>  <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>
 1 0.992 0.565  0.983 0.681 0.988 0.220  0.740 
 2 0.432 0.251  0.260 0.588 0.950 0.0120 0.927 
 3 0.460 0.773  0.382 0.224 0.627 0.304  0.0713
 4 0.361 0.527  0.520 0.336 0.872 0.486  0.439 
 5 0.913 0.720  0.965 0.481 0.975 0.960  0.630 
 6 0.936 0.0678 0.916 0.648 0.477 0.935  0.563 
 7 0.329 0.690  0.964 0.789 0.993 0.183  0.804 
 8 0.788 0.831  0.890 0.944 0.656 0.735  0.147 
 9 0.118 0.564  0.785 0.422 0.356 0.869  0.984 
10 0.385 0.523  0.453 0.577 0.531 0.958  0.144 
# ℹ 66 more rows

[[3]][[87]]
# A tibble: 74 × 7
       V1     V2    V3     V4     V5    V6     V7
    <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.963  0.795  0.122 0.449  0.698  0.533 0.982 
 2 0.0929 0.758  0.650 0.851  0.511  0.901 0.313 
 3 0.604  0.296  0.700 0.519  0.155  0.412 0.203 
 4 0.236  0.668  0.452 0.469  0.460  0.188 0.346 
 5 0.662  0.256  0.508 0.594  0.934  0.448 0.0810
 6 0.326  0.416  0.340 0.0128 0.134  0.416 0.335 
 7 0.310  0.270  0.190 0.719  0.0776 0.912 0.183 
 8 0.747  0.0346 0.742 0.280  0.292  0.828 0.836 
 9 0.528  0.411  0.993 0.234  0.463  0.956 0.325 
10 0.146  0.421  0.656 0.0628 0.328  0.850 0.820 
# ℹ 64 more rows

[[3]][[88]]
# A tibble: 69 × 7
       V1    V2     V3    V4    V5     V6    V7
    <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl>
 1 0.0340 0.866 0.196  0.262 0.989 0.988  0.378
 2 0.899  0.704 0.865  0.815 0.498 0.284  0.945
 3 0.618  0.558 0.0726 0.261 0.643 0.785  0.151
 4 0.605  0.345 0.860  0.977 0.860 0.149  0.725
 5 0.473  0.228 0.876  0.676 0.142 0.113  0.704
 6 0.340  0.997 0.810  0.714 0.909 0.142  0.428
 7 0.471  0.922 0.873  0.933 0.573 0.0377 0.897
 8 0.528  0.297 0.859  0.616 0.757 0.0843 0.664
 9 0.746  0.283 0.692  0.189 0.985 0.0746 0.530
10 0.122  0.583 0.0119 0.252 0.752 0.292  0.902
# ℹ 59 more rows

[[3]][[89]]
# A tibble: 62 × 7
       V1    V2     V3     V4     V5    V6     V7
    <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.561  0.429 0.640  0.215  0.931  0.501 0.803 
 2 0.130  0.583 0.751  0.965  0.236  0.321 0.355 
 3 0.600  0.913 0.483  0.853  0.128  0.725 0.615 
 4 0.622  0.292 0.639  0.694  0.779  0.765 0.263 
 5 0.739  0.892 0.0453 0.771  0.0661 0.711 0.179 
 6 0.564  0.123 0.503  0.519  0.507  0.544 0.789 
 7 0.112  0.495 0.139  0.628  0.0806 0.158 0.893 
 8 0.0913 0.988 0.137  0.360  0.643  0.301 0.205 
 9 0.967  0.476 0.315  0.0314 0.577  0.983 0.0861
10 0.157  0.659 0.141  0.973  0.620  0.394 0.513 
# ℹ 52 more rows

[[3]][[90]]
# A tibble: 47 × 7
      V1     V2     V3      V4    V5    V6     V7
   <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl>  <dbl>
 1 0.664 0.715  0.374  0.00290 0.958 0.187 0.324 
 2 0.817 0.0307 0.669  0.918   0.928 0.720 0.0455
 3 0.580 0.757  0.0514 0.314   0.898 0.509 0.503 
 4 0.169 0.431  0.270  0.797   0.941 0.548 0.839 
 5 0.735 0.554  0.696  0.961   0.310 0.358 0.834 
 6 0.959 0.781  0.544  0.962   0.443 0.976 0.152 
 7 0.666 0.0872 0.758  0.818   0.839 0.649 0.360 
 8 0.139 0.537  0.200  0.228   0.500 0.582 0.0803
 9 0.874 0.680  0.968  0.0188  0.785 0.302 0.771 
10 0.620 0.795  0.164  0.720   0.605 0.296 0.632 
# ℹ 37 more rows

[[3]][[91]]
# A tibble: 38 × 7
       V1    V2    V3     V4      V5    V6    V7
    <dbl> <dbl> <dbl>  <dbl>   <dbl> <dbl> <dbl>
 1 0.642  0.669 0.194 0.265  0.368   0.807 0.109
 2 0.458  0.681 0.686 0.587  0.838   0.827 0.580
 3 0.663  0.304 0.630 0.344  0.125   0.426 0.216
 4 0.572  0.651 0.609 0.721  0.00375 0.772 0.142
 5 0.263  0.433 0.485 0.657  0.693   0.410 0.656
 6 0.866  0.554 0.861 0.770  0.607   0.210 0.217
 7 0.430  0.803 0.185 0.0385 0.115   0.461 0.917
 8 0.788  0.303 0.944 0.629  0.385   0.537 0.968
 9 0.184  0.877 0.498 0.729  0.813   0.824 0.818
10 0.0823 0.808 0.775 0.498  0.548   0.394 0.811
# ℹ 28 more rows

[[3]][[92]]
# A tibble: 14 × 7
        V1      V2    V3     V4      V5     V6     V7
     <dbl>   <dbl> <dbl>  <dbl>   <dbl>  <dbl>  <dbl>
 1 0.737   0.600   0.715 0.930  0.474   0.237  0.826 
 2 0.822   0.705   0.307 0.466  0.342   0.935  0.279 
 3 0.00299 0.321   0.577 0.641  0.00987 0.110  0.285 
 4 0.792   0.226   0.602 0.744  0.651   0.483  0.648 
 5 0.0740  0.00908 0.241 0.0361 0.937   0.954  0.187 
 6 0.178   0.935   0.404 0.340  0.144   0.784  0.692 
 7 0.228   0.296   0.572 0.382  0.374   0.270  0.366 
 8 0.387   0.405   0.856 0.778  0.0748  0.0345 0.641 
 9 0.164   0.163   0.286 0.254  0.158   0.316  0.0382
10 0.0497  0.626   0.426 0.372  0.406   0.782  0.603 
11 0.859   0.956   0.320 0.647  0.0768  0.557  0.627 
12 0.403   0.318   0.470 0.989  0.0443  0.202  0.260 
13 0.00284 0.339   0.672 0.382  0.134   0.742  0.694 
14 0.354   0.283   0.492 0.170  0.581   0.649  0.269 

[[3]][[93]]
# A tibble: 84 × 7
      V1    V2    V3    V4     V5     V6      V7
   <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>   <dbl>
 1 0.381 0.312 0.829 0.173 0.892  0.0895 0.730  
 2 0.204 0.887 0.391 0.506 0.541  0.427  0.283  
 3 0.685 0.662 0.968 0.378 0.0644 0.482  0.354  
 4 0.853 0.516 0.451 0.557 0.950  0.868  0.346  
 5 0.191 0.914 0.633 0.211 0.392  0.809  0.329  
 6 0.967 0.710 0.563 0.177 0.388  0.383  0.940  
 7 0.560 0.718 0.717 0.521 0.170  0.901  0.861  
 8 0.490 0.184 0.560 0.302 0.0192 0.0910 0.410  
 9 0.520 0.427 0.622 0.622 0.936  0.0409 0.00321
10 0.703 0.748 0.316 0.912 0.683  0.320  0.889  
# ℹ 74 more rows

[[3]][[94]]
# A tibble: 19 × 7
       V1    V2     V3     V4     V5     V6      V7
    <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>   <dbl>
 1 0.598  0.913 0.363  0.756  0.542  0.309  0.286  
 2 0.331  0.139 0.641  0.465  0.0363 0.803  0.751  
 3 0.696  0.988 0.437  0.585  0.311  0.418  0.862  
 4 0.292  0.135 0.219  0.313  0.661  0.223  0.211  
 5 0.476  0.955 0.772  0.579  0.947  0.160  0.744  
 6 0.825  0.140 0.278  0.0451 0.140  0.433  0.289  
 7 0.424  0.789 0.206  0.812  0.0427 0.253  0.998  
 8 0.443  0.736 0.943  0.953  0.782  0.615  0.782  
 9 0.424  0.327 0.536  0.809  0.0105 0.208  0.00942
10 0.673  0.408 0.166  0.227  0.659  0.517  0.532  
11 0.348  0.328 0.845  0.138  0.494  0.918  0.0809 
12 0.513  0.319 0.160  0.114  0.192  0.203  0.300  
13 0.483  0.135 0.602  0.271  0.169  0.0260 0.0523 
14 0.0978 0.161 0.0119 0.763  0.585  0.654  0.900  
15 0.777  0.226 0.612  0.909  0.907  0.378  0.882  
16 0.154  0.838 0.865  0.442  0.883  0.416  0.555  
17 0.644  0.460 0.547  0.200  0.875  0.653  0.960  
18 0.105  0.905 0.137  0.0792 0.379  0.707  0.803  
19 0.431  0.724 0.904  0.205  0.506  0.979  0.825  

[[3]][[95]]
# A tibble: 17 × 7
       V1     V2     V3     V4     V5    V6     V7
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.575  0.202  0.190  0.338  0.706  0.106 0.949 
 2 0.331  0.989  0.716  0.994  0.0257 0.716 0.469 
 3 0.982  0.240  0.639  0.375  0.608  0.417 0.235 
 4 0.200  0.0478 0.959  0.437  0.993  0.817 0.0383
 5 0.699  0.306  0.188  0.804  0.866  0.686 0.621 
 6 0.236  0.782  0.912  0.438  0.357  0.604 0.550 
 7 0.793  0.146  0.609  0.442  0.114  0.964 0.839 
 8 0.616  0.414  0.112  0.182  0.564  0.622 0.368 
 9 0.395  0.344  0.615  0.415  0.0389 0.264 0.183 
10 0.769  0.690  0.661  0.0760 0.799  0.946 0.118 
11 0.0983 0.155  0.496  0.0619 0.261  0.173 0.0270
12 0.392  0.865  0.598  0.0446 0.924  0.679 0.956 
13 0.659  0.411  0.0746 0.636  0.820  0.419 0.744 
14 0.779  0.920  0.119  0.259  0.0498 0.230 0.434 
15 0.691  0.930  0.932  0.920  0.796  0.755 0.911 
16 0.811  0.377  0.929  0.660  0.592  0.804 0.214 
17 0.801  0.477  0.285  0.831  0.740  0.976 0.168 

[[3]][[96]]
# A tibble: 23 × 7
       V1     V2     V3    V4     V5    V6    V7
    <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl>
 1 0.988  0.218  0.895  0.961 0.921  0.912 0.393
 2 0.573  0.658  0.866  0.105 0.903  0.912 0.831
 3 0.0629 0.831  0.640  0.417 0.0118 0.257 0.689
 4 0.137  0.968  0.819  0.725 0.323  0.785 0.761
 5 0.0569 0.0632 0.370  0.554 0.342  0.437 0.465
 6 0.128  0.652  0.951  0.537 0.708  0.855 0.978
 7 0.126  0.824  0.522  0.636 0.238  0.527 0.243
 8 0.937  0.515  0.0731 0.544 0.179  0.122 0.115
 9 0.195  0.429  0.129  0.371 0.0804 0.148 0.444
10 0.378  0.718  0.632  0.241 0.748  0.865 0.985
# ℹ 13 more rows

[[3]][[97]]
# A tibble: 81 × 7
        V1    V2     V3    V4     V5      V6     V7
     <dbl> <dbl>  <dbl> <dbl>  <dbl>   <dbl>  <dbl>
 1 0.699   0.985 0.116  0.253 0.989  0.0297  0.968 
 2 0.424   0.471 0.769  0.549 0.191  0.783   0.692 
 3 0.169   0.860 0.519  0.314 0.0990 0.00272 0.514 
 4 0.946   0.438 0.620  0.997 0.876  0.126   0.439 
 5 0.627   0.716 0.950  0.361 0.225  0.562   0.202 
 6 0.00954 0.834 0.723  0.948 0.333  0.0129  0.953 
 7 0.0938  0.511 0.363  0.851 0.0296 0.264   0.374 
 8 0.488   0.403 0.247  0.104 0.452  0.493   0.861 
 9 0.614   0.400 0.276  0.300 0.908  0.684   0.417 
10 0.591   0.193 0.0899 0.562 0.586  0.264   0.0877
# ℹ 71 more rows

[[3]][[98]]
# A tibble: 30 × 7
        V1     V2    V3      V4     V5     V6    V7
     <dbl>  <dbl> <dbl>   <dbl>  <dbl>  <dbl> <dbl>
 1 0.274   0.0235 0.930 0.443   0.866  0.380  0.835
 2 0.657   0.409  0.849 0.276   0.0852 0.331  0.695
 3 0.116   0.459  0.289 0.180   0.937  0.0768 0.612
 4 0.558   0.747  0.801 0.411   0.298  0.723  0.303
 5 0.994   0.0796 0.113 0.00318 0.584  0.876  0.825
 6 0.236   0.689  0.741 0.567   0.382  0.430  0.372
 7 0.483   0.834  0.511 0.824   0.857  0.233  0.556
 8 0.222   0.0184 0.990 0.267   0.384  0.752  0.386
 9 0.323   0.635  0.976 0.629   0.273  0.947  0.330
10 0.00192 0.415  0.234 0.327   0.569  0.388  0.614
# ℹ 20 more rows

[[3]][[99]]
# A tibble: 2 × 7
     V1    V2    V3     V4    V5    V6    V7
  <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>
1 0.446 0.317 0.885 0.615  0.372 0.399 0.191
2 0.200 0.750 0.188 0.0443 0.196 0.848 0.429

[[3]][[100]]
# A tibble: 83 × 7
        V1     V2     V3      V4     V5     V6      V7
     <dbl>  <dbl>  <dbl>   <dbl>  <dbl>  <dbl>   <dbl>
 1 0.0179  0.461  0.581  0.781   0.729  0.0976 0.779  
 2 0.901   0.695  0.513  0.00199 0.496  0.846  0.00396
 3 0.364   0.855  0.508  0.491   0.595  0.914  0.908  
 4 0.346   0.766  0.0829 0.865   0.568  0.998  0.0206 
 5 0.497   0.161  0.623  0.327   0.165  0.943  0.726  
 6 0.766   0.356  0.679  0.614   0.754  0.640  0.216  
 7 0.457   0.161  0.126  0.935   0.250  0.901  0.462  
 8 0.0864  0.161  0.862  0.0156  0.0428 0.0901 0.374  
 9 0.995   0.0342 0.954  0.488   0.115  0.455  0.717  
10 0.00814 0.654  0.732  0.847   0.198  0.530  0.134  
# ℹ 73 more rows


[[4]]
[[4]][[1]]
# A tibble: 91 × 4
       V1    V2     V3     V4
    <dbl> <dbl>  <dbl>  <dbl>
 1 0.531  0.965 0.233  0.818 
 2 0.174  0.988 0.419  0.709 
 3 0.131  0.602 0.913  0.0700
 4 0.689  0.804 0.898  0.563 
 5 0.0962 0.283 0.0734 0.854 
 6 0.755  0.206 0.644  0.990 
 7 0.283  0.896 0.483  0.0853
 8 0.391  0.307 0.802  0.972 
 9 0.832  0.434 0.460  0.129 
10 0.803  0.302 0.942  0.421 
# ℹ 81 more rows

[[4]][[2]]
# A tibble: 44 × 4
       V1     V2    V3    V4
    <dbl>  <dbl> <dbl> <dbl>
 1 0.987  0.756  0.143 0.757
 2 0.303  0.541  0.872 0.729
 3 0.297  0.809  0.503 0.431
 4 0.0650 0.571  0.930 0.334
 5 0.443  0.0295 0.376 0.532
 6 0.0284 0.562  0.222 0.151
 7 0.337  0.766  0.512 0.548
 8 0.956  0.885  0.996 0.256
 9 0.269  0.836  0.856 0.674
10 0.222  0.539  0.601 0.737
# ℹ 34 more rows

[[4]][[3]]
# A tibble: 45 × 4
        V1     V2    V3     V4
     <dbl>  <dbl> <dbl>  <dbl>
 1 0.214   0.430  0.318 0.0906
 2 0.520   0.0900 0.449 0.168 
 3 0.732   0.803  0.922 0.706 
 4 0.654   0.208  0.524 0.0814
 5 0.354   0.613  0.689 0.812 
 6 0.967   0.785  0.311 0.727 
 7 0.880   0.954  0.900 0.713 
 8 0.733   0.0864 0.112 0.460 
 9 0.512   0.886  0.741 0.346 
10 0.00570 0.477  0.182 0.768 
# ℹ 35 more rows

[[4]][[4]]
# A tibble: 30 × 4
       V1     V2    V3     V4
    <dbl>  <dbl> <dbl>  <dbl>
 1 0.0402 0.541  0.267 0.489 
 2 0.950  0.163  0.915 0.242 
 3 0.740  0.500  0.397 0.649 
 4 0.876  0.862  0.196 0.0990
 5 0.217  0.211  0.558 0.793 
 6 0.251  0.218  0.207 0.470 
 7 0.139  0.0948 0.890 0.127 
 8 0.718  0.140  0.464 0.181 
 9 0.947  0.664  0.931 0.351 
10 0.349  0.396  0.999 0.455 
# ℹ 20 more rows

[[4]][[5]]
# A tibble: 81 × 4
       V1       V2     V3      V4
    <dbl>    <dbl>  <dbl>   <dbl>
 1 0.107  0.921    0.479  0.0661 
 2 0.483  0.911    0.396  0.683  
 3 0.531  0.884    0.0145 0.911  
 4 0.510  0.492    0.813  0.519  
 5 0.226  0.000332 0.0397 0.00991
 6 0.331  0.238    0.716  0.516  
 7 0.652  0.0242   0.660  0.442  
 8 0.897  0.724    0.0538 0.601  
 9 0.0502 0.00882  0.987  0.969  
10 0.739  0.966    0.909  0.164  
# ℹ 71 more rows

[[4]][[6]]
# A tibble: 4 × 4
     V1      V2    V3    V4
  <dbl>   <dbl> <dbl> <dbl>
1 0.146 0.385   0.718 0.417
2 0.316 0.288   0.560 0.764
3 0.303 0.609   0.844 0.222
4 0.419 0.00845 0.146 0.193

[[4]][[7]]
# A tibble: 44 × 4
       V1     V2     V3     V4
    <dbl>  <dbl>  <dbl>  <dbl>
 1 0.647  0.0960 0.251  0.149 
 2 0.874  0.0979 0.806  0.844 
 3 0.111  0.425  0.169  0.851 
 4 0.920  0.748  0.0680 0.734 
 5 0.332  0.376  0.548  0.716 
 6 0.295  0.829  0.0725 0.0122
 7 0.444  0.359  0.862  0.873 
 8 0.748  0.223  0.907  0.903 
 9 0.0890 0.947  0.689  0.173 
10 0.429  0.241  0.0386 0.536 
# ℹ 34 more rows

[[4]][[8]]
# A tibble: 75 × 4
      V1    V2     V3    V4
   <dbl> <dbl>  <dbl> <dbl>
 1 0.179 0.297 0.837  0.478
 2 0.660 0.210 0.792  0.760
 3 0.771 0.580 0.184  0.492
 4 0.758 0.429 0.255  0.904
 5 0.275 0.892 0.556  0.482
 6 0.759 0.119 0.311  0.301
 7 0.715 0.880 0.0795 0.573
 8 0.762 0.378 0.640  0.281
 9 0.784 0.194 0.306  0.816
10 0.998 0.167 0.646  0.468
# ℹ 65 more rows

[[4]][[9]]
# A tibble: 83 × 4
      V1    V2     V3     V4
   <dbl> <dbl>  <dbl>  <dbl>
 1 0.689 0.107 0.499  0.658 
 2 0.672 0.756 0.0761 0.227 
 3 0.184 0.950 0.575  0.0138
 4 0.597 0.517 0.278  0.493 
 5 0.456 0.172 0.352  0.910 
 6 0.482 0.371 0.195  0.282 
 7 0.559 0.580 0.246  0.534 
 8 0.753 0.919 0.938  0.510 
 9 0.968 0.653 0.574  0.264 
10 0.581 0.560 0.160  0.245 
# ℹ 73 more rows

[[4]][[10]]
# A tibble: 37 × 4
       V1     V2    V3     V4
    <dbl>  <dbl> <dbl>  <dbl>
 1 0.698  0.0649 0.763 0.444 
 2 0.909  0.861  0.749 0.906 
 3 0.447  0.133  0.251 0.0750
 4 0.688  0.778  0.856 0.881 
 5 0.715  0.313  0.741 0.544 
 6 0.0352 0.964  0.987 0.257 
 7 0.460  0.572  0.717 0.310 
 8 0.549  0.223  0.429 0.956 
 9 0.695  0.493  0.972 0.614 
10 0.0605 0.376  0.796 0.364 
# ℹ 27 more rows

[[4]][[11]]
# A tibble: 46 × 4
      V1     V2     V3     V4
   <dbl>  <dbl>  <dbl>  <dbl>
 1 0.108 0.724  0.215  0.917 
 2 0.660 0.0208 0.656  0.346 
 3 0.600 0.560  0.0400 0.0228
 4 0.253 0.0344 0.819  0.0539
 5 0.871 0.709  0.704  0.978 
 6 0.747 0.112  0.199  0.816 
 7 0.502 0.122  0.110  0.116 
 8 0.139 0.328  0.864  0.884 
 9 0.171 0.220  0.389  0.691 
10 0.469 0.115  0.794  0.616 
# ℹ 36 more rows

[[4]][[12]]
# A tibble: 60 × 4
       V1    V2     V3     V4
    <dbl> <dbl>  <dbl>  <dbl>
 1 0.810  0.142 0.0423 0.734 
 2 0.673  0.917 0.628  0.230 
 3 0.554  0.927 0.961  0.211 
 4 0.535  0.614 0.189  0.293 
 5 0.921  0.372 0.281  0.268 
 6 0.602  0.996 0.133  0.627 
 7 0.153  0.996 0.145  0.0810
 8 0.0225 0.889 0.190  0.527 
 9 0.507  0.772 0.271  0.937 
10 0.900  0.460 0.943  0.621 
# ℹ 50 more rows

[[4]][[13]]
# A tibble: 74 × 4
      V1     V2    V3    V4
   <dbl>  <dbl> <dbl> <dbl>
 1 0.558 0.283  0.922 0.799
 2 0.254 0.0369 0.755 0.430
 3 0.497 0.268  0.191 0.484
 4 0.531 0.372  0.878 0.278
 5 0.905 0.839  0.954 0.843
 6 0.379 0.369  0.195 0.683
 7 0.690 0.195  0.461 0.660
 8 0.510 0.439  0.603 0.391
 9 0.938 0.406  0.750 0.139
10 0.691 0.791  0.647 0.935
# ℹ 64 more rows

[[4]][[14]]
# A tibble: 75 × 4
       V1    V2     V3      V4
    <dbl> <dbl>  <dbl>   <dbl>
 1 0.989  0.647 0.0285 0.235  
 2 0.857  0.897 0.834  0.881  
 3 0.884  0.362 0.370  0.959  
 4 0.508  0.746 0.0318 0.675  
 5 0.832  0.133 0.317  0.966  
 6 0.519  0.774 0.146  0.375  
 7 0.405  0.164 0.503  0.942  
 8 0.320  0.507 0.279  0.621  
 9 0.0243 0.526 0.279  0.00634
10 0.121  0.493 0.941  0.796  
# ℹ 65 more rows

[[4]][[15]]
# A tibble: 12 × 4
      V1     V2     V3      V4
   <dbl>  <dbl>  <dbl>   <dbl>
 1 0.698 0.0990 0.997  0.0980 
 2 0.734 0.270  0.375  0.00753
 3 0.538 0.786  0.464  0.00418
 4 0.463 0.233  0.189  0.877  
 5 0.135 0.955  0.194  0.568  
 6 0.366 0.0798 0.565  0.597  
 7 0.506 0.742  0.846  0.498  
 8 0.511 0.283  0.985  0.498  
 9 0.456 0.249  0.633  0.0616 
10 0.174 0.325  0.678  0.0238 
11 0.142 0.972  0.0728 0.975  
12 0.101 0.831  0.0605 0.134  

[[4]][[16]]
# A tibble: 77 × 4
       V1     V2     V3     V4
    <dbl>  <dbl>  <dbl>  <dbl>
 1 0.469  0.0664 0.228  0.530 
 2 0.190  0.888  0.122  0.812 
 3 0.708  0.855  0.0472 0.276 
 4 0.530  0.667  0.578  0.356 
 5 0.355  0.253  0.292  0.724 
 6 0.409  0.622  0.216  0.777 
 7 0.0361 0.152  0.718  0.325 
 8 0.327  0.103  0.592  0.303 
 9 0.365  0.944  0.261  0.664 
10 0.489  0.828  0.508  0.0428
# ℹ 67 more rows

[[4]][[17]]
# A tibble: 95 × 4
      V1    V2    V3     V4
   <dbl> <dbl> <dbl>  <dbl>
 1 0.395 0.293 0.629 0.893 
 2 0.443 0.906 0.214 0.339 
 3 0.231 0.899 0.311 0.0157
 4 0.819 0.112 0.670 0.143 
 5 0.616 0.602 0.943 0.480 
 6 0.532 0.180 0.779 0.477 
 7 0.415 0.235 0.750 0.646 
 8 0.278 0.738 0.381 0.589 
 9 0.974 0.319 0.210 0.438 
10 0.189 0.368 0.793 0.677 
# ℹ 85 more rows

[[4]][[18]]
# A tibble: 54 × 4
       V1    V2    V3     V4
    <dbl> <dbl> <dbl>  <dbl>
 1 0.0543 0.215 0.311 0.220 
 2 0.0321 0.118 0.882 0.462 
 3 0.166  0.348 0.435 0.467 
 4 0.720  0.715 0.254 0.876 
 5 0.224  0.317 0.183 0.923 
 6 0.449  0.789 0.246 0.756 
 7 0.354  0.533 0.448 0.568 
 8 0.918  0.964 0.892 0.448 
 9 0.0637 0.976 0.626 0.156 
10 0.0595 0.816 0.858 0.0250
# ℹ 44 more rows

[[4]][[19]]
# A tibble: 53 × 4
      V1     V2     V3    V4
   <dbl>  <dbl>  <dbl> <dbl>
 1 0.246 0.699  0.896  0.400
 2 0.811 0.0647 0.672  0.583
 3 0.997 0.773  0.745  0.633
 4 0.368 0.665  0.553  0.214
 5 0.904 0.510  0.0285 0.704
 6 0.335 0.271  0.458  0.615
 7 0.282 0.0499 0.390  0.424
 8 0.152 0.395  0.819  0.329
 9 0.510 0.639  0.999  0.547
10 0.627 0.818  0.635  0.678
# ℹ 43 more rows

[[4]][[20]]
# A tibble: 6 × 4
      V1    V2      V3     V4
   <dbl> <dbl>   <dbl>  <dbl>
1 0.434  0.935 0.251   0.525 
2 0.0478 0.110 0.359   0.472 
3 0.732  0.193 0.203   0.524 
4 0.783  0.836 0.00186 0.848 
5 0.684  0.420 0.175   0.260 
6 0.162  0.526 0.497   0.0863

[[4]][[21]]
# A tibble: 99 × 4
      V1     V2    V3      V4
   <dbl>  <dbl> <dbl>   <dbl>
 1 0.700 0.0379 0.615 0.500  
 2 0.739 0.901  0.334 0.253  
 3 0.175 0.774  0.799 0.510  
 4 0.780 0.967  0.149 0.357  
 5 0.821 0.344  0.821 0.764  
 6 0.581 0.718  0.416 0.0962 
 7 0.184 0.457  0.889 0.00713
 8 0.990 0.217  0.914 0.0612 
 9 0.108 0.481  0.829 0.961  
10 0.961 0.520  0.456 0.713  
# ℹ 89 more rows

[[4]][[22]]
# A tibble: 7 × 4
      V1    V2    V3     V4
   <dbl> <dbl> <dbl>  <dbl>
1 0.391  0.848 0.216 0.195 
2 0.0865 0.888 0.517 0.543 
3 0.612  0.643 0.767 0.627 
4 0.0115 0.766 0.341 0.0928
5 0.869  0.290 0.552 0.769 
6 0.167  0.368 0.268 0.701 
7 0.266  0.664 0.120 0.197 

[[4]][[23]]
# A tibble: 61 × 4
       V1    V2    V3     V4
    <dbl> <dbl> <dbl>  <dbl>
 1 0.612  0.345 0.356 0.902 
 2 0.493  0.876 0.451 0.819 
 3 0.734  0.300 0.163 0.653 
 4 0.905  0.399 0.189 0.375 
 5 0.387  0.840 0.659 0.591 
 6 0.0467 0.451 0.255 0.0141
 7 0.247  0.260 0.236 0.341 
 8 0.0371 0.890 0.399 0.814 
 9 0.967  0.677 0.996 0.367 
10 0.0293 0.702 0.229 0.455 
# ℹ 51 more rows

[[4]][[24]]
# A tibble: 20 × 4
        V1     V2     V3    V4
     <dbl>  <dbl>  <dbl> <dbl>
 1 0.808   0.428  0.801  0.929
 2 0.730   0.360  0.329  0.149
 3 0.415   0.0993 0.936  0.825
 4 0.131   0.476  0.876  0.567
 5 0.860   0.644  0.0820 0.415
 6 0.657   0.644  0.830  0.744
 7 0.530   0.844  0.965  0.803
 8 0.0634  0.569  0.927  0.937
 9 0.786   0.290  0.0273 0.344
10 0.187   0.660  0.356  0.996
11 0.00995 0.864  0.357  0.114
12 0.423   0.701  0.694  0.422
13 0.539   0.471  0.949  0.849
14 0.984   0.795  0.231  0.237
15 0.120   0.981  0.897  0.676
16 0.0692  0.288  0.571  0.103
17 0.398   0.0746 0.575  0.286
18 0.817   0.791  0.779  0.128
19 0.143   0.222  0.409  0.764
20 0.0648  0.732  0.494  0.817

[[4]][[25]]
# A tibble: 70 × 4
      V1      V2     V3    V4
   <dbl>   <dbl>  <dbl> <dbl>
 1 0.371 0.00147 0.280  0.905
 2 0.708 0.803   0.258  0.319
 3 0.110 0.0495  0.0488 0.261
 4 0.834 0.224   0.328  0.660
 5 0.738 0.508   0.233  0.588
 6 0.802 0.719   0.925  0.634
 7 0.633 0.956   0.247  0.733
 8 0.740 0.469   0.386  0.706
 9 0.948 0.591   0.463  0.942
10 0.765 0.207   0.352  0.660
# ℹ 60 more rows

[[4]][[26]]
# A tibble: 86 × 4
       V1     V2     V3    V4
    <dbl>  <dbl>  <dbl> <dbl>
 1 0.288  0.0819 0.260  0.633
 2 0.659  0.817  0.441  0.787
 3 0.514  0.199  0.186  0.900
 4 0.992  0.0334 0.0603 0.477
 5 0.0316 0.881  0.960  0.981
 6 0.641  0.664  0.532  0.415
 7 0.247  0.862  0.178  0.119
 8 0.631  0.701  0.674  0.323
 9 0.635  0.677  0.847  0.856
10 0.258  0.380  0.612  0.717
# ℹ 76 more rows

[[4]][[27]]
# A tibble: 97 × 4
      V1     V2     V3      V4
   <dbl>  <dbl>  <dbl>   <dbl>
 1 0.517 0.419  0.353  0.460  
 2 0.643 0.240  0.123  0.399  
 3 0.403 0.124  0.838  0.00367
 4 0.399 0.0498 0.532  0.145  
 5 0.474 0.305  0.221  0.927  
 6 0.724 0.308  0.0560 0.0517 
 7 0.395 0.826  0.902  0.165  
 8 0.846 0.860  0.998  0.0935 
 9 0.364 0.138  0.728  0.879  
10 0.152 0.703  0.291  0.472  
# ℹ 87 more rows

[[4]][[28]]
# A tibble: 6 × 4
      V1     V2     V3     V4
   <dbl>  <dbl>  <dbl>  <dbl>
1 0.500  0.911  0.300  0.879 
2 0.565  0.955  0.388  0.264 
3 0.0258 0.0442 0.612  0.350 
4 0.496  0.487  0.347  0.0901
5 0.895  0.686  0.0628 0.457 
6 0.430  0.919  0.976  0.734 

[[4]][[29]]
# A tibble: 83 × 4
       V1    V2     V3    V4
    <dbl> <dbl>  <dbl> <dbl>
 1 0.911  0.497 0.435  0.309
 2 0.171  0.111 0.331  0.540
 3 0.0894 0.264 0.420  0.773
 4 0.989  0.523 0.0362 0.683
 5 0.190  0.782 0.696  0.444
 6 0.902  0.801 0.433  0.779
 7 0.806  0.500 0.325  0.107
 8 0.232  0.646 0.261  0.266
 9 0.612  0.986 0.977  0.925
10 0.250  0.121 0.552  0.286
# ℹ 73 more rows

[[4]][[30]]
# A tibble: 54 × 4
       V1       V2     V3    V4
    <dbl>    <dbl>  <dbl> <dbl>
 1 0.930  0.133    0.553  0.294
 2 0.194  0.813    0.946  0.178
 3 0.967  0.312    0.956  0.829
 4 0.333  0.282    0.579  0.230
 5 0.859  0.290    0.529  0.810
 6 0.796  0.461    0.0855 0.765
 7 0.343  0.727    0.662  0.780
 8 0.0703 0.858    0.860  0.761
 9 0.648  0.000533 0.0315 0.647
10 0.714  0.885    0.347  0.201
# ℹ 44 more rows

[[4]][[31]]
# A tibble: 27 × 4
       V1     V2     V3    V4
    <dbl>  <dbl>  <dbl> <dbl>
 1 0.131  0.0311 0.389  0.432
 2 0.121  0.751  0.0434 0.172
 3 0.663  0.432  0.395  0.844
 4 0.185  0.745  0.931  0.634
 5 0.0160 0.527  0.509  0.505
 6 0.335  0.380  0.920  0.111
 7 0.0779 0.392  0.816  0.144
 8 0.711  0.205  0.698  0.605
 9 0.189  0.604  0.0443 0.397
10 0.563  0.432  0.0826 0.535
# ℹ 17 more rows

[[4]][[32]]
# A tibble: 98 × 4
       V1     V2    V3    V4
    <dbl>  <dbl> <dbl> <dbl>
 1 0.382  0.251  0.137 0.287
 2 0.313  0.0105 0.185 0.196
 3 0.493  0.973  0.580 0.314
 4 0.344  0.304  0.779 0.951
 5 0.747  0.191  0.142 0.287
 6 0.615  0.0821 0.208 0.715
 7 0.299  0.562  0.866 0.234
 8 0.261  0.981  0.243 0.448
 9 0.0418 0.0836 0.969 0.759
10 0.410  0.601  0.102 0.917
# ℹ 88 more rows

[[4]][[33]]
# A tibble: 64 × 4
         V1    V2    V3    V4
      <dbl> <dbl> <dbl> <dbl>
 1 0.846    0.860 0.523 0.196
 2 0.328    0.104 0.281 0.876
 3 0.686    0.899 0.724 0.787
 4 0.620    0.713 0.813 0.141
 5 0.745    0.341 0.317 0.679
 6 0.0904   0.205 0.587 0.939
 7 0.409    0.975 0.297 0.934
 8 0.101    0.762 0.667 0.270
 9 0.0685   0.817 0.439 0.737
10 0.000775 0.261 0.676 0.928
# ℹ 54 more rows

[[4]][[34]]
# A tibble: 90 × 4
       V1    V2     V3     V4
    <dbl> <dbl>  <dbl>  <dbl>
 1 0.692  0.631 0.608  0.109 
 2 0.763  0.493 0.388  0.653 
 3 0.351  0.732 0.402  0.871 
 4 0.0319 0.719 0.931  0.607 
 5 0.549  0.840 0.0816 0.393 
 6 0.316  0.160 0.0278 0.222 
 7 0.130  0.325 0.288  0.0140
 8 0.445  0.511 0.0567 0.848 
 9 0.449  0.783 0.245  0.754 
10 0.819  0.379 0.423  0.330 
# ℹ 80 more rows

[[4]][[35]]
# A tibble: 83 × 4
       V1     V2     V3     V4
    <dbl>  <dbl>  <dbl>  <dbl>
 1 0.614  0.574  0.397  0.122 
 2 0.584  0.108  0.118  0.289 
 3 0.776  0.221  0.0206 0.222 
 4 0.588  0.865  0.132  0.227 
 5 0.356  0.0857 0.793  0.428 
 6 0.355  0.821  0.588  0.0742
 7 0.0790 0.741  0.715  0.236 
 8 0.954  0.758  0.0868 0.179 
 9 0.455  0.822  0.890  0.623 
10 0.844  0.408  0.702  0.345 
# ℹ 73 more rows

[[4]][[36]]
# A tibble: 40 × 4
      V1    V2     V3     V4
   <dbl> <dbl>  <dbl>  <dbl>
 1 0.656 0.673 0.146  0.0407
 2 0.552 0.907 0.503  0.889 
 3 0.116 0.870 0.810  0.951 
 4 0.592 0.763 0.149  0.910 
 5 0.895 0.440 0.562  0.567 
 6 0.195 0.649 0.463  0.0179
 7 0.489 0.623 0.414  0.612 
 8 0.978 0.642 0.398  0.648 
 9 0.202 0.313 0.192  0.967 
10 0.359 0.381 0.0446 0.159 
# ℹ 30 more rows

[[4]][[37]]
# A tibble: 27 × 4
      V1     V2    V3     V4
   <dbl>  <dbl> <dbl>  <dbl>
 1 0.734 0.285  0.894 0.993 
 2 0.708 0.0268 0.303 0.356 
 3 0.683 0.394  0.514 0.602 
 4 0.288 0.124  0.894 0.867 
 5 0.546 0.0427 0.314 0.755 
 6 0.813 0.561  0.109 0.832 
 7 0.774 0.672  0.810 0.0570
 8 0.329 0.241  0.280 0.0852
 9 0.341 0.914  0.194 0.782 
10 0.833 0.182  0.108 0.124 
# ℹ 17 more rows

[[4]][[38]]
# A tibble: 70 × 4
       V1     V2    V3     V4
    <dbl>  <dbl> <dbl>  <dbl>
 1 0.909  0.147  0.575 0.0406
 2 0.440  0.0954 0.976 0.781 
 3 0.789  0.743  0.630 0.146 
 4 0.0310 0.723  0.223 0.817 
 5 0.173  0.523  0.140 0.874 
 6 0.438  0.751  0.640 0.729 
 7 0.521  0.0839 0.393 0.650 
 8 0.496  0.421  0.422 0.314 
 9 0.900  0.654  0.772 0.280 
10 0.655  0.911  0.242 0.461 
# ℹ 60 more rows

[[4]][[39]]
# A tibble: 19 × 4
       V1      V2     V3     V4
    <dbl>   <dbl>  <dbl>  <dbl>
 1 0.657  0.725   0.278  0.449 
 2 0.748  0.357   0.588  0.194 
 3 0.468  0.565   0.663  0.583 
 4 0.194  0.207   0.0257 0.303 
 5 0.0172 0.493   0.276  0.951 
 6 0.755  0.205   0.0413 0.921 
 7 0.553  0.119   0.657  0.336 
 8 0.348  0.747   0.834  0.711 
 9 0.831  0.304   0.342  0.417 
10 0.433  0.240   0.832  0.787 
11 0.576  0.568   0.217  0.685 
12 0.198  0.368   0.139  0.103 
13 0.913  0.926   0.662  0.564 
14 0.988  0.169   0.572  0.461 
15 0.525  0.892   0.415  0.274 
16 0.592  0.0919  0.262  0.0596
17 0.0810 0.411   0.740  0.315 
18 0.182  0.00936 0.518  0.330 
19 0.199  0.212   0.934  0.911 

[[4]][[40]]
# A tibble: 52 × 4
        V1    V2     V3     V4
     <dbl> <dbl>  <dbl>  <dbl>
 1 0.535   0.972 0.914  0.373 
 2 0.940   0.504 0.0968 0.879 
 3 0.795   0.144 0.800  0.327 
 4 0.110   0.529 0.971  0.664 
 5 0.620   0.980 0.588  0.952 
 6 0.111   0.177 0.508  0.666 
 7 0.00174 0.424 0.607  0.725 
 8 0.608   0.122 0.874  0.849 
 9 0.609   0.926 0.965  0.717 
10 0.0399  0.141 0.626  0.0993
# ℹ 42 more rows

[[4]][[41]]
# A tibble: 36 × 4
      V1     V2     V3    V4
   <dbl>  <dbl>  <dbl> <dbl>
 1 0.763 0.0220 0.384  0.192
 2 0.272 0.819  0.201  0.103
 3 0.843 0.401  0.972  0.877
 4 0.950 0.450  0.673  0.516
 5 0.181 0.428  0.760  0.923
 6 0.461 0.569  0.845  0.959
 7 0.557 0.790  0.0866 0.831
 8 0.431 0.0214 0.569  0.183
 9 0.670 0.0719 0.342  0.359
10 0.315 0.466  0.947  0.521
# ℹ 26 more rows

[[4]][[42]]
# A tibble: 48 × 4
      V1    V2    V3    V4
   <dbl> <dbl> <dbl> <dbl>
 1 0.467 0.583 0.273 0.907
 2 0.263 0.420 0.662 0.771
 3 0.407 0.616 0.404 0.106
 4 0.774 0.608 0.765 0.971
 5 0.622 0.542 0.362 0.262
 6 0.621 0.744 0.470 0.501
 7 0.360 0.745 0.466 0.841
 8 0.904 0.807 0.630 0.578
 9 0.663 0.152 0.536 0.687
10 0.919 0.703 0.519 0.838
# ℹ 38 more rows

[[4]][[43]]
# A tibble: 40 × 4
       V1    V2      V3    V4
    <dbl> <dbl>   <dbl> <dbl>
 1 0.0783 0.817 0.647   0.484
 2 0.909  0.529 0.270   0.348
 3 0.110  0.836 0.614   0.547
 4 0.911  0.275 0.500   0.632
 5 0.591  0.370 0.485   0.822
 6 0.231  0.527 0.503   0.779
 7 0.692  0.867 0.00288 0.959
 8 0.627  0.241 0.198   0.303
 9 0.439  0.514 0.00637 0.992
10 0.624  0.307 0.613   0.827
# ℹ 30 more rows

[[4]][[44]]
# A tibble: 46 × 4
       V1    V2     V3     V4
    <dbl> <dbl>  <dbl>  <dbl>
 1 0.444  0.162 0.180  0.584 
 2 0.858  0.785 0.136  0.0559
 3 0.484  0.991 0.792  0.931 
 4 0.503  0.472 0.388  0.411 
 5 0.705  0.801 0.311  0.128 
 6 0.993  0.366 0.645  0.374 
 7 0.298  0.664 0.363  0.367 
 8 0.775  0.593 0.543  0.477 
 9 0.533  0.773 0.844  0.640 
10 0.0242 0.135 0.0422 0.957 
# ℹ 36 more rows

[[4]][[45]]
# A tibble: 27 × 4
        V1    V2    V3    V4
     <dbl> <dbl> <dbl> <dbl>
 1 0.509   0.504 0.608 0.588
 2 0.209   0.717 0.949 0.807
 3 0.558   0.660 0.929 0.304
 4 0.0401  0.621 0.824 0.523
 5 0.102   0.515 0.423 0.165
 6 0.00230 0.281 0.171 0.609
 7 0.876   0.485 0.299 0.856
 8 0.0787  0.373 0.252 0.141
 9 0.0843  0.127 0.126 0.821
10 0.901   0.877 0.850 0.500
# ℹ 17 more rows

[[4]][[46]]
# A tibble: 86 × 4
       V1    V2    V3      V4
    <dbl> <dbl> <dbl>   <dbl>
 1 0.0822 0.676 0.914 0.00317
 2 0.512  0.342 0.563 0.709  
 3 0.303  0.465 0.633 0.247  
 4 0.620  0.849 0.690 0.276  
 5 0.162  0.532 0.218 0.294  
 6 0.838  0.646 0.388 0.972  
 7 0.307  0.434 0.708 0.976  
 8 0.851  0.365 0.848 0.758  
 9 0.0829 0.604 0.515 0.880  
10 0.441  0.890 0.294 0.279  
# ℹ 76 more rows

[[4]][[47]]
# A tibble: 91 × 4
        V1     V2     V3     V4
     <dbl>  <dbl>  <dbl>  <dbl>
 1 0.958   0.588  0.641  0.888 
 2 0.252   0.151  0.592  0.222 
 3 0.427   0.335  0.595  0.0600
 4 0.295   0.795  0.0787 0.806 
 5 0.431   0.350  0.688  0.832 
 6 0.00198 0.721  0.582  0.475 
 7 0.128   0.706  0.456  0.172 
 8 0.945   0.105  0.652  0.0659
 9 0.0383  0.0498 0.226  0.190 
10 0.0730  0.140  0.871  0.452 
# ℹ 81 more rows

[[4]][[48]]
# A tibble: 70 × 4
       V1    V2      V3    V4
    <dbl> <dbl>   <dbl> <dbl>
 1 0.107  0.678 0.861   0.890
 2 0.847  0.133 0.739   0.575
 3 0.670  0.351 0.243   0.942
 4 0.483  0.922 0.00504 0.282
 5 0.0974 0.989 0.159   0.495
 6 0.952  0.215 0.622   0.936
 7 0.982  0.625 0.571   0.616
 8 0.588  0.462 0.896   0.586
 9 0.0470 0.703 0.657   0.879
10 0.497  0.205 0.688   0.928
# ℹ 60 more rows

[[4]][[49]]
# A tibble: 45 × 4
       V1    V2     V3    V4
    <dbl> <dbl>  <dbl> <dbl>
 1 0.460  0.514 0.233  0.503
 2 0.501  0.936 0.972  0.214
 3 0.346  0.993 0.722  0.572
 4 0.0973 0.343 0.0588 0.399
 5 0.0418 0.395 0.606  0.823
 6 0.350  0.773 0.649  0.963
 7 1.00   0.217 0.648  0.486
 8 0.584  0.645 0.602  0.843
 9 0.766  0.125 0.271  0.576
10 0.0377 0.490 0.638  0.180
# ℹ 35 more rows

[[4]][[50]]
# A tibble: 78 × 4
      V1      V2     V3     V4
   <dbl>   <dbl>  <dbl>  <dbl>
 1 0.161 0.301   0.767  0.343 
 2 0.523 0.744   0.566  0.410 
 3 0.334 0.00315 0.857  0.919 
 4 0.629 0.708   0.776  0.433 
 5 0.227 0.408   0.632  0.567 
 6 0.401 0.909   0.907  0.254 
 7 0.829 0.338   0.963  0.268 
 8 0.493 0.888   0.0827 0.995 
 9 0.611 0.899   0.175  0.539 
10 0.397 0.945   0.102  0.0372
# ℹ 68 more rows

[[4]][[51]]
# A tibble: 86 × 4
       V1    V2    V3     V4
    <dbl> <dbl> <dbl>  <dbl>
 1 0.459  0.572 0.945 0.252 
 2 0.570  0.871 0.263 0.758 
 3 0.637  0.487 0.652 0.649 
 4 0.923  0.307 0.998 0.698 
 5 0.341  0.624 0.516 0.0104
 6 0.996  0.394 0.422 0.753 
 7 0.689  0.875 0.535 0.363 
 8 0.732  0.959 0.742 0.0839
 9 0.0892 0.207 0.316 0.283 
10 0.714  0.933 0.323 0.228 
# ℹ 76 more rows

[[4]][[52]]
# A tibble: 69 × 4
       V1     V2    V3    V4
    <dbl>  <dbl> <dbl> <dbl>
 1 0.0183 0.0218 0.629 0.638
 2 0.468  0.946  0.817 0.486
 3 0.431  0.321  0.507 0.348
 4 0.969  0.462  0.144 0.797
 5 0.632  0.623  0.231 0.496
 6 0.699  0.603  0.811 0.457
 7 0.925  0.972  0.300 0.226
 8 0.935  0.535  0.905 0.242
 9 0.490  0.0209 0.681 0.933
10 0.297  0.720  0.301 0.710
# ℹ 59 more rows

[[4]][[53]]
# A tibble: 76 × 4
       V1     V2     V3      V4
    <dbl>  <dbl>  <dbl>   <dbl>
 1 0.0572 0.222  0.0915 0.684  
 2 0.262  0.957  0.122  0.598  
 3 0.730  0.751  0.249  0.616  
 4 0.571  0.849  0.302  0.916  
 5 0.535  0.397  0.295  0.620  
 6 0.559  0.397  0.467  0.00619
 7 0.449  0.571  0.306  0.761  
 8 0.827  0.654  0.940  0.351  
 9 0.419  0.935  0.680  0.813  
10 0.0310 0.0848 0.407  0.618  
# ℹ 66 more rows

[[4]][[54]]
# A tibble: 84 × 4
        V1      V2     V3     V4
     <dbl>   <dbl>  <dbl>  <dbl>
 1 0.896   0.239   0.0682 0.965 
 2 0.707   0.456   0.888  0.759 
 3 0.0704  0.319   0.348  0.480 
 4 0.00131 0.454   0.235  0.637 
 5 0.445   0.805   0.385  0.472 
 6 0.549   0.00449 0.157  0.810 
 7 0.838   0.395   0.342  0.151 
 8 0.855   0.302   0.289  0.397 
 9 0.0537  0.411   0.293  0.0749
10 0.442   0.473   0.924  0.834 
# ℹ 74 more rows

[[4]][[55]]
# A tibble: 76 × 4
        V1     V2     V3     V4
     <dbl>  <dbl>  <dbl>  <dbl>
 1 0.888   0.642  0.103  0.258 
 2 0.778   0.224  0.226  0.223 
 3 0.804   0.202  0.994  0.0800
 4 0.451   0.349  0.764  0.0904
 5 0.349   0.779  0.0428 0.748 
 6 0.646   0.0347 0.214  0.434 
 7 0.0423  0.504  0.392  0.551 
 8 0.698   0.203  0.185  0.0232
 9 0.00601 0.688  0.188  0.131 
10 0.00123 0.784  0.220  0.608 
# ℹ 66 more rows

[[4]][[56]]
# A tibble: 61 × 4
       V1     V2     V3    V4
    <dbl>  <dbl>  <dbl> <dbl>
 1 0.893  0.0920 0.0931 0.485
 2 0.147  0.929  0.390  0.683
 3 0.335  0.327  0.442  0.342
 4 0.947  0.263  0.0831 0.509
 5 0.443  0.834  0.932  0.259
 6 0.380  0.923  0.703  0.855
 7 0.0617 0.889  0.865  0.235
 8 0.268  0.0882 0.372  0.128
 9 0.962  0.819  0.179  0.513
10 0.443  0.0582 0.765  0.200
# ℹ 51 more rows

[[4]][[57]]
# A tibble: 3 × 4
     V1     V2    V3     V4
  <dbl>  <dbl> <dbl>  <dbl>
1 0.909 0.158  0.485 0.580 
2 0.576 0.698  0.189 0.805 
3 0.336 0.0732 0.360 0.0174

[[4]][[58]]
# A tibble: 29 × 4
      V1     V2     V3     V4
   <dbl>  <dbl>  <dbl>  <dbl>
 1 0.666 0.0778 0.672  0.726 
 2 0.389 0.282  0.281  0.363 
 3 0.649 0.170  0.0259 0.750 
 4 0.608 0.770  0.104  0.296 
 5 0.268 0.196  0.437  0.0609
 6 0.817 0.210  0.482  0.136 
 7 0.310 0.155  0.228  0.374 
 8 0.465 0.515  0.647  0.355 
 9 0.919 0.500  0.963  0.693 
10 0.110 0.272  0.869  0.987 
# ℹ 19 more rows

[[4]][[59]]
# A tibble: 12 × 4
       V1     V2     V3     V4
    <dbl>  <dbl>  <dbl>  <dbl>
 1 0.423  0.112  0.432  0.961 
 2 0.443  0.185  0.271  0.726 
 3 0.0506 0.381  0.698  0.0836
 4 0.525  0.216  0.906  0.345 
 5 0.842  0.690  0.680  0.180 
 6 0.997  0.0597 0.981  0.846 
 7 0.742  0.957  0.273  0.555 
 8 0.999  0.244  0.180  0.779 
 9 0.473  0.556  0.278  0.674 
10 0.978  0.654  0.829  0.827 
11 0.793  0.962  0.560  0.187 
12 0.293  0.675  0.0401 0.124 

[[4]][[60]]
# A tibble: 26 × 4
      V1      V2     V3    V4
   <dbl>   <dbl>  <dbl> <dbl>
 1 0.671 0.465   0.0408 0.328
 2 0.605 0.297   0.396  0.662
 3 0.502 0.148   0.246  0.361
 4 0.673 0.00951 0.528  0.812
 5 0.734 0.946   0.692  0.900
 6 0.108 0.497   0.136  0.404
 7 0.547 0.497   0.204  0.695
 8 0.556 0.407   0.0337 0.965
 9 0.631 0.912   0.0366 0.435
10 0.825 0.520   0.0145 0.436
# ℹ 16 more rows

[[4]][[61]]
# A tibble: 26 × 4
      V1     V2     V3     V4
   <dbl>  <dbl>  <dbl>  <dbl>
 1 0.544 0.427  0.693  0.642 
 2 0.259 0.701  0.0782 0.956 
 3 0.614 0.0181 0.551  0.776 
 4 0.401 0.498  0.315  0.702 
 5 0.525 0.514  0.127  0.287 
 6 0.209 0.280  0.733  0.0842
 7 0.101 0.423  0.404  0.732 
 8 0.457 0.866  0.779  0.606 
 9 0.514 0.486  0.940  0.0427
10 0.185 0.0642 0.205  0.765 
# ℹ 16 more rows

[[4]][[62]]
# A tibble: 54 × 4
       V1     V2     V3    V4
    <dbl>  <dbl>  <dbl> <dbl>
 1 0.401  0.557  0.170  0.457
 2 0.794  0.249  0.385  0.450
 3 0.472  0.399  0.431  0.326
 4 0.973  0.876  0.227  0.146
 5 0.472  0.847  0.642  0.629
 6 0.822  0.693  0.791  0.754
 7 0.478  0.0540 0.0718 0.169
 8 0.333  0.420  0.397  0.813
 9 0.0620 0.605  0.856  0.373
10 0.997  0.171  0.948  0.830
# ℹ 44 more rows

[[4]][[63]]
# A tibble: 40 × 4
      V1     V2    V3     V4
   <dbl>  <dbl> <dbl>  <dbl>
 1 0.726 0.303  0.637 0.908 
 2 0.703 0.0928 0.593 0.0457
 3 0.945 0.883  0.697 0.611 
 4 0.700 0.277  0.243 0.956 
 5 0.840 0.304  0.896 0.514 
 6 0.394 0.236  0.757 0.952 
 7 0.484 0.598  0.177 0.468 
 8 0.225 0.993  0.777 0.164 
 9 0.435 0.234  0.389 0.847 
10 0.640 0.418  0.379 0.416 
# ℹ 30 more rows

[[4]][[64]]
# A tibble: 12 × 4
       V1    V2     V3      V4
    <dbl> <dbl>  <dbl>   <dbl>
 1 0.918  0.565 0.412  0.187  
 2 0.946  0.594 0.819  0.373  
 3 0.0598 0.161 0.0663 0.440  
 4 0.283  0.212 0.299  0.903  
 5 0.500  0.532 0.122  0.0864 
 6 0.788  0.809 0.599  0.707  
 7 0.317  0.674 0.334  0.240  
 8 0.259  0.181 0.562  0.324  
 9 0.136  0.739 0.307  0.444  
10 0.417  0.166 0.297  0.00379
11 0.115  0.451 0.209  0.707  
12 0.668  0.340 0.451  0.673  

[[4]][[65]]
# A tibble: 100 × 4
       V1     V2    V3     V4
    <dbl>  <dbl> <dbl>  <dbl>
 1 0.827  0.447  0.854 0.976 
 2 0.0881 0.134  0.187 0.596 
 3 0.452  0.817  0.161 0.178 
 4 0.884  0.187  0.855 0.766 
 5 0.873  0.433  0.821 0.375 
 6 0.105  0.324  0.570 0.0956
 7 0.138  0.0177 0.732 0.477 
 8 0.356  0.403  0.527 0.793 
 9 0.329  0.235  0.119 0.969 
10 0.813  0.127  0.314 0.873 
# ℹ 90 more rows

[[4]][[66]]
# A tibble: 10 × 4
       V1     V2     V3    V4
    <dbl>  <dbl>  <dbl> <dbl>
 1 0.701  0.329  0.307  0.187
 2 0.249  0.351  0.888  0.688
 3 0.507  0.675  0.280  0.751
 4 0.643  0.477  0.0987 0.282
 5 0.628  0.0126 0.0325 0.190
 6 0.994  0.0976 0.993  0.256
 7 0.0631 0.521  0.908  0.744
 8 0.119  0.427  0.647  0.169
 9 0.851  0.0980 0.393  0.389
10 0.184  0.620  0.149  0.421

[[4]][[67]]
# A tibble: 57 × 4
       V1     V2     V3     V4
    <dbl>  <dbl>  <dbl>  <dbl>
 1 0.374  0.377  0.637  0.847 
 2 0.564  0.0758 0.266  0.767 
 3 0.603  0.505  0.977  0.750 
 4 0.216  0.679  0.547  0.208 
 5 0.528  0.845  0.0963 0.117 
 6 0.0930 0.788  0.402  0.108 
 7 0.908  0.317  0.640  0.0425
 8 0.565  0.283  0.459  0.945 
 9 0.782  0.243  0.625  0.359 
10 0.368  0.606  0.749  0.358 
# ℹ 47 more rows

[[4]][[68]]
# A tibble: 71 × 4
      V1     V2    V3     V4
   <dbl>  <dbl> <dbl>  <dbl>
 1 0.371 0.855  0.729 0.129 
 2 0.402 0.549  0.603 0.887 
 3 0.518 0.646  0.797 0.103 
 4 0.909 0.605  0.830 0.471 
 5 0.527 0.0593 0.752 0.223 
 6 0.557 0.978  0.959 0.698 
 7 0.692 0.218  0.809 0.122 
 8 0.203 0.352  0.410 0.506 
 9 0.886 0.0624 0.931 0.0935
10 0.702 0.717  0.269 0.0367
# ℹ 61 more rows

[[4]][[69]]
# A tibble: 4 × 4
      V1    V2     V3     V4
   <dbl> <dbl>  <dbl>  <dbl>
1 0.861  0.124 0.476  0.778 
2 0.754  0.999 0.0179 0.982 
3 0.0500 0.600 0.257  0.0498
4 0.997  0.145 0.924  0.592 

[[4]][[70]]
# A tibble: 47 × 4
       V1     V2     V3    V4
    <dbl>  <dbl>  <dbl> <dbl>
 1 0.0518 0.556  0.566  0.412
 2 0.478  0.433  0.899  0.832
 3 0.975  0.0295 0.211  0.381
 4 0.296  0.801  0.370  0.684
 5 0.893  0.0896 0.152  0.789
 6 0.545  0.782  0.556  0.261
 7 0.675  0.354  0.248  0.864
 8 0.0176 0.514  0.0955 0.395
 9 0.941  0.229  0.298  0.180
10 0.206  0.753  0.591  0.865
# ℹ 37 more rows

[[4]][[71]]
# A tibble: 70 × 4
       V1     V2     V3    V4
    <dbl>  <dbl>  <dbl> <dbl>
 1 0.407  0.566  0.963  0.153
 2 0.262  0.333  0.857  0.667
 3 0.212  0.893  0.638  0.583
 4 0.787  0.403  0.111  0.691
 5 0.518  0.624  0.694  0.624
 6 0.445  0.0417 0.813  0.277
 7 0.187  0.238  0.809  0.600
 8 0.0122 0.145  0.808  0.111
 9 0.281  0.224  0.0112 0.890
10 0.255  0.195  0.731  0.770
# ℹ 60 more rows

[[4]][[72]]
# A tibble: 67 × 4
       V1    V2     V3     V4
    <dbl> <dbl>  <dbl>  <dbl>
 1 0.610  0.333 0.301  0.0639
 2 0.804  0.924 0.785  0.0990
 3 0.604  0.182 0.676  0.339 
 4 0.0884 0.958 0.902  0.611 
 5 0.600  0.704 0.511  0.677 
 6 0.314  0.733 0.124  0.564 
 7 0.360  0.443 0.0319 0.100 
 8 0.197  0.522 0.817  0.324 
 9 0.598  0.761 0.140  0.311 
10 0.876  0.743 0.737  0.607 
# ℹ 57 more rows

[[4]][[73]]
# A tibble: 53 × 4
       V1    V2     V3     V4
    <dbl> <dbl>  <dbl>  <dbl>
 1 0.244  0.101 0.614  0.360 
 2 0.0349 0.307 0.662  0.337 
 3 0.937  0.346 0.423  0.451 
 4 0.732  0.648 0.332  0.0236
 5 0.813  0.997 0.0120 0.0201
 6 0.652  0.185 0.475  0.550 
 7 0.399  0.754 0.150  0.355 
 8 0.712  0.738 0.934  0.661 
 9 0.959  0.172 0.312  0.770 
10 0.793  0.340 0.228  0.833 
# ℹ 43 more rows

[[4]][[74]]
# A tibble: 87 × 4
       V1     V2     V3     V4
    <dbl>  <dbl>  <dbl>  <dbl>
 1 0.0122 0.297  0.369  0.550 
 2 0.0618 0.720  0.880  0.384 
 3 0.570  0.0911 0.0671 0.568 
 4 0.677  0.185  0.0397 0.596 
 5 0.0870 0.252  0.751  0.0527
 6 0.814  0.854  0.732  0.699 
 7 0.196  0.340  0.998  0.683 
 8 0.528  0.881  0.711  0.920 
 9 0.236  0.940  0.102  0.471 
10 0.784  0.708  0.220  0.532 
# ℹ 77 more rows

[[4]][[75]]
# A tibble: 86 × 4
      V1     V2     V3    V4
   <dbl>  <dbl>  <dbl> <dbl>
 1 0.691 0.930  0.0464 0.963
 2 0.824 0.167  0.571  0.373
 3 0.366 0.596  0.203  0.230
 4 0.801 0.684  0.603  0.990
 5 0.946 0.772  0.937  0.635
 6 0.702 0.0170 0.847  0.432
 7 0.177 0.625  0.0426 0.680
 8 0.882 0.0476 0.421  0.329
 9 0.498 0.258  0.389  0.586
10 0.552 0.726  0.538  0.649
# ℹ 76 more rows

[[4]][[76]]
# A tibble: 38 × 4
      V1     V2    V3     V4
   <dbl>  <dbl> <dbl>  <dbl>
 1 0.327 0.345  0.595 0.233 
 2 0.656 0.247  0.519 0.396 
 3 0.109 0.586  0.770 0.0610
 4 0.403 0.775  0.735 0.277 
 5 0.192 0.364  0.632 0.463 
 6 0.366 0.272  0.218 0.0957
 7 0.115 0.0732 0.407 0.886 
 8 0.578 0.440  0.362 0.656 
 9 0.826 0.446  0.127 0.186 
10 0.194 0.478  0.599 0.650 
# ℹ 28 more rows

[[4]][[77]]
# A tibble: 15 × 4
      V1     V2     V3     V4
   <dbl>  <dbl>  <dbl>  <dbl>
 1 0.339 0.899  0.0175 0.139 
 2 0.216 0.0855 0.688  0.976 
 3 0.729 0.426  0.128  0.313 
 4 0.471 0.485  0.0729 0.712 
 5 0.755 0.216  0.0141 0.0239
 6 0.249 0.975  0.312  0.114 
 7 0.597 0.384  0.838  0.631 
 8 0.709 0.120  0.646  0.513 
 9 0.863 0.130  0.581  0.544 
10 0.902 0.268  0.489  0.325 
11 0.230 0.0725 0.145  0.956 
12 0.314 0.0715 0.950  0.433 
13 0.492 0.0828 0.136  0.422 
14 0.479 0.0464 0.977  0.710 
15 0.424 0.825  0.202  0.245 

[[4]][[78]]
# A tibble: 16 × 4
       V1    V2     V3     V4
    <dbl> <dbl>  <dbl>  <dbl>
 1 0.0158 0.122 0.647  0.414 
 2 0.715  0.686 0.337  0.657 
 3 0.0850 0.676 0.0412 0.755 
 4 0.667  0.278 0.457  0.598 
 5 0.816  0.897 0.538  0.789 
 6 0.146  0.457 0.574  0.583 
 7 0.668  0.492 0.655  0.568 
 8 0.197  0.882 0.986  0.950 
 9 0.390  0.424 0.401  0.984 
10 0.906  0.316 0.336  0.0993
11 0.301  0.271 0.372  0.285 
12 0.809  0.303 0.165  0.851 
13 0.535  0.558 0.335  0.568 
14 0.489  0.642 0.526  0.214 
15 0.237  0.515 0.854  0.233 
16 0.967  0.432 0.362  0.957 

[[4]][[79]]
# A tibble: 69 × 4
       V1     V2     V3    V4
    <dbl>  <dbl>  <dbl> <dbl>
 1 0.951  0.437  0.440  0.840
 2 0.933  0.221  0.177  0.914
 3 0.601  0.0444 0.393  0.274
 4 0.0608 0.299  0.0305 0.423
 5 0.678  0.461  0.601  0.920
 6 0.0141 0.689  0.0707 0.827
 7 0.858  0.382  0.833  0.211
 8 0.448  0.397  0.882  0.883
 9 0.337  0.901  0.527  0.845
10 0.0266 0.0167 0.706  0.280
# ℹ 59 more rows

[[4]][[80]]
# A tibble: 17 × 4
       V1     V2     V3     V4
    <dbl>  <dbl>  <dbl>  <dbl>
 1 0.882  0.640  0.923  0.157 
 2 0.161  0.0868 0.333  0.925 
 3 0.449  0.608  0.0235 0.513 
 4 0.436  0.389  0.552  0.772 
 5 0.837  0.527  0.273  0.453 
 6 0.387  0.0753 0.306  0.551 
 7 0.363  0.857  0.434  0.163 
 8 0.500  0.424  0.531  0.0747
 9 0.508  0.159  0.281  0.942 
10 0.624  0.154  0.427  0.0927
11 0.936  0.787  0.521  0.394 
12 0.195  0.545  0.908  0.422 
13 0.702  0.248  0.376  0.0217
14 0.405  0.706  0.373  0.673 
15 0.803  0.560  0.353  0.0663
16 0.0567 0.379  0.874  0.677 
17 0.316  0.0863 0.835  0.201 

[[4]][[81]]
# A tibble: 18 × 4
       V1    V2    V3      V4
    <dbl> <dbl> <dbl>   <dbl>
 1 0.378  0.107 0.197 0.602  
 2 0.263  0.312 0.993 0.145  
 3 0.399  0.738 0.952 0.597  
 4 0.737  0.386 0.648 0.625  
 5 0.0546 0.210 0.197 0.506  
 6 0.0488 0.119 0.966 0.133  
 7 0.675  0.271 0.252 0.860  
 8 0.176  0.344 0.362 0.670  
 9 0.960  0.880 0.935 0.360  
10 0.920  0.350 0.432 0.785  
11 0.357  0.301 0.654 0.0239 
12 0.620  0.921 0.949 0.167  
13 0.682  0.500 0.695 0.0273 
14 0.577  0.760 0.442 0.00929
15 0.0843 0.372 0.300 0.651  
16 0.941  0.766 0.220 0.278  
17 0.413  0.379 0.697 0.846  
18 0.919  0.606 0.882 0.267  

[[4]][[82]]
# A tibble: 83 × 4
       V1    V2      V3     V4
    <dbl> <dbl>   <dbl>  <dbl>
 1 0.921  0.608 0.0336  0.704 
 2 0.805  0.344 0.123   0.133 
 3 0.912  0.705 0.208   0.328 
 4 0.414  0.205 0.907   0.550 
 5 0.630  0.386 0.862   0.447 
 6 0.917  0.633 0.348   0.380 
 7 0.0268 0.350 0.00848 0.0306
 8 0.103  0.691 0.512   0.0151
 9 0.470  0.405 0.669   0.995 
10 0.691  0.644 0.621   0.852 
# ℹ 73 more rows

[[4]][[83]]
# A tibble: 19 × 4
       V1     V2     V3     V4
    <dbl>  <dbl>  <dbl>  <dbl>
 1 0.776  0.793  0.304  0.833 
 2 0.0390 0.395  0.238  0.895 
 3 0.222  0.0182 0.967  0.113 
 4 0.400  0.867  0.671  0.0996
 5 0.730  0.489  0.797  0.554 
 6 0.0805 0.405  0.790  0.770 
 7 0.718  0.446  0.686  0.917 
 8 0.440  0.941  0.241  0.258 
 9 0.774  0.582  0.798  0.0244
10 0.132  0.767  0.843  0.910 
11 0.486  0.802  0.314  0.0630
12 0.425  0.443  0.198  0.136 
13 0.395  0.356  0.418  0.841 
14 0.0996 0.226  0.558  0.0946
15 0.228  0.212  0.744  0.457 
16 0.307  0.0199 0.718  0.841 
17 0.790  0.923  0.501  0.527 
18 0.733  0.937  0.0328 0.566 
19 0.853  0.0781 0.193  0.599 

[[4]][[84]]
# A tibble: 56 × 4
        V1     V2     V3     V4
     <dbl>  <dbl>  <dbl>  <dbl>
 1 0.951   0.882  0.0706 0.252 
 2 0.339   0.864  0.661  0.880 
 3 0.937   0.349  0.822  0.542 
 4 0.714   0.0929 0.593  0.519 
 5 0.234   0.396  0.540  0.862 
 6 0.785   0.734  0.748  0.769 
 7 0.521   0.324  0.656  0.119 
 8 0.00241 0.440  0.406  0.495 
 9 0.996   0.169  0.770  0.688 
10 0.480   0.673  0.172  0.0384
# ℹ 46 more rows

[[4]][[85]]
# A tibble: 52 × 4
       V1     V2     V3     V4
    <dbl>  <dbl>  <dbl>  <dbl>
 1 0.300  0.630  0.921  0.638 
 2 0.260  0.627  0.516  0.0921
 3 0.0471 0.0729 0.793  0.325 
 4 0.712  0.0407 0.0769 0.0386
 5 0.325  0.115  0.111  0.645 
 6 0.603  0.520  0.561  0.710 
 7 0.953  0.593  0.294  0.135 
 8 0.480  0.344  0.527  0.427 
 9 0.546  0.596  0.504  0.0762
10 0.232  0.692  0.855  0.760 
# ℹ 42 more rows

[[4]][[86]]
# A tibble: 56 × 4
      V1     V2    V3     V4
   <dbl>  <dbl> <dbl>  <dbl>
 1 0.642 0.280  0.478 0.170 
 2 0.305 0.411  0.747 0.703 
 3 0.152 0.0533 0.126 0.983 
 4 0.740 0.375  0.898 0.915 
 5 0.785 0.0518 0.582 0.407 
 6 0.406 0.750  0.807 0.0391
 7 0.342 0.665  0.800 0.496 
 8 0.985 0.594  0.923 0.797 
 9 0.200 0.819  0.595 0.875 
10 1.00  0.604  0.513 0.390 
# ℹ 46 more rows

[[4]][[87]]
# A tibble: 16 × 4
       V1     V2     V3     V4
    <dbl>  <dbl>  <dbl>  <dbl>
 1 0.838  0.689  0.247  0.478 
 2 0.237  0.142  0.839  0.604 
 3 0.340  0.681  0.495  0.0471
 4 0.0511 0.996  0.604  0.342 
 5 0.575  0.200  0.871  0.646 
 6 0.248  0.772  0.735  0.961 
 7 0.354  0.373  0.880  0.907 
 8 0.536  0.0389 0.274  0.128 
 9 0.150  0.930  0.867  0.311 
10 0.472  0.365  0.127  0.721 
11 0.580  0.708  0.438  0.262 
12 0.710  0.102  0.200  0.948 
13 0.285  0.137  0.232  0.426 
14 0.646  0.302  0.0820 0.355 
15 0.768  0.707  0.575  0.345 
16 0.997  0.531  0.421  0.871 

[[4]][[88]]
# A tibble: 68 × 4
       V1    V2      V3     V4
    <dbl> <dbl>   <dbl>  <dbl>
 1 0.384  0.376 0.940   0.958 
 2 0.986  0.412 0.242   0.724 
 3 0.591  0.825 0.701   0.0350
 4 0.307  0.794 0.769   0.204 
 5 0.166  0.434 0.435   0.383 
 6 0.279  0.379 0.464   0.372 
 7 0.571  0.502 0.00869 0.819 
 8 0.0624 0.838 0.0993  0.426 
 9 0.0898 0.896 0.572   0.320 
10 0.956  0.890 0.747   0.187 
# ℹ 58 more rows

[[4]][[89]]
# A tibble: 31 × 4
       V1    V2    V3    V4
    <dbl> <dbl> <dbl> <dbl>
 1 0.398  0.924 0.218 0.888
 2 0.0640 0.543 0.431 0.525
 3 0.601  0.451 0.470 0.375
 4 0.711  0.851 0.646 0.448
 5 0.0425 0.539 0.595 0.675
 6 0.607  0.552 0.930 0.907
 7 0.357  0.395 0.256 0.112
 8 0.721  0.811 0.683 0.392
 9 0.477  0.891 0.652 0.363
10 0.382  0.660 0.228 0.109
# ℹ 21 more rows

[[4]][[90]]
# A tibble: 30 × 4
       V1    V2       V3     V4
    <dbl> <dbl>    <dbl>  <dbl>
 1 0.476  0.817 0.971    0.594 
 2 0.552  0.513 0.594    0.133 
 3 0.521  0.573 0.323    0.412 
 4 0.615  0.284 0.358    0.747 
 5 0.999  0.221 0.781    0.775 
 6 0.608  0.699 0.000621 0.227 
 7 0.607  0.459 0.178    0.443 
 8 0.321  0.651 0.0296   0.425 
 9 0.0857 0.159 0.472    0.0522
10 0.144  0.758 0.0501   0.959 
# ℹ 20 more rows

[[4]][[91]]
# A tibble: 1 × 4
     V1    V2     V3    V4
  <dbl> <dbl>  <dbl> <dbl>
1 0.996 0.679 0.0752 0.290

[[4]][[92]]
# A tibble: 4 × 4
      V1    V2     V3     V4
   <dbl> <dbl>  <dbl>  <dbl>
1 0.0529 0.199 0.855  0.759 
2 0.455  0.745 0.0989 0.0767
3 0.0791 0.628 0.0201 0.294 
4 0.190  0.315 0.744  0.834 

[[4]][[93]]
# A tibble: 16 × 4
         V1     V2     V3      V4
      <dbl>  <dbl>  <dbl>   <dbl>
 1 0.266    0.449  0.157  0.897  
 2 0.658    0.546  0.148  0.0147 
 3 0.954    0.538  0.0588 0.130  
 4 0.204    0.0335 0.946  0.708  
 5 0.587    0.184  0.0828 0.783  
 6 0.977    0.740  0.281  0.00508
 7 0.000447 0.691  0.774  0.351  
 8 0.0644   0.259  0.998  0.653  
 9 0.869    0.700  0.868  0.771  
10 0.176    0.649  0.938  0.821  
11 0.953    0.114  0.651  0.195  
12 0.0307   0.643  0.401  0.790  
13 0.0783   0.126  0.526  0.493  
14 0.307    0.944  0.846  0.283  
15 0.305    0.0877 0.0744 0.0888 
16 0.236    0.588  0.111  0.0152 

[[4]][[94]]
# A tibble: 6 × 4
      V1    V2     V3    V4
   <dbl> <dbl>  <dbl> <dbl>
1 0.363  0.969 0.775  0.774
2 0.847  0.661 0.0814 0.403
3 0.267  0.938 0.0167 0.412
4 0.267  0.632 0.238  0.363
5 0.191  0.234 0.862  0.164
6 0.0523 0.461 0.202  0.276

[[4]][[95]]
# A tibble: 11 × 4
       V1    V2     V3     V4
    <dbl> <dbl>  <dbl>  <dbl>
 1 0.597  0.969 0.666  0.961 
 2 0.299  0.752 0.282  0.116 
 3 0.893  0.202 0.806  0.689 
 4 0.364  0.337 0.363  0.203 
 5 0.0469 0.687 0.537  0.931 
 6 0.968  0.527 0.865  0.291 
 7 0.953  0.454 0.686  0.824 
 8 0.777  0.568 0.743  0.311 
 9 0.887  0.193 0.0618 0.955 
10 0.519  0.144 0.499  0.258 
11 0.341  0.754 0.444  0.0330

[[4]][[96]]
# A tibble: 10 × 4
       V1     V2    V3     V4
    <dbl>  <dbl> <dbl>  <dbl>
 1 0.917  0.912  0.265 0.150 
 2 0.288  0.807  0.856 0.495 
 3 0.612  0.724  0.890 0.295 
 4 0.907  0.974  0.880 0.632 
 5 0.166  0.855  0.752 0.883 
 6 0.678  0.0510 0.444 0.223 
 7 0.0607 0.438  0.907 0.895 
 8 0.809  0.531  0.630 0.0608
 9 0.357  0.223  0.902 0.311 
10 0.302  0.194  0.418 0.237 

[[4]][[97]]
# A tibble: 91 × 4
      V1    V2    V3     V4
   <dbl> <dbl> <dbl>  <dbl>
 1 0.574 0.102 0.204 0.587 
 2 0.821 0.757 0.190 0.125 
 3 0.854 0.647 0.463 0.0608
 4 0.390 0.452 0.264 0.409 
 5 0.732 0.727 0.848 0.0575
 6 0.576 0.395 0.166 0.472 
 7 0.641 0.403 0.690 0.552 
 8 0.612 0.498 0.180 0.500 
 9 0.837 0.350 0.270 0.149 
10 0.793 0.852 0.876 0.653 
# ℹ 81 more rows

[[4]][[98]]
# A tibble: 73 × 4
       V1    V2    V3    V4
    <dbl> <dbl> <dbl> <dbl>
 1 0.0915 0.139 0.129 0.819
 2 0.635  0.773 0.696 0.716
 3 0.462  0.371 0.710 0.602
 4 0.407  0.705 0.913 0.444
 5 0.812  0.585 0.312 0.102
 6 0.0681 0.727 0.382 0.313
 7 0.910  0.424 0.870 0.137
 8 0.0197 0.272 0.496 0.801
 9 0.390  0.335 0.376 0.464
10 0.628  0.371 0.993 0.289
# ℹ 63 more rows

[[4]][[99]]
# A tibble: 55 × 4
       V1     V2     V3    V4
    <dbl>  <dbl>  <dbl> <dbl>
 1 0.834  0.723  0.118  0.636
 2 0.831  0.506  0.385  0.575
 3 0.210  0.105  0.314  0.408
 4 0.745  0.0552 0.0580 0.865
 5 0.544  0.102  0.360  0.837
 6 0.978  0.119  0.243  0.137
 7 0.165  0.518  0.254  0.384
 8 0.787  0.966  0.521  0.314
 9 0.804  0.121  0.793  0.889
10 0.0676 0.821  0.944  0.942
# ℹ 45 more rows

[[4]][[100]]
# A tibble: 45 × 4
      V1     V2     V3    V4
   <dbl>  <dbl>  <dbl> <dbl>
 1 0.229 0.149  0.349  0.448
 2 0.206 0.809  0.675  0.683
 3 0.944 0.436  0.952  0.958
 4 0.890 0.724  0.743  0.574
 5 0.917 0.0721 0.955  0.377
 6 0.885 0.979  0.433  0.110
 7 0.137 0.224  0.759  0.740
 8 0.529 0.458  0.119  0.481
 9 0.553 0.428  0.0251 0.146
10 0.990 0.755  0.536  0.746
# ℹ 35 more rows


[[5]]
[[5]][[1]]
# A tibble: 18 × 10
       V1     V2     V3     V4     V5     V6    V7     V8    V9   V10
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl>
 1 0.410  0.243  0.865  0.143  0.177  0.661  0.842 0.655  0.669 0.365
 2 0.953  0.935  0.0232 0.734  0.312  0.464  0.333 0.302  0.586 0.467
 3 0.0800 0.273  0.113  0.764  0.981  0.436  0.328 0.123  0.120 0.277
 4 0.653  0.558  0.552  0.672  0.385  0.521  0.265 0.520  0.195 0.578
 5 0.320  0.286  0.723  0.935  0.694  0.351  0.832 0.808  0.320 0.483
 6 0.496  0.804  0.683  0.878  0.611  0.409  0.862 0.647  0.574 0.645
 7 0.520  0.364  0.540  0.892  0.413  0.189  0.781 0.0116 0.681 0.831
 8 0.0861 0.799  0.992  0.278  0.183  0.478  0.188 0.351  0.567 0.645
 9 0.442  0.773  0.654  0.569  0.740  0.508  0.807 0.339  0.354 0.662
10 0.850  0.512  0.0360 0.747  0.874  0.286  0.839 0.0780 0.246 0.883
11 0.998  0.360  0.597  0.0888 0.567  0.841  0.663 0.665  0.744 0.448
12 0.772  0.118  0.105  0.796  0.146  0.525  0.475 0.547  0.911 0.319
13 0.661  0.942  0.595  0.140  0.975  0.901  0.552 0.277  0.310 0.505
14 0.156  0.561  0.965  0.446  0.829  0.859  0.495 0.421  0.249 0.180
15 0.992  0.263  0.0679 0.967  0.901  0.0892 0.747 0.206  0.302 0.736
16 0.320  0.149  0.643  0.313  0.495  0.780  0.185 0.861  0.214 0.355
17 0.432  0.0191 0.945  0.230  0.518  0.396  0.854 0.176  0.406 0.912
18 0.0920 0.744  0.557  0.861  0.0436 0.974  0.532 0.857  0.303 0.716

[[5]][[2]]
# A tibble: 64 × 10
       V1      V2    V3    V4     V5    V6     V7     V8     V9   V10
    <dbl>   <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.0717 0.00606 0.874 0.846 0.127  0.315 0.214  0.617  0.0726 0.163
 2 0.150  0.0256  0.968 0.628 0.551  0.708 0.414  0.918  0.0258 0.632
 3 0.956  0.354   0.117 0.925 0.0670 0.596 0.995  0.553  0.820  0.447
 4 0.841  0.217   0.456 0.148 0.646  0.554 0.250  0.937  0.935  0.456
 5 0.832  0.713   0.336 0.477 0.634  0.358 0.0637 0.0150 0.775  0.475
 6 0.980  0.634   0.721 0.908 0.762  0.595 0.490  0.290  0.773  0.233
 7 0.131  0.820   0.854 0.312 0.811  0.861 0.171  0.790  0.553  0.495
 8 0.370  0.846   0.381 0.110 0.762  0.166 0.849  0.472  0.245  0.502
 9 0.901  0.858   0.957 0.468 0.373  0.218 0.900  0.951  0.0677 0.689
10 0.859  0.669   0.628 0.877 0.0635 0.198 0.541  0.616  0.0823 0.966
# ℹ 54 more rows

[[5]][[3]]
# A tibble: 71 × 10
       V1      V2     V3       V4    V5    V6     V7    V8    V9    V10
    <dbl>   <dbl>  <dbl>    <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.0165 0.715   0.294  0.619    0.911 0.531 0.950  0.450 0.504 0.0809
 2 0.340  0.505   0.559  0.682    0.933 0.163 0.751  0.393 0.231 0.174 
 3 0.968  0.394   0.969  0.249    0.163 0.355 0.440  0.124 0.507 0.822 
 4 0.467  0.00294 0.614  0.972    0.592 0.112 0.390  0.165 0.498 0.119 
 5 0.290  0.481   0.972  0.817    0.189 0.885 0.754  0.659 0.643 0.794 
 6 0.662  0.653   0.0231 0.0739   0.391 0.620 0.834  0.659 0.187 0.534 
 7 0.0726 0.497   0.0522 0.697    0.338 0.278 0.626  0.339 0.793 0.292 
 8 0.112  0.360   0.351  0.000161 0.707 0.989 0.0254 0.875 0.158 0.879 
 9 0.794  0.261   0.557  0.372    0.272 0.283 0.431  0.435 0.747 0.570 
10 0.116  0.128   0.469  0.411    0.138 0.424 0.431  0.501 0.399 0.620 
# ℹ 61 more rows

[[5]][[4]]
# A tibble: 49 × 10
       V1    V2    V3     V4     V5     V6     V7     V8    V9    V10
    <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.762  0.770 0.974 0.120  0.794  0.293  0.795  0.628  0.512 0.0679
 2 0.903  0.984 0.787 0.119  0.503  0.873  0.0734 0.396  0.517 0.193 
 3 0.613  0.610 0.493 0.976  0.900  0.0311 0.982  0.881  0.814 0.859 
 4 0.677  0.458 0.406 0.112  0.0321 0.511  0.778  0.0839 0.219 0.966 
 5 0.378  0.161 0.525 0.309  0.258  0.470  0.324  0.935  0.298 0.374 
 6 0.533  0.952 0.382 0.994  0.460  0.262  0.530  0.941  0.313 0.0356
 7 0.502  0.348 0.648 0.777  0.888  0.192  0.247  0.447  0.488 0.278 
 8 0.255  0.476 0.242 0.219  0.506  0.329  0.238  0.980  0.184 0.492 
 9 0.388  0.924 0.809 0.0547 0.667  0.507  0.890  0.121  0.891 0.175 
10 0.0818 0.905 0.959 0.400  0.984  0.731  0.409  0.399  0.803 0.708 
# ℹ 39 more rows

[[5]][[5]]
# A tibble: 35 × 10
       V1     V2     V3     V4     V5    V6    V7      V8    V9      V10
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>   <dbl> <dbl>    <dbl>
 1 0.160  0.563  0.552  0.677  0.284  0.539 0.139 0.239   0.130 0.276   
 2 0.943  0.710  0.827  0.118  0.211  0.724 0.243 0.0291  0.464 0.916   
 3 0.397  0.0314 0.590  0.0692 0.890  0.739 0.899 0.319   0.303 0.716   
 4 0.753  0.163  0.180  0.148  0.907  0.802 0.820 0.381   0.201 0.000556
 5 0.637  0.829  0.549  0.952  0.544  0.423 0.172 0.329   0.336 0.389   
 6 0.170  0.510  0.0705 0.194  0.328  0.734 0.851 0.288   0.739 0.423   
 7 0.179  0.0325 0.768  0.592  0.0179 0.728 0.503 0.114   0.633 0.568   
 8 0.444  0.788  0.812  0.992  0.474  0.112 0.561 0.418   0.259 0.896   
 9 0.0134 0.815  0.310  0.286  0.857  0.869 0.152 0.00769 0.435 0.694   
10 0.225  0.211  0.501  0.737  0.0105 0.806 0.443 0.650   0.356 0.871   
# ℹ 25 more rows

[[5]][[6]]
# A tibble: 90 × 10
       V1     V2    V3     V4     V5    V6     V7     V8     V9    V10
    <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.0250 0.165  0.373 0.955  0.861  0.577 0.270  0.980  0.466  0.0914
 2 0.512  0.713  0.475 0.0438 0.379  0.215 0.701  0.467  0.374  0.349 
 3 0.418  0.359  0.959 0.937  0.0301 0.890 0.125  0.533  0.578  0.874 
 4 0.940  0.0374 0.238 0.201  0.0314 0.519 0.924  0.358  0.899  0.618 
 5 0.725  0.915  0.148 0.434  0.540  0.803 0.695  0.307  0.351  0.971 
 6 0.323  0.754  0.923 0.279  0.144  0.242 0.207  0.0882 0.976  0.496 
 7 0.395  0.152  0.629 0.0928 0.446  0.139 0.774  0.457  0.848  0.740 
 8 0.907  0.721  0.179 0.603  0.445  0.305 0.391  0.563  0.508  0.810 
 9 0.378  0.260  0.324 0.492  0.658  0.174 0.536  0.169  0.0321 0.640 
10 0.828  0.672  0.817 0.883  0.425  0.255 0.0519 0.118  0.812  0.240 
# ℹ 80 more rows

[[5]][[7]]
# A tibble: 17 × 10
      V1     V2     V3     V4     V5     V6     V7     V8     V9   V10
   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.114 0.655  0.614  0.0344 0.661  0.292  0.886  0.696  0.907  0.537
 2 0.490 0.939  0.365  0.510  0.611  0.426  0.0269 0.581  0.536  0.966
 3 0.619 0.400  0.395  0.489  0.337  0.0873 0.737  0.629  0.546  0.127
 4 0.399 0.314  0.544  0.864  0.111  0.690  0.587  0.0776 0.466  0.107
 5 0.179 0.238  0.504  0.0741 0.671  0.341  0.761  0.175  0.0847 0.879
 6 0.179 0.275  0.152  0.716  0.103  0.260  0.695  0.690  0.0239 0.946
 7 0.717 0.707  0.295  0.636  0.532  0.632  0.634  0.322  0.136  0.121
 8 0.122 0.136  0.902  0.226  0.0457 0.168  0.246  0.327  0.868  0.933
 9 0.593 0.572  0.965  0.256  0.0936 0.285  0.527  0.0755 0.915  0.799
10 0.299 0.734  0.914  0.618  0.806  0.448  0.627  0.402  0.793  0.611
11 0.779 0.396  0.430  0.280  0.472  0.543  0.861  0.130  0.132  0.724
12 0.943 0.808  0.0265 0.444  0.737  0.122  0.964  0.474  0.708  0.748
13 0.901 0.984  0.447  0.472  0.626  0.916  0.0222 0.429  0.768  0.804
14 0.997 0.401  0.630  0.124  0.498  0.0492 0.135  0.228  0.208  0.967
15 0.787 0.0389 0.666  0.965  0.913  0.625  0.532  0.916  0.184  0.244
16 0.466 0.743  0.658  0.0433 0.168  0.902  0.128  0.832  0.434  0.895
17 0.849 0.976  0.126  0.122  0.957  0.0282 0.155  0.0702 0.900  0.675

[[5]][[8]]
# A tibble: 15 × 10
       V1     V2     V3     V4     V5     V6    V7      V8     V9    V10
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>   <dbl>  <dbl>  <dbl>
 1 0.0277 0.231  0.988  0.663  0.583  0.849  0.265 0.386   0.528  0.687 
 2 0.718  0.960  0.490  0.270  0.187  0.227  0.838 0.641   0.647  0.566 
 3 0.854  0.814  0.131  0.300  0.628  0.362  0.756 0.00189 0.606  0.342 
 4 0.172  0.735  0.166  0.0543 0.0129 0.713  0.905 0.946   0.272  0.666 
 5 0.517  0.378  0.796  0.307  0.691  0.145  0.141 0.0200  0.0727 0.235 
 6 0.479  0.928  0.963  0.786  0.615  0.815  0.338 0.550   0.525  0.702 
 7 0.770  0.751  0.0526 0.721  0.215  0.171  0.125 0.427   0.608  0.0148
 8 0.946  0.510  0.826  0.0555 0.0142 0.248  0.853 0.852   0.147  0.611 
 9 0.397  0.827  0.0915 0.800  0.367  0.321  0.793 0.634   0.741  0.723 
10 0.704  0.987  0.782  0.498  0.770  0.817  0.500 0.406   0.408  0.350 
11 0.0357 0.331  0.743  0.735  0.789  0.0439 0.762 0.164   0.609  0.382 
12 0.810  0.837  0.327  0.921  0.224  0.402  0.196 0.0851  0.438  0.112 
13 0.446  0.264  0.234  0.214  0.414  0.703  0.132 0.410   0.633  0.872 
14 0.393  0.232  0.491  0.521  0.210  0.530  0.181 0.882   0.581  0.409 
15 0.0692 0.0206 0.178  0.687  0.446  0.312  0.567 0.162   0.760  0.627 

[[5]][[9]]
# A tibble: 11 × 10
       V1     V2    V3     V4     V5    V6     V7     V8     V9   V10
    <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.0819 0.251  0.355 0.820  0.0377 0.342 0.333  0.666  0.720  0.205
 2 0.519  0.466  0.902 0.0309 0.575  0.123 0.327  0.267  0.508  0.126
 3 0.147  0.797  0.994 0.534  0.177  0.917 0.500  0.238  0.430  0.202
 4 0.0338 0.953  0.154 0.511  0.0282 0.907 0.853  0.132  0.168  0.911
 5 0.940  0.0346 0.277 0.852  0.533  0.636 0.667  0.332  0.675  0.152
 6 0.0896 0.0278 0.425 0.620  0.566  0.983 0.377  0.406  0.148  0.530
 7 0.346  0.992  0.582 0.326  0.651  0.817 0.145  0.186  0.974  0.966
 8 0.894  0.437  0.890 0.564  0.105  0.739 0.749  0.472  0.805  0.518
 9 0.302  0.358  0.688 0.459  0.679  0.494 0.164  0.461  0.171  0.191
10 0.192  0.0969 0.216 0.271  0.482  0.850 0.966  0.894  0.813  0.157
11 0.904  0.541  0.573 0.343  0.397  0.201 0.0291 0.0209 0.0207 0.414

[[5]][[10]]
# A tibble: 42 × 10
        V1     V2     V3    V4     V5      V6     V7     V8    V9   V10
     <dbl>  <dbl>  <dbl> <dbl>  <dbl>   <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.640   0.598  0.0786 0.425 0.686  0.172   0.617  0.913  0.726 0.569
 2 0.0822  0.0471 0.272  0.999 0.705  0.718   0.611  0.981  0.344 0.298
 3 0.688   0.492  0.390  0.721 0.595  0.332   0.320  0.692  0.264 0.263
 4 0.541   0.842  0.771  0.824 0.791  0.390   0.742  0.891  0.524 0.493
 5 0.448   0.551  0.494  0.497 0.0639 0.672   0.100  0.0894 0.323 0.772
 6 0.0240  0.526  0.472  0.941 0.283  0.415   0.0171 0.0244 0.281 0.708
 7 0.609   0.852  0.781  0.136 0.862  0.457   0.905  0.794  0.992 0.415
 8 0.476   0.199  0.371  0.447 0.693  0.00498 0.766  0.320  0.488 0.923
 9 0.00295 0.447  0.107  0.720 0.629  0.0153  0.795  0.465  0.316 0.431
10 0.151   0.416  0.587  0.562 0.715  0.217   0.782  0.230  0.896 0.805
# ℹ 32 more rows

[[5]][[11]]
# A tibble: 19 × 10
       V1        V2      V3     V4    V5     V6     V7      V8     V9    V10
    <dbl>     <dbl>   <dbl>  <dbl> <dbl>  <dbl>  <dbl>   <dbl>  <dbl>  <dbl>
 1 0.0238 0.677     0.103   0.0283 0.558 0.559  0.521  0.826   0.427  0.255 
 2 0.679  0.234     0.822   0.126  0.961 0.359  0.322  0.499   0.219  0.0459
 3 0.262  0.594     0.669   0.916  0.959 0.478  0.206  0.302   0.715  0.0548
 4 0.322  0.787     0.211   0.972  0.627 0.358  0.801  0.389   0.955  0.224 
 5 0.341  0.553     0.0271  0.580  0.977 0.695  0.144  0.678   0.452  0.269 
 6 0.269  0.638     0.347   0.491  0.399 0.285  0.121  0.975   0.578  1.00  
 7 0.810  0.674     0.531   0.514  0.586 0.0767 0.781  0.680   0.509  0.321 
 8 0.727  0.259     0.695   0.236  0.122 0.427  0.684  0.745   0.729  0.650 
 9 0.684  0.756     0.00199 0.591  0.890 0.139  0.882  0.00824 0.130  0.482 
10 0.361  0.625     0.143   0.533  0.786 0.386  0.970  0.494   0.663  0.785 
11 0.953  0.636     0.723   0.101  0.337 0.175  0.0713 0.409   0.0763 0.713 
12 0.580  0.172     0.376   0.571  0.556 0.186  0.285  0.837   0.941  0.491 
13 0.372  0.636     0.263   0.187  0.237 0.403  0.0774 0.285   0.577  0.735 
14 0.0161 0.0000939 0.909   0.584  0.453 0.455  0.960  0.490   0.106  0.265 
15 0.0624 0.692     0.265   0.127  0.757 0.245  0.664  0.690   0.894  0.612 
16 0.736  0.347     0.140   0.588  0.989 0.302  0.425  0.290   0.887  0.169 
17 0.361  0.0460    0.491   0.478  0.173 0.797  0.124  0.766   0.168  0.551 
18 0.963  0.715     0.114   0.301  0.880 0.562  0.204  0.790   0.471  0.881 
19 0.964  0.959     0.543   0.510  0.786 0.879  0.743  0.918   0.772  0.0994

[[5]][[12]]
# A tibble: 30 × 10
       V1     V2    V3     V4     V5     V6    V7     V8     V9    V10
    <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.0976 0.0141 0.477 0.259  0.849  0.738  0.837 0.947  0.0857 0.152 
 2 0.0199 0.158  0.144 0.441  0.499  0.402  0.216 0.611  0.694  0.0216
 3 0.0842 0.0656 0.958 0.463  0.0958 0.325  0.477 0.245  0.921  0.214 
 4 0.955  0.782  0.270 0.383  0.497  0.0892 0.230 0.590  0.222  0.628 
 5 0.683  0.0707 0.279 0.899  0.379  0.169  0.803 0.149  0.430  0.875 
 6 0.0257 0.476  0.653 0.649  0.789  0.519  0.345 0.544  0.995  0.289 
 7 0.636  0.941  0.733 0.0930 0.193  0.0585 0.163 0.0984 0.502  0.177 
 8 0.201  0.667  0.309 0.648  0.610  0.0345 0.437 0.557  0.947  0.808 
 9 0.224  0.522  0.586 0.703  0.919  0.599  0.619 0.0443 0.678  0.488 
10 0.785  0.407  0.941 0.734  0.580  0.124  0.589 0.987  0.668  0.864 
# ℹ 20 more rows

[[5]][[13]]
# A tibble: 94 × 10
       V1      V2     V3    V4    V5      V6    V7     V8     V9   V10
    <dbl>   <dbl>  <dbl> <dbl> <dbl>   <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.594  0.195   0.192  0.636 0.913 0.00227 0.299 0.342  0.240  0.326
 2 0.983  0.455   0.0663 0.764 0.602 0.437   0.378 0.544  0.629  0.896
 3 0.779  0.614   0.110  0.258 0.143 0.740   0.432 0.990  0.387  0.757
 4 0.484  0.517   0.874  0.797 0.632 0.607   0.534 0.0835 0.182  0.226
 5 0.691  0.574   0.383  0.386 0.285 0.549   0.500 0.279  0.919  0.984
 6 0.520  0.728   0.550  0.705 0.337 0.0273  0.493 0.130  0.0236 0.131
 7 0.595  0.948   0.0524 0.936 0.622 0.992   0.849 0.612  0.693  0.121
 8 0.216  0.00961 0.660  0.613 0.383 0.819   0.475 0.900  0.553  0.865
 9 0.0317 0.245   0.567  0.201 0.767 0.460   0.716 0.451  0.470  0.256
10 0.205  0.455   0.619  0.380 0.538 0.239   0.239 0.846  0.377  0.719
# ℹ 84 more rows

[[5]][[14]]
# A tibble: 28 × 10
        V1     V2     V3     V4     V5    V6    V7    V8     V9     V10
     <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>  <dbl>   <dbl>
 1 0.0339  0.0232 0.459  0.0217 0.361  0.136 0.953 0.897 0.0326 0.690  
 2 0.776   0.450  0.352  0.271  0.500  0.466 0.356 0.616 0.431  0.268  
 3 0.575   0.0333 0.176  0.739  0.914  0.570 0.496 0.175 0.0287 0.551  
 4 0.0924  0.498  0.0175 0.737  0.557  0.829 0.780 0.318 0.885  0.339  
 5 0.419   0.655  0.663  0.764  0.810  0.762 0.855 0.859 0.857  0.00894
 6 0.544   0.368  0.180  0.592  0.0874 0.296 0.191 0.325 0.917  0.159  
 7 0.267   0.321  0.236  0.834  0.0779 0.282 0.190 0.399 0.136  0.159  
 8 0.784   0.520  0.524  0.781  0.760  0.101 0.478 0.855 0.291  0.410  
 9 0.00166 0.0358 0.433  0.777  0.102  0.448 0.457 0.241 0.488  0.538  
10 0.884   0.785  0.420  0.210  0.694  0.594 0.925 0.851 0.437  0.268  
# ℹ 18 more rows

[[5]][[15]]
# A tibble: 19 × 10
      V1      V2      V3     V4     V5    V6    V7    V8     V9    V10
   <dbl>   <dbl>   <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>
 1 0.919 0.666   0.135   0.921  0.941  0.645 0.144 0.170 0.936  0.855 
 2 0.542 0.834   0.896   0.384  0.446  0.793 0.988 0.927 0.630  0.295 
 3 0.979 0.189   0.985   0.669  0.398  1.00  0.100 0.689 0.555  0.936 
 4 0.610 0.891   0.178   0.373  0.363  0.885 0.398 0.445 0.320  0.155 
 5 0.711 0.00277 0.478   0.969  0.0509 0.204 0.132 0.581 0.0650 0.231 
 6 0.664 0.810   0.744   0.207  0.958  0.232 0.674 0.439 0.0196 0.194 
 7 0.883 0.561   0.0244  0.417  0.0178 0.738 0.145 0.690 0.626  0.884 
 8 0.930 0.915   0.00875 0.426  0.0383 0.242 0.239 0.202 0.938  0.403 
 9 0.466 0.838   0.837   0.422  0.936  0.318 0.611 0.858 0.963  0.190 
10 0.181 0.515   0.0687  0.539  0.559  0.528 0.646 0.685 0.701  0.245 
11 0.562 0.766   0.240   0.110  0.187  0.599 0.274 0.405 0.152  0.272 
12 0.101 0.386   0.709   0.623  0.409  0.296 0.563 0.772 0.533  0.389 
13 0.409 0.561   0.258   0.920  0.916  0.509 0.359 0.437 0.500  0.964 
14 0.782 0.708   0.564   0.968  0.143  0.460 0.547 0.999 0.666  0.0339
15 0.854 0.308   0.380   0.0980 0.134  0.146 0.221 0.543 0.292  0.0910
16 0.186 0.285   0.363   0.338  0.640  0.182 0.507 0.990 0.626  0.839 
17 0.647 0.0782  0.536   0.364  0.395  0.555 0.551 0.659 0.594  0.574 
18 0.430 0.360   0.242   0.383  0.428  0.543 0.543 0.360 0.671  0.417 
19 0.846 0.577   0.743   0.0309 0.207  0.534 0.924 0.615 0.598  0.289 

[[5]][[16]]
# A tibble: 56 × 10
       V1     V2    V3    V4    V5    V6      V7     V8     V9   V10
    <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl>  <dbl>  <dbl> <dbl>
 1 0.822  0.836  0.568 0.680 0.133 0.334 0.995   0.0397 0.511  0.557
 2 0.0355 0.358  0.284 0.350 0.643 0.261 0.00826 0.481  0.919  0.870
 3 0.149  0.0425 0.862 0.692 0.875 0.544 0.252   0.548  0.708  0.902
 4 0.358  0.792  0.249 0.361 0.118 0.185 0.657   0.844  0.0251 0.197
 5 0.103  0.750  0.987 0.398 0.682 0.280 0.136   0.201  0.487  0.167
 6 0.0560 0.139  0.364 0.766 0.959 0.387 0.772   0.666  0.0889 0.569
 7 0.413  0.109  0.225 0.642 0.187 0.482 0.448   0.441  0.698  0.521
 8 0.249  0.842  0.534 0.394 0.864 0.150 0.604   0.505  0.510  0.511
 9 0.798  0.296  0.264 0.395 0.567 0.779 0.853   0.185  0.353  0.661
10 0.302  0.843  0.975 0.987 0.289 0.132 0.903   0.992  0.726  0.604
# ℹ 46 more rows

[[5]][[17]]
# A tibble: 83 × 10
      V1    V2     V3    V4     V5    V6     V7     V8    V9   V10
   <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.389 0.293 0.755  0.951 0.0557 0.583 0.566  0.785  0.223 0.365
 2 0.920 0.756 0.438  0.301 0.386  0.224 0.0369 0.811  0.280 0.304
 3 0.371 0.483 0.0221 0.976 0.829  0.149 0.738  0.283  0.985 0.716
 4 0.987 0.495 0.286  0.432 0.490  0.838 0.671  0.840  0.603 0.292
 5 0.362 0.990 0.466  0.464 0.0156 0.516 0.140  0.0784 0.925 0.639
 6 0.729 0.558 0.292  0.250 0.597  0.682 0.904  0.510  0.233 0.145
 7 0.788 0.831 0.824  0.710 0.236  0.881 0.0758 0.288  0.183 0.120
 8 0.277 0.720 0.943  0.119 0.413  0.409 0.734  0.744  0.113 0.634
 9 0.393 0.868 0.935  0.751 0.196  0.313 0.952  0.714  0.391 0.764
10 0.222 0.888 0.844  0.159 0.871  0.354 0.415  0.190  0.241 0.514
# ℹ 73 more rows

[[5]][[18]]
# A tibble: 63 × 10
       V1     V2     V3    V4     V5     V6      V7       V8     V9   V10
    <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>   <dbl>    <dbl>  <dbl> <dbl>
 1 0.882  0.945  0.0369 0.630 0.0710 0.628  0.963   0.215    0.347  0.714
 2 0.712  0.865  0.909  0.153 0.177  0.754  0.508   0.643    0.742  0.139
 3 0.0584 0.682  0.275  0.512 0.433  0.0615 0.470   0.336    0.570  0.611
 4 0.812  0.655  0.725  0.826 0.415  0.139  0.612   0.0447   0.946  0.282
 5 0.619  0.869  0.832  0.473 0.334  0.248  0.611   0.607    0.578  0.476
 6 0.194  0.378  0.0236 0.164 0.680  0.687  0.0174  0.0863   0.989  0.402
 7 0.823  0.705  0.488  0.342 0.665  0.796  0.834   0.333    0.0568 0.594
 8 0.567  0.0984 0.0614 0.389 0.461  0.333  0.555   0.000937 0.956  0.597
 9 0.148  0.631  0.120  0.714 0.302  0.469  0.222   0.803    0.167  0.921
10 0.147  0.989  0.702  0.241 0.866  0.599  0.00307 0.815    0.902  0.500
# ℹ 53 more rows

[[5]][[19]]
# A tibble: 48 × 10
       V1    V2     V3     V4     V5     V6     V7     V8     V9    V10
    <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.461  0.932 0.712  0.169  0.751  0.445  0.511  0.818  0.190  0.0779
 2 0.913  0.980 0.894  0.0142 0.404  0.453  0.532  0.557  0.798  0.973 
 3 0.693  0.563 0.623  0.351  0.885  0.696  0.444  0.0580 0.711  0.776 
 4 0.252  0.385 0.0993 0.541  0.751  0.986  0.833  0.574  0.774  0.859 
 5 0.788  0.879 0.273  0.524  0.0420 0.449  0.0263 0.553  0.387  0.764 
 6 0.480  0.344 0.343  0.568  0.894  0.764  0.234  0.489  0.0197 0.768 
 7 0.384  0.350 0.897  0.378  0.781  0.100  0.0243 0.789  0.514  0.392 
 8 0.0628 0.620 0.877  0.292  0.752  0.0897 0.0972 0.588  0.319  0.423 
 9 0.690  0.586 0.0640 0.908  0.542  0.184  0.0980 0.482  0.550  0.788 
10 0.690  0.762 0.253  0.799  0.294  0.446  0.126  0.630  0.676  0.516 
# ℹ 38 more rows

[[5]][[20]]
# A tibble: 67 × 10
        V1     V2    V3     V4    V5     V6     V7     V8      V9   V10
     <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>   <dbl> <dbl>
 1 0.244   0.708  0.320 0.350  0.827 0.0585 0.531  0.942  0.521   0.726
 2 0.0216  0.755  0.767 0.0299 0.839 0.354  0.0293 0.261  0.100   0.539
 3 0.489   0.634  0.243 0.504  0.975 0.709  0.148  0.554  0.583   0.595
 4 0.143   0.907  0.722 0.739  0.291 0.306  0.638  0.0571 0.181   0.875
 5 0.521   0.854  0.847 0.199  0.898 0.0619 0.0861 0.474  0.185   0.155
 6 0.611   0.497  0.900 0.562  0.527 0.583  0.846  0.930  0.625   0.679
 7 0.732   0.950  0.513 0.189  0.505 0.444  0.857  0.745  0.133   0.957
 8 0.0432  0.482  0.712 0.742  0.558 0.975  0.540  0.109  0.0883  0.927
 9 0.00394 0.0581 0.945 0.230  0.234 0.306  0.311  0.603  0.00591 0.798
10 0.158   0.387  0.302 0.993  0.496 0.149  0.810  0.264  0.567   0.590
# ℹ 57 more rows

[[5]][[21]]
# A tibble: 30 × 10
       V1     V2    V3     V4     V5     V6    V7      V8    V9    V10
    <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>   <dbl> <dbl>  <dbl>
 1 0.616  0.545  0.109 0.187  0.791  0.915  0.266 0.844   0.967 0.266 
 2 0.820  0.420  0.522 0.854  0.326  0.891  0.623 0.857   0.577 0.0697
 3 0.481  0.761  0.155 0.535  0.896  0.178  0.871 0.770   0.762 0.910 
 4 0.800  0.0321 0.452 0.431  0.644  0.638  0.215 0.983   0.274 0.210 
 5 0.682  0.287  0.114 0.0746 0.495  0.703  0.799 0.0210  0.535 0.854 
 6 0.109  0.934  0.803 0.524  0.0614 0.183  0.547 0.894   0.732 0.128 
 7 0.495  0.904  0.785 0.476  0.853  0.149  0.927 0.286   0.768 0.622 
 8 0.0430 0.741  0.373 0.897  0.438  0.0929 0.830 0.118   0.925 0.212 
 9 0.636  0.201  0.529 0.683  0.498  0.180  0.940 0.465   0.287 0.0220
10 0.721  0.876  0.210 0.436  0.202  0.121  0.513 0.00626 0.486 0.0804
# ℹ 20 more rows

[[5]][[22]]
# A tibble: 62 × 10
      V1     V2     V3    V4     V5     V6     V7     V8      V9    V10
   <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>   <dbl>  <dbl>
 1 0.789 0.174  0.833  0.258 0.454  0.966  0.699  0.685  0.00268 0.786 
 2 0.356 0.0375 0.970  0.192 0.123  0.141  0.968  0.0460 0.337   0.624 
 3 0.625 0.446  0.648  0.382 0.520  0.167  0.331  0.473  0.415   0.219 
 4 0.939 0.981  0.629  0.594 0.493  0.833  0.225  0.471  0.859   0.737 
 5 0.771 0.278  0.557  0.353 0.820  0.0199 0.0856 0.110  0.189   0.494 
 6 0.514 0.130  0.0115 0.238 0.266  0.697  0.443  0.0325 0.0779  0.316 
 7 0.706 0.832  0.361  0.106 0.793  0.139  0.0889 0.638  0.490   0.269 
 8 0.411 0.543  0.787  0.897 0.0166 0.547  0.969  0.659  0.217   0.0692
 9 0.152 0.476  0.871  0.299 0.135  0.709  0.814  0.398  0.271   0.257 
10 0.214 0.771  0.458  0.941 0.396  0.0360 0.348  0.724  0.380   0.124 
# ℹ 52 more rows

[[5]][[23]]
# A tibble: 12 × 10
      V1    V2      V3      V4      V5     V6     V7     V8     V9    V10
   <dbl> <dbl>   <dbl>   <dbl>   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.894 0.517 0.943   0.0813  0.902   0.0664 0.573  0.462  0.480  0.495 
 2 0.404 0.437 0.795   0.690   0.783   0.414  0.746  0.716  0.0565 0.0777
 3 0.808 0.313 0.189   0.502   0.809   0.253  0.865  0.103  0.174  0.457 
 4 0.222 0.810 0.278   0.00875 0.0730  0.389  0.338  0.221  0.0971 0.800 
 5 0.246 0.654 0.0178  0.310   0.484   0.833  0.330  0.788  0.505  0.488 
 6 0.667 0.365 0.477   0.0153  0.714   0.857  0.650  0.548  0.399  0.528 
 7 0.998 0.981 0.638   0.195   0.906   0.0631 0.701  0.418  0.896  0.850 
 8 0.454 0.319 0.101   0.746   0.251   0.648  0.0378 0.729  0.328  0.731 
 9 0.621 0.480 0.00369 0.203   0.888   0.908  0.193  0.860  0.561  0.0196
10 0.938 0.193 0.964   0.363   0.529   0.545  0.641  0.941  0.717  0.450 
11 0.571 0.190 0.914   0.0890  0.433   0.0475 0.691  0.719  0.565  0.638 
12 0.383 0.518 0.00225 0.965   0.00789 0.917  0.371  0.0875 0.445  0.326 

[[5]][[24]]
# A tibble: 67 × 10
       V1      V2     V3     V4     V5      V6    V7     V8     V9   V10
    <dbl>   <dbl>  <dbl>  <dbl>  <dbl>   <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.387  0.0149  0.910  0.832  0.418  0.494   0.712 0.989  0.154  0.890
 2 0.107  0.226   0.0841 0.650  0.387  0.309   0.699 0.616  0.971  0.217
 3 0.208  0.681   0.815  0.607  0.653  0.805   0.574 0.136  0.584  0.544
 4 0.986  0.00937 0.539  0.178  0.541  0.101   0.676 0.157  0.630  0.850
 5 0.785  0.815   0.210  0.0779 0.306  0.905   0.335 0.328  0.466  0.462
 6 0.610  0.00737 0.197  0.312  0.747  0.0311  0.490 0.139  0.437  0.318
 7 0.261  0.164   0.380  0.706  0.633  0.922   0.501 0.679  0.395  0.549
 8 0.0186 0.359   0.761  0.632  0.0344 0.869   0.117 0.797  0.302  0.648
 9 0.593  0.656   0.383  0.995  0.766  0.667   0.908 0.218  0.0370 0.672
10 0.672  0.334   0.789  0.579  0.302  0.00815 0.102 0.0119 0.676  0.230
# ℹ 57 more rows

[[5]][[25]]
# A tibble: 51 × 10
       V1    V2     V3     V4     V5    V6     V7     V8     V9    V10
    <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.249  0.510 0.807  0.0242 0.810  0.548 0.738  0.972  0.860  0.394 
 2 0.711  0.922 0.809  0.606  0.596  0.769 0.864  0.308  0.237  0.411 
 3 0.101  0.462 0.474  0.367  0.384  0.498 0.907  0.173  0.0384 0.718 
 4 0.666  0.486 0.228  0.519  0.572  0.517 0.421  0.419  0.654  0.653 
 5 0.203  0.540 0.0962 0.770  0.0672 0.213 0.616  0.0480 0.394  0.0326
 6 0.735  0.484 0.791  0.733  0.799  0.731 0.895  0.660  0.317  0.722 
 7 0.0383 0.137 0.175  0.836  0.721  0.377 0.504  0.101  0.700  0.987 
 8 0.174  0.795 0.217  0.379  0.750  0.128 0.409  0.251  0.384  0.852 
 9 0.472  0.819 0.532  0.429  0.161  0.747 0.805  0.228  0.735  0.260 
10 0.980  0.492 0.0626 0.174  0.267  0.860 0.0194 0.0321 0.0943 0.266 
# ℹ 41 more rows

[[5]][[26]]
# A tibble: 35 × 10
      V1     V2     V3    V4     V5    V6     V7    V8     V9     V10
   <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>   <dbl>
 1 0.258 0.371  0.0329 0.167 0.735  0.961 0.0452 0.559 0.489  0.860  
 2 0.737 0.112  0.811  0.792 0.552  0.874 0.523  0.618 0.820  0.471  
 3 0.579 0.371  0.260  0.156 0.0509 0.590 0.282  0.852 0.840  0.0160 
 4 0.968 0.678  0.835  0.791 0.138  0.211 0.0457 0.358 0.914  0.110  
 5 0.871 0.176  0.443  0.530 0.935  0.307 0.229  0.787 0.389  0.00754
 6 0.152 0.185  0.436  0.964 0.922  0.944 0.713  0.654 0.756  0.705  
 7 0.565 0.0767 0.505  0.795 0.772  0.834 0.933  0.542 0.290  0.389  
 8 0.456 0.0410 0.245  0.756 0.365  0.536 0.537  0.496 0.0289 0.492  
 9 0.676 0.841  0.0747 0.581 0.437  0.907 0.159  0.339 0.645  0.760  
10 0.404 0.809  0.978  0.225 0.686  0.579 0.0765 0.684 0.416  0.336  
# ℹ 25 more rows

[[5]][[27]]
# A tibble: 84 × 10
       V1     V2      V3     V4      V5     V6     V7     V8    V9   V10
    <dbl>  <dbl>   <dbl>  <dbl>   <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.0382 0.410  0.764   0.0453 0.830   0.427  0.631  0.816  0.660 0.290
 2 0.555  0.0736 0.0408  0.0530 0.245   0.0230 0.366  0.458  0.105 0.931
 3 0.265  0.929  0.211   0.0778 0.363   0.477  0.786  0.620  0.956 0.848
 4 0.626  0.659  0.555   0.639  0.461   0.745  0.328  0.639  0.587 0.989
 5 0.570  0.459  0.538   0.823  0.645   0.573  0.757  0.507  0.205 0.482
 6 0.643  0.653  0.00291 0.950  0.00884 0.634  0.476  0.680  0.945 0.173
 7 0.557  0.178  0.757   0.218  0.607   0.312  0.206  0.0341 0.458 0.144
 8 0.707  0.684  0.221   0.184  0.659   0.274  0.190  0.497  0.339 0.702
 9 0.864  0.373  0.276   0.240  0.846   0.210  0.0650 0.669  0.438 0.378
10 0.647  0.530  0.959   0.593  0.418   0.398  0.735  0.720  0.574 0.223
# ℹ 74 more rows

[[5]][[28]]
# A tibble: 14 × 10
       V1     V2     V3      V4     V5     V6    V7      V8     V9    V10
    <dbl>  <dbl>  <dbl>   <dbl>  <dbl>  <dbl> <dbl>   <dbl>  <dbl>  <dbl>
 1 0.0616 0.973  0.495  0.455   0.789  0.697  0.224 0.0203  0.602  0.396 
 2 0.689  0.424  0.0673 0.0695  0.0993 0.172  0.303 0.474   0.770  0.607 
 3 0.864  0.598  0.863  0.391   0.205  0.335  0.112 0.893   0.470  0.581 
 4 0.537  0.936  0.263  0.0642  0.472  0.795  0.446 0.957   0.0542 0.284 
 5 0.588  0.0848 0.294  0.162   0.0963 0.937  0.846 0.974   0.690  0.0629
 6 0.231  0.859  0.139  0.230   0.840  0.124  0.943 0.931   0.764  0.830 
 7 0.416  0.704  0.228  0.164   0.874  0.131  0.309 0.800   0.314  0.472 
 8 0.115  0.384  0.0974 0.644   0.228  0.105  0.645 0.662   0.0977 0.864 
 9 0.186  0.132  0.411  0.709   0.203  0.303  0.700 0.00699 0.145  0.492 
10 0.601  0.846  0.985  0.581   0.787  0.0298 0.263 0.624   0.836  0.550 
11 0.821  0.909  0.401  0.818   0.801  0.990  0.687 0.780   0.231  0.128 
12 0.361  0.253  0.302  0.755   0.862  0.986  0.460 0.880   0.965  0.0110
13 0.904  0.899  0.921  0.538   0.824  0.353  0.927 0.669   0.280  0.266 
14 0.276  0.723  0.715  0.00166 0.342  0.0176 0.105 0.625   0.552  0.156 

[[5]][[29]]
# A tibble: 81 × 10
      V1      V2      V3     V4     V5    V6    V7    V8    V9   V10
   <dbl>   <dbl>   <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
 1 0.833 0.288   0.604   0.857  0.535  0.647 0.717 0.196 0.198 0.376
 2 0.788 0.533   0.00925 0.177  0.0984 0.500 0.253 0.433 0.419 0.504
 3 0.207 0.342   0.00382 0.617  0.768  0.823 0.781 0.129 0.939 0.707
 4 0.941 0.912   0.593   0.991  0.827  0.661 0.125 0.249 0.733 0.432
 5 0.920 0.353   0.221   0.688  0.730  0.381 0.459 0.933 0.525 0.638
 6 0.117 0.600   0.102   0.917  0.261  0.780 0.253 0.786 0.776 0.635
 7 0.590 0.631   0.389   0.0896 0.276  0.577 0.244 0.146 0.136 0.751
 8 0.383 0.734   0.841   0.560  0.118  0.736 0.709 0.105 0.728 0.184
 9 0.614 0.693   0.361   0.893  0.767  0.106 0.885 0.302 0.955 0.783
10 0.563 0.00503 0.696   0.0759 0.696  0.407 0.754 0.287 0.493 0.863
# ℹ 71 more rows

[[5]][[30]]
# A tibble: 6 × 10
     V1     V2    V3     V4     V5    V6    V7    V8     V9    V10
  <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>
1 0.647 0.771  0.492 0.436  0.0888 0.686 0.316 0.712 0.309  0.427 
2 0.658 0.308  0.347 0.475  0.672  0.807 0.503 0.700 0.270  0.856 
3 0.565 0.545  0.346 0.233  0.424  0.866 0.350 0.542 0.0168 0.471 
4 0.311 0.140  0.818 0.314  0.0360 0.597 0.459 0.666 0.828  0.142 
5 0.853 0.965  0.181 0.0586 0.401  0.304 0.257 0.531 0.442  0.0733
6 0.274 0.0697 0.665 0.139  0.877  0.444 0.748 0.229 0.373  0.498 

[[5]][[31]]
# A tibble: 50 × 10
        V1    V2     V3     V4     V5     V6     V7     V8    V9    V10
     <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.00626 0.487 0.264  0.919  0.376  0.118  0.494  0.915  0.772 0.677 
 2 0.145   0.683 0.0191 0.475  0.905  0.390  0.836  0.117  0.926 0.347 
 3 0.500   0.237 0.349  0.0996 0.419  0.757  0.0148 0.617  0.757 0.267 
 4 0.447   0.205 0.894  0.241  0.424  0.0144 0.0452 0.736  0.873 0.820 
 5 0.334   0.593 0.745  0.0477 0.657  0.917  0.499  0.470  0.918 0.253 
 6 0.829   0.559 0.762  0.385  0.379  0.317  0.598  0.628  0.609 0.0483
 7 0.529   0.619 0.390  0.274  0.0127 0.685  0.871  0.676  0.222 0.103 
 8 0.935   0.369 0.404  0.976  0.768  0.281  0.844  0.695  0.759 0.460 
 9 0.528   0.654 0.342  0.927  0.369  0.204  0.225  0.363  0.777 0.120 
10 0.246   0.148 0.842  0.657  0.630  0.383  0.955  0.0202 0.579 0.501 
# ℹ 40 more rows

[[5]][[32]]
# A tibble: 51 × 10
       V1    V2     V3    V4     V5     V6     V7    V8     V9   V10
    <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.644  0.544 0.580  0.475 0.178  0.468  0.131  0.288 0.957  0.364
 2 0.353  0.682 0.181  0.803 0.712  0.257  0.470  0.389 0.431  0.567
 3 0.306  0.818 0.313  0.833 0.292  0.380  0.939  0.547 0.405  0.493
 4 0.141  0.266 0.424  0.278 0.994  0.154  0.617  0.251 0.762  0.866
 5 0.435  0.807 0.301  0.809 0.592  0.0757 0.816  0.790 0.359  0.882
 6 0.346  0.199 0.553  0.203 0.316  0.438  0.0669 0.284 0.256  0.187
 7 0.833  0.133 0.361  0.582 0.360  0.925  0.610  0.167 0.0420 0.256
 8 0.0349 0.637 0.0358 0.657 0.719  0.161  0.704  0.921 0.662  0.193
 9 0.436  0.799 0.980  0.815 0.672  0.461  0.650  0.419 0.425  0.370
10 0.394  0.493 0.822  0.425 0.0387 0.638  0.708  0.274 0.407  0.416
# ℹ 41 more rows

[[5]][[33]]
# A tibble: 98 × 10
       V1     V2    V3      V4     V5     V6      V7    V8    V9    V10
    <dbl>  <dbl> <dbl>   <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl>  <dbl>
 1 0.690  0.258  0.142 0.369   0.388  0.433  0.00386 0.338 0.641 0.225 
 2 0.474  0.0478 0.415 0.815   0.0831 0.907  0.597   0.247 0.321 0.139 
 3 0.403  0.681  0.906 0.517   0.491  0.534  0.262   0.938 0.922 0.328 
 4 0.404  0.715  0.901 0.156   0.413  0.0347 0.987   0.247 0.326 0.997 
 5 0.663  0.943  0.541 0.00179 0.224  0.656  0.197   0.862 0.344 0.0429
 6 0.0307 0.0861 0.940 0.577   0.331  0.291  0.303   0.698 0.255 0.172 
 7 0.123  0.863  0.940 0.581   0.0425 0.179  0.984   0.443 0.128 0.124 
 8 0.225  0.816  0.768 0.109   0.387  0.470  0.110   0.953 0.762 0.244 
 9 0.0662 0.906  0.207 0.432   0.533  0.741  0.730   0.377 0.345 0.731 
10 0.188  0.0476 0.717 0.496   0.318  0.387  0.980   0.989 0.818 0.561 
# ℹ 88 more rows

[[5]][[34]]
# A tibble: 70 × 10
      V1    V2    V3    V4    V5      V6     V7     V8     V9      V10
   <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl>  <dbl>  <dbl>  <dbl>    <dbl>
 1 0.662 0.100 0.632 0.701 0.472 0.0454  0.137  0.127  0.268  0.0404  
 2 0.953 0.549 0.545 0.575 0.495 0.424   0.116  0.125  0.833  0.730   
 3 0.169 0.573 0.508 0.528 0.303 0.160   0.592  0.857  0.0651 0.927   
 4 0.193 0.804 0.945 0.224 0.407 0.996   0.256  0.149  0.596  0.563   
 5 0.358 0.101 0.483 0.837 0.387 0.769   0.987  0.787  0.375  0.590   
 6 0.697 0.835 0.305 0.146 0.615 0.756   0.643  0.149  0.480  0.809   
 7 0.860 0.677 0.578 0.479 0.940 0.0313  0.377  0.0763 0.695  0.000759
 8 0.883 0.107 0.275 0.988 0.182 0.755   0.883  0.217  0.590  0.0286  
 9 0.493 0.393 0.461 0.255 0.500 0.762   0.488  0.252  0.0284 0.341   
10 0.367 0.723 0.170 0.851 0.548 0.00258 0.0432 0.988  0.101  0.892   
# ℹ 60 more rows

[[5]][[35]]
# A tibble: 16 × 10
       V1      V2     V3     V4      V5      V6     V7     V8     V9    V10
    <dbl>   <dbl>  <dbl>  <dbl>   <dbl>   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.0834 0.0985  0.634  0.221  0.675   0.727   0.0751 0.0309 0.381  0.610 
 2 0.991  0.473   0.914  0.312  0.00233 0.0201  0.589  0.0481 0.829  0.802 
 3 0.987  0.835   0.960  0.519  0.487   0.0410  0.645  0.526  0.0453 0.141 
 4 0.141  0.443   0.163  0.579  0.356   0.172   0.308  0.0891 0.0211 0.216 
 5 0.547  0.268   0.424  0.249  0.555   0.140   0.359  0.424  0.230  0.449 
 6 0.0982 0.201   0.0115 0.209  0.624   0.747   0.169  0.834  0.351  0.697 
 7 0.329  0.669   0.692  0.165  0.563   0.00345 0.296  0.111  0.797  0.767 
 8 0.340  0.474   0.533  0.918  0.970   0.469   0.386  0.164  0.452  0.0759
 9 0.836  0.331   0.357  0.211  0.741   0.953   0.911  0.817  0.869  0.204 
10 0.809  0.933   0.0908 0.651  0.0899  0.994   0.808  0.174  0.489  0.996 
11 0.0730 0.0722  0.306  0.0105 0.709   0.999   0.827  0.935  0.332  0.825 
12 0.547  0.954   0.608  0.697  0.164   0.108   0.447  0.338  0.232  0.479 
13 0.899  0.439   0.996  0.317  0.710   0.860   0.692  0.850  0.666  0.804 
14 0.0255 0.00837 0.751  0.202  0.508   0.364   0.838  0.429  0.704  0.893 
15 0.702  0.480   0.668  0.794  0.656   0.0728  0.166  0.592  0.160  0.434 
16 0.102  0.206   0.301  0.587  0.490   0.515   0.265  0.162  0.438  0.704 

[[5]][[36]]
# A tibble: 94 × 10
      V1    V2     V3    V4    V5     V6     V7     V8     V9    V10
   <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.874 0.130 0.629  0.440 0.758 0.468  0.257  0.500  0.272  0.421 
 2 0.342 0.413 0.0298 0.401 0.535 0.294  0.561  0.234  0.402  0.503 
 3 0.846 0.630 0.436  0.521 0.237 0.173  0.274  0.0406 0.623  0.616 
 4 0.834 0.975 0.820  0.741 0.664 0.953  0.0929 0.173  0.940  0.742 
 5 0.415 0.372 0.555  0.507 0.516 0.404  0.744  0.478  0.437  0.346 
 6 0.538 0.324 0.102  0.710 0.390 0.626  0.764  0.838  0.140  0.186 
 7 0.989 0.460 0.319  0.209 0.740 0.978  0.371  0.626  0.0296 0.840 
 8 0.118 0.907 0.955  0.802 0.367 0.585  0.272  0.873  0.330  0.323 
 9 0.239 0.137 0.141  0.309 0.508 0.0144 0.0240 0.704  0.104  0.302 
10 0.877 0.536 0.308  0.454 0.759 0.151  0.431  0.712  0.404  0.0319
# ℹ 84 more rows

[[5]][[37]]
# A tibble: 88 × 10
       V1      V2    V3     V4     V5    V6     V7     V8     V9   V10
    <dbl>   <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.387  0.288   0.918 0.310  0.981  0.908 0.0522 0.623  0.876  0.430
 2 0.189  0.571   0.769 0.0125 0.539  0.219 0.875  0.378  0.296  0.159
 3 0.706  0.882   0.851 0.401  0.198  0.570 0.845  0.841  0.0506 0.125
 4 0.613  0.724   0.476 0.530  0.644  0.509 0.0808 0.403  0.277  0.446
 5 0.268  0.831   0.796 0.585  0.234  0.981 0.107  0.0233 0.425  0.540
 6 0.360  0.530   0.739 0.588  0.933  0.133 0.708  0.583  0.516  0.150
 7 0.470  0.695   0.907 0.595  0.136  0.346 0.744  0.611  0.180  0.341
 8 0.0469 0.00752 0.960 0.0684 0.860  0.929 0.265  0.607  0.388  0.976
 9 0.336  0.402   0.884 0.487  0.0855 0.408 0.905  0.916  0.421  0.824
10 0.131  0.203   0.386 0.641  0.268  0.635 0.325  0.495  0.389  0.286
# ℹ 78 more rows

[[5]][[38]]
# A tibble: 6 × 10
     V1     V2     V3     V4    V5       V6     V7      V8     V9   V10
  <dbl>  <dbl>  <dbl>  <dbl> <dbl>    <dbl>  <dbl>   <dbl>  <dbl> <dbl>
1 0.967 0.0241 0.400  0.446  0.191 0.000518 0.0109 0.00825 0.386  0.470
2 0.188 0.523  0.300  0.0268 0.381 0.559    0.881  0.0824  0.871  0.386
3 0.516 0.870  0.0585 0.633  0.950 0.0360   0.878  0.846   0.0430 0.460
4 0.317 0.980  0.710  0.591  0.764 0.760    0.549  0.720   0.228  0.667
5 0.599 0.374  0.842  0.0625 0.629 0.596    0.244  0.968   0.178  0.870
6 0.900 0.755  0.961  0.909  0.938 0.627    0.295  0.254   0.674  0.603

[[5]][[39]]
# A tibble: 46 × 10
      V1     V2     V3    V4     V5     V6     V7        V8     V9       V10
   <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>     <dbl>  <dbl>     <dbl>
 1 0.830 0.211  0.447  0.275 0.630  0.0350 0.159  0.483     0.131  0.421    
 2 0.265 0.414  0.125  0.772 0.790  0.974  0.0274 0.567     0.302  0.176    
 3 0.901 0.749  0.810  0.918 0.225  0.868  0.159  0.127     0.709  0.0560   
 4 0.875 0.0484 0.558  0.152 0.583  0.889  0.253  0.395     0.203  0.347    
 5 0.250 0.597  0.939  0.825 0.840  0.508  0.520  0.795     0.141  0.220    
 6 0.790 0.609  0.116  0.760 0.771  0.802  0.901  0.0000162 0.0977 0.234    
 7 0.764 0.993  0.0562 0.758 0.802  0.308  0.884  0.481     0.672  0.698    
 8 0.712 0.438  0.839  0.669 0.0974 0.0922 0.219  0.468     0.243  0.498    
 9 0.711 0.180  0.900  0.498 0.175  0.456  0.888  0.241     0.624  0.0000272
10 0.791 0.111  0.286  0.542 0.210  0.168  0.366  0.560     0.900  0.641    
# ℹ 36 more rows

[[5]][[40]]
# A tibble: 22 × 10
       V1    V2    V3    V4    V5    V6    V7      V8     V9     V10
    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl>  <dbl>   <dbl>
 1 0.601  0.476 0.197 0.355 0.760 0.168 0.147 0.933   0.792  0.0842 
 2 0.714  0.678 0.708 0.848 0.676 0.894 0.405 0.783   0.202  0.747  
 3 0.363  0.306 0.173 0.342 0.255 0.642 0.106 0.0212  0.249  0.445  
 4 0.0557 0.973 0.595 0.214 0.464 0.885 0.617 0.438   0.961  0.141  
 5 0.830  0.351 0.496 0.903 0.951 0.539 0.166 0.146   0.458  0.171  
 6 0.215  0.500 0.764 0.293 0.172 0.318 0.869 0.336   0.0747 0.654  
 7 0.253  0.464 0.779 0.982 0.309 0.686 0.417 0.314   0.851  0.481  
 8 0.802  0.522 0.543 0.851 0.348 0.565 0.569 0.737   0.899  0.925  
 9 0.671  0.349 0.875 0.226 0.748 0.645 0.580 0.886   0.909  0.972  
10 0.673  0.171 0.198 0.757 0.752 0.901 0.594 0.00917 0.999  0.00524
# ℹ 12 more rows

[[5]][[41]]
# A tibble: 9 × 10
     V1    V2    V3    V4     V5     V6     V7    V8     V9    V10
  <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>
1 0.499 0.432 0.398 0.763 0.508  0.488  0.104  0.967 0.779  0.585 
2 0.725 0.117 0.843 0.448 0.522  0.917  0.119  0.870 0.812  0.589 
3 0.887 0.171 0.694 0.379 0.465  0.503  0.895  0.329 0.105  0.529 
4 0.874 0.255 0.464 0.937 0.739  0.754  0.316  0.188 0.711  0.381 
5 0.771 0.222 0.179 0.129 0.483  0.708  0.971  0.767 0.917  0.0857
6 0.994 0.110 0.348 0.505 0.702  0.618  0.390  0.696 0.184  0.252 
7 0.322 0.488 0.711 0.455 0.204  0.409  0.0443 0.356 0.838  0.954 
8 0.940 0.817 0.765 0.324 0.0222 0.312  0.234  0.840 0.0926 0.0498
9 0.367 0.552 0.521 0.442 0.911  0.0463 0.107  0.700 0.428  0.120 

[[5]][[42]]
# A tibble: 51 × 10
       V1    V2    V3      V4    V5     V6     V7     V8     V9    V10
    <dbl> <dbl> <dbl>   <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.206  0.926 0.536 0.310   0.783 0.0174 0.714  0.0319 0.162  0.635 
 2 0.0479 0.534 0.988 0.412   0.530 0.875  0.898  0.880  0.919  0.294 
 3 0.280  0.309 0.490 0.0626  0.749 0.339  0.147  0.333  0.599  0.938 
 4 0.933  0.289 0.419 0.840   0.963 0.488  0.109  0.354  0.646  0.373 
 5 0.175  0.276 0.740 0.683   0.572 0.428  0.397  0.419  0.258  0.130 
 6 0.579  0.859 0.825 0.609   0.232 0.335  0.961  0.705  0.473  0.755 
 7 0.630  0.135 0.333 0.00936 0.743 0.126  0.780  0.748  0.0147 0.404 
 8 0.955  0.174 0.695 0.605   0.995 0.206  0.0324 0.858  0.458  0.0897
 9 0.768  0.139 0.103 0.600   0.215 0.617  0.925  0.521  0.268  0.492 
10 0.875  0.303 0.498 0.434   0.406 0.191  0.770  0.632  0.490  0.0182
# ℹ 41 more rows

[[5]][[43]]
# A tibble: 11 × 10
       V1    V2     V3     V4     V5     V6     V7    V8      V9    V10
    <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>   <dbl>  <dbl>
 1 0.534  0.638 0.883  0.190  0.689  0.794  0.734  0.801 0.725   0.881 
 2 0.679  0.191 0.0673 0.580  0.590  0.346  0.113  0.599 0.942   0.692 
 3 0.0610 0.816 0.327  0.221  0.216  0.838  0.815  0.954 0.00176 0.848 
 4 0.366  0.263 0.776  0.349  0.370  0.104  0.157  0.271 0.153   0.788 
 5 0.403  0.393 0.972  0.132  0.915  0.0989 0.0379 0.212 0.260   0.271 
 6 0.770  0.818 0.841  0.238  0.0574 0.640  0.363  0.130 0.0563  0.198 
 7 0.310  0.891 0.448  0.374  0.972  0.905  0.515  0.731 0.696   0.0765
 8 0.347  0.280 0.379  0.594  0.975  0.0200 0.734  0.634 0.291   0.665 
 9 0.900  0.449 0.807  0.0274 0.0716 0.0712 0.921  0.553 0.464   0.983 
10 0.237  0.230 0.0848 0.159  0.0100 0.673  0.173  0.291 0.859   0.368 
11 0.295  0.676 0.925  0.642  0.935  0.0238 0.931  0.820 0.0532  0.0827

[[5]][[44]]
# A tibble: 33 × 10
       V1     V2     V3     V4    V5    V6     V7     V8     V9    V10
    <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.0127 0.562  0.364  0.248  0.295 0.870 0.306  0.393  0.372  0.684 
 2 0.224  0.939  0.766  0.0912 0.311 0.785 0.841  0.909  0.744  0.796 
 3 0.588  0.246  0.0105 0.315  0.472 0.623 0.383  0.513  0.754  0.0184
 4 0.258  0.822  0.144  0.639  0.754 0.782 0.382  0.740  0.0623 0.635 
 5 0.596  0.902  0.577  0.323  0.268 0.815 0.0533 0.0971 0.946  0.646 
 6 0.947  0.736  0.0483 0.841  0.876 0.724 0.486  0.0793 0.108  0.863 
 7 0.335  0.360  0.758  0.782  0.723 0.829 0.968  0.0585 0.873  0.407 
 8 0.378  0.868  0.783  0.446  0.793 0.269 0.840  0.162  0.382  0.0973
 9 0.597  0.0602 0.432  0.997  0.806 0.857 0.466  0.919  0.925  0.327 
10 0.697  0.345  0.562  0.600  0.164 0.697 0.738  0.256  0.0331 0.155 
# ℹ 23 more rows

[[5]][[45]]
# A tibble: 21 × 10
       V1     V2     V3     V4    V5     V6     V7     V8     V9    V10
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.443  0.826  0.705  0.743  0.894 0.238  0.0197 0.525  0.0660 0.573 
 2 0.685  0.140  0.597  0.636  0.235 0.0796 0.644  0.731  0.124  0.0252
 3 0.871  0.0191 0.349  0.663  0.937 0.995  0.715  0.742  0.825  0.292 
 4 0.114  0.411  0.487  0.537  0.150 0.658  0.836  0.255  0.569  0.249 
 5 0.647  0.509  0.469  0.951  0.307 0.111  0.373  0.0996 0.857  0.603 
 6 0.0458 0.796  0.0199 0.539  0.999 0.166  0.568  0.230  0.762  0.790 
 7 0.517  0.691  0.606  0.203  0.566 0.493  0.105  0.173  0.133  0.506 
 8 0.175  0.162  0.770  0.358  0.436 0.775  0.325  0.125  0.676  0.811 
 9 0.715  0.354  0.436  0.101  0.532 0.441  0.0179 0.998  0.980  0.527 
10 0.540  0.986  0.767  0.0468 0.452 0.569  0.825  0.0955 0.597  0.538 
# ℹ 11 more rows

[[5]][[46]]
# A tibble: 7 × 10
     V1    V2     V3     V4     V5    V6    V7     V8    V9    V10
  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>
1 0.553 0.142 0.0883 0.271  0.405  0.631 0.191 0.723  0.851 0.559 
2 0.656 0.829 0.642  0.0816 0.949  0.292 0.125 0.159  0.685 0.591 
3 0.137 0.975 0.820  0.137  0.967  0.942 0.292 0.799  0.927 0.0722
4 0.759 0.735 0.179  0.450  0.240  0.624 0.967 0.0337 0.959 0.657 
5 0.363 0.354 0.428  0.993  0.0711 0.452 0.173 0.136  0.966 0.649 
6 0.238 0.215 0.939  0.992  0.647  0.866 0.380 0.378  0.833 0.406 
7 0.139 0.537 0.366  0.433  0.172  0.297 0.214 0.653  0.279 0.959 

[[5]][[47]]
# A tibble: 39 × 10
       V1    V2     V3      V4      V5     V6    V7     V8    V9    V10
    <dbl> <dbl>  <dbl>   <dbl>   <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>
 1 0.0194 0.413 0.191  0.950   0.0409  0.727  0.418 0.279  0.756 0.745 
 2 0.917  0.580 0.726  0.850   0.638   0.0699 0.545 0.0875 0.342 0.364 
 3 0.810  0.219 0.399  0.00752 0.644   0.899  0.434 0.841  0.738 0.771 
 4 0.561  0.122 0.441  0.660   0.614   0.122  0.296 0.181  0.354 0.421 
 5 0.280  0.375 0.450  0.626   0.00741 0.237  0.307 0.638  0.706 0.592 
 6 0.219  0.340 0.405  0.194   0.959   0.249  0.444 0.727  0.979 0.501 
 7 0.628  0.196 0.0311 0.714   0.00654 0.100  0.975 0.793  0.637 0.800 
 8 0.877  0.281 0.732  0.567   0.883   0.241  0.277 0.474  0.356 0.0158
 9 0.632  0.916 0.685  0.562   0.492   0.153  0.454 0.174  0.640 0.767 
10 0.566  0.580 0.378  0.176   0.602   0.325  0.307 0.305  0.533 0.692 
# ℹ 29 more rows

[[5]][[48]]
# A tibble: 24 × 10
        V1     V2    V3    V4     V5      V6     V7    V8      V9    V10
     <dbl>  <dbl> <dbl> <dbl>  <dbl>   <dbl>  <dbl> <dbl>   <dbl>  <dbl>
 1 0.645   0.887  0.263 0.755 0.0193 0.363   0.469  0.650 0.484   0.473 
 2 0.516   0.430  0.912 0.679 0.197  0.567   0.475  0.848 0.135   0.0735
 3 0.862   0.791  0.312 0.423 0.623  0.911   0.732  0.842 0.329   0.728 
 4 0.464   0.113  0.946 0.308 0.213  0.712   0.0968 0.254 0.404   0.321 
 5 0.489   0.328  0.780 0.536 0.448  0.471   0.168  0.182 0.215   0.641 
 6 0.497   0.0583 0.562 0.470 0.819  0.567   0.281  0.708 0.00847 0.633 
 7 0.122   0.199  0.525 0.490 0.785  0.750   0.652  0.366 0.485   0.757 
 8 0.00866 0.408  0.166 0.805 0.906  0.411   0.770  0.480 0.915   0.168 
 9 0.216   0.231  0.910 0.663 0.489  0.893   0.599  0.954 0.152   0.940 
10 0.696   0.578  0.636 0.343 0.0837 0.00980 0.384  0.588 0.221   0.796 
# ℹ 14 more rows

[[5]][[49]]
# A tibble: 75 × 10
      V1     V2     V3    V4     V5     V6     V7     V8     V9     V10
   <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>   <dbl>
 1 0.466 0.600  0.718  0.678 0.701  0.540  0.443  0.975  0.795  0.165  
 2 0.340 0.996  0.163  0.537 0.388  0.825  0.0299 0.443  0.476  0.221  
 3 0.582 0.588  0.0264 0.644 0.445  0.0237 0.782  0.982  0.945  0.477  
 4 0.885 0.0160 0.915  0.554 0.541  0.465  0.0421 0.0211 0.688  0.783  
 5 0.132 0.642  0.792  0.965 0.281  0.663  0.700  0.141  0.145  0.00708
 6 0.341 0.418  0.398  0.140 0.451  0.796  0.519  0.229  0.847  0.234  
 7 0.139 0.571  0.845  0.247 0.898  0.427  0.593  0.591  0.363  0.0615 
 8 0.850 0.836  0.424  0.274 0.665  0.0470 0.375  0.478  0.0656 0.184  
 9 0.264 0.534  0.458  0.267 0.572  0.275  0.953  0.623  0.388  0.486  
10 0.469 0.960  0.866  0.545 0.0810 0.563  0.311  0.995  0.856  0.0110 
# ℹ 65 more rows

[[5]][[50]]
# A tibble: 91 × 10
       V1     V2    V3     V4     V5    V6     V7     V8     V9    V10
    <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.938  0.801  0.818 0.0781 0.493  0.868 0.726  0.0552 0.962  0.361 
 2 0.158  0.408  0.145 0.518  0.288  0.292 0.630  0.685  0.599  0.0585
 3 0.819  0.111  0.775 0.329  0.311  0.766 0.185  0.126  0.126  0.0781
 4 0.769  0.553  0.684 0.257  0.894  0.534 0.0616 0.744  0.200  0.983 
 5 0.759  0.313  0.238 0.116  0.719  0.737 0.880  0.820  0.0566 0.517 
 6 0.528  0.0671 0.902 0.412  0.428  0.421 0.519  0.327  0.0562 0.381 
 7 0.0822 0.668  0.564 0.0152 0.561  0.617 0.149  0.794  0.878  0.970 
 8 0.612  0.439  0.358 0.698  0.943  0.500 0.109  0.121  0.564  0.0653
 9 0.557  0.870  0.809 0.315  0.867  0.857 0.178  0.151  0.670  0.789 
10 0.253  0.753  0.320 0.800  0.0660 0.502 0.573  0.605  0.782  0.304 
# ℹ 81 more rows

[[5]][[51]]
# A tibble: 3 × 10
      V1    V2    V3    V4    V5    V6    V7     V8     V9   V10
   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl>
1 0.0509 0.610 0.573 0.558 0.623 0.299 0.567 0.452  0.578  0.147
2 0.245  0.846 0.144 0.567 0.109 0.623 0.532 0.347  0.516  0.750
3 0.437  0.293 0.886 0.588 0.534 0.855 0.479 0.0731 0.0607 0.862

[[5]][[52]]
# A tibble: 29 × 10
      V1    V2     V3     V4    V5     V6    V7     V8    V9   V10
   <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl>
 1 0.710 0.352 0.570  0.0306 0.725 0.169  0.408 0.424  0.738 0.190
 2 0.981 0.988 0.0431 0.571  0.740 0.635  0.304 0.563  0.323 0.367
 3 0.167 0.102 0.392  0.300  0.315 0.776  0.645 0.494  0.301 0.209
 4 0.256 0.113 0.0984 0.162  0.140 0.335  0.443 0.952  0.515 0.361
 5 0.915 0.642 0.342  0.981  0.370 0.0683 0.333 0.532  0.551 0.673
 6 0.632 0.642 0.893  0.853  0.890 0.663  0.315 0.948  0.355 0.411
 7 0.153 0.213 0.265  0.791  0.763 0.348  0.348 0.0827 0.874 0.655
 8 0.922 0.475 0.671  0.845  0.818 0.942  0.415 0.374  0.923 0.428
 9 0.120 0.622 0.849  0.872  0.473 0.675  0.800 0.137  0.151 0.594
10 0.476 0.108 0.133  0.970  0.923 0.477  0.766 0.279  0.647 0.786
# ℹ 19 more rows

[[5]][[53]]
# A tibble: 74 × 10
       V1     V2    V3    V4      V5       V6    V7    V8    V9   V10
    <dbl>  <dbl> <dbl> <dbl>   <dbl>    <dbl> <dbl> <dbl> <dbl> <dbl>
 1 0.700  0.506  0.670 0.573 0.710   0.756    0.713 0.425 0.692 0.831
 2 0.101  0.331  0.997 0.596 0.244   0.715    0.865 0.481 0.588 0.399
 3 0.0532 0.819  0.344 0.163 0.812   0.815    0.423 0.618 0.888 0.304
 4 0.0361 0.533  0.520 0.540 0.0322  0.437    0.464 0.304 0.852 0.615
 5 0.279  0.0316 0.501 0.773 0.863   0.277    0.661 0.577 0.773 0.987
 6 0.896  0.154  0.289 0.651 0.0699  0.357    0.556 0.477 0.150 0.943
 7 0.349  0.830  0.721 0.513 0.929   0.000713 0.545 0.749 0.497 0.761
 8 0.136  0.720  0.483 0.581 0.0618  0.0879   0.815 0.331 0.680 0.381
 9 0.723  0.451  0.785 0.726 0.497   0.0186   0.782 0.612 0.130 0.614
10 0.241  0.749  0.807 0.320 0.00405 0.0223   0.643 0.686 0.443 0.404
# ℹ 64 more rows

[[5]][[54]]
# A tibble: 19 × 10
       V1     V2      V3     V4      V5      V6     V7     V8     V9   V10
    <dbl>  <dbl>   <dbl>  <dbl>   <dbl>   <dbl>  <dbl>  <dbl>  <dbl> <dbl>
 1 0.864  0.299  0.313   0.382  0.424   0.589   0.929  0.741  0.172  0.142
 2 0.132  0.772  0.534   0.795  0.00721 0.138   0.507  0.106  0.0916 0.974
 3 0.214  0.699  0.700   0.101  0.594   0.472   0.607  0.679  0.571  0.605
 4 0.862  0.636  0.0764  0.977  0.867   0.940   0.268  0.474  0.890  0.526
 5 0.191  0.471  0.855   0.173  0.00232 0.338   0.285  0.920  0.834  0.563
 6 0.773  0.421  0.257   0.616  0.863   0.837   0.485  0.110  0.111  0.342
 7 0.702  0.0271 0.535   0.358  0.369   0.968   0.505  0.780  0.999  0.370
 8 0.423  0.130  0.00278 0.0492 0.627   0.740   0.642  0.373  0.133  0.326
 9 0.668  0.776  0.116   0.228  0.113   0.937   0.354  0.881  0.597  0.223
10 0.673  0.579  0.699   0.173  0.398   0.763   0.203  0.685  0.0951 0.174
11 0.395  0.197  0.870   0.422  0.589   0.680   0.858  0.947  0.155  0.911
12 0.848  0.0700 0.787   0.361  0.762   0.731   0.299  0.0134 0.909  0.105
13 0.182  0.395  0.392   0.732  0.287   0.515   0.368  0.306  0.875  0.422
14 0.296  0.508  0.462   0.705  0.0293  0.787   0.551  0.0937 0.777  0.981
15 0.869  0.787  0.215   0.0796 0.755   0.184   0.247  0.402  0.410  0.152
16 0.341  0.489  0.103   0.181  0.531   0.00141 0.648  0.448  0.397  0.264
17 0.375  0.872  0.464   0.327  0.835   0.0447  0.0501 0.224  0.794  0.304
18 0.0561 0.478  0.392   0.0666 0.104   0.515   0.816  0.673  0.401  0.958
19 0.233  0.200  0.824   0.692  0.850   0.873   0.737  0.722  0.238  0.478

[[5]][[55]]
# A tibble: 97 × 10
       V1     V2      V3     V4     V5    V6    V7     V8     V9   V10
    <dbl>  <dbl>   <dbl>  <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.720  0.732  0.222   0.212  0.796  0.747 0.906 0.518  0.202  0.257
 2 0.652  0.471  0.310   0.661  0.520  0.480 0.160 0.952  0.472  0.507
 3 0.569  0.424  0.316   0.699  0.892  0.605 0.340 0.860  0.104  0.576
 4 0.0580 0.116  0.768   0.581  0.851  0.556 0.405 0.709  0.876  0.198
 5 0.522  0.297  0.185   0.863  0.868  0.880 0.518 0.795  0.882  0.116
 6 0.346  0.422  0.0960  0.713  0.523  0.196 0.704 0.0504 0.770  0.724
 7 0.784  0.0255 0.247   0.900  0.443  0.972 0.100 0.623  0.0880 0.384
 8 0.998  0.0720 0.603   0.105  0.172  0.466 0.507 0.591  0.990  0.612
 9 0.0161 0.0931 0.00722 0.744  0.175  0.902 0.634 0.638  0.977  0.591
10 0.718  0.744  0.636   0.0267 0.0434 0.437 0.921 0.837  0.446  0.826
# ℹ 87 more rows

[[5]][[56]]
# A tibble: 20 × 10
        V1     V2     V3     V4       V5       V6     V7     V8     V9    V10
     <dbl>  <dbl>  <dbl>  <dbl>    <dbl>    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.390   0.940  0.900  0.0339 0.204    0.301    0.769  0.776  0.276  0.944 
 2 0.930   0.554  0.994  0.425  0.891    0.605    0.538  0.695  0.0533 0.206 
 3 0.142   0.637  0.0316 0.371  0.256    0.313    0.974  0.568  0.997  0.587 
 4 0.973   0.867  0.282  0.306  0.749    0.881    0.672  0.723  0.0626 0.109 
 5 0.363   0.863  0.602  0.681  0.551    0.0386   0.739  0.464  0.373  0.646 
 6 0.00367 0.0357 0.0457 0.370  0.273    0.0867   0.371  0.0966 0.995  0.729 
 7 0.566   0.963  0.611  0.141  0.858    0.993    0.0810 0.574  0.0535 0.0506
 8 0.406   0.950  0.543  0.589  0.000552 0.357    0.0613 0.799  0.394  0.230 
 9 0.614   0.766  0.973  0.875  0.592    0.983    0.120  0.148  0.677  0.314 
10 0.697   0.425  0.370  0.116  0.653    0.115    0.472  0.386  0.578  0.142 
11 0.214   0.307  0.0161 0.892  0.466    0.860    0.971  0.122  0.282  0.939 
12 0.274   0.294  0.585  0.684  0.410    0.565    0.264  0.634  0.814  0.754 
13 0.506   0.409  0.630  0.569  0.783    0.000274 0.125  0.811  0.237  0.272 
14 0.293   0.574  0.187  0.155  0.518    0.451    0.295  0.246  0.732  0.260 
15 0.924   0.232  0.407  0.541  0.124    0.400    0.0405 0.305  0.800  0.866 
16 0.918   0.503  0.662  0.261  0.711    0.385    0.973  0.475  0.809  0.891 
17 0.0484  0.511  0.187  0.431  0.113    0.425    0.0731 0.936  0.146  0.489 
18 0.355   0.577  0.0542 0.820  0.239    0.770    0.345  0.933  0.789  0.713 
19 0.999   0.731  0.428  0.382  0.322    0.143    0.517  0.163  0.329  0.786 
20 0.345   0.713  0.897  0.951  0.0814   0.776    0.912  0.680  0.430  0.434 

[[5]][[57]]
# A tibble: 93 × 10
      V1    V2    V3      V4     V5       V6     V7     V8     V9    V10
   <dbl> <dbl> <dbl>   <dbl>  <dbl>    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.486 0.537 0.509 0.713   0.220  0.789    0.433  0.487  0.503  0.277 
 2 0.159 0.334 0.805 0.258   0.952  0.000354 0.308  0.547  0.298  0.247 
 3 0.231 0.919 0.867 0.258   0.635  0.109    0.270  0.469  0.179  0.250 
 4 0.318 0.832 0.414 0.0521  0.125  0.423    0.969  0.0662 0.0958 0.230 
 5 0.340 0.996 0.850 0.681   0.432  0.278    0.0252 0.212  0.525  0.326 
 6 0.268 0.661 0.667 0.358   0.0783 0.423    0.393  0.822  0.472  0.0604
 7 0.884 0.952 0.950 0.00701 0.948  0.969    0.335  0.185  0.215  0.118 
 8 0.965 0.403 0.772 0.172   0.0573 0.110    0.905  0.255  0.0211 0.287 
 9 0.647 0.872 0.925 0.379   0.786  0.749    0.374  0.229  0.951  0.0995
10 0.661 0.696 0.303 0.353   0.458  0.0899   0.0630 0.606  0.720  0.158 
# ℹ 83 more rows

[[5]][[58]]
# A tibble: 68 × 10
       V1    V2      V3     V4     V5     V6     V7     V8     V9    V10
    <dbl> <dbl>   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.267  0.907 0.270   0.905  0.144  0.740  0.145  0.984  0.236  0.463 
 2 0.354  0.306 0.944   0.260  0.809  0.409  0.244  0.454  0.394  0.273 
 3 0.896  0.363 0.239   0.889  0.445  0.163  0.606  0.562  0.769  0.680 
 4 0.169  0.621 0.563   0.371  0.0753 0.0443 0.733  0.0280 0.147  0.264 
 5 0.641  0.590 0.884   0.759  0.396  0.358  0.872  0.251  0.411  0.0556
 6 0.432  0.205 0.871   0.667  0.907  0.219  0.396  0.609  0.0963 0.359 
 7 0.860  0.722 0.953   0.593  0.233  0.0414 0.776  0.663  0.873  0.476 
 8 0.761  0.250 0.271   0.0868 0.703  0.793  0.720  0.102  0.647  0.348 
 9 0.0172 0.837 0.465   0.495  0.714  0.955  0.901  0.647  0.887  0.663 
10 0.912  0.310 0.00696 0.567  0.545  0.912  0.0433 0.276  0.747  0.928 
# ℹ 58 more rows

[[5]][[59]]
# A tibble: 72 × 10
       V1     V2    V3    V4    V5    V6     V7      V8     V9    V10
    <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>   <dbl>  <dbl>  <dbl>
 1 0.846  0.517  0.869 0.911 0.713 0.358 0.445  0.586   0.658  0.700 
 2 0.619  0.781  0.120 0.242 0.280 0.199 0.461  0.663   0.0847 0.961 
 3 0.854  0.659  0.311 0.423 0.626 0.961 0.198  0.617   0.184  0.778 
 4 0.878  0.652  0.632 0.444 0.651 0.844 0.0840 0.721   0.891  0.336 
 5 0.491  0.452  0.310 0.349 0.727 0.727 0.720  0.846   0.861  0.988 
 6 0.875  0.0142 0.684 0.656 0.527 0.587 0.453  0.481   0.853  0.293 
 7 0.0884 0.389  0.855 0.382 0.241 0.994 0.666  0.0223  0.521  0.865 
 8 0.718  0.567  0.770 0.588 0.221 0.232 0.779  0.612   0.180  0.0578
 9 0.863  0.116  0.183 0.475 0.731 0.961 0.311  0.00251 0.342  0.440 
10 0.310  0.719  0.548 0.708 0.764 0.564 0.947  0.125   0.877  0.428 
# ℹ 62 more rows

[[5]][[60]]
# A tibble: 24 × 10
       V1     V2     V3     V4    V5     V6    V7     V8     V9    V10
    <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.466  0.768  0.925  0.288  0.732 0.830  0.999 0.730  0.380  0.697 
 2 0.716  0.0373 0.533  0.115  0.307 0.295  0.369 0.346  0.532  0.254 
 3 0.526  0.718  0.692  0.386  0.604 0.587  0.589 0.717  0.712  0.453 
 4 0.0342 0.487  0.0714 0.250  0.204 0.501  0.536 0.311  0.0974 0.953 
 5 0.0304 0.351  0.0881 0.543  0.731 0.639  0.626 0.310  0.0223 0.962 
 6 0.355  0.775  0.663  0.145  0.601 0.0757 0.514 0.694  0.0841 0.951 
 7 0.822  0.936  0.183  0.982  0.843 0.955  0.517 0.852  0.0925 0.126 
 8 0.137  0.486  0.247  0.833  0.386 0.837  0.602 0.0103 0.763  0.941 
 9 0.216  0.655  0.895  0.0980 0.705 0.963  0.355 0.475  0.0545 0.584 
10 0.258  0.877  0.0765 0.985  0.934 0.209  0.213 0.835  0.758  0.0571
# ℹ 14 more rows

[[5]][[61]]
# A tibble: 72 × 10
       V1     V2     V3     V4      V5     V6     V7     V8    V9     V10
    <dbl>  <dbl>  <dbl>  <dbl>   <dbl>  <dbl>  <dbl>  <dbl> <dbl>   <dbl>
 1 0.768  0.575  0.679  0.210  0.458   0.858  0.979  0.979  0.387 0.396  
 2 0.859  0.0663 0.764  0.863  0.491   0.341  0.233  0.0499 0.531 0.810  
 3 0.505  0.917  0.0348 0.924  0.482   0.344  0.549  0.740  0.495 0.555  
 4 0.787  0.517  0.437  0.445  0.836   0.732  0.475  0.699  0.679 0.742  
 5 0.0631 0.153  0.194  0.526  0.423   0.0931 0.343  0.859  0.225 0.740  
 6 0.833  0.388  0.401  0.836  0.274   0.858  0.134  0.604  0.794 0.00583
 7 0.565  0.158  0.139  0.661  0.210   0.0390 0.413  0.312  0.832 0.547  
 8 0.552  0.0484 0.300  0.0886 0.956   0.758  0.0204 0.352  0.790 0.423  
 9 0.0565 0.292  0.990  0.0548 0.926   0.683  0.290  0.0503 0.582 0.120  
10 0.997  0.566  0.372  0.581  0.00185 0.470  0.661  0.585  0.948 0.359  
# ℹ 62 more rows

[[5]][[62]]
# A tibble: 9 × 10
       V1    V2     V3     V4     V5     V6    V7     V8    V9    V10
    <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>
1 0.414   0.723 0.0908 0.374  0.0144 0.597  0.538 0.106  0.892 0.253 
2 0.126   0.448 0.445  0.611  0.825  0.605  0.241 0.935  0.443 0.772 
3 0.295   0.225 0.772  0.654  0.756  0.450  0.326 0.783  0.383 0.426 
4 0.615   0.824 0.624  0.0208 0.847  0.0958 0.218 0.353  0.507 0.0666
5 0.00193 0.200 0.123  0.197  0.438  0.226  0.594 0.0524 0.819 0.298 
6 0.871   0.485 0.163  0.964  0.485  0.257  0.410 0.740  0.986 0.587 
7 0.432   0.939 0.303  0.342  0.331  0.292  0.508 0.918  0.125 0.897 
8 0.860   0.292 0.282  0.128  0.421  0.366  0.836 0.833  0.230 0.311 
9 0.0914  0.176 0.750  0.272  0.360  0.552  0.240 0.156  0.208 0.960 

[[5]][[63]]
# A tibble: 90 × 10
      V1    V2     V3     V4     V5     V6    V7     V8     V9   V10
   <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.443 0.680 0.440  0.231  0.213  0.181  0.488 0.790  0.210  0.271
 2 0.417 0.628 0.488  0.296  0.494  0.0341 0.390 0.0677 0.610  0.490
 3 0.261 0.236 0.893  0.811  0.616  0.0752 0.744 0.902  0.111  0.809
 4 0.566 0.465 0.338  0.416  0.116  0.0122 0.777 0.163  0.392  0.530
 5 0.777 0.342 0.135  0.851  0.537  0.992  0.848 0.889  0.867  0.717
 6 0.726 0.961 0.374  0.230  0.474  0.625  0.390 0.345  0.370  0.328
 7 0.539 0.241 0.0475 0.0556 0.0116 0.675  0.502 0.936  0.0430 0.269
 8 0.101 0.553 0.285  0.0597 0.990  0.286  0.892 0.272  0.735  0.915
 9 0.558 0.473 0.532  0.347  0.493  0.840  0.935 0.727  0.0556 0.953
10 0.348 0.345 0.187  0.804  0.184  0.646  0.214 0.448  0.705  0.338
# ℹ 80 more rows

[[5]][[64]]
# A tibble: 83 × 10
       V1    V2    V3    V4    V5     V6     V7    V8      V9   V10
    <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl>   <dbl> <dbl>
 1 0.0823 0.183 0.483 0.662 0.127 0.121  0.577  0.739 0.215   0.305
 2 0.105  0.136 0.667 0.827 0.682 0.980  0.521  0.157 0.699   0.688
 3 0.332  0.601 0.703 0.210 0.192 0.173  0.487  0.150 0.428   0.295
 4 0.210  0.970 0.316 0.376 0.496 0.0362 0.824  0.523 0.00335 0.299
 5 0.429  0.315 0.830 0.568 0.471 0.243  0.278  0.282 0.886   0.681
 6 0.155  0.806 0.926 0.587 0.505 0.612  0.632  0.538 0.541   0.570
 7 0.450  0.224 0.820 0.339 0.930 0.0189 0.208  0.386 0.834   0.418
 8 0.197  0.757 0.848 0.337 0.884 0.118  0.820  0.496 0.318   0.171
 9 0.740  0.646 0.759 0.288 0.300 0.848  0.0532 0.845 0.837   0.620
10 0.410  0.344 0.220 0.201 0.204 0.754  0.572  0.441 0.247   0.407
# ℹ 73 more rows

[[5]][[65]]
# A tibble: 7 × 10
      V1     V2    V3      V4    V5    V6      V7     V8    V9   V10
   <dbl>  <dbl> <dbl>   <dbl> <dbl> <dbl>   <dbl>  <dbl> <dbl> <dbl>
1 0.283  0.533  0.305 0.917   0.399 0.775 0.0808  0.497  0.793 0.376
2 0.603  0.112  0.567 0.171   0.994 0.336 0.490   0.838  0.228 0.454
3 0.0275 0.0377 0.680 0.623   0.775 0.757 0.00515 0.0729 0.773 0.259
4 0.754  0.927  0.439 0.00436 0.749 0.112 0.632   0.902  0.805 0.396
5 0.290  0.630  0.519 0.200   0.985 0.197 0.371   0.484  0.593 0.469
6 0.0515 0.696  0.543 0.780   0.418 0.642 0.638   0.840  0.783 0.824
7 0.756  0.808  0.776 0.411   0.957 0.182 0.725   0.721  0.285 0.269

[[5]][[66]]
# A tibble: 11 × 10
       V1     V2      V3    V4     V5     V6    V7     V8    V9   V10
    <dbl>  <dbl>   <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl>
 1 0.841  0.521  0.714   0.691 0.315  0.469  0.550 0.0694 0.404 0.278
 2 0.475  0.666  0.666   0.834 0.808  0.876  0.868 0.152  0.451 0.355
 3 0.230  0.958  0.495   0.850 0.423  0.660  0.978 0.785  0.499 0.411
 4 0.798  0.426  0.244   0.667 0.493  0.748  0.244 0.0271 0.614 0.846
 5 0.647  0.444  0.677   0.793 0.0332 0.0133 0.342 0.201  0.593 0.936
 6 0.505  0.465  0.818   0.171 0.279  0.676  0.754 0.0851 0.504 0.268
 7 0.0762 0.0417 0.277   0.957 0.474  0.835  0.924 0.807  0.911 0.113
 8 0.947  0.951  0.00379 0.646 0.386  0.367  0.578 0.649  0.535 0.567
 9 0.975  0.876  0.656   0.297 0.912  0.806  0.522 0.294  0.371 0.869
10 0.546  0.237  0.766   0.396 0.0688 0.0796 0.320 0.531  0.904 0.423
11 0.101  0.520  0.274   0.887 0.917  0.223  0.587 0.595  0.459 0.282

[[5]][[67]]
# A tibble: 64 × 10
       V1     V2     V3     V4     V5      V6    V7     V8     V9    V10
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl>   <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.902  0.422  0.0309 0.838  0.913  0.288   0.824 0.794  0.556  0.551 
 2 0.135  0.0389 0.549  0.460  0.812  0.465   0.239 0.602  0.202  0.928 
 3 0.946  0.998  0.332  0.479  0.757  0.365   0.341 0.0861 0.488  0.395 
 4 0.299  0.547  0.921  0.0505 0.157  0.00762 0.158 0.959  0.187  0.496 
 5 0.865  0.0629 0.147  0.617  0.401  0.0118  0.484 0.0243 0.594  0.446 
 6 0.745  0.539  0.815  0.274  0.0365 0.976   0.840 0.0910 0.0305 0.520 
 7 0.475  0.773  0.0450 0.625  0.876  0.985   0.524 0.330  0.135  0.0989
 8 0.0133 0.0421 0.898  0.751  0.721  0.533   0.539 0.853  0.306  0.644 
 9 0.640  0.136  0.0599 0.451  0.460  0.679   0.653 0.750  0.923  0.264 
10 0.907  0.357  0.215  0.276  0.476  0.764   0.597 0.811  0.174  0.313 
# ℹ 54 more rows

[[5]][[68]]
# A tibble: 14 × 10
       V1    V2     V3    V4    V5     V6     V7      V8    V9     V10
    <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl>   <dbl> <dbl>   <dbl>
 1 0.874  0.557 0.850  0.647 0.833 0.314  0.938  0.692   0.392 0.948  
 2 0.460  0.330 0.718  0.397 0.360 0.0957 0.0712 0.543   0.949 0.454  
 3 0.205  0.165 0.710  0.577 0.578 0.903  0.621  0.377   0.700 0.328  
 4 0.0969 0.859 0.987  0.788 0.976 0.475  0.861  0.00329 0.852 0.340  
 5 0.461  0.956 0.925  0.951 0.981 0.580  0.280  0.378   0.814 0.00168
 6 0.0360 0.554 0.545  0.961 0.709 0.706  0.0351 0.497   0.333 0.222  
 7 0.986  0.446 0.256  0.555 0.514 0.690  0.227  0.777   0.235 0.139  
 8 0.768  0.982 0.688  0.298 0.127 0.964  0.576  0.930   0.681 0.967  
 9 0.342  0.432 0.112  0.266 0.205 0.100  0.971  0.626   0.459 0.237  
10 0.0104 0.887 0.124  0.501 0.636 0.428  0.318  0.668   0.779 0.326  
11 0.150  0.903 0.443  0.856 0.960 0.820  0.102  0.0407  0.937 0.449  
12 0.350  0.579 0.714  0.491 0.696 0.188  0.605  0.928   0.279 0.264  
13 0.893  0.809 0.382  0.776 0.698 0.384  0.121  0.369   0.346 0.114  
14 0.375  0.411 0.0891 0.670 0.448 0.119  0.695  0.0384  0.161 0.624  

[[5]][[69]]
# A tibble: 76 × 10
        V1     V2     V3     V4    V5    V6     V7    V8    V9    V10
     <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.103   0.445  0.611  0.332  0.115 0.270 0.0358 0.529 0.117 0.0658
 2 0.998   0.467  0.469  0.934  0.338 0.551 0.0811 0.963 0.613 0.185 
 3 0.693   0.0993 0.391  0.920  0.432 0.346 0.532  0.913 0.758 0.807 
 4 0.409   0.406  0.698  0.861  0.348 0.331 0.614  0.377 0.660 0.224 
 5 0.672   0.376  0.609  0.238  0.594 0.688 0.290  0.920 0.637 0.0838
 6 0.197   0.743  0.0947 0.0805 0.569 0.664 0.0197 0.300 0.380 0.614 
 7 0.0812  0.167  0.0691 0.640  0.576 0.119 0.395  0.185 0.643 0.957 
 8 0.342   0.333  0.754  0.120  0.982 0.900 0.299  0.891 0.152 0.382 
 9 0.267   0.515  0.489  0.827  0.925 0.503 0.347  0.871 0.364 0.757 
10 0.00541 0.305  0.275  0.830  0.867 0.403 0.996  0.615 0.635 0.346 
# ℹ 66 more rows

[[5]][[70]]
# A tibble: 13 × 10
      V1     V2      V3     V4     V5     V6      V7     V8    V9    V10
   <dbl>  <dbl>   <dbl>  <dbl>  <dbl>  <dbl>   <dbl>  <dbl> <dbl>  <dbl>
 1 0.719 0.916  0.00688 0.467  1.00   0.249  0.915   0.767  0.992 0.784 
 2 0.283 0.617  0.472   0.672  0.572  0.558  0.798   0.141  0.943 0.594 
 3 0.591 0.666  0.770   0.962  0.367  0.526  0.349   0.725  0.967 0.302 
 4 0.121 0.930  0.304   0.493  0.385  0.0717 0.468   0.277  0.284 0.388 
 5 0.845 0.279  0.317   0.999  0.824  0.349  0.821   0.773  0.960 0.155 
 6 0.851 0.688  0.246   0.0593 0.563  0.297  0.0718  0.0402 0.126 0.773 
 7 0.451 0.993  0.180   0.733  0.209  0.0717 0.731   0.857  0.370 0.428 
 8 0.991 0.422  0.538   0.172  0.655  0.196  0.140   0.275  0.915 0.342 
 9 0.427 0.0540 0.459   0.0238 0.783  0.0566 0.248   0.196  0.180 0.237 
10 0.947 0.761  0.909   0.530  0.447  0.220  0.00768 0.129  0.151 0.727 
11 0.959 0.282  0.543   0.768  0.155  0.582  0.122   0.756  0.492 0.715 
12 0.238 0.765  0.164   0.718  0.0534 0.957  0.510   0.329  0.667 0.0577
13 0.546 0.587  0.270   0.118  0.650  0.203  0.217   0.207  0.360 0.719 

[[5]][[71]]
# A tibble: 22 × 10
       V1     V2    V3    V4    V5    V6     V7     V8     V9    V10
    <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.532  0.431  0.669 0.957 0.315 0.173 0.330  0.558  0.564  0.931 
 2 0.504  0.541  0.240 0.410 0.449 0.560 0.587  0.618  0.688  0.389 
 3 0.376  0.576  0.745 0.606 0.773 0.261 0.353  0.752  0.0964 0.919 
 4 0.0931 0.636  0.180 0.232 0.763 0.922 0.338  0.103  0.710  0.398 
 5 0.0125 0.962  0.565 0.306 0.156 0.936 0.789  0.0492 0.605  0.109 
 6 0.837  0.832  0.852 0.403 0.415 0.891 0.707  0.426  0.179  0.780 
 7 0.0889 0.0137 0.336 0.970 0.213 0.630 0.0603 0.104  0.131  0.625 
 8 0.589  0.397  0.524 0.451 0.795 0.111 0.392  0.321  0.680  0.628 
 9 0.876  0.869  0.243 0.772 0.238 0.883 0.523  0.719  0.820  0.0763
10 0.441  0.995  0.471 0.753 0.594 0.959 0.407  0.688  0.0228 0.915 
# ℹ 12 more rows

[[5]][[72]]
# A tibble: 71 × 10
       V1     V2    V3     V4    V5      V6     V7     V8     V9    V10
    <dbl>  <dbl> <dbl>  <dbl> <dbl>   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.774  0.882  0.571 0.0966 0.787 0.967   0.857  0.762  0.611  0.458 
 2 0.0769 0.737  0.491 0.456  0.622 0.883   0.695  0.377  0.261  0.0969
 3 0.0409 0.217  0.238 0.0922 0.998 0.195   0.620  0.0264 0.138  0.945 
 4 0.950  0.248  0.566 0.721  0.601 0.927   0.248  0.438  0.0710 0.298 
 5 0.737  0.214  0.494 0.889  0.442 0.917   0.113  0.159  0.946  0.643 
 6 0.835  0.291  0.730 0.0550 0.355 0.824   0.219  0.290  0.446  0.445 
 7 0.397  0.0939 0.432 0.0648 0.290 0.0454  0.0508 0.819  0.309  0.197 
 8 0.643  0.293  0.838 0.0780 0.136 0.625   0.508  0.748  0.190  0.236 
 9 0.157  0.491  0.540 0.724  0.271 0.00999 0.0323 0.541  0.919  0.502 
10 0.976  0.962  0.676 0.940  0.452 0.194   0.606  0.632  0.804  0.249 
# ℹ 61 more rows

[[5]][[73]]
# A tibble: 80 × 10
         V1     V2     V3     V4    V5    V6      V7     V8    V9    V10
      <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>   <dbl>  <dbl> <dbl>  <dbl>
 1 0.611    0.688  0.338  0.637  0.473 0.301 0.674   0.917  0.402 0.0504
 2 0.227    0.795  0.0545 0.657  0.941 0.446 0.00484 0.787  0.915 0.197 
 3 0.200    0.253  0.677  0.468  0.905 0.228 0.698   0.0299 0.693 0.334 
 4 0.678    0.914  0.831  0.898  0.746 0.991 0.680   0.621  0.790 0.238 
 5 0.458    0.277  0.443  0.621  0.919 0.577 0.902   0.931  0.167 0.290 
 6 0.996    0.435  0.182  0.196  0.411 0.108 0.510   0.379  0.628 0.611 
 7 0.744    0.514  0.186  0.750  0.572 0.451 0.685   0.112  0.754 0.452 
 8 0.000313 0.0677 0.229  0.133  0.113 0.523 0.991   0.365  0.932 0.710 
 9 0.262    0.980  0.911  0.0791 0.270 0.130 0.986   0.320  0.612 0.620 
10 0.688    0.921  0.647  0.313  0.841 0.464 0.959   0.0974 0.725 0.304 
# ℹ 70 more rows

[[5]][[74]]
# A tibble: 100 × 10
      V1      V2    V3    V4     V5    V6    V7     V8     V9   V10
   <dbl>   <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.406 0.0971  0.312 0.163 0.297  0.581 0.527 0.942  0.0212 0.328
 2 0.773 0.508   0.373 0.880 0.362  0.536 0.886 0.886  0.0740 0.146
 3 0.484 0.961   0.246 0.327 0.0509 0.299 0.250 0.142  0.886  0.619
 4 0.425 0.750   0.118 0.645 0.370  0.262 0.541 0.0115 0.366  0.963
 5 0.916 0.246   0.855 0.579 0.357  0.490 0.443 0.805  0.277  0.992
 6 0.269 0.688   0.802 0.622 0.827  0.997 0.656 0.178  0.809  0.580
 7 0.283 0.273   0.530 0.163 0.571  0.831 0.119 0.988  0.253  0.333
 8 0.376 0.696   0.227 0.887 0.873  0.137 0.554 0.175  0.442  0.292
 9 0.159 0.294   0.747 0.736 0.122  0.610 0.300 0.285  0.568  0.293
10 0.815 0.00452 0.864 0.269 0.104  0.408 0.160 0.401  0.941  0.166
# ℹ 90 more rows

[[5]][[75]]
# A tibble: 88 × 10
          V1     V2    V3    V4     V5    V6    V7    V8     V9    V10
       <dbl>  <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>
 1 0.859     0.349  0.811 0.439 0.919  0.399 0.298 0.927 0.622  0.669 
 2 0.154     0.504  0.833 0.950 0.123  0.214 0.269 0.596 0.726  0.930 
 3 0.562     0.377  0.427 0.729 0.875  0.920 0.342 0.233 0.775  0.254 
 4 0.0525    0.280  0.187 0.849 0.0594 0.148 0.423 0.397 0.880  0.337 
 5 0.896     0.313  0.494 0.497 0.982  0.974 0.608 0.869 0.0724 0.648 
 6 0.847     0.221  0.653 0.748 0.582  0.189 0.926 0.572 0.837  0.502 
 7 0.0000688 0.0793 0.398 0.657 0.160  0.592 0.570 0.178 0.424  0.168 
 8 0.770     0.494  0.785 0.360 0.735  0.530 0.234 0.704 0.240  0.669 
 9 0.587     0.561  0.200 0.283 0.801  0.816 0.937 0.334 0.304  0.224 
10 0.149     0.714  0.996 0.838 0.271  0.864 0.941 0.863 0.366  0.0122
# ℹ 78 more rows

[[5]][[76]]
# A tibble: 91 × 10
       V1      V2     V3     V4       V5     V6    V7     V8      V9    V10
    <dbl>   <dbl>  <dbl>  <dbl>    <dbl>  <dbl> <dbl>  <dbl>   <dbl>  <dbl>
 1 0.333  0.843   0.669  0.211  0.773    0.510  0.676 0.401  0.286   0.847 
 2 0.0385 0.453   0.817  0.128  0.569    0.400  0.551 0.0371 0.00431 0.395 
 3 0.945  0.603   0.282  0.452  0.566    0.733  0.957 0.0307 0.235   0.421 
 4 0.0144 0.798   0.933  0.0191 0.538    0.0320 0.263 0.0405 0.908   0.595 
 5 0.0598 0.639   0.0408 0.958  0.209    0.263  0.242 0.874  0.258   0.0739
 6 0.816  0.623   0.292  0.546  0.000905 0.791  0.523 0.618  0.918   0.147 
 7 0.991  0.00917 0.182  0.521  0.124    0.323  0.831 0.286  0.349   0.655 
 8 0.370  0.979   0.975  0.906  0.539    0.565  0.397 0.106  0.519   0.959 
 9 0.738  0.587   0.214  0.537  0.702    0.182  0.120 0.285  0.198   0.384 
10 0.850  0.431   0.662  0.814  0.602    0.286  0.847 0.979  0.250   0.707 
# ℹ 81 more rows

[[5]][[77]]
# A tibble: 86 × 10
       V1    V2     V3     V4     V5     V6     V7      V8     V9    V10
    <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>   <dbl>  <dbl>  <dbl>
 1 0.672  0.521 0.729  0.392  0.0542 0.0816 0.0280 0.0431  0.695  0.774 
 2 0.502  0.591 0.504  0.248  0.834  0.311  0.840  0.615   0.0797 0.600 
 3 0.0755 0.973 0.733  0.828  0.894  0.498  0.435  0.335   0.612  0.459 
 4 0.166  0.442 0.720  0.828  0.420  0.771  0.411  0.784   0.668  0.440 
 5 0.365  0.718 0.454  0.0131 0.396  0.560  0.550  0.203   0.166  0.990 
 6 0.797  0.739 0.933  0.906  0.810  0.445  0.0692 0.0114  0.216  0.363 
 7 0.727  0.651 0.748  0.895  0.741  0.480  0.544  0.267   0.879  0.814 
 8 0.587  0.574 0.789  0.200  0.581  0.284  0.285  0.151   0.401  0.209 
 9 0.741  0.832 0.153  0.200  0.452  0.262  0.615  0.309   0.156  0.0784
10 0.471  0.360 0.0251 0.704  0.634  0.608  0.0495 0.00138 0.653  0.482 
# ℹ 76 more rows

[[5]][[78]]
# A tibble: 96 × 10
       V1    V2    V3    V4     V5    V6     V7     V8     V9    V10
    <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.273  0.670 0.668 0.500 0.173  0.472 0.814  0.723  0.358  0.567 
 2 0.615  0.865 0.381 0.334 0.293  0.591 0.0228 0.516  0.834  0.591 
 3 0.760  0.504 0.285 0.824 0.548  0.544 0.0405 0.634  0.578  0.175 
 4 0.418  0.100 0.303 0.821 0.898  0.723 0.0791 0.739  0.645  0.311 
 5 0.540  0.155 0.306 0.901 0.474  0.883 0.821  0.525  0.0233 0.234 
 6 0.398  0.490 0.258 0.548 0.0692 0.825 0.435  0.666  0.567  0.421 
 7 0.554  0.832 0.317 0.481 0.747  0.985 0.595  0.963  0.302  0.514 
 8 0.488  0.504 0.426 0.932 0.238  0.600 0.649  0.0105 0.349  0.0107
 9 0.0690 0.439 0.457 0.625 0.500  0.994 0.418  0.654  0.437  0.542 
10 0.820  0.742 0.468 0.408 0.762  0.351 0.814  0.844  0.525  0.841 
# ℹ 86 more rows

[[5]][[79]]
# A tibble: 7 × 10
     V1    V2     V3    V4     V5     V6     V7    V8     V9   V10
  <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>
1 0.453 0.906 0.655  0.988 0.750  0.479  0.584  0.338 0.0927 0.449
2 0.694 0.639 0.362  0.717 0.0921 0.231  0.695  0.464 0.808  0.122
3 0.399 0.331 0.0255 0.439 0.0564 0.562  0.678  0.175 0.105  0.544
4 0.141 0.374 0.621  0.573 0.140  0.315  0.0782 0.736 0.873  0.577
5 0.629 0.478 0.0873 0.141 0.103  0.0249 0.453  0.731 0.386  0.350
6 0.213 0.560 1.00   0.752 0.241  0.655  0.573  0.903 0.921  0.451
7 0.399 0.328 0.426  0.290 0.911  0.669  0.578  0.146 0.0393 0.805

[[5]][[80]]
# A tibble: 49 × 10
      V1    V2     V3     V4     V5    V6     V7     V8     V9    V10
   <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.274 0.180 0.919  0.910  0.892  0.728 0.996  0.655  0.0288 0.213 
 2 0.895 0.759 0.267  0.325  0.923  0.136 0.121  0.616  0.271  0.736 
 3 0.225 0.515 0.839  0.997  0.443  0.122 0.143  0.0649 0.857  0.0716
 4 0.169 0.186 0.245  0.984  0.229  0.286 0.623  0.164  0.155  0.708 
 5 0.723 0.409 0.0722 0.0507 0.650  0.976 0.260  0.239  0.744  0.413 
 6 0.871 0.353 0.847  0.926  0.898  0.490 0.849  0.475  0.948  0.596 
 7 0.188 0.497 0.706  0.339  0.0277 0.870 0.519  0.444  0.470  0.607 
 8 0.689 0.624 0.941  0.270  0.281  0.466 0.0906 0.102  0.0967 0.622 
 9 0.989 0.690 0.948  0.891  0.483  0.123 0.611  0.871  0.209  0.249 
10 0.566 0.489 0.530  0.990  0.708  0.393 0.796  0.836  0.0403 0.238 
# ℹ 39 more rows

[[5]][[81]]
# A tibble: 65 × 10
       V1     V2    V3     V4    V5     V6     V7     V8    V9    V10
    <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.386  0.0736 0.691 0.780  0.826 0.881  0.0695 0.945  0.286 0.147 
 2 0.0849 0.476  0.913 0.680  0.899 0.319  0.0405 0.199  0.386 0.0498
 3 0.741  0.896  0.537 0.808  0.844 0.123  0.484  0.552  0.542 0.995 
 4 0.725  0.586  0.583 0.826  0.792 0.513  0.728  0.409  0.844 0.919 
 5 0.696  0.584  0.571 0.453  0.237 0.0421 0.163  0.405  0.806 0.338 
 6 0.522  0.894  0.829 0.698  0.368 0.580  0.571  0.327  0.228 0.278 
 7 0.0901 0.642  0.619 0.0244 0.519 0.687  0.344  0.528  0.575 0.409 
 8 0.0299 0.187  0.352 0.650  0.173 0.516  0.656  0.0354 0.760 0.0939
 9 0.578  0.802  0.576 0.232  0.906 0.467  0.113  0.448  0.132 0.673 
10 0.517  0.341  0.934 0.939  0.137 0.455  0.707  0.781  0.888 0.702 
# ℹ 55 more rows

[[5]][[82]]
# A tibble: 44 × 10
       V1     V2     V3    V4     V5    V6     V7     V8    V9    V10
    <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl>
 1 0.347  0.287  0.971  0.838 0.958  0.738 0.630  0.228  0.874 0.0285
 2 0.892  0.904  0.331  0.741 0.618  0.485 0.418  0.932  0.617 0.216 
 3 0.0806 0.570  0.192  0.332 0.174  0.507 0.470  0.862  0.222 0.350 
 4 0.938  0.508  0.0265 0.300 0.646  0.377 0.964  0.728  0.439 0.772 
 5 0.519  0.407  0.637  0.693 0.770  0.869 0.928  0.674  0.770 0.628 
 6 0.461  0.546  0.672  0.653 0.792  0.658 0.0230 0.347  0.291 0.828 
 7 0.310  0.0764 0.295  0.387 0.445  0.234 0.977  0.667  0.969 0.939 
 8 0.114  0.895  0.204  0.128 0.406  0.916 0.210  0.265  0.206 0.416 
 9 0.725  0.113  0.205  0.534 0.509  0.977 0.379  0.715  0.173 0.279 
10 0.213  0.722  0.0975 0.941 0.0302 0.438 0.381  0.0915 0.550 0.602 
# ℹ 34 more rows

[[5]][[83]]
# A tibble: 44 × 10
      V1     V2      V3     V4    V5    V6    V7    V8     V9     V10
   <dbl>  <dbl>   <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>   <dbl>
 1 0.239 0.637  0.00385 0.583  0.964 0.956 0.111 0.318 0.943  0.696  
 2 0.663 0.772  0.905   0.308  0.431 0.502 0.343 0.998 0.180  0.646  
 3 0.804 0.923  0.244   0.0344 0.401 0.619 0.865 0.744 0.738  0.137  
 4 0.688 0.441  0.130   0.213  0.813 0.903 0.783 0.135 0.731  0.978  
 5 0.907 0.767  0.0560  0.0496 0.546 0.598 0.774 0.351 0.0359 0.00257
 6 0.756 0.446  0.142   0.237  0.946 0.487 0.535 0.430 0.919  0.233  
 7 0.844 0.528  0.665   0.702  0.401 0.186 0.224 0.142 0.196  0.881  
 8 0.231 0.269  0.783   0.992  0.812 0.252 0.872 0.447 0.306  0.706  
 9 0.248 0.0750 0.218   0.653  0.128 0.120 0.816 0.358 0.880  0.544  
10 0.798 0.442  0.820   0.512  0.315 0.851 0.409 0.472 0.296  0.460  
# ℹ 34 more rows

[[5]][[84]]
# A tibble: 8 × 10
      V1     V2     V3    V4        V5     V6    V7    V8    V9   V10
   <dbl>  <dbl>  <dbl> <dbl>     <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl>
1 0.443  0.462  0.763  0.820 0.309     0.349  0.213 0.595 0.209 0.556
2 0.698  0.705  0.0575 0.532 0.0000773 0.982  0.570 0.465 0.787 0.817
3 0.898  0.799  0.478  0.690 0.339     0.295  0.473 0.319 0.252 0.530
4 0.754  0.0929 0.122  0.796 0.337     0.589  0.558 0.281 0.647 0.377
5 0.723  0.135  0.734  0.519 0.804     0.912  0.465 0.139 0.268 0.786
6 0.307  0.926  0.0158 0.434 0.422     0.179  0.215 0.451 0.296 0.299
7 0.0822 0.809  0.761  0.290 0.513     0.0515 0.268 0.652 0.131 0.149
8 0.744  0.449  0.270  0.177 0.130     0.723  0.478 0.883 0.562 0.969

[[5]][[85]]
# A tibble: 47 × 10
       V1     V2     V3     V4     V5    V6     V7     V8     V9    V10
    <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
 1 0.474  0.996  0.887  0.460  0.816  0.279 0.398  0.966  0.377  0.231 
 2 0.357  0.0590 0.878  0.103  0.152  0.477 0.280  0.769  0.0587 0.465 
 3 0.448  0.334  0.502  0.425  0.438  0.149 0.674  0.642  0.720  0.691 
 4 0.0392 0.477  0.0490 0.786  0.241  0.260 0.0897 0.821  0.981  0.0680
 5 0.0859 0.860  0.335  0.0984 0.0565 0.855 0.279  0.226  0.176  0.971 
 6 0.437  0.0900 0.999  0.572  0.0873 0.594 0.492  0.0160 0.441  0.426 
 7 0.101  0.862  0.709  0.257  0.894  0.332 0.516  0.714  0.465  0.978 
 8 0.885  0.713  0.0284 0.613  0.657  0.193 0.432  0.299  0.662  0.241 
 9 0.481  0.481  0.457  0.804  0.570  0.872 0.174  0.340  0.386  0.661 
10 0.496  0.685  0.310  0.260  0.561  0.470 0.362  0.308  0.691  0.359 
# ℹ 37 more rows

[[5]][[86]]
# A tibble: 32 × 10
       V1     V2    V3    V4    V5     V6      V7    V8     V9    V10
    <dbl>  <dbl> <dbl> <dbl> <dbl>  <dbl>   <dbl> <dbl>  <dbl>  <dbl>
 1 0.240  0.145  0.824 0.659 0.334 0.497  0.308   0.245 0.487  0.346 
 2 0.858  0.326  0.795 0.327 0.428 0.439  0.00859 0.209 0.602  0.952 
 3 0.443  0.431  0.391 0.680 0.639 0.0477 0.944   0.244 0.713  0.202 
 4 0.720  0.969  0.630 0.905 0.904 0.525  0.799   0.891 0.335  0.666 
 5 0.901  0.0383 0.507 0.587 0.787 0.583  0.512   0.707 0.731  0.242 
 6 0.632  0.287  0.764 0.245 0.730 0.922  0.790   0.149 0.0258 0.0667
 7 0.0639 0.612  0.817 0.841 0.300 0.713  0.450   0.830 0.279  0.130 
 8 0.662  0.811  0.514 0.640 0.513 0.0682 0.663   0.962 0.271  0.117 
 9 0.218  0.859  0.564 0.648 0.120 0.779  0.701   0.311 0.189  0.334 
10 0.738  0.773  0.686 0.292 0.775 0.457  0.426   0.991 0.823  0.572 
# ℹ 22 more rows

[[5]][[87]]
# A tibble: 27 × 10
       V1    V2     V3    V4      V5      V6    V7    V8    V9    V10
    <dbl> <dbl>  <dbl> <dbl>   <dbl>   <dbl> <dbl> <dbl> <dbl>  <dbl>
 1 0.205  0.648 0.734  0.877 0.892   0.437   0.101 0.763 0.812 0.564 
 2 0.662  0.351 0.0360 0.235 0.0121  0.358   0.264 0.608 0.558 0.673 
 3 0.821  0.805 0.779  0.701 0.474   0.821   0.635 0.958 0.853 0.0415
 4 0.700  0.275 0.173  0.868 0.00567 0.00487 0.140 0.586 0.392 0.927 
 5 0.355  0.350 0.226  0.335 0.376   0.239   0.102 0.435 0.569 0.569 
 6 0.296  0.758 0.517  0.493 0.345   0.528   0.373 0.156 0.309 0.484 
 7 0.664  0.623 0.427  0.414 0.477   0.882   0.438 0.905 0.973 0.616 
 8 0.423  0.754 0.781  0.463 0.567   0.326   0.448 0.634 0.535 0.967 
 9 0.102  0.496 0.670  0.838 0.819   0.285   0.860 0.230 0.795 0.226 
10 0.0449 0.694 0.730  0.530 0.220   0.437   0.840 0.976 0.567 0.110 
# ℹ 17 more rows

[[5]][[88]]
# A tibble: 8 × 10
     V1    V2     V3     V4     V5    V6     V7     V8      V9    V10
  <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl>   <dbl>  <dbl>
1 0.896 0.118 0.328  0.589  0.846  0.308 0.370  0.817  0.876   0.716 
2 0.840 0.915 0.381  0.855  0.0429 0.353 0.0711 0.0676 0.495   0.207 
3 0.281 0.735 0.0673 0.270  0.514  0.234 0.872  0.389  0.325   0.396 
4 0.675 0.145 0.933  0.495  0.950  0.969 0.0436 0.989  0.479   0.898 
5 0.771 0.908 0.540  0.520  0.0910 0.401 0.761  0.362  0.00680 0.516 
6 0.217 0.778 0.856  0.632  0.417  0.995 0.360  0.479  0.824   0.994 
7 0.927 0.697 0.754  0.0849 0.397  0.789 0.846  0.0389 0.358   0.0814
8 0.471 0.524 0.908  0.0639 0.931  0.181 0.332  0.909  0.784   0.0132

[[5]][[89]]
# A tibble: 86 × 10
      V1     V2    V3     V4     V5     V6     V7     V8    V9   V10
   <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>
 1 0.739 0.475  0.290 0.535  0.301  0.438  0.729  0.915  0.975 0.363
 2 0.154 0.937  0.668 0.413  0.0278 0.162  0.735  0.328  0.442 0.724
 3 0.880 0.589  0.229 0.319  0.948  0.325  0.458  0.0179 0.147 0.724
 4 0.421 0.497  0.898 0.865  0.842  0.315  0.957  0.583  0.318 1.00 
 5 0.270 0.0547 0.785 0.0607 0.386  0.452  0.802  0.599  0.393 0.952
 6 0.346 0.958  0.468 0.381  0.354  0.406  0.426  0.0325 0.314 0.834
 7 0.773 0.646  0.665 0.938  0.396  0.886  0.440  0.336  0.574 0.205
 8 0.356 0.941  0.796 0.677  0.651  0.0956 0.913  0.421  0.231 0.239
 9 0.387 0.134  0.215 0.291  0.634  0.999  0.0871 0.817  0.858 0.468
10 0.749 0.988  0.683 0.235  0.682  0.779  0.876  0.139  0.894 0.821
# ℹ 76 more rows

[[5]][[90]]
# A tibble: 79 × 10
      V1     V2    V3    V4    V5      V6     V7    V8    V9    V10
   <dbl>  <dbl> <dbl> <dbl> <dbl>   <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.950 0.536  0.708 0.477 0.320 0.351   0.521  0.630 0.294 0.188 
 2 0.914 0.834  0.577 0.277 0.146 0.665   0.380  0.224 0.279 0.174 
 3 0.940 0.218  0.173 0.794 0.368 0.00580 0.0421 0.870 0.265 0.540 
 4 0.708 0.127  0.952 0.528 0.296 0.320   0.119  0.928 0.395 0.574 
 5 0.590 0.745  0.290 0.936 0.180 0.0880  0.604  0.689 0.558 0.0600
 6 0.671 0.555  0.869 0.499 0.141 0.852   0.992  0.909 0.825 0.619 
 7 0.339 0.0828 0.155 0.169 0.287 0.752   0.739  0.236 0.820 0.795 
 8 0.654 0.884  0.323 0.392 0.956 0.169   0.555  0.950 0.983 0.216 
 9 0.774 0.791  0.414 0.412 0.408 0.745   0.761  0.995 0.101 0.752 
10 0.494 0.189  0.642 0.421 0.291 0.429   0.919  0.872 0.456 0.226 
# ℹ 69 more rows

[[5]][[91]]
# A tibble: 17 × 10
       V1    V2     V3     V4     V5     V6     V7      V8      V9    V10
    <dbl> <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>   <dbl>   <dbl>  <dbl>
 1 0.117  0.223 0.288  0.151  0.270  0.585  0.224  0.0200  0.365   0.178 
 2 0.347  0.836 0.205  0.933  0.777  0.972  0.419  0.125   0.165   0.793 
 3 0.914  0.243 0.0938 0.956  0.0512 0.999  0.350  0.631   0.380   0.385 
 4 0.856  0.687 0.634  0.156  0.0737 0.279  0.104  0.594   0.647   0.355 
 5 0.225  0.728 0.517  0.269  0.494  0.751  0.897  0.546   0.00447 0.801 
 6 0.442  0.536 0.788  0.0389 0.607  0.850  0.132  0.926   0.693   0.692 
 7 0.136  0.965 0.645  0.619  0.515  0.708  0.969  0.00217 0.732   0.932 
 8 0.756  0.760 0.340  0.630  0.555  0.820  0.935  0.933   0.505   0.143 
 9 0.958  0.825 0.765  0.484  0.992  0.479  0.808  0.468   0.434   0.845 
10 0.822  0.525 0.716  0.0956 0.539  0.303  0.195  0.340   0.710   0.926 
11 0.446  0.121 0.761  0.678  0.588  0.0993 0.954  0.317   0.363   0.0220
12 0.662  0.345 0.208  0.689  0.110  0.938  0.384  0.435   0.992   0.525 
13 0.815  0.843 0.956  0.0652 0.0543 0.524  0.155  0.871   0.415   0.936 
14 0.300  0.943 0.458  0.796  0.180  0.870  0.714  0.284   0.0573  0.625 
15 0.350  0.714 0.978  0.892  0.506  0.734  0.329  0.175   0.494   0.929 
16 0.0933 0.396 0.622  0.736  0.256  0.862  0.589  0.425   0.157   0.856 
17 0.798  1.00  0.768  0.596  0.654  0.598  0.0729 0.698   0.243   0.895 

[[5]][[92]]
# A tibble: 87 × 10
      V1     V2      V3    V4    V5     V6     V7    V8     V9   V10
   <dbl>  <dbl>   <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl> <dbl>
 1 0.668 0.193  0.705   0.334 0.509 0.217  0.164  0.568 0.771  0.682
 2 0.374 0.553  0.00477 0.213 0.488 0.794  0.461  0.875 0.0133 0.216
 3 0.179 0.662  0.994   0.258 0.850 0.971  0.0731 0.461 0.483  0.185
 4 0.923 0.860  0.756   0.586 0.497 0.302  0.992  0.478 0.116  0.809
 5 0.711 0.0902 0.587   0.547 0.593 0.986  0.529  0.528 0.141  0.740
 6 0.794 0.241  0.167   0.515 0.851 0.991  0.0711 0.531 0.421  0.111
 7 0.136 0.405  0.313   0.188 0.162 0.726  0.0683 0.200 0.106  0.588
 8 0.711 0.264  0.700   0.531 0.402 0.0652 0.490  0.882 0.633  0.684
 9 0.351 0.850  0.535   0.793 0.276 0.343  0.568  0.299 0.143  0.275
10 0.277 0.446  0.859   0.620 0.919 0.541  0.854  0.872 0.781  0.710
# ℹ 77 more rows

[[5]][[93]]
# A tibble: 71 × 10
       V1      V2    V3      V4     V5     V6     V7    V8    V9   V10
    <dbl>   <dbl> <dbl>   <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>
 1 0.109  0.546   0.685 0.00562 0.444  0.548  0.604  0.124 0.664 0.270
 2 0.0294 0.296   0.890 0.195   0.819  0.0662 0.295  0.781 0.592 0.928
 3 0.810  0.127   0.535 0.646   0.794  0.346  0.718  0.853 0.792 0.574
 4 0.223  0.679   0.651 0.193   0.571  0.667  0.853  0.150 0.252 0.362
 5 0.761  0.733   0.564 0.0292  0.132  0.837  0.0646 0.343 0.480 0.559
 6 0.725  0.717   0.906 0.553   0.0618 0.318  0.524  0.837 0.745 0.389
 7 0.746  0.0142  0.907 0.985   0.905  0.721  0.492  0.395 0.871 0.334
 8 0.378  0.00564 0.239 0.234   0.961  0.886  0.447  0.957 0.689 0.224
 9 0.895  0.792   0.476 0.170   0.431  0.210  0.544  0.178 0.938 0.288
10 0.542  0.607   0.539 0.972   0.157  0.638  0.643  0.201 0.203 0.287
# ℹ 61 more rows

[[5]][[94]]
# A tibble: 82 × 10
      V1     V2    V3     V4    V5     V6    V7     V8     V9    V10
   <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>
 1 0.967 0.986  0.116 0.234  0.292 0.176  0.463 0.834  0.298  0.671 
 2 0.555 0.499  0.916 0.730  0.882 0.471  0.155 0.121  0.984  0.504 
 3 0.229 0.0276 0.571 0.688  0.256 0.624  0.351 0.737  0.923  0.383 
 4 0.978 0.937  0.139 0.864  0.790 0.0549 0.764 0.103  0.385  0.0670
 5 0.581 0.614  0.863 0.945  0.852 0.803  0.886 0.501  0.247  0.988 
 6 0.787 0.195  0.973 0.0856 0.458 0.735  0.670 0.582  0.0270 0.986 
 7 0.280 0.349  0.277 0.827  0.950 0.356  0.525 0.819  0.232  0.353 
 8 0.207 0.153  0.780 0.541  0.832 0.272  0.688 0.501  0.587  0.731 
 9 0.277 0.581  0.725 0.227  0.606 0.195  0.479 0.0339 0.746  0.884 
10 0.316 0.166  0.137 0.709  0.539 0.478  0.972 0.970  0.745  0.144 
# ℹ 72 more rows

[[5]][[95]]
# A tibble: 91 × 10
       V1    V2     V3    V4     V5    V6     V7    V8    V9    V10
    <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>
 1 0.0410 0.805 0.0623 0.604 0.342  0.283 0.425  0.600 0.951 0.664 
 2 0.742  0.501 0.878  0.614 0.134  0.500 0.444  0.572 0.647 0.807 
 3 0.293  0.556 0.444  0.994 0.936  0.255 0.552  0.272 0.333 0.481 
 4 0.510  0.268 0.165  0.980 0.414  0.511 0.846  0.507 0.906 0.131 
 5 0.842  0.779 0.257  0.699 0.767  0.227 0.401  0.887 0.969 0.486 
 6 0.819  0.495 0.601  0.190 0.0989 0.949 0.691  0.773 0.100 0.764 
 7 0.189  0.687 0.236  0.860 0.525  0.441 0.204  0.528 0.319 0.507 
 8 0.819  0.763 0.990  0.521 0.353  0.507 0.0649 0.922 0.645 0.172 
 9 0.526  0.435 0.0863 0.126 0.852  0.462 0.0654 0.283 0.293 0.0907
10 0.657  0.789 0.820  0.781 0.549  0.207 0.120  0.925 0.928 0.268 
# ℹ 81 more rows

[[5]][[96]]
# A tibble: 43 × 10
       V1    V2    V3     V4    V5     V6     V7    V8      V9   V10
    <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl>   <dbl> <dbl>
 1 0.731  0.703 0.129 0.0572 0.433 0.600  0.245  0.569 0.207   0.813
 2 0.277  0.175 0.694 0.902  0.505 0.848  0.398  0.724 0.156   0.281
 3 0.797  0.722 0.980 0.150  0.388 0.116  0.424  0.495 0.656   0.262
 4 0.987  0.918 0.985 0.800  0.930 0.153  0.0485 0.771 0.316   0.254
 5 0.867  0.344 0.801 0.103  0.313 0.944  0.474  0.541 0.288   0.205
 6 0.992  0.915 0.639 0.359  0.824 0.0484 0.777  0.951 0.572   0.993
 7 0.164  0.885 0.726 0.485  0.209 0.683  0.569  0.770 0.00641 0.837
 8 0.0974 0.543 0.353 0.669  0.693 0.503  0.972  0.338 0.671   0.795
 9 0.463  0.827 0.976 0.323  0.957 0.226  0.747  0.417 0.621   0.903
10 0.907  0.346 0.869 0.302  0.551 0.671  0.452  0.595 0.687   0.540
# ℹ 33 more rows

[[5]][[97]]
# A tibble: 90 × 10
       V1    V2     V3     V4      V5     V6    V7     V8     V9   V10
    <dbl> <dbl>  <dbl>  <dbl>   <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.456  0.463 0.626  0.618  0.120   0.869  0.548 0.176  0.972  0.125
 2 0.578  0.758 0.574  0.291  0.453   0.818  0.360 0.422  0.684  0.393
 3 0.554  0.372 0.603  0.448  0.788   0.568  0.580 0.551  0.539  0.253
 4 0.972  0.780 0.438  0.337  0.263   0.922  0.862 0.258  0.749  0.747
 5 0.274  0.179 0.195  0.414  0.697   0.409  0.634 0.366  0.268  0.485
 6 0.0453 0.493 0.533  0.0239 0.700   0.101  0.574 0.0363 0.563  0.398
 7 0.730  0.949 0.275  0.353  0.576   0.851  0.741 0.320  0.682  0.700
 8 0.708  0.219 0.0308 0.872  0.872   0.568  0.782 0.0669 0.459  0.935
 9 0.0739 0.338 0.918  0.204  0.0624  0.790  0.593 0.428  0.959  0.938
10 0.329  0.639 0.121  0.449  0.00427 0.0197 0.924 0.335  0.0893 0.942
# ℹ 80 more rows

[[5]][[98]]
# A tibble: 24 × 10
       V1     V2     V3      V4    V5    V6    V7     V8     V9   V10
    <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl>
 1 0.854  0.311  1.00   0.00779 0.317 0.159 0.426 0.921  0.536  0.766
 2 0.743  0.849  0.184  0.557   0.395 0.273 0.609 0.802  0.502  0.719
 3 0.0461 0.507  0.0517 0.854   0.320 0.673 0.553 0.975  0.806  0.305
 4 0.450  0.548  0.972  0.199   0.908 0.676 0.898 0.0814 0.0852 0.994
 5 0.348  0.0620 0.335  0.526   0.697 0.790 0.541 0.892  0.362  0.775
 6 0.782  0.342  0.923  0.468   0.854 0.507 0.186 0.217  0.831  0.141
 7 0.898  0.573  0.687  0.788   0.478 0.773 0.103 0.972  0.426  0.160
 8 0.420  0.847  0.731  0.222   0.653 0.316 0.792 0.249  0.599  0.243
 9 0.245  0.381  0.667  0.729   0.396 0.714 0.466 0.364  0.889  0.732
10 0.845  0.714  0.105  0.502   0.716 0.570 0.904 0.607  0.926  0.726
# ℹ 14 more rows

[[5]][[99]]
# A tibble: 79 × 10
      V1     V2     V3     V4      V5    V6    V7     V8    V9   V10
   <dbl>  <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl>
 1 0.922 0.432  0.0833 0.600  0.690   0.481 0.855 0.300  0.650 0.171
 2 0.304 0.960  0.569  0.741  0.986   0.293 0.719 0.186  0.809 0.686
 3 0.728 0.0959 0.485  0.218  0.0465  0.350 0.628 0.803  0.307 0.488
 4 0.944 0.0852 0.808  0.132  0.483   0.141 0.571 0.527  0.996 0.911
 5 0.417 0.169  0.690  0.983  0.809   0.506 0.442 0.0907 0.506 0.511
 6 0.289 0.652  0.315  0.938  0.606   0.233 0.212 0.861  0.309 0.885
 7 0.689 0.671  0.117  0.969  0.00185 0.681 0.143 0.191  0.840 0.618
 8 0.904 0.157  0.161  0.165  0.256   0.580 0.323 0.450  0.757 0.909
 9 0.148 0.529  0.439  0.581  0.874   0.610 0.674 0.0827 0.110 0.571
10 0.183 0.770  0.948  0.0146 0.924   0.749 0.954 0.328  0.760 0.537
# ℹ 69 more rows

[[5]][[100]]
# A tibble: 61 × 10
       V1    V2     V3     V4    V5     V6     V7    V8    V9   V10
    <dbl> <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>
 1 0.432  0.538 0.244  0.844  0.648 0.400  0.529  0.191 0.135 0.878
 2 0.0428 0.814 0.422  0.599  0.706 0.0229 0.549  0.432 0.857 0.920
 3 0.819  0.342 0.312  0.973  0.652 0.901  0.179  0.367 0.572 0.590
 4 0.741  0.656 0.666  0.417  0.818 0.450  0.327  0.673 0.802 0.990
 5 0.187  0.321 0.989  0.985  0.346 0.448  0.183  0.221 0.627 0.467
 6 0.557  0.300 0.0101 0.515  0.900 0.497  0.859  0.999 0.778 0.424
 7 0.0114 0.713 0.185  0.439  0.123 0.268  0.0243 0.570 0.283 0.105
 8 0.791  0.504 0.705  0.804  0.815 0.884  0.897  0.821 0.841 0.509
 9 0.124  0.207 0.885  0.0630 0.791 0.141  0.717  0.771 0.539 0.461
10 0.597  0.377 0.582  0.153  0.242 0.674  0.510  0.117 0.298 0.261
# ℹ 51 more rows


[[6]]
[[6]][[1]]
# A tibble: 36 × 3
       V1     V2    V3
    <dbl>  <dbl> <dbl>
 1 0.270  0.903  0.783
 2 0.0167 0.714  0.110
 3 0.496  0.312  0.975
 4 0.392  0.364  0.464
 5 0.542  0.678  0.239
 6 0.955  0.584  0.889
 7 0.848  0.0172 0.738
 8 0.858  0.357  0.930
 9 0.147  0.488  0.487
10 0.684  0.146  0.681
# ℹ 26 more rows

[[6]][[2]]
# A tibble: 55 × 3
      V1     V2    V3
   <dbl>  <dbl> <dbl>
 1 0.528 0.0629 0.474
 2 0.903 0.763  0.876
 3 0.753 0.427  0.191
 4 0.917 0.765  0.563
 5 0.186 0.892  0.663
 6 0.409 0.302  0.733
 7 0.100 0.202  0.317
 8 0.799 0.170  0.594
 9 0.987 0.0909 0.106
10 0.613 0.0602 0.613
# ℹ 45 more rows

[[6]][[3]]
# A tibble: 68 × 3
       V1    V2    V3
    <dbl> <dbl> <dbl>
 1 0.170  0.386 0.152
 2 0.410  0.417 0.808
 3 0.902  0.790 0.857
 4 0.926  0.496 0.898
 5 0.808  0.215 0.871
 6 0.772  0.313 0.687
 7 0.252  0.660 0.361
 8 0.0534 0.101 0.385
 9 0.931  0.809 0.144
10 0.185  0.664 0.889
# ℹ 58 more rows

[[6]][[4]]
# A tibble: 37 × 3
       V1     V2     V3
    <dbl>  <dbl>  <dbl>
 1 0.102  0.0126 0.534 
 2 0.0604 0.792  0.0622
 3 0.200  0.814  0.450 
 4 0.734  0.113  0.832 
 5 0.680  0.199  0.891 
 6 0.277  0.978  0.593 
 7 0.548  0.0517 0.559 
 8 0.410  0.172  0.336 
 9 0.699  0.583  0.837 
10 0.326  0.297  0.668 
# ℹ 27 more rows

[[6]][[5]]
# A tibble: 95 × 3
      V1    V2    V3
   <dbl> <dbl> <dbl>
 1 0.315 0.693 0.519
 2 0.247 0.473 0.694
 3 0.844 0.680 0.961
 4 0.607 0.200 0.715
 5 0.629 0.839 0.660
 6 0.936 0.201 0.784
 7 0.896 0.810 0.471
 8 0.791 0.488 0.636
 9 0.900 0.106 0.625
10 0.832 0.127 0.406
# ℹ 85 more rows

[[6]][[6]]
# A tibble: 79 × 3
      V1    V2     V3
   <dbl> <dbl>  <dbl>
 1 0.253 0.440 0.233 
 2 0.748 0.776 0.959 
 3 0.688 0.400 0.362 
 4 0.182 0.962 0.345 
 5 0.594 0.769 0.362 
 6 0.504 0.880 0.0124
 7 0.581 0.975 0.973 
 8 0.539 0.493 0.832 
 9 0.802 0.935 0.0486
10 0.203 0.793 0.414 
# ℹ 69 more rows

[[6]][[7]]
# A tibble: 57 × 3
      V1     V2     V3
   <dbl>  <dbl>  <dbl>
 1 0.426 0.215  0.610 
 2 0.169 0.242  0.725 
 3 0.175 0.199  0.968 
 4 0.672 0.0668 0.620 
 5 0.799 0.108  0.481 
 6 0.605 0.748  0.762 
 7 0.385 0.643  0.708 
 8 0.264 0.114  0.818 
 9 0.699 0.618  0.673 
10 0.597 0.327  0.0603
# ℹ 47 more rows

[[6]][[8]]
# A tibble: 21 × 3
       V1     V2    V3
    <dbl>  <dbl> <dbl>
 1 0.328  0.0800 0.909
 2 0.748  0.740  0.773
 3 0.0927 0.192  0.154
 4 0.0279 0.571  0.368
 5 0.455  0.166  0.107
 6 0.201  0.0378 0.219
 7 0.630  0.338  0.581
 8 0.244  0.479  0.188
 9 0.0748 0.152  0.588
10 0.386  0.376  0.519
# ℹ 11 more rows

[[6]][[9]]
# A tibble: 82 × 3
      V1     V2     V3
   <dbl>  <dbl>  <dbl>
 1 0.246 0.920  0.428 
 2 0.922 0.809  0.0360
 3 0.137 0.446  0.694 
 4 0.660 0.925  0.0276
 5 0.361 0.445  0.129 
 6 0.368 0.263  0.0130
 7 0.920 0.965  0.932 
 8 0.556 0.942  0.159 
 9 0.937 0.571  0.540 
10 0.340 0.0221 0.848 
# ℹ 72 more rows

[[6]][[10]]
# A tibble: 39 × 3
      V1     V2     V3
   <dbl>  <dbl>  <dbl>
 1 0.435 0.588  0.919 
 2 0.334 0.395  0.927 
 3 0.627 0.816  0.377 
 4 0.621 0.642  0.845 
 5 0.660 0.870  0.747 
 6 0.661 0.924  0.436 
 7 0.482 0.303  0.281 
 8 0.643 0.558  0.0831
 9 0.205 0.0308 0.964 
10 0.775 0.846  0.963 
# ℹ 29 more rows

[[6]][[11]]
# A tibble: 3 × 3
     V1     V2     V3
  <dbl>  <dbl>  <dbl>
1 0.109 0.0436 0.698 
2 0.473 0.326  0.0699
3 0.472 0.520  0.358 

[[6]][[12]]
# A tibble: 81 × 3
      V1     V2     V3
   <dbl>  <dbl>  <dbl>
 1 0.725 0.597  0.506 
 2 0.379 0.0233 0.501 
 3 0.889 0.758  0.0734
 4 0.305 0.201  0.574 
 5 0.790 0.101  0.185 
 6 0.587 0.572  0.443 
 7 0.573 0.565  0.640 
 8 0.698 0.492  0.250 
 9 0.694 0.136  0.387 
10 0.341 0.139  0.615 
# ℹ 71 more rows

[[6]][[13]]
# A tibble: 18 × 3
       V1     V2     V3
    <dbl>  <dbl>  <dbl>
 1 0.392  0.921  0.983 
 2 0.459  0.205  0.182 
 3 0.597  0.139  0.714 
 4 0.497  0.125  0.250 
 5 0.997  0.0254 0.442 
 6 0.360  0.554  0.827 
 7 0.988  0.778  0.818 
 8 0.483  0.449  0.559 
 9 0.176  0.222  0.815 
10 0.0316 0.950  0.162 
11 0.339  0.274  0.687 
12 0.671  0.253  0.492 
13 0.873  0.580  0.784 
14 0.735  0.315  0.138 
15 0.586  0.100  0.307 
16 0.577  0.705  0.0146
17 0.364  0.200  0.332 
18 0.495  0.352  0.720 

[[6]][[14]]
# A tibble: 61 × 3
       V1     V2    V3
    <dbl>  <dbl> <dbl>
 1 0.875  0.0256 0.802
 2 0.123  0.173  0.273
 3 0.228  0.230  0.645
 4 0.377  0.168  0.401
 5 0.783  0.0751 0.514
 6 0.168  0.213  0.174
 7 0.0439 0.723  0.298
 8 0.260  0.0573 0.642
 9 0.208  0.0982 0.112
10 0.870  0.634  0.267
# ℹ 51 more rows

[[6]][[15]]
# A tibble: 85 × 3
        V1    V2     V3
     <dbl> <dbl>  <dbl>
 1 0.214   0.932 0.449 
 2 0.423   0.460 0.588 
 3 0.00930 0.500 0.876 
 4 0.595   0.579 0.449 
 5 0.974   0.518 0.698 
 6 0.0449  0.480 0.884 
 7 0.0181  0.193 0.0457
 8 0.704   0.261 0.761 
 9 0.473   0.405 0.844 
10 0.536   0.618 0.645 
# ℹ 75 more rows

[[6]][[16]]
# A tibble: 72 × 3
      V1      V2     V3
   <dbl>   <dbl>  <dbl>
 1 0.125 0.994   0.742 
 2 0.513 0.728   0.718 
 3 0.262 0.0956  0.407 
 4 0.304 0.0400  0.711 
 5 0.653 0.0686  0.0711
 6 0.744 0.268   0.544 
 7 0.111 0.00155 0.508 
 8 0.895 0.460   0.806 
 9 0.555 0.177   0.295 
10 0.647 0.447   0.876 
# ℹ 62 more rows

[[6]][[17]]
# A tibble: 70 × 3
       V1       V2     V3
    <dbl>    <dbl>  <dbl>
 1 0.462  0.0742   0.493 
 2 0.666  0.184    0.224 
 3 0.0459 0.997    0.482 
 4 0.430  0.760    0.193 
 5 0.824  0.470    0.168 
 6 0.553  0.000200 0.440 
 7 0.436  0.0377   0.422 
 8 0.175  0.384    0.426 
 9 0.216  0.105    0.0793
10 0.256  0.305    0.484 
# ℹ 60 more rows

[[6]][[18]]
# A tibble: 32 × 3
       V1    V2      V3
    <dbl> <dbl>   <dbl>
 1 0.321  0.180 0.599  
 2 0.659  0.231 0.450  
 3 0.962  0.344 0.800  
 4 0.0887 0.659 0.00382
 5 0.323  0.357 0.890  
 6 0.689  0.764 0.698  
 7 0.322  0.642 0.0969 
 8 0.668  0.882 0.545  
 9 0.0118 0.251 0.419  
10 0.624  0.558 0.286  
# ℹ 22 more rows

[[6]][[19]]
# A tibble: 31 × 3
       V1    V2     V3
    <dbl> <dbl>  <dbl>
 1 0.788  0.885 0.0722
 2 0.556  0.136 0.641 
 3 0.427  0.724 0.767 
 4 0.569  0.132 0.975 
 5 0.243  0.996 0.667 
 6 0.692  0.812 0.761 
 7 0.124  0.997 0.524 
 8 0.688  0.179 0.534 
 9 0.0857 0.855 0.785 
10 0.251  0.901 0.837 
# ℹ 21 more rows

[[6]][[20]]
# A tibble: 65 × 3
       V1     V2     V3
    <dbl>  <dbl>  <dbl>
 1 0.806  0.385  0.524 
 2 0.472  0.257  0.105 
 3 0.301  0.597  0.613 
 4 0.943  0.255  0.999 
 5 0.0472 0.817  0.0958
 6 0.0715 0.422  0.411 
 7 0.920  0.424  0.320 
 8 0.0165 0.397  0.871 
 9 0.292  0.0841 0.363 
10 0.145  0.505  0.246 
# ℹ 55 more rows

[[6]][[21]]
# A tibble: 46 × 3
       V1    V2    V3
    <dbl> <dbl> <dbl>
 1 0.928  0.672 0.361
 2 0.710  0.436 0.968
 3 0.127  0.212 0.777
 4 0.851  0.430 0.379
 5 0.501  0.405 0.194
 6 0.500  0.682 0.661
 7 0.477  0.182 0.848
 8 0.547  0.718 0.529
 9 0.337  0.247 0.389
10 0.0399 0.741 0.247
# ℹ 36 more rows

[[6]][[22]]
# A tibble: 24 × 3
        V1    V2     V3
     <dbl> <dbl>  <dbl>
 1 0.813   0.529 0.651 
 2 0.206   0.891 0.534 
 3 0.685   0.337 0.732 
 4 0.673   0.444 0.0595
 5 0.189   0.380 0.908 
 6 0.869   0.724 0.879 
 7 0.750   0.276 0.640 
 8 0.00198 0.144 0.708 
 9 0.907   0.900 0.435 
10 0.976   0.617 0.787 
# ℹ 14 more rows

[[6]][[23]]
# A tibble: 53 × 3
      V1     V2     V3
   <dbl>  <dbl>  <dbl>
 1 0.290 0.872  0.251 
 2 0.205 0.141  0.627 
 3 0.226 0.0786 0.264 
 4 0.400 0.402  0.817 
 5 0.395 0.0348 0.0884
 6 0.727 0.114  0.616 
 7 0.597 0.508  0.0766
 8 0.333 0.101  0.824 
 9 0.187 0.801  0.125 
10 0.285 0.298  0.150 
# ℹ 43 more rows

[[6]][[24]]
# A tibble: 42 × 3
      V1      V2      V3
   <dbl>   <dbl>   <dbl>
 1 0.929 0.948   0.443  
 2 0.453 0.672   0.950  
 3 0.266 0.520   0.0961 
 4 0.610 0.547   0.560  
 5 0.492 0.209   0.00627
 6 0.986 0.881   0.191  
 7 0.829 0.927   0.393  
 8 0.238 0.757   0.291  
 9 0.753 0.00876 0.0684 
10 0.292 0.979   0.885  
# ℹ 32 more rows

[[6]][[25]]
# A tibble: 89 × 3
       V1    V2      V3
    <dbl> <dbl>   <dbl>
 1 0.651  0.840 0.00275
 2 0.400  0.553 0.147  
 3 0.0953 0.533 0.636  
 4 0.931  0.667 0.694  
 5 0.444  0.973 0.768  
 6 0.631  0.787 0.0551 
 7 0.0900 0.527 0.208  
 8 0.475  0.969 0.939  
 9 0.138  0.962 0.0934 
10 0.770  0.937 0.0590 
# ℹ 79 more rows

[[6]][[26]]
# A tibble: 27 × 3
       V1     V2       V3
    <dbl>  <dbl>    <dbl>
 1 0.225  0.592  0.166   
 2 0.236  0.608  0.511   
 3 0.108  0.661  0.000144
 4 0.0518 0.424  0.900   
 5 0.218  0.945  0.0913  
 6 0.534  0.0663 0.706   
 7 0.627  0.357  0.0797  
 8 0.352  0.669  0.903   
 9 0.222  0.403  0.724   
10 0.940  0.379  0.804   
# ℹ 17 more rows

[[6]][[27]]
# A tibble: 7 × 3
     V1     V2     V3
  <dbl>  <dbl>  <dbl>
1 0.705 0.708  0.603 
2 0.483 0.413  0.978 
3 0.123 0.0854 0.813 
4 0.572 0.272  0.0880
5 0.159 0.257  0.992 
6 0.566 0.778  0.0717
7 0.691 0.982  0.740 

[[6]][[28]]
# A tibble: 34 × 3
        V1     V2     V3
     <dbl>  <dbl>  <dbl>
 1 0.527   0.242  0.0432
 2 0.801   0.130  0.701 
 3 0.00408 0.0820 0.266 
 4 0.299   0.684  0.0121
 5 0.474   0.784  0.161 
 6 0.0748  0.313  0.108 
 7 0.332   0.839  0.920 
 8 0.328   0.0710 0.326 
 9 0.477   0.827  0.579 
10 0.370   0.235  0.335 
# ℹ 24 more rows

[[6]][[29]]
# A tibble: 90 × 3
       V1     V2    V3
    <dbl>  <dbl> <dbl>
 1 0.702  0.713  0.641
 2 0.825  0.0634 0.424
 3 0.0871 0.532  0.236
 4 0.733  0.550  0.641
 5 0.645  0.984  0.279
 6 0.122  0.669  0.459
 7 0.365  0.491  0.201
 8 0.507  0.162  0.302
 9 0.0619 0.372  0.986
10 0.882  0.0319 0.252
# ℹ 80 more rows

[[6]][[30]]
# A tibble: 44 × 3
      V1     V2    V3
   <dbl>  <dbl> <dbl>
 1 0.277 0.298  0.667
 2 0.126 0.196  0.790
 3 0.937 0.677  0.331
 4 0.626 0.166  0.826
 5 0.267 0.631  0.539
 6 0.114 0.769  0.801
 7 0.185 0.624  0.352
 8 0.419 0.943  0.595
 9 0.557 0.928  0.260
10 0.857 0.0354 0.375
# ℹ 34 more rows

[[6]][[31]]
# A tibble: 64 × 3
      V1    V2    V3
   <dbl> <dbl> <dbl>
 1 0.752 0.381 0.108
 2 0.577 0.832 0.985
 3 0.779 0.232 0.628
 4 0.220 0.882 0.862
 5 0.944 0.745 0.525
 6 0.312 0.242 0.686
 7 0.864 0.678 0.146
 8 0.493 0.837 0.359
 9 0.557 0.363 0.740
10 0.806 0.333 0.516
# ℹ 54 more rows

[[6]][[32]]
# A tibble: 84 × 3
       V1    V2     V3
    <dbl> <dbl>  <dbl>
 1 0.253  0.437 0.412 
 2 0.151  0.414 0.0688
 3 0.515  0.472 0.651 
 4 0.0809 0.504 0.935 
 5 0.975  0.538 0.976 
 6 0.849  0.171 0.221 
 7 0.0405 0.129 0.397 
 8 0.789  0.680 0.862 
 9 0.178  0.501 0.874 
10 0.330  0.934 0.490 
# ℹ 74 more rows

[[6]][[33]]
# A tibble: 46 × 3
       V1     V2    V3
    <dbl>  <dbl> <dbl>
 1 0.326  0.609  0.848
 2 0.0273 0.400  0.692
 3 0.903  0.759  0.216
 4 0.743  0.0606 0.529
 5 0.397  0.906  0.777
 6 0.223  0.493  0.826
 7 0.219  0.864  0.152
 8 0.757  0.446  0.311
 9 0.404  0.927  0.515
10 0.833  0.711  0.420
# ℹ 36 more rows

[[6]][[34]]
# A tibble: 96 × 3
      V1    V2    V3
   <dbl> <dbl> <dbl>
 1 0.855 0.186 0.408
 2 0.791 0.691 0.944
 3 0.154 0.822 0.842
 4 0.975 0.631 0.819
 5 0.799 0.602 0.840
 6 0.650 0.453 0.950
 7 0.955 0.157 0.875
 8 0.293 0.343 0.914
 9 0.475 0.732 0.310
10 0.685 0.565 0.528
# ℹ 86 more rows

[[6]][[35]]
# A tibble: 24 × 3
        V1     V2     V3
     <dbl>  <dbl>  <dbl>
 1 0.968   0.829  0.182 
 2 0.988   0.780  0.220 
 3 0.923   0.277  0.857 
 4 0.659   0.0265 0.607 
 5 0.905   0.188  0.792 
 6 0.174   0.394  0.308 
 7 0.356   0.395  0.459 
 8 0.241   0.312  0.0484
 9 0.00405 0.191  0.226 
10 0.837   0.289  0.0831
# ℹ 14 more rows

[[6]][[36]]
# A tibble: 28 × 3
       V1     V2     V3
    <dbl>  <dbl>  <dbl>
 1 0.175  0.544  0.0473
 2 0.406  0.569  0.816 
 3 0.581  0.0342 0.665 
 4 0.523  0.470  0.382 
 5 0.234  0.427  0.308 
 6 0.0888 0.525  0.0437
 7 0.733  0.713  0.981 
 8 0.664  0.204  0.942 
 9 0.394  0.534  0.679 
10 0.961  0.0140 0.640 
# ℹ 18 more rows

[[6]][[37]]
# A tibble: 38 × 3
      V1    V2     V3
   <dbl> <dbl>  <dbl>
 1 0.828 0.271 0.0127
 2 0.297 0.422 0.0891
 3 0.952 0.885 0.169 
 4 0.459 0.268 0.154 
 5 0.928 0.570 0.175 
 6 0.813 0.246 0.508 
 7 0.428 0.756 0.0818
 8 0.218 0.869 0.946 
 9 0.516 0.261 0.136 
10 0.879 0.243 0.309 
# ℹ 28 more rows

[[6]][[38]]
# A tibble: 23 × 3
      V1     V2     V3
   <dbl>  <dbl>  <dbl>
 1 0.883 0.446  0.715 
 2 0.396 0.624  0.597 
 3 0.252 0.0978 0.410 
 4 0.669 0.493  0.0936
 5 0.745 0.244  0.169 
 6 0.413 0.465  0.871 
 7 0.650 0.0711 0.398 
 8 0.713 0.746  0.442 
 9 0.636 0.824  0.529 
10 0.365 0.655  0.788 
# ℹ 13 more rows

[[6]][[39]]
# A tibble: 93 × 3
       V1    V2     V3
    <dbl> <dbl>  <dbl>
 1 0.375  0.678 0.451 
 2 0.261  0.531 0.0200
 3 0.971  0.308 0.363 
 4 0.0975 0.541 0.797 
 5 0.587  0.329 0.0230
 6 0.795  0.821 0.0276
 7 0.924  0.653 0.637 
 8 0.617  0.291 0.579 
 9 0.362  0.389 0.957 
10 0.450  0.907 0.730 
# ℹ 83 more rows

[[6]][[40]]
# A tibble: 15 × 3
       V1      V2     V3
    <dbl>   <dbl>  <dbl>
 1 0.395  0.189   0.664 
 2 0.260  0.842   0.0443
 3 0.0786 0.392   0.401 
 4 0.287  0.893   0.413 
 5 0.961  0.778   0.0988
 6 0.556  0.295   0.123 
 7 0.479  0.427   0.191 
 8 0.507  0.973   0.998 
 9 0.744  0.990   0.612 
10 0.0726 0.593   0.981 
11 0.797  0.257   0.361 
12 0.648  0.983   0.0160
13 0.228  0.777   0.931 
14 0.0732 0.0583  0.492 
15 0.0377 0.00610 0.127 

[[6]][[41]]
# A tibble: 30 × 3
        V1      V2    V3
     <dbl>   <dbl> <dbl>
 1 0.952   0.625   0.832
 2 0.00568 0.122   0.875
 3 0.320   0.369   0.693
 4 0.634   0.573   0.172
 5 0.446   0.00299 0.957
 6 0.820   0.764   0.174
 7 0.711   0.185   0.618
 8 0.571   0.660   0.996
 9 0.701   0.195   0.883
10 0.999   0.155   0.982
# ℹ 20 more rows

[[6]][[42]]
# A tibble: 75 × 3
      V1     V2     V3
   <dbl>  <dbl>  <dbl>
 1 0.765 0.377  0.379 
 2 0.601 0.454  0.0360
 3 0.829 0.743  0.411 
 4 0.803 0.833  0.622 
 5 0.643 0.371  0.793 
 6 0.224 0.727  0.0677
 7 0.466 0.447  0.642 
 8 0.142 0.0118 0.917 
 9 0.718 0.645  0.136 
10 0.595 0.645  0.324 
# ℹ 65 more rows

[[6]][[43]]
# A tibble: 100 × 3
       V1    V2     V3
    <dbl> <dbl>  <dbl>
 1 0.220  0.706 0.483 
 2 0.0132 0.476 0.0395
 3 0.527  0.729 0.816 
 4 0.940  0.946 0.703 
 5 0.860  0.524 0.575 
 6 0.611  0.508 0.326 
 7 0.680  0.697 0.617 
 8 0.531  0.898 0.297 
 9 0.929  0.460 0.743 
10 0.953  0.130 0.218 
# ℹ 90 more rows

[[6]][[44]]
# A tibble: 39 × 3
       V1    V2     V3
    <dbl> <dbl>  <dbl>
 1 0.136  0.611 0.679 
 2 0.694  0.202 0.338 
 3 0.988  0.798 0.795 
 4 0.329  0.926 0.0274
 5 0.789  0.120 0.168 
 6 0.0673 0.732 0.336 
 7 0.811  0.542 0.384 
 8 0.0446 0.832 0.988 
 9 0.662  0.212 0.356 
10 0.678  0.990 0.626 
# ℹ 29 more rows

[[6]][[45]]
# A tibble: 54 × 3
      V1     V2    V3
   <dbl>  <dbl> <dbl>
 1 0.718 0.243  0.505
 2 0.908 0.536  0.146
 3 0.752 0.757  0.553
 4 0.987 0.506  0.862
 5 0.220 0.480  0.756
 6 0.208 0.465  0.553
 7 0.388 0.0339 0.522
 8 0.793 0.452  0.719
 9 0.286 0.692  0.150
10 0.325 0.929  0.345
# ℹ 44 more rows

[[6]][[46]]
# A tibble: 13 × 3
       V1     V2     V3
    <dbl>  <dbl>  <dbl>
 1 0.712  0.265  0.766 
 2 0.834  0.601  0.550 
 3 0.853  0.678  0.311 
 4 0.536  0.386  0.734 
 5 0.719  0.876  0.967 
 6 0.0975 0.0187 0.0996
 7 0.870  0.775  0.0902
 8 0.583  0.957  0.419 
 9 0.0211 0.0167 0.615 
10 0.445  0.306  0.714 
11 0.530  0.667  0.0658
12 0.741  0.423  0.610 
13 0.875  0.754  0.606 

[[6]][[47]]
# A tibble: 56 × 3
      V1    V2     V3
   <dbl> <dbl>  <dbl>
 1 0.872 0.508 0.349 
 2 0.453 0.520 0.240 
 3 0.633 0.395 0.284 
 4 0.659 0.514 0.833 
 5 0.532 0.266 0.0715
 6 0.342 0.371 0.450 
 7 0.303 0.843 0.221 
 8 0.168 0.284 0.0332
 9 0.795 0.330 0.563 
10 0.808 0.303 0.231 
# ℹ 46 more rows

[[6]][[48]]
# A tibble: 83 × 3
        V1    V2      V3
     <dbl> <dbl>   <dbl>
 1 0.288   0.333 0.478  
 2 0.424   0.899 0.233  
 3 0.807   0.376 0.159  
 4 0.951   0.542 0.490  
 5 0.00435 0.481 0.818  
 6 0.166   0.521 0.901  
 7 0.202   0.322 0.0544 
 8 0.208   0.771 0.00417
 9 0.754   0.824 0.369  
10 0.555   0.971 0.734  
# ℹ 73 more rows

[[6]][[49]]
# A tibble: 13 × 3
       V1     V2    V3
    <dbl>  <dbl> <dbl>
 1 0.0769 0.643  0.178
 2 0.889  0.754  0.801
 3 0.774  0.508  0.479
 4 0.0438 0.544  0.743
 5 0.980  0.755  0.273
 6 0.647  0.340  0.812
 7 0.871  0.867  0.478
 8 0.405  0.471  0.224
 9 0.385  0.203  0.253
10 0.151  0.235  0.744
11 0.100  0.714  0.571
12 0.745  0.0382 0.204
13 0.548  0.605  0.363

[[6]][[50]]
# A tibble: 14 × 3
       V1     V2     V3
    <dbl>  <dbl>  <dbl>
 1 0.286  0.431  0.602 
 2 0.917  0.244  0.176 
 3 0.579  0.667  0.176 
 4 0.440  0.410  0.310 
 5 0.221  0.416  0.508 
 6 0.954  0.591  0.933 
 7 0.553  0.0768 0.592 
 8 0.941  0.0687 0.344 
 9 0.661  0.306  0.340 
10 0.0447 0.173  0.0620
11 0.537  0.433  0.945 
12 0.553  0.427  0.991 
13 0.0282 0.244  0.758 
14 0.994  0.191  0.255 

[[6]][[51]]
# A tibble: 93 × 3
      V1    V2     V3
   <dbl> <dbl>  <dbl>
 1 0.729 0.692 0.784 
 2 0.117 0.984 0.992 
 3 0.557 0.287 0.172 
 4 0.203 0.631 0.470 
 5 0.692 0.339 0.0540
 6 0.421 0.546 0.655 
 7 0.997 0.770 0.829 
 8 0.621 0.720 0.710 
 9 0.727 0.407 0.654 
10 0.276 0.741 0.307 
# ℹ 83 more rows

[[6]][[52]]
# A tibble: 53 × 3
       V1    V2     V3
    <dbl> <dbl>  <dbl>
 1 0.402  0.390 0.0600
 2 0.260  0.111 0.682 
 3 0.0653 0.826 0.597 
 4 0.721  0.957 0.389 
 5 0.653  0.984 0.904 
 6 0.0997 0.512 0.750 
 7 0.431  0.350 0.0276
 8 0.715  0.682 0.741 
 9 0.384  0.993 0.478 
10 0.368  0.155 0.787 
# ℹ 43 more rows

[[6]][[53]]
# A tibble: 38 × 3
       V1     V2    V3
    <dbl>  <dbl> <dbl>
 1 0.981  0.603  0.523
 2 0.790  0.449  0.713
 3 0.805  0.796  0.818
 4 0.833  0.476  0.966
 5 0.0815 0.0731 0.711
 6 0.0232 0.464  0.992
 7 0.370  0.719  0.709
 8 0.190  0.550  0.218
 9 0.840  0.518  0.412
10 0.732  0.983  0.482
# ℹ 28 more rows

[[6]][[54]]
# A tibble: 91 × 3
       V1      V2     V3
    <dbl>   <dbl>  <dbl>
 1 0.555  0.573   0.427 
 2 0.739  0.0395  0.760 
 3 0.424  0.843   0.784 
 4 0.848  0.328   0.0497
 5 0.629  0.0878  0.242 
 6 0.606  0.406   0.186 
 7 0.439  0.00575 0.0705
 8 0.0141 0.266   0.299 
 9 0.174  0.130   0.129 
10 0.933  0.495   0.762 
# ℹ 81 more rows

[[6]][[55]]
# A tibble: 96 × 3
        V1    V2     V3
     <dbl> <dbl>  <dbl>
 1 0.530   0.363 0.0513
 2 0.956   0.957 0.438 
 3 0.947   0.556 0.650 
 4 0.695   0.657 0.595 
 5 0.00999 0.993 0.335 
 6 0.614   1.00  0.881 
 7 0.0846  0.439 0.558 
 8 0.160   0.207 0.142 
 9 0.957   0.617 0.799 
10 0.788   0.953 0.861 
# ℹ 86 more rows

[[6]][[56]]
# A tibble: 51 × 3
       V1     V2     V3
    <dbl>  <dbl>  <dbl>
 1 0.797  0.895  0.539 
 2 0.654  0.483  0.419 
 3 0.872  0.0220 0.729 
 4 0.109  0.656  0.626 
 5 0.0330 0.195  0.846 
 6 0.475  0.390  0.733 
 7 0.0790 0.0139 0.0935
 8 0.414  0.841  0.928 
 9 0.151  0.826  0.233 
10 0.0415 0.340  0.393 
# ℹ 41 more rows

[[6]][[57]]
# A tibble: 12 × 3
       V1     V2     V3
    <dbl>  <dbl>  <dbl>
 1 0.919  0.337  0.587 
 2 0.825  0.399  0.291 
 3 0.0919 0.459  0.620 
 4 0.0549 0.168  0.553 
 5 0.394  0.0704 0.344 
 6 0.700  0.152  0.584 
 7 0.711  0.644  0.248 
 8 0.133  0.664  0.0223
 9 0.839  0.239  0.900 
10 0.922  0.670  0.532 
11 0.656  0.590  0.435 
12 0.895  0.274  0.163 

[[6]][[58]]
# A tibble: 24 × 3
        V1    V2     V3
     <dbl> <dbl>  <dbl>
 1 0.117   0.510 0.882 
 2 0.806   0.572 0.840 
 3 0.328   0.413 0.793 
 4 0.204   0.364 0.589 
 5 0.152   0.808 0.693 
 6 0.326   0.375 0.698 
 7 0.906   0.391 0.707 
 8 0.649   0.172 0.609 
 9 0.00555 0.380 0.208 
10 0.961   0.309 0.0781
# ℹ 14 more rows

[[6]][[59]]
# A tibble: 16 × 3
       V1    V2     V3
    <dbl> <dbl>  <dbl>
 1 0.818  0.269 0.538 
 2 0.0274 0.587 0.873 
 3 0.599  0.707 0.605 
 4 0.509  0.308 0.424 
 5 0.205  0.519 0.717 
 6 0.400  0.746 0.0117
 7 0.197  0.974 0.664 
 8 0.580  0.748 0.403 
 9 0.609  0.781 0.936 
10 0.816  0.382 0.900 
11 0.671  0.215 0.397 
12 0.154  0.824 0.218 
13 0.621  0.272 0.648 
14 0.928  0.997 0.385 
15 0.487  0.839 0.0441
16 0.607  0.956 0.214 

[[6]][[60]]
# A tibble: 68 × 3
      V1     V2    V3
   <dbl>  <dbl> <dbl>
 1 0.766 0.579  0.287
 2 0.984 0.0216 0.326
 3 0.402 0.454  0.772
 4 0.755 0.332  0.924
 5 0.223 0.924  0.979
 6 0.154 0.751  0.639
 7 0.940 0.286  0.540
 8 0.579 0.140  0.625
 9 0.569 0.648  0.906
10 0.860 0.184  0.341
# ℹ 58 more rows

[[6]][[61]]
# A tibble: 26 × 3
      V1    V2     V3
   <dbl> <dbl>  <dbl>
 1 0.338 0.223 0.348 
 2 0.182 0.143 0.395 
 3 0.329 0.129 0.477 
 4 0.953 0.989 0.318 
 5 0.831 0.488 0.943 
 6 0.747 0.684 0.981 
 7 0.806 0.428 0.165 
 8 0.812 0.366 0.406 
 9 0.932 0.666 0.261 
10 0.515 0.189 0.0273
# ℹ 16 more rows

[[6]][[62]]
# A tibble: 20 × 3
      V1     V2    V3
   <dbl>  <dbl> <dbl>
 1 0.886 0.183  0.686
 2 0.123 0.173  0.567
 3 0.383 0.605  0.569
 4 0.868 0.228  0.845
 5 0.626 0.0979 0.206
 6 0.598 0.994  0.570
 7 0.857 0.797  0.141
 8 0.665 0.886  0.421
 9 0.973 0.321  0.547
10 0.476 0.813  0.777
11 0.404 0.0667 0.681
12 0.863 0.536  0.242
13 0.988 0.742  0.176
14 0.931 0.705  0.375
15 0.769 0.641  0.180
16 0.779 0.858  0.679
17 0.639 0.106  0.809
18 0.959 0.888  0.759
19 0.510 0.0109 0.902
20 0.776 0.890  0.585

[[6]][[63]]
# A tibble: 98 × 3
        V1     V2      V3
     <dbl>  <dbl>   <dbl>
 1 0.346   0.252  0.601  
 2 0.0322  0.621  0.0402 
 3 0.00823 0.0839 0.863  
 4 0.363   0.0215 0.0634 
 5 0.565   0.541  0.452  
 6 0.904   0.697  0.300  
 7 0.962   0.531  0.646  
 8 0.433   0.0195 0.752  
 9 0.580   0.502  0.452  
10 0.269   0.673  0.00920
# ℹ 88 more rows

[[6]][[64]]
# A tibble: 51 × 3
       V1     V2    V3
    <dbl>  <dbl> <dbl>
 1 0.0799 0.799  0.391
 2 0.487  0.364  0.134
 3 0.539  0.263  0.666
 4 0.596  0.622  0.561
 5 0.486  0.730  0.277
 6 0.681  0.646  0.576
 7 0.478  0.120  0.258
 8 0.0182 0.602  0.828
 9 0.412  0.0232 0.698
10 0.755  0.455  0.703
# ℹ 41 more rows

[[6]][[65]]
# A tibble: 62 × 3
      V1     V2      V3
   <dbl>  <dbl>   <dbl>
 1 0.180 0.0706 0.00552
 2 0.208 0.134  0.871  
 3 0.752 0.141  0.0640 
 4 0.273 0.546  0.340  
 5 0.117 0.197  0.262  
 6 0.707 0.799  0.507  
 7 0.760 0.189  0.630  
 8 0.338 0.243  0.649  
 9 0.389 0.110  0.949  
10 0.905 0.428  0.113  
# ℹ 52 more rows

[[6]][[66]]
# A tibble: 82 × 3
      V1    V2     V3
   <dbl> <dbl>  <dbl>
 1 0.757 0.608 0.341 
 2 0.794 0.834 0.987 
 3 0.909 0.720 0.277 
 4 0.581 0.328 0.825 
 5 0.416 0.995 0.472 
 6 0.448 0.696 0.959 
 7 0.941 0.527 0.0979
 8 0.780 0.228 0.517 
 9 0.442 0.456 0.552 
10 0.136 0.929 0.257 
# ℹ 72 more rows

[[6]][[67]]
# A tibble: 24 × 3
      V1    V2    V3
   <dbl> <dbl> <dbl>
 1 0.359 0.761 0.297
 2 0.913 0.770 0.885
 3 0.877 0.788 0.154
 4 0.571 0.985 0.886
 5 0.247 0.865 0.464
 6 0.389 0.572 0.905
 7 0.988 0.244 0.821
 8 0.622 0.251 0.803
 9 0.646 0.678 0.863
10 0.775 0.301 0.348
# ℹ 14 more rows

[[6]][[68]]
# A tibble: 65 × 3
       V1    V2    V3
    <dbl> <dbl> <dbl>
 1 0.914  0.464 0.743
 2 0.725  0.638 0.736
 3 0.622  0.934 0.163
 4 0.575  0.365 0.260
 5 0.547  0.526 0.826
 6 0.0312 0.941 0.714
 7 0.827  0.973 0.487
 8 0.861  0.830 0.149
 9 0.218  0.557 0.616
10 0.847  0.707 0.189
# ℹ 55 more rows

[[6]][[69]]
# A tibble: 32 × 3
       V1     V2    V3
    <dbl>  <dbl> <dbl>
 1 0.250  0.338  0.390
 2 0.658  0.999  0.376
 3 0.922  0.314  0.764
 4 0.899  0.625  0.844
 5 0.411  0.0591 0.829
 6 0.577  0.974  0.616
 7 0.117  0.767  0.837
 8 0.749  0.397  0.703
 9 0.0939 0.484  0.726
10 0.976  0.599  0.778
# ℹ 22 more rows

[[6]][[70]]
# A tibble: 98 × 3
      V1     V2     V3
   <dbl>  <dbl>  <dbl>
 1 0.578 0.579  0.891 
 2 0.206 0.928  0.780 
 3 0.171 0.0213 0.285 
 4 0.654 0.894  0.100 
 5 0.753 0.476  0.818 
 6 0.622 0.612  0.322 
 7 0.453 0.983  0.770 
 8 0.883 0.0754 0.0686
 9 0.519 0.635  0.967 
10 0.583 0.483  0.463 
# ℹ 88 more rows

[[6]][[71]]
# A tibble: 58 × 3
      V1     V2    V3
   <dbl>  <dbl> <dbl>
 1 0.685 0.913  0.837
 2 0.300 0.414  0.494
 3 0.804 0.567  0.546
 4 0.824 0.706  0.601
 5 0.502 0.426  0.293
 6 0.545 0.0106 0.233
 7 0.449 0.811  0.511
 8 0.911 0.342  0.782
 9 0.607 0.188  0.424
10 0.315 0.0501 0.490
# ℹ 48 more rows

[[6]][[72]]
# A tibble: 44 × 3
       V1     V2    V3
    <dbl>  <dbl> <dbl>
 1 0.976  0.0870 0.359
 2 0.405  0.0616 0.182
 3 0.539  0.608  0.336
 4 0.569  0.731  0.124
 5 0.272  0.520  0.631
 6 0.0453 0.357  0.303
 7 0.845  0.0162 0.234
 8 0.871  0.487  0.693
 9 0.0545 0.348  0.672
10 0.793  0.133  0.612
# ℹ 34 more rows

[[6]][[73]]
# A tibble: 69 × 3
      V1    V2    V3
   <dbl> <dbl> <dbl>
 1 0.876 0.223 0.524
 2 0.593 0.751 0.600
 3 0.734 0.882 0.195
 4 0.804 0.376 0.800
 5 0.995 0.419 0.905
 6 0.214 0.794 0.464
 7 0.666 0.483 0.303
 8 0.182 0.512 0.843
 9 0.701 0.168 0.695
10 0.302 0.507 0.300
# ℹ 59 more rows

[[6]][[74]]
# A tibble: 38 × 3
       V1     V2      V3
    <dbl>  <dbl>   <dbl>
 1 0.0396 0.618  0.599  
 2 0.784  0.212  0.342  
 3 0.598  0.852  0.00801
 4 0.279  0.0725 0.134  
 5 0.897  0.281  0.0773 
 6 0.502  0.799  0.262  
 7 0.746  0.555  0.829  
 8 0.710  0.989  0.0497 
 9 0.627  0.256  0.0236 
10 0.595  0.653  0.231  
# ℹ 28 more rows

[[6]][[75]]
# A tibble: 33 × 3
       V1     V2      V3
    <dbl>  <dbl>   <dbl>
 1 0.0936 0.511  0.544  
 2 0.643  0.876  0.305  
 3 0.327  0.0104 0.612  
 4 0.112  0.700  0.987  
 5 0.507  0.502  0.699  
 6 0.0924 0.136  0.0753 
 7 0.651  0.293  0.484  
 8 0.178  0.682  0.184  
 9 0.141  0.831  0.00725
10 0.598  0.443  0.506  
# ℹ 23 more rows

[[6]][[76]]
# A tibble: 21 × 3
       V1     V2    V3
    <dbl>  <dbl> <dbl>
 1 0.967  0.0980 0.943
 2 0.312  0.322  0.465
 3 0.127  0.158  0.652
 4 0.629  0.333  0.167
 5 0.103  0.474  0.916
 6 0.160  0.153  0.968
 7 0.714  0.242  0.802
 8 0.331  0.691  0.710
 9 0.488  0.0102 0.137
10 0.0986 0.580  0.726
# ℹ 11 more rows

[[6]][[77]]
# A tibble: 81 × 3
       V1    V2      V3
    <dbl> <dbl>   <dbl>
 1 0.162  0.830 0.263  
 2 0.127  0.108 0.206  
 3 0.465  0.504 0.0678 
 4 0.0456 0.586 0.492  
 5 0.0520 0.608 0.798  
 6 0.0884 0.175 0.680  
 7 0.633  0.820 0.523  
 8 0.174  0.972 0.795  
 9 0.879  0.219 0.0236 
10 0.177  0.559 0.00381
# ℹ 71 more rows

[[6]][[78]]
# A tibble: 4 × 3
     V1    V2     V3
  <dbl> <dbl>  <dbl>
1 0.917 0.543 0.514 
2 0.112 0.320 0.807 
3 0.857 0.865 0.0199
4 0.711 0.997 0.634 

[[6]][[79]]
# A tibble: 58 × 3
      V1     V2     V3
   <dbl>  <dbl>  <dbl>
 1 0.539 0.0567 0.676 
 2 0.467 0.528  0.978 
 3 0.594 0.736  0.697 
 4 0.910 0.962  0.119 
 5 0.798 0.150  0.104 
 6 0.972 0.325  0.0543
 7 0.780 0.300  0.565 
 8 0.456 0.732  0.128 
 9 0.444 0.660  0.196 
10 0.828 0.871  0.986 
# ℹ 48 more rows

[[6]][[80]]
# A tibble: 24 × 3
      V1     V2    V3
   <dbl>  <dbl> <dbl>
 1 0.683 0.966  0.314
 2 0.742 0.389  0.573
 3 0.337 0.683  0.620
 4 0.332 0.0709 0.700
 5 0.352 0.0759 0.810
 6 0.242 0.488  0.870
 7 0.858 0.430  0.844
 8 0.669 0.745  0.362
 9 0.775 0.365  0.826
10 0.484 0.532  0.985
# ℹ 14 more rows

[[6]][[81]]
# A tibble: 46 × 3
       V1     V2     V3
    <dbl>  <dbl>  <dbl>
 1 0.445  0.805  0.349 
 2 0.465  0.618  0.562 
 3 0.0310 0.500  0.0138
 4 0.705  0.404  0.734 
 5 0.136  0.554  0.463 
 6 0.810  0.824  0.425 
 7 0.679  0.0877 0.526 
 8 0.351  0.602  0.105 
 9 0.720  0.461  0.894 
10 0.666  0.947  0.640 
# ℹ 36 more rows

[[6]][[82]]
# A tibble: 88 × 3
       V1     V2    V3
    <dbl>  <dbl> <dbl>
 1 0.552  0.937  0.698
 2 0.969  0.559  0.306
 3 0.272  0.0708 0.401
 4 0.199  0.834  0.129
 5 0.712  0.174  0.110
 6 0.570  0.0752 0.420
 7 0.624  0.490  0.192
 8 0.0272 0.314  0.624
 9 0.167  0.161  0.515
10 0.826  0.367  0.841
# ℹ 78 more rows

[[6]][[83]]
# A tibble: 47 × 3
        V1     V2    V3
     <dbl>  <dbl> <dbl>
 1 0.645   0.613  0.933
 2 0.141   0.313  0.574
 3 0.148   0.584  0.892
 4 0.532   0.270  0.769
 5 0.874   0.0154 0.387
 6 0.556   0.592  0.562
 7 0.418   0.0270 0.606
 8 0.00102 0.0628 0.430
 9 0.307   0.664  0.931
10 0.177   0.527  0.865
# ℹ 37 more rows

[[6]][[84]]
# A tibble: 58 × 3
        V1    V2     V3
     <dbl> <dbl>  <dbl>
 1 0.247   0.335 0.722 
 2 0.896   0.443 0.809 
 3 0.677   0.445 0.649 
 4 0.651   0.199 0.0885
 5 0.0462  0.948 0.918 
 6 0.0917  0.857 0.0452
 7 0.834   0.780 0.916 
 8 0.00393 0.682 0.0706
 9 0.201   0.635 0.693 
10 0.396   0.795 0.808 
# ℹ 48 more rows

[[6]][[85]]
# A tibble: 31 × 3
       V1     V2      V3
    <dbl>  <dbl>   <dbl>
 1 0.232  0.137  0.492  
 2 0.246  0.0599 0.660  
 3 0.808  0.813  0.955  
 4 0.607  0.953  0.0424 
 5 0.348  0.767  0.00987
 6 0.991  0.770  0.962  
 7 0.0355 0.916  0.117  
 8 0.517  0.430  0.975  
 9 0.0308 0.910  0.247  
10 0.152  0.334  0.305  
# ℹ 21 more rows

[[6]][[86]]
# A tibble: 43 × 3
      V1    V2    V3
   <dbl> <dbl> <dbl>
 1 0.650 0.638 0.330
 2 0.925 0.236 0.361
 3 0.868 0.311 0.211
 4 0.498 0.838 0.761
 5 0.331 0.819 0.622
 6 0.673 0.771 0.255
 7 0.464 0.422 0.243
 8 0.890 0.519 0.392
 9 0.445 0.820 0.813
10 0.849 0.860 0.897
# ℹ 33 more rows

[[6]][[87]]
# A tibble: 38 × 3
       V1    V2    V3
    <dbl> <dbl> <dbl>
 1 0.564  0.988 0.608
 2 0.353  0.170 0.208
 3 0.146  0.985 0.797
 4 0.919  0.664 0.435
 5 0.233  0.392 0.302
 6 0.604  0.387 0.184
 7 0.0116 0.399 0.789
 8 0.120  0.164 0.938
 9 0.747  0.780 0.744
10 0.0234 0.393 0.710
# ℹ 28 more rows

[[6]][[88]]
# A tibble: 64 × 3
       V1     V2     V3
    <dbl>  <dbl>  <dbl>
 1 0.569  0.0108 0.391 
 2 0.216  0.788  0.190 
 3 0.553  0.306  0.667 
 4 0.753  0.366  0.384 
 5 0.0939 0.355  0.0946
 6 0.315  0.812  0.688 
 7 0.740  0.262  0.465 
 8 0.0316 0.775  0.909 
 9 0.196  0.0854 0.337 
10 0.894  0.331  0.875 
# ℹ 54 more rows

[[6]][[89]]
# A tibble: 33 × 3
       V1     V2     V3
    <dbl>  <dbl>  <dbl>
 1 0.564  0.0876 0.587 
 2 0.117  0.563  0.300 
 3 0.504  0.220  0.174 
 4 0.626  0.573  0.614 
 5 0.606  0.303  0.735 
 6 0.918  0.717  0.614 
 7 0.0539 0.119  0.855 
 8 0.420  0.605  0.0297
 9 0.969  0.193  0.309 
10 0.493  0.654  0.613 
# ℹ 23 more rows

[[6]][[90]]
# A tibble: 71 × 3
       V1    V2    V3
    <dbl> <dbl> <dbl>
 1 0.249  0.708 0.818
 2 0.840  0.671 0.494
 3 0.919  0.399 0.670
 4 0.937  0.289 0.578
 5 0.363  0.737 0.263
 6 0.207  0.326 0.285
 7 0.857  0.631 0.106
 8 0.451  0.963 0.348
 9 0.434  0.927 0.865
10 0.0481 0.113 0.804
# ℹ 61 more rows

[[6]][[91]]
# A tibble: 23 × 3
       V1    V2     V3
    <dbl> <dbl>  <dbl>
 1 0.0756 0.685 0.581 
 2 0.494  0.462 0.160 
 3 0.400  0.928 0.613 
 4 0.597  0.149 0.0929
 5 0.899  0.939 0.941 
 6 0.398  0.483 0.734 
 7 0.957  0.352 0.493 
 8 0.993  0.534 0.555 
 9 0.0936 0.578 0.0824
10 0.0964 0.581 0.811 
# ℹ 13 more rows

[[6]][[92]]
# A tibble: 46 × 3
       V1       V2    V3
    <dbl>    <dbl> <dbl>
 1 0.876  0.659    0.792
 2 0.585  0.000813 0.667
 3 0.800  0.638    0.489
 4 0.629  0.0511   0.248
 5 0.887  0.996    0.671
 6 0.592  0.476    0.593
 7 0.0210 0.635    0.522
 8 0.217  0.738    0.861
 9 0.572  0.630    0.723
10 0.404  0.155    0.470
# ℹ 36 more rows

[[6]][[93]]
# A tibble: 22 × 3
       V1     V2     V3
    <dbl>  <dbl>  <dbl>
 1 0.899  0.308  0.408 
 2 0.518  0.495  0.0379
 3 0.336  0.846  0.474 
 4 0.569  0.889  0.216 
 5 0.506  0.891  0.783 
 6 0.942  0.0118 0.193 
 7 0.525  0.323  0.0515
 8 0.140  0.387  0.0105
 9 0.0998 0.183  0.139 
10 0.967  0.603  0.747 
# ℹ 12 more rows

[[6]][[94]]
# A tibble: 79 × 3
      V1     V2     V3
   <dbl>  <dbl>  <dbl>
 1 0.709 0.101  0.919 
 2 0.806 0.718  0.107 
 3 0.753 0.109  0.0302
 4 0.312 0.557  0.792 
 5 0.155 0.968  0.0215
 6 0.394 0.646  0.268 
 7 0.434 0.411  0.203 
 8 0.871 0.472  0.547 
 9 0.560 0.0394 0.411 
10 0.741 0.963  0.615 
# ℹ 69 more rows

[[6]][[95]]
# A tibble: 67 × 3
       V1     V2     V3
    <dbl>  <dbl>  <dbl>
 1 0.0399 0.317  0.158 
 2 0.649  0.494  0.363 
 3 0.544  0.276  0.177 
 4 0.556  0.353  0.207 
 5 0.444  0.473  0.150 
 6 0.207  0.779  0.214 
 7 0.356  0.145  0.0653
 8 0.719  0.500  0.143 
 9 0.995  0.0851 0.810 
10 0.147  0.332  0.585 
# ℹ 57 more rows

[[6]][[96]]
# A tibble: 49 × 3
      V1      V2     V3
   <dbl>   <dbl>  <dbl>
 1 0.365 0.00147 0.0390
 2 0.538 0.285   0.957 
 3 0.681 0.235   0.776 
 4 0.366 0.741   0.377 
 5 0.880 0.153   0.350 
 6 0.720 0.868   0.789 
 7 0.601 0.219   0.563 
 8 0.515 0.0845  0.952 
 9 0.743 0.601   0.506 
10 0.873 0.439   0.522 
# ℹ 39 more rows

[[6]][[97]]
# A tibble: 91 × 3
       V1    V2     V3
    <dbl> <dbl>  <dbl>
 1 0.977  0.852 0.971 
 2 0.114  0.447 0.0883
 3 0.877  0.776 0.320 
 4 0.889  0.730 0.455 
 5 0.641  0.319 0.240 
 6 0.0282 0.285 0.282 
 7 0.876  0.412 0.656 
 8 0.362  0.401 0.0709
 9 0.459  0.240 0.288 
10 0.464  0.179 0.465 
# ℹ 81 more rows

[[6]][[98]]
# A tibble: 15 × 3
       V1     V2    V3
    <dbl>  <dbl> <dbl>
 1 0.964  0.750  0.162
 2 0.167  0.766  0.997
 3 0.872  0.218  0.406
 4 0.813  0.267  0.599
 5 0.631  0.740  0.987
 6 0.0532 0.0646 0.491
 7 0.150  0.134  0.919
 8 0.951  0.440  0.266
 9 0.964  0.113  0.230
10 0.0382 0.137  0.694
11 0.286  0.672  0.895
12 0.926  0.529  0.797
13 0.442  0.115  0.880
14 0.521  0.920  0.798
15 0.251  0.493  0.916

[[6]][[99]]
# A tibble: 31 × 3
      V1     V2     V3
   <dbl>  <dbl>  <dbl>
 1 0.641 0.968  0.189 
 2 0.345 0.389  0.747 
 3 0.576 0.612  0.854 
 4 0.298 0.824  0.997 
 5 0.754 0.756  0.231 
 6 0.391 0.0695 0.299 
 7 0.484 0.412  0.170 
 8 0.715 0.855  0.0672
 9 0.690 0.268  0.583 
10 0.877 0.588  0.0569
# ℹ 21 more rows

[[6]][[100]]
# A tibble: 61 × 3
        V1    V2     V3
     <dbl> <dbl>  <dbl>
 1 0.400   0.792 0.754 
 2 0.395   0.167 0.120 
 3 0.596   0.953 0.422 
 4 0.552   0.754 0.0385
 5 0.0928  0.929 0.783 
 6 0.00275 0.225 0.105 
 7 0.627   0.324 0.568 
 8 0.613   0.889 0.782 
 9 0.359   0.279 0.0806
10 0.0265  0.168 0.352 
# ℹ 51 more rows
```

1. write code to read these all into one long list of data frames. `str_c()` will be helpful.







```
processing file: 5-functional-programming.Rpres

Quitting from lines 776-781 [unnamed-chunk-59] (5-functional-programming.Rpres)
Execution halted
```
