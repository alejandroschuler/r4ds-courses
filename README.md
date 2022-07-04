# R for Data Science

### Logistics
| Person | Role | Contact |
|---|---|---|
| Alejandro Schuler | Instructor | alejandro.schuler@gmail.com |

- Website: https://github.com/alejandroschuler/r4ds-courses/tree/advance-2022
- Location: CCSR 4205
- Dates: Tuesday July 5, 2022 - Thursday July 7, 2022
- Time: 10am - 2pm

### Overview
This course will make you an expert at data I/O, transformation, programming, and visualization in R. 
We will use a consistent set of packages for these tasks called the `tidyverse`.

This is not a traditional programming or computer science course. 
It is meant to be an *applied* tour of how to actually use R for your data science needs. 
We also will not cover statistical analysis of data in this course, but the curriculum is a useful prerequisite for subsequent courses on statistics or machine learning.

This course is not graded, nor are there any assignments or homework. The lectures are just to get you started- they will be frequently interrupted by active learning exercises that you will be asked to complete in pairs or small groups. That's where the real learning will happen!

### Prerequisites
No prior experience with R is expected. Those with experience using R will still likely find much of value in this course since it covers a more modern style of R programming that has only recently gained traction.

You will need to install R (and RStudio) to follow along with the material, or have access to a machine that has that software installed.
[Follow this link](https://cran.rstudio.com/) and click on the appropriate options for your operating system to install R, 
then do the same to [install RStudio](https://rstudio.com/products/rstudio/download/#download).

### Learning Goals
By the end of the course, you will be able to:

* comfortably use R through the Rstudio interface
* read and write tabular data between R and flat files
* subset, transform, summarize, join, and plot data
* write reusable and readable programs
* seek out, learn, and integrate new packages into your analyses

### Schedule

<table>
  <tbody>
    <tr>
        <th>Day</th>
        <th>Topic</th>
        <th>Learning Goals</th>
        <th>Packages</th>
        <th>Reading</th>
    </tr>
    <tr>
        <td>1</td>
        <td>Rstudio and Visualization</td>
        <td><ul>
              <li>issue commands to R using the Rstudio REPL interface</li>
              <li>load a package into R</li>
              <li>read some tabluar data into R</li>
              <li>visualize tabluar data using ggplot geoms, aesthetics, and facets</li>
        </ul></td>
        <td><ul>
            <li><code>ggplot2</code></li>
        </ul></td>
        <td>R4DS ch. 1-3</td>
    </tr>
    <tr>
      <td>2</td>
      <td>R Fundamentals</td>
      <td>
        <ul>
            <li>save values to variables</li>
            <li>find and call R functions with multiple arguments by position and name</li>
            <li>recognize vectors and vectorized functions</li>
            <li>recognize and inspect data frames</li>
            <li>issue commands to R using the Rstudio script pane</li>
        </ul>
      </td>
        <td></td>
        <td>R4DS ch. 4</td>
    </tr>
    <tr>
      <td>3</td>
      <td>Basic Tabular Data Manipulation</td>
        <td><ul>
            <li>filter rows of a dataset based on conditions</li>
            <li>arrange rows of a dataset based on one or more columns</li>
            <li>select columns of a dataset</li>
            <li>mutate existing columns to create new columns</li>
            <li>group and summarize data by one or more columns</li>
            <li>use the pipe to combine multiple operations</li>
        </ul></td>
        <td><ul>
            <li><code>dplyr</code></li>
        </ul></td>
        <td>R4DS ch. 5</td>
    </tr>
  </tbody>
</table>

This course is based on a longer version I've taught before. The materials for the longer version are also accessible here so I'll give you the outline for them as well

<table>
  <tbody>
    <tr>
      <td>4</td>
      <td>Advanced Tabular Data Manipulation</td>
      <td>
        <ul>
            <li>compute cumulative, offset, and sliding-window transformations</li>
            <li>simultaneously transform or summarize multiple columns</li>
            <li>transform between long and wide data formats</li>
            <li>combine multiple data frames using joins on one or more columns</li>
        </ul></td>
        <td><ul>
            <li><code>slider</code></li>
            <li><code>dplyr</code></li>
            <li><code>tidyr</code></li>
        </ul></td>
        <td>R4DS ch. 12,13</td>
    </tr>
    <tr>
      <td>5</td>
      <td>Datatypes and I/O</td>
      <td>
        <ul>
            <li>create and index vectors of different types</li>
            <li>efficiently manipulate strings, factors, and date-time vectors</li>
            <li>tightly control the intake of tabular data</li>
        </ul>
      </td>
        <td><ul>
            <li><code>forcats</code></li>
            <li><code>stringr</code></li>
            <li><code>lubridate</code></li>
            <li><code>readr</code></li>
        </ul></td>
        <td>R4DS ch. 11, 14-16</td>
    </tr>
    <tr>
      <td>6</td>
      <td>Functional Programming</td>
        <td><ul>
            <li>write your own functions</li>
            <li>write code that evaluates conditionally</li>
            <li>create, manipulate, and inspect lists</li>
            <li>iterate functions over lists of arguments</li>
            <li>iterate in parallel</li>
        </ul></td>
        <td><ul>
            <li><code>purrr</code></li>
            <li><code>furrr</code></li>
            <li><code>zeallot</code></li>
        </ul></td>
        <td>R4DS ch. 17-21</td>
    </tr>
    <tr>
      <td>7</td>
      <td>Worked Analyses in R</td>
        <td><ul>
            <li>point out ways to use tidyverse functions in biological analyses</li>
            <li>find, learn, and integrate domain-specific R packages into an analysis</li>
        </ul></td>
        <td></td>
        <td></td>
    </tr>
    <tr>
      <td>8</td>
      <td>Bring-Your-Own-Data Lab</td>
        <td><ul>
            <li>apply tidyverse functions to solve a real-life data processing problem</li>
            <li>provide programming consultation support to peers</li>
        </ul></td>
        <td></td>
        <td></td>
    </tr>
  </tbody>
</table>

### In-class Exercises
Programming, like all things, is something you learn by doing. The lectures include a lot of in-class group exercises so you can get your hands dirty. When we come upon one of these we will split the class into [Zoom breakout rooms](https://blog.zoom.us/using-zoom-breakout-rooms/) of 3-4 students each (plus maybe a TA). Once you are in your group you should then decide the roles each of you will have:
- **scribe** (1): The scribe will share their screen with the group and type out/execute the code required for the exercise. They will also contribute to the solution.
- **presenter** (1): The presenter is in charge of presenting the group's work to the rest of the class once the breakout session has concluded. They should also contribute to the solution.
- **contributor** (0+): Contributors are responsible for generating ideas and code for the exercise.

### Textbook
We will be using parts of the fantastic book [R for Data Science](http://r4ds.had.co.nz/) (R4DS) by [Hadley Wickham](http://hadley.nz/) and Garrett Grolemund (O'Reilly Media, 2017); it is online and also available in hardcopy.

### Slides
Slides can be found [here](https://github.com/alejandroschuler/r4ds-courses/tree/advance-2022lectures). Github renders the `.md` files nicely in the browser but to see plots you should open the `.pdf` versions. You can also download the `.Rpres` files for easy copy-pasting of code, etc.

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

[Coming from SAS or excel, R can seem daunting](http://r4stats.com/articles/why-r-is-hard-to-learn/). 
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
- [Evaluating the design of the R language](https://haben-michael.github.io/stats195/Morendat%20et%20al.%20--%20Evaluating%20the%20design%20of%20the%20R%20language.pdf): academic computer scientists dissect R in this peer-reviewed paper. Highly technical.

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
- `zoo`: functions for time-series data
- `Rcpp`: helpers to write efficient C++ code that can be called by R

Furthermore, if you are writing your own package for the public, you may want to use base R as much as possible to reduce its dependency on other code.

All in all, though, the tidyverse provides by far the best unified interface to data anlysis in R.
It should be your go-to toolbox, even if there are tools you have that don't fit in it.
