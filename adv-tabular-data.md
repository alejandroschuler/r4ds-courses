Advanced Tabular Data
========================================================
author: Alejandro Schuler, based on R for Data Science by Hadley Wickham
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

- transform between "tidy" and "messy" data
- perform simultaneous multi-variable multi-function manipulations in dplyr
- perform manipulations that involve fixed or rolling windows of rows

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

- Tidy data: ch 12
- Multi-variable manipulations: [dplyr reference](https://dplyr.tidyverse.org/reference/scoped.html)
- Window manipulations: [dplyr reference](https://dplyr.tidyverse.org/articles/window-functions.html), 
[RcppRoll reference](https://cran.r-project.org/web/packages/RcppRoll/RcppRoll.pdf)

Cheatsheets: https://www.rstudio.com/resources/cheatsheets/

Tidy data: rearranging a data frame
============================================================
type: section

Reshaping data
============================================================
- Sometimes data are organized in a way that makes it difficult to compute in a vector-oriented way.
- Sometimes data elements are included in the column names.
- The `tidyr` package from `tidyverse` allows you to change the organization of
the data, keeping the content the same.
- we'll also use `lubridate` later on so let's load it now

```r
> library(tidyverse)
── Attaching packages ─────────────────────────────────────────────── tidyverse 1.2.1.9000 ──
✔ tibble  2.0.1       ✔ dplyr   0.8.0.1
✔ tidyr   0.8.2       ✔ stringr 1.4.0  
✔ readr   1.3.1       ✔ forcats 0.3.0  
✔ purrr   0.3.0       
── Conflicts ─────────────────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
> library(lubridate)

Attaching package: 'lubridate'
The following object is masked from 'package:base':

    date
```

Reshaping example
============================================================

```r
> messy <- read_csv("http://stanford.edu/~sbagley2/bios205/data/messy_data.csv")
Parsed with column specification:
cols(
  state = col_character(),
  January = col_double(),
  February = col_double()
)
> messy
# A tibble: 2 x 3
  state      January February
  <chr>        <dbl>    <dbl>
1 Alaska          10       10
2 California      15       45
```
- This data frame contains (made-up) data for two states
in two different months.
- This is sometimes called _wide_ format. Note that the month
is stored in the column name, not the content of the dataframe.
- If you add data for another month, you would create a new _column_.
- In R, it is often better to set up the data frame so that new
data are added as rows (_tall_ or _long_ format).

Messy vs tidy
============================================================

```r
> messy
# A tibble: 2 x 3
  state      January February
  <chr>        <dbl>    <dbl>
1 Alaska          10       10
2 California      15       45
```


```r
> tidy
# A tibble: 4 x 3
  state      month    avg_temp
  <chr>      <chr>       <dbl>
1 Alaska     January        10
2 California January        15
3 Alaska     February       10
4 California February       45
```
- We'll explain how to do this shortly, but for now convince yourself
that the same information appears in these two data frames.
- In `tidy`, the columns _describe_ the data; they don't _contain_ any data.

A visual representation
============================================================
<div align="center">
<img src="https://lgatto.github.io/2017_11_09_Rcourse_Jena/figs/gather_data_R.png">
</div>


Using gather
============================================================

```r
> tidy <- gather(messy, month, avg_temp, January:February)
> tidy
# A tibble: 4 x 3
  state      month    avg_temp
  <chr>      <chr>       <dbl>
1 Alaska     January        10
2 California January        15
3 Alaska     February       10
4 California February       45
```
The arguments to gather:

1. The data frame, here `messy`
2. The `key`, which is the name of the new column for the values from the old column names, here `month`
3. The `value`, which is the name of the new column for the data values, here `avg_temp`
4. The columns from which to gather the data. Anything that works in `select()` can be used here. The default is to use all the columns

Using gather
============================================================

```r
> tidy <- gather(messy, month, avg_temp, -state)
> tidy
# A tibble: 4 x 3
  state      month    avg_temp
  <chr>      <chr>       <dbl>
1 Alaska     January        10
2 California January        15
3 Alaska     February       10
4 California February       45
```
The arguments to gather:

1. The data frame, here `messy`
2. The `key`, which is the name of the new column for the values from the old column names, here `month`
3. The `value`, which is the name of the new column for the data values, here `avg_temp`
4. **The columns from which to gather the data. Anything that works in `select()` can be used here. The default is to use all the columns**

Exercise: using tidy data
============================================================
- Filter the rows of `tidy` for Alaska only.
- Separately, filter to get the rows for January.


Answer: using tidy data
============================================================

```r
> filter(tidy, state == "Alaska")
# A tibble: 2 x 3
  state  month    avg_temp
  <chr>  <chr>       <dbl>
1 Alaska January        10
2 Alaska February       10
```

```r
> filter(tidy, month == "January")
# A tibble: 2 x 3
  state      month   avg_temp
  <chr>      <chr>      <dbl>
1 Alaska     January       10
2 California January       15
```
- Try to do the same for `messy`. It's hard to do!
- `filter()` should be all that is necessary to select a subset of your data, but when it is in the messy format, you need to do a `select()` and do sometimes complicated operations on the column names


Exercise: tidying gene expression data
============================================================
- This is a data set that contains gene expression values for three genes in both untreated and treated samples.

```r
> gene <- read_csv("http://stanford.edu/~sbagley2/bios205/data/gene_exp1.csv")
Parsed with column specification:
cols(
  gene = col_character(),
  control = col_double(),
  treatment = col_double()
)
```
- Turn this into:

```
# A tibble: 6 x 3
  gene   group     expression_level
  <chr>  <chr>                <dbl>
1 ABC123 control                  0
2 DEF234 control                 10
3 GKK7   control                 12
4 ABC123 treatment                1
5 DEF234 treatment                3
6 GKK7   treatment               13
```


Answer: gene expression data
============================================================

```r
> gene %>%
+   gather(group, expression_level, control:treatment)
# A tibble: 6 x 3
  gene   group     expression_level
  <chr>  <chr>                <dbl>
1 ABC123 control                  0
2 DEF234 control                 10
3 GKK7   control                 12
4 ABC123 treatment                1
5 DEF234 treatment                3
6 GKK7   treatment               13
```


Exercise: compute change in gene expression
============================================================
- Compute the change (`treatment - control`) for each sample
- Hint: think about what shape the data should have to enable this computation.


Answer: compute change in gene expression
============================================================
- We use the data in the original format because then we can subtract the columns.

```r
> gene %>%
+   mutate(change = treatment - control)
# A tibble: 3 x 4
  gene   control treatment change
  <chr>    <dbl>     <dbl>  <dbl>
1 ABC123       0         1      1
2 DEF234      10         3     -7
3 GKK7        12        13      1
```


Exercise: plot the treatment expression values by gene name
============================================================
- Produce this plot: treatment value (y-axis) vs gene name (x-axis)

![plot of chunk unnamed-chunk-15](adv-tabular-data-figure/unnamed-chunk-15-1.png)


Answer: plot the treatment expression values by gene name
============================================================

```r
> gene %>%
+ ggplot(aes(gene, treatment)) + 
+   geom_col()
```

![plot of chunk unnamed-chunk-16](adv-tabular-data-figure/unnamed-chunk-16-1.png)


Exercise: filtering the gene expression data
============================================================
- Produce a data frame that includes all data where the control
or treatment expression value is above 5.


Answer: filtering the gene expression data
============================================================

```r
> gene %>%
+ gather(group, expression_level, -gene) %>%
+   filter(expression_level > 5)
# A tibble: 3 x 3
  gene   group     expression_level
  <chr>  <chr>                <dbl>
1 DEF234 control                 10
2 GKK7   control                 12
3 GKK7   treatment               13
```
- Note that this computation is very easy to do using the tidy data
version (from `gather`). In this format, it is single comparison
that works for both treatment and control groups.
- Note the use of chaining.


Example: what is the minimum expression level for each gene?
============================================================

```r
> gene %>% 
+   gather(group, expression_level, control, treatment) %>%
+   group_by(gene) %>%
+   filter(expression_level == min(expression_level))
# A tibble: 3 x 3
# Groups:   gene [3]
  gene   group     expression_level
  <chr>  <chr>                <dbl>
1 ABC123 control                  0
2 GKK7   control                 12
3 DEF234 treatment                3
```


Exercise: spread, the opposite of gather
============================================================
- Suppose you started with the data in tidy format.

```r
> gene_tidy <- gene %>% 
+   gather(group, expression_level, control:treatment)
```
How would you convert it to the wide format?
- You will need to read the R for Data Science reference or look at the cheat sheet: [https://tidyr.tidyverse.org/](https://tidyr.tidyverse.org/)

Answer: spread, the opposite of gather
============================================================

```r
> gene_tidy %>%
+   spread(group, expression_level)
# A tibble: 3 x 3
  gene   control treatment
  <chr>    <dbl>     <dbl>
1 ABC123       0         1
2 DEF234      10         3
3 GKK7        12        13
```
- `spread` is the opposite of `gather` and constructs _wide_ data frames.
- The second argument defines the column in the tall format to be
used to make new column names.
- The third argument defines the column in the tall format to be
used as the source of data for those new columns.

Answer: spread, the opposite of gather
============================================================
<div align="center">
<img src="https://datacarpentry.org/R-ecology-lesson/img/spread_data_R.png">
</div>

Example of getting information out of column names
============================================================
First, create a small dataframe.

```r
> (d <- tibble(gene = c("abc123", "abc123", "def234", "def234"),
+ d1_g1 = c(1, 3, 6, 2),
+ d1_g2 = c(3, 4, 6, 5),
+ d2_g1 = c(10, 20, 30, 40),
+ d2_g2 = c(1, 1, 1, 2)))
# A tibble: 4 x 5
  gene   d1_g1 d1_g2 d2_g1 d2_g2
  <chr>  <dbl> <dbl> <dbl> <dbl>
1 abc123     1     3    10     1
2 abc123     3     4    20     1
3 def234     6     6    30     1
4 def234     2     5    40     2
```


Convert from wide to tall format
============================================================

```r
> (d2 <- d %>% gather(condition, expression_level, -gene))
# A tibble: 16 x 3
   gene   condition expression_level
   <chr>  <chr>                <dbl>
 1 abc123 d1_g1                    1
 2 abc123 d1_g1                    3
 3 def234 d1_g1                    6
 4 def234 d1_g1                    2
 5 abc123 d1_g2                    3
 6 abc123 d1_g2                    4
 7 def234 d1_g2                    6
 8 def234 d1_g2                    5
 9 abc123 d2_g1                   10
10 abc123 d2_g1                   20
11 def234 d2_g1                   30
12 def234 d2_g1                   40
13 abc123 d2_g2                    1
14 abc123 d2_g2                    1
15 def234 d2_g2                    1
16 def234 d2_g2                    2
```


Getting data out of the condition column
============================================================
The condition column has the compressed format for the values: `d1_g1` means "day 1, group 1". We need to split the string apart at the `"_"`.


```r
> (d3 <- d2 %>% separate(condition, into = c("day", "group"), sep = "_"))
# A tibble: 16 x 4
   gene   day   group expression_level
   <chr>  <chr> <chr>            <dbl>
 1 abc123 d1    g1                   1
 2 abc123 d1    g1                   3
 3 def234 d1    g1                   6
 4 def234 d1    g1                   2
 5 abc123 d1    g2                   3
 6 abc123 d1    g2                   4
 7 def234 d1    g2                   6
 8 def234 d1    g2                   5
 9 abc123 d2    g1                  10
10 abc123 d2    g1                  20
11 def234 d2    g1                  30
12 def234 d2    g1                  40
13 abc123 d2    g2                   1
14 abc123 d2    g2                   1
15 def234 d2    g2                   1
16 def234 d2    g2                   2
```
- `separate()` (from `tidyr`) does exactly this (its opposite is `unite()`)

Clean up the data: strings
============================================================
If we want to get rid of the `"d"` and `"g"` prefixes, we need to
do some string manipulation, replacing those patterns with an empty string.

```r
> (d4 <- d3 %>% mutate(
+     day = str_replace(day, "d", ""), 
+     group = str_replace(group, "g", "")))
# A tibble: 16 x 4
   gene   day   group expression_level
   <chr>  <chr> <chr>            <dbl>
 1 abc123 1     1                    1
 2 abc123 1     1                    3
 3 def234 1     1                    6
 4 def234 1     1                    2
 5 abc123 1     2                    3
 6 abc123 1     2                    4
 7 def234 1     2                    6
 8 def234 1     2                    5
 9 abc123 2     1                   10
10 abc123 2     1                   20
11 def234 2     1                   30
12 def234 2     1                   40
13 abc123 2     2                    1
14 abc123 2     2                    1
15 def234 2     2                    1
16 def234 2     2                    2
```
- `str_replace()` from `stringr` is useful here.

Clean up the data: numbers
===========================================================
The values in the `day` and `group` columns are strings, not numbers, so might be good idea to convert:

```r
> (d5 <- mutate(d4, 
+               day = as.integer(day), 
+               group = as.integer(group)))
# A tibble: 16 x 4
   gene     day group expression_level
   <chr>  <int> <int>            <dbl>
 1 abc123     1     1                1
 2 abc123     1     1                3
 3 def234     1     1                6
 4 def234     1     1                2
 5 abc123     1     2                3
 6 abc123     1     2                4
 7 def234     1     2                6
 8 def234     1     2                5
 9 abc123     2     1               10
10 abc123     2     1               20
11 def234     2     1               30
12 def234     2     1               40
13 abc123     2     2                1
14 abc123     2     2                1
15 def234     2     2                1
16 def234     2     2                2
```
- note that now `day` and `group` are `<int>`s. 

All in one pipe
===

```r
> d %>% 
+   gather(condition, expression_level, -gene) %>%
+   separate(condition, into = c("day", "group"), sep = "_") %>%
+   mutate(
+     day = day %>% str_replace("d", "") %>% as.integer(), 
+     group = group %>% str_replace("g", "") %>% as.integer())
# A tibble: 16 x 4
   gene     day group expression_level
   <chr>  <int> <int>            <dbl>
 1 abc123     1     1                1
 2 abc123     1     1                3
 3 def234     1     1                6
 4 def234     1     1                2
 5 abc123     1     2                3
 6 abc123     1     2                4
 7 def234     1     2                6
 8 def234     1     2                5
 9 abc123     2     1               10
10 abc123     2     1               20
11 def234     2     1               30
12 def234     2     1               40
13 abc123     2     2                1
14 abc123     2     2                1
15 def234     2     2                1
16 def234     2     2                2
```

tidyr cheat sheet (2nd page of data import cheat sheet)
=== 
<div align="center">
<img src="https://ugoproto.github.io/ugo_r_doc/img/base_r_cs/data_importb.png" height=1000 width=1400>
</div>

Multi-variable/function operations in dplyr
===
type: section

Multi-variable/function operations in dplyr
===
- In our discussion about dates we used a long mutate statement to convert date-time components into `dttm`s

```r
> library(nycflights13)
> flights_fixed = flights %>%
+   mutate(arr_time_hour = str_sub(arr_time, 1, -3) %>% as.numeric(),
+          arr_time_min = str_sub(arr_time, -2, -1) %>% as.numeric(),
+          sched_arr_time_hour = str_sub(sched_arr_time, 1, -3) %>% as.numeric(),
+          sched_arr_time_min = str_sub(sched_arr_time, 1, -1) %>% as.numeric(),
+          dep_time_hour = str_sub(dep_time, 1, -3) %>% as.numeric(),
+          dep_time_min = str_sub(sched_dep_time, -2, -1) %>% as.numeric(),
+          sched_dep_time_hour = str_sub(sched_dep_time, 1, -3) %>% as.numeric(),
+          sched_dep_time_min = str_sub(sched_dep_time, -2, -1) %>% as.numeric())
```
- Copy-pasting code like this frequently creates errors and bugs that are hard to see

Multi-variable/function operations in dplyr
===
- In our discussion about dates we used a long mutate statement to convert date-time components into `dttm`s

```r
> library(nycflights13)
> flights_fixed = flights %>%
+   mutate(arr_time_hour = str_sub(arr_time, 1, -3) %>% as.numeric(),
+          arr_time_min = str_sub(arr_time, -2, -1) %>% as.numeric(),
+          sched_arr_time_hour = str_sub(sched_arr_time, 1, -3) %>% as.numeric(),
+          sched_arr_time_min = str_sub(sched_arr_time, -2, -1) %>% as.numeric(),
+          dep_time_hour = str_sub(dep_time, 1, -3) %>% as.numeric(),
+          dep_time_min = str_sub(dep_time, -2, -1) %>% as.numeric(),
+          sched_dep_time_hour = str_sub(sched_dep_time, 1, -3) %>% as.numeric(),
+          sched_dep_time_min = str_sub(sched_dep_time, -2, -1) %>% as.numeric())
```
- Copy-pasting code like this frequently creates errors and bugs that are hard to see

Scoped mutate
===
- We can do better by using `mutate_at()`

```r
> flights_fixed = flights %>%
+   mutate_at(vars(arr_time, sched_arr_time, dep_time, sched_dep_time),
+             list(hour = ~ str_sub(., 1, -3) %>% as.numeric(),
+                  min = ~ str_sub(., -2, -1) %>% as.numeric()))
```

```r
> flights_fixed %>% select(ends_with("_hour"), ends_with("_min"), -time_hour)
# A tibble: 336,776 x 8
   arr_time_hour sched_arr_time_… dep_time_hour sched_dep_time_…
           <dbl>            <dbl>         <dbl>            <dbl>
 1             8                8             5                5
 2             8                8             5                5
 3             9                8             5                5
 4            10               10             5                5
 5             8                8             5                6
 6             7                7             5                5
 7             9                8             5                6
 8             7                7             5                6
 9             8                8             5                6
10             7                7             5                6
# … with 336,766 more rows, and 4 more variables: arr_time_min <dbl>,
#   sched_arr_time_min <dbl>, dep_time_min <dbl>, sched_dep_time_min <dbl>
```

Scoped mutate
===

```r
> flights_fixed = flights %>%
>   mutate_at(
>     vars(arr_time, sched_arr_time, dep_time, sched_dep_time),
>     list(hour = ~ str_sub(., 1, -3) %>% as.numeric(),
>          min = ~ str_sub(., -2, -1) %>% as.numeric()))
```
- `mutate_at()` takes two arguments
  - the variables you want to apply the functions to (wrapped in `vars()`)
  - the functions you want to apply to the variables (wrapped in `list()`)
- it then applies each function to each variable
- In the functions, use `.` as a stand-in for the variable and `~` as a stand-in for `f = function(.) { ... }`
- Give the functions appropriate names (e.g. `hour`, `min`). These will be appended as suffixes to the names of the resulting columns. 

Scoped mutate
===
- you can also use anything that would work in `select()` inside of `vars()`

```r
> flights_fixed = flights %>%
>   mutate_at(
>     vars(ends_with("time")),
>     list(hour = ~str_sub(., 1, -3) %>% as.numeric(),
>          min = ~str_sub(., -2, -1) %>% as.numeric()))
```

Scoped mutate
===
- Istead of `vars()`, you can also use a character vector

```r
> times = c("arr_time", "sched_arr_time", "dep_time", "sched_dep_time")
> flights_fixed = flights %>%
>   mutate_at(
>     times,
>     list(hour = ~str_sub(., 1, -3) %>% as.numeric(),
>          min = ~str_sub(., -2, -1) %>% as.numeric()))
```
- This is useful when some other code will generate the variables

Scoped mutate
===
- if you only pass in one function and don't name it, `mutate_at()` replaces each variable in `vars()` with the result of applying that function to it
- this code thus translates each character vector to a vector of periods

```r
> flights %>%
+   mutate_at(
+     vars(ends_with("time")),
+     list(~hours(str_sub(., 1, -3) %>% as.numeric()) +
+          minutes(str_sub(., -2, -1) %>% as.numeric())))
# A tibble: 336,776 x 19
    year month   day dep_time  sched_dep_time dep_delay arr_time 
   <int> <int> <int> <S4: Per> <S4: Period>       <dbl> <S4: Per>
 1  2013     1     1 5H 17M 0S 5H 15M 0S              2 8H 30M 0S
 2  2013     1     1 5H 33M 0S 5H 29M 0S              4 8H 50M 0S
 3  2013     1     1 5H 42M 0S 5H 40M 0S              2 9H 23M 0S
 4  2013     1     1 5H 44M 0S 5H 45M 0S             -1 10H 4M 0S
 5  2013     1     1 5H 54M 0S 6H 0M 0S              -6 8H 12M 0S
 6  2013     1     1 5H 54M 0S 5H 58M 0S             -4 7H 40M 0S
 7  2013     1     1 5H 55M 0S 6H 0M 0S              -5 9H 13M 0S
 8  2013     1     1 5H 57M 0S 6H 0M 0S              -3 7H 9M 0S 
 9  2013     1     1 5H 57M 0S 6H 0M 0S              -3 8H 38M 0S
10  2013     1     1 5H 58M 0S 6H 0M 0S              -2 7H 53M 0S
# … with 336,766 more rows, and 12 more variables: sched_arr_time <S4:
#   Period>, arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
#   origin <chr>, dest <chr>, air_time <S4: Period>, distance <dbl>,
#   hour <dbl>, minute <dbl>, time_hour <dttm>
```

Scoped mutate
===
- If that function has a single name, you don't need to wrap it in `list` or use the `.`

```r
> flights %>%
+   mutate_at(
+     vars(ends_with("time")),
+     as.character) # same as list(as.character(.))
# A tibble: 336,776 x 19
    year month   day dep_time sched_dep_time dep_delay arr_time
   <int> <int> <int> <chr>    <chr>              <dbl> <chr>   
 1  2013     1     1 517      515                    2 830     
 2  2013     1     1 533      529                    4 850     
 3  2013     1     1 542      540                    2 923     
 4  2013     1     1 544      545                   -1 1004    
 5  2013     1     1 554      600                   -6 812     
 6  2013     1     1 554      558                   -4 740     
 7  2013     1     1 555      600                   -5 913     
 8  2013     1     1 557      600                   -3 709     
 9  2013     1     1 557      600                   -3 838     
10  2013     1     1 558      600                   -2 753     
# … with 336,766 more rows, and 12 more variables: sched_arr_time <chr>,
#   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
#   origin <chr>, dest <chr>, air_time <chr>, distance <dbl>, hour <dbl>,
#   minute <dbl>, time_hour <dttm>
```

Replacing NAs
===
- Replacing NAs with some other value is a very common operation so it gets its own function: `replace_na()`
- this code replaces all NAs in the `arr_delay` column with 0s.

```r
> flights %>%
>   mutate(arr_delay = replace_na(arr_delay, 0))
```
- You can replace NAs in multiple colummns with the same value using the scoped `mutate()` variants:

```r
> flights %>%
>   mutate_at(
>     vars(ends_with("_delay")), # in any of these columns, 
>     list(~replace_na(.,0)))     # replace NA with 0
```
- You can also pipe the whole data frame to `replace_na()` to get it to operate on every column in a named list (like a vector) that you provide.

```r
> flights %>%
>   replace_na(list(
>     arr_delay = 0, # replace NAs in arr_delay with 0
>     dep_delay = 5  # replace NAs in dep_delay with 5
>   ))
```
- `recode()` does this more generally for non-NA values

Scoped filter
===
- What if we wanted to get all the rows with any NA value in any hour column? 
- This requires a filter, but we want to filter on several columns at once

```r
> flights %>%
>   filter(is.na(arr_time_hour) | is.na(dep_time_hour) | 
>          is.na(sched_arr_time_hour) | is.na(sched_dep_time_hour))
```
- This is tedious. We can use the `_at` variant of `filter()`, which is `filter_at()`

```r
> flights %>%
>   filter_at(
>     vars(ends_with("_hour")), 
>     any_vars(is.na(.))
>   )
```
- The first argument is again a set of variables to apply the condition to, wrapped in `vars()`
- The second is a predicate function (returns T/F), wrapped either in `any_vars()` or `all_vars()`

```r
> filter_at(vars(...), any_vars(is.na(.))) 
> # eq. to filter(is.na(var1) | is.na(var2) | is.na(var3) ....)
> filter_at(vars(...), all_vars(is.na(.))) 
> # eq. to filter(is.na(var1) & is.na(var2) & is.na(var3) ....)
```

Scoped filter
===
- If you want to check all columns simultaneously, use `filter_all()`. 

```r
> flights %>%
>   filter_all(any_vars(is.na(.)))
```
- No need to pass in the `vars(...)` argument since you are checking the condition over all of the variables

Scoped select
===
- What about select? 
  - `select_at()` would do the same as `select()`
  - `select_all()` would return the same as the input
- Can we select columns based on some property that they have? For instance, all columns containing an NA?

```r
> flights %>%
+   select_if(list(~any(is.na(.)))) %>%
+   head()
# A tibble: 6 x 6
  dep_time dep_delay arr_time arr_delay tailnum air_time
     <int>     <dbl>    <int>     <dbl> <chr>      <dbl>
1      517         2      830        11 N14228       227
2      533         4      850        20 N24211       227
3      542         2      923        33 N619AA       160
4      544        -1     1004       -18 N804JB       183
5      554        -6      812       -25 N668DN       116
6      554        -4      740        12 N39463       150
```
- with `_if`, there is no need to provide an explicit list of variables, they are selcted according to the function in `list()`

Exercise: complete cases and variables
===
Using the flights data, pull out a subset of the data that is only rows and columns that have no NAs in them (i.e. if a row has an NA it can't be included, and if a column has an NA in it, it can't be included). Convert any `_time` columns in the result to doubles.

Exercise: complete cases and variables
===
Using the flights data, pull out a subset of the data that is only rows and columns that have no NAs in them (i.e. if a row has an NA it can't be included, and if a column has an NA in it, it can't be included). Convert any `_time` columns in the result to doubles.

```r
> flights %>%
+   filter_all(all_vars(!is.na(.))) %>%
+   select_if(~all(!is.na(.))) %>%
+   mutate_at(
+     vars(ends_with("_time")),
+     list(~as.double(.)))
# A tibble: 327,346 x 19
    year month   day dep_time sched_dep_time dep_delay arr_time
   <int> <int> <int>    <dbl>          <dbl>     <dbl>    <dbl>
 1  2013     1     1      517            515         2      830
 2  2013     1     1      533            529         4      850
 3  2013     1     1      542            540         2      923
 4  2013     1     1      544            545        -1     1004
 5  2013     1     1      554            600        -6      812
 6  2013     1     1      554            558        -4      740
 7  2013     1     1      555            600        -5      913
 8  2013     1     1      557            600        -3      709
 9  2013     1     1      557            600        -3      838
10  2013     1     1      558            600        -2      753
# … with 327,336 more rows, and 12 more variables: sched_arr_time <dbl>,
#   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
#   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
#   minute <dbl>, time_hour <dttm>
```

Scoped verbs
===
- Each dplyr verb (`filter()`, `select()`, `arrange()`, `mutate()`, `summarise()`) and the adverb `group_by()` has an `_if`, `_at`, and `_all` variant. 
- We've only covered some of them here, but you've now seen all of the verbs and at least one `_if`, `_at`, and `_all` form
- This should give you an idea of what is possible, but there is no need to memorize how they all work because they are so similar in nature.
  - `_at` applies to the provided columns
  - `_all` applies to all columns
  - `_if` applies to columns that meet a condition
  
Exercise: mean delays
===
Find the mean departure and arrival delays for each carrier. 
  
Answer: mean delays
===
Find the mean departure and arrival delays for each carrier. 

Using `summarize_at()`

```r
> flights %>%
+   group_by(carrier) %>%
+   summarize_at(
+     vars(ends_with("delay")),
+     list(~mean(., na.rm=T)))
# A tibble: 16 x 3
   carrier dep_delay arr_delay
   <chr>       <dbl>     <dbl>
 1 9E          16.7      7.38 
 2 AA           8.59     0.364
 3 AS           5.80    -9.93 
 4 B6          13.0      9.46 
 5 DL           9.26     1.64 
 6 EV          20.0     15.8  
 7 F9          20.2     21.9  
 8 FL          18.7     20.1  
 9 HA           4.90    -6.92 
10 MQ          10.6     10.8  
11 OO          12.6     11.9  
12 UA          12.1      3.56 
13 US           3.78     2.13 
14 VX          12.9      1.76 
15 WN          17.7      9.65 
16 YV          19.0     15.6  
```

Answer: mean delays
===
Find the mean departure and arrival delays for each carrier. 

Using `gather()`/`spread()`

```r
> flights %>%
+   select(carrier, ends_with("delay")) %>%
+   gather(direction, delay, -carrier) %>%
+   group_by(carrier, direction) %>%
+   summarize(mean_delay = mean(delay, na.rm=T)) %>%
+   spread(direction, mean_delay)
# A tibble: 16 x 3
# Groups:   carrier [16]
   carrier arr_delay dep_delay
   <chr>       <dbl>     <dbl>
 1 9E          7.38      16.7 
 2 AA          0.364      8.59
 3 AS         -9.93       5.80
 4 B6          9.46      13.0 
 5 DL          1.64       9.26
 6 EV         15.8       20.0 
 7 F9         21.9       20.2 
 8 FL         20.1       18.7 
 9 HA         -6.92       4.90
10 MQ         10.8       10.6 
11 OO         11.9       12.6 
12 UA          3.56      12.1 
13 US          2.13       3.78
14 VX          1.76      12.9 
15 WN          9.65      17.7 
16 YV         15.6       19.0 
```

Answer: mean delays
===
Find the mean departure and arrival delays for each carrier. 

Using `summarize()` with two summaries

```r
> flights %>%
+   group_by(carrier) %>%
+   summarize(arr_delay = mean(arr_delay, na.rm=T),
+             dep_delay = mean(dep_delay, na.rm=T))
# A tibble: 16 x 3
   carrier arr_delay dep_delay
   <chr>       <dbl>     <dbl>
 1 9E          7.38      16.7 
 2 AA          0.364      8.59
 3 AS         -9.93       5.80
 4 B6          9.46      13.0 
 5 DL          1.64       9.26
 6 EV         15.8       20.0 
 7 F9         21.9       20.2 
 8 FL         20.1       18.7 
 9 HA         -6.92       4.90
10 MQ         10.8       10.6 
11 OO         11.9       12.6 
12 UA          3.56      12.1 
13 US          2.13       3.78
14 VX          1.76      12.9 
15 WN          9.65      17.7 
16 YV         15.6       19.0 
```

Answer: mean delays
===
Find the mean departure and arrival delays for each carrier. 


```r
> flights %>%
>   group_by(carrier) %>%
>   summarize_at(
>     vars(ends_with("delay")),
>     list(~mean(., na.rm=T)))
```

```r
> flights %>%
>   select(carrier, ends_with("delay")) %>%
>   gather(direction, delay, -carrier) %>%
>   group_by(carrier, direction) %>%
>   summarize(mean_delay = mean(delay, na.rm=T)) %>%
>   spread(direction, mean_delay)
```

```r
> flights %>%
>   group_by(carrier) %>%
>   summarize(arr_delay = mean(arr_delay, na.rm=T),
>             dep_delay = mean(dep_delay, na.rm=T))
```
Which would you use and why?

Exercise: descriptive statistics
===
R has a built-in function called `summary()` that calculates and displays quantiles and means of variables in a data frame:

```r
> flights %>%
+   select(year:dep_time) %>% # some subset of columns for printing
+   summary()
      year          month             day           dep_time   
 Min.   :2013   Min.   : 1.000   Min.   : 1.00   Min.   :   1  
 1st Qu.:2013   1st Qu.: 4.000   1st Qu.: 8.00   1st Qu.: 907  
 Median :2013   Median : 7.000   Median :16.00   Median :1401  
 Mean   :2013   Mean   : 6.549   Mean   :15.71   Mean   :1349  
 3rd Qu.:2013   3rd Qu.:10.000   3rd Qu.:23.00   3rd Qu.:1744  
 Max.   :2013   Max.   :12.000   Max.   :31.00   Max.   :2400  
                                                 NA's   :8255  
```
- Let's build our own summary that captures other aspects of the distributions. We'll include mean, standard deviation, median, min, and max.

Exercise: descriptive statistics
===
- Let's build our own summary that captures other aspects of the distributions. We'll include mean, standard deviation, median, min, and max.
- Write code that calculates each of these statistics for each of the numeric variables in `flights`
- Do this however you like, but aim for concise and readable code. My code uses a scoped dplyr verb and three tidyr functions (with a regex look-ahead)!
- This is my output, but you can format yours however you think is sensible

```
# A tibble: 14 x 6
   var              max    mean median   min      sd
   <chr>          <dbl>   <dbl>  <dbl> <dbl>   <dbl>
 1 air_time         695  151.      129    20   93.7 
 2 arr_delay       1272    6.90     -5   -86   44.6 
 3 arr_time        2400 1502.     1535     1  533.  
 4 day               31   15.7      16     1    8.77
 5 dep_delay       1301   12.6      -2   -43   40.2 
 6 dep_time        2400 1349.     1401     1  488.  
 7 distance        4983 1040.      872    17  733.  
 8 flight          8500 1972.     1496     1 1632.  
 9 hour              23   13.2      13     1    4.66
10 minute            59   26.2      29     0   19.3 
11 month             12    6.55      7     1    3.41
12 sched_arr_time  2359 1536.     1556     1  497.  
13 sched_dep_time  2359 1344.     1359   106  467.  
14 year            2013 2013      2013  2013    0   
```

Answer: descriptive statistics
===
- Write code that calculates each of these statistics for each of the numeric variables in `flights`
- Do this however you like, but aim for concise and readable code. My code uses a scoped dplyr verb and three tidyr functions (with a regex look-ahead)!

```r
> flights %>%                                   # summarize over all rows (no groups)
+   summarize_if(                               # summarize stats for 
+     is.numeric,                               # numeric columns
+     list(~mean(., na.rm=T),
+          ~sd(., na.rm=T),                     # calculate these five stats
+          ~median(., na.rm=T),                 # remember to ignore NAs
+          ~min(., na.rm=T), 
+          ~max(., na.rm=T))) %>%               # returns a single row (lots of stats)
+   gather(var_stat, value) %>%                 # reshape to tall format
+   separate(var_stat, into=c("var", "stat"),   # split up the var name / stat name
+            sep="_(?=[a-z]+$)") %>%            # look-ahead to split at last underscore
+   spread(stat, value) %>%                     # transform to table with stats as cols
+ head()
# A tibble: 6 x 6
  var         max    mean median   min     sd
  <chr>     <dbl>   <dbl>  <dbl> <dbl>  <dbl>
1 air_time    695  151.      129    20  93.7 
2 arr_delay  1272    6.90     -5   -86  44.6 
3 arr_time   2400 1502.     1535     1 533.  
4 day          31   15.7      16     1   8.77
5 dep_delay  1301   12.6      -2   -43  40.2 
6 dep_time   2400 1349.     1401     1 488.  
```

Answer: 5-number summaries
===
- Unlike R's built-in summary function, this code can easily be modified and adapted for different summary statistics or to run over groups in the data
- In addition, this code returns a data frame which is easy to pull values out of and compute on

```r
> flights %>%                                   
+   group_by(carrier) %>%                       # !now grouped by carrier!
+   summarize_if(                               # summarize stats for 
+     is.numeric,                               # numeric columns
+     list(~mean(., na.rm=T),
+          ~sd(., na.rm=T),                     # calculate these five stats
+          ~median(., na.rm=T),                 # remember to ignore NAs
+          ~min(., na.rm=T), 
+          ~quantile(., 0.4, na.rm=T),          # !now with 40th %ile!
+          ~max(., na.rm=T))) %>%               # returns a single row (lots of stats)
+   gather(var_stat, value, -carrier) %>%       # reshape to tall format
+   separate(var_stat, into=c("var", "stat"),   # split up the var name / stat name
+            sep="_(?=[a-z]+$)") %>%            # look-ahead to split at last underscore
+   spread(stat, value) %>%                     # transform to table with stats as cols
+ sample_n(5)
# A tibble: 5 x 8
  carrier var              max    mean median   min quantile     sd
  <chr>   <chr>          <dbl>   <dbl>  <dbl> <dbl>    <dbl>  <dbl>
1 WN      sched_arr_time  2235 1450.     1430   705  1315    444.  
2 US      dep_time        2347 1231.     1221     2  1030    456.  
3 YV      flight          3799 3283.     3750  2625  2885    508.  
4 AA      month             12    6.48      6     1     5      3.43
5 OO      dep_delay        154   12.6      -6   -14    -6.80  43.1 
```

Window functions
===
type: section

Motivation
===
- Our data are often samples of various things through time

```r
> df = tibble( # some fake dates and blood pressure measurement
+   date = today() - days(round(runif(50, 0,600))),
+   blood_pressure = rnorm(50, 110, 5),
+   patient = c(rep("A",25), rep("B",25)))
> df %>% 
+ ggplot(aes(date, blood_pressure)) + 
+   geom_point()
```

![plot of chunk unnamed-chunk-55](adv-tabular-data-figure/unnamed-chunk-55-1.png)

Motivation
===
![plot of chunk unnamed-chunk-56](adv-tabular-data-figure/unnamed-chunk-56-1.png)
- How do we calculate things like: 
  - rates of change?
  - running averages?
  - max in the past month at each point in time?
- This is what **window functions** do.

Lead and lag
===
- `lead()` and `lag()` from `dplyr` help in calculating differences from timepoint to timepoint

```r
> df %>%
+   group_by(patient) %>%
+   arrange(patient, date) %>%
+   mutate(blood_pressure_lead = lead(blood_pressure),
+          blood_pressure_lag = lag(blood_pressure)) %>%
+   head()
# A tibble: 6 x 5
# Groups:   patient [1]
  date       blood_pressure patient blood_pressure_lead blood_pressure_lag
  <date>              <dbl> <chr>                 <dbl>              <dbl>
1 2017-08-08           124. A                      117.                NA 
2 2017-08-18           117. A                      116.               124.
3 2017-09-29           116. A                      111.               117.
4 2017-10-07           111. A                      110.               116.
5 2017-11-13           110. A                      110.               111.
6 2017-11-21           110. A                      106.               110.
```
- `lead()` shifts the vector back by one increment so the future measurement aligns with the current measurement
- `lag()` shifts it forward by one so the past measurement aligns with the current measurement
- If the past or future measurement is not in the data, an NA is introduced. You can change this using `default=`.
- You can shift by more than one row using the `n=` argument
- Note that these functions operate based on row order, so you should usually `arrange()` your data first (within each relvant group)

Finite differences with lead and lag
===
- `lead()` and `lag()` from `dplyr` help in calculating differences and rates of change from timepoint to timepoint

```r
> df %>%
+   group_by(patient) %>%
+   arrange(patient, date) %>%
+   mutate(bp_change = blood_pressure - lag(blood_pressure),
+          t_elapsed = as.duration(date-lag(date)) / ddays(1),
+          bp_change_rate = bp_change/t_elapsed) %>%
+   head()
# A tibble: 6 x 6
# Groups:   patient [1]
  date       blood_pressure patient bp_change t_elapsed bp_change_rate
  <date>              <dbl> <chr>       <dbl>     <dbl>          <dbl>
1 2017-08-08           124. A          NA            NA        NA     
2 2017-08-18           117. A          -6.93         10        -0.693 
3 2017-09-29           116. A          -0.917        42        -0.0218
4 2017-10-07           111. A          -4.51          8        -0.564 
5 2017-11-13           110. A          -1.68         37        -0.0453
6 2017-11-21           110. A           0.274         8         0.0343
```

Finite differences with lead and lag
===
- `lead()` and `lag()` from `dplyr` help in calculating differences and rates of change from timepoint to timepoint

```r
> df %>%
+   group_by(patient) %>%
+   arrange(patient, date) %>%
+   mutate(bp_change = blood_pressure - lag(blood_pressure),
+          t_elapsed = as.duration(date-lag(date)) / ddays(1),
+          bp_change_rate = bp_change/t_elapsed) %>%
+   gather(var, value, blood_pressure, bp_change, bp_change_rate) %>%
+ ggplot(aes(x=date, y=value)) + 
+   geom_smooth(method="loess") + 
+   facet_grid(var~., scales="free_y")
Warning: Removed 4 rows containing non-finite values (stat_smooth).
```

![plot of chunk unnamed-chunk-59](adv-tabular-data-figure/unnamed-chunk-59-1.png)

Exercise: projectile trajectory
===
- These made-up data represent the trajectory of a rocket. 

```r
> traj = tibble(
+   t = 0:100,
+   x_pos = 100*0:100,
+   y_pos = 500*t - 0.5*9.81*(t^2)
+ )
```

- Use them to reproduce the following plot

![plot of chunk unnamed-chunk-61](adv-tabular-data-figure/unnamed-chunk-61-1.png)
- Recall that velocity is the rate of change of position and acceleration is the rate of change of velocity

Answer: projectile trajectory
===

```r
> traj %>%
+   mutate(
+     dt = t - lag(t),
+     x_vel = (x_pos - lag(x_pos))/dt,
+     y_vel = (y_pos - lag(y_pos))/dt,
+     x_accel = (x_vel - lag(x_vel))/dt,
+     y_accel = (y_vel - lag(y_vel))/dt) %>%
+   gather(coord_measure, value, -t, -dt) %>%
+   separate(coord_measure, into=c("coord", "measure"), sep="_") %>%
+   mutate(measure = fct_relevel(measure, "pos", "vel", "accel")) %>%
+ ggplot(aes(x=t, y=value)) +
+   geom_line() +
+   facet_grid(measure~coord, scales="free")
```

![plot of chunk unnamed-chunk-62](adv-tabular-data-figure/unnamed-chunk-62-1.png)

Cumulative statistics
===
- Sometimes we're interested in things like averages-to-date. 
- These are called **cumulative statistics** and can be caluclated with functions like `cummean()` and `cummax()`. Others can be found in the `cumstats` package.

```r
> df  %>% 
+   group_by(patient) %>%
+   arrange(patient, date) %>%
+   mutate(bp_cummean = cummean(blood_pressure),
+          bp_cummax = cummax(blood_pressure)) %>%
+ head()
# A tibble: 6 x 5
# Groups:   patient [1]
  date       blood_pressure patient bp_cummean bp_cummax
  <date>              <dbl> <chr>        <dbl>     <dbl>
1 2017-08-08           124. A             124.      124.
2 2017-08-18           117. A             120.      124.
3 2017-09-29           116. A             119.      124.
4 2017-10-07           111. A             117.      124.
5 2017-11-13           110. A             116.      124.
6 2017-11-21           110. A             115.      124.
```

Fixed-length rolling windows
=== 
- The windows for cumulative statistics are a look-back period that changes length (from the first row to the current row, which changes)
- What if we want to calculate statistics over fixed-length windows that move?
- These calculations are efficiently implemented in the `RcppRoll` package with functions like `roll_mean()` and `roll_max()` (others are available as well)

```r
> library(RcppRoll) 
> df  %>% 
+   group_by(patient) %>%
+   arrange(patient, date) %>%
+   mutate(bp_cummean = roll_mean(blood_pressure, n=3, align="right", fill=NA),
+          bp_cummax = roll_max(blood_pressure, n=3, align="right",  fill=NA)) %>%
+   head()
# A tibble: 6 x 5
# Groups:   patient [1]
  date       blood_pressure patient bp_cummean bp_cummax
  <date>              <dbl> <chr>        <dbl>     <dbl>
1 2017-08-08           124. A              NA        NA 
2 2017-08-18           117. A              NA        NA 
3 2017-09-29           116. A             119.      124.
4 2017-10-07           111. A             115.      117.
5 2017-11-13           110. A             112.      116.
6 2017-11-21           110. A             110.      111.
```

Fixed-length rolling windows
=== 

```r
> df  %>% 
+   group_by(patient) %>%
+   arrange(patient, date) %>%
+   mutate(bp_cummean = roll_mean(blood_pressure, n=3, align="right", fill=NA),
+          bp_cummax = roll_max(blood_pressure, n=3, align="right",  fill=NA)) %>%
+   head()
# A tibble: 6 x 5
# Groups:   patient [1]
  date       blood_pressure patient bp_cummean bp_cummax
  <date>              <dbl> <chr>        <dbl>     <dbl>
1 2017-08-08           124. A              NA        NA 
2 2017-08-18           117. A              NA        NA 
3 2017-09-29           116. A             119.      124.
4 2017-10-07           111. A             115.      117.
5 2017-11-13           110. A             112.      116.
6 2017-11-21           110. A             110.      111.
```
- `n=` specifies how many rows around the current row are used in the rolling window
- `align=` specifies how the window should line up with the current row (right, center, left)
  - `roll_meanr()` is a variant with `align="right"` hard-coded in.
- `fill=` specifies what should go in rows where the window extends beyond available data

Wrap-up
========================================================
type: section

Goals of this course
========================================================
By the end of the course you should be able to...

- transform between "tidy" and "messy" data
- perform simultaneous multi-variable multi-function manipulations in dplyr
- perform manipulations that involve fixed or rolling windows of rows

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

- Tidy data: ch 12
- Multi-variable manipulations: [dplyr reference](https://dplyr.tidyverse.org/reference/scoped.html)
- Window manipulations: [dplyr reference](https://dplyr.tidyverse.org/articles/window-functions.html), 
[RcppRoll reference](https://cran.r-project.org/web/packages/RcppRoll/RcppRoll.pdf)

Cheatsheets: https://www.rstudio.com/resources/cheatsheets/
