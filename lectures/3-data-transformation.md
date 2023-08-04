Basic Tabular Data Manipulation	
========================================================
author: Alejandro Schuler, adapted from Steve Bagley and based on R for Data Science by Hadley Wickham, updated to include GTEx sample data by Nicole Ferraro
date: 2022
transition: none
width: 1680
height: 1050

- filter rows of a dataset based on conditions
- arrange rows of a dataset based on one or more columns
- select columns of a dataset
- mutate existing columns to create new columns
- use the pipe to combine multiple operations



<style>
.small-code pre code {
  font-size: 0.5em;
}
</style>



dplyr
========================================================
This section shows the basic data frame functions ("verbs") in the `dplyr` package (part of `tidyverse`).

<div align="center">
  <img src="https://d33wubrfki0l68.cloudfront.net/621a9c8c5d7b47c4b6d72e8f01f28d14310e8370/193fc/css/images/hex/dplyr.png"; style="max-width:500px;"; class="center">
</div>

dplyr verbs
========================================================
Each operation takes a data frame and produces a new data frame.

- `filter()` picks out rows according to specified conditions
- `select()` picks out columns according to their names
- `arrange()` sorts the row by values in some column(s)
- `mutate()` creates new columns, often based on operations on other columns
- `summarize()` collapses many values in one or more columns down to one value per column

These can all be used in conjunction with `group_by()` which changes the scope of each function from operating on the entire dataset to operating on it group-by-group. These six functions provide the "verbs" for a language of data manipulation.

All work similarly:

1. The first argument is a data frame.
2. The subsequent arguments describe what to do with the data frame, using the variable names (without quotes).
3. The result is a new data frame.

Together these properties make it easy to chain together multiple simple steps to achieve a complex result. 

GTEx data
===
This is a subset of the Genotype Tissue Expression (GTEx) dataset

- **The full dataset.** Includes gene expression data, measured via RNA-sequencing, from 54 post-mortem tissues in ~800 individuals. Whole genome sequencing is also available for these individuals as part of the GTEx v8 release, available through dbGaP. 
- **The subsetted dataset.** We are looking at expression data for just 78 individuals here, in four tissues including blood, heart, lung and liver. 
- **Data processing** The expression values have been normalized and corrected for technical covariates and are now in the form of Z-scores, which indicate the distance of a given expression value from the mean across all measurements of that gene in that tissue. 
- **Goal.** We will use the data here to illustrate different functions for data transformation, often focused on extracting individuals with extremely high or low expression values for a given gene as compared to the distribution across all samples.


**NOTE**: If copying the code, make sure there are no spaces in the download link (where it wraps to a new line).

```r
# Read subsetted data from online file - make sure there are no spaces
gtex = read_tsv('https://tinyurl.com/342rhdc2')

# Check number of rows
nrow(gtex)
[1] 389922
```

Filter rows with filter()
====
type: section

Filter rows with filter()
========================================================
- `filter()` lets you filter out rows of a dataset that meet a certain condition

![](http://ohi-science.org/data-science-training/img/rstudio-cheatsheet-filter.png)

Filter rows with filter()
========================================================
- `filter()` lets you filter out rows of a dataset that meet a certain condition
- It takes two arguments: the dataset and the condition


```r
filter(gtex, Blood >= 12)
# A tibble: 12 × 6
   Gene       Ind        Blood Heart  Lung Liver
   <chr>      <chr>      <dbl> <dbl> <dbl> <dbl>
 1 AC012358.7 GTEX-VUSG   13.6 -1.43  1.22 -0.39
 2 DCSTAMP    GTEX-12696  13.6 NA    -0.57 -0.91
 3 DIAPH2-AS1 GTEX-VUSG   12.2 -0.33  1.18  0.67
 4 DNASE2B    GTEX-12696  14.4 -0.82 -0.92  0.35
 5 FFAR4      GTEX-12696  12.9 -0.96 -0.67  0.18
 6 GAPDHP33   GTEX-UPK5   13.8  1.52 -1.48 -1.84
 7 GTF2A1L    GTEX-VUSG   12.2  1.67  0.78  0.09
 8 GTF2IP14   GTEX-11NV4  12.2  7.26  5.79  7.06
 9 KCNT1      GTEX-1KANB  13.5  3.14  0.62 -0.37
10 KLK3       GTEX-147F4  15.7 -0.74 -0.44 -0.02
11 NAPSA      GTEX-1CB4J  12.3 -0.29 -0.44 -0.14
12 REN        GTEX-U8XE   18.9 -0.57 NA     0.09
```

Comparison operators
=========================================================
- `==` and `!=` test for equality and inequality (do not use `=` for equality)
- `>` and `<` test for greater-than and less-than
- `>=` and `<=` are greater-than-or-equal and less-than-or-equal
- these can also be used directly on vectors outside of data frames

```r
c(1,5,-22,4) > 0
[1]  TRUE  TRUE FALSE  TRUE
```

Comparing to NA
===
- A common "gotcha" is that  `==`  cannot be used to compare to `NA`:

```r
x = NA
x == NA
[1] NA
```
- The result actually makes sense though, because I'm asking if "I don't know" is the same as "I don't know". Since either side could be any value, the right answer is "I don't know".
- To check if something is `NA`, use `is.na()`

```r
x = NA
is.na(x)
[1] TRUE
```

Filtering on computed values
========================================================
- the condition can contain computed values


```r
filter(gtex, exp(Blood) > 1)
# A tibble: 185,698 × 6
   Gene  Ind        Blood Heart  Lung Liver
   <chr> <chr>      <dbl> <dbl> <dbl> <dbl>
 1 A2ML1 GTEX-11TT1  0.3  -1.11  0.59 -0.12
 2 A2ML1 GTEX-11TUW  0.02 -0.47  0.29 -0.66
 3 A2ML1 GTEX-12WSD  0.53  0.36  0.2   0.51
 4 A2ML1 GTEX-12WSG  0.03 -0.64 -1.02  0.07
 5 A2ML1 GTEX-131XE  0.3   0.05  0.53 -0.87
 6 A2ML1 GTEX-132NY  0.42 -0.14 -0.27  1.47
 7 A2ML1 GTEX-13OW6  0.15 -0.13  1.06  0.24
 8 A2ML1 GTEX-147F4  0.2  -0.26  0.11 -0.76
 9 A2ML1 GTEX-147JS  0.36 -0.45 -0.34 -1.39
10 A2ML1 GTEX-14DAQ  0.1   0.69  0.99 -0.79
# ℹ 185,688 more rows
```
- note that we didn't actually do anything to the values in the blood column


Filtering out all rows
=========================================================

```r
filter(gtex, Blood > 10000)
# A tibble: 0 × 6
# ℹ 6 variables: Gene <chr>, Ind <chr>, Blood <dbl>, Heart <dbl>, Lung <dbl>,
#   Liver <dbl>
```
- If you ever get a data frame of length zero, it's because no rows satisfy the condition you asked for


Exercise
========================================================
type:prompt

- What is the result of running this code?


```r
nrow(gtex)
[1] 389922
```


```r
filter(gtex, Gene == ZZZ3)
filter(gtex, Heart <= -5)
nrow(gtex)
```


Exercise
========================================================
type:prompt

- Without using the internet, think of how you can use `filter` multiple times to create a dataset
where blood expression is positive (>0) **and** heart expression is negative (<0)

- Using any resources you like, figure out how to use `filter` to create a dataset
where **either** blood expression is positive (>0) **or** heart expression is negative (<0)

Logical conjunctions (AND)
========================================================

```r
filter(gtex, Blood <= -5 & Heart <= -5)
# A tibble: 3 × 6
  Gene     Ind        Blood  Heart   Lung Liver
  <chr>    <chr>      <dbl>  <dbl>  <dbl> <dbl>
1 ATP5A1   GTEX-YFC4  -5.35  -6.05  -7.96 -4.4 
2 GHITM    GTEX-WK11  -5.7   -7.24  -7.37 -4.06
3 MTATP6P1 GTEX-1KD5A -9.18 -10.1  -10.3  -9.52
```
- This filters by the **conjunction** of the two constraints---both must be satisfied.
- The ampersand sign ` & ` stands for "AND"


```r
filter(gtex, Blood <= -5, Heart <= -5)
# A tibble: 3 × 6
  Gene     Ind        Blood  Heart   Lung Liver
  <chr>    <chr>      <dbl>  <dbl>  <dbl> <dbl>
1 ATP5A1   GTEX-YFC4  -5.35  -6.05  -7.96 -4.4 
2 GHITM    GTEX-WK11  -5.7   -7.24  -7.37 -4.06
3 MTATP6P1 GTEX-1KD5A -9.18 -10.1  -10.3  -9.52
```
- For filter, you can do "AND" by passing in two separate conditions as two different arguments, but the comma and ampersand are not generally interchangeable

Logical conjunctions (OR)
=========================================================

```r
filter(gtex, Gene == "A2ML1" | Gene == "A4GALT")
# A tibble: 156 × 6
   Gene  Ind        Blood Heart  Lung Liver
   <chr> <chr>      <dbl> <dbl> <dbl> <dbl>
 1 A2ML1 GTEX-11DXZ -0.14 -1.08 NA    -0.66
 2 A2ML1 GTEX-11GSP -0.5   0.53  0.76 -0.1 
 3 A2ML1 GTEX-11NUK -0.08 -0.4  -0.26 -0.13
 4 A2ML1 GTEX-11NV4 -0.37  0.11 -0.42 -0.61
 5 A2ML1 GTEX-11TT1  0.3  -1.11  0.59 -0.12
 6 A2ML1 GTEX-11TUW  0.02 -0.47  0.29 -0.66
 7 A2ML1 GTEX-11ZUS -1.07 -0.41  0.67  0.06
 8 A2ML1 GTEX-11ZVC -0.27 -0.51  0.13 -0.75
 9 A2ML1 GTEX-1212Z -0.3   0.53  0.1  -0.48
10 A2ML1 GTEX-12696 -0.11  0.24  0.96  0.72
# ℹ 146 more rows
```
- The pipe sign ` | ` stands for "OR" 
- Multiple conjunctions can describe complex logical conditions

Logical conjunctions (OR)
=========================================================

```r
filter(gtex, Gene %in% c(ZZZ3,A2ML1)) # equivalent to filter(gtex, Gene==ZZZ3 | Gene==A2ML1)
Error in `filter()`:
ℹ In argument: `Gene %in% c(ZZZ3, A2ML1)`.
Caused by error:
! object 'ZZZ3' not found
```
- ` %in% ` returns true for all elements of the thing on the left that are also elements of the thing on the right. This is actually shorthand for a match function (use `help('%in%')` to learn more)

Negation (NOT)
=========================================================

```r
filter(gtex, !(Gene=="A2ML1"))
# A tibble: 389,844 × 6
   Gene    Ind        Blood Heart  Lung Liver
   <chr>   <chr>      <dbl> <dbl> <dbl> <dbl>
 1 A3GALT2 GTEX-11DXZ -0.48 -1     1.83 -0.4 
 2 A3GALT2 GTEX-11GSP -0.39  2.09  0.88 -0.78
 3 A3GALT2 GTEX-11NUK -0.36 -0.27 NA     0.2 
 4 A3GALT2 GTEX-11NV4 -0.77 -0.08  0.13  0.06
 5 A3GALT2 GTEX-11TT1 -1.4   1.29  1.45  1.57
 6 A3GALT2 GTEX-11TUW  0.15 -3.41  0.96 -0.83
 7 A3GALT2 GTEX-11ZUS -0.03 -0.32  0.25 -0.73
 8 A3GALT2 GTEX-11ZVC -0.21 -0.75  0.59 -0.66
 9 A3GALT2 GTEX-1212Z  0.36 -0.12  0.78  1.5 
10 A3GALT2 GTEX-12696 -0.25 -0.31 -0.03  2.62
# ℹ 389,834 more rows
```
- The exclamation point ` ! ` means "NOT", which negates the logical condition
- sometimes it's easier to say what you *don't* want!

Exercise: computed conditions
==========================================================
type: prompt

- Filter the GTEX data to keep just the rows where the product of Blood and Heart expression is between 0 and 1.

Exercise: conjunctions
==========================================================
type: prompt

Excluding the gene `LAMP3`, does the individual `GTEX-11TT1` have any genes with expression level greater than 4 in their blood?

Exercise: getting rid of NAs
==========================================================
type: prompt

- Filter out any rows where the value for `Heart` is missing (value is `NA`) 

Sampling rows
==========================================================
- You can use `slice_sample()` to get `n` randomly selected rows if you don't have a particular condition you would like to filter on.


```r
slice_sample(gtex, n=5)
# A tibble: 5 × 6
  Gene   Ind        Blood Heart  Lung Liver
  <chr>  <chr>      <dbl> <dbl> <dbl> <dbl>
1 IGSF23 GTEX-12WSI -0.16 -0.16 -0.2   0.89
2 DENND3 GTEX-14XAO  1.53 -0.45 -0.09  0.49
3 PRKAA2 GTEX-1KANB -0.67 -1.46  1.21 -0.91
4 MNDA   GTEX-11GSP  1.1  -0.8  -0.1   1   
5 RETSAT GTEX-1GN2E  0.67  0.23 -1.51  0.39
```

- the named argument `prop` allows you to sample a proportion of rows
- Do `?slice_sample()` to see how you can sample with replacement or with weights

Filtering by row number
==========================================================

- Use `row_number()` to filter specific rows. This is more useful once you have sorted the data in a particular order, which we will soon see how to do.


```r
filter(gtex, row_number()<=3)
# A tibble: 3 × 6
  Gene  Ind        Blood Heart  Lung Liver
  <chr> <chr>      <dbl> <dbl> <dbl> <dbl>
1 A2ML1 GTEX-11DXZ -0.14 -1.08 NA    -0.66
2 A2ML1 GTEX-11GSP -0.5   0.53  0.76 -0.1 
3 A2ML1 GTEX-11NUK -0.08 -0.4  -0.26 -0.13
```

Sort rows by a column with arrange()
===
type:section

Arrange rows with arrange()
===========================================================
- `arrange()` takes a data frame and a column, and sorts the rows by the values in that column (ascending order).

![](https://rstudio-education.github.io/tidyverse-cookbook/images/dplyr-arrange.png)

Arrange rows with arrange()
===========================================================
- `arrange()` takes a data frame and a column, and sorts the rows by the values in that column (ascending order).
- Again, the first argument is the data frame and the other arguments tell the function what to do with it

```r
arrange(gtex, Blood)
# A tibble: 389,922 × 6
   Gene        Ind        Blood  Heart   Lung Liver
   <chr>       <chr>      <dbl>  <dbl>  <dbl> <dbl>
 1 HBA2        GTEX-11DXZ -9.44  -1.52  -1.44 -2.15
 2 MTATP6P1    GTEX-1KD5A -9.18 -10.1  -10.3  -9.52
 3 RP11-46D6.1 GTEX-14E1K -7.83  -3.94  -5.22 -4.49
 4 CYTH3       GTEX-11NV4 -6.63  -0.6   -0.37 -1.32
 5 TRG-AS1     GTEX-11NV4 -6.47   2.39  -0.6  -0.22
 6 SMG1P1      GTEX-11ZUS -6.26  -1.68  -1.41 -0.31
 7 ZBTB10      GTEX-VUSG  -6.13   0.77   0.51 -0.67
 8 RPS29       GTEX-1B8L1 -5.84  -0.8   -0.46 -0.17
 9 GHITM       GTEX-WK11  -5.7   -7.24  -7.37 -4.06
10 ZNF2        GTEX-VUSG  -5.62   1.52   0.61  0.13
# ℹ 389,912 more rows
```

Arrange can sort by more than one column
===========================================================
- This is useful if there is a tie in sorting by the first column.


```r
arrange(gtex, Gene, Blood)
# A tibble: 389,922 × 6
   Gene  Ind        Blood Heart  Lung Liver
   <chr> <chr>      <dbl> <dbl> <dbl> <dbl>
 1 A2ML1 GTEX-1B8L1 -1.4   0.37 -1.05  0.07
 2 A2ML1 GTEX-ZVT3  -1.35  1.01  2.91 -0.28
 3 A2ML1 GTEX-1AX9I -1.29 -0.19 -0.41 -0.78
 4 A2ML1 GTEX-1A32A -1.16  0.44 -0.41 -0.39
 5 A2ML1 GTEX-1GN73 -1.13 -0.05 -0.21 -0.82
 6 A2ML1 GTEX-11ZUS -1.07 -0.41  0.67  0.06
 7 A2ML1 GTEX-18A7A -1.01 -0.74 -0.72 -0.76
 8 A2ML1 GTEX-17EVP -1    -0.18 -0.2  -0.95
 9 A2ML1 GTEX-U8XE  -0.88 -0.91 NA    -0.86
10 A2ML1 GTEX-131YS -0.78 NA     0.17 -1.5 
# ℹ 389,912 more rows
```


Use the desc function to arrange by descending values
===========================================================


```r
arrange(gtex, desc(Blood))
# A tibble: 389,922 × 6
   Gene       Ind        Blood Heart  Lung Liver
   <chr>      <chr>      <dbl> <dbl> <dbl> <dbl>
 1 REN        GTEX-U8XE   18.9 -0.57 NA     0.09
 2 KLK3       GTEX-147F4  15.7 -0.74 -0.44 -0.02
 3 DNASE2B    GTEX-12696  14.4 -0.82 -0.92  0.35
 4 GAPDHP33   GTEX-UPK5   13.8  1.52 -1.48 -1.84
 5 DCSTAMP    GTEX-12696  13.6 NA    -0.57 -0.91
 6 AC012358.7 GTEX-VUSG   13.6 -1.43  1.22 -0.39
 7 KCNT1      GTEX-1KANB  13.5  3.14  0.62 -0.37
 8 FFAR4      GTEX-12696  12.9 -0.96 -0.67  0.18
 9 NAPSA      GTEX-1CB4J  12.3 -0.29 -0.44 -0.14
10 DIAPH2-AS1 GTEX-VUSG   12.2 -0.33  1.18  0.67
# ℹ 389,912 more rows
```

Exercise: top 5 high expression instances
===========================================================
type:prompt

Use `arrange()` and `filter()` to get the data for the 5 rows with the highest expression values in blood

Exercise: top 5 high expression instances
===========================================================
type:prompt

Use `arrange()` and `filter()` to get the data for the 5 rows with the highest expression values in blood


```r
filter(arrange(gtex, desc(Blood)), row_number()<=5) # "nesting" the calls to filter and arrange
# A tibble: 5 × 6
  Gene     Ind        Blood Heart  Lung Liver
  <chr>    <chr>      <dbl> <dbl> <dbl> <dbl>
1 REN      GTEX-U8XE   18.9 -0.57 NA     0.09
2 KLK3     GTEX-147F4  15.7 -0.74 -0.44 -0.02
3 DNASE2B  GTEX-12696  14.4 -0.82 -0.92  0.35
4 GAPDHP33 GTEX-UPK5   13.8  1.52 -1.48 -1.84
5 DCSTAMP  GTEX-12696  13.6 NA    -0.57 -0.91
```
or

```r
gtex_by_blood = arrange(gtex, desc(Blood)) # using a temporary variable
filter(gtex_by_blood, row_number()<=5)
# A tibble: 5 × 6
  Gene     Ind        Blood Heart  Lung Liver
  <chr>    <chr>      <dbl> <dbl> <dbl> <dbl>
1 REN      GTEX-U8XE   18.9 -0.57 NA     0.09
2 KLK3     GTEX-147F4  15.7 -0.74 -0.44 -0.02
3 DNASE2B  GTEX-12696  14.4 -0.82 -0.92  0.35
4 GAPDHP33 GTEX-UPK5   13.8  1.52 -1.48 -1.84
5 DCSTAMP  GTEX-12696  13.6 NA    -0.57 -0.91
```

- what happens if we reverse the order in which we did `filter` and `arrange`? Does it still work?

Select columns with select()
===
type:section

Select columns with select()
=========================================================
- The select function will return a subset of the tibble, using only the requested columns in the order specified.

![](http://ohi-science.org/data-science-training/img/rstudio-cheatsheet-select.png)

Select columns with select()
=========================================================
- The select function will return a subset of the tibble, using only the requested columns in the order specified.
- first argument is a data frame, then columns you want to select


```r
select(gtex, Gene, Ind, Blood)
# A tibble: 389,922 × 3
   Gene  Ind        Blood
   <chr> <chr>      <dbl>
 1 A2ML1 GTEX-11DXZ -0.14
 2 A2ML1 GTEX-11GSP -0.5 
 3 A2ML1 GTEX-11NUK -0.08
 4 A2ML1 GTEX-11NV4 -0.37
 5 A2ML1 GTEX-11TT1  0.3 
 6 A2ML1 GTEX-11TUW  0.02
 7 A2ML1 GTEX-11ZUS -1.07
 8 A2ML1 GTEX-11ZVC -0.27
 9 A2ML1 GTEX-1212Z -0.3 
10 A2ML1 GTEX-12696 -0.11
# ℹ 389,912 more rows
```

Select columns with select()
=========================================================
- `select()` can also be used with handy helpers like `starts_with()` and `contains()`


```r
select(gtex, starts_with("L"))
# A tibble: 389,922 × 2
    Lung Liver
   <dbl> <dbl>
 1 NA    -0.66
 2  0.76 -0.1 
 3 -0.26 -0.13
 4 -0.42 -0.61
 5  0.59 -0.12
 6  0.29 -0.66
 7  0.67  0.06
 8  0.13 -0.75
 9  0.1  -0.48
10  0.96  0.72
# ℹ 389,912 more rows
```
- Use `?select` to see all the possibilities

***


```r
select(gtex, contains("N"))
# A tibble: 389,922 × 3
   Gene  Ind         Lung
   <chr> <chr>      <dbl>
 1 A2ML1 GTEX-11DXZ NA   
 2 A2ML1 GTEX-11GSP  0.76
 3 A2ML1 GTEX-11NUK -0.26
 4 A2ML1 GTEX-11NV4 -0.42
 5 A2ML1 GTEX-11TT1  0.59
 6 A2ML1 GTEX-11TUW  0.29
 7 A2ML1 GTEX-11ZUS  0.67
 8 A2ML1 GTEX-11ZVC  0.13
 9 A2ML1 GTEX-1212Z  0.1 
10 A2ML1 GTEX-12696  0.96
# ℹ 389,912 more rows
```
- The quotes around the letter `"N"` make it a string. If we did not do this, `R` would think it was looking for a variable called `N` and not just the plain letter.
- We don't have to quote the names of columns (like `Ind`) because the `tidyverse` functions know that we are working within the dataframe and thus treat the column names like they are variables in their own right

select() subsets columns by name
=========================================================
- `select()` can also be used to select everything **except for** certain columns

```r
select(gtex, -starts_with("L"), -Ind)
# A tibble: 389,922 × 3
   Gene  Blood Heart
   <chr> <dbl> <dbl>
 1 A2ML1 -0.14 -1.08
 2 A2ML1 -0.5   0.53
 3 A2ML1 -0.08 -0.4 
 4 A2ML1 -0.37  0.11
 5 A2ML1  0.3  -1.11
 6 A2ML1  0.02 -0.47
 7 A2ML1 -1.07 -0.41
 8 A2ML1 -0.27 -0.51
 9 A2ML1 -0.3   0.53
10 A2ML1 -0.11  0.24
# ℹ 389,912 more rows
```

***

- or even to select only columns that match a certain condition


```r
select(gtex, where(is.numeric))
# A tibble: 389,922 × 4
   Blood Heart  Lung Liver
   <dbl> <dbl> <dbl> <dbl>
 1 -0.14 -1.08 NA    -0.66
 2 -0.5   0.53  0.76 -0.1 
 3 -0.08 -0.4  -0.26 -0.13
 4 -0.37  0.11 -0.42 -0.61
 5  0.3  -1.11  0.59 -0.12
 6  0.02 -0.47  0.29 -0.66
 7 -1.07 -0.41  0.67  0.06
 8 -0.27 -0.51  0.13 -0.75
 9 -0.3   0.53  0.1  -0.48
10 -0.11  0.24  0.96  0.72
# ℹ 389,912 more rows
```

Exercise: select and filter
===
type:prompt

A colleague wants to see the blood expression for the gene A2ML1 for each person. Use select and filter to produce a dataframe for her that has just two columns: `individual` and `expression`, where the expression values are the blood expression values for each person for the gene A2ML1.

Before writing any code, break the problem down conceptually into steps. Figure out how to do each step independently before you put them together.

Exercise: select text columns
===
type:prompt

- Use select to subset the `gtex` dataframe to just those columns that contain text data. 
- Can you do this programmatically without specifying the names of each of the desired columns? 
- Which base R function will help you determine if a column is textual or not? Use whatever tools you want to find out.

pull() is a friend of select()
=========================================================
- `select()` has a friend called `pull()` which returns a vector instead of a (one-column) data frame

![](https://www.gastonsanchez.com/intro2cwd/images/eda/dplyr-extract-column.svg)


```r
pull(gtex, Gene)
    [1] "A2ML1"              "A2ML1"              "A2ML1"             
    [4] "A2ML1"              "A2ML1"              "A2ML1"             
    [7] "A2ML1"              "A2ML1"              "A2ML1"             
...
```

***


```r
select(gtex, Gene)
# A tibble: 389,922 × 1
   Gene 
   <chr>
 1 A2ML1
 2 A2ML1
 3 A2ML1
 4 A2ML1
 5 A2ML1
 6 A2ML1
 7 A2ML1
 8 A2ML1
 9 A2ML1
10 A2ML1
# ℹ 389,912 more rows
```




Rename column names with rename()
=========================================================
- `select()` can be used to rename variables, but it drops all variables not selected

```r
select(gtex, individual = Ind)
# A tibble: 389,922 × 1
   individual
   <chr>     
 1 GTEX-11DXZ
 2 GTEX-11GSP
 3 GTEX-11NUK
...
```

- `rename()` is better suited for this because it keeps all the columns

```r
rename(gtex, individual = Ind)
# A tibble: 389,922 × 6
   Gene  individual Blood Heart  Lung Liver
   <chr> <chr>      <dbl> <dbl> <dbl> <dbl>
 1 A2ML1 GTEX-11DXZ -0.14 -1.08 NA    -0.66
 2 A2ML1 GTEX-11GSP -0.5   0.53  0.76 -0.1 
 3 A2ML1 GTEX-11NUK -0.08 -0.4  -0.26 -0.13
...
```

Note: `mutate()`, can also change a column name (more on `mutate()` soon)


Add new variables with mutate()
===
type:section

Add new variables with mutate()
================================================================
- `muatate` creates new columns

![](https://ohi-science.org/data-science-training/img/rstudio-cheatsheet-mutate.png)

Add new variables with mutate()
================================================================
- `muatate` creates new columns
- first argument is a dataframe, second specifies what you want the new columns to be

```r
mutate(gtex, abs_blood = abs(Blood))
# A tibble: 389,922 × 7
   Gene  Ind        Blood Heart  Lung Liver abs_blood
   <chr> <chr>      <dbl> <dbl> <dbl> <dbl>     <dbl>
 1 A2ML1 GTEX-11DXZ -0.14 -1.08 NA    -0.66      0.14
 2 A2ML1 GTEX-11GSP -0.5   0.53  0.76 -0.1       0.5 
...
```
- This uses `mutate()` to add a new column to which is the absolute value of `Blood`.
- The thing on the left of the `=` is a new name that you make up which you would like the new column to be called
- The expression on the right of the `=` defines what will go into the new column
- **Warning!** If the new variable name already exists, `mutate()` will overwrite the existing one

```r
mutate(gtex, Blood = Blood *1000)
# A tibble: 389,922 × 6
   Gene  Ind        Blood Heart  Lung Liver
   <chr> <chr>      <dbl> <dbl> <dbl> <dbl>
 1 A2ML1 GTEX-11DXZ  -140 -1.08 NA    -0.66
 2 A2ML1 GTEX-11GSP  -500  0.53  0.76 -0.1 
...
```

mutate() can create multiple new columns at once
================================================================
- `mutate()` can create multiple columns at the same time and use multiple columns to define a single new one


```r
mutate(gtex, # the newlines make it more readable
      abs_blood = abs(Blood),
      abs_heart = abs(Heart),
      blood_heart_dif = abs_blood - abs_heart
)
# A tibble: 389,922 × 9
   Gene  Ind        Blood Heart  Lung Liver abs_blood abs_heart blood_heart_dif
   <chr> <chr>      <dbl> <dbl> <dbl> <dbl>     <dbl>     <dbl>           <dbl>
 1 A2ML1 GTEX-11DXZ -0.14 -1.08 NA    -0.66      0.14      1.08         -0.94  
 2 A2ML1 GTEX-11GSP -0.5   0.53  0.76 -0.1       0.5       0.53         -0.0300
 3 A2ML1 GTEX-11NUK -0.08 -0.4  -0.26 -0.13      0.08      0.4          -0.32  
 4 A2ML1 GTEX-11NV4 -0.37  0.11 -0.42 -0.61      0.37      0.11          0.26  
 5 A2ML1 GTEX-11TT1  0.3  -1.11  0.59 -0.12      0.3       1.11         -0.81  
 6 A2ML1 GTEX-11TUW  0.02 -0.47  0.29 -0.66      0.02      0.47         -0.45  
 7 A2ML1 GTEX-11ZUS -1.07 -0.41  0.67  0.06      1.07      0.41          0.66  
 8 A2ML1 GTEX-11ZVC -0.27 -0.51  0.13 -0.75      0.27      0.51         -0.24  
 9 A2ML1 GTEX-1212Z -0.3   0.53  0.1  -0.48      0.3       0.53         -0.23  
10 A2ML1 GTEX-12696 -0.11  0.24  0.96  0.72      0.11      0.24         -0.13  
# ℹ 389,912 more rows
```
- Note that we have also used two columns simultaneously (`Blood` and `Heart`) to create a new column)

mutate() for data type conversion
===
- Data is sometimes given to you in a form that makes it difficult to do operations on

```r
df = tibble(number = c("1", "2", "3"))
df
# A tibble: 3 × 1
  number
  <chr> 
1 1     
2 2     
3 3     
mutate(df, number_plus_1 = number + 1)
Error in `mutate()`:
ℹ In argument: `number_plus_1 = number + 1`.
Caused by error in `number + 1`:
! non-numeric argument to binary operator
```

- `mutate()` is also useful for converting data types, in this case text to numbers

```r
mutate(df, number = as.numeric(number))
# A tibble: 3 × 1
  number
   <dbl>
1      1
2      2
3      3
```

Exercise: mutate()
===
type:prompt

I want to see if certain genes are generally more highly expressed in certain individuals, irrespective of tissue type. Using the GTEX data, create a new column containing the average of the four expression measurements in the different tissues.


Exercise: mutate() and ggplot
===
type:prompt

Filter `gtex` to only include measurements of the MYL1 gene. Then, use mutate to mark which gene-individual pairs have outlier MYL1 expression in blood, defined as Z > 3 or Z < -3. Then, produce a plot showing blood Z-scores vs heart Z-scores and color the blood gene expression outliers in a different color than the other points.

![plot of chunk unnamed-chunk-37](3-data-transformation-figure/unnamed-chunk-37-1.png)


Exercise: putting it together
===
type:prompt

Produce a vector containing the ten individual IDs (`Ind`) with the biggest absolute difference in their heart and lung expression for the A2ML1 gene.

Before writing any code, break the problem down conceptually into steps. Do you have to create new columns? Filter the rows of a dataset? Arrange rows? Select certain columns? In what order? Once you have a plan, write code, one step at a time.



mutate() and if_else()
===
- `if_else` is a vectorized if-else statement
- the first argument is an R expression that evaluates to a logical vector, the second argument is what to replace all of the resulting TRUEs with, and the third argument is what to replace the resulting FALSEs with

```r
x = c(-1, 1/2, 2/3, 5)
if_else(0<=x & x<=1, "in [0,1]", "not in [0,1]")
[1] "not in [0,1]" "in [0,1]"     "in [0,1]"     "not in [0,1]"
```
- this is often used in `mutate()`:

```r
mutate(
  gtex, 
  blood_expression = ifelse(
    Blood < 0, 
    "-", "+"
  )
)
# A tibble: 389,922 × 7
   Gene  Ind        Blood Heart  Lung Liver blood_expression
   <chr> <chr>      <dbl> <dbl> <dbl> <dbl> <chr>           
 1 A2ML1 GTEX-11DXZ -0.14 -1.08 NA    -0.66 -               
 2 A2ML1 GTEX-11GSP -0.5   0.53  0.76 -0.1  -               
 3 A2ML1 GTEX-11NUK -0.08 -0.4  -0.26 -0.13 -               
 4 A2ML1 GTEX-11NV4 -0.37  0.11 -0.42 -0.61 -               
 5 A2ML1 GTEX-11TT1  0.3  -1.11  0.59 -0.12 +               
 6 A2ML1 GTEX-11TUW  0.02 -0.47  0.29 -0.66 +               
 7 A2ML1 GTEX-11ZUS -1.07 -0.41  0.67  0.06 -               
...
```

mutate() and if_else()
===
- this is useful to "interleave" columns:

```
# A tibble: 4 × 4
  name  school             personal            preferred
  <chr> <chr>              <chr>               <chr>    
1 aya   aya@amherst.edu    aya@aol.com         school   
2 bilal bilal@berkeley.edu bilal@bellsouth.net personal 
3 chris chris@cornell.edu  chris@comcast.com   personal 
4 diego diego@duke.edu     diego@dodo.com.au   school   
```


```r
mutate(emails,
  preferred_email = ifelse(preferred=='personal', personal, school)
)
# A tibble: 4 × 5
  name  school             personal            preferred preferred_email    
  <chr> <chr>              <chr>               <chr>     <chr>              
1 aya   aya@amherst.edu    aya@aol.com         school    aya@amherst.edu    
2 bilal bilal@berkeley.edu bilal@bellsouth.net personal  bilal@bellsouth.net
3 chris chris@cornell.edu  chris@comcast.com   personal  chris@comcast.com  
4 diego diego@duke.edu     diego@dodo.com.au   school    diego@duke.edu     
```


Piping
===
type:section

Why pipe?
===

- In our last exercise, we used a number of different function applications to arrive at our answer. Shown below, we used temporary variables to keep our code clean. 


```r
gtex_A2ML1 = filter(gtex, Gene=="A2ML1")
gtex_diff = mutate(gtex_A2ML1, diff = abs(Heart-Lung))
gtex_sort = arrange(gtex_diff, desc(diff))
gtex_top = filter(gtex_sort, row_number()<=10)
pull(gtex_top, Ind)
```

- Compare that to the same code using nested calls (instead of storing in temporary variables):


```r
pull(
  filter(
    arrange(
      mutate(
        filter(
          gtex, Gene=="A2ML1"),
        diff = abs(Heart-Lung)),
      desc(diff)),
    row_number()<=10),
  Ind
)
```

- What makes either of these hard to read or understand?

The pipe operator
===

- Tidyverse solves these problems with the pipe operator `%>%`


```r
gtex %>% 
    filter(Gene == 'A2ML1') %>%
    mutate(diff = abs(Heart-Lung)) %>%
    arrange(desc(diff)) %>%
    filter(row_number() <= 10) %>%
    pull(Ind)
```


The pipe operator
===

- Tidyverse solves these problems with the pipe operator `%>%`


```r
gtex %>% 
    filter(Gene == 'A2ML1') %>%
    mutate(diff = abs(Heart-Lung)) %>%
    arrange(desc(diff)) %>%
    filter(row_number() <= 10) %>%
    pull(Ind)
```

- How does this compare with our code before? What do you notice?


```r
gtex_A2ML1 = filter(gtex, Gene=="A2ML1")
gtex_diff = mutate(gtex_A2ML1, diff = abs(Heart-Lung))
gtex_sort = arrange(gtex_diff, desc(diff))
gtex_top = filter(gtex_sort, row_number()<=10)
pull(gtex_top, Ind)
```


Pipe details: What happens to an object when it gets "piped in"?
=================================================================

When `df1` is piped into `fun(x)` (`fun` is just some fake function)


```r
df1 %>% fun(x)
```

is converted into:


```r
fun(df1, x)
```

- That is: the thing being piped in is used as the _first_ argument of `fun`.
- The tidyverse functions are consistently designed so that the first argument is a data frame, and the result is a data frame, so you can push a dataframe all the way through a series of functions

Pipe details: What objects can be piped?
=================================================================
- The pipe works for all variables and functions (not just tidyverse functions)

Piping with a vector


```r
c(1,44,21,0,-4) %>%
    sum() # instead of sum(c(1,44,21,0,-4))
[1] 62
```

Piping with a scalar


```r
1 %>% `+`(1) # `+` is just a function that takes two arguments!
[1] 2
```

Piping with a data frame


```r
tibble(
  name = c("Petunia", "Rose", "Daisy", "Marigold", "Arabidopsis"),
  age = c(10,54,21,99,96)
) %>%
filter(age > 30) 
# A tibble: 3 × 2
  name          age
  <chr>       <dbl>
1 Rose           54
2 Marigold       99
3 Arabidopsis    96
```

Exercise: Pipe to ggplot
===
type:prompt

- Run this code to see what it does. Then rewrite it using the pipe operator and get it to produce the same output.


```r
gene_data = filter(gtex, Gene == 'MYBL2')
outliers = mutate(gene_data, blood_outlier = abs(Blood) > 2)
ggplot(outliers) +
  geom_bar(aes(x=blood_outlier)) +
  scale_x_discrete("Class", labels=c("Other", "Outlier")) +
  ggtitle("How many individuals have outlier MYBL2 expression in blood?")
```

============================================================
<div align="center">
<img src="https://miro.medium.com/max/1200/1*O4LZwd_rTEGY2zMyDkvR9A.png"; style="max-width:1500;"; class="center">
</div>

Source: [Rstudio Cheat Sheets](https://www.google.com/search?client=safari&rls=en&q=data+transformation+with+dplyr+cheat+sheet&ie=UTF-8&oe=UTF-8). Download the [full dplyr cheat sheet here.](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwiP_KO4m9_xAhVYOs0KHfRUCfgQFnoECAQQAA&url=https%3A%2F%2Fraw.githubusercontent.com%2Frstudio%2Fcheatsheets%2Fmaster%2Fdata-transformation.pdf&usg=AOvVaw3vYk678LtmDz7gbHCvDeM0)
<!-- ^^  COMPLETE   ^^ -->
