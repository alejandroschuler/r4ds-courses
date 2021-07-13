Metaprogramming in R
========================================================
author: Alejandro Schuler, based on Advanced R by Hadley Wickham
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

- create and evaluate expressions
- splice expressions into others within and outside of functions
- call tidyverse functions dynamically from other functions
- write your own tidyverse-like functions

Packages: `rlang`, `lobstr`


<div align="center">
<img src="https://d33wubrfki0l68.cloudfront.net/571b056757d68e6df81a3e3853f54d3c76ad6efc/32d37/diagrams/data-science.png" width=800 height=300>
</div>

Resources for this course
========================================================

- [Advanced R ch. 17-21: metaprogramming](https://adv-r.hadley.nz/metaprogramming.html)
- [Advanced R ch. 22-24: performance testing](https://adv-r.hadley.nz/techniques.html)
- [Advanced R ch. 2: memory management](https://adv-r.hadley.nz/names-values.html)

Code as a data type
===
- we know that numbers, dates, factors and other data types can be represented in R
- **R code** can also be represented in R
  - code captured this way is called an *expression*. 
  - the process of creating an expression is called *quoting*
  - this code can then later be evaluated on-the-fly in the context of different environments
- `rlang::expr()` captures code the same way `"..."` captures text

```r
> expr(1+1)
1 + 1
```
- `rlang::enexpr()` is used to capture code passed into a function

```r
> f = function(x) {
+   enexpr(x)
+ }
> f(1+1)
1 + 1
```

Evaluating expressions
===
- expressions are evaluated with `eval()`

```r
> x = expr(1+1)
> eval(x)
[1] 2
```
- expressions are evaluated in the context of the current environment 

```r
> x = expr(1+y)
> y = 5
> eval(x)
[1] 6
> y = 1
> eval(x)
[1] 2
```

Evaluating expressions
===
- when `x` gets *evaluated*, R looks up any needed variables. 

```r
> y = 5
> x = expr(y)
> f = function(x) {
+   y = -5
+   eval(x)
+ }
> f(x)
[1] -5
```

***

- To tell R to look up needed variables in the environment that the expression was *created*, use `quo()` + `eval_tidy()` instead of `expr()` + `eval()` (and `enquo()` instead of `enexpr()`)
- expressions created this way are called *quosures* (they are actually an expression + a reference to an environment)
- this is generally what you want, so from here on out we'll use `quo()`

```r
> y = 5
> x = quo(y)
> f = function(x) {
+   y = -5
+   eval_tidy(x)
+ }
> f(x)
[1] 5
```

Explicitly denoting the evaluating environment
===
- `eval_tidy()` can also take a second argument that is interpreted as the environment in which to evaluate the quosure `x`. 

```r
> x = quo(a+b)
> df = tibble(
+   a = c(1,2,3),
+   b = -c(1,2,3)
+ )
> 
> eval_tidy(x, df)
[1] 0 0 0
```


Exercise: mutate_z
===




```r
> df
# A tibble: 3 x 2
      a     b
  <dbl> <dbl>
1     1    -1
2     2    -2
3     3    -3
```
Write a function called `mutate_z` that replicates the behavior seen here. You will have to:
- capture the second argument as an expression
- evaluate it in the context of the data
- save the result as a column of the data
- return the data

***


```r
> df %>% mutate_z(a+b)
# A tibble: 3 x 3
      a     b     z
  <dbl> <dbl> <dbl>
1     1    -1     0
2     2    -2     0
3     3    -3     0
> df %>% mutate_z(a^2)
# A tibble: 3 x 3
      a     b     z
  <dbl> <dbl> <dbl>
1     1    -1     1
2     2    -2     4
3     3    -3     9
> df %>% mutate_z(b+1)
# A tibble: 3 x 3
      a     b     z
  <dbl> <dbl> <dbl>
1     1    -1     0
2     2    -2    -1
3     3    -3    -2
```

Answer: mutate_z
===


```r
> mutate_z = function(df, mutation) {
+   df[["z"]] = eval_tidy(enquo(mutation), df)
+   df
+ }
```

Splicing into expressions
===
You may have noticed that this does not work:

```r
> add_1_to_col = function(df, x) {
+   df %>% mutate(added = x+1)
+ }
```


```r
> add_1_to_col(df, a)
Error: object 'a' not found
> add_1_to_col(df, "a")
Error in x + 1: non-numeric argument to binary operator
> add_1_to_col(df, quo(a))
Error: Base operators are not defined for quosures.
Do you need to unquote the quosure?

  # Bad:
  myquosure + rhs

  # Good:
  !!myquosure + rhs
```
we are getting closer...

Splicing into expressions
===

```r
> add_1_to_col = function(df, x) {
+   df %>% mutate(added = x+1)
+ }
```
- each argument to `mutate` is a named expression, so what we want to do is pass *an expression* on the right hand side of the `=`.
- The first step is to capture the user input as an expression

```r
> add_1_to_col = function(df, x) {
+   df %>% mutate(added = enquo(x)+1)
+ }
> add_1_to_col(df, b)
Error: Base operators are not defined for quosures.
Do you need to unquote the quosure?

  # Bad:
  myquosure + rhs

  # Good:
  !!myquosure + rhs
```
- but this doesn't work because now R doesn't know how to add 1 to an expression object!

Splicing into expressions
===

```r
> add_1_to_col = function(df, x) {
+   df %>% mutate(added = enquo(x)+1)
+ }
> add_1_to_col(df, b)
Error: Base operators are not defined for quosures.
Do you need to unquote the quosure?

  # Bad:
  myquosure + rhs

  # Good:
  !!myquosure + rhs
```
- what we need is a way to create a new expression that is the result of splicing in whatever expression `x` is into the expression `x+1`. 
- the `!!` operator does exactly that:

```r
> add_1_to_col = function(df, x) {
+   df %>% mutate(added = !!enquo(x)+1)
+ }
> add_1_to_col(df, b)
# A tibble: 3 x 3
      a     b added
  <dbl> <dbl> <dbl>
1     1    -1     0
2     2    -2    -1
3     3    -3    -2
```

Splicing into expressions
===
- To help us understand this, let's look at how code is represented
- Code is an *abstract syntax tree* (AST), which you can view using `lobstr::ast()`

```r
> ast(
+   x <- log(g(1+y))
+ )
█─`<-` 
├─x 
└─█─log 
  └─█─g 
    └─█─`+` 
      ├─1 
      └─y 
```


```r
> x <- expr(a + b + c)
> expr(f(!!x, y))
f(a + b + c, y)
```

***

- `!!` splices one AST into another
![](https://d33wubrfki0l68.cloudfront.net/6460470e66f39052d794dd365141a7cc0cb02e56/08719/diagrams/quotation/bang-bang.png)

Splicing into expressions
===
- Takeaway: if you want to use `dplyr` functions inside your own functions and you'd like to use column names as variables to your function, use this idiom:

```r
> f = function(..., x, ...) {
>   ...
>   dplyr_fun(... !!enquo(x) ...)
>   ...
> }
```
- This is the price you pay for being able to call `dplyr` functions so cleanly!

Quoting multiple expressions
===
You can get a list of expressions with `quos()` (or `enquos()` to capture a list of expression arguments to a function)

```r
> quos(x+y, x-z, w)
[[1]]
<quosure>
expr: ^x + y
env:  global

[[2]]
<quosure>
expr: ^x - z
env:  global

[[3]]
<quosure>
expr: ^w
env:  global
```

***

This is most useful with the dots:

```r
> my_mutate = function(df, ...) {
+   mutations = enquos(...)
+   new_var_names = names(mutations)
+   for (i in seq_along(mutations)) {
+     df[[new_var_names[i]]] = 
+       eval_tidy(mutations[[i]], df)
+   }
+   df
+ }
```


```r
> df %>% my_mutate(z = a+b, w = a^2)
# A tibble: 3 x 4
      a     b     z     w
  <dbl> <dbl> <dbl> <dbl>
1     1    -1     0     1
2     2    -2     0     4
3     3    -3     0     9
```

Splicing multiple expressions
===
- `!!!` is like `!!` but it takes a list of expressions and splices them into the arguments for a function


```r
> xs <- exprs(1, a, -b)
> expr(f(!!!xs, y))
f(1, a, -b, y)
```

![](https://d33wubrfki0l68.cloudfront.net/9e60ab46ad3c470bc27437b05fcd53fef781039d/17433/diagrams/quotation/bang-bang-bang.png)

***


```r
> mean_age_by = function(df, ...) {
+   df %>%
+     group_by(!!!enquos(...)) %>%
+     summarize(mean = mean(age))
+ }
```


```r
> gss_cat %>% 
+   mean_age_by(partyid, relig)
# A tibble: 125 x 3
# Groups:   partyid [10]
   partyid   relig                    mean
   <fct>     <fct>                   <dbl>
 1 No answer No answer                NA  
 2 No answer Don't know               29  
 3 No answer Inter-nondenominational  39  
 4 No answer Christian                53.6
 5 No answer Orthodox-christian       41  
 6 No answer Moslem/islam             32.8
 7 No answer Hinduism                 33.5
 8 No answer Buddhism                 41.5
 9 No answer Other                    NA  
10 No answer None                     43.4
# … with 115 more rows
```

