Functional Programming
========================================================
author: Alejandro Schuler,  based on R for Data Science by Hadley Wickham
date: 2019
transition: none
width: 1680
height: 1050



Introduction to the course
========================================================
type: section


Goals of this course
========================================================
By the end of the course you should be able to...

- write and test your own functions
- write code that evaluates conditionally
- create, manipulate, and inspect lists
- iterate functions over lists of arguments
- iterate in parallel

<div align="center">
<img src="https://d33wubrfki0l68.cloudfront.net/571b056757d68e6df81a3e3853f54d3c76ad6efc/32d37/diagrams/data-science.png" width=800 height=300>
</div>

Resources for this course
========================================================

R for Data Science (R4DS): https://r4ds.had.co.nz
<div align="center">
<img src="https://r4ds.had.co.nz/cover.png">
</div>

***

- Lists and iteration: Ch. 19, 20, and 21
- Higher order functions: [Advanced R Ch. 9-11](https://adv-r.hadley.nz/fp.html)
- Parallelism: [furrr documentation](https://github.com/DavisVaughan/furrr)

Writing functions
============================================================
type: section

Motivation
===
- It's handy to be able to reuse your code and automate repetetive tasks
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
> df <- tibble(
+   a = rnorm(10), # 10 random numbers from N(0,1)
+   b = rnorm(10),
+   c = rnorm(10),
+   d = rnorm(10)
+ )
```

```r
> df$a <- (df$a - min(df$a, na.rm = TRUE)) / 
>   (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))
> df$b <- (df$b - min(df$b, na.rm = TRUE)) / 
>   (max(df$b, na.rm = TRUE) - min(df$a, na.rm = TRUE))
> df$c <- (df$c - min(df$c, na.rm = TRUE)) / 
>   (max(df$c, na.rm = TRUE) - min(df$c, na.rm = TRUE))
> df$d <- (df$d - min(df$d, na.rm = TRUE)) / 
>   (max(df$d, na.rm = TRUE) - min(df$d, na.rm = TRUE))
```

Example
===
(recall that `df$col` is the same as `df %>% pull(col)`)

```r
> df$a <- (df$a - min(df$a, na.rm = TRUE)) / 
>   (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))
> df$b <- (df$b - min(df$b, na.rm = TRUE)) / 
>   (max(df$b, na.rm = TRUE) - min(df$a, na.rm = TRUE))
> df$c <- (df$c - min(df$c, na.rm = TRUE)) / 
>   (max(df$c, na.rm = TRUE) - min(df$c, na.rm = TRUE))
> df$d <- (df$d - min(df$d, na.rm = TRUE)) / 
>   (max(df$d, na.rm = TRUE) - min(df$d, na.rm = TRUE))
```
- It looks like we're standardizing all the variables by their range so that they fall between 0 and 1
- But did you spot the mistake? The code runs with no errors...

Example
===

```r
> df2 = df %>%
>   mutate_all(
>     funs(
>       (.- min(.,na.rm=T)) /
>       (max(.,na.rm=T)-min(.,na.rm=T))
>       )
>   )
```
- This is better, but it's still ugly and hard to read, especially with all the periods and parentheses

Example
===

```r
> rescale_0_1 = function(x) {
>   (x - min(x))/(max(x) - min(x))
> }
> 
> df2 = df %>%
>   mutate_all(rescale_0_1)
```
- Much improved!
- The last two lines clearly say: replace all the columns with their rescaled versions
  - This is becasue the function name `rescale_0_1()` is informative and communicates what it does
  - If a user (or you a few weeks later) is curious about the specifics, they can check the function body
- Now we notice that `min()` is being computed twice in the function body, which is inefficient
- We are also not accounting for NAs

Example
===

```r
> rescale_0_1 = function(x) {
+   x_rng = range(x, na.rm=T) # returns the same result as c(min(x,na.rm=T), max(x,na.rm=T))
+   (x - x_rng[1])/(x_rng[2] - x_rng[1])
+ }
> 
> df2 = df %>%
+   mutate_all(rescale_0_1)
```
- Since we have a function, we can make the change in a single place and improve the efficiency of multiple parts of our code
- Bonus question: why use `range()` instead of getting and saving the results of `min()` and `max()` separately?

Example
===
We can also test our function in cases where we know what the output shoud be to make sure it works as intended before we let it loose on the real data

```r
> rescale_0_1(c(0,0,0,0,0,1))
[1] 0 0 0 0 0 1
> rescale_0_1(0:10)
 [1] 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
> rescale_0_1(-10:0)
 [1] 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
> x = c(0,1,runif(100))
> all(x == rescale_0_1(x))
[1] TRUE
```
- These tests are a critical part of writing good code! It is helpful to save your tests in a separate file and organize them as you go

Function syntax
===
To write a function, just wrap your code in some special syntax that tells it what variables will be passed in and what will be returned

```r
> rescale_0_1 = function(x) {
+   x_rng = range(x, na.rm=T) # returns the same result as c(min(x,na.rm=T), max(x,na.rm=T))
+   (x - x_rng[1])/(x_rng[2] - x_rng[1])
+ }
> 
> rescale_0_1(c(0,0,0,0,0,1))
[1] 0 0 0 0 0 1
> rescale_0_1(0:10)
 [1] 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
```
- The syntax is `FUNCTION_NAME <- function(ARGUMENTS...) { CODE }`
- Just like assigning a variable, except what you put into `FUNCTION_NAME` now isn't a data frame, vector, etc, it's a function object that gets created by the `function(..) {...}` syntax
- at any point in the body you can `return()` the value, or R will automatically return the result of the last line of code in the body that gets run

Function syntax
===
To add a named argument, add an `=` after you declare it as a variable and write in the default value that you would like that variable to take

```r
> rescale_0_1 = function(x, na.rm=TRUE) {
+   x_rng = range(x, na.rm=na.rm) # returns the same result as c(min(x,na.rm=T), max(x,na.rm=T))
+   (x - x_rng[1])/(x_rng[2] - x_rng[1])
+ }
> 
> rescale_0_1(c(0,0,0,0,0,1))
[1] 0 0 0 0 0 1
> rescale_0_1(0:10)
 [1] 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0
```
- All named arguments must go after positional arguments in the function declaration

Exercise: NAs in two vectors
===
- Write a function called both_na() that takes two vectors of the same length and returns the total number of positions that have an NA in both vectors
- Make a few vectors and test out your code

Answer: NAs in two vectors
===

```r
> both_na = function(x,y) {
+     x_na = is.na(x)
+     y_na = is.na(y)
+     sum(x_na & y_na)
+ }
> 
> test1 = c(1,2,3,NA,5)
> test2 = c(NA,2,3,NA,5)
> test3 = c(NA,2,NA,NA,5)
> 
> both_na(test1, test2)
[1] 1
> both_na(test1, test2)
[1] 1
> both_na(test2, test3)
[1] 2
> both_na(test3, test3)
[1] 3
```

Exercise: harmonic sum
===
Write a function that takes an integer `n` as an argument and returns the sum $\sum^n_{k=1} \frac{1}{k} = 1 + \frac{1}{2} + \frac{1}{3} \dots + \frac{1}{n}$

Answer: harmonic sum
===

Write a function that takes an integer `n` as an argument and returns the sum $\sum^n_{k=1} \frac{1}{k} = 1 + \frac{1}{2} + \frac{1}{3} \dots + \frac{1}{n}$


```r
> harmonic_sum = function(n) {
+     sum(1/(1:n))
+ }
```

Exercise: harmonic sum
===
Modify your function so it can calculate $\sum^n_{k=1} \frac{1}{k^r}$ where `r` is a number passed in by the user, but defaults to 1.

Answer: harmonic sum
===

Modify your function so it can calculate $\sum^n_{k=1} \frac{1}{k^r}$ where `r` is a number passed in by the user, but defaults to 1.


```r
> harmonic_sum = function(n,r=1) {
+     sum(1/(1:n)^r)
+ }
```
- Another reason functions are great is that if you want to change your code you only need to do it in one place.
- Always think about how to boil down your code into reusable functions

Note: functions are objects just like variables are
===

```r
> rescale_0_1
function(x, na.rm=TRUE) {
  x_rng = range(x, na.rm=na.rm) # returns the same result as c(min(x,na.rm=T), max(x,na.rm=T))
  (x - x_rng[1])/(x_rng[2] - x_rng[1])
}
<bytecode: 0x7ffb500cd428>
```
- As we've seen, they themselves can be passed as arguments to other functions

```r
> df2 = df %>% mutate_all(rescale_0_1)
```
- This is what **functional programming** means. The functions themselves are can be treated as regular objects like variables
- The name of the function is just what you call the "box" that the function (the code) lives in, just like variables names are names for "boxes" that contain data

Exercise: function factory
===
Without running this code, predict what the output will be:

```r
> f = function(x) {
>   y = x
>   function(y) {
>     y + x
>   }
> }
> f(1)(2)
```

Exercise: function factory
===
Without running this code, predict what the output will be:

```r
> f = function(x) {
+   y = x # this effectively does nothing
+   function(y) { # f returns a new function that takes an argument called y
+     y + x # here, y refers to the argument of this new function, not the y in the body of f
+   }
+ }
> g = f(1) # this is the same as: g = function(y) y + 1
> g(2)
[1] 3
> f(1)(2)
[1] 3
```

Exercise: exponent function factory
===
Write a function called `power()` that takes an argument `n` and returns a function that takes an argument x and computes `x^n`

- example use:

```r
> square = power(2)
> cube = power(3)
> square(2)
[1] 4
> cube(2)
[1] 8
```

Function operators
===
- As we've seen, functions can also take other functions as arguments
- We can use this to write functions that take functions, modify them, and return the modified function

```r
> set_na.rm = function(f, na.rm) {
+   function(x) {
+     f(x, na.rm=na.rm)
+   }
+ }
> mean_na.rm = set_na.rm(mean, na.rm=T)
> 
> x = c(rnorm(100), NA)
> mean_na.rm(x)
[1] -0.01115
```

Functional programming
===
We've disucssed a number of **higher-order functions** that either take functions as inputs, return functions as outputs, or both. 
<div align="center">
<img src="https://d33wubrfki0l68.cloudfront.net/1dff819e743f280bbab1c55f8f063e60b6a0d2fb/2269e/diagrams/fp.png">
</div>
- `mean()` is a "regular function". It takes data and returns data
- the `power()` function we made as an exercise is a "funciton factory". It takes data and returns a function (e.g. `square()` or `cube()`)
- `mutate_all` and friends are "functionals". They take a function (and data) and return data
- the `set_na.rm` function we made as an exercise is a "functional": it takes a function and returns a function

These categories are not explicit constructs that exist in R, they are just a way to think about the power of higher order functions. 

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
> absolute_value = function(x) {
+     if (x>0) {
+         x
+     } else {
+         -x
+     }
+ }
> absolute_value(2)
[1] 2
> absolute_value(-2)
[1] 2
```


Conditional Evaluation
=== 
- if_else is a function that condenses an if-else statement and is good when the condition and bodies of code are very short
- the first argument is the conditon, the second is what it returns when the condition is true, the third is what it returns when the condition is false

```r
> absolute_value = function(x) {
+     if_else(x>0, x, -x)
+ }
> absolute_value(2)
[1] 2
> absolute_value(-2)
[1] 2
```

Multiple conditions 
===

- You can evaluate multiple conditions with if...  else if... else

```r
> valence = function(x) {
+     if (x>0) {
+         "positive"
+     } else if (x<0) {
+         "negative"
+     } else {
+         "zero"
+     }
+ }
> valence(-12)
[1] "negative"
> valence(99)
[1] "positive"
> valence(0)
[1] "zero"
```

Exercise: greeting
===
Write a greeting function that says “good morning”, “good afternoon”, or “good evening”, depending on the  time of day of a `dttm` that the user passes in. (*Hint*: use an argument that defaults to `lubridate::now()`. That will make it easier to test your function. `lubridate::hour()` and `print()` may also be useful.)

Exercise: greeting
===
Write a greeting function that returns `“good morning”`, `“good afternoon”`, or `“good evening”`, depending on the  time of day of a `dttm` that the user passes in. (*Hint*: use an argument that defaults to `lubridate::now()`. That will make it easier to test your function. `lubridate::hour()` and `print()` may also be useful.)

```r
> library(lubridate)

Attaching package: 'lubridate'
The following object is masked from 'package:base':

    date
> 
> greet = function(time = now()) {
+   this_hour = hour(time)
+   if (this_hour < 12) {
+       "Good morning"
+   } else if (this_hour < 18) {
+       "Good afternoon"
+   } else {
+       "Good evening"
+   }
+ }
> 
> greet()
[1] "Good afternoon"
```

Conditions
===
- Conditions can be anything that evaluates to a single `TRUE` or `FALSE`

```r
> sun_or_moon = function(time = now()) {
+   this_hour = hour(time)
+   if (this_hour < 6 | this_hour > 18) {
+       "moon in the sky"
+   } else {
+       "sun in the sky"
+   }
+ }
> sun_or_moon(mdy_hm("Jan 2, 2000, 10:55pm"))
[1] "moon in the sky"
> sun_or_moon(mdy_hm("Sept 10, 1990, 09:12am"))
[1] "sun in the sky"
```
- but not a logical vector or an NA

```r
> sun_or_moon(c(
+   mdy_hm("Jan 2, 2000, 10:55pm"), 
+   mdy_hm("Sept 10, 1990, 09:12am")))
Warning in if (this_hour < 6 | this_hour > 18) {: the condition has length
> 1 and only the first element will be used
[1] "moon in the sky"
```

Motivation for lists and iteration
===

```r
> sun_or_moon(c(
+   mdy_hm("Jan 2, 2000, 10:55pm"), 
+   mdy_hm("Sept 10, 1990, 09:12am")))
Warning in if (this_hour < 6 | this_hour > 18) {: the condition has length
> 1 and only the first element will be used
[1] "moon in the sky"
```
- We see this doesn't work. How can we tell the function to iterate over multiple sets of arguments?

```r
> list(mdy_hm("Jan 2, 2000, 10:55pm"), 
+      mdy_hm("Sept 10, 1990, 09:12am")) %>%
+ map(sun_or_moon)
[[1]]
[1] "moon in the sky"

[[2]]
[1] "sun in the sky"
```
- To do this, we need to understand:
  - how to build and manipulate `list`s 
  - how to iterate with `purrr::map()` and its friends

Lists
===
type: section

Lists
===
- a `list` is like an atomic vector, except the elements don't have to be the same type of thing

```r
> a_vector = c(1,2,4,5)
> maybe_a_vector = c(1,2,"hello",5,TRUE)
> maybe_a_vector # R converted all of these things to strings!
[1] "1"     "2"     "hello" "5"     "TRUE" 
```
- you make them with list() and you can index them like vectors

```r
> a_list = list(1,2,"hello",5,TRUE)
> a_list[3:5]
[[1]]
[1] "hello"

[[2]]
[1] 5

[[3]]
[1] TRUE
```
- anything can go in lists, including vectors, other lists, data frames, etc.
- in fact, a data frame (or tibble) is actually just a list of named column vectors with an enforced constraint that all of the vectors have to be of the same length. That's why the `df$col` syntax works for data frames.

Seeing into lists
===
- use `str()` to dig into nested lists and other complicated objects

```r
> nested_list = list(a_list, 4, mtcars)
> str(nested_list)
List of 3
 $ :List of 5
  ..$ : num 1
  ..$ : num 2
  ..$ : chr "hello"
  ..$ : num 5
  ..$ : logi TRUE
 $ : num 4
 $ :'data.frame':	32 obs. of  11 variables:
  ..$ mpg : num [1:32] 21 21 22.8 21.4 18.7 18.1 14.3 24.4 22.8 19.2 ...
  ..$ cyl : num [1:32] 6 6 4 6 8 6 8 4 4 6 ...
  ..$ disp: num [1:32] 160 160 108 258 360 ...
  ..$ hp  : num [1:32] 110 110 93 110 175 105 245 62 95 123 ...
  ..$ drat: num [1:32] 3.9 3.9 3.85 3.08 3.15 2.76 3.21 3.69 3.92 3.92 ...
  ..$ wt  : num [1:32] 2.62 2.88 2.32 3.21 3.44 ...
  ..$ qsec: num [1:32] 16.5 17 18.6 19.4 17 ...
  ..$ vs  : num [1:32] 0 0 1 1 0 1 0 1 1 1 ...
  ..$ am  : num [1:32] 1 1 1 0 0 0 0 0 0 0 ...
  ..$ gear: num [1:32] 4 4 4 3 3 3 3 4 4 4 ...
  ..$ carb: num [1:32] 4 4 1 1 2 1 4 2 2 4 ...
```

Getting elements from a list
===
- you can also name the elements in a list

```r
> a_list = list(
+     first_number = 1,
+     second_number = 2,
+     a_string = "hello",
+     third_number = 5,
+     some_logical = TRUE)
```
- and then retrieve elements by name or position or using the tidyverse-friendly `pluck()`

```r
> a_list$a_string  # returns the element named "thrid_number"
[1] "hello"
> a_list[[3]] # returns the 3rd element
[1] "hello"
> a_list[3] # subsets the list, so returns a list of length 1 that contains a single element (the third)
$a_string
[1] "hello"
> a_list %>%
+   pluck("a_string")
[1] "hello"
```

Using elements in list
===
- if you use the `magrittr` package, you can operate on items in lists with the `%$%` operator (fun fact: the `%>%` operator originally came from `magrittr`)

```r
> library(magrittr)

Attaching package: 'magrittr'
The following object is masked from 'package:purrr':

    set_names
The following object is masked from 'package:tidyr':

    extract
> list(a=5, b=6) %$%
+   rnorm(10, mean=a, sd=b)
 [1]  6.2710020  4.4772246  4.8695029 12.7425710 -0.9694692 11.7420099
 [7]  7.3964019 -4.8065353  8.2724911  1.1030796
```
- `%$%` makes the elements of the list on the left-hand side accessible in bare-name form to the expression on the right-hand side so you don't have to type extra dollar signs:

```r
> x =  list(a=5, b=6)
> rnorm(10, mean=x$a, sd=x$b)
 [1]  1.8768779 11.8572446 -5.8988231  1.2900112 -1.4251316 13.8082495
 [7]  0.9512059 13.3736877  8.8985212  2.2465260
```

Exercise: getting things out of a list
===
Create this list in your workspace and write code to extract the element `"b"`.

```r
> x = list(
+   list("a", "b", "c"), 
+   "d", 
+   "e", 
+   6
+ )
```

Exercise: getting things out of a list
===
Create this list in your workspace and write code to extract the element `"b"`.

```r
> x = list(
+   list("a", "b", "c"), 
+   "d", 
+   "e", 
+   6
+ )
```


```r
> x[[1]][[2]]
[1] "b"
> 
> x %>% pluck(1,2) 
[1] "b"
```

Functions returning multiple values
===
- A function can only return a single object
- Often, however, it makes sense to group the calculation of two or more things you want to return within a single function
- You can put all of that into a list and then retrun a single list

```r
> min_max = function(x) {
+   x_sorted = sort(x)
+   list(
+     min = x_sorted[1],
+     max = x_sorted[length(x)]
+   )
+ }
```
- Why might this code be preferable to running `min()` and then `max()`?

Functions returning multiple values
===
- If you use the `zeallot` package, you can assign multiple values out of a list at once using the following syntax

```r
> min_max = function(x) {
+   x_sorted = sort(x)
+   list(
+     min = x_sorted[1],
+     max = x_sorted[length(x)]
+   )
+ }
> 
> library(zeallot)
> c(min_x, max_x) %<-% min_max(rnorm(10))
> min_x
[1] -0.7920266
> max_x
[1] 1.30356
```

Dots
===
- Besides positional and named arguments, functions in R can also be written to take a variable number of arguments!

```r
> sum(1)
[1] 1
> sum(1,2,3,6) # pass in as many as you want and it still works
[1] 12
```
- Obviously there aren't an infinite number of `sum()` functions to work with all the possible different numbers of arguments
- To write functions like this, use the dots `...` syntax

```r
> space_text = function(...) {
+   dots = list(...)
+   str_c(dots, collapse=" ")
+ } 
> 
> space_text("hello", "there,", "how", "are", "you")
[1] "hello there, how are you"
> space_text("fine,", "thanks")
[1] "fine, thanks"
```
- You can get whatever is passed to the function and save it as a (possibly named) list using `list(...)`

Dots
===
- This is useful when you want to pass on a bunch of arbitrary named arguments to another function, but hardcode one or more of them

```r
> mean_no_na = function(...) {
+   mean(..., na.rm=T)
+ }
> x = c(rnorm(100), NA)
> mean(x)
[1] NA
> mean_no_na(x)
[1] 0.06825539
> mean_no_na(x, trim=0.5)
[1] 0.03416817
> mean(x, trim=0.5, na.rm=T)
[1] 0.03416817
```
- Note how `trim` gets passed through as an argument to `mean()` even though it is not specified as an argument in the function declaration of `mean_no_na()`

Exercise: ggplot with default red points
===
- Use the dots to create a fully-featured function (call it `ggplot_redpoint()`), that works exactly like `ggplot()` except that it automatically adds a geom with red points.
- Test it out using data of your choice


Example: 

```r
> mtcars %>%
+ ggplot_redpoint(aes(mpg, hp)) 
```

![plot of chunk unnamed-chunk-45](functional-programming-figure/unnamed-chunk-45-1.png)

Answer: ggplot with default red points
===
- Use the dots to create a fully-featured function (call it `ggplot_point()`), that works exactly like `ggplot()` except that it automatically adds a geom with red points.
- Test it out using data of your choice

```r
> ggplot_redpoint = function(...) {
+   ggplot(...) + 
+     geom_point(color="red")
+ }
> 
> mtcars %>%
+ ggplot_redpoint(aes(mpg, hp)) 
```

![plot of chunk unnamed-chunk-46](functional-programming-figure/unnamed-chunk-46-1.png)

Exercise: sample_n_groups
===
- We know `sample_n()` takes `n` random rows from a data frame
- What if we want to sample all of the rows from `n` randomly selected groups?
- Write a function that takes a grouped data frame as well as any arguments that `sample_n` can take and returns all of the rows for n groups. (call it `sample_n_groups()`). Make sure it maintains all of the functionality of `sample_n()`.
- *Hint*: summarize, sample, join. Recall that dplyr joins automatically join on all matching column names

Answer: sample_n_groups
===
- Write a function that takes a grouped data frame as well as any arguments that `sample_n` can take and returns all of the rows for n groups. (call it `sample_n_groups()`). Make sure it maintains all of the functionality of `sample_n()`.
- *Hint*: summarize, sample, join. Recall that dplyr joins automatically join on all matching column names

```r
> sample_n_groups = function(tbl, ...) {
+   tbl %>% 
+     summarise() %>% 
+     sample_n(...) %>%
+     left_join(tbl) 
+ }
```

```r
> mtcars %>% 
+   group_by(cyl) %>% 
+   sample_n_groups(1)
Joining, by = "cyl"
# A tibble: 14 x 11
     cyl   mpg  disp    hp  drat    wt  qsec    vs    am  gear  carb
   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
 1     8  18.7  360    175  3.15  3.44  17.0     0     0     3     2
 2     8  14.3  360    245  3.21  3.57  15.8     0     0     3     4
 3     8  16.4  276.   180  3.07  4.07  17.4     0     0     3     3
 4     8  17.3  276.   180  3.07  3.73  17.6     0     0     3     3
 5     8  15.2  276.   180  3.07  3.78  18       0     0     3     3
 6     8  10.4  472    205  2.93  5.25  18.0     0     0     3     4
 7     8  10.4  460    215  3     5.42  17.8     0     0     3     4
 8     8  14.7  440    230  3.23  5.34  17.4     0     0     3     4
 9     8  15.5  318    150  2.76  3.52  16.9     0     0     3     2
10     8  15.2  304    150  3.15  3.44  17.3     0     0     3     2
11     8  13.3  350    245  3.73  3.84  15.4     0     0     3     4
12     8  19.2  400    175  3.08  3.84  17.0     0     0     3     2
13     8  15.8  351    264  4.22  3.17  14.5     0     1     5     4
14     8  15    301    335  3.54  3.57  14.6     0     1     5     8
```

Iteration
===
type:section

Map
===
- map is a function that takes a list (or vector) as its first argument and a function as its second argument
- recall that functions are objects just like anything else so you can pass them around to other functions
- map then runs that function on each element of the first argument, slaps 
the results together into a list, and returns that

```r
> times = list(mdy_hm("Jan 2, 2000, 10:55pm"), 
+              mdy_hm("Sept 10, 1990, 09:12am"))
> map(times, sun_or_moon)
[[1]]
[1] "moon in the sky"

[[2]]
[1] "sun in the sky"
```
- Equivalently:

```r
> list(mdy_hm("Jan 2, 2000, 10:55pm"), 
+      mdy_hm("Sept 10, 1990, 09:12am")) %>%
+ map(sun_or_moon)
[[1]]
[1] "moon in the sky"

[[2]]
[1] "sun in the sky"
```

Names are preserved through map
===
- if the input list (or vector) has names, the output will have elements with the same names

```r
> list(random_day = mdy_hm("Jan 2, 2000, 10:55pm"), 
+      my_birthday = mdy_hm("Sept 10, 1990, 09:12am")) %>%
+ map(sun_or_moon)
$random_day
[1] "moon in the sky"

$my_birthday
[1] "sun in the sky"
```
- you can also dynamically set names in a list using `set_names()`

```r
> list(mdy_hm("Jan 2, 2000, 10:55pm"), 
+      mdy_hm("Sept 10, 1990, 09:12am")) %>%
+   set_names(c("random_day", "my_birthday")) %>%
+ map(sun_or_moon)
$random_day
[1] "moon in the sky"

$my_birthday
[1] "sun in the sky"
```

Returning vectors
===
- `map()` typically returns a list (why?)
- but there are varaints that return vectors of different types

```r
> list(mdy_hm("Jan 2, 2000, 10:55pm"), 
+      mdy_hm("Sept 10, 1990, 09:12am")) %>%
+ map_chr(sun_or_moon)
[1] "moon in the sky" "sun in the sky" 
```


```r
> 1:10 %>%
+   map_dbl(harmonic_sum)
 [1] 1.000000 1.500000 1.833333 2.083333 2.283333 2.450000 2.592857
 [8] 2.717857 2.828968 2.928968
```

Returning a data frame
===

```r
> df <- tibble::tibble(
+   a = rnorm(10), 
+   b = rnorm(10),
+   c = rnorm(10),
+   d = rnorm(10)
+ ) %>%
+   mutate(d = if_else(row_number()==6, NA_real_, d)) # makes an element an NA
```


```r
> df %>%
+   map_df(mean)
# A tibble: 1 x 4
        a       b     c     d
    <dbl>   <dbl> <dbl> <dbl>
1 -0.0366 -0.0855 0.136    NA
```
- Why can we feed a data frame into `map()`?
- Notice the `c` column's mean is NA because we don't have a way to specify `na.rm=TRUE` to `mean()`

Composing functions inside map()
===
- How can we pass na.rm=TRUE to mean() inside of map?

- Define a new function with `na.rm=T` hardcoded in

```r
> mean_no_rm = function(x) mean(x, na.rm=TRUE)
> df %>% map_df(mean_no_rm)
# A tibble: 1 x 4
        a       b     c       d
    <dbl>   <dbl> <dbl>   <dbl>
1 -0.0366 -0.0855 0.136 -0.0329
```

- **Better**: define an anonymous function inside of map

```r
> df %>% map_df(function(x) mean(x, na.rm=TRUE))
# A tibble: 1 x 4
        a       b     c       d
    <dbl>   <dbl> <dbl>   <dbl>
1 -0.0366 -0.0855 0.136 -0.0329
```

***

- **Better**: use the `~ .` syntax to create an "anonymous" function inside of map. The `~` tells map that what follows is the body of a function (with no name) and a single argument called `.`

```r
> df %>% map_df(~ mean(., na.rm=TRUE))
# A tibble: 1 x 4
        a       b     c       d
    <dbl>   <dbl> <dbl>   <dbl>
1 -0.0366 -0.0855 0.136 -0.0329
```

- **Best**: any additional named arguments to map get passed on as named arguments to the function you want to call!

```r
> df %>% map_df(mean, na.rm=TRUE)
# A tibble: 1 x 4
        a       b     c       d
    <dbl>   <dbl> <dbl>   <dbl>
1 -0.0366 -0.0855 0.136 -0.0329
```

- In this case, the last option is the clearest, but in others it maybe a good idea to define a function outside of map or explicitly inside of map with the `function` syntax. It all depends on what makes the most sense for the situation.

Exercise: map practice
===
- Determine the type of each column in nycflights13::flights (?typeof).
- Generate 10 random normals for each of μ=-10, 0, 10, and 100 (?rnorm)

Answer: map practice
===

```r
> library(nycflights13)
> flights %>% map_chr(typeof)
          year          month            day       dep_time sched_dep_time 
     "integer"      "integer"      "integer"      "integer"      "integer" 
     dep_delay       arr_time sched_arr_time      arr_delay        carrier 
      "double"      "integer"      "integer"       "double"    "character" 
        flight        tailnum         origin           dest       air_time 
     "integer"    "character"    "character"    "character"       "double" 
      distance           hour         minute      time_hour 
      "double"       "double"       "double"       "double" 
> c(-10, 0, 10, 100) %>% map(~rnorm(10, mean=.))
[[1]]
 [1]  -9.214533  -8.724138  -9.602404  -9.096840  -8.420113  -9.639502
 [7] -11.447157 -10.964098 -10.076273 -11.018315

[[2]]
 [1] -0.004854499  1.115087252 -0.966051762  0.628494313  0.118039276
 [6]  0.693704490 -0.845620448 -0.486822643  1.648866121  0.398652519

[[3]]
 [1]  7.864193 10.343503 10.608225  8.480915 11.952779 10.390879 10.352182
 [8] 10.595261  9.449200 10.506442

[[4]]
 [1]  98.78429 100.40566 102.42777 100.65762 100.53431  99.68810 101.15723
 [8]  99.06313  99.33308  98.92483
```

Exercise: partial harmonic sum
===
- Combine your harmonic sum function with `map_dbl()` to create a new function that takes the same arguments but returns a vector of partial sums up to the full sum. i.e. instead of returning $\sum^n_{k=1} \frac{1}{k^r}$, it returns $\sum^1_{k=1} \frac{1}{k^r}, \sum^2_{k=1} \frac{1}{k^r}, \dots \sum^n_{k=1} \frac{1}{k^r}$. 
- Accomplish the same thing by modifing your old harmonic sum function. Do not use `map()`. The function `cumsum()` will be useful.

Answer: partial harmonic sum
===
- Combine your harmonic sum function with `map_dbl()` to create a new function that takes the same arguments but returns a vector of partial sums up to the full sum. i.e. instead of returning $\sum^n_{k=1} \frac{1}{k^r}$, it returns $\sum^1_{k=1} \frac{1}{k^r}, \sum^2_{k=2} \frac{1}{k^r}, \dots \sum^1_{k=n} \frac{1}{k^r}$. 
- Accomplish the same thing by modifing your old harmonic sum function. Do not use `map()`. The function `cumsum()` will be useful.
- Test both and make sure they return the same result


```r
> harmonic_partial_sums_map = function(n,r=1) {
+     1:n %>% map_dbl(harmonic_sum)
+ }
> 
> harmonic_partial_sums = function(n,r=1) {
+     cumsum(1/(1:n)^r)
+ }
> 
> all(harmonic_partial_sums_map(10) == harmonic_partial_sums(10))
[1] TRUE
```
- Both of these give the same answer. Make an argument for which is better.

Exercise: partial harmonic sum
===
- Now use map() with `harmonic_partial_sum()` (your function from the previous exercise) to make a list where each element is a vector of partial sums from 1 to 100, but for values of `r=1`, `r=2` and `r=3` (each element of the list corresponds to the partial sums for a different value of r when `n=100`).

Answer: partial harmonic sum
===
- Now use map() with `harmonic_partial_sum()` (your function from the previous exercise) to make a list where each element is a vector of partial sums from 1 to 100, but for values of `r=1`, `r=2` and `r=3` (each element of the list corresponds to the partial sums for a different value of r when `n=100`).

```r
> r_sums = c(1,2,3) %>% 
+   map(~harmonic_partial_sums(100, r=.))
```

Exercise: plotting partial harmonic sums
===
Use all of your skills to reproduce the following plot with as little code as possible:

*hint*: use `gather()`

![plot of chunk unnamed-chunk-64](functional-programming-figure/unnamed-chunk-64-1.png)

Exercise: plotting partial harmonic sums
===
Use all of your skills to reproduce the following plot with as little code as possible:


```r
> r_sums = c(1,2,3) %>% 
+     set_names(.,.) %>% # automatic naming!
+     map_df(~harmonic_partial_sums(100, r=.))
> 
> r_sums %>% 
+     mutate(n=row_number()) %>%
+     gather(r, partial_sum, -n) %>%
+ ggplot(aes(x=n, y=partial_sum, color=r)) +
+     geom_line()
```

![plot of chunk unnamed-chunk-65](functional-programming-figure/unnamed-chunk-65-1.png)

Group map
===
- Sometimes you want something done for each group in a data frame that can't be done with a summarize (for instance, if you want to return multiple rows for group instead of just one)
- For example, what if we wanted to sample `n` rows from each group? This is kind of a pain to do with regular `dplyr` verbs:

```r
> mtcars %>%
+   group_by(cyl) %>%
+   arrange(rnorm(n())) %>% # sort randomly within groups
+   mutate(keep = row_number() <= 2) %>% # keep first n rows
+   filter(keep)
# A tibble: 6 x 12
# Groups:   cyl [3]
    mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb keep 
  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <lgl>
1  15.5     8  318    150  2.76  3.52  16.9     0     0     3     2 TRUE 
2  13.3     8  350    245  3.73  3.84  15.4     0     0     3     4 TRUE 
3  26       4  120.    91  4.43  2.14  16.7     0     1     5     2 TRUE 
4  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4 TRUE 
5  24.4     4  147.    62  3.69  3.19  20       1     0     4     2 TRUE 
6  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1 TRUE 
```

Group map
===
- `group_map()` (`dplyr` v0.8+) makes this easier

```r
> mtcars %>%
+   group_by(cyl) %>%
+   group_map(~sample_n(.,2))
# A tibble: 6 x 11
# Groups:   cyl [3]
    cyl   mpg  disp    hp  drat    wt  qsec    vs    am  gear  carb
  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
1     4  30.4  95.1   113  3.77  1.51  16.9     1     1     5     2
2     4  22.8 108      93  3.85  2.32  18.6     1     1     4     1
3     6  18.1 225     105  2.76  3.46  20.2     1     0     3     1
4     6  17.8 168.    123  3.92  3.44  18.9     1     0     4     4
5     8  15.2 304     150  3.15  3.44  17.3     0     0     3     2
6     8  19.2 400     175  3.08  3.84  17.0     0     0     3     2
```

Exercise: right tool for the right job
===
Decide how you would tackle the following problems (no need to write the code):
- Run a separate regression model for each group in the data, returning coefficients for each variable
- Run a separate regression model for each group in the data, returning coefficients for one variable of interest
- Return the rows that have the maximum value within each group of a particular variable
- Calculate the mean of all numeric variables in the data

Answer: right tool for the right job
===
Decide how you would tackle the following problems:
- Run a separate regression model for each group in the data, returning coefficients for each variable

```r
> library(broom) # cleans up the output of regression models
> mtcars %>%
+   group_by(cyl) %>%
+   group_map(~lm(mpg~., data=.) %>% 
+               tidy())
# A tibble: 25 x 6
# Groups:   cyl [3]
     cyl term        estimate std.error statistic p.value
   <dbl> <chr>          <dbl>     <dbl>     <dbl>   <dbl>
 1     4 (Intercept)  60.9      180.       0.338    0.793
 2     4 disp         -0.345      0.469   -0.735    0.596
 3     4 hp           -0.0332     0.364   -0.0915   0.942
 4     4 drat         -4.19      46.4     -0.0903   0.943
 5     4 wt            4.48      29.7      0.151    0.905
 6     4 qsec         -0.106      7.82    -0.0136   0.991
 7     4 vs           -3.64      34.0     -0.107    0.932
 8     4 am           -6.33      45.2     -0.140    0.912
 9     4 gear          4.07      29.1      0.140    0.912
10     4 carb          3.22      28.2      0.114    0.928
# … with 15 more rows
```

Answer: right tool for the right job
===
- Run a separate regression model for each group in the data, returning the coefficients for one variable of interest

```r
> hp_beta = function(df) {
+   lm(mpg~., data=df) %>% 
+   tidy() %>%
+   filter(term=="hp") %>%
+   select(hp_beta=estimate)
+ }
> 
> mtcars %>%
+   group_by(cyl) %>%
+   group_map(~hp_beta(.))
# A tibble: 3 x 2
# Groups:   cyl [3]
    cyl hp_beta
  <dbl>   <dbl>
1     4 -0.0332
2     6 -0.0425
3     8  0.152 
```

Answer: right tool for the right job
===
- Return the rows that have the maximum value within each group of a particular variable

```r
> mtcars %>%
+   group_by(cyl) %>%
+   filter(mpg == max(mpg))
# A tibble: 3 x 11
# Groups:   cyl [3]
    mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
1  21.4     6 258     110  3.08  3.22  19.4     1     0     3     1
2  33.9     4  71.1    65  4.22  1.84  19.9     1     1     4     1
3  19.2     8 400     175  3.08  3.84  17.0     0     0     3     2
```

Answer: right tool for the right job
===
- Calculate the mean of all numeric variables in the data, by group

```r
> mtcars %>%
+   group_by(cyl) %>%
+   summarize_if(is.numeric, ~mean(.))
# A tibble: 3 x 11
    cyl   mpg  disp    hp  drat    wt  qsec    vs    am  gear  carb
  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
1     4  26.7  105.  82.6  4.07  2.29  19.1 0.909 0.727  4.09  1.55
2     6  19.7  183. 122.   3.59  3.12  18.0 0.571 0.429  3.86  3.43
3     8  15.1  353. 209.   3.23  4.00  16.8 0     0.143  3.29  3.5 
```

Mapping over multiple inputs
===
- So far we’ve mapped along a single input. But often you have multiple related inputs that you need iterate along in parallel. That’s the job of `pmap()`. For example, imagine you want to simulate some random normals with different means. You know how to do that with `map()`:

```r
> means <- list(5, 10, -3)
> means %>% 
+   map(rnorm, n = 5) %>%
+   glimpse()
List of 3
 $ : num [1:5] 6 3.09 5.89 5.69 5.26
 $ : num [1:5] 10.71 10.22 10.15 9.64 9.93
 $ : num [1:5] -3.06 -2.74 -1.66 -1.19 -2.63
```

Mapping over multiple inputs
===
- What if you also want to vary the standard deviation and `n`? One way to do that would be to iterate over the indices and index into vectors of means and sds:

```r
> mean = list(5, 10, -3)
> sd = list(1, 5, 10)
> n = list(1, 3, 5)
> 1:3 %>%
+   map(~rnorm(n[[.]], mean[[.]], sd[[.]])) %>% 
+   glimpse()
List of 3
 $ : num 4.2
 $ : num [1:3] 6.59 7.34 14.44
 $ : num [1:5] 1.72 -8.47 -3.84 -3.35 -13.08
```
- This looks like `C++`, not `R`. It's better to use `pmap()`

Mapping over multiple inputs
===

```r
> list(
+   n = list(1, 3, 5),
+   mean = list(5, 10, -3),
+   sd = list(1, 5, 10)
+ ) %>%
+ pmap(rnorm) %>% 
+ glimpse()
List of 3
 $ : num 3.2
 $ : num [1:3] 0.615 16.827 4.899
 $ : num [1:5] -8.8 6.22 8.68 -5.45 -1.24
```

<div align="center">
<img src="http://r4ds.had.co.nz/diagrams/lists-pmap-named.png">
</div>

Mapping over multiple inputs
===
- If you name the elements of the list, `pmap()` will match them to named arguments of the function you are calling

```r
> list(
>     to = c(1,2,3),
>     from = c(10,11,12)
>   ) %>%
>   pmap(seq) %>%
>   glimpse()
```
- Otherwise arguments will be passed positionally

```r
> list(
>     c(1,2,3),
>     c(10,11,12)
>   ) %>%
>   pmap(seq) %>%
>   glimpse()
```

Mapping over multiple inputs
===
- You can and should sometimes write functions inside of `pmap()`
- The same variants (e.g. `pmap_dbl()`) exist for `pmap()` as for `map()`

```r
> list(
+     c(1,2,3),
+     c(10,11,12)
+   ) %>%
+   pmap_dbl(function(x,y) {
+     seq(x,y) %>%
+       median()
+   })
[1] 5.5 6.5 7.5
```

Cross
=== 
- `cross()` gives you every combintion of the items in the list you pass it

```r
> list(
+     a = c(1,2,3),
+     b = c(10,11)
+   ) %>%
+   cross() %>%
+   glimpse()
List of 6
 $ :List of 2
  ..$ a: num 1
  ..$ b: num 10
 $ :List of 2
  ..$ a: num 2
  ..$ b: num 10
 $ :List of 2
  ..$ a: num 3
  ..$ b: num 10
 $ :List of 2
  ..$ a: num 1
  ..$ b: num 11
 $ :List of 2
  ..$ a: num 2
  ..$ b: num 11
 $ :List of 2
  ..$ a: num 3
  ..$ b: num 11
```

Cross
=== 
- `cross_df()` returns the result as a data frame

```r
> list(
+     a = c(1,2,3),
+     b = c(10,11)
+   ) %>%
+   cross_df()
# A tibble: 6 x 2
      a     b
  <dbl> <dbl>
1     1    10
2     2    10
3     3    10
4     1    11
5     2    11
6     3    11
```

Binding rows
===
- `map()` and `pmap()` sometimes give you back a list of data frames. To glue them all together you will need `bind_rows()`:

```r
> 1:3 %>%
+   map(~tibble(
+     rep = .,
+     sample = rnorm(5)
+   )) %>%
+   bind_rows()
# A tibble: 15 x 2
     rep sample
   <int>  <dbl>
 1     1 -0.762
 2     1  0.373
 3     1 -0.216
 4     1  0.867
 5     1  0.410
 6     2  0.163
 7     2 -0.113
 8     2 -0.596
 9     2 -0.285
10     2 -0.567
11     3  0.645
12     3 -0.103
13     3 -1.25 
14     3 -0.901
15     3 -0.366
```

Exercise: 
===
Generate a table like the one shown here by drawing 3 normally-distributed random numbers from every combination of the following parameters: `mean = c(-1, 0, 1)`, `sd = c(1,2)`.


```
# A tibble: 18 x 3
    sample  mean    sd
     <dbl> <dbl> <dbl>
 1 -0.503     -1     1
 2  0.820     -1     1
 3  0.621     -1     1
 4  0.364      0     1
 5  1.43       0     1
 6 -0.685      0     1
 7  1.23       1     1
 8  1.41       1     1
 9  0.991      1     1
10 -2.26      -1     2
11 -1.86      -1     2
12 -1.61      -1     2
13  0.926      0     2
14  0.395      0     2
15 -1.57       0     2
16 -0.682      1     2
17 -0.524      1     2
18 -0.0261     1     2
```

Exercise: 
===
Generate a table like the one shown here by drawing 3 normally-distributed random numbers from every combination of the following parameters: `mean = c(-1, 0, 1)`, `sd = c(1,2)`.


```r
> list(
+     mean = c(-1, 0, 1),
+     sd = c(1,2)
+   ) %>%
+   cross_df() %>%
+   pmap(function(mean, sd){
+     tibble(
+       sample = rnorm(mean=mean, sd=sd, n=3),
+       mean = mean,
+       sd = sd)
+   }) %>%
+   bind_rows() %>%
+   head()
# A tibble: 6 x 3
  sample  mean    sd
   <dbl> <dbl> <dbl>
1  0.484    -1     1
2 -0.682    -1     1
3  0.167    -1     1
4  0.238     0     1
5  0.584     0     1
6  1.80      0     1
```

Why not for loops?
===
- R also provides something called a `for` loop, which is common to many other languages as well. It looks like this:

```r
> ## generate 5 random numbers each from 3 normal distributions with different means
> samples = list(NA, NA, NA)
> means = c(1,10,100)
> for (i in 1:3) {
+   samples[[i]] = rnorm(5, means[i])
+ }
```
- The `for` loop is very flexible and you can do a lot with it
- `for` loops are unavoidable when the result of one iteration depends on the result of the last iteration

***

- Compare to the `map()`-style solution:

```r
> ## generate 5 random numbers each from 3 normal distributions with different means
> samples = c(1,10,100) %>%
+   map(~rnorm(5,.))
```
- Compared to the `for` loop, the `map()` syntax is much more concise and eliminates much of the "admin" code in the loop (setting up indices, initializing the list that will be filled in, indexing into the data structures)
- The `map()` syntax also encourages you to write a function for whatever is happening inside the loop. This means you have something that's reusable and easily testable, and your code will look cleaner
- Loops in R can be catastrophically slow due to the compexities of [copy-on-modify semantics](https://adv-r.hadley.nz/names-values.html). 

purrr Cheatsheet
===
<div align="center">
<img src="https://www.rstudio.com/wp-content/uploads/2018/08/purrr.png", height=1000, width=1400>
</div>

R in Parallel
===
type: section

Motivation
===
- Computers run programmers on processors
- Each processor can only do one thing at a time
- If there are many things to do, it will take a long time
- If the tasks are independent of each other, we can use multiple processors operating in *parallel* 
- parallel maps are implemented in the `furrr` pacakge

Example: Permutation test of a regression coefficient
===
- Let's say we're interested in the association of `mpg` and `hp` in the mtcars dataset (adjusted for ohter variables)
- We can run a linear model to estimate that association, assuming a linear trend

```r
> lm(mpg~., data=mtcars) %>%
+   broom::tidy() %>%
+   filter(term=="hp")
# A tibble: 1 x 5
  term  estimate std.error statistic p.value
  <chr>    <dbl>     <dbl>     <dbl>   <dbl>
1 hp     -0.0215    0.0218    -0.987   0.335
```
- Here we've used `lm()` to run a linear model- you can learn more about `lm()` and the formula interface it uses by looking at the help page
- We've also used `tidy()` from the `broom` package to clean up the output into a tibble.
- We could use this p-value, but since this is from the output of `lm()`, it is only valid if we believe that the noise in the model is actually normally distributed
- we can use a **permutation test** to get an estimate that does not rely on this assumption

Example: Permutation test of a regression coefficient
===
- The idea of the permutation test is that you shuffle the outcome differently to produce many different permutations of the data
- this destroys any associations with the outcome in the permuted datasets, but preserves the correlations within the covariates
- The analysis is then performed on the permuted data to get a set of coefficients that might have been estimated, given that there is no association
- the true estimated coefficient is thus compared to these. If it is of the same magnitude, we can say we are likely to have gotten such a value by chance even if there was no association

Example: Permutation test of a regression coefficient
===
- These are the functions we'll need

```r
> permute_mtcars_mpg = function() {
+   mtcars %>%
+     mutate(mpg = sample(mpg, nrow(mtcars)))
+ }
> 
> analyze = function(data) {
+   lm(mpg~., data=data) %>%
+     broom::tidy() %>%
+     filter(term=="hp") %>%
+     pull(estimate)
+ }
```


```r
> permute_mtcars_mpg() %>%
+   analyze()
[1] 0.04812343
> 
> permute_mtcars_mpg() %>%
+   analyze()
[1] 0.1313428
```

Example: Permutation test of a regression coefficient
===

```r
> library(tictoc) # for timing things easily
```


```r
> tic()
> perm_distribution = 1:5000 %>%
+   map_dbl(~permute_mtcars_mpg() %>%
+            analyze())
> toc()
13.315 sec elapsed
```
- We made 5000 coefficients, but it's slow!

Example: Permutation test of a regression coefficient
===
- If we parallelize across CPUs, we can go faster

```r
> library(furrr) # parallel maps
Loading required package: future

Attaching package: 'future'
The following objects are masked from 'package:zeallot':

    %->%, %<-%
> plan(multiprocess(workers=4)) # turns on parallel processing 
```

```r
> tic()
> perm_distribution = 1:5000 %>%
+   future_map_dbl(~permute_mtcars_mpg() %>%
+            analyze())
> toc()
3.884 sec elapsed
```

Example: Permutation test of a regression coefficient
===

```r
> beta = analyze(mtcars)
> 
> p_empirical = mean(abs(perm_distribution) >= abs(beta))
> 
> p_parametric = lm(mpg~., data=mtcars) %>%
+   broom::tidy() %>%
+   filter(term=="hp") %>%
+   pull(p.value)
```


```r
> p_empirical
[1] 0.671
> p_parametric
[1] 0.3349553
```
- under the assumptions of the permutation test, we can be even less sure there is an association.

Using future_map()
===
- `furrr` implements all of the functions from `purrr` with a prefix `future_` that allows them to be used in parallel. 
  - a "future" is a programming abstraction for a value that will be available in the future, which is one way of allowing for asynchronous (parallel) processes.
  - `furrr` uses futures under the hood to do what it does, therefore the naming convention
- The `future_` versions of `map()` work exactly the same as the standard `map()` versions.
- to turn on parallelism, simply put `plan(multiprocess(workers=K))` at the top of your script and all `future_` maps will be run in parallel across the number of workers that you specify
  - You can't exceed the number of available cores

Goals of this course
========================================================
By the end of the course you should be able to...

- write and test your own functions
- write code that evaluates conditionally
- create, manipulate, and inspect lists
- iterate functions over lists of arguments
- iterate in parallel

<div align="center">
<img src="https://d33wubrfki0l68.cloudfront.net/571b056757d68e6df81a3e3853f54d3c76ad6efc/32d37/diagrams/data-science.png" width=800 height=300>
</div>

Resources for this course
========================================================

R for Data Science (R4DS): https://r4ds.had.co.nz
<div align="center">
<img src="https://r4ds.had.co.nz/cover.png">
</div>

***

- Lists and iteration: Ch. 19, 20, and 21
- Higher order functions: [Advanced R Ch. 9-11](https://adv-r.hadley.nz/fp.html)
- Parallelism: [furrr documentation](https://github.com/DavisVaughan/furrr)
