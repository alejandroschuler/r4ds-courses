R for Data Science
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

Goals of this course
========================================================
By the end of the course you should be able to...

- comfortably use R through the Rstudio interface
- read and write tabular data between R and flat files
- subset, transform, summarize, join, and plot data
- write reusable and readable programs
- seek out, learn, and integrate new packages into your analyses

<div align="center">
<img src="https://d33wubrfki0l68.cloudfront.net/571b056757d68e6df81a3e3853f54d3c76ad6efc/32d37/diagrams/data-science.png" width=800 height=300>
</div>

Tidyverse
========================================================
<div align="center">
<img src="https://pbs.twimg.com/media/DuRP1tVVAAEcpxO.jpg">
</div>

Resources for this course
========================================================

R for Data Science (R4DS): https://r4ds.had.co.nz
<div align="center">
<img src="https://r4ds.had.co.nz/cover.png">
</div>

***

Cheatsheets: https://www.rstudio.com/resources/cheatsheets/
Website: https://github.com/alejandroschuler/r4ds-courses/tree/advance-2020

Basics and Plotting
========================================================
type:section

Learning Goals:

- issue commands to R using the Rstudio REPL interface
- load a package into R
- read some tabluar data into R
- visualize tabluar data using ggplot geoms, aesthetics, and facets

Basics
========================================================
type:section

The basics of interaction using the console window
========================================================
The R console window is the left (or lower-left) window in RStudio.
The R console uses a "read, eval, print" loop. This is sometimes
called a REPL.
- Read: R reads what you type ...
- Eval: R evaluates it ...
- Print: R prints the result ...
- Loop: (repeat forever)


A simple example in the console
========================================================
- The box contains an expression that will be evaluated by R, followed by the result of evaluating that expression.

```r
1 + 2
[1] 3
```
- `3` is the answer
- Ignore the `[1]` for now. 

- R performs operations (called *functions*) on data and values
- These can be composed arbitrarily

```r
log(1 + 3)
[1] 1.386294
paste("The answer is", log(1 + 3))
[1] "The answer is 1.38629436111989"
```

How do I...
===
- typing 
```
?function_name
``` 
gives you information about what the function does
- Google is your friend. Try "function_name R language" or "how do I X in R?". I also strongly recommend using "tidyverse" in your queries or the name of a tidyverse package (more in a moment) that has related functions
- stackoverflow is your friend. It might take some scrolling, but you will eventually find what you need

Quadratic Equation
===
type: prompt
incremental: true

One of the solutions to a polynomial equation $ax^2 + bx + c = 0$ is given by

$$x = \frac{-b + \sqrt{b^2 -4ac}}{2a}$$

Figure out how to use R functions and operations for square roots, exponentiation, and multiplication to calculate $x$ given $a=3, b=14, c=-5$.



What did you learn? What did you notice?
<!-- - Parentheses are used to encapsulate the *arguments* to a function like `sqrt()` -->
<!-- - Operators like `\`, `*`, and `^` are useful for math -->
<!-- - Parentheses can also be used to establish order of operations -->

Packages
===
- The amazing thing about programming is that you are not limited to what is built into the language
- Millions of R users have written their own functions that you can use
- These are bundled together into *packages*
- To use functions that aren't built into the "base" language, you have to tell R to first go download the relevant code, and then to load it in the current session

```r
install.packages("tidyverse")  # go download the package called 'tidyverse'- only have to do this once
library("tidyverse")  # load the package into the current R session - do this every time you use R and need functions from this package
```

Packages
===
- The `tidyverse` package has a function called `read_csv()` that lets you read csv (comma-separated values) files into R. 
- csv is a common format for data to come in, and it's easy to export csv files from microsoft excel, for instance. 


```r
# I have a file called 'lupusGenes.csv' in a folder called data
genes = read_csv("data/LupusGenes.csv")
Error in read_csv("data/LupusGenes.csv"): could not find function "read_csv"
```

- This fails because I haven't yet loaded the `tidyverse` package

```r
library(tidyverse)
```



```r
genes = read_csv("data/LupusGenes.csv")
```

- Now there is no error message

Packages
===
- packages only need to be loaded once per R session (session starts when you open R studio, ends when you shut it down)
- once the package is loaded it doesn't need to be loaded again before each function call

```r
poly = read_csv("data/poly.csv")  # reading another csv file
```


Using R to look at your data
========================================================
type: section

Data analysis workflow
====
1. Read data into R (done!)
2. ~~Manipulate data~~
3. Get results, **make plots and figures**

Getting your data in R
===
- Getting your data into R is easy. We already saw, for example:


```r
genes = read_csv("https://raw.githubusercontent.com/alejandroschuler/r4ds-courses/advance-2020/data/lupusGenes.csv")
```

- `read_csv()` requires you to tell it where to find the file you want to read in
  - Windows, e.g.: `"C:\Users\me\Desktop\myfile.csv"`
  - Mac, e.g.: `"/Users/me/Desktop/myfile.csv"`
  - Internet, e.g.: `"http://www.mywebsite.com/myfile.csv"`
- If your data is not already in csv format, google "covert X format to csv" or "read X format data in R"
- We'll learn the details of this later, but this is enough to get you started! 

Looking at data
===
- `genes` is now a dataset loaded into R. To look at it, just type

```r
genes
# A tibble: 59 x 11
   sampleid   age gender ancestry phenotype FAM50A ERCC2 IFI44 EIF3L  RSAD2
   <chr>    <dbl> <chr>  <chr>    <chr>      <dbl> <dbl> <dbl> <dbl>  <dbl>
 1 GSM3057…    70 F      Caucasi… SLE         18.6  4.28  18.0 182.    25.5
 2 GSM3057…    78 F      Caucasi… SLE         20.3  3.02  21.1 157.    37.2
 3 GSM3057…    64 F      Caucasi… SLE         21.4  4.00 488.  169.   792. 
 4 GSM3057…    32 F      Asian    SLE         17.1  4.49  34.0 149.    60.7
 5 GSM3057…    33 F      Caucasi… SLE         20.9  5.00  34.4 224.    60.8
 6 GSM3057…    46 M      Maori    SLE         15.8  3.96 466.  111.  1382. 
 7 GSM3057…    45 F      Asian    SLE         18.9  6.04 299.  157.   926. 
 8 GSM3057…    67 M      Caucasi… SLE         27.6  4.77  21.8 265.    20.6
 9 GSM3057…    33 F      Caucasi… SLE         15.4  3.88 700.   98.6 1652. 
10 GSM3057…    28 F      Caucasi… SLE         19.9  7.21 278.  217.   972. 
# … with 49 more rows, and 1 more variable: VAPA <dbl>
```

This is a **data frame**, one of the most powerful features in R (a "tibble" is a kind of data frame).
- Similar to an Excel spreadsheet.
- One row ~ one
instance of some (real-world) object.
- One column ~ one variable, containing the values for the
corresponding instances.
- All the values in one column should be of the same type (a number, a category, text, etc.), but
different columns can be of different types.

The Dataset
===

```r
genes
# A tibble: 59 x 11
   sampleid   age gender ancestry phenotype FAM50A ERCC2 IFI44 EIF3L  RSAD2
   <chr>    <dbl> <chr>  <chr>    <chr>      <dbl> <dbl> <dbl> <dbl>  <dbl>
 1 GSM3057…    70 F      Caucasi… SLE         18.6  4.28  18.0 182.    25.5
 2 GSM3057…    78 F      Caucasi… SLE         20.3  3.02  21.1 157.    37.2
 3 GSM3057…    64 F      Caucasi… SLE         21.4  4.00 488.  169.   792. 
 4 GSM3057…    32 F      Asian    SLE         17.1  4.49  34.0 149.    60.7
 5 GSM3057…    33 F      Caucasi… SLE         20.9  5.00  34.4 224.    60.8
 6 GSM3057…    46 M      Maori    SLE         15.8  3.96 466.  111.  1382. 
 7 GSM3057…    45 F      Asian    SLE         18.9  6.04 299.  157.   926. 
 8 GSM3057…    67 M      Caucasi… SLE         27.6  4.77  21.8 265.    20.6
 9 GSM3057…    33 F      Caucasi… SLE         15.4  3.88 700.   98.6 1652. 
10 GSM3057…    28 F      Caucasi… SLE         19.9  7.21 278.  217.   972. 
# … with 49 more rows, and 1 more variable: VAPA <dbl>
```
This is a subset of a real RNA-seq (GSE112087) dataset comparing RNA levels in blood between lupus (SLE) patients and healthy controls.
- 29 SLE Patients, 30 Healthy Controls
- We have basic metadata as well as the levels of multiple genes in blood.
- Let's see if we can find anything interesting from this already-generated data!

Investigating a relationship
===
Let's say we're curious about the relationship between two genes RSAD2 (the column `RSAD2`) and IFI44 (column `IFI44`).
- Can we use R to make a plot of these two variables?


```r
ggplot(genes) + 
  geom_point(aes(x = RSAD2, y = IFI44))
```

<img src="0-intro-plotting-figure/unnamed-chunk-14-1.png" title="plot of chunk unnamed-chunk-14" alt="plot of chunk unnamed-chunk-14" height="80%" />

***
- `ggplot(dataset)` says "start a chart with this dataset"
- `+ geom_point(...)` says "put points on this chart"
- `aes(x=x_values y=y_values)` says "map the values in the column `x_values` to the x-axis, and map the values in the column `y_values` to the y-axis" (`aes` is short for *aesthetic*)

ggplot
===


```r
ggplot(genes) + 
  geom_point(aes(x = VAPA, y = EIF3L))
```

![plot of chunk unnamed-chunk-15](0-intro-plotting-figure/unnamed-chunk-15-1.png)

***

- `ggplot` is short for "grammar of graphics plot"
  - This is a language for describing how data get linked to visual elements
- `ggplot()` and `geom_point()` are functions imported from the `ggplot2` package, which is one of the "sub-packages" of the `tidyverse` package we loaded earlier

Investigating a relationship
===
type: prompt
incremental: true

Make a scatterplot of `phenotype` vs `IFI44` (another gene in the dataset). The result should look like this:

![plot of chunk unnamed-chunk-16](0-intro-plotting-figure/unnamed-chunk-16-1.png)

Investigating a relationship
===
Let's say we're curious about the relationship between RSAD2 (the column `RSAD2`) and IFI44 (column `IFI44`).

![plot of chunk unnamed-chunk-17](0-intro-plotting-figure/unnamed-chunk-17-1.png)

- What's going on here? It seems like there are two clusters. 
- What is driving this clustering? Age? Sex? Ancestry? Phenotype?

Aesthetics
===
- Aesthetics aren't just for mapping columns to the x- and y-axis
- You can also use them to assign color, for instance


```r
ggplot(genes) + 
  geom_point(aes(x = RSAD2, 
                 y = IFI44,
                 color = phenotype))
```

- ggplot automatically gives each value of the column a unique level of the aesthetic (here a color) and adds a legend
- What did we learn about the genes that we are interested in?

***
<img src="0-intro-plotting-figure/unnamed-chunk-19-1.png" title="plot of chunk unnamed-chunk-19" alt="plot of chunk unnamed-chunk-19" width="90%" />

Aesthetics
===
- Aesthetics aren't just for mapping columns to the x- and y-axis
- We could have used a shape


```r
ggplot(genes) + 
  geom_point(aes(
    x = RSAD2, 
    y = IFI44, 
    shape=phenotype
  )) 
```


***
<img src="0-intro-plotting-figure/unnamed-chunk-21-1.png" title="plot of chunk unnamed-chunk-21" alt="plot of chunk unnamed-chunk-21" width="90%" />

Aesthetics
===
- Aesthetics aren't just for mapping columns to the x- and y-axis
- Or size


```r
ggplot(genes) + 
  geom_point(aes(
    x = RSAD2, 
    y = IFI44, 
    size=ancestry
  )) 
```
- This one doesn't really make sense because we're mapping a categorical variable to an aesthetic that can take continuous values that imply some ordering

***

```
Warning: Using size for a discrete variable is not advised.
```

<img src="0-intro-plotting-figure/unnamed-chunk-23-1.png" title="plot of chunk unnamed-chunk-23" alt="plot of chunk unnamed-chunk-23" width="90%" />

Aesthetics
===
- If we set a property *outside* of the aesthetic, it no longer maps that property to a column. 


```r
ggplot(genes) + 
  geom_point(
    aes(
      x = RSAD2, 
      y = IFI44
    ),
    color = "blue"
  ) 
```
- However, we can use this to assign fixed properties to the plot that don't depend on the data

***
<img src="0-intro-plotting-figure/unnamed-chunk-25-1.png" title="plot of chunk unnamed-chunk-25" alt="plot of chunk unnamed-chunk-25" width="90%" />

Exercise
===
incremental: true
type: prompt

Can you recreate this plot?


![plot of chunk unnamed-chunk-26](0-intro-plotting-figure/unnamed-chunk-26-1.png)

Exercise
===
incremental: true
type: prompt

What will this do? Why?


```r
ggplot(genes) + 
  geom_point(aes(x = RSAD2, y = IFI44, color = "blue"))
```

Facets
===
- Aesthetics are useful for mapping columns to particular properties of a single plot
- Use **facets** to generate multiple plots with shared structure


```r
ggplot(genes) + 
  geom_point(aes(x = RSAD2, y = IFI44)) + 
  facet_wrap(~ phenotype, nrow = 2)
```

<img src="0-intro-plotting-figure/unnamed-chunk-28-1.png" title="plot of chunk unnamed-chunk-28" alt="plot of chunk unnamed-chunk-28" style="display: block; margin: auto;" />
- `facet_wrap` is good for faceting according to unordered categories

Facets
===
- `facet_grid` is better for ordered categories, and can be used with two variables


```r
ggplot(genes) + 
  geom_point(aes(x = RSAD2, y = IFI44)) + 
  facet_grid(phenotype ~ gender)
```

<img src="0-intro-plotting-figure/unnamed-chunk-29-1.png" title="plot of chunk unnamed-chunk-29" alt="plot of chunk unnamed-chunk-29" style="display: block; margin: auto;" />

Exercise
===
type:prompt
incremental: true

Run this code and comment on what role `.` plays:


```r
ggplot(genes) + 
  geom_point(aes(x = RSAD2, y = IFI44)) +
  facet_grid(ancestry ~ .)
```


Geoms
===


```r
ggplot(genes) + 
  geom_point(aes(x = RSAD2, y = IFI44))
```

<img src="0-intro-plotting-figure/unnamed-chunk-31-1.png" title="plot of chunk unnamed-chunk-31" alt="plot of chunk unnamed-chunk-31" style="display: block; margin: auto;" />
- Both these plots represent the same data, but they use a different geometric representation ("geom")
- e.g. bar chart vs. line chart, etc. 

***

```r
ggplot(genes) + 
  geom_smooth(aes(x = RSAD2, y = IFI44))
```

<img src="0-intro-plotting-figure/unnamed-chunk-32-1.png" title="plot of chunk unnamed-chunk-32" alt="plot of chunk unnamed-chunk-32" style="display: block; margin: auto;" />

Geoms
===
- Different geoms are configured to work with different aesthetics. 
- e.g. you can set the shape of a point, but you can’t set the “shape” of a line.
- On the other hand, you *can* set the "line type" of a line:


```r
ggplot(genes) + 
  geom_smooth(aes(x = RSAD2, y = IFI44, linetype = phenotype))
```

<img src="0-intro-plotting-figure/unnamed-chunk-33-1.png" title="plot of chunk unnamed-chunk-33" alt="plot of chunk unnamed-chunk-33" style="display: block; margin: auto;" />

Geoms
===
- It's possible to add multiple geoms to the same plot

```r
ggplot(genes) + 
  geom_smooth(aes(x = RSAD2, y = IFI44, color = phenotype)) + 
  geom_point(aes(x = RSAD2, y = IFI44, color = phenotype))
```

<img src="0-intro-plotting-figure/unnamed-chunk-34-1.png" title="plot of chunk unnamed-chunk-34" alt="plot of chunk unnamed-chunk-34" style="display: block; margin: auto;" />

Geoms
===
- To assign the same aesthetics to all geoms, pass the aesthetics to the `ggplot` function directly instead of to each geom individually

```r
ggplot(genes, aes(x = RSAD2, y = IFI44, color = phenotype)) + 
  geom_smooth() + 
  geom_point()
```

<img src="0-intro-plotting-figure/unnamed-chunk-35-1.png" title="plot of chunk unnamed-chunk-35" alt="plot of chunk unnamed-chunk-35" style="display: block; margin: auto;" />

Geoms
===
- You can also use different mappings in different geoms

```r
ggplot(genes, mapping = aes(x = RSAD2, y = IFI44)) + 
  geom_point(aes(color = ancestry)) + 
  geom_smooth()
```

<img src="0-intro-plotting-figure/unnamed-chunk-36-1.png" title="plot of chunk unnamed-chunk-36" alt="plot of chunk unnamed-chunk-36" style="display: block; margin: auto;" />

Exercise
===
type: prompt
incremental: true

Use google or other resources to figure out how to receate this plot in R:

```
ggplot(genes) + 
  ...
```

<img src="0-intro-plotting-figure/unnamed-chunk-37-1.png" title="plot of chunk unnamed-chunk-37" alt="plot of chunk unnamed-chunk-37" style="display: block; margin: auto;" />

- What might the name of this geom be? What properties of the plot (aesthetics) are mapped to what columns of the data?
- If you accomplish making the plot, can you figure out how to change the colors of the groups?

Learning More
===

From **R for Data Science**:

>If you want to learn more about the mechanics of ggplot2, I’d highly recommend grabbing a copy of the ggplot2 book: https://amzn.com/331924275X. It’s been recently updated, so it includes dplyr and tidyr code, and has much more space to explore all the facets of visualisation. Unfortunately the book isn’t generally available for free, but if you have a connection to a university you can probably get an electronic version for free through SpringerLink.

> Another useful resource is the R Graphics Cookbook by Winston Chang. Much of the contents are available online at http://www.cookbook-r.com/Graphs/.

> I also recommend Graphical Data Analysis with R, by Antony Unwin. This is a book-length treatment similar to the material covered in this chapter, but has the space to go into much greater depth.

===
<div align="center">
<img src="https://d33wubrfki0l68.cloudfront.net/21d683072b0c21cbd9b41fc0e37a587ad26b9525/cbf41/wp-content/uploads/2018/08/data-visualization-2.1.png"; style="max-width:1500;"; class="center">
</div>
