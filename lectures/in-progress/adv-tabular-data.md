Advanced Tabular Data Manipulation	
========================================================
author: Alejandro Schuler, adapted from Steve Bagley and based on R for Data Science by Hadley Wickham
date: July 2020
transition: none
width: 1680
height: 1050

- compute cumulative, offset, and sliding-window transformations
- simultaneously transform or summarize multiple columns
- transform between long and wide data formats
- combine multiple data frames using joins on one or more columns


<style>
.small-code pre code {
  font-size: 0.5em;
}
</style>

Window transformations
===
type: section

Offsets
===
incremental: true

- `lead()` and `lag()` return either forward- or backward-shifted versions of their input vectors

```r
lead(c(1, 2, 3))
[1]  2  3 NA
lag(c(1, 2, 3))
[1] NA  1  2
```

- This is most useful to compute offsets

```r
scores = tibble(
  day = c(1,2,3,4),
  score = c(72, 87, 94, 99)
)
```


```r
scores %>%
  mutate(daily_improvement = score - lag(score))
# A tibble: 4 x 3
    day score daily_improvement
  <dbl> <dbl>             <dbl>
1     1    72                NA
2     2    87                15
3     3    94                 7
4     4    99                 5
```

Exercise: multiple offsets
===
type: prompt


```r
scores = tibble(
  week = c(1,1,2,2,3,3,4,4),
  weekday = c("M","F","M","F","M","F","M","F"),
  score = c(72, 71, 80, 87, 94, 82, 99, 98)
)
```
Let's say you want to compute the improvement in scores within weekdays from one week to the next
(i.e. comparing week 1 Monday to week 2 Monday and week 1 Friday to week 2 Friday)

1. Figure out a way to do this using `lead()` or `lag()` in a single `mutate()` statement (hint: check the documentation).
2. Figure out a different way to do this with `group_by()` instead. Which seems more natural or robust to you? Why?
3. In both solutions you end up with some `NA`s since the "week 0" scores are unknown. If we wanted to assume that the week 0 scores would be the same as the week 1 scores, how might we modify our code to reflect that in order to make sure we don't get `NA`s in the result?

Rolling functions
===

- `slide_vec` applies a function using a sliding window across a vector (sometimes called a "rolling" function)


```r
library("slider")
numbers = c(9, 6, 8, 4, 7, 3, 8, 4, 2, 1, 3, 2)
slide_vec(numbers, sum, .after = 3, .step = 2)
 [1] 27 NA 22 NA 22 NA 15 NA  8 NA  5 NA
```

- the `.after` argument specifies how many elements after the "index" element are included in the rolling window
- `.step` specifies how to move from one index element to the next

***

![](https://www.oreilly.com/library/view/introduction-to-apache/9781491977132/assets/itaf_0406.png)

Rolling functions
===

```r
profits = tibble(
  day = c(1,2,3,4),
  profit = c(12, 40, 19, 13)
)
```

- `.before` is the backward-looking equivalent of `.after`


```r
profits %>%
  mutate(avg_2_day_profit = slide_vec(profit, mean, .before=1))
# A tibble: 4 x 3
    day profit avg_2_day_profit
  <dbl>  <dbl>            <dbl>
1     1     12             12  
2     2     40             26  
3     3     19             29.5
4     4     13             16  
```

Cumulative functions
===
incremental: true

- A cumulative function is like a rolling window function except that the window expands with each iteration instead of shifting over
- For example, `cumsum` takes the cumulative sum of a vector. See `?cumsum` for similar functions

```r
cumsum(c(1, 2, 3))
[1] 1 3 6
```


```r
profits = tibble(
  day = c(1,2,3,4),
  profit = c(12, 40, 19, 13)
)
```


```r
profits %>%
  mutate(best_day_to_date = cumsum(profit))
# A tibble: 4 x 3
    day profit best_day_to_date
  <dbl>  <dbl>            <dbl>
1     1     12               12
2     2     40               52
3     3     19               71
4     4     13               84
```

Turning any function into a cumulative function
===

- you can use `slider::slide_vec()` to turn any function that accepts a vector and returns a number into a cumulative function
- Use `.before=Inf` to achieve this

```r
library(slider) # imports slide_vec() function

profits %>%
  mutate(profit_to_date = slide_vec(profit, sum, .before=Inf))
# A tibble: 4 x 3
    day profit profit_to_date
  <dbl>  <dbl>          <dbl>
1     1     12             12
2     2     40             52
3     3     19             71
4     4     13             84
```

- it is usually better (computationally faster) to use a built-in cumulative function (e.g. `cumsum()`), but if none exists this is a great solution

Turning any function into a cumulative function
===
- If the function you want to transform takes additional arguments, you can give those to `slide_vec` and it will pass them through for you

```r
tibble(
  day = c(1,2,3,4),
  profit = c(12, 40, NA, 13)
) %>%
  mutate(profit_to_date = slide_vec(profit, mean, .before=Inf, na.rm=T))
# A tibble: 4 x 3
    day profit profit_to_date
  <dbl>  <dbl>          <dbl>
1     1     12           12  
2     2     40           26  
3     3     NA           26  
4     4     13           21.7
```

Exercise: maximum temperature to-date
===
type:prompt


```r
# install.packages('devtools')
library("devtools")
# install_github('Ram-N/weatherData')
library(weatherData)
library(lubridate)
data(SFO2013)
```


```r
sfo = SFO2013 %>%
  transmute( # mutate, but drops all other columns
    time = ymd_hms(Time), 
    temp = Temperature
  ) %>%
  group_by(day = date(time)) %>%
  summarize(max_temp = max(temp))
```

Starting with this `sfo` dataframe that I've prepared for you, add a column that has the maximum temperature in the past 30 days relative to the day indicated in that row

Column-wise operations
===
type: section

Repeating operations on columns
===

```r
df = tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  g = rbinom(10,1,0.5)
)
```

- Let's say we have these data and we want to take the mean of each column `a`, `b`, and `c` within the groups `g`. 
- One way to do it is with a normal summarize:


```r
df %>%
  group_by(g) %>%
  summarize(
    mean_a = mean(a),
    mean_b = mean(b),
    mean_b = mean(c)
  )
# A tibble: 2 x 3
      g mean_a  mean_b
  <int>  <dbl>   <dbl>
1     0  0.216 -0.815 
2     1  0.117  0.0888
```


***

- Copy-pasting code like this frequently creates errors and bugs that are hard to see
- It's even worse if you want to do multiple summaries


```r
df %>%
  group_by(g) %>%
  summarize(
    mean_a = mean(a),
    mean_b = mean(b),
    mean_b = mean(c),
    median_a = median(a),
    median_b = median(b),
    median_c = median(c)
  )
# A tibble: 2 x 6
      g mean_a  mean_b median_a median_b median_c
  <int>  <dbl>   <dbl>    <dbl>    <dbl>    <dbl>
1     0  0.216 -0.815     0.285    0.837  -1.12  
2     1  0.117  0.0888    0.117   -0.682   0.0888
```

Columnwise operations
===

- The solution is to use `across()` in your summarize:

```r
df %>%
  group_by(g) %>%
  summarize(across(c(a,b,c), mean))
# A tibble: 2 x 4
      g     a      b       c
  <int> <dbl>  <dbl>   <dbl>
1     0 0.216  0.702 -0.815 
2     1 0.117 -0.682  0.0888
```

- The first argument to `across()` is a selection of columns. You can use anything that would work in a `select()` here

*** 

- The second argument is the function you'd like to apply to each column. You can provide multiple functions by wrapping them in a "`list()`". Lists are like vectors but their elements can be of different types and each element has a name (more on that later)


```r
fns = list(
  avg=mean, 
  max=max
)

df %>%
  group_by(g) %>%
  summarize(across(c(a,b), fns))
# A tibble: 2 x 5
      g a_avg a_max  b_avg b_max
  <int> <dbl> <dbl>  <dbl> <dbl>
1     0 0.216 1.47   0.702 1.84 
2     1 0.117 0.118 -0.682 0.138
```

- see `?across()` to find out how to control how these columns get named in the output

Columnwise operations with where()
===

```r
df = tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = as.character(rnorm(10)),
  g = rbinom(10,1,0.5)
)
```

- Sometimes its nice to apply a transformation to all columns of a given type or all columns that match some condition
- `where()` is a handy function for that


```r
df %>%
  group_by(g) %>%
  summarize(across(where(is.numeric), mean))
# A tibble: 2 x 3
      g      a     b
  <int>  <dbl> <dbl>
1     0 -0.767 0.724
2     1 -0.718 0.757
```

Columnwise mutate
===

```r
df = tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = as.character(rnorm(10)),
  g = rbinom(10,1,0.5)
)
```

- `across()` works with any `dplyr` "verb", including `mutate()`:


```r
df %>%
  mutate(across(where(is.character), as.numeric))
# A tibble: 10 x 4
         a       b      c     g
     <dbl>   <dbl>  <dbl> <int>
 1  0.878  -0.805  -0.820     0
 2 -0.155   1.50   -0.722     0
 3  0.930  -0.0962  0.502     1
 4  1.40    0.825   0.512     0
 5  0.747   0.0787 -0.211     0
 6  0.831  -0.639  -1.13      0
 7 -0.647   0.249   0.323     0
 8  0.196   1.09   -1.88      1
 9  0.0718  1.51    0.636     1
10 -0.133  -1.52   -0.218     1
```

Columnwise mutate
===
- Most often you will need to write your own mini function to do what you want. To do that you put `~` before your expression and use `.` where you would put the name of the column


```r
df %>%
  mutate(across(
    a:b,                      # columns to mutate
    ~ . - lag(.),           # function to mutate them with
    .names = '{col}_offset'   # how to name the outputs
  ))
# A tibble: 10 x 6
         a       b c                      g a_offset b_offset
     <dbl>   <dbl> <chr>              <int>    <dbl>    <dbl>
 1  0.878  -0.805  -0.820265337678531     0  NA        NA    
 2 -0.155   1.50   -0.721511732343777     0  -1.03      2.31 
 3  0.930  -0.0962 0.501822169202019      1   1.08     -1.60 
 4  1.40    0.825  0.512415348015902      0   0.466     0.921
 5  0.747   0.0787 -0.211089934442458     0  -0.649    -0.746
 6  0.831  -0.639  -1.12973162033812      0   0.0841   -0.718
 7 -0.647   0.249  0.322591420158754      0  -1.48      0.888
 8  0.196   1.09   -1.87600695770898      1   0.843     0.841
 9  0.0718  1.51   0.636446932322054      1  -0.125     0.417
10 -0.133  -1.52   -0.217709985526627     1  -0.205    -3.02 
```

- Note that I've also used the `.names` argument to control how the output columns get named

Exercise: Filtering out or replacing NAs
===
type: prompt


```r
# install.packages('nycflights13')
library(nycflights13)
# glimpse(flights)
```

1. Replacing NAs with some other value is a very common operation so it gets its own function: `replace_na()`. Use this function to replace all `NA`s present in any numeric column of the flights dataset with `0`s
2. Instead of replacing these values, we may want to filter them all out instead. Starting with the original data, use `filter()` and `across()` to remove all rows from the data that have any `NA`s in any column. Recall that `is.na()` checks which elements in a vector are `NA`.

Tidy data: rearranging a data frame
============================================================
type: section

Messy data
============================================================
- Sometimes data are organized in a way that makes it difficult to compute in a vector-oriented way. For example, look at this dataset:


```r
head(relig_income, 2)
# A tibble: 2 x 11
  religion `<$10k` `$10-20k` `$20-30k` `$30-40k` `$40-50k` `$50-75k` `$75-100k`
  <chr>      <dbl>     <dbl>     <dbl>     <dbl>     <dbl>     <dbl>      <dbl>
1 Agnostic      27        34        60        81        76       137        122
2 Atheist       12        27        37        52        35        70         73
# … with 3 more variables: `$100-150k` <dbl>, `>150k` <dbl>, `Don't
#   know/refused` <dbl>
```

- the values in the table represent how many survey respondents were of each religion and income bracket.
- How could I use ggplot to make this plot? It's hard!



![plot of chunk unnamed-chunk-29](adv-tabular-data-figure/unnamed-chunk-29-1.png)

Messy data
===

```r
head(relig_income, 3)
# A tibble: 3 x 11
  religion `<$10k` `$10-20k` `$20-30k` `$30-40k` `$40-50k` `$50-75k` `$75-100k`
  <chr>      <dbl>     <dbl>     <dbl>     <dbl>     <dbl>     <dbl>      <dbl>
1 Agnostic      27        34        60        81        76       137        122
2 Atheist       12        27        37        52        35        70         73
3 Buddhist      27        21        30        34        33        58         62
# … with 3 more variables: `$100-150k` <dbl>, `>150k` <dbl>, `Don't
#   know/refused` <dbl>
```
- One of the problems with the way these data are formatted is that the income level, which is a property of a particular population, is stuck into the names of the columns. 
- Because of this, it's also not obvious what the numbers in the table mean (although we know they are counts)

Tidy data
===
- Here's a better way to organize the data:

```
# A tibble: 6 x 3
  religion income  count
  <chr>    <chr>   <dbl>
1 Agnostic <$10k      27
2 Agnostic $10-20k    34
3 Agnostic $20-30k    60
4 Agnostic $30-40k    81
5 Agnostic $40-50k    76
6 Agnostic $50-75k   137
```

This data is *tidy*. Tidy data follows three precepts:

1. each "variable" has its own dedicated column
2. each "observation" has its own row
3. each type of observational unit has its own data frame

In our example, each the **observations** are different **populations**, each of which has an associated _religion_, _income_, and _count_. These are the _variables_ that are measured about the population. 

Tidy data
===

Tidy data is easy to work with.


```r
tidy %>%
    filter(religion %in% c("Muslim", "Jewish", "Hindu", "Buddhist", "Catholic", "Atheist", "Mainline Prot")) %>%
ggplot() +
  geom_bar(aes(x=income, y=count, fill=religion), stat='identity')
```

![plot of chunk unnamed-chunk-32](adv-tabular-data-figure/unnamed-chunk-32-1.png)

Tidying data with pivot_longer()
===

- `tidyr::pivot_longer()` is the function you will most often want to use to tidy your data

```r
relig_income %>%
  pivot_longer(-religion, names_to="income", values_to="count") %>%
  head(3)
# A tibble: 3 x 3
  religion income  count
  <chr>    <chr>   <dbl>
1 Agnostic <$10k      27
2 Agnostic $10-20k    34
3 Agnostic $20-30k    60
```

- the three important arguments are: a) a selection of columns, b) the name of the new key column, and c) the name of the new value column

![](https://swcarpentry.github.io/r-novice-gapminder/fig/14-tidyr-fig3.png)

Exercise: cleaning GTEX
===
type:prompt


```r
gtex = read_tsv("https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/advance-2020/data/gtex.tissue.zscores.advance2020.txt")
```

Use the GTEX data to reproduce the following plot:

![plot of chunk unnamed-chunk-35](adv-tabular-data-figure/unnamed-chunk-35-1.png)

The individuals and genes of interest are `c('GTEX-11GSP', 'GTEX-11DXZ')` and `c('A2ML1', 'A3GALT2', 'A4GALT')`, respectively.

"Messy" data is relative and not always bad
===


```
# A tibble: 4 x 3
  mouse weight_before weight_after
  <dbl>         <dbl>        <dbl>
1     1          8.07        12.6 
2     2          8.74         8.28
3     3          6.72        11.4 
4     4         12.1          9.02
```


```r
wide_mice %>%
  mutate(weight_gain = weight_after - weight_before) %>%
  select(mouse, weight_gain)
# A tibble: 4 x 2
  mouse weight_gain
  <dbl>       <dbl>
1     1       4.55 
2     2      -0.457
3     3       4.63 
4     4      -3.04 
```

***


```
# A tibble: 8 x 3
  mouse time   weight
  <dbl> <chr>   <dbl>
1     1 before   8.07
2     1 after   12.6 
3     2 before   8.74
4     2 after    8.28
5     3 before   6.72
6     3 after   11.4 
7     4 before  12.1 
8     4 after    9.02
```


```r
long_mice %>%
  group_by(mouse) %>%
  mutate(weight_gain = weight - lag(weight)) %>%
  filter(!is.na(weight_gain)) %>%
  select(mouse, weight_gain)
# A tibble: 4 x 2
# Groups:   mouse [4]
  mouse weight_gain
  <dbl>       <dbl>
1     1       4.55 
2     2      -0.457
3     3       4.63 
4     4      -3.04 
```

Pivoting wider
============================================================
- As we saw with the mouse example, sometimes our data is actually easier to work with in the "wide" format. 
- wide data is also often nice to make tables for presentations, or is (unfortunately) sometimes required as input for other software packages
- To go from long to wide, we use `pivot_wider()`:


```r
long_mice
# A tibble: 8 x 3
  mouse time   weight
  <dbl> <chr>   <dbl>
1     1 before   8.07
2     1 after   12.6 
3     2 before   8.74
4     2 after    8.28
5     3 before   6.72
6     3 after   11.4 
7     4 before  12.1 
8     4 after    9.02
```

***


```r
long_mice %>% 
  pivot_wider(
    names_from = time, 
    values_from = weight
  )
# A tibble: 4 x 3
  mouse before after
  <dbl>  <dbl> <dbl>
1     1   8.07 12.6 
2     2   8.74  8.28
3     3   6.72 11.4 
4     4  12.1   9.02
```

Names prefix
============================================================


```r
long_mice
# A tibble: 8 x 3
  mouse time   weight
  <dbl> <chr>   <dbl>
1     1 before   8.07
2     1 after   12.6 
3     2 before   8.74
4     2 after    8.28
5     3 before   6.72
6     3 after   11.4 
7     4 before  12.1 
8     4 after    9.02
```

***

- you can use `names_prefix` to make variables names that are more clear in the result


```r
long_mice %>% 
  pivot_wider(
    names_from = time, 
    values_from = weight,
    names_prefix = "weight_"
  ) %>% head(2)
# A tibble: 2 x 3
  mouse weight_before weight_after
  <dbl>         <dbl>        <dbl>
1     1          8.07        12.6 
2     2          8.74         8.28
```

- this can also be used to _remove_ a prefix when going from wide to long:


```r
wide_mice %>% 
  pivot_longer(
    -mouse
    names_to = "time",
    values_to = "weight",
    names_prefix = "weight_"
  )
```

Exercise: creating a table
===
type: prompt

Use the GTEX data to make the following table:


```
[1] "Number of missing tissues:"
# A tibble: 2 x 4
# Groups:   Ind [2]
  Ind        A2ML1 A3GALT2 A4GALT
  <chr>      <int>   <int>  <int>
1 GTEX-11DXZ     1       0      0
2 GTEX-11GSP     0       0      0
```

The numbers in the table are the number of tissues in each individual for which the gene in question was missing.

Multi-pivoting
===
incremental: true


Have a look at the following data. How do you think we might want to make it look?


```r
data(anscombe)
anscombe
   x1 x2 x3 x4    y1   y2    y3    y4
1  10 10 10  8  8.04 9.14  7.46  6.58
2   8  8  8  8  6.95 8.14  6.77  5.76
3  13 13 13  8  7.58 8.74 12.74  7.71
4   9  9  9  8  8.81 8.77  7.11  8.84
5  11 11 11  8  8.33 9.26  7.81  8.47
6  14 14 14  8  9.96 8.10  8.84  7.04
7   6  6  6  8  7.24 6.13  6.08  5.25
8   4  4  4 19  4.26 3.10  5.39 12.50
9  12 12 12  8 10.84 9.13  8.15  5.56
10  7  7  7  8  4.82 7.26  6.42  7.91
11  5  5  5  8  5.68 4.74  5.73  6.89
```

The problem here is that the column names contain two pieces of data:

1. the coordinate (`x` or `y`)
2. some group that it came from (`1`, `2`, `3`, or `4`)

Our use of `pivot_longer` has so far been to extract a single piece of information from the column name

Multi-pivoting
===
- Turns out this problem can be tackled too:


```r
anscombe %>%
  pivot_longer(everything(),
    names_pattern = "(.)(.)", # a "regular expression"- we'll learn about these later
    names_to = c(".value", "group")
  ) 
# A tibble: 44 x 3
   group     x     y
   <chr> <dbl> <dbl>
 1 1        10  8.04
 2 2        10  9.14
 3 3        10  7.46
 4 4         8  6.58
 5 1         8  6.95
 6 2         8  8.14
 7 3         8  6.77
 8 4         8  5.76
 9 1        13  7.58
10 2        13  8.74
# … with 34 more rows
```

- We won't dig into this, but you should know that almost any kind of data-tidying problem can be solved with some combination of the functions in the `tidyr` package. 
- See the online [docs and vignettes](https://tidyr.tidyverse.org/articles/pivot.html) for more info

