Basics and Plotting
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

Introduction to the course
========================================================
type: section


Goals of this course
========================================================
By the end of the course you should be able to...

- write neat R scripts and markdown reports in R studio
- find, read, and understand package and function documentation 
- read and write tabular data into R from flat files
- perform basic manipulations on tabular data: subsetting, manipulating and summarizing data, and joining
- visualize tabluar data using line and scatter plots along with color and facets

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

- Fundamentals: ch 1, 4, 6
- Input/output: ch 11
- Data manipulation: ch 5, 13
- Visualization: ch 3, 28

Cheatsheets: https://www.rstudio.com/resources/cheatsheets/

Getting Started in RStudio
========================================================
type: section


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
> 1 + 2
[1] 3
```
- `3` is the answer
- Ignore the `[1]` for now. 

- R performs operations (called *functions*) on data and values
- These can be composed arbitrarily

```r
> log(1 + 3)
[1] 1.386294
> paste("The answer is", log(1 + 3))
[1] "The answer is 1.38629436111989"
```

How do I...
===
- typing 
```
?function_name
``` 
gives you information about what the function does
- Google is your friend. Try "function_name R language" or "how do I X in R?"
- stackoverflow is your friend. It might take some scrolling, but you will eventually find what you need

Quadratic Equation
===
type: prompt
incremental: true

One of the solutions to a polynomial equation $ax^2 + bx + c = 0$ is given by

$$x = \frac{-b + \sqrt{b^2 -4ac}}{2a}$$

Figure out how to use R functions and operations for square roots, exponentiation, and multiplication to calculate $x$ given $a=3, b=14, c=-5$.


```r
> (-14 + sqrt(14^2 - 4 * 3 * (-5)))/(2 * 3)
[1] 0.3333333
```

What did you learn? What did you notice?
- Parentheses are used to encapsulate the *arguments* to a function like `sqrt()`
- Operators like `\`, `*`, and `^` are useful for math
- Parentheses can also be used to establish order of operations

Packages
===
- The amazing thing about programming is that you are not limited to what is built into the language
- Millions of R users have written their own functions that you can use
- These are bundled together into *packages*
- To use functions that aren't built into the "base" language, you have to tell R to first go download the relevant code, and then to load it in the current session

```r
> install.packages("tidyverse")  # go download the package called 'tidyverse'- only have to do this once
> library("tidyverse")  # load the package into the current R session - do this every time you use R and need functions from this package
```

Packages
===
- The `tidyverse` package has a function called `read_csv()` that lets you read csv (comma-separated values) files into R. 
- csv is a common format for data to come in, and it's easy to export csv files from microsoft excel, for instance. 


```r
> # I have a file called 'mpg.csv' in a folder called data
> my_data = read_csv("data/mpg.csv")
Error in read_csv("data/mpg.csv"): could not find function "read_csv"
```

- This fails because I haven't yet loaded the `tidyverse` package

```r
> library(tidyverse)
```



```r
> my_data = read_csv("data/mpg.csv")
Parsed with column specification:
cols(
  `18.0   8   307.0      130.0      3504.      12.0   70  1` = col_character(),
  `chevrolet chevelle malibu` = col_character()
)
```

Packages
===
- packages only need to be loaded once per R session (session starts when you open R studio, ends when you shut it down)
- once the package is loaded it doesn't need to be loaded again before each function call

```r
> my_data_2 = read_csv("data/poly.csv")  # reading another csv file
Parsed with column specification:
cols(
  x = col_double(),
  y = col_double()
)
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
> my_data = read_csv("data/mpg.csv")
Parsed with column specification:
cols(
  `18.0   8   307.0      130.0      3504.      12.0   70  1` = col_character(),
  `chevrolet chevelle malibu` = col_character()
)
```

- `read_csv()` requires you to tell it where to find the file you want to read in
  - Windows, e.g.: `"C:\Users\me\Desktop\myfile.csv"`
  - Mac, e.g.: `"/Users/me/Desktop/myfile.csv"`
- If your data is not already in csv format, google "covert X format to csv" or "read X format data in R"
- We'll learn the details of this later, but this is enough to get you started! 
- the `mpg` dataset actually comes pre-loaded with `tidyverse`, so you have it already

Looking at data
===
- `mpg` is now a dataset loaded into R. To look at it, just type

```r
> mpg
# A tibble: 234 x 11
   manufacturer model    displ  year   cyl trans   drv     cty   hwy fl    class
   <chr>        <chr>    <dbl> <int> <int> <chr>   <chr> <int> <int> <chr> <chr>
 1 audi         a4         1.8  1999     4 auto(l… f        18    29 p     comp…
 2 audi         a4         1.8  1999     4 manual… f        21    29 p     comp…
 3 audi         a4         2    2008     4 manual… f        20    31 p     comp…
 4 audi         a4         2    2008     4 auto(a… f        21    30 p     comp…
 5 audi         a4         2.8  1999     6 auto(l… f        16    26 p     comp…
 6 audi         a4         2.8  1999     6 manual… f        18    26 p     comp…
 7 audi         a4         3.1  2008     6 auto(a… f        18    27 p     comp…
 8 audi         a4 quat…   1.8  1999     4 manual… 4        18    26 p     comp…
 9 audi         a4 quat…   1.8  1999     4 auto(l… 4        16    25 p     comp…
10 audi         a4 quat…   2    2008     4 manual… 4        20    28 p     comp…
# … with 224 more rows
```

This is a **data frame**, one of the most powerful features in R (a "tibble" is a kind of data frame).
- Similar to an Excel spreadsheet.
- One ro ~ one
instance of some (real-world) object.
- One column ~ one variable, containing the values for the
corresponding instances.
- All the values in one column should be of the same type (a number, a category, text, etc.), but
different columns can be of different types.

Investigating a relationship
===
Let's say we're curious about the relationship between a car's engine size (the column `displ`) and a car's highway fuel efficiency (column `hww`).
- Can we use R to make a plot of these two variables?


```r
> ggplot(mpg) + 
+   geom_point(aes(x = displ, y = hwy))
```

![plot of chunk unnamed-chunk-13](0-intro-plotting-figure/unnamed-chunk-13-1.png)

- `ggplot(dataset)` says "start a chart with this dataset"
- `+ geom_point(...)` says "put points on this chart"
- `aes(x=x_values y=y_values)` says "map the values in the column `x_values` to the x-axis, and map the values in the column `y_values` to the y-axis" (`aes` is short for *aesthetic*)

ggplot
===


```r
> ggplot(mpg) + 
+   geom_point(aes(x = displ, y = hwy))
```

![plot of chunk unnamed-chunk-14](0-intro-plotting-figure/unnamed-chunk-14-1.png)

***

- `ggplot` is short for "grammar of graphics plot"
  - This is a language for describing how data get linked to visual elements
- `ggplot()` and `geom_point()` are functions imported from the `ggplot2` package, which is one of the "sub-packages" of the `tidyverse` package we loaded earlier

Investigating a relationship
===
type: prompt
incremental: true

Make a scatterplot of `hwy` vs `cyl` (how many cylinders the car has)

```r
> ggplot(mpg) + 
+   geom_point(aes(x = hwy, y = cyl))
```

![plot of chunk unnamed-chunk-15](0-intro-plotting-figure/unnamed-chunk-15-1.png)


Investigating a relationship
===
type: prompt
incremental: true

Make a scatterplot of `hwy` vs `cyl` (how many cylinders the car has)


```r
> ggplot(mpg) + 
+   geom_point(aes(x = hwy, y = cyl))
```

![plot of chunk unnamed-chunk-16](0-intro-plotting-figure/unnamed-chunk-16-1.png)

Investigating a relationship
===
Let's say we're curious about the relationship between a car's engine size (the column `displ`) and a car's highway fuel efficiency (column `hww`).

![plot of chunk unnamed-chunk-17](0-intro-plotting-figure/unnamed-chunk-17-1.png)

- What's going on with these cars? They have higher gas mileage than cars of similar engine size, so maybe they are hybrids?
- If they are hybrids, they would probably be of `class` "compact" or "subcompact"?

Aesthetics
===
- Aesthetics aren't just for mapping columns to the x- and y-axis
- You can also use them to assign color, for instance


```r
> ggplot(mpg) + 
+   geom_point(aes(
+     x = displ, 
+     y = hwy, 
+     color=class
+   )) 
```

- ggplot automatically gives each value of the column a unique level of the aesthetic (here a color) and adds a legend
- What did we learn about the cars we were interested in?

***
<img src="0-intro-plotting-figure/unnamed-chunk-19-1.png" title="plot of chunk unnamed-chunk-19" alt="plot of chunk unnamed-chunk-19" width="90%" />

Aesthetics
===
- Aesthetics aren't just for mapping columns to the x- and y-axis
- Or we could have done a shape


```r
> ggplot(mpg) + 
+   geom_point(aes(
+     x = displ, 
+     y = hwy, 
+     shape=class
+   )) 
```


***

```
Warning: The shape palette can deal with a maximum of 6 discrete values because
more than 6 becomes difficult to discriminate; you have 7. Consider
specifying shapes manually if you must have them.
Warning: Removed 62 rows containing missing values (geom_point).
```

<img src="0-intro-plotting-figure/unnamed-chunk-21-1.png" title="plot of chunk unnamed-chunk-21" alt="plot of chunk unnamed-chunk-21" width="90%" />

Aesthetics
===
- Aesthetics aren't just for mapping columns to the x- and y-axis
- Or size


```r
> ggplot(mpg) + 
+   geom_point(aes(
+     x = displ, 
+     y = hwy, 
+     size=class
+   )) 
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
> ggplot(mpg) + 
+   geom_point(
+     aes(
+       x = displ, 
+       y = hwy
+     ),
+     color = "blue"
+   ) 
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
***

```r
> ggplot(mpg) + 
+   geom_point(
+     aes(
+       x = displ, 
+       y = hwy,
+       color = displ,
+       size = hwy
+     )
+   ) 
```

Exercise
===
incremental: true
type: prompt

What will this do? Why?


```r
> ggplot(mpg) + 
+   geom_point(aes(x = displ, y = hwy, color = "blue"))
```
***
![plot of chunk unnamed-chunk-29](0-intro-plotting-figure/unnamed-chunk-29-1.png)

Facets
===
- Aesthetics are useful for mapping columns to particular properties of a single plot
- Use **facets** to generate multiple plots with shared structure


```r
> ggplot(mpg) + 
+   geom_point(aes(x = displ, y = hwy)) + 
+   facet_wrap(~ class, nrow = 2)
```

<img src="0-intro-plotting-figure/unnamed-chunk-30-1.png" title="plot of chunk unnamed-chunk-30" alt="plot of chunk unnamed-chunk-30" style="display: block; margin: auto;" />
- `facet_wrap` is good for faceting according to unordered categories

Facets
===
- `facet_grid` is better for ordered categories, and can be used with two variables


```r
> ggplot(mpg) + 
+   geom_point(aes(x = displ, y = hwy)) + 
+   facet_grid(drv ~ cyl)
```

<img src="0-intro-plotting-figure/unnamed-chunk-31-1.png" title="plot of chunk unnamed-chunk-31" alt="plot of chunk unnamed-chunk-31" style="display: block; margin: auto;" />

Exercise
===
type:prompt
incremental: true

Run this code and comment on what role `.` plays:


```r
> ggplot(mpg) + 
+   geom_point(aes(x = displ, y = hwy)) +
+   facet_grid(drv ~ .)
```

<img src="0-intro-plotting-figure/unnamed-chunk-32-1.png" title="plot of chunk unnamed-chunk-32" alt="plot of chunk unnamed-chunk-32" style="display: block; margin: auto;" />


Geoms
===


```r
> ggplot(mpg) + 
+   geom_point(aes(x = displ, y = hwy))
```

<img src="0-intro-plotting-figure/unnamed-chunk-33-1.png" title="plot of chunk unnamed-chunk-33" alt="plot of chunk unnamed-chunk-33" style="display: block; margin: auto;" />
- Both these plots represent the same data, but they use a different geometric representation ("geom")
- e.g. bar chart vs. line chart, etc. 

***

```r
> ggplot(mpg) + 
+   geom_smooth(aes(x = displ, y = hwy))
```

<img src="0-intro-plotting-figure/unnamed-chunk-34-1.png" title="plot of chunk unnamed-chunk-34" alt="plot of chunk unnamed-chunk-34" style="display: block; margin: auto;" />

Geoms
===
- Different geoms are configured to work with different aesthetics. 
- e.g. you can set the shape of a point, but you ca’t set the “shape” of a line.
- On the other hand, you *can* set the "line type" of a line:


```r
> ggplot(mpg) + 
+   geom_smooth(aes(x = displ, y = hwy, linetype = drv))
```

<img src="0-intro-plotting-figure/unnamed-chunk-35-1.png" title="plot of chunk unnamed-chunk-35" alt="plot of chunk unnamed-chunk-35" style="display: block; margin: auto;" />

Geoms
===
- It's possible to add multiple geoms to the same plot

```r
> ggplot(mpg) + 
+   geom_smooth(aes(x = displ, y = hwy, color = drv)) + 
+   geom_point(aes(x = displ, y = hwy, color = drv))
```

<img src="0-intro-plotting-figure/unnamed-chunk-36-1.png" title="plot of chunk unnamed-chunk-36" alt="plot of chunk unnamed-chunk-36" style="display: block; margin: auto;" />

Geoms
===
- To assign the same aesthetics to all geoms, pass the aesthetics to the `ggplot` function directly instead of to each geom individually

```r
> ggplot(mpg, aes(x = displ, y = hwy, color = drv)) + 
+   geom_smooth() + 
+   geom_point()
```

<img src="0-intro-plotting-figure/unnamed-chunk-37-1.png" title="plot of chunk unnamed-chunk-37" alt="plot of chunk unnamed-chunk-37" style="display: block; margin: auto;" />

Geoms
===
- You can also use different mappings in different geoms

```r
> ggplot(mpg, mapping = aes(x = displ, y = hwy)) + 
+   geom_point(aes(color = class)) + 
+   geom_smooth()
```

<img src="0-intro-plotting-figure/unnamed-chunk-38-1.png" title="plot of chunk unnamed-chunk-38" alt="plot of chunk unnamed-chunk-38" style="display: block; margin: auto;" />

Exercise
===
type: prompt
- Use google or other resources to figure out how to receate this plot in R:

```
ggplot(mpg) + 
  ...
```

<img src="0-intro-plotting-figure/unnamed-chunk-39-1.png" title="plot of chunk unnamed-chunk-39" alt="plot of chunk unnamed-chunk-39" style="display: block; margin: auto;" />

- What might the name of this geom be? What properties of the plot (aesthetics) are mapped to what columns of the data?
- If you accomplish making the plot, can you figure out how to fix the labels overlapping at the bottom?

Learning More
===

From **R for Data Science**:

>If you want to learn more about the mechanics of ggplot2, I’d highly recommend grabbing a copy of the ggplot2 book: https://amzn.com/331924275X. It’s been recently updated, so it includes dplyr and tidyr code, and has much more space to explore all the facets of visualisation. Unfortunately the book isn’t generally available for free, but if you have a connection to a university you can probably get an electronic version for free through SpringerLink.

> Another useful resource is the R Graphics Cookbook by Winston Chang. Much of the contents are available online at http://www.cookbook-r.com/Graphs/.

> I also recommend Graphical Data Analysis with R, by Antony Unwin. This is a book-length treatment similar to the material covered in this chapter, but has the space to go into much greater depth.
