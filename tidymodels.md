Supervised Learning: Theory and Practice in R
========================================================
author: Alejandro Schuler
date: 2019
transition: none
width: 1680
height: 1050


```r
library(tidyverse)
library(magrittr)
```


<style>
.small-code pre code {
  font-size: 0.5em;
}
</style>

What is the question?
===
- Scientific questions in clinical informatics can be roughly categorized into one of six types
- One project may have more than one type of question
- Similar methods can be used to answer different questions
- In this course we will discuss *predictive* questions, which I prefer to call *supervised learning* questions


Citation: [*Leek, Jeffery T., and Roger D. Peng. "What is the question?." Science 347.6228 (2015): 1314-1315.*](https://www.d.umn.edu/~kgilbert/ened5560-1/The%20Research%20Question-2015-Leek-1314-5.pdf)

What is the question?
===

<div align="center">
<img src="http://science.sciencemag.org/content/sci/347/6228/1314/F1.large.jpg" width=1200 height=1000>
</div>

What is supervised learning?
========================================================
- Supervised learning is about estimating $E[Y|X]$: given that we observe some variables $X=x$, what should we expect the value of the variable $Y$ to be? For example:
  - Given that we know the demographics and presenting characteristics of a patient, can we predict what their final diagnosis will be for given visit? (diagnostic model)
  - Given a patient's current LAPS, demographics, and vitals, can we predict whether or not they will transfer to the ICU in 6 hours? (prognostic model)
- We estimate $E[Y|X]$ from data $(Y_i, X_i)$ that has been collected
- Supervised learning is also called 
  - *regression* if $Y$ is continuous (linear regression being one example)
  - *classification* if $Y$ is categorical or binary
  - *prediction* if $Y$ is something typically measured after $X$
- We do not care *why* or *how* $X$ and $Y$ are related. 
- $Y$ is alternatively called the *outcome*, *dependent variable*, or *target*
- $X$ are referred to as the *covariates*, *independent variables*, *predictors*, or *features*

A note about math and symbols
===
- $E[Y|X]$ and other mathematical notations are your friends, not your adversaries
- They are just a shorter way of expressing ideas that would otherwise take a lot of text
- Mathematics was an oral tradition for most of its history!
- If at any point it is not clear what is meant by notation, please speak up

Exercise: supervised learning?
===
Which of these is a supervised learning problem and which is not?
- Estimating the incidence of kidney disease in the bay area
- Finding patients with a mention of type 2 diabetes in their record
- Finding groups of patients that are more similar to each other than they are to patients outside the group
- Estimating the risk that a hypertensive patient will have a heart attack in the next three months
- Estimating how long it will take for a patient's wound to heal
- Estimating the effect of a heart surgery on 30-day survival

Answer: supervised learning?
===
Which of these is a supervised learning problem and which is not?
- Estimating the incidence of kidney disease in the bay area
- Finding patients with a mention of type 2 diabetes in their record
- Finding groups of patients that are more similar to each other than they are to patients outside the group
- **Estimating the risk that a hypertensive patient will have a heart attack in the next three months**
- **Estimating how long it will take for a patient's wound to heal**
- Estimating the effect of a heart surgery on 30-day survival

Data-Generating Processes
===
type: section

The data-generating process (DGP)
===
- The true model is the real process that generates the data. We imagine that the data are drawn from an unknown probability distribution over the covariates and outcome $(X_i,Y_i) \overset{IID}{\sim} \mathcal{D}(X,Y)$
  - Here, $\mathcal{D}(X,Y)$ is the data-generating process (true model)
  - If we knew what this was, we would know everything there is to know about the relationship between $X$ and $Y$
- In reality, we can never completely pin this down, but we assume the universe generates the data *somehow* and there is *some* "real" distribution $\mathcal{D}$ the the data are "drawn from"
  
An example DGP
===
- In this universe, assume $X$ (e.g. patient age in some population) and $Y$ (e.g. patient COPS2 in that population) are generated via $(X,Y) \sim \mathcal{N}(\mathbf{\mu}, \mathbf{\Sigma})$



```r
> library(MASS) # for mvrnorm

Attaching package: 'MASS'
The following object is masked from 'package:dplyr':

    select
> 
> Sigma = rbind(c(5,4), 
+               c(4,7))
> mu = c(63, 40)
> 
> mvrnorm(5, mu, Sigma) %>%
+   as_tibble() %>%
+   set_names(c("x","y"))
Warning: `as_tibble.matrix()` requires a matrix with column names or a `.name_repair` argument. Using compatibility `.name_repair`.
This warning is displayed once per session.
# A tibble: 5 x 2
      x     y
  <dbl> <dbl>
1  62.7  37.7
2  62.8  40.9
3  60.6  38.5
4  65.5  44.5
5  64.0  40.6
```

An example DGP
===
- We've just generated data!
- In real life, we don't get to see the "code" that made the data, we just get the data itself:

```
# A tibble: 5 x 2
      x     y
  <dbl> <dbl>
1  62.7  37.7
2  62.8  40.9
3  60.6  38.5
4  65.5  44.5
5  64.0  40.6
```
- When we talk about the DGP (or "true model"), we're talking about the unknown "code" that made our data
- The notation we use is $(x_i,y_i) \overset{IID}{\sim} \mathcal{D}(X,Y)$. 
  - $(\mathbf x,\mathbf y)$ represent the dataset we might draw: i.e. $\mathbf y = [y_1, y_2 \dots y_n]$
  - $\mathcal{D}(X,Y)$ is the code that the data get drawn from. 
  - IID (independent and identically distributed) means that the code is the same each time we run it (it doesn't change over time, for instance)

An example DGP
===
Let's generate 10000 samples

```r
> data = mvrnorm(10000, mu, Sigma) %>%
+   as_tibble() %>%
+   set_names(c("x","y"))
```
An example DGP: conditional mean
===
- If $(X,Y) \sim \mathcal{N}(\mathbf{\mu}, \mathbf{\Sigma})$, we can do some math to figure out that $E[Y|X=x] = \mu_Y + \sigma_{XY} \sigma_{X}^{-1} (x-\mu_X)$, where

$\mathbf{\mu} = \left[ \begin{array}{c} \mu_X \\ \mu_Y \end{array} \right]$
$\mathbf{\Sigma} = \left[ \begin{array}{cc} \sigma_{X} & \sigma_{XY} \\ \sigma_{XY} & \sigma_{Y} \end{array} \right]$

```r
> Sigma = rbind(c(5,4), 
+               c(4,7))
> mu = c(63, 40)
> 
> names(mu) = c("x", "y")
> rownames(Sigma) = c("x","y")
> colnames(Sigma) = c("x","y")
> 
> # ----> math -----> 
> E_y_given_x = function(x){
+   mu["y"] + (Sigma["x","y"] / Sigma["x","x"]) * (x-mu["x"])
+ }
```

An example DGP: visualizing samples and a conditional mean
===

```r
> data %>%
+   mutate(E_y_given_x = E_y_given_x(x)) %>%
+ ggplot(aes(x=x, y=y)) +
+   geom_point(alpha=0.3, color="grey") +
+   geom_density2d(color="black") + 
+   geom_line(aes(y=E_y_given_x), color="cyan", size=2)
```

<img src="tidymodels-figure/unnamed-chunk-8-1.png" title="plot of chunk unnamed-chunk-8" alt="plot of chunk unnamed-chunk-8" style="display: block; margin: auto;" />

An example DGP: visualizing samples and a conditional mean
===
<img src="tidymodels-figure/unnamed-chunk-9-1.png" title="plot of chunk unnamed-chunk-9" alt="plot of chunk unnamed-chunk-9" style="display: block; margin: auto 0 auto auto;" />

***

<img src="tidymodels-figure/unnamed-chunk-10-1.png" title="plot of chunk unnamed-chunk-10" alt="plot of chunk unnamed-chunk-10" style="display: block; margin: auto auto auto 0;" />

The goal of supervised learning
===
<img src="tidymodels-figure/unnamed-chunk-11-1.png" title="plot of chunk unnamed-chunk-11" alt="plot of chunk unnamed-chunk-11" style="display: block; margin: auto;" />

***

- We're interested in approximating this cyan function $f(x) = E[Y|X=x]$ which we call the **conditional mean** or target function
- We'll say $\hat{f}(x)$ is an approximation of $f$ that we come up with using the data

**The goals of supervised learning are:**
  1. Come up with a good estimate $\hat{f}(x)$ (*learning*)
  2. Figure out how good that estimate is (*evaluating*)

Constructing DGPs from conditional means
====
- One way to imagine a data generating process is to start with $f(x)$ "known".
- First generate $X$ (at random), then calculate $f(X)$ and add some mean-zero noise to obtain a value for $Y$.
- For example:

```r
> n = 1000
> data = tibble(
+   x = rpois(n,5) + runif(n),
+   f_x = sin(x) + x, 
+   y = f_x + rnorm(n))
```
<img src="tidymodels-figure/unnamed-chunk-13-1.png" title="plot of chunk unnamed-chunk-13" alt="plot of chunk unnamed-chunk-13" style="display: block; margin: auto;" />


Exercise: make your own DGP
===
- Use what you've learned to come up with your own 2-variable DGP.
- You should produce a data frame with three columns: `x`, `y`, and `f_x`
- Plot your data with `geom_point()` for `(x,y)` and `geom_line()` for `(x,f_x)`. Add a `geom_smooth()` for $\hat{f}(x)$

Answer: make your own DGP
===
- Use what you've learned to come up with your own 2-variable DGP.
- You should produce a data frame with three columns: `x`, `y`, and `f_x`

```r
> n = 1000
> data = tibble(
+   x = if_else(rbinom(n,1,0.5)==1, runif(n,0,1), rnorm(n,3)),
+   f_x = x^2,
+   y = f_x + rchisq(n,3)-3)
```

Answer: make your own DGP
===
class: small-code

- Plot your data with `geom_point()` for `(x,y)` and `geom_line()` for `(x,f_x)`. Add a `geom_smooth()` for $\hat{f}(x)$

```r
> ggplot(data, aes(x,y)) +
+   geom_point(color="grey", alpha=0.5) + 
+   geom_line(aes(y=f_x, color="f"), size=2) + 
+   geom_smooth(method="lm", aes(color="f_hat"), size=2, linetype=2, se=F) +
+   scale_colour_manual(name = "function",
+       values=c("f" = "cyan", "f_hat" = "purple"),
+       labels = c("f"=expr(f(x)), "f_hat"=expr(hat(f)(x))))
```

<img src="tidymodels-figure/unnamed-chunk-15-1.png" title="plot of chunk unnamed-chunk-15" alt="plot of chunk unnamed-chunk-15" style="display: block; margin: auto;" />

Multi-covariate DGPs
===
- So far we've only seen examples of DGPs where $X$ is 1-dimensional
- Here's an example of a DGP (and the data it generates) where each $x_i$ is a length $p=2$ vector:

```r
> n = 100
> f = function(x1, x2) x1 + 4*x2 - x1*x2 # conditional mean
> 
> mvrnorm(n, mu, Sigma) %>%
+   as_tibble() %>%
+   set_names(c("x1", "x2")) %>%
+   mutate(y = f(x1, x2) + rnorm(n))
# A tibble: 100 x 3
      x1    x2      y
   <dbl> <dbl>  <dbl>
 1  60.2  38.8 -2125.
 2  62.8  41.2 -2360.
 3  65.2  39.6 -2360.
 4  67.4  40.2 -2480.
 5  57.9  36.8 -1922.
 6  61.7  38.4 -2151.
 7  62.8  40.6 -2326.
 8  65.4  43.9 -2634.
 9  62.0  37.9 -2135.
10  63.2  35.9 -2063.
# … with 90 more rows
```
- Now $f(\mathbf x) = f([x_1, x_2])$ is a function of a vector (i.e. a function of $p$ variables) so this creates a "surface" that we want to estimate instead of a "curve".

Multi-covariate DGPs
===
class: small-code

Here's a function we'll use later on to generate $n$ samples from a multivariate normal distribution where the user passes in $\beta$ (the length of which determines how many covariates there are):
- $X \sim \mathcal N(\mathbf \mu, \mathbf \Sigma)$
- $Y \sim \mathcal N(\beta_0 + X\beta_{1:p}, 1)$
- $\mathbf \Sigma$ and $\mathbf \mu$ are picked randomly

```r
> library(stringr)
> square_matrix = function(matrix) t(matrix) %*% matrix
> gen_data = function(betas, n) { # betas[1] is an intercept
+   p = length(betas)
+   Sigma = rnorm((p-1)^2) %>% # random covariance between variables
+     matrix(nrow=(p-1)) %>%  # turn it into a matrix
+     square_matrix() # square it so the result is positive-definite
+   mu = rnorm(p-1) # random means of the variables
+   x = mvrnorm(n, mu, Sigma) # sample variables 
+   x = cbind(rep(1,n), x) # add a dummy intercept variable
+   y = x %*% betas + rnorm(n, sd=0.5) # generate y
+   x_names = c("intercept", str_c("x", 1:(p-1), sep=""))
+   x %>% # put the data together into data frame
+     as_tibble() %>%
+     set_names(x_names) %>% # human-readable names
+     mutate(y = y[,1]) # y is a matrix so get the column vector out
+ }
```

Multi-covariate DGPs
===

```r
> gen_data(c(1,2,3,4), 5)
# A tibble: 5 x 5
  intercept     x1     x2     x3      y
      <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
1         1  0.405 -2.09  -0.625  -6.94
2         1 -2.21  -3.20  -3.82  -27.7 
3         1  0.379 -0.476  0.419   2.67
4         1  1.56   0.728  0.970  10.1 
5         1 -0.607 -1.56  -4.52  -23.3 
> gen_data(c(1,2,3,4,-1,-10,100), 5)
# A tibble: 5 x 8
  intercept     x1    x2     x3     x4     x5      x6      y
      <dbl>  <dbl> <dbl>  <dbl>  <dbl>  <dbl>   <dbl>  <dbl>
1         1  2.90   3.95  4.69  1.79    5.25  -1.09   -126. 
2         1 -0.702  1.06 -2.12  1.28   -3.30  -2.92   -267. 
3         1  0.334  3.84 -0.140 1.97    0.401  0.0500   12.2
4         1  2.43   1.76  0.929 0.0959 -9.07   0.276   133. 
5         1 -0.179 -1.29 -2.01  0.922  -2.95  -4.60   -443. 
```

DGPs with categorical variables
===
- So far we've only seen examples of DGPs where $X$ and $Y$ are numeric. We can also imagine DGPs where they are categorical
- Here's an example of a DGP (and the data it generates) with categorical variables

```r
> n = 100
> inv_logit = function(log_odds) exp(log_odds)/(1+exp(log_odds))
> f = function(x1, x2) inv_logit(-x1 + 4*x2 - x1*x2) # conditional mean
> 
> mvrnorm(n, mu, Sigma) %>%
+   as_tibble() %>%
+   set_names(c("x1", "x2")) %>%
+   mutate(x1 = x1>=63) %>%
+   mutate(y = rbinom(n, 1, f(x1, x2))) %>%
+   head(4)
# A tibble: 4 x 3
  x1       x2     y
  <lgl> <dbl> <int>
1 TRUE   42.7     1
2 FALSE  39.4     1
3 TRUE   41.1     1
4 TRUE   40.4     1
```
- In this case, $f(x) = E[Y|X=x] = P(Y=1|X=x)$ is the class probability

Summary: DGPs in supervised learning
===

- Data are generated by "code" that we think of as being run by the universe 
- We want to know $f(x) = E[Y|X=x]$, which is baked into the code, but we can't see the code
- We are interested in using the observed data that the code generates to guess what the function $f(x) = E[Y|X=x]$ is

Supervised Learning
===
type: section

Supervised Learning
===
- Informally, doing supervised learning (or "fitting a model") refers to the process of guessing $\hat f(x)$ given data $(\mathbf x, \mathbf y)$
- Formally, supervised learning refers to finding a DGP from a specified class of DGPs that "best fits" the observed data.

**Three ingredients of supervised learning:**

1. A "statstical model" is a *class of DGPs*, which we call  $\mathcal F$.
2. To measure "best fit", we have to pick a metric $L$ (the *loss*) to assess each potential DGP against the observed data
3. The last thing we need is an efficient way to look through different DGPs in $\mathcal F$ since it's impractical to try them all (the *optimization algorithm*)

***

- By analogy, imagine trying to decide what to eat:

1. The model is the menu of the restaurant you go to- it defines what your choices are. 
2. The loss is your taste- it defines what you think will be good to eat
3. The optimization algorithm is how you search the menu

Fitting a model
===
- Informally, "fitting" a model refers to the process of guessing $\hat f(x)$ given data $(\mathbf x, \mathbf y)$
- Formally, "fitting" a" model refers to finding a DGP from a specified class of DGPs that "best fits" the observed data.

**Three ingredients of model fitting:**

1. A "statstical model" is a *class of DGPs*, which we call  $\mathcal F$.
2. To measure "best fit", we have to pick a metric $L$ (the *loss*) to assess each potential DGP against the observed data
3. The last thing we need is an efficient way to look through different DGPs in $\mathcal F$ since it's impractical to try them all (the *optimization algorithm*)

***

We'll work through an example using this data

```r
> data = tibble(
+   x = rnorm(100),
+   y = x + rnorm(100, sd=0.5)
+ )
> data  %$% qplot(x,y)
```

<img src="tidymodels-figure/unnamed-chunk-20-1.png" title="plot of chunk unnamed-chunk-20" alt="plot of chunk unnamed-chunk-20" style="display: block; margin: auto;" />

A class of DGPs (the model)
=== 
- After looking at the plot, we guess that the data are generated as follows: $X ~ P(X)$ (unknown and don't care) and then $Y = \alpha + \beta X$ with $\alpha$ and $\beta$ unknown. Thus $\hat f(x) = E[Y|X=x] = \alpha + \beta X$
- We call $\alpha$ and $\beta$ the *parameters* of the model $\mathcal F$
- $\mathcal F$ is a *class* of DGPs, since each combination of $\alpha$ and $\beta$ is actually a separate DGP. Thus each value of $\alpha$ and $\beta$ give a different potential conditional mean $\hat f(x)$

```r
> f_hat_model = function(alpha, beta) { # given parameters 
+   function(x) alpha + beta*x # returns a function f hat
+ }  
```

A loss function
=== 
- Let's say we pick $\beta = 1$ and $\alpha = 0$. How good is $\hat f$ relative to our data?
- To answer this question, we pick a loss function $L(\hat f, \mathbf x, \mathbf y)$ that compares $\hat f$ to the observed data. This often takes the form $L(\hat f(x), y) = L(\hat y, y)$
- One common choice when the outcome $Y$ is continuous is root-mean-squared error:

```r
> rmse_loss = function(f_hat, data) {
+   ((f_hat(data$x) - data$y)^2) %>%
+     mean() %>%
+     sqrt()
+ }
```

An optimization algorithm
=== 
- Ideally, we could try every possible DGP in our model (every possible value of $\alpha$ and $\beta$), but we don't have infinite time
- Let's do a **grid search**. We'll enumerate a finite number of possible values for the parameters, find out what $\hat f$ would be given those parameters, and evaluate how good it would be according to $L$

```r
> grid_search_params = function(params) {
+   params %>% 
+     pmap_dbl(function(alpha, beta) {
+       f_hat = f_hat_model(alpha, beta)
+       rmse_loss(f_hat, data)
+   })
+ }
```

***

- We'll optimize over these parameters:

```r
> params = list(
+   alpha = seq(-10,10,0.5),
+   beta = seq(-10,10,0.5)) %>%
+ cross_df() 
```
- This is called a grid search because we can lay the parameters out in a grid:

```r
> params %$% qplot(alpha, beta) + geom_point(size=0.01)
```

<img src="tidymodels-figure/unnamed-chunk-25-1.png" title="plot of chunk unnamed-chunk-25" alt="plot of chunk unnamed-chunk-25" style="display: block; margin: auto;" />

Putting it all together
===
We now evaluate the losses for each set of parameters:

```r
> rmse = grid_search_params(params)
```
- Now we can see each set of parameters (potential DGP) and its corresponding loss

```r
> model_performance = params %>%
+   mutate(rmse = rmse) %>%
+   arrange(rmse) %>%
+   mutate(best = rmse==min(rmse))
> model_performance %>% head()
# A tibble: 6 x 4
  alpha  beta  rmse best 
  <dbl> <dbl> <dbl> <lgl>
1   0     1   0.463 TRUE 
2   0     0.5 0.662 FALSE
3   0.5   1   0.673 FALSE
4  -0.5   1   0.690 FALSE
5   0     1.5 0.780 FALSE
6   0.5   0.5 0.827 FALSE
```
- Looks like the parameters with lowest loss are $\beta=1$ and $\alpha=0$ so our fit model should be $Y = 1X + 0$.

***

<img src="tidymodels-figure/unnamed-chunk-28-1.png" title="plot of chunk unnamed-chunk-28" alt="plot of chunk unnamed-chunk-28" style="display: block; margin: auto;" />


Putting it all together
===

```r
> f_hat = model_performance %>%
+   filter(best) %>%
+   sample_n(1) %$% # in case of ties
+   f_hat_model(alpha, beta)
> 
> data %>%
+ ggplot(aes(x=x,y=y)) +
+   geom_point() +
+   geom_line(aes(y=f_hat(x)), color="purple")
```

<img src="tidymodels-figure/unnamed-chunk-29-1.png" title="plot of chunk unnamed-chunk-29" alt="plot of chunk unnamed-chunk-29" style="display: block; margin: auto;" />

***

- We just developed a brand new supervised learning method!
- Our method is defined by:
  1. A linear **model**
  2. Root-mean-squared-error **loss**
  3. A grid search **optimization algorithm**
  
- And, looking at the data and the fit, it actually works!

Exercise: polynomial regression
===

- Read these data into R and make sure you can plot them:

```r
> # data = read_csv("http://dords-gitlab.kaiser.org:5080/aschuler/r4ds-courses/raw/master/data/poly.csv")
> poly = read_csv("data/poly.csv")
Parsed with column specification:
cols(
  x = col_double(),
  y = col_double()
)
> poly  %$% qplot(x,y)
```

<img src="tidymodels-figure/unnamed-chunk-31-1.png" title="plot of chunk unnamed-chunk-31" alt="plot of chunk unnamed-chunk-31" style="display: block; margin: auto;" />

***

- Using the previous slides as a template, create your own supervised learning method to fit these data that uses:
  - a *2nd-order polynomial model*: $Y = \gamma X^2 + \beta X + \alpha$. 
  - root-mean-squared-error loss
  - grid search optimization over the three parameters (you'll need to eyeball the data to figure out the parameter ranges to test over and the spacing out of the parameter grid)
  
Answer: polynomial regression
===


```r
> f_hat_model = function(alpha, beta, gamma) { # added gamma
+   function(x) alpha + beta*x + gamma*x^2 # added gamma term
+ }  
> 
> rmse_loss = function(f_hat, data) { # same as before
+   ((f_hat(data$x) - data$y)^2) %>%
+     mean() %>%
+     sqrt()
+ }
> 
> grid_search_params = function(params) {
+   params %>% 
+     pmap_dbl(function(alpha, beta, gamma) { # added gamma
+       f_hat = f_hat_model(alpha, beta, gamma) # added gamma
+       rmse_loss(f_hat, poly)
+   })
+ }
```

  
Answer: polynomial regression
===
class: small-code


```r
> params = list(
+   alpha = seq(-10,10,1),
+   beta = seq(-10,10,1),
+   gamma = seq(-10,10,1)) %>% # added gamma
+ cross_df() 
> 
> rmse = grid_search_params(params)
> 
> model_performance = params %>%
+   mutate(rmse = rmse) %>%
+   arrange(rmse) %>%
+   mutate(best = rmse==min(rmse))
> 
> f_hat = model_performance %>%
+   filter(best) %>%
+   sample_n(1) %$% # in case of ties
+   f_hat_model(alpha, beta, gamma) # added gamma
```


```r
> poly %>%
> ggplot(aes(x=x,y=y)) +
>   geom_point() +
>   geom_line(aes(y=f_hat(x)), color="purple")
```

***

<img src="tidymodels-figure/unnamed-chunk-35-1.png" title="plot of chunk unnamed-chunk-35" alt="plot of chunk unnamed-chunk-35" style="display: block; margin: auto;" />

- Looks good!

Problems with our method
===
What are the problems with our general approach so far?

Problems with our method
===
- Linear/polynomial model is restrictive. What if the relaitonship between $X$ and $Y$ is actually something like $Y \sim \mathcal{N}(\sin(X), 1)$?
- RMSE is sensetive to outliers
- Grid search is slow and further restricts the model
  - As the number of parameters increases, the number of grid points vastly increases. With $p$ parameters, each with $10$ unique values in the grid, the total number of grid points is $10^p$! This is one effect of the **curse of dimensionality**.
  - The grid also restricts the model space to a particular region, e.g. $(\alpha, \beta, \gamma) \in [-10,10]^3$ instead of $\in \mathbb{R}^3$
  
These are often fundamental problems in supervised learning! In general, we worry about:
- Models that are too restrictive
- Losses that are sensitive to outliers
- Optimization algorithms that are too slow or further restrict the model

Optimization algorithms
===
type: section

Doing better than grid search
===
- Grid search is the most serious problem with our method so far
- Let's improve on it using *gradient descent*
- Idea: write $L(\hat f_{\alpha, \beta}, \mathbf x, \mathbf y)$ as a function of the parameters $\alpha$ and $\beta$ since the data $\mathbf x, \mathbf y$ are fixed.

$L(\hat f_{\alpha, \beta}, \mathbf x, \mathbf y) = \sum_i^N (\hat f_{\alpha, \beta}(x_i) - y_i)^2$

$L_{\mathbf x, \mathbf y}(\alpha, \beta) = \sum_i^N (\alpha + \beta x_i - y_i)^2 = \sum^N_i \alpha^2 + 2 \alpha \beta x_i - 2 \alpha y_i + \beta^2 x_i^2 - 2\beta x_i y_i + y_i^2$

- Seen as a function of $\alpha$ and $\beta$, this is a quadratic function
  - Quadratics have a single global minimum, which means there is one optimal set of parameters $(\alpha^*, \beta^*)$
- Use a trick from calculus: to find the minimum of a function, find where its derivative is equal to 0
  - $\frac{\partial L}{\partial \alpha} = 2\sum^N_i \alpha + \beta x_i - y_i$
  - $\frac{\partial L}{\partial \beta} = 2\sum^N_i \alpha x_i + \beta x_i^2 - \beta x_i y_i$

Gradient descent
===
class: small-code

- Instead of doing more math, we let the computer do the work of finding an approximate solution to $\nabla_{\alpha,\beta} L = 0$ for us
- Given the derivative (gradient) function, evaluate at a point in parameter space $(\alpha, \beta)$ and it will tell which direction is the steepest slope towards $0$
- Take a small step in that direction and repeat 

```r
> # loss function
> L = function(alpha, beta) data %$% sqrt(sum(alpha + beta*x - y)^2)
> # gradient
> dL_dalpha = function(alpha, beta) data %$% sum(alpha + beta*x - y)*2
> dL_dbeta = function(alpha, beta) data %$% sum((alpha + beta*x - y)*x)*2
> # starting values
> alpha = 3
> beta = 3
```


```r
> step_length = 0.1
> for (i in 1:100) {
+   # step one step length in the direction of the gradient
+   norm = sqrt(dL_dalpha(alpha, beta)^2 + 
+               dL_dbeta(alpha, beta)^2)
+   alpha = alpha - step_length*dL_dalpha(alpha, beta)/norm
+   beta = beta - step_length*dL_dbeta(alpha, beta)/norm
+ }
```



Gradient descent
===
Here we plot the trajectory of the gradient descent algorithm in the parameter space:

<img src="tidymodels-figure/unnamed-chunk-39-1.png" title="plot of chunk unnamed-chunk-39" alt="plot of chunk unnamed-chunk-39" style="display: block; margin: auto;" />

***

And the final fit:

<img src="tidymodels-figure/unnamed-chunk-40-1.png" title="plot of chunk unnamed-chunk-40" alt="plot of chunk unnamed-chunk-40" style="display: block; margin: auto;" />

- We have now have a method for doing linear regression!
  - "Linear regression" is the common name for any supervised learning method that assumes a linear model and uses squared error loss

Gradient descent
===
- Gradient descent is a widely-used algorithm to search the parameter space because it:
  - works for any loss function that you can write a gradient for, given the model
  - is relatively insensitive to the initial value
  - finds a minimum quickly without evaluating enormous numbers of parameters
- With a few minor improvements, the gradient descent algorithm can:
  - work for a problem of any dimension (here we only had 2 parameters, $\alpha$ and $\beta$)
  - get closer to the optimum by adaptively changing the step length
- If the model is more complicated, the loss function may have local minima in the parameter space
  - gradient descent may get stuck in local minima
  - however, local minima are often nearly as good as global minima
  - another minor improvement turns gradient descent into *stochastic gradient descent*, which can avoid local minima

Gradient descent powers everything from mighty neural networks down to humble linear regression! In a modified form, it also *is* gradient boosting.

Exercise: improving basic gradient descent
===
Split into three groups. Starting with our basic gradient descent setup as a template, implement the following:

**Group 1: Multivariable linear regression:**
- Write a gradient descent algorithm that uses a vector-valued gradient function. I.e. a function that returns $[\frac{\partial L}{\partial \theta_1}, \frac{\partial L}{\partial \theta_2} \dots \frac{\partial L}{\partial \theta_p}]$ instead of $p$ different functions that return each of the partial derivatives
- Use this gradient function for the RMSE:

```r
> grad_L = function(data, beta) { # beta is a p-length vector
+   x = data %>% 
+     dplyr::select(intercept, starts_with("x")) %>%
+     as.matrix()
+   c(t(c(x %*% beta) - data$y) %*% x)
+ }
```
- Test with draws from our `gen_data()` function

***

**Group 2: stochastic gradient descent and tolerance:**
- In each iteration, calculate the gradient using a randomly chosen subset of the data instead of the full dataset
  - This will require you to modify the gradient functions
- Change the outer `for` loop to a `while` loop that keeps running until the absolute change in loss from the previous iteration to the current iteration is less than `tolerance = 0.0001`

**Group 3: Adaptive step size**
- Devise a method of adapting the step size in each iteration to get closer to the true optimum
- For example: if the loss would *increase* by taking a step, don't take the step and instead decrease the step size.
- For a challenge, try to implement a *[backtracking line search](https://en.wikipedia.org/wiki/Backtracking_line_search)*

Search algorithms summary
===
- There are hundreds of optimizations and variations of gradient descent 
  - Details add complexity, but the core idea is always the same: go downhill
- Besides gradient methods, hundreds of other optimization algorithms can be used in supervised learning
  - e.g. genetic algorithms, simulated annealing, Nelder-Mead, particle swarm
  - these are useful when the parameters of the model are discrete values (no derivatives) or enter into the loss in ways that create many local minima
- There is no free lunch: all optimization methods have pros and cons
- Do not try this at home
  - Unless you are doing hardcore methods research, you should not try and write your own optimization algorithm.
  - Pick one you think will work for your model and loss and [call someone else's code](https://cran.r-project.org/web/views/Optimization.html)

Models
===
type: section

Making our model more flexible
===
- In our method we've been assuming that the DGP is: $X ~ P(X)$ (unknown and don't care) and then $Y = \alpha + \beta X$ with $\alpha$ and $\beta$ unknown. Thus $\hat f(x) = E[Y|X=x] = \alpha + \beta X$
- The toy data we used are indeed from such a DGP, so our method works.
- But if the data were generated differently, a line wouldn't fit very well:
<img src="tidymodels-figure/unnamed-chunk-42-1.png" title="plot of chunk unnamed-chunk-42" alt="plot of chunk unnamed-chunk-42" style="display: block; margin: auto;" />
- One way around this is to add more parameters to the model. For instance, what if we let our model be: $E[Y|X=x] = \alpha + \beta x + \gamma \sin(\delta x) + \theta x^2 + ...$
  - we could set this up and do gradient descent to fit all the parameters
- These are examples of *parametric models*. Each DGP in the model is identified by a fixed-length vector of parameters.
  - For instance, in the linear model, $(\alpha=0, \beta=1)$ is one DGP, $(\alpha=-10, \beta=33)$ is another.

Parametric models
===
- In a *parametric models*, each DGP in the model is identified by a fixed-length vector of $p$ parameters.
  - For instance, in the linear model, $[\alpha=0, \beta=1]$ is one DGP, $[\alpha=-10, \beta=33]$ is another.
  - You can imagine that each DGP is a point in a $p$-dimensional space
  - You can then also imagine that the space is "colored" by the loss function and that the optimization algorithm is a method for navigating the space
- The parametric model assumes that $E[Y|X]$ has a fixed functional form $f(x;\theta)$ where $\theta$ is the vector of parameters
  - The only downside of this assumption is that prediction error might be worse that it otherwise would be
  - It does not make the predictions inherently "wrong"
  
A complex parametric model
===
Parametric models can be very complicated and expressive. Consider this neural network:

<div align="center">
<img src="https://skymind.ai/images/wiki/perceptron_node.png">
</div>

<div align="center">
<img src="https://cdn-images-1.medium.com/max/1600/1*CcQPggEbLgej32mVF2lalg.png">
</div>

$\hat f(x) = g(\sum^{K_m}_k w_{m_k} g(\sum^{K_{m-1}}_k  w_{{m-1}_k} g( \dots g(\sum^{K_{1}}_k  w_{{1}_k} x_p) \dots)))$

***

- $g()$ is a fixed function, often $\frac{1}{1+e^{-x}}$
- The parameters of this model are the "weights" $w_{m_k}$
- This model has $M$ layers and $K_m$ hidden units in each layer, so the number of parameters is $\sum^m_1 K_m$ which is $K \times m$ if $K_m = K$ is a constant
- These models often have tens of thousands of parameters, all of which are fit with variants of gradient descent (combined with automatic differentiation)
- [Turns out a nested series of functions and sums like this can approximate any function](https://en.wikipedia.org/wiki/Universal_approximation_theorem)

A different kind of model
===
- Define a "distance" between any two observations $x_i$ and $x_j$, e.g. $d(x_i, x_j) = \sqrt(\sum(x_i - x_j))$
- Approximate $E[Y|X=x] = \frac{1}{K} \sum_{i \in \text{A(x)}}^K y_i$
  - $A(x)$ returns the $K$ nearest neighbors of $x$ as defined by $d(x, x_i)$

```r
> N = 100
> data = tibble(
+   x1 = rnorm(N),
+   x2 = rnorm(N),
+   y = x1 + x2^2 + rnorm(N, sd=0.1)
+ )
```


```r
> d = function(x, xi) {
+   sum((unlist(x) - unlist(xi))^2)
+ }
```

***


```r
> A = function(x, data, k) {
+   nearest_rows = data %>% 
+     dplyr::select(-y) %>%
+     transpose() %>%
+     imap_dfr(function(xi, row) {
+       tibble(row=row, dist=d(xi,x))
+     }) %>%
+     arrange(dist) %>%
+     filter(row_number() <= k) %>%
+     pull(row)
+   data %>% 
+     slice(nearest_rows)
+ }
```


```r
> knn = function(x, data, k) {
+   A(x, data, k) %>%
+     summarize(yhat=mean(y)) %>%
+     pull(yhat)
+ }
```


```r
> x = tibble(x1 = 0.5, x2 = 0.1)
> knn(x, data, 5)
[1] 0.363162
```

Exercise: KNN model and parameters
===
- This is a famous algorithm called *K-nearest neighbors* (KNN)
- Does KNN have parameters? 
- What is the model space? I.e. what kinds of functions can be modeled with KNN?

Answer: KNN model and parameters
===
- KNN does not have parameters. It requires *all of the training data* at prediction time to make a prediction
  - parametric models can be boiled down to a finite number of parameters
  - KNN has as many "parameters" as there are training data points, which can vary in number
- The model space of KNN is distributions with conditional means that are constant over Voroni tesselations

<div align="center">
<img src="http://mathworld.wolfram.com/images/eps-gif/VoronoiDiagramPlots_800.gif", height=400, width=1100>
</div>


<!-- Requires different optimization -->
<!-- === -->

<!-- Loss -->
<!-- === -->
<!-- type: section -->

<!-- Robustness -->
<!-- === -->

<!-- Regularization -->
<!-- === -->
