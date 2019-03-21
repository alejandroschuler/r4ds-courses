# R for Data Science Part 1: Working with Data in R

### Overview
This curriculum is a set of modules that will make you an expert at data I/O, transformation, programming, and visualization in R. 
We will focus on a consistent set of packages for these tasks called the `tidyverse` throughout the course.

This is not a traditional programming or computer science course. 
It is meant to be an *applied* tour of how to actually use R for your data science needs.
As the course progresses, however, we will delve deeper into the internals of the language in order to solve more complicated problems and you will become familiar with some of the fundamental constructs of the language itself. 

We will not cover statistical analysis of data in this course, but the curriculum is a prerequisite for a subsequent course on the theory and practice of supervised learning with R. 

### Prerequisites
No prior experience with R is expected. Those with experience using R will still likely find much of value in this course since it covers a more modern style of R programming that has only recently gained traction.

You will need to install R (and RStudio) to follow along with the material, or have access to a machine that has that software installed.
[Follow this link](https://cran.cnr.berkeley.edu/) and click on the appropriate options for your operating system to install R, 
then do the same to [install RStudio](https://www.rstudio.com/products/rstudio/download/#download).

### Learning Goals
By the end of each of these modules, you will be able to:

#### Tabular data in R
Packages: `dplyr`, `ggplot2`

* write neat R scripts and markdown reports in R studio
* find, read, and understand package and function documentation 
* read and write tabular data into R from flat files
* perform basic manipulations on tabular data: subsetting, manipulating and summarizing data, and joining
* visualize tabluar data using line and scatter plots along with color and facets

#### Data representation in R
Packages: `stringr`, `forcats`, `lubridate`, `readr`

* create and index vectors of different types
* efficiently manipulate strings, factors, and date-time vectors
* tightly control the intake of tabular data

#### Advanced tabular data manipulation in R
Packages: `tidyr`, `dplyr`, `RcppRoll`

* transform between tidy (tall) and messy (wide) data
* perform simultaneous multi-variable multi-function manipulations in dplyr
* perform manipulations that involve fixed or rolling windows of rows

#### Functional programming in R
Packages `purrr`, `furrr`

* write your own functions
* write code that evaluates conditionally
* create, manipulate, and inspect lists
* iterate functions over lists of arguments
* iterate in parallel

#### Metaprogramming in R
Packages `rlang`, `lobstr`

* create and evaluate expressions
* splice expressions into others within and outside of functions
* call tidyverse functions dynamically from other functions
* write your own tidyverse-like functions

#### Writing performant code in R
Packages `profvis`, `bench`

* predict what code will run slowly or quickly in R based on copy-on-modify semantics
* identify and correct code that can be vectorized
* profile and benchmark code to identify bottlenecks

### Textbook
We will be using parts of the fantastic book [R for Data Science](http://r4ds.had.co.nz/) by [Hadley Wickham](http://hadley.nz/) and Garrett Grolemund (O'Reilly Media, 2017); it is online and also available in hardcopy.

### Slides
Slides can be found [here](https://github.com/alejandroschuler/r4ds-courses). Download the `.html` files for the "finished" product or the `.Rpres` files to see how the sausage is made.

# Motivation

### Why R?
What does `R` have going for it? 
Dr. Wickham puts it well in the introduction to his other book, [Advanced R](http://adv-r.had.co.nz/Introduction.html):

* It’s free, open source, and available on every major platform. As a result, if you do your analysis in R, anyone can easily replicate it.
* A massive set of packages for statistical modelling, machine learning, visualisation, and importing and manipulating data. Whatever model or graphic you’re trying to do, chances are that someone has already tried to do it. At a minimum, you can learn from their efforts.
* Cutting edge tools. Researchers in statistics and machine learning will often publish an R package to accompany their articles. This means immediate access to the very latest statistical techniques and implementations.
* Deep-seated language support for data analysis. This includes features likes missing values, data frames, and subsetting.
* A fantastic community. It is easy to get help from experts on the R-help mailing list, stackoverflow, or subject-specific mailing lists like R-SIG-mixed-models or ggplot2. You can also connect with other R learners via twitter, linkedin, and through many local user groups.
* Powerful tools for communicating your results. R packages make it easy to produce html or pdf reports, or create interactive websites.
* A strong foundation in functional programming. The ideas of functional programming are well suited to solving many of the challenges of data analysis. R provides a powerful and flexible toolkit which allows you to write concise yet descriptive code.
* An IDE tailored to the needs of interactive data analysis and statistical programming.
* Powerful metaprogramming facilities. R is not just a programming language, it is also an environment for interactive data analysis. Its metaprogramming capabilities allow you to write magically succinct and concise functions and provide an excellent environment for designing domain-specific languages.
* Designed to connect to high-performance programming languages like C, Fortran, and C++.

[Coming from SAS, R can seem daunting](http://r4stats.com/articles/why-r-is-hard-to-learn/). 
That's a perfectly normal feeling! 
R is a fully-fledged programming language that can handle a lot more than data analysis, 
so it is naturally a little more complicated. I promise you that it is worth the effort.

If you already have some experience programming, R may seem quirky and inefficient to you.
That's also a normal feeling! 
You can find many hilarious takes on R's idiosyncrasies and problems scattered around the internet.
Some of my favorites are:
- [The R Inferno](https://www.burns-stat.com/pages/Tutor/R_inferno.pdf): a detailed guide to the base language, written partially in the style of *Dante's Inferno*.
- [aRrgh: a newcomer's (angry) guide to R](http://arrgh.tim-smith.us/): an experienced software engineer rants about R's quirks
- [Rbitrary standards](https://ironholds.org/projects/rbitrary/): a little about the history of R's strangest features
- [Evaluating the design of the R language](http://r.cs.purdue.edu/pub/ecoop12.pdf): academic computer scientists dissect R in this peer-reviewed paper. Highly technical.

Although some of the odd design choices are precisely what enable its most powerful features, 
[there are certainly improvements that could be made](http://adv-r.had.co.nz/Performance.html#language-performance).

### Why tidyverse?
The tidyverse solves both of these problems: 
it makes R [accessible to data analysts](http://varianceexplained.org/r/teach-tidyverse/) 
and cleaner for experienced programmers. 
It provides a consistent and principled framework for R programming that is easier to learn
and produces code that is easier to maintain than base R.

Of course, the tidyverse and adjacent packages are not always the right tool for the job. 
Other useful packages and frameworks include:
- `data.table`: fast data manipulation and rolling joins
- `ff`: on-disk manipulation of large datasets
- `zoo`: functions for time-series data
- `Rcpp`: helpers to write efficient C++ code that can be called by R

Furthermore, if you are writing your own package for the public, you may want to use base R as much as possible to reduce its dependency on other code.

All in all, though, the tidyverse provides by far the best unified interface to data anlysis in R.
It should be your go-to toolbox, even if there are tools you have that don't fit in it.
