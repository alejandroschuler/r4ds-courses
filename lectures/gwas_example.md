GWAS Example
========================================================
author: Emily Flynn
date: 8/24/2020
transition: none
width: 1680
height: 1050

Learning objectives
========================================================
- preprocess a large messy dataset
- use an R package to make manhattan plots
- use external code to make a miami plot


Background
========================================================
- UK Biobank
- Sex differences
- Sex differences in testosterone genetics
- Genome-wide association study (GWAS)

https://www.biorxiv.org/content/10.1101/837021v1


Dataset - GWAS summary statistics
========================================================
First, we're going to read in summary statistics for testosterone. For GWAS, the summary statistics consist of the BETA, SE, and P (pvalue) for the association between a particular genetic variant (ID, rs...) at a specific location in the genome (given here by the chromosome and position). 

These files were generated using plink. 

Try using `summary()` - what do you notice about the data? What about missingness?

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

The idea behind GWAS is that we're fitting a ton of models, one for each variant, in order to identify variants is associated with a trait of interest. At every location (except for most of the X and Y chromosomes), people have two  alleles. Here we use an additive model (given by "ADD"), where for each person at that particular location we have a 0, 1, 2 for the number of copies of the alternate allele. There are other models that consider recessive/dominant or multiplicative effects. By fitting the model across many individuals, we get a coefficient (or $beta$) for the variant. We also get a standard error for that $beta$. 

 $$ trait \~ beta*num\_copies\_alternate\_allele $$

After fitting tons of these models (in theory as many as 3 million, one for each variant - in practice usually a factor below that), we then want to test whether the variants are associated with the trait, in this case testosterone. To do so, we test whether the coefficient $beta$ is significantly different than zero, and we get a p-value describing this. For very low p-values, we reject the null hypothesis that $beta$ is zero, or that the variant is not associated with the trait. Because we are doing so many tests, we use a very low threshold to call something "genome-wide significant" (the standard is  $p < 5 x 10^{-8}$).

Looking at GWAS data
========================================================

Use tidyverse to filter for the variants under the genome-wide significance threshold.
What is the lowest p-value? What is the highest absolute coefficient (beta)?



Plotting GWAS data with qqman
========================================================
left: 25%

The standard way to visualize GWAS data is to create a Manhattan plot.


```r
#install.packages('qqman')
library('qqman')
manhattan(gwasResults)
```

![plot of chunk unnamed-chunk-3](gwas_example-figure/unnamed-chunk-3-1.png)

***

In order to use qqman, we'll have to figure out how to get our data into the manhattan function. Try `?manhattan` and then also take a look at the GWAS results -- how does it look different from our data? What are the labels and types of the important columns? 

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
testosterone_f %>% head(3)
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

Exercise - plotting our data with qqman
========================================================

What modifications do you have to make to the data to be able to plot? Let's start with a smaller version of the testosterone dataset for females -- we'll come back to why in a second. Now work in groups to plot the data.

```r
testosterone_sm = testosterone_f %>% sample_n(10000)
```



Plotting large datasets
========================================================

We suggested starting with a smaller version of the dataset because if you try to plot the data - you'll notice it starts to hang.

```r
#manhattan(testosterone_cleaned)
```

Use "Ctrl-C" or press the "STOP" button or try "Session" > "Interrupt R". These are all good ways to stop a command when it's taking too long.

Why did this happen? Take a look at the number of rows in the example versus our dataset using `nrow()`. It's helpful to get an idea of how different the data are in size.

We used `sample_n()` to select a smaller portion of the data to plot.

```r
manhattan(testosterone_sm_cleaned)
```

![plot of chunk unnamed-chunk-8](gwas_example-figure/unnamed-chunk-8-1.png)

What are the variants with smallest pvalues in `t2_sm`? Does it match the full dataset?

Downsampling for visualization
========================================================

Typically, when we downsample for visualization purposes, we want to downsample the data that we're less interested in - e.g. the variants that are not associated and have high p-values. For visualization purposes it looks like $p = 10^(-3)$ is a reasonable cutoff.

To do this, use tidyverse to divide the dataset into two parts based on p-value. Then use `sample_n()` to grab 10% of the high-pvalue variants. Put the data back together (hint: `bind_rows()`) and plot again with qqman. Does this work?


Truncating the data for visualization
========================================================
You'll notice now that when you plot, you can do it in a reasonable time but the y axis scale now goes very high, which makes it hard to see. 

![plot of chunk unnamed-chunk-10](gwas_example-figure/unnamed-chunk-10-1.png)

***

For visualization, it is common to truncate the data so it solves this, e.g. make all p-values < $10^(-30)$ equal to $10^-30$. Use a mutate to do this and visualize again. Does this help? Can you tell that we've downsampled the data?



```r
manhattan(testosterone_truncated)
```

![plot of chunk unnamed-chunk-12](gwas_example-figure/unnamed-chunk-12-1.png)

Functions
========================================================
Now we want to do the same thing we just did with the testosterone GWAS summary statistics from males. 

We could copy and paste everything - but there is a better way!

Write a function that takes a table with summary stats and performs these pre-processing steps (dealing with column names, filtering NAs, converting to numeric, downsampling, etc) to get it ready for a manhattan plot. Check that it produces the same output (within random sampling) on the female testosterone sumstats data, then apply to the male data.

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

Making the Manhattan plot fancier
========================================================
Take a look at the manhattan plot vignette and try a couple things: https://cran.r-project.org/web/packages/qqman/vignettes/qqman.html. 

Miami plot
========================================================
A Miami plot is two Manhattan plots opposite each other. It allows for comparison of the datasets.

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

Now let's use the functions and cleaned data to make a Miami plot


```r
testosterone_f_clean <- testosterone_truncated
testosterone_m_clean <- testosterone_truncated
```


```r
gwas_dat = prep_miami_dat(testosterone_f_clean, testosterone_m_clean)
gwas_dat %>%
  make_miami_plot()
```

![plot of chunk unnamed-chunk-16](gwas_example-figure/unnamed-chunk-16-1.png)


Highlighting points
========================================================

Let's make the significant variants stand out. The nice thing is that we have a ggplot object so we can just add to it. We can do this by adding points. An easy way to add these points is to add new data objects for these geoms.

```r
gwas_dat %>%
  make_miami_plot()+
   geom_point(data=gwas_dat %>% 
                 filter(log10P > 8), col="blue")+
   geom_point(data=gwas_dat %>% 
                 filter(log10P < -8), col="red")
```

![plot of chunk unnamed-chunk-17](gwas_example-figure/unnamed-chunk-17-1.png)


Adding labels
========================================================
As part of my analysis of these data, we used a Bayesian Mixture Model to identify subsets of variants that showed shared and sex-specific effects. The details aren't important for this, let's just say that we want to highlight these variants in the plot.

First, let's read in these data. They're part of the supplement for this paper (Table S10) and are located in three different sheets. We'll read directly from the google sheets, but think about how you'd read these data in if you downloaded the supplement from the paper page. 

```r
require('googlesheets4') # this is a tidyverse package for reading google sheets. It can do a lot more fancy stuff if you pair with the `googledrive` package, but we'll leave it at this for now. 

supplement_url = "https://docs.google.com/spreadsheets/d/1id9s8dqJYHgOiCk9VmdjHmBnVz1xo9kOg9ilwTWFLRY/edit#gid=325131881"
f_spec = read_sheet(supplement_url, sheet=19)
m_spec = read_sheet(supplement_url, sheet=20)
shared = read_sheet(supplement_url, sheet=21)

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

Filter all pf these data so we're only looking at the Testosterone variants.

```r
f_spec_t = f_spec %>% filter(trait=="Testosterone")
```

Highlighting points -- part 2
========================================================
left: 60%

Then we're going to need to do a type of "join" with the "gwas_dat". First - what column are we joining by? You will have to use the `by=c("id1"="id2")` syntax. Second - what columns do we want in the output? Use a select and set it up so that this only adds two columns "Consequence" and "GENE" to the table.


```r
f_spec_filt = gwas_dat %>% 
  inner_join(f_spec_t %>% select(ID, GENE, Consequence), by=c("SNP"="ID"))
head(f_spec_filt, 4)
```

```
# A tibble: 4 x 17
  CHR       BP SNP   REF   ALT   A1    TEST  OBS_CT    BETA      SE T_STAT
  <chr>  <dbl> <chr> <chr> <chr> <chr> <chr>  <dbl>   <dbl>   <dbl>  <dbl>
1 X     1.53e8 rs73… G     T     T     ADD   142068 -0.0274 0.00467  -5.87
2 1     7.90e6 rs10… A     G     G     ADD   142005 -0.0279 0.00473  -5.89
3 1     2.21e7 rs33… A     G     G     ADD   142019  0.0327 0.00639   5.12
4 1     1.02e8 rs37… T     C     C     ADD   142055  0.0545 0.00841   6.48
# … with 6 more variables: P <dbl>, BPcum <dbl>, log10P <dbl>, point_grp <lgl>,
#   GENE <chr>, Consequence <chr>
```

*** 

```r
gwas_dat %>%
  make_miami_plot()+
   geom_point(data=f_spec_filt, col="blue")
```

![plot of chunk unnamed-chunk-21](gwas_example-figure/unnamed-chunk-21-1.png)

Repeat this for each of the types of variants.

Adding labels for genes
=================
You might be interested in looking at what genes are attached to the significant variants. We can use the variant tables and the package `ggrepel` to add these.

For a first pass, it can be helpful to sample only a subset of variants so that we don't get too crowded with labels.

```r
#install.packages('ggrepel')
library(ggrepel)
# gwas_dat %>%
#   make_miami_plot()+
#   geom_point(data=f_spec_filt, col="blue")+
#   geom_label_repel(data=f_spec_filt %>% sample_n(50), aes(label=GENE), size=2) 
```



Miami Plot Exercises 
==================================

1. Modify this code so that instead of sampling random genes, we are getting only the missense variants. You will use the `Consequence` field.

2. Modify this again so that we only label the top 20 most significant variants.  

3. Add in the m-spec and shared variants. Note - you may have to do something a little different to label variants these variants on either side of the axis. 


```r
# solution
# gwas_dat %>%
#   make_miami_plot()+
#   geom_point(data=f_spec_filt, col="blue")+
#   geom_label_repel(data=f_spec_filt %>% 
#                      arrange(desc(log10P)) %>% head(30),
#                    aes(label=GENE), size=2) 
```

