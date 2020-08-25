Plotting GWAS data
========================================================
author: Emily Flynn
date: 8/25/2020
transition: none
width: 1680
height: 1050

Learning objectives
========================================================
- preprocess a large messy GWAS dataset
- use an R package to make manhattan plots
- make a paper-ready miami plot


Background
========================================================
- UK Biobank is a repository with genetic and phenotypic data for 500,000 individuals

- We looked at whether sex differences in lab test levels were due to genetics

- For most biomarkers we examined this was not the case, except for testosterone

Background
========================================================
- UK Biobank is a repository with genetic and phenotypic data for 500,000 individuals

- We looked at whether sex differences in lab test levels were due to genetics

- For most biomarkers we examined this was not the case, except for testosterone

<div align="center">
<img src="https://www.dropbox.com/s/tsy4timfau48uo6/gen_cor_plot.png?raw=1", , height=600, width=1200>
</div>

Paper link: https://www.biorxiv.org/content/10.1101/837021v1


Goal: plot GWAS data for testosterone
=====================================================
We're going to use GWAS data for testosterone to remake this plot from the paper. 

The plot allows us to visualize genetic variants that have different associations with testosterone in males and females.

<div align="center">
<img src="https://www.dropbox.com/s/y4pyagpng1glv9y/mhplot_high_p2.png?raw=1", height=800, width=1000>
</div>

Dataset - GWAS summary statistics
========================================================
First, we're going to read in summary statistics for testosterone. For GWAS, the summary statistics consist of the BETA, SE, and P (pvalue) for the association between a particular genetic variant (ID, rs...) at a specific location in the genome (given here by the chromosome and position). 

These files were generated using plink. 


```r
library('tidyverse')
testosterone_m =read_tsv("https://www.dropbox.com/s/dtvuhymnsf2nyog/ukbb_testosterone_sumstats_males.txt?dl=1")
testosterone_f =read_tsv("https://www.dropbox.com/s/3j1m02lxuezikb4/ukbb_testosterone_sumstats_females.txt?dl=1")
head(testosterone_f, 3)
```

```
# A tibble: 3 x 12
  `#CHROM`   POS ID    REF   ALT   A1    TEST  OBS_CT    BETA      SE T_STAT
  <chr>    <dbl> <chr> <chr> <chr> <chr> <chr>  <dbl>   <dbl>   <dbl>  <dbl>
1 XY       60425 rs34… C     A     A     ADD   141845 0.00817 0.0103   0.791
2 XY       60454 rs28… A     G     G     ADD   141198 0.00633 0.00369  1.72 
3 XY       61067 rs28… A     G     G     ADD   142169 0.00676 0.0102   0.661
# … with 1 more variable: P <dbl>
```


How does GWAS work?
========================================================

We want to identify which genetic variants are associated with a trait of interest. To do this we fit a model for each variant (up to 3mil models!).

 $$ trait = beta*num\_copies\_alternate\_allele $$
 
For a given variant, there is reference and alternate (or multiple alternate) alleles (in this case a "C" or an "T"). Each person has two alleles at this location and a specific value for a trait (e.g. testosterone level).

```
# A tibble: 5 x 5
  person_id variant_id alleles testosterone_level num_alternate
      <int> <chr>      <chr>                <dbl>         <dbl>
1         1 rs71556711 CC                   0.651             0
2         2 rs71556711 CT                   0.207             1
3         3 rs71556711 CT                   0.184             1
4         4 rs71556711 CC                   0.142             0
5         5 rs71556711 TT                   0.648             2
```

We fit the model on these data and the result is a summary statistic ($beta$, standard error) for that variant:

```
# A tibble: 1 x 8
  `#CHROM`      POS ID         REF   ALT     BETA      SE        P
  <chr>       <dbl> <chr>      <chr> <chr>  <dbl>   <dbl>    <dbl>
1 7        72854549 rs71556711 C     T     0.0440 0.00647 1.05e-11
```

Genome-wide significance
========================================================

To test whether a variant is associated with a trait, we test whether the coefficient $beta$ is different than zero.  We get a p-value describing this.

```
# A tibble: 1 x 8
  `#CHROM`      POS ID         REF   ALT     BETA      SE        P
  <chr>       <dbl> <chr>      <chr> <chr>  <dbl>   <dbl>    <dbl>
1 7        72854549 rs71556711 C     T     0.0440 0.00647 1.05e-11
```

- The null hypothesis is that $beta$ is zero, or that the variant is not associated with the trait.
- For p-values below a certain threshold we reject the null hypothesis 

- Because we are doing so many tests (up to 3mil!), we use a very low threshold to call something "genome-wide significant" (the standard is $p < 5 * 10^{-8}$).

Try this: Look at Testosterone summary statistics
========================================================
type: prompt

Read in the data.Try using `summary()` - what do you notice about the data? What about missingness?

```r
library('tidyverse')
testosterone_m = read_tsv("https://www.dropbox.com/s/dtvuhymnsf2nyog/ukbb_testosterone_sumstats_males.txt?dl=1")
testosterone_f = read_tsv("https://www.dropbox.com/s/3j1m02lxuezikb4/ukbb_testosterone_sumstats_females.txt?dl=1")
```

Use tidyverse to filter for the variants under the genome-wide significance threshold.
What is the lowest p-value? 
What is the highest absolute coefficient (beta)?




Manhattan plots
========================================================
type: section

The standard way to visualize GWAS data is to create a Manhattan plot.
The R package qqman helps us with this:

```r
#install.packages('qqman')
library('qqman')
manhattan(gwasResults) # example data
```

![plot of chunk unnamed-chunk-7](gwas_example-figure/unnamed-chunk-7-1.png)


Exercise - plotting our data with qqman
========================================================
type: prompt

Let's start with a smaller version of the testosterone dataset -- we'll come back to why in a second.

```r
testosterone_sm = testosterone_f %>% sample_n(10000)
```


What modifications do you have to make to the data to be able to plot? In order to use qqman, we'll have to figure out how to get our data into the manhattan function. Try `?manhattan` and then also take a look at the example data -- how does it look different from our data? What are the labels and types of the important columns? 

```r
gwasResults %>% as_tibble() %>% head(2)
```

```
# A tibble: 2 x 4
  SNP     CHR    BP     P
  <chr> <int> <int> <dbl>
1 rs1       1     1 0.915
2 rs2       1     2 0.937
```

```r
testosterone_sm %>% head(3)
```

```
# A tibble: 3 x 12
  `#CHROM`    POS ID    REF   ALT   A1    TEST  OBS_CT    BETA      SE T_STAT
  <chr>     <dbl> <chr> <chr> <chr> <chr> <chr>  <dbl>   <dbl>   <dbl>  <dbl>
1 11       1.34e8 rs38… A     C     C     ADD   127669 0.00310 0.00494  0.628
2 8        7.43e7 rs75… G     T     T     ADD   142170 0.0142  0.0169   0.842
3 12       1.10e8 rs98… T     C     C     ADD   142233 0.0788  0.0967   0.814
# … with 1 more variable: P <dbl>
```




Plotting large datasets
========================================================

We used `sample_n()` to select a small portion of the dataset because if you try to plot the entire data you'll notice it starts to hang.

```r
#manhattan(testosterone_cleaned)
```

If you did this, use "Ctrl-C" or press the "STOP" button or try "Session" > "Interrupt R". These are all good ways to stop a command when it's taking too long.


Try this: Downsampling data
========================================================
type: prompt

1. Why did that hang? Take a look at the number of rows in the example versus our dataset using `nrow()`. It's helpful to get an idea of how different the data are in size.

2. What are the variants with smallest pvalues in `testosterone_sm`? Does it match the full dataset?


Downsampling and truncating data for visualization
========================================================
incremental: true

Typically, when we downsample for visualization purposes, we want to downsample the data that we're less interested in, e.g. the variants that are not associated. For visualization purposes let's use $p = 10^{-3}$ as a cutoff.







```r
manhattan(testosterone_downsampled)
```

![plot of chunk unnamed-chunk-14](gwas_example-figure/unnamed-chunk-14-1.png)

We can now plot in a reasonable time but the high y axis scale makes it hard to see. 


***
To fix this, we want to truncate the data -- here it is truncated such that all $p < 10^{-30}$ are set to $p = 10^{-30}$. 



```r
manhattan(testosterone_truncated)
```

![plot of chunk unnamed-chunk-15](gwas_example-figure/unnamed-chunk-15-1.png)

Does this help? 

Can you tell that we've downsampled the data?

Exercise - Preprocessing the data for visualization
========================================================
type: prompt

0. Go back to working with the full `testosterone_f` dataset (not the `testosterone_sm`) and repeat the preprocessing steps you did before to make it plot in qqman.

1. Downsample: Divide the dataset into two parts based on p-value. Then use `sample_n()` to grab 10% of the high p-value variants (> $10^{-3}$). Put the data back together (hint: `bind_rows()`) and plot again with qqman. 

2. Truncate: Use a mutate to make all p-values < $10^{-30}$ equal to $10^{-30}$ and replot.


3. Functions: While we could copy and paste to do the same thing for the male sumstats data, it's better to wrap it in a function. Write a function that takes summary stats and performs the pre-processing steps which just did to get it ready for a manhattan plot. Check that it produces the same output (within random sampling) on the female testosterone sumstats data, then apply to the male data.

```r
preprocess_gwas_for_manhattan = function(sum_stats){
  # 1. remove NAs
  # 2. fix column names
  # 3. fix data types
  # 4. downsample for viz
  # 5. truncate
}
```


Once you've processed the data, make both manhattan plots!

Extra: If you're interested, you can also take a look at the manhattan plot vignette and try a couple things: https://cran.r-project.org/web/packages/qqman/vignettes/qqman.html. 

Miami plot
========================================================
type: section

<div align="center">
<img src="https://www.dropbox.com/s/y4pyagpng1glv9y/mhplot_high_p2.png?raw=1", height=800, width=1000>
</div>


Miami plot
========================================================
A Miami plot is two Manhattan plots opposite each other to allow for comparison of datasets.

I initially googled "how to make a miami plot R" and tired a few solutions, but wound up wanting more control. So instead I googled "how to make a manhattan plot ggplot" and adapted the code for a Miami plot. 

This is the original manhattan plot code:
https://danielroelfs.com/blog/how-i-create-manhattan-plots-using-ggplot/

My adaptation is here https://github.com/rivas-lab/sex-div-analysis/blob/master/src/07_figures/s5_make_miami_plot.R. Take a look at how these functions are set up to see what is going on.

To simplify, we can just load the functions using `source()`. Source all the code located in a file, so make sure you know what you are running before using this command.

```r
source("https://raw.githubusercontent.com/rivas-lab/sex-div-analysis/master/src/07_figures/s5_make_miami_plot.R")
```
The key functions here are: `prep_miami_dat()` and `make_miami_plot()`. 

Making a Miami plot
========================================================

Now let's use the data we just cleaned and these new functions to make a Miami plot:






```r
gwas_dat = prep_miami_dat(testosterone_f_clean, testosterone_m_clean)
gwas_dat %>%
  make_miami_plot()
```

![plot of chunk unnamed-chunk-20](gwas_example-figure/unnamed-chunk-20-1.png)


Highlighting points
========================================================

Let's make the significant variants stand out. The nice thing is that we have a ggplot object so we can just add to it. We can do this by adding points. An easy way to add these points is to add new data objects for these geoms.

```r
gwas_dat %>%
  make_miami_plot()+
   geom_point(data=gwas_dat %>% filter(log10P > 8), col="blue")+
   geom_point(data=gwas_dat %>% filter(log10P < -8), col="red")
```

![plot of chunk unnamed-chunk-21](gwas_example-figure/unnamed-chunk-21-1.png)


Adding labels
========================================================
As part of my analysis of these data, we used a Bayesian Mixture Model to identify subsets of variants that showed shared and sex-specific effects. The details aren't important for this, let's just say that we want to highlight these variants in the plot.

First, let's read in these data. They're part of the supplement for this paper (Table S10) and are located in three different sheets. We'll read directly from the google sheets, but think about how you'd read these data in if you downloaded the supplement for the paper. 

```r
#install.packages('googlesheets4') # tidyverse package for google sheets
library('googlesheets4') # note: you can do fancy things if you pair with the googledrive package
supplement_url = "https://docs.google.com/spreadsheets/d/1id9s8dqJYHgOiCk9VmdjHmBnVz1xo9kOg9ilwTWFLRY/edit#gid=325131881"
f_spec = read_sheet(supplement_url, sheet=19)
#m_spec = read_sheet(supplement_url, sheet=20)
#shared = read_sheet(supplement_url, sheet=21)
head(f_spec,4)
```

```
# A tibble: 4 x 20
  trait ID    CHR      POS REF   ALT   GENE      MAF    B.f    B.m    SE.f
  <chr> <chr> <lis>  <dbl> <chr> <chr> <chr>   <dbl>  <dbl>  <dbl>   <dbl>
1 Alan… rs14… <dbl… 1.46e8 G     A     GPT   8.02e-5 -1.92  -1.24  0.0400 
2 Alka… rs12… <dbl… 2.19e7 G     A     ALPL  6.90e-4 -1.54  -1.54  0.00426
3 Alka… rs12… <dbl… 2.19e7 A     C     ALPL  1.80e-4 -2.44  -2.37  0.0147 
4 Alka… rs62… <dbl… 2.45e7 G     A     GPLD1 1.82e-4 -0.774 -0.714 0.0156 
# … with 9 more variables: SE.m <dbl>, P.f <dbl>, P.m <dbl>, p0 <dbl>,
#   p1 <dbl>, p2 <dbl>, p3 <dbl>, Consequence <chr>, HGVSp <chr>
```



Try this: highlighting points
========================================================
type: prompt
left: 60%

1. Read in and filter the f-specific variant data so we're only looking at the Testosterone variants.
2. Use an `inner_join` to add this data to the "gwas_dat". First - what column are we joining by? You will have to use the `by=c("id1"="id2")` syntax. Second - what columns do we want in the output? Use a select and set it up so that this only adds two columns "Consequence" and "GENE" to the table. This is what the output should look like:




```
# A tibble: 3 x 17
  CHR       BP SNP   REF   ALT   A1    TEST  OBS_CT    BETA      SE T_STAT
  <chr>  <dbl> <chr> <chr> <chr> <chr> <chr>  <dbl>   <dbl>   <dbl>  <dbl>
1 X     1.53e8 rs73… G     T     T     ADD   142068 -0.0274 0.00467  -5.87
2 1     7.90e6 rs10… A     G     G     ADD   142005 -0.0279 0.00473  -5.89
3 1     2.21e7 rs33… A     G     G     ADD   142019  0.0327 0.00639   5.12
# … with 6 more variables: P <dbl>, BPcum <dbl>, log10P <dbl>, point_grp <lgl>,
#   GENE <chr>, Consequence <chr>
```

3. Now use this to plot the points in a different color. Think about what you will use for the `data` argument.
![plot of chunk unnamed-chunk-25](gwas_example-figure/unnamed-chunk-25-1.png)


Adding labels for genes
=================
You might be interested in looking at what genes are attached to the significant variants. We can use the variant tables and the package `ggrepel` to add these.

For a first pass, it can be helpful to sample only a subset of variants so that we don't get too crowded with labels.

```r
#install.packages('ggrepel')
library(ggrepel)
gwas_dat %>%
   make_miami_plot()+
   geom_point(data=gwas_w_fspec, col="blue")+
   geom_label_repel(data=gwas_w_fspec %>% sample_n(50), aes(label=GENE), size=2) 
```

![plot of chunk unnamed-chunk-26](gwas_example-figure/unnamed-chunk-26-1.png)



Miami Plot Exercises 
==================================
type: prompt

0. Use the code on the previous slides to add labels and points for the male-specific variants. 

1. Modify the code on the previous slide so that instead of sampling random genes, we are getting only the missense variants. You will use the `Consequence` field.

2. Modify this again so that we only label the top 20 most significant variants.  

3. Add in the m-spec and shared variants. Note - you may have to do something a little different to label variants these variants on either side of the axis. 



