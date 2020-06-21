Data Transformation
========================================================
author: Alejandro Schuler, adapted from Steve Bagley and based on R for Data Science by Hadley Wickham
date: 2019
transition: none
width: 1680
height: 1050


<style>
.small-code pre code {
  font-size: 0.5em;
}
</style>


dplyr verbs
========================================================
The rest of this section shows the basic data frame functions ("verbs") in the `dplyr` package (part of `tidyverse`). Each operation takes a data frame and produces a new data frame.

- `filter()` picks out rows according to specified conditions
- `select()` picks out columns according to their names
- `arrange()` sorts the row by values in some column(s)
- `mutate()` creates new columns, often based on operations on other columns
- `summarize()` collapses many values in one or more columns down to one value per column

These can all be used in conjunction with `group_by()` which changes the scope of each function from operating on the entire dataset to operating on it group-by-group. These six functions provide the verbs for a language of data manipulation.

All verbs work similarly:

1. The first argument is a data frame.
2. The subsequent arguments describe what to do with the data frame, using the variable names (without quotes).
3. The result is a new data frame.

Together these properties make it easy to chain together multiple simple steps to achieve a complex result. Let’s dive in and see how these verbs work.

Filter rows with filter()
====
type: section

Filter rows with filter()
========================================================
- `filter()` lets you filter out rows of a dataset that meet a certain condition
- it takes two arguments: the dataset and the condition


```r
> nrow(mpg)
[1] 234
> filter(mpg, hwy <= 25)
# A tibble: 133 x 11
   manufacturer model     displ  year   cyl trans  drv     cty   hwy fl    class
   <chr>        <chr>     <dbl> <int> <int> <chr>  <chr> <int> <int> <chr> <chr>
 1 audi         a4 quatt…   1.8  1999     4 auto(… 4        16    25 p     comp…
 2 audi         a4 quatt…   2.8  1999     6 auto(… 4        15    25 p     comp…
 3 audi         a4 quatt…   2.8  1999     6 manua… 4        17    25 p     comp…
 4 audi         a4 quatt…   3.1  2008     6 auto(… 4        17    25 p     comp…
 5 audi         a4 quatt…   3.1  2008     6 manua… 4        15    25 p     comp…
 6 audi         a6 quatt…   2.8  1999     6 auto(… 4        15    24 p     mids…
 7 audi         a6 quatt…   3.1  2008     6 auto(… 4        17    25 p     mids…
 8 audi         a6 quatt…   4.2  2008     8 auto(… 4        16    23 p     mids…
 9 chevrolet    c1500 su…   5.3  2008     8 auto(… r        14    20 r     suv  
10 chevrolet    c1500 su…   5.3  2008     8 auto(… r        11    15 e     suv  
# … with 123 more rows
```

Exercise
========================================================
- What is the result of running this code?


```r
> nrow(mpg)
[1] 234
```


```r
> filter(mpg, hwy <= 25)
> filter(mpg, cyl <= 4)
> nrow(mpg)
```

- remember, functions usually do not change their arguments!


```r
> low_mileage = filter(mpg, hwy <= 25)
> low_mileage_few_cyl = filter(low_mileage, cyl <= 4)
> nrow(low_mileage_few_cyl)
[1] 13
```

Combining constraints in filter
========================================================

```r
> filter(mpg, hwy <= 25, year > 2000)
# A tibble: 70 x 11
   manufacturer model     displ  year   cyl trans  drv     cty   hwy fl    class
   <chr>        <chr>     <dbl> <int> <int> <chr>  <chr> <int> <int> <chr> <chr>
 1 audi         a4 quatt…   3.1  2008     6 auto(… 4        17    25 p     comp…
 2 audi         a4 quatt…   3.1  2008     6 manua… 4        15    25 p     comp…
 3 audi         a6 quatt…   3.1  2008     6 auto(… 4        17    25 p     mids…
 4 audi         a6 quatt…   4.2  2008     8 auto(… 4        16    23 p     mids…
 5 chevrolet    c1500 su…   5.3  2008     8 auto(… r        14    20 r     suv  
 6 chevrolet    c1500 su…   5.3  2008     8 auto(… r        11    15 e     suv  
 7 chevrolet    c1500 su…   5.3  2008     8 auto(… r        14    20 r     suv  
 8 chevrolet    c1500 su…   6    2008     8 auto(… r        12    17 r     suv  
 9 chevrolet    corvette    6.2  2008     8 auto(… r        15    25 p     2sea…
10 chevrolet    corvette    7    2008     8 manua… r        15    24 p     2sea…
# … with 60 more rows
```
- This filters by the **conjunction** of the two constraints---both must be satisfied.
- Constraints appear as second (and third...) arguments, separated by commas.


Filtering out all rows
=========================================================

```r
> filter(mpg, hwy > 60)
# A tibble: 0 x 11
# … with 11 variables: manufacturer <chr>, model <chr>, displ <dbl>,
#   year <int>, cyl <int>, trans <chr>, drv <chr>, cty <int>, hwy <int>,
#   fl <chr>, class <chr>
```
- If the constraint is too severe, then you will select **no** rows, and produce a zero row sized tibble.

Comparison operators
=========================================================
- `==` and `!=` test for equality and inequality (do not use `=` for equality)
- `>` and `<` test for greater-than and less-than
- `>=` and `<=` are greater-than-or-equal and less-than-or-equal
- these can also be used directly on vectors outside of data frames

```r
> c(1, 5, -22, 4) > 0
[1]  TRUE  TRUE FALSE  TRUE
```

<!-- Finite precision arithemetic -->
<!-- === -->
<!-- ```{r} -->
<!-- sqrt(2) ^ 2 == 2 -->
<!-- 1 / 49 * 49 == 1 -->
<!-- near(sqrt(2) ^ 2,  2) -->
<!-- near(1 / 49 * 49, 1) -->
<!-- ``` -->

Logical conjunctions
=========================================================

```r
> filter(mpg, hwy > 30 | hwy < 20)
# A tibble: 100 x 11
   manufacturer model     displ  year   cyl trans  drv     cty   hwy fl    class
   <chr>        <chr>     <dbl> <int> <int> <chr>  <chr> <int> <int> <chr> <chr>
 1 audi         a4          2    2008     4 manua… f        20    31 p     comp…
 2 chevrolet    c1500 su…   5.3  2008     8 auto(… r        11    15 e     suv  
 3 chevrolet    c1500 su…   5.7  1999     8 auto(… r        13    17 r     suv  
 4 chevrolet    c1500 su…   6    2008     8 auto(… r        12    17 r     suv  
 5 chevrolet    k1500 ta…   5.3  2008     8 auto(… 4        14    19 r     suv  
 6 chevrolet    k1500 ta…   5.3  2008     8 auto(… 4        11    14 e     suv  
 7 chevrolet    k1500 ta…   5.7  1999     8 auto(… 4        11    15 r     suv  
 8 chevrolet    k1500 ta…   6.5  1999     8 auto(… 4        14    17 d     suv  
 9 dodge        caravan …   3.3  2008     6 auto(… f        11    17 e     mini…
10 dodge        dakota p…   3.7  2008     6 manua… 4        15    19 r     pick…
# … with 90 more rows
```
- `|` stands for OR, `&` is AND
- as we have seen, separating conditions by a comma is the same as using `&` inside `filter()`
- these can be made into complex logical conditions

Logical conjunctions
=========================================================

```r
> filter(mpg, !(hwy > 30 | hwy < 20))
# A tibble: 134 x 11
   manufacturer model    displ  year   cyl trans   drv     cty   hwy fl    class
   <chr>        <chr>    <dbl> <int> <int> <chr>   <chr> <int> <int> <chr> <chr>
 1 audi         a4         1.8  1999     4 auto(l… f        18    29 p     comp…
 2 audi         a4         1.8  1999     4 manual… f        21    29 p     comp…
 3 audi         a4         2    2008     4 auto(a… f        21    30 p     comp…
 4 audi         a4         2.8  1999     6 auto(l… f        16    26 p     comp…
 5 audi         a4         2.8  1999     6 manual… f        18    26 p     comp…
 6 audi         a4         3.1  2008     6 auto(a… f        18    27 p     comp…
 7 audi         a4 quat…   1.8  1999     4 manual… 4        18    26 p     comp…
 8 audi         a4 quat…   1.8  1999     4 auto(l… 4        16    25 p     comp…
 9 audi         a4 quat…   2    2008     4 manual… 4        20    28 p     comp…
10 audi         a4 quat…   2    2008     4 auto(s… 4        19    27 p     comp…
# … with 124 more rows
```
- `!` is NOT, which negates the logical condition

Logical conjunctions
=========================================================

```r
> filter(mpg, cyl %in% c(6, 8))  # equivalent to filter(mtc, cyl==6 | cyl==8)
# A tibble: 149 x 11
   manufacturer model    displ  year   cyl trans   drv     cty   hwy fl    class
   <chr>        <chr>    <dbl> <int> <int> <chr>   <chr> <int> <int> <chr> <chr>
 1 audi         a4         2.8  1999     6 auto(l… f        16    26 p     comp…
 2 audi         a4         2.8  1999     6 manual… f        18    26 p     comp…
 3 audi         a4         3.1  2008     6 auto(a… f        18    27 p     comp…
 4 audi         a4 quat…   2.8  1999     6 auto(l… 4        15    25 p     comp…
 5 audi         a4 quat…   2.8  1999     6 manual… 4        17    25 p     comp…
 6 audi         a4 quat…   3.1  2008     6 auto(s… 4        17    25 p     comp…
 7 audi         a4 quat…   3.1  2008     6 manual… 4        15    25 p     comp…
 8 audi         a6 quat…   2.8  1999     6 auto(l… 4        15    24 p     mids…
 9 audi         a6 quat…   3.1  2008     6 auto(s… 4        17    25 p     mids…
10 audi         a6 quat…   4.2  2008     8 auto(s… 4        16    23 p     mids…
# … with 139 more rows
```
- `%in%` returns true for all elements of the thing on the left that are also elements of the thing on the right

Exercise: Audis
==========================================================
type: prompt
incremental: true

- How many Audis are there in this dataset?

```r
> nrow(filter(mpg, manufacturer == "audi"))
[1] 18
```

Filtering by row number
==========================================================

```r
> filter(mpg, row_number() <= 3)
# A tibble: 3 x 11
  manufacturer model displ  year   cyl trans      drv     cty   hwy fl    class 
  <chr>        <chr> <dbl> <int> <int> <chr>      <chr> <int> <int> <chr> <chr> 
1 audi         a4      1.8  1999     4 auto(l5)   f        18    29 p     compa…
2 audi         a4      1.8  1999     4 manual(m5) f        21    29 p     compa…
3 audi         a4      2    2008     4 manual(m6) f        20    31 p     compa…
```
- use `row_number()` to get specific rows. This is more useful once you have sorted the data in a particular order, which we will soon see how to do.

Sampling rows
==========================================================

```r
> sample_n(mtc, 5)
Error in sample_n(mtc, 5): object 'mtc' not found
```
- You can use `sample_n()` to get `n` randomly selected rows if you don't have a particular condition you would like to filter on.
- `sample_frac()` is similar
- do `?sample_n()` to see how you can sample with replacement or with weights

Arrange rows with arrange()
===
type:section

Arrange rows with arrange()
===========================================================
- `arrange()` takes a data frame and a column, and sorts the rows by the values in that column (ascending order).
- again, the first argument is the data frame and the other arguments tell the function what to do with it

```r
> arrange(mpg, hwy)
# A tibble: 234 x 11
   manufacturer model     displ  year   cyl trans  drv     cty   hwy fl    class
   <chr>        <chr>     <dbl> <int> <int> <chr>  <chr> <int> <int> <chr> <chr>
 1 dodge        dakota p…   4.7  2008     8 auto(… 4         9    12 e     pick…
 2 dodge        durango …   4.7  2008     8 auto(… 4         9    12 e     suv  
 3 dodge        ram 1500…   4.7  2008     8 auto(… 4         9    12 e     pick…
 4 dodge        ram 1500…   4.7  2008     8 manua… 4         9    12 e     pick…
 5 jeep         grand ch…   4.7  2008     8 auto(… 4         9    12 e     suv  
 6 chevrolet    k1500 ta…   5.3  2008     8 auto(… 4        11    14 e     suv  
 7 jeep         grand ch…   6.1  2008     8 auto(… 4        11    14 p     suv  
 8 chevrolet    c1500 su…   5.3  2008     8 auto(… r        11    15 e     suv  
 9 chevrolet    k1500 ta…   5.7  1999     8 auto(… 4        11    15 r     suv  
10 dodge        dakota p…   5.2  1999     8 auto(… 4        11    15 r     pick…
# … with 224 more rows
```

Arrange can sort by more than one column
===========================================================
- This is useful if there is a tie in sorting by the first column.

```r
> arrange(mpg, hwy, displ)
# A tibble: 234 x 11
   manufacturer model     displ  year   cyl trans  drv     cty   hwy fl    class
   <chr>        <chr>     <dbl> <int> <int> <chr>  <chr> <int> <int> <chr> <chr>
 1 dodge        dakota p…   4.7  2008     8 auto(… 4         9    12 e     pick…
 2 dodge        durango …   4.7  2008     8 auto(… 4         9    12 e     suv  
 3 dodge        ram 1500…   4.7  2008     8 auto(… 4         9    12 e     pick…
 4 dodge        ram 1500…   4.7  2008     8 manua… 4         9    12 e     pick…
 5 jeep         grand ch…   4.7  2008     8 auto(… 4         9    12 e     suv  
 6 chevrolet    k1500 ta…   5.3  2008     8 auto(… 4        11    14 e     suv  
 7 jeep         grand ch…   6.1  2008     8 auto(… 4        11    14 p     suv  
 8 land rover   range ro…   4    1999     8 auto(… 4        11    15 p     suv  
 9 land rover   range ro…   4.6  1999     8 auto(… 4        11    15 p     suv  
10 toyota       land cru…   4.7  1999     8 auto(… 4        11    15 r     suv  
# … with 224 more rows
```


Use the desc function to sort by descending values
===========================================================

```r
> arrange(mpg, desc(hwy))
# A tibble: 234 x 11
   manufacturer model   displ  year   cyl trans   drv     cty   hwy fl    class 
   <chr>        <chr>   <dbl> <int> <int> <chr>   <chr> <int> <int> <chr> <chr> 
 1 volkswagen   jetta     1.9  1999     4 manual… f        33    44 d     compa…
 2 volkswagen   new be…   1.9  1999     4 manual… f        35    44 d     subco…
 3 volkswagen   new be…   1.9  1999     4 auto(l… f        29    41 d     subco…
 4 toyota       corolla   1.8  2008     4 manual… f        28    37 r     compa…
 5 honda        civic     1.8  2008     4 auto(l… f        25    36 r     subco…
 6 honda        civic     1.8  2008     4 auto(l… f        24    36 c     subco…
 7 toyota       corolla   1.8  1999     4 manual… f        26    35 r     compa…
 8 toyota       corolla   1.8  2008     4 auto(l… f        26    35 r     compa…
 9 honda        civic     1.8  2008     4 manual… f        26    34 r     subco…
10 honda        civic     1.6  1999     4 manual… f        28    33 r     subco…
# … with 224 more rows
```

Exercise: top 5 mpg cars
===========================================================
type:prompt
incremental:true

Use `arrange()` and `filter()` to get the data for the 5 cars with the highest highway MPG (`hwy`)


```r
> filter(arrange(mpg, desc(hwy)), row_number() <= 5)  # 'nesting' the calls to filter and arrange
# A tibble: 5 x 11
  manufacturer model   displ  year   cyl trans   drv     cty   hwy fl    class  
  <chr>        <chr>   <dbl> <int> <int> <chr>   <chr> <int> <int> <chr> <chr>  
1 volkswagen   jetta     1.9  1999     4 manual… f        33    44 d     compact
2 volkswagen   new be…   1.9  1999     4 manual… f        35    44 d     subcom…
3 volkswagen   new be…   1.9  1999     4 auto(l… f        29    41 d     subcom…
4 toyota       corolla   1.8  2008     4 manual… f        28    37 r     compact
5 honda        civic     1.8  2008     4 auto(l… f        25    36 r     subcom…
```
or

```r
> cars_by_mpg = arrange(mpg, desc(hwy))  # using a temporary variable
> filter(cars_by_mpg, row_number() <= 5)
# A tibble: 5 x 11
  manufacturer model   displ  year   cyl trans   drv     cty   hwy fl    class  
  <chr>        <chr>   <dbl> <int> <int> <chr>   <chr> <int> <int> <chr> <chr>  
1 volkswagen   jetta     1.9  1999     4 manual… f        33    44 d     compact
2 volkswagen   new be…   1.9  1999     4 manual… f        35    44 d     subcom…
3 volkswagen   new be…   1.9  1999     4 auto(l… f        29    41 d     subcom…
4 toyota       corolla   1.8  2008     4 manual… f        28    37 r     compact
5 honda        civic     1.8  2008     4 auto(l… f        25    36 r     subcom…
```

Select columns with select()
===
type:section

Select columns with select()
=========================================================

```r
> select(mpg, hwy, cyl, manufacturer)
# A tibble: 234 x 3
     hwy   cyl manufacturer
   <int> <int> <chr>       
 1    29     4 audi        
 2    29     4 audi        
 3    31     4 audi        
 4    30     4 audi        
 5    26     6 audi        
 6    26     6 audi        
 7    27     6 audi        
 8    26     4 audi        
 9    25     4 audi        
10    28     4 audi        
# … with 224 more rows
```
- The select function will return a subset of the tibble, using only the requested columns in the order specified.

Select columns with select()
=========================================================
- `select()` can also be used with handy helpers like `starts_with()` and `contains()`

```r
> select(mpg, starts_with("m"))
# A tibble: 234 x 2
   manufacturer model     
   <chr>        <chr>     
 1 audi         a4        
 2 audi         a4        
 3 audi         a4        
 4 audi         a4        
 5 audi         a4        
 6 audi         a4        
 7 audi         a4        
 8 audi         a4 quattro
 9 audi         a4 quattro
10 audi         a4 quattro
# … with 224 more rows
```
- Use `?select` to see all the possibilities

***


```r
> select(mpg, contains("l"))
# A tibble: 234 x 5
   model      displ   cyl fl    class  
   <chr>      <dbl> <int> <chr> <chr>  
 1 a4           1.8     4 p     compact
 2 a4           1.8     4 p     compact
 3 a4           2       4 p     compact
 4 a4           2       4 p     compact
 5 a4           2.8     6 p     compact
 6 a4           2.8     6 p     compact
 7 a4           3.1     6 p     compact
 8 a4 quattro   1.8     4 p     compact
 9 a4 quattro   1.8     4 p     compact
10 a4 quattro   2       4 p     compact
# … with 224 more rows
```
- The quotes around the letter `"l"` make it a string. If we did not do this, `R` would think it was looking for a variable called `m` and not just the plain letter.
- We don't have to quote the names of columns (like `hp`) because the `tidyverse` functions know that we are working within the dataframe and thus treat the column names like they are variables in their own right

select() subsets columns by name
=========================================================
- `select()` can also be used to select everything **except for** certain columns

```r
> select(mpg, -contains("l"), -hwy)
# A tibble: 234 x 5
   manufacturer  year trans      drv     cty
   <chr>        <int> <chr>      <chr> <int>
 1 audi          1999 auto(l5)   f        18
 2 audi          1999 manual(m5) f        21
 3 audi          2008 manual(m6) f        20
 4 audi          2008 auto(av)   f        21
 5 audi          1999 auto(l5)   f        16
 6 audi          1999 manual(m5) f        18
 7 audi          2008 auto(av)   f        18
 8 audi          1999 manual(m5) 4        18
 9 audi          1999 auto(l5)   4        16
10 audi          2008 manual(m6) 4        20
# … with 224 more rows
```

select() subsets columns by name
=========================================================
- or even to select only columns that match a certain condition


```r
> select(mpg, where(is.integer))
# A tibble: 234 x 4
    year   cyl   cty   hwy
   <int> <int> <int> <int>
 1  1999     4    18    29
 2  1999     4    21    29
 3  2008     4    20    31
 4  2008     4    21    30
 5  1999     6    16    26
 6  1999     6    18    26
 7  2008     6    18    27
 8  1999     4    18    26
 9  1999     4    16    25
10  2008     4    20    28
# … with 224 more rows
```

pull() is a friend of select()
=========================================================
- `select()` has a friend called `pull()` which returns a vector instead of a (one-column) data frame

```r
> select(mpg, hwy)
# A tibble: 234 x 1
     hwy
   <int>
 1    29
 2    29
 3    31
 4    30
 5    26
 6    26
 7    27
 8    26
 9    25
10    28
# … with 224 more rows
> pull(mpg, hwy)
  [1] 29 29 31 30 26 26 27 26 25 28 27 25 25 25 25 24 25 23 20 15 20 17 17 26 23
 [26] 26 25 24 19 14 15 17 27 30 26 29 26 24 24 22 22 24 24 17 22 21 23 23 19 18
 [51] 17 17 19 19 12 17 15 17 17 12 17 16 18 15 16 12 17 17 16 12 15 16 17 15 17
 [76] 17 18 17 19 17 19 19 17 17 17 16 16 17 15 17 26 25 26 24 21 22 23 22 20 33
[101] 32 32 29 32 34 36 36 29 26 27 30 31 26 26 28 26 29 28 27 24 24 24 22 19 20
[126] 17 12 19 18 14 15 18 18 15 17 16 18 17 19 19 17 29 27 31 32 27 26 26 25 25
[151] 17 17 20 18 26 26 27 28 25 25 24 27 25 26 23 26 26 26 26 25 27 25 27 20 20
[176] 19 17 20 17 29 27 31 31 26 26 28 27 29 31 31 26 26 27 30 33 35 37 35 15 18
[201] 20 20 22 17 19 18 20 29 26 29 29 24 44 29 26 29 29 29 29 23 24 44 41 29 26
[226] 28 29 29 29 28 29 26 26 26
```

rename()
=========================================================
- `select()` can be used to rename variables, but it drops all variables not selected

```r
> select(mpg, hwy_milage = hwy)
# A tibble: 234 x 1
   hwy_milage
        <int>
 1         29
 2         29
 3         31
 4         30
 5         26
 6         26
 7         27
 8         26
 9         25
10         28
# … with 224 more rows
```
***
- `rename()` is better suited for this because it keeps all the columns

```r
> rename(mpg, hwy_milage = hwy)
# A tibble: 234 x 11
   manufacturer model displ  year   cyl trans drv     cty hwy_milage fl    class
   <chr>        <chr> <dbl> <int> <int> <chr> <chr> <int>      <int> <chr> <chr>
 1 audi         a4      1.8  1999     4 auto… f        18         29 p     comp…
 2 audi         a4      1.8  1999     4 manu… f        21         29 p     comp…
 3 audi         a4      2    2008     4 manu… f        20         31 p     comp…
 4 audi         a4      2    2008     4 auto… f        21         30 p     comp…
 5 audi         a4      2.8  1999     6 auto… f        16         26 p     comp…
 6 audi         a4      2.8  1999     6 manu… f        18         26 p     comp…
 7 audi         a4      3.1  2008     6 auto… f        18         27 p     comp…
 8 audi         a4 q…   1.8  1999     4 manu… 4        18         26 p     comp…
 9 audi         a4 q…   1.8  1999     4 auto… 4        16         25 p     comp…
10 audi         a4 q…   2    2008     4 manu… 4        20         28 p     comp…
# … with 224 more rows
```

select and filter
===
incremental:true
type:prompt

- create a one-column dataframe of the highway fuel efficiencies (`hwy`) of all of the compact cars (`class`) in the `mpg` dataset.


```r
> select(filter(mpg, class == "compact"), hwy)
# A tibble: 47 x 1
     hwy
   <int>
 1    29
 2    29
 3    31
 4    30
 5    26
 6    26
 7    27
 8    26
 9    25
10    28
# … with 37 more rows
```

- what is wrong with this?

```r
> filter(select(mpg, hwy), class == "compact")
```


Add new variables with mutate()
===
type:section

Add new variables with mutate()
================================================================

```r
> mpg_vars_subset = select(mpg, hwy, displ)
> mutate(mtc_vars_subset, hw_gallons_per_mile = 1/hwy)
Error in mutate(mtc_vars_subset, hw_gallons_per_mile = 1/hwy): object 'mtc_vars_subset' not found
```
- This uses `mutate()` to add a new column to which is the reciprocal of `hwy`.
- The thing on the left of the `=` is a new name that you make up which you would like the new column to be called
- The expresssion on the right of the `=` defines what will go into the new column
-`mutate()` can create multiple columns at the same time and use multiple columns to define a single new one

mutate() can create multiple new columns at once
================================================================

```r
> mutate(mpg_vars_subset, # the newlines make it more readable
+       hw_gallons_per_mile = 1/hwy,
+       mpg_displ_ratio = hwy/displ
+ )
# A tibble: 234 x 4
     hwy displ hw_gallons_per_mile mpg_displ_ratio
   <int> <dbl>               <dbl>           <dbl>
 1    29   1.8              0.0345           16.1 
 2    29   1.8              0.0345           16.1 
 3    31   2                0.0323           15.5 
 4    30   2                0.0333           15   
 5    26   2.8              0.0385            9.29
 6    26   2.8              0.0385            9.29
 7    27   3.1              0.0370            8.71
 8    26   1.8              0.0385           14.4 
 9    25   1.8              0.04             13.9 
10    28   2                0.0357           14   
# … with 224 more rows
```
- note that we have also used two columns simultaneously (`hwy` and `displ`) to create a new column)

mutate() for data type conversion
===
- Data is sometimes given to you in a form that makes it difficult to do operations on

```r
> df = tibble(number = c("1", "2", "3"))
> df
# A tibble: 3 x 1
  number
  <chr> 
1 1     
2 2     
3 3     
> mutate(df, number_plus_1 = number + 1)
Error: Problem with `mutate()` input `number_plus_1`.
x non-numeric argument to binary operator
ℹ Input `number_plus_1` is `number + 1`.
```

- `mutate()` is also useful for converting data types, in this case text to numbers

```r
> mutate(df, number = as.numeric(number))
# A tibble: 3 x 1
  number
   <dbl>
1      1
2      2
3      3
```
- if you save the result into a column that already exists, it will be overwritten

mutate() for computing offsets
===
incremental: true

```r
> lead(c(1, 2, 3))
[1]  2  3 NA
> lag(c(1, 2, 3))
[1] NA  1  2
```


```r
> scores = tibble(
+   day = c(1,2,3,4),
+   score = c(72, 87, 94, 99)
+ )
```


```r
> mutate(scores, daily_improvement = score - lag(score))
# A tibble: 4 x 3
    day score daily_improvement
  <dbl> <dbl>             <dbl>
1     1    72                NA
2     2    87                15
3     3    94                 7
4     4    99                 5
```

mutate() for cumulative functions
===
incremental: true

```r
> cumsum(c(1, 2, 3))
[1] 1 3 6
```
- `cumsum` takes the cumulative sum of a vector. See `?cumsum` for similar functions 


```r
> profits = tibble(
+   day = c(1,2,3,4),
+   profit = c(12, 40, 19, 13)
+ )
```


```r
> mutate(profits, profit_to_date = cumsum(profit))
# A tibble: 4 x 3
    day profit profit_to_date
  <dbl>  <dbl>          <dbl>
1     1     12             12
2     2     40             52
3     3     19             71
4     4     13             84
```

mutate() for rolling functions
===
incremental: true

```r
> library("slider")
> slide_vec(c(1, 2, 3, 4), mean, .before = 1)
[1] 1.0 1.5 2.5 3.5
```
- `slide_vec` applies a function using a sliding window across a vector (sometimes called "rolling" functions)


```r
> profits = tibble(
+   day = c(1,2,3,4),
+   profit = c(12, 40, 19, 13)
+ )
```


```r
> mutate(profits, avg_2_day_profit = slide_vec(profit, mean, .before = 1))
# A tibble: 4 x 3
    day profit avg_2_day_profit
  <dbl>  <dbl>            <dbl>
1     1     12             12  
2     2     40             26  
3     3     19             29.5
4     4     13             16  
```

- More on this in the section on functional programming!

Exercise
===
type:prompt
incremental:true

`hwy` is the highway mileage and `cty` is the city mileage for each car in this dataset. Assuming I usually drive twice as many miles in the city as I do on the highway, can you compute my average mileage with each of these cars?


```r
> mutate(mpg, avg_mpg = (2 * cty + hwy)/3)
# A tibble: 234 x 12
   manufacturer model displ  year   cyl trans drv     cty   hwy fl    class
   <chr>        <chr> <dbl> <int> <int> <chr> <chr> <int> <int> <chr> <chr>
 1 audi         a4      1.8  1999     4 auto… f        18    29 p     comp…
 2 audi         a4      1.8  1999     4 manu… f        21    29 p     comp…
 3 audi         a4      2    2008     4 manu… f        20    31 p     comp…
 4 audi         a4      2    2008     4 auto… f        21    30 p     comp…
 5 audi         a4      2.8  1999     6 auto… f        16    26 p     comp…
 6 audi         a4      2.8  1999     6 manu… f        18    26 p     comp…
 7 audi         a4      3.1  2008     6 auto… f        18    27 p     comp…
 8 audi         a4 q…   1.8  1999     4 manu… 4        18    26 p     comp…
 9 audi         a4 q…   1.8  1999     4 auto… 4        16    25 p     comp…
10 audi         a4 q…   2    2008     4 manu… 4        20    28 p     comp…
# … with 224 more rows, and 1 more variable: avg_mpg <dbl>
```

Exercise
===
type:prompt
incremental:true

I'm considering buying a car. I know Toyotas and Subarus are reliable so I'd like for the car to be either a Toyota or Subaru. Besides that the only thing I really care about is overall fuel efficiency. I usually drive twice as many miles in the city as I do on the highway. Can you produce me a rank-ordered list of the top 10 cars that I should consider, from best to worst? I'd just like the make, model, transmission, year, and overall fuel efficiency.


```r
> toyotas_and_subarus = filter(mpg, manufacturer == "toyota" | manufacturer == "subaru")
> with_avg_mpg = mutate(toyotas_and_subarus, avg_mpg = (2 * cty + hwy)/3)
> sorted = arrange(with_avg_mpg, desc(avg_mpg))
> top_10 = filter(sorted, row_number() <= 10)
> select(top_10, manufacturer, model, trans, year, avg_mpg)
# A tibble: 10 x 5
   manufacturer model        trans       year avg_mpg
   <chr>        <chr>        <chr>      <int>   <dbl>
 1 toyota       corolla      manual(m5)  2008    31  
 2 toyota       corolla      manual(m5)  1999    29  
 3 toyota       corolla      auto(l4)    2008    29  
 4 toyota       corolla      auto(l4)    1999    27  
 5 toyota       corolla      auto(l3)    1999    26  
 6 toyota       camry solara auto(s5)    2008    25  
 7 toyota       camry        manual(m5)  2008    24.3
 8 toyota       camry        auto(l5)    2008    24.3
 9 toyota       camry solara manual(m5)  2008    24.3
10 toyota       camry        manual(m5)  1999    23.7
```

Exercise
===
type:prompt
incremental:true

In the first lecture we identified that sports cars (`class=="2seater"`) were outliers in the plot of displacement vs. highway mileage. Use `mutate()` as part of your answer to produce a plot where just the sports cars are a different color than the other cars:

![plot of chunk unnamed-chunk-45](2-data-transformation-figure/unnamed-chunk-45-1.png)


```r
> sports = mutate(mpg, sports_car = class=="2seater")
> ggplot(sports) + 
+   geom_point(aes(x=displ, y=hwy, color=sports_car))
```

<!-- ^^  COMPLETE   ^^ -->
<!-- vv IN PROGRESS vv -->

summarize() computes desired summaires across rows
================================================================

```r
> summarize(mtc, mpg_avg = mean(mpg))
Error in summarize(mtc, mpg_avg = mean(mpg)): object 'mtc' not found
```
- `summarize()` boils down the data frame according to the conditions it gets. In this case, it creates a data frame with a single column called `mpg_avg` that contains the mean of the `mpg` column
- Summaries can be very useful when you apply them to subgoups of the data, which we will soon see how to do.

summarize() computes desired summaires across rows
================================================================
- you can also pass in multiple conditions that operate on multiple columns at the same time

```r
> summarize(mtc, # newlines not necessary, again just increase clarity
+           mpg_avg = mean(mpg),
+           mpg_2x_max = max(2*mpg),
+           hp_mpg_ratio_min = min(hp/mpg))
Error in summarize(mtc, mpg_avg = mean(mpg), mpg_2x_max = max(2 * mpg), : object 'mtc' not found
```

dplyr verbs summary
========================================================

- `filter()` picks out rows according to specified conditions
- `select()` picks out columns according to their names
- `arrange()` sorts the row by values in some column(s)
- `mutate()` creates new columns, often based on operations on other columns
- `summarize()` collapses many values in one or more columns down to one value per column

All verbs work similarly:

1. The first argument is a data frame.
2. The subsequent arguments describe what to do with the data frame, using the variable names (without quotes).
3. The result is a new data frame.

Together these properties make it easy to chain together multiple simple steps to achieve a complex result.

Computing over groups
==================================================================
type: section


group_by() groups data according to some variable(s)
==================================================================
First, let's load in some new data.

```r
> data1 <- read_csv("http://stanford.edu/~sbagley2/bios205/data/data1.csv")
Error in open.connection(con, "rb"): HTTP error 404.
> data1
Error in eval(expr, envir, enclos): object 'data1' not found
```
- `<chr>` is short for "character string", which means text data
- Let's compute the mean weight for each gender.
- There are two values of gender in this data, so there will be two groups.
- The following builds a new version of the data frame that saves the grouping information:

```r
> data1_by_gender <- group_by(data1, gender)
Error in group_by(data1, gender): object 'data1' not found
```
- We can now use the grouped data frame in further calculations.

group_by() groups data according to some variable(s)
==================================================================

```r
> data1_by_gender
Error in eval(expr, envir, enclos): object 'data1_by_gender' not found
```
- The grouped data looks exactly the same, but under the hood, `R` knows that this is really two sub-data-frames (one for each group) instead of one.

Grouped summary: computing the mean of each group
===================================================================

```r
> summarize(data1_by_gender, mean_weight = mean(weight))
Error in summarize(data1_by_gender, mean_weight = mean(weight)): object 'data1_by_gender' not found
```
- `summarize()` works the same as before, except now it returns two rows instead of one because there are two groups that were defined by `group_by(gender)`.
- The result also always contains colunmns corresponding to the unique values of the grouping variable

Grouping can also be applied across multiple variables
===================================================================
- This computes the mean weight and the mean age for each group:

```r
> data1_by_gender_and_shoesize = group_by(data1, gender, shoesize)
Error in group_by(data1, gender, shoesize): object 'data1' not found
> summarize(data1_by_gender_and_shoesize, mean_weight = mean(weight), mean_age = mean(age))
Error in summarize(data1_by_gender_and_shoesize, mean_weight = mean(weight), : object 'data1_by_gender_and_shoesize' not found
```
- Now both `gender` and `shoesize` appear as columns in the result
- There are 3 rows because there are 3 unique combinations of `gender` and `shoesize` in the original data

Computing the number of rows in each group
=====================================================================
- The `n()` function counts the number of rows in each group:

```r
> summarize(data1_by_gender, count = n())
Error in summarize(data1_by_gender, count = n()): object 'data1_by_gender' not found
```


Computing the number of distinct values of a column in each group
=====================================================================
- The `n_distinct()` function counts the number of distinct (unique) values in the specified column:

```r
> summarize(data1_by_gender, n_sizes = n_distinct(shoesize))
Error in summarize(data1_by_gender, n_sizes = n_distinct(shoesize)): object 'data1_by_gender' not found
```
- Note: `distinct()` filters out any duplicate rows in a dataframe. The equivalent for vectors is `unique()`


Exercise: count states in each region
=====================================================================

```r
> state_data <- read_csv("http://stanford.edu/~sbagley2/bios205/data/state_data.csv")
Error in open.connection(con, "rb"): HTTP error 404.
> state_data
Error in eval(expr, envir, enclos): object 'state_data' not found
```
- How many states are in each region?


Answer: count states in each region
=====================================================================

```r
> state_data_by_region <- group_by(state_data, region)
Error in group_by(state_data, region): object 'state_data' not found
> summarize(state_data_by_region, n_states = n())
Error in summarize(state_data_by_region, n_states = n()): object 'state_data_by_region' not found
```


Challenge exercise: finding rows by group
===================================================================
`filter()` the grouped data in `data1_by_gender` to pick out the rows for the youngest male and female (hint: use `min()` and `==`).


Answer: finding rows by group
===================================================================

```r
> filter(data1_by_gender, age == min(age))
Error in filter(data1_by_gender, age == min(age)): object 'data1_by_gender' not found
```
- This shows how filter can be applied to grouped data. Instead of applying the condition across all the data, it applies it group-by-group.

Chaining: combining a sequence of function calls
=================================================================
type: section

Both nesting and temporary variables can be ugly and hard to read
=================================================================
- In this expression, the result of `summarize` is used as an argument to `arrange`.
- The operations are performed "inside out": first `summarize`, then `arrange`.

```r
> arrange(summarize(group_by(state_data, region), sd_area = sd(area)), sd_area)
```
- We could store the first result in a temporary variable:

```r
> state_data_by_region <- group_by(state_data, region)
Error in group_by(state_data, region): object 'state_data' not found
> region_area_sds <- summarize(state_data_by_region, sd_area = sd(area))
Error in summarize(state_data_by_region, sd_area = sd(area)): object 'state_data_by_region' not found
> arrange(region_area_sds, sd_area)
Error in arrange(region_area_sds, sd_area): object 'region_area_sds' not found
```


Chaining using the pipe operator
=================================================================
- Or, we can use a new operator, `%>%`, to "pipe" the result from the first
function call to the second function call.

```r
> state_data %>% group_by(region) %>% summarize(sd_area = sd(area)) %>% arrange(sd_area)
Error in eval(lhs, parent, parent): object 'state_data' not found
```

- This makes explicit the flow of data through operations:
  - Start with `state_data`
  - group it by region
  - summarize by region, computing `sd_area`
  - arrange rows by `sd_area`
- The code reads like instructions that a human could understand
- putting the function calls on different lines also improves readability

Pipe: details
=================================================================

```r
> df1 %>% fun(x)
```
is converted into:

```r
> fun(df1, x)
```
- That is: the thing being piped in is used as the _first_ argument of `fun`.
- The tidyverse functions are consistently designed so that the first argument is a data frame, and the result is a data frame, so piping always works as intended.

Pipe: details
=================================================================
- However, the pipe works for all variables and functions, not just tidyverse functions

```r
> c(1, 44, 21, 0, -4) %>% sum()
[1] 62
> sum(c(1, 44, 21, 0, -4))
[1] 62
> 1 %>% +1  # `+` is just a function that takes two arguments!
[1] 2
```

Piping to another position
===
- The pipe typically pipes into the first argument of a function, but you can use the `.` syntax to send the argument elsewhere:

```r
> values = c(1, 2, 3, NA)
> 
> TRUE %>% mean(values, na.rm = .)
[1] 2
```
- This is typically not done, but can be a handy shortcut in many situations

dplyr cheatsheet
============================================================
<div align="center">
<img src="https://www.rstudio.com/wp-content/uploads/2018/08/data-transformation.png", height=1000, width=1400>
</div>