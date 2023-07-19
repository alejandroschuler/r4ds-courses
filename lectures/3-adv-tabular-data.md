Advanced Tabular Data Manipulation	
========================================================
author: Alejandro Schuler, adapted from Steve Bagley and based on R for Data Science by Hadley Wickham
date: 2022
transition: none
width: 1680
height: 1050

- group and summarize data by one or more columns
- use the pipe to combine multiple operations
- transform between long and wide data formats
- combine multiple data frames using joins on one or more columns


<style>
.small-code pre code {
  font-size: 0.5em;
}
</style>


Tidy data: rearranging a data frame
============================================================
type: section

Messy data
============================================================
- Sometimes data are organized in a way that makes it difficult to compute in a vector-oriented way. For example, look at this dataset:


```r
gtex_time_link = 
  "https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/advance-2021/data/gtex_metadata/gtex_time_tissue.csv"

gtex_time_tissue_data = read_csv(file = gtex_time_link, col_types = cols())

head(gtex_time_tissue_data, 3L)
# A tibble: 3 × 8
  tissue         `2011` `2012` `2013` `2014` `2015` `2016` `2017`
  <chr>           <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
1 Adipose Tissue     56    107    243    206     84    134      2
2 Adrenal Gland      28     41     84     65     20     31      0
3 Bladder             2     18      0      1      0      0      0
```

- the values in the table represent how many samples of that tissue were collected during that year.
- How could I use ggplot to make this plot? It's hard!



![plot of chunk unnamed-chunk-4](3-adv-tabular-data-figure/unnamed-chunk-4-1.png)

Messy data
===

```r
head(gtex_time_tissue_data, 3L)
# A tibble: 3 × 8
  tissue         `2011` `2012` `2013` `2014` `2015` `2016` `2017`
  <chr>           <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
1 Adipose Tissue     56    107    243    206     84    134      2
2 Adrenal Gland      28     41     84     65     20     31      0
3 Bladder             2     18      0      1      0      0      0
```
- One of the problems with the way these data are formatted is that the year collected, which is a property of the samples, is stuck into the names of the columns. 
- Because of this, it's also not obvious what the numbers in the table mean (although we know they are counts)

Tidy data
===
- Here's a better way to organize the data:

```
# A tibble: 6 × 3
  tissue         year  count
  <chr>          <chr> <dbl>
1 Adipose Tissue 2011     56
2 Adipose Tissue 2012    107
3 Adipose Tissue 2013    243
4 Adipose Tissue 2014    206
5 Adipose Tissue 2015     84
6 Adipose Tissue 2016    134
```

This data is *tidy*. Tidy data follows three precepts:

1. each "variable" has its own dedicated column
2. each "observation" has its own row
3. each type of observational unit has its own data frame

In our example, each of the **observations** are different **groups of samples**, each of which has an associated _tissue_, _year_, and _count_. These are the _variables_ that are associated with the groups of samples. 

Tidy data
===

Tidy data is easy to work with.


```r
tidy %>% 
  filter(tissue %in% c("Blood", "Heart", "Liver", "Lung")) %>%
  ggplot() +
  geom_bar(aes(x = year, y = count, fill = tissue), stat = 'identity')
```

![plot of chunk unnamed-chunk-7](3-adv-tabular-data-figure/unnamed-chunk-7-1.png)

Tidying data with pivot_longer()
===

- `tidyr::pivot_longer()` is the function you will most often want to use to tidy your data

```r
gtex_time_tissue_data %>%
  pivot_longer(-tissue, names_to = "year", values_to = "count") %>%
  head(2L)
# A tibble: 2 × 3
  tissue         year  count
  <chr>          <chr> <dbl>
1 Adipose Tissue 2011     56
2 Adipose Tissue 2012    107
```

- the three important arguments are: a) a selection of columns, b) the name of the new key column, and c) the name of the new value column

![](https://swcarpentry.github.io/r-novice-gapminder/fig/14-tidyr-fig3.png)

Exercise: cleaning GTEX
===
type:prompt


```r
head(gtex_data, 3L)
Error in eval(expr, envir, enclos): object 'gtex_data' not found
```

Use the GTEX data to reproduce the following plot:


```
Error in eval(expr, envir, enclos): object 'gtex_data' not found
```

The individuals and genes of interest are `c('GTEX-11GSP', 'GTEX-11DXZ')` and `c('A2ML1', 'A3GALT2', 'A4GALT')`, respectively.

"Messy" data is relative and not always bad
===


```
# A tibble: 4 × 3
  mouse weight_before weight_after
  <dbl>         <dbl>        <dbl>
1     1          6.16        12.3 
2     2         13.8         15.7 
3     3         12.3         13.6 
4     4          6.67         8.93
```


```r
wide_mice %>%
  mutate(weight_gain = weight_after - weight_before) %>%
  select(mouse, weight_gain)
# A tibble: 4 × 2
  mouse weight_gain
  <dbl>       <dbl>
1     1        6.14
2     2        1.82
3     3        1.29
4     4        2.25
```

***


```
# A tibble: 8 × 3
  mouse time   weight
  <dbl> <chr>   <dbl>
1     1 before   6.16
2     1 after   12.3 
3     2 before  13.8 
4     2 after   15.7 
5     3 before  12.3 
6     3 after   13.6 
7     4 before   6.67
8     4 after    8.93
```


```r
long_mice %>%
  group_by(mouse) %>%
  mutate(weight_gain = weight - lag(weight)) %>%
  filter(!is.na(weight_gain)) %>%
  select(mouse, weight_gain)
# A tibble: 4 × 2
# Groups:   mouse [4]
  mouse weight_gain
  <dbl>       <dbl>
1     1        6.14
2     2        1.82
3     3        1.29
4     4        2.25
```

Pivoting wider
============================================================
- As we saw with the mouse example, sometimes our data is actually easier to work with in the "wide" format. 
- wide data is also often nice to make tables for presentations, or is (unfortunately) sometimes required as input for other software packages
- To go from long to wide, we use `pivot_wider()`:


```r
long_mice
# A tibble: 8 × 3
  mouse time   weight
  <dbl> <chr>   <dbl>
1     1 before   6.16
2     1 after   12.3 
3     2 before  13.8 
4     2 after   15.7 
5     3 before  12.3 
6     3 after   13.6 
7     4 before   6.67
8     4 after    8.93
```

***


```r
long_mice %>% 
  pivot_wider(
    names_from = time, 
    values_from = weight
  )
# A tibble: 4 × 3
  mouse before after
  <dbl>  <dbl> <dbl>
1     1   6.16 12.3 
2     2  13.8  15.7 
3     3  12.3  13.6 
4     4   6.67  8.93
```

Names prefix
============================================================


```r
long_mice
# A tibble: 8 × 3
  mouse time   weight
  <dbl> <chr>   <dbl>
1     1 before   6.16
2     1 after   12.3 
3     2 before  13.8 
4     2 after   15.7 
5     3 before  12.3 
6     3 after   13.6 
7     4 before   6.67
8     4 after    8.93
```

***

- you can use `names_prefix` to make variables names that are more clear in the result


```r
long_mice %>% 
  pivot_wider(
    names_from = time, 
    values_from = weight,
    names_prefix = "weight_"
  ) %>% 
  head(2L)
# A tibble: 2 × 3
  mouse weight_before weight_after
  <dbl>         <dbl>        <dbl>
1     1          6.16         12.3
2     2         13.8          15.7
```

- this can also be used to _remove_ a prefix when going from wide to long:


```r
wide_mice %>% 
  pivot_longer(
    -mouse,
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
Error in eval(expr, envir, enclos): object 'gtex_data' not found
```

The numbers in the table are the number of tissues in each individual for which the gene in question was missing.

Multi-pivoting
===
incremental: true


Have a look at the following data. How do you think we might want to make it look?


```r
gtex_time_chunk_link = 
  "https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/advance-2021/data/gtex_metadata/gtex_samples_tiss_time_chunk.csv"

gtex_samples_time_chunk = 
  read_csv(file = gtex_time_chunk_link, col_types = cols())

head(gtex_samples_time_chunk)
# A tibble: 6 × 9
  tissue     `Sept-2015` `Sept-2016` `Oct-2015` `Oct-2016` `Nov-2015` `Nov-2016`
  <chr>            <dbl>       <dbl>      <dbl>      <dbl>      <dbl>      <dbl>
1 Adipose T…           5          36          4         20         15         16
2 Adrenal G…           4           5          1          5          2          6
3 Blood                2           0          6          0         33          0
4 Blood Ves…           9          24          7         26          9         17
5 Brain               12           2          3          9         17         24
6 Breast               9          19          7         20          5          8
# ℹ 2 more variables: `Dec-2016` <dbl>, `Dec-2015` <dbl>
```

The problem here is that the column names contain two pieces of data:

1. the year 
2. the month it came from

Our use of `pivot_longer` has so far been to extract a single piece of information from the column name

Multi-pivoting
===
- Turns out this problem can be tackled too:


```r
gtex_samples_time_chunk %>%
  pivot_longer(
    cols=contains("-201"), # selects columns that contain this
    names_pattern = "(\\D+)-(\\d+)", # a "regular expression"- we'll learn about these later
    names_to = c(".value", "year")
  )
# A tibble: 54 × 6
   tissue         year   Sept   Oct   Nov   Dec
   <chr>          <chr> <dbl> <dbl> <dbl> <dbl>
 1 Adipose Tissue 2015      5     4    15     0
 2 Adipose Tissue 2016     36    20    16    15
 3 Adrenal Gland  2015      4     1     2     0
 4 Adrenal Gland  2016      5     5     6     2
 5 Blood          2015      2     6    33    17
 6 Blood          2016      0     0     0     0
 7 Blood Vessel   2015      9     7     9     0
 8 Blood Vessel   2016     24    26    17    12
 9 Brain          2015     12     3    17     0
10 Brain          2016      2     9    24     9
# ℹ 44 more rows
```

- We won't dig into this, but you should know that almost any kind of data-tidying problem can be solved with some combination of the functions in the `tidyr` package. 
- See the online [docs and vignettes](https://tidyr.tidyverse.org/articles/pivot.html) for more info

Combining multiple tables with joins
===
type:section


Relational data
=====================================================================
incremental: true

- Relational data are interconnected data that is spread across multiple tables, each of which usually has a different unit of observation
- When we get an expression dataset, the data is usually divided into an expression matrix with the expression values of each sample, and table(s) with metadata about the samples themselves. 
- For the GTEx dataset, we have information about the samples, subjects, and experiment batches in additional data frames in addition to the expression matrix we've been working with. 



```r
gtex_metadata_link = 
  "https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/advance-2021/data/gtex_metadata/gtex_sample_metadata.csv"

gtex_sample_data = read_csv(file = gtex_metadata_link, col_types = cols())

head(gtex_sample_data, 2L)
# A tibble: 2 × 6
  subject_id sample_id     batch_id center_id tissue rin_score
  <chr>      <chr>         <chr>    <chr>     <chr>      <dbl>
1 GTEX-11DXZ 0003-SM-58Q7X BP-39216 B1        Blood       NA  
2 GTEX-11DXZ 0126-SM-5EGGY BP-44460 B1        Liver        7.9
```
- The sample data has information about the tissue and the subject who contributed the sample, the batch it was processed in, the center the sample was processed at, and the RNA integrity number (RIN score) for the sample. 

Relational data
===
incremental: true

The subject data table contains some subject demographic information. Death refers to circumstances surrounding death.

```r
gtex_subject_link = 
  "https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/9e4fb21ccf93a83e2b6004b9aa467426806f8589/data/gtex_metadata/gtex_subject_metadata.csv"

gtex_subject_data = read_csv(file = gtex_subject_link, col_types = cols())

head(gtex_subject_data, 2L)
# A tibble: 2 × 4
  subject_id sex    age   death                    
  <chr>      <chr>  <chr> <chr>                    
1 GTEX-11DXZ male   50-59 ventilator               
2 GTEX-11GSP female 60-69 sudden but natural causes
```

The batch data containts the batch type and the dates the batches were run (we were been working a bit with this date data aggregated into counts of samples earlier).

```r
gtex_batch_link = "https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/9e4fb21ccf93a83e2b6004b9aa467426806f8589/data/gtex_metadata/gtex_batch_metadata.csv"
gtex_batch_data = read_csv(file = gtex_batch_link, col_types = cols())

head(gtex_batch_data, 2L)
# A tibble: 2 × 3
  batch_id batch_type                                         batch_date
  <chr>    <chr>                                              <chr>     
1 BP-38516 DNA isolation_Whole Blood_QIAGEN Puregene (Manual) 05/02/2013
2 BP-42319 RNA isolation_PAXgene Tissue miRNA                 08/14/2013
```

We might also have tables with additional information, such as that about the centers (see `center_id`) where the samples were taken, or a table with information about the genes that includes their length and location.


Relational data
===

- These data are not independent of each other. Subjects described in the `subject` data are referenced in the `sample` data, and the batches referenced in the `sample` data are in the `batch` data. The sample ids from the `sample` data are used for accessing expression data.

<div align="center">
<img src="https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/advance-2020/relational_data.png", height=500>
</div>


- `subject` connects to `sample` via a single variable, `subject_id`.
- `sample` connects to `batch` through the `batch_id` variable.


Relational + tidy data
===
incremental: true
For the expression data, we have been using the `gtex_data` expression data frame:

```r
gtex_data = read_tsv(file = gtex_link, col_types = cols())
Error in eval(expr, envir, enclos): object 'gtex_link' not found

gtex_data %>% 
  head(2L)
Error in eval(expr, envir, enclos): object 'gtex_data' not found
```

The expression data on the previous slide is formatted slightly differently:

```r
gtex_expression_link = "https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/9e4fb21ccf93a83e2b6004b9aa467426806f8589/data/gtex_metadata/gtex_expression.csv"

gtex_expression = read_csv(file = gtex_expression_link, col_types = cols())

gtex_expression %>% 
  head(2L) # note: sample_id replaces Ind + tissue
# A tibble: 2 × 3
  sample_id     Gene  zscore
  <chr>         <chr>  <dbl>
1 0003-SM-58Q7X A2ML1  -0.14
2 0326-SM-5EGH1 A2ML1  -1.08
```
What makes this data tidy when the other is not? (You'll notice that a `pivot` helped convert between the two.)

```r
gtex_data %>% 
  pivot_longer(Blood:Liver, names_to = "tissue", values_to = "zscore") %>% 
  head(2L)
Error in eval(expr, envir, enclos): object 'gtex_data' not found
```

An example join
===
- Imagine we want to add subject information to the sample data
- We can accomplish that with a **join**:

```r
gtex_sample_data %>% 
  inner_join(gtex_subject_data, by = "subject_id")
# A tibble: 312 × 9
   subject_id sample_id    batch_id center_id tissue rin_score sex   age   death
   <chr>      <chr>        <chr>    <chr>     <chr>      <dbl> <chr> <chr> <chr>
 1 GTEX-11DXZ 0003-SM-58Q… BP-39216 B1        Blood       NA   male  50-59 vent…
 2 GTEX-11DXZ 0126-SM-5EG… BP-44460 B1        Liver        7.9 male  50-59 vent…
 3 GTEX-11DXZ 0326-SM-5EG… BP-44460 B1        Heart        8.3 male  50-59 vent…
 4 GTEX-11DXZ 0726-SM-5N9… BP-43956 B1        Lung         7.8 male  50-59 vent…
 5 GTEX-11GSP 0004-SM-58Q… BP-39412 B1        Blood       NA   fema… 60-69 sudd…
 6 GTEX-11GSP 0626-SM-598… BP-44902 B1        Liver        6.2 fema… 60-69 sudd…
 7 GTEX-11GSP 0726-SM-598… BP-44902 B1        Lung         6.9 fema… 60-69 sudd…
 8 GTEX-11GSP 1226-SM-598… BP-44902 B1        Heart        7.9 fema… 60-69 sudd…
 9 GTEX-11NUK 0004-SM-58Q… BP-39723 B1        Blood       NA   male  50-59 sudd…
10 GTEX-11NUK 0826-SM-5HL… BP-43730 B1        Lung         7.4 male  50-59 sudd…
# ℹ 302 more rows
```

Joins
===

```r
x = tibble(
  key = c(1, 2, 3),
  val_x = c("x1", "x2", "x3")
)

y = tibble(
  key = c(1, 2, 4),
  val_y = c("y1", "y2", "y3")
)
```

<div align="center">
<img src="https://d33wubrfki0l68.cloudfront.net/108c0749d084c03103f8e1e8276c20e06357b124/5f113/diagrams/join-setup.png">
</div>

***


```r
inner_join(x, y, by = "key")
# A tibble: 2 × 3
    key val_x val_y
  <dbl> <chr> <chr>
1     1 x1    y1   
2     2 x2    y2   
```
- An inner join matches pairs of observations when their "keys" are equal
- the column that is joined on is specified as a "key" with the argument `by="column"`

<div align="center">
<img src="https://d33wubrfki0l68.cloudfront.net/3abea0b730526c3f053a3838953c35a0ccbe8980/7f29b/diagrams/join-inner.png">
</div>

Duplicate keys
===

```r
x = tibble(
  key = c(1, 2, 2, 3),
  val_x = c("x1", "x2", "x3", "x4")
)

y = tibble(
  key = c(1, 2, 2, 4),
  val_y = c("y1", "y2", "y3", "y4")
)
```

<div align="center">
<img src="https://d33wubrfki0l68.cloudfront.net/d37530bbf7749f48c02684013ae72b2996b07e25/37510/diagrams/join-many-to-many.png">
</div>

***


```r
inner_join(x, y, by = "key")
Warning in inner_join(x, y, by = "key"): Detected an unexpected many-to-many relationship between `x` and `y`.
ℹ Row 2 of `x` matches multiple rows in `y`.
ℹ Row 2 of `y` matches multiple rows in `x`.
ℹ If a many-to-many relationship is expected, set `relationship =
  "many-to-many"` to silence this warning.
# A tibble: 5 × 3
    key val_x val_y
  <dbl> <chr> <chr>
1     1 x1    y1   
2     2 x2    y2   
3     2 x2    y3   
4     2 x3    y2   
5     2 x3    y3   
```

When keys are duplicated, multiple rows can match multiple rows, so each possible combination is produced

Specifying the keys
===

```r
gtex_sample_data %>% 
  inner_join(gtex_subject_data, by = "center_id")
Error in `inner_join()`:
! Join columns in `y` must be present in the data.
✖ Problem with `center_id`.
```
- Why does this fail?

Specifying the keys
===
- When keys have different names in different dataframes, the syntax to join is:

```r
head(gtex_data, 2)
Error in eval(expr, envir, enclos): object 'gtex_data' not found
head(gtex_subject_data, 2)
# A tibble: 2 × 4
  subject_id sex    age   death                    
  <chr>      <chr>  <chr> <chr>                    
1 GTEX-11DXZ male   50-59 ventilator               
2 GTEX-11GSP female 60-69 sudden but natural causes

gtex_data %>% 
  inner_join(gtex_subject_data, by = c("Ind" = "subject_id")) %>% 
  head(5L)
Error in eval(expr, envir, enclos): object 'gtex_data' not found
```
Note that the first key (`Ind`) corresponds to the first data frame (`gtex_data`) and the second key (`subject_id`) corresponds to the second data frame (`gtex_subject_data`).


Exercise: finding expression of specific samples
===
Use joins to find the samples collected in 2015 with high blood expression (Z>3) of "KRT19" in males. Start with the `batch_data_year`; this data has an extra extracted column with the year (we'll go over how this worked in the next lecture). 

```r
batch_data_year = 
  gtex_batch_data %>% 
  mutate(
    batch_date = lubridate::mdy(batch_date), 
    year = lubridate::year(batch_date)
  ) 

head(batch_data_year, 2L)
# A tibble: 2 × 4
  batch_id batch_type                                         batch_date  year
  <chr>    <chr>                                              <date>     <dbl>
1 BP-38516 DNA isolation_Whole Blood_QIAGEN Puregene (Manual) 2013-05-02  2013
2 BP-42319 RNA isolation_PAXgene Tissue miRNA                 2013-08-14  2013
```

Note that you'll have to join to other data frames the `sample` data frame to put this together.

Other joins
===

<div align="center">
<img src="https://d33wubrfki0l68.cloudfront.net/9c12ca9e12ed26a7c5d2aa08e36d2ac4fb593f1e/79980/diagrams/join-outer.png">
</div>

***

- A left join keeps all observations in `x`.
- A right join keeps all observations in `y`.
- A full join keeps all observations in `x` and `y`.

<div align="center">
<img src="https://d33wubrfki0l68.cloudfront.net/aeab386461820b029b7e7606ccff1286f623bae1/ef0d4/diagrams/join-venn.png">
</div>

- Left join should be your default
  - it looks up additional information in other tables
  - preserves all rows in the table you're most interested in

Joining on multiple columns
===
- It is often desirable to find matches along more than one column, such as month and year in this example. Here we're joining tissue sample counts with total sample counts.

```r
gtex_tissue_month_link = "https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/9e4fb21ccf93a83e2b6004b9aa467426806f8589/data/gtex_metadata/gtex_tissue_month_year.csv"

gtex_tissue_month = 
  read_csv(file = gtex_tissue_month_link, col_types = cols()) %>%
  filter(tissue %in% c("Blood", "Heart", "Liver", "Lung"))

head(gtex_tissue_month, 2L)
# A tibble: 2 × 4
  tissue month  year tiss_samples
  <chr>  <dbl> <dbl>        <dbl>
1 Blood      1  2012           25
2 Blood      1  2013           16

gtex_samples_by_month = 
  read_csv(file = gtex_samples_time_link, col_types = cols())
Error in eval(expr, envir, enclos): object 'gtex_samples_time_link' not found

head(gtex_samples_by_month, 2L)
Error in eval(expr, envir, enclos): object 'gtex_samples_by_month' not found

gtex_tissue_month %>% 
  inner_join(gtex_samples_by_month, by = c("month", "year")) %>%
  head(5L)
Error: object 'gtex_samples_by_month' not found
```

Joining on multiple columns
===

This is also possible if the columns have different names:

```r
gtex_data_long = gtex_data %>% 
  pivot_longer(cols = c("Blood", "Heart", "Lung", "Liver"), names_to = "tissue", 
    values_to = "zscore") 
Error in eval(expr, envir, enclos): object 'gtex_data' not found
head(gtex_data_long, n = 2L)
Error in eval(expr, envir, enclos): object 'gtex_data_long' not found
head(gtex_sample_data, n = 2L)
# A tibble: 2 × 6
  subject_id sample_id     batch_id center_id tissue rin_score
  <chr>      <chr>         <chr>    <chr>     <chr>      <dbl>
1 GTEX-11DXZ 0003-SM-58Q7X BP-39216 B1        Blood       NA  
2 GTEX-11DXZ 0126-SM-5EGGY BP-44460 B1        Liver        7.9

gtex_data_long %>% 
  inner_join(gtex_sample_data, by = c("tissue", "Ind" = "subject_id")) %>%
  head(n = 4L)
Error in eval(expr, envir, enclos): object 'gtex_data_long' not found
```

Join problems
===
- Joins can be a source of subtle errors in your code
- check for `NA`s in variables you are going to join on
- make sure rows aren't being dropped if you don't intend to drop rows
  - checking the number of rows before and after the join is not sufficient. If you have an inner join with duplicate keys in both tables, you might get unlucky as the number of dropped rows might exactly equal the number of duplicated rows
- `anti_join()` and `semi_join()` are useful tools (filtering joins) to diagnose problems
  - `anti_join()` keeps only the rows in `x` that *don't* have a match in `y`
  - `semi_join()` keeps only the rows in `x` that *do* have a match in `y`

Exercise: Looking for variables related to data missingness
====
type: prompt

It is important to make sure that the missingness in the expression data is not related to variables present in the data. Use the tables `batch_data_year`, `sample_data`, `subject_data`, and the `gtex_data` to look at the relationship between missing gene values and other variables in the data. 

