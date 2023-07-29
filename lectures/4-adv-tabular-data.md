Advanced Tabular Data Manipulation	
========================================================
author: Alejandro Schuler, adapted from Steve Bagley and based on R for Data Science by Hadley Wickham
date: 2022
transition: none
width: 1680
height: 1050

- group and summarize data by one or more columns
- transform between long and wide data formats
- combine multiple data frames using joins on one or more columns


<style>
.small-code pre code {
  font-size: 0.5em;
}
</style>


Grouped summaries with summarize()
===
type:section

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
gtex_data = read_tsv('https://tinyurl.com/mwrvahjz')

# Check number of rows
nrow(gtex_data)
[1] 389922
```

Grouped summaries with summarize()
================================================================

```r
summarize(gtex_data, tissue_avg=mean(NTissues))
# A tibble: 1 × 1
  tissue_avg
       <dbl>
1       3.97
```
- `summarize()` boils down the data frame according to the conditions it gets. In this case, it creates a data frame with a single column called `tissue_avg` that contains the mean of the `NTissues` column
- As with `mutate()`, the name on the left of the `=` is something you make up that you would like the new column to be named.
- `mutate()` transforms columns into new columns of the same length, but `summarize()` collapses down the data frame into a single row
- Summaries are more useful when you apply them to subgoups of the data, which we will soon see how to do.

Grouped summaries with summarize()
================================================================
- note that you can also pass in multiple conditions that operate on multiple columns at the same time

```r
gtex_data %>% 
summarize( # newlines not necessary, again just increase clarity
  tissue_avg = mean(NTissues),
  blood_max = max(Blood, na.rm=T),
  blood_lung_dif_min = min(Blood - Lung, na.rm=T)
)
# A tibble: 1 × 3
  tissue_avg blood_max blood_lung_dif_min
       <dbl>     <dbl>              <dbl>
1       3.97      18.9              -12.8
```

Grouped summaries with summarize()
==================================================================
- Summaries are more useful when you apply them to subgroups of the data


```r
gtex_data %>% 
  group_by(Gene) %>%
  summarize(max_blood = max(Blood))
# A tibble: 4,999 × 2
   Gene               max_blood
   <chr>                  <dbl>
 1 A2ML1                   2.08
 2 A3GALT2                 2.77
 3 A4GALT                  2.78
 4 AAMDC                  NA   
 5 AANAT                   1.71
 6 AAR2                    2.52
 7 AARSD1                  1.89
 8 AB019441.29             2.31
 9 ABC7-42389800N19.1      1.98
10 ABCA5                   2.3 
# ℹ 4,989 more rows
```


- `group_by()` is a helper function that "groups" the data according to the unique values in the column(s) it gets passed. 
- Its output is a grouped data frame that looks the same as the original except for some additional metadata that subsequent functions can use
- `summarize()` works the same as before, except now it returns as many rows as there are groups in the data
- The result also always contains colunmns corresponding to the unique values of the grouping variable

Multiple columns can be used to group the data simultaneously
===================================================================


```r
gtex_data %>% 
  group_by(Gene,Ind) %>%
  summarize(max_blood = max(Blood))
# A tibble: 389,922 × 3
# Groups:   Gene [4,999]
   Gene  Ind        max_blood
   <chr> <chr>          <dbl>
 1 A2ML1 GTEX-11DXZ     -0.14
 2 A2ML1 GTEX-11GSP     -0.5 
 3 A2ML1 GTEX-11NUK     -0.08
 4 A2ML1 GTEX-11NV4     -0.37
 5 A2ML1 GTEX-11TT1      0.3 
 6 A2ML1 GTEX-11TUW      0.02
 7 A2ML1 GTEX-11ZUS     -1.07
 8 A2ML1 GTEX-11ZVC     -0.27
 9 A2ML1 GTEX-1212Z     -0.3 
10 A2ML1 GTEX-12696     -0.11
# ℹ 389,912 more rows
```

- The result has the summary value for each unique combination of the grouping variables

Computing the number of rows in each group
=====================================================================
- The `n()` function counts the number of rows in each group:


```r
gtex_data %>% 
  filter(!is.na(Blood)) %>%
  group_by(Gene) %>%
  summarize(how_many = n())
# A tibble: 4,999 × 2
   Gene               how_many
   <chr>                 <int>
 1 A2ML1                    78
 2 A3GALT2                  78
 3 A4GALT                   78
 4 AAMDC                    77
 5 AANAT                    78
 6 AAR2                     78
 7 AARSD1                   78
 8 AB019441.29              78
 9 ABC7-42389800N19.1       78
10 ABCA5                    78
# ℹ 4,989 more rows
```
- You can also use `count()`, which is just a shorthand for the same thing


```r
gtex_data %>% 
  filter(!is.na(Blood)) %>%
  group_by(Gene) %>%
  count()
```

Computing the number of distinct elements in a column, per group
=====================================================================
- `n_distinct()` counts the number of unique elements in a column


```r
gtex_data %>% 
  group_by(Ind) %>%
  summarize(n_genes = n_distinct(Gene))
# A tibble: 78 × 2
   Ind        n_genes
   <chr>        <int>
 1 GTEX-11DXZ    4999
 2 GTEX-11GSP    4999
 3 GTEX-11NUK    4999
 4 GTEX-11NV4    4999
 5 GTEX-11TT1    4999
 6 GTEX-11TUW    4999
 7 GTEX-11ZUS    4999
 8 GTEX-11ZVC    4999
 9 GTEX-1212Z    4999
10 GTEX-12696    4999
# ℹ 68 more rows
```


Exercise: top expression per tissue
=====================================================================
type:prompt

- Ignoring NAs, what is the highest liver expression value seen for each gene in the `gtex_data` dataset?
- What about the lowest?

Exercise: top expression per tissue
=====================================================================
type:prompt

- Ignoring NAs, what is the highest liver expression value seen for each gene in the `gtex_data` dataset?
- What about the lowest?


```r
gtex_data %>% 
  group_by(Gene) %>%
  summarize(
    max_liver = max(Liver, na.rm=T),
    min_liver = min(Liver, na.rm=T)
  )
# A tibble: 4,999 × 3
   Gene               max_liver min_liver
   <chr>                  <dbl>     <dbl>
 1 A2ML1                   3.65     -1.94
 2 A3GALT2                 3.61     -1.3 
 3 A4GALT                  2.22     -1.76
 4 AAMDC                   3.43     -2.62
 5 AANAT                   3.78     -2.22
 6 AAR2                    2.32     -3.23
 7 AARSD1                  2.77     -2.75
 8 AB019441.29             3.36     -1.53
 9 ABC7-42389800N19.1      2.51     -3.2 
10 ABCA5                   3.27     -3.27
# ℹ 4,989 more rows
```

Exercise: summarize and plot
===
type:prompt

Recreate this plot. 

![plot of chunk unnamed-chunk-11](4-adv-tabular-data-figure/unnamed-chunk-11-1.png)


Exercise: summarize and plot
===
type:prompt

Recreate this plot. 

![plot of chunk unnamed-chunk-12](4-adv-tabular-data-figure/unnamed-chunk-12-1.png)



```r
gtex_data %>% 
  filter(Gene %in% c('FFAR4', 'KLK3', 'PLOD2', 'MLPH')) %>%
  group_by(Gene, NTissues) %>%
  summarize(max_heart = max(Heart ,na.rm=T)) %>% 
  
ggplot() +
  geom_point(aes(y=Gene, x=max_heart)) + 
  facet_grid(. ~ NTissues , labeller = label_both)
```

Grouped mutates and filters
===
type:section

Filtering grouped data
===

- `filter()` is aware of grouping. When used on a grouped dataset, it applies the filtering condition separately in each group


```r
gtex_data %>% 
  group_by(Gene) %>%
  filter(NTissues == max(NTissues))
# A tibble: 376,883 × 7
# Groups:   Gene [4,999]
   Gene  Ind        Blood Heart  Lung Liver NTissues
   <chr> <chr>      <dbl> <dbl> <dbl> <dbl>    <dbl>
 1 A2ML1 GTEX-11GSP -0.5   0.53  0.76 -0.1         4
 2 A2ML1 GTEX-11NUK -0.08 -0.4  -0.26 -0.13        4
 3 A2ML1 GTEX-11NV4 -0.37  0.11 -0.42 -0.61        4
 4 A2ML1 GTEX-11TT1  0.3  -1.11  0.59 -0.12        4
 5 A2ML1 GTEX-11TUW  0.02 -0.47  0.29 -0.66        4
 6 A2ML1 GTEX-11ZUS -1.07 -0.41  0.67  0.06        4
 7 A2ML1 GTEX-11ZVC -0.27 -0.51  0.13 -0.75        4
 8 A2ML1 GTEX-1212Z -0.3   0.53  0.1  -0.48        4
 9 A2ML1 GTEX-12696 -0.11  0.24  0.96  0.72        4
10 A2ML1 GTEX-12WSD  0.53  0.36  0.2   0.51        4
# ℹ 376,873 more rows
```

- Why do we get back multiple rows per `class`?
- This is an extremely convenient idiom for finding the rows that minimize or maximize a condition

Exercise: Max expression change in blood and lung
===

Which are the individual pairs that have both the max blood expression change *and* max lung expression change among all individuals with measurements for the same gene?


```r
gtex_data %>% 
  group_by(Gene) %>%
  filter(Blood == max(Blood), Lung==max(Lung))
# A tibble: 64 × 7
# Groups:   Gene [64]
   Gene        Ind        Blood Heart  Lung Liver NTissues
   <chr>       <chr>      <dbl> <dbl> <dbl> <dbl>    <dbl>
 1 A4GALT      GTEX-12696  2.78 -1.02  2.31 -0.23        4
 2 ABHD1       GTEX-VUSG   6.33  0.41  2.04 -0.04        4
 3 AL162151.3  GTEX-WZTO   2.37 -0.19  4.23 -1.22        4
 4 ANKRD36B    GTEX-12WSD  2.72  0.74  2.66  1.22        4
 5 APOA1       GTEX-12WSD  5.45 NA     7     0.67        3
 6 C14orf119   GTEX-11ZUS  2.51  0.76  1.85 -0.99        4
 7 CD1D        GTEX-1B996  3.05  2.85  2.78  2.1         4
 8 CTB-131B5.2 GTEX-1GN73  6.29 -1.17  5.51 -0.96        4
 9 CTC-448F2.6 GTEX-131YS  4.1   0.75  2.67 -0.24        4
10 EVC         GTEX-UPK5   4.31  0.21  2.6  -0.61        4
# ℹ 54 more rows
```

Mutating grouped data
===

- `mutate()` is aware of grouping. When used on a grouped dataset, it applies the mutation separately in each group


```r
gtex_data %>%
  group_by(Gene) %>%
  mutate(blood_diff_from_min = Blood - min(Blood)) %>%
  select(Gene, Ind, Blood, blood_diff_from_min)
# A tibble: 389,922 × 4
# Groups:   Gene [4,999]
   Gene  Ind        Blood blood_diff_from_min
   <chr> <chr>      <dbl>               <dbl>
 1 A2ML1 GTEX-11DXZ -0.14                1.26
 2 A2ML1 GTEX-11GSP -0.5                 0.9 
 3 A2ML1 GTEX-11NUK -0.08                1.32
 4 A2ML1 GTEX-11NV4 -0.37                1.03
 5 A2ML1 GTEX-11TT1  0.3                 1.7 
 6 A2ML1 GTEX-11TUW  0.02                1.42
 7 A2ML1 GTEX-11ZUS -1.07                0.33
 8 A2ML1 GTEX-11ZVC -0.27                1.13
 9 A2ML1 GTEX-1212Z -0.3                 1.1 
10 A2ML1 GTEX-12696 -0.11                1.29
# ℹ 389,912 more rows
```

- As always, mutate does not change the number of rows in the dataset

Tidy data: rearranging a data frame
============================================================
type: section

Messy data
============================================================
- Sometimes data are organized in a way that makes it difficult to compute in a vector-oriented way. For example, look at this dataset:


```r
gtex_time_tissue_data = read_csv("https://tinyurl.com/3wd4dcsf")

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



![plot of chunk unnamed-chunk-19](4-adv-tabular-data-figure/unnamed-chunk-19-1.png)

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

![plot of chunk unnamed-chunk-22](4-adv-tabular-data-figure/unnamed-chunk-22-1.png)

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
# A tibble: 3 × 7
  Gene  Ind        Blood Heart  Lung Liver NTissues
  <chr> <chr>      <dbl> <dbl> <dbl> <dbl>    <dbl>
1 A2ML1 GTEX-11DXZ -0.14 -1.08 NA    -0.66        3
2 A2ML1 GTEX-11GSP -0.5   0.53  0.76 -0.1         4
3 A2ML1 GTEX-11NUK -0.08 -0.4  -0.26 -0.13        4
```

Use the GTEX data to reproduce the following plot:

![plot of chunk unnamed-chunk-25](4-adv-tabular-data-figure/unnamed-chunk-25-1.png)

The individuals and genes of interest are `c('GTEX-11GSP', 'GTEX-11DXZ')` and `c('A2ML1', 'A3GALT2', 'A4GALT')`, respectively.

"Messy" data is relative and not always bad
===


```
# A tibble: 4 × 3
  mouse weight_before weight_after
  <dbl>         <dbl>        <dbl>
1     1         11.4          9.44
2     2         13.0         12.8 
3     3          6.11         8.76
4     4          9.09         8.30
```


```r
wide_mice %>%
  mutate(weight_gain = weight_after - weight_before) %>%
  select(mouse, weight_gain)
# A tibble: 4 × 2
  mouse weight_gain
  <dbl>       <dbl>
1     1      -1.99 
2     2      -0.142
3     3       2.65 
4     4      -0.785
```

***


```
# A tibble: 8 × 3
  mouse time   weight
  <dbl> <chr>   <dbl>
1     1 before  11.4 
2     1 after    9.44
3     2 before  13.0 
4     2 after   12.8 
5     3 before   6.11
6     3 after    8.76
7     4 before   9.09
8     4 after    8.30
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
1     1      -1.99 
2     2      -0.142
3     3       2.65 
4     4      -0.785
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
1     1 before  11.4 
2     1 after    9.44
3     2 before  13.0 
4     2 after   12.8 
5     3 before   6.11
6     3 after    8.76
7     4 before   9.09
8     4 after    8.30
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
1     1  11.4   9.44
2     2  13.0  12.8 
3     3   6.11  8.76
4     4   9.09  8.30
```

Names prefix
============================================================


```r
long_mice
# A tibble: 8 × 3
  mouse time   weight
  <dbl> <chr>   <dbl>
1     1 before  11.4 
2     1 after    9.44
3     2 before  13.0 
4     2 after   12.8 
5     3 before   6.11
6     3 after    8.76
7     4 before   9.09
8     4 after    8.30
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
1     1          11.4         9.44
2     2          13.0        12.8 
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
# A tibble: 2 × 4
# Groups:   Ind [2]
  Ind        A2ML1 A3GALT2 A4GALT
  <chr>      <int>   <int>  <int>
1 GTEX-11DXZ     1       0      0
2 GTEX-11GSP     0       0      0
```

The numbers in the table are the number of tissues in each individual for which the gene in question was missing.


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
  "https://tinyurl.com/2hy9awda"

gtex_samples = read_csv("https://tinyurl.com/2hy9awda")

head(gtex_samples, 2L)
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
gtex_subjects = read_csv("https://tinyurl.com/3tfbew8f")
head(gtex_subjects, 2L)
# A tibble: 2 × 4
  subject_id sex    age   death                    
  <chr>      <chr>  <chr> <chr>                    
1 GTEX-11DXZ male   50-59 ventilator               
2 GTEX-11GSP female 60-69 sudden but natural causes
```

The batch data containts the batch type and the dates the batches were run (we were been working a bit with this date data aggregated into counts of samples earlier).

```r
gtex_batches = read_csv("https://tinyurl.com/3phsbxsj")

head(gtex_batches, 2L)
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


An example join
===
- Imagine we want to add subject information to the sample data
- We can accomplish that with a **join**:

```r
gtex_samples %>% 
  inner_join(gtex_subjects, by = join_by(subject_id))
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
inner_join(x, y, by = join_by(key))
# A tibble: 2 × 3
    key val_x val_y
  <dbl> <chr> <chr>
1     1 x1    y1   
2     2 x2    y2   
```
- An inner join matches pairs of observations when their "keys" are equal
- the column that is joined on is specified as a "key" with the argument `by=join_by(column_name)`

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
inner_join(x, y, join_by(key))
Warning in inner_join(x, y, join_by(key)): Detected an unexpected many-to-many relationship between `x` and `y`.
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
gtex_samples %>% 
  inner_join(gtex_subjects, join_by(center_id))
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
# A tibble: 2 × 7
  Gene  Ind        Blood Heart  Lung Liver NTissues
  <chr> <chr>      <dbl> <dbl> <dbl> <dbl>    <dbl>
1 A2ML1 GTEX-11DXZ -0.14 -1.08 NA    -0.66        3
2 A2ML1 GTEX-11GSP -0.5   0.53  0.76 -0.1         4
head(gtex_subjects, 2)
# A tibble: 2 × 4
  subject_id sex    age   death                    
  <chr>      <chr>  <chr> <chr>                    
1 GTEX-11DXZ male   50-59 ventilator               
2 GTEX-11GSP female 60-69 sudden but natural causes
```

```r
gtex_data %>% 
  inner_join(gtex_subjects, join_by(Ind == subject_id)) %>% 
  head(5L)
# A tibble: 5 × 10
  Gene  Ind        Blood Heart  Lung Liver NTissues sex    age   death          
  <chr> <chr>      <dbl> <dbl> <dbl> <dbl>    <dbl> <chr>  <chr> <chr>          
1 A2ML1 GTEX-11DXZ -0.14 -1.08 NA    -0.66        3 male   50-59 ventilator     
2 A2ML1 GTEX-11GSP -0.5   0.53  0.76 -0.1         4 female 60-69 sudden but nat…
3 A2ML1 GTEX-11NUK -0.08 -0.4  -0.26 -0.13        4 male   50-59 sudden but nat…
4 A2ML1 GTEX-11NV4 -0.37  0.11 -0.42 -0.61        4 male   60-69 sudden but nat…
5 A2ML1 GTEX-11TT1  0.3  -1.11  0.59 -0.12        4 male   20-29 ventilator     
```
Note that the first key (`Ind`) corresponds to the first data frame (`gtex_data`) and the second key (`subject_id`) corresponds to the second data frame (`gtex_subjects`).

Exercise: join vs. concatenation
===
type: prompt
Another common way to combine two data frames is `bind_rows` (or `bind_cols`). Read the documentation for those functions and compare to what you know about joins. What is fundamentally different about binding (concatenating) vs. joining?

When would you do one vs. the other?

Exercise: finding expression of specific samples
===
type: prompt

Use joins to find the samples collected in 2015 with high blood expression (Z>3) of "KRT19" in males. Start with the `batch_data_year`; this data has an extra extracted column with the year.

```r
batch_data_year = 
  gtex_batches %>% 
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
Let's read in some more data

```r
gtex_monthly_tissues = 
  read_csv("https://tinyurl.com/nze7rz7a") %>%
  filter(tissue %in% c("Blood", "Heart", "Liver", "Lung"))
head(gtex_monthly_tissues, 2L)
# A tibble: 2 × 4
  tissue month  year tiss_samples
  <chr>  <dbl> <dbl>        <dbl>
1 Blood      1  2012           25
2 Blood      1  2013           16

gtex_monthly_samples = read_csv("https://tinyurl.com/2s5neht6")
head(gtex_monthly_samples, 2L)
# A tibble: 2 × 3
  month  year num_samples
  <dbl> <dbl>       <dbl>
1     5  2011          20
2     6  2011          44
```
*** 
- It is often desirable to find matches along more than one column, such as month and year in this example. Here we're joining tissue sample counts with total sample counts.

```r
inner_join(
  gtex_monthly_tissues,
  gtex_monthly_samples, 
  join_by(month, year)
) %>%
head(5L)
# A tibble: 5 × 5
  tissue month  year tiss_samples num_samples
  <chr>  <dbl> <dbl>        <dbl>       <dbl>
1 Blood      1  2012           25         208
2 Blood      1  2013           16          64
3 Blood      1  2014           26         662
4 Blood      1  2015           39         263
5 Blood      2  2012            9          95
```

Joining on multiple columns
===

This is also possible if the columns have different names:

```r
gtex_data_long = gtex_data %>% 
  pivot_longer(cols = c("Blood", "Heart", "Lung", "Liver"), names_to = "tissue", 
    values_to = "zscore") 
head(gtex_data_long, n = 2L)
# A tibble: 2 × 5
  Gene  Ind        NTissues tissue zscore
  <chr> <chr>         <dbl> <chr>   <dbl>
1 A2ML1 GTEX-11DXZ        3 Blood   -0.14
2 A2ML1 GTEX-11DXZ        3 Heart   -1.08
head(gtex_samples, n = 2L)
# A tibble: 2 × 6
  subject_id sample_id     batch_id center_id tissue rin_score
  <chr>      <chr>         <chr>    <chr>     <chr>      <dbl>
1 GTEX-11DXZ 0003-SM-58Q7X BP-39216 B1        Blood       NA  
2 GTEX-11DXZ 0126-SM-5EGGY BP-44460 B1        Liver        7.9

gtex_data_long %>% 
  inner_join(gtex_samples, join_by(tissue, Ind == subject_id)) %>%
  head(n = 4L)
# A tibble: 4 × 9
  Gene  Ind        NTissues tissue zscore sample_id batch_id center_id rin_score
  <chr> <chr>         <dbl> <chr>   <dbl> <chr>     <chr>    <chr>         <dbl>
1 A2ML1 GTEX-11DXZ        3 Blood   -0.14 0003-SM-… BP-39216 B1             NA  
2 A2ML1 GTEX-11DXZ        3 Heart   -1.08 0326-SM-… BP-44460 B1              8.3
3 A2ML1 GTEX-11DXZ        3 Lung    NA    0726-SM-… BP-43956 B1              7.8
4 A2ML1 GTEX-11DXZ        3 Liver   -0.66 0126-SM-… BP-44460 B1              7.9
```

Join problems
===
- Joins can be a source of subtle errors in your code
- check for `NA`s in variables you are going to join on
- make sure rows aren't being dropped if you don't intend to drop rows
  - checking the number of rows before and after the join is not sufficient. If you have an inner join with duplicate keys in both tables, you might get unlucky as the number of dropped rows might exactly equal the number of duplicated rows


Exercise: Looking for variables related to data missingness
====
type: prompt

It is important to make sure that the missingness in the expression data is not related to variables present in the data. Use the tables `batch_data_year`, `sample_data`, `subject_data`, and the `gtex_data` to look at the relationship between missing gene values and other variables in the data. 

