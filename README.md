# R for Data Science

### Logistics
| Person | Role | Contact |
|---|---|---|
| Alejandro Schuler | Instructor | alejandro.schuler@berkeley.edu |

- Website: [https://github.com/alejandroschuler/r4ds-courses](https://github.com/alejandroschuler/r4ds-courses)

### Overview
This course will make you an expert at data I/O, transformation, programming, and visualization in R. 
We will use a consistent set of packages for these tasks called the `tidyverse`.

This is not a traditional programming or computer science course. 
It is meant to be an *applied* tour of how to actually use R for your data science needs. 
We also will not cover statistical analysis of data in this course, but the curriculum is a useful prerequisite for subsequent courses on statistics or machine learning.

This course is not graded, nor are there any assignments or homework. The lectures are just to get you started- they will be frequently interrupted by active learning exercises that you will be asked to complete in pairs or small groups. That's where the real learning will happen!

### Prerequisites
No prior experience with R is expected. Those with experience using R will still likely find much of value in this course since it covers a more modern style of R programming that has gained traction in the past decade.

We will use R through the RStudio interface. The easiest way to access RStudio is through the cloud: [posit.cloud](https://posit.cloud). It's fast and easy- just go the link, click "get started" and create an account. Once you're in, click "new project" near the upper-right and the RStudio interface will open.

Alternatively, you can install R and RStudio on your own computer: 
[Follow this link](https://cran.rstudio.com/) and click on the appropriate options for your operating system to install R, 
then do the same to [install RStudio](https://posit.co/download/rstudio-desktop/#download).

### Learning Goals
By the end of the course, you will be able to:

* comfortably use R through the Rstudio interface
* read and write tabular data between R and flat files
* subset, transform, summarize, join, and plot data
* write reusable and readable programs
* seek out, learn, and integrate new packages and code into your analyses

### Schedule

<table>
  <tbody>
    <tr>
        <th>Module</th>
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
            <li>recognize and index vectors and lists</li>
            <li>recognize, import, and inspect data frames</li>
            <li>issue commands to R using the Rstudio script pane</li>
        </ul></td>
        <td><ul>
            <li><code>tibble</code></li>
            <li><code>readr</code></li>
        </ul></td>
        <td>R4DS ch. 3, 5, 7, 8, 13-19</td>
    </tr>
    <tr>
      <td>3</td>
      <td>Basic Tabular Data Manipulation</td>
        <td><ul>
            <li>filter rows of a dataset based on conditions</li>
            <li>arrange rows of a dataset based on one or more columns</li>
            <li>select columns of a dataset</li>
            <li>mutate existing columns to create new columns</li>
            <li>use the pipe to combine multiple operations</li>          
        </ul></td>
        <td><ul>
            <li><code>dplyr</code></li>
        </ul></td>
        <td>R4DS ch. 4</td>
    </tr>
    <tr>
      <td>4</td>
      <td>Advanced Tabular Data Manipulation</td>
      <td>
        <ul>
            <li>group and summarize data by one or more columns</li>
            <li>transform between long and wide data formats</li>
            <li>combine multiple data frames using joins on one or more columns</li>
        </ul></td>
        <td><ul>
            <li><code>dplyr</code></li>
            <li><code>tidyr</code></li>
        </ul></td>
        <td>R4DS ch. 4, 6, 20, </td>
    </tr>
    <tr>
      <td>5</td>
      <td>Functional Programming</td>
        <td><ul>
            <li>write your own functions</li>
            <li>iterate functions over lists of arguments</li>
        </ul></td>
        <td><ul>
            <li><code>purrr</code></li>
        </ul></td>
        <td>R4DS ch. 26, 27</td>
    </tr>
  </tbody>
</table>



### In-class Exercises
Programming, like all things, is something you learn by doing. The lectures include a lot of in-class group exercises so you can get your hands dirty. When we come upon one of these we will split the class into small groups of 3-4 students each (plus maybe a TA). Once you are in your group you should then decide the roles each of you will have:
- **scribe** (1): The scribe will share their screen with the group and type out/execute the code required for the exercise. They will also contribute to the solution.
- **presenter** (1): The presenter is in charge of presenting the group's work to the rest of the class once the breakout session has concluded. They should also contribute to the solution.
- **contributor** (0+): Contributors are responsible for generating ideas and code for the exercise.

### Textbook
We will be using parts of the fantastic book [R for Data Science](https://r4ds.hadley.nz/) (R4DS:2e) by [Hadley Wickham](http://hadley.nz/), Mine Çetinkaya-Rundel, and Garrett Grolemund (O'Reilly Media, 2017); it is online and also available in hardcopy.

### Slides
Slides can be found in the `lectures` folder on the website. Github renders the `.md` files nicely in the browser. You can also download the `.Rpres` files for easy copy-pasting of code, etc.

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
- [Rbitrary standards](https://ironholds.org/resources/misc/rbitrary/): a little about the history of R's strangest features
- [Evaluating the design of the R language](http://janvitek.org/pubs/ecoop12.pdf): academic computer scientists dissect R in this peer-reviewed paper. Highly technical.

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
