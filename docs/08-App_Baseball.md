---
output:
  html_document:
    df_print: paged
  pdf_document: default
  word_document: default
---
# Baseball Benchmarking Applications

## Introduction

Now that we have covered an introduction to benchmarking using data envelopment analysis, let's look at a variety of models applied to sports - in particular, baseball.  

Sports has a long history in operatons research and management science, long before the idea of sports analytics was popularized by Michael Lewis' *Moneyball*.  While it doesn't have the life and death significance of emergency relief or health care applications, it provides quite a few benefits:

* Accurate and well curated historical data
* Easy to understand models
* Opportuntities to validate results
* Clear, quantifiable, and objective metrics
* Input-output models can be agreed upon

The range of applications can cover benchmarking individual players, managers, general managers, and teams.  Analyzing individual players is the most common type of baseball application and will be the bulk of this chapter. Each baseball player typically plays a role as a batter, a fielder, and/or a pitcher. We will focus on batting for this first section.

## Baseball Data, R, and dplyr

For the sake of readers unfamiliar with baseball, we will provide a brief introduction. If you want to think of a baseball batter as a simple factory that uses Plate Appearances as a resource to produce five different kinds of products.  The following discussion gives more context for baseball fans.  

Batting is in many ways the simplest to examine. In the abstract, a batter uses their at-bats or plate appearances as opportunities to create events that help create runs for their team. In each game, a batter typically has four to six at-bats. These at-bats may be framed as a contest between a pitcher trying to make the batter create an out and the batter trying to get a hit. Hits include singles, doubles, triples, and home runs, in increasing order of value. A fifth common outcome is a walk or "base-on-balls" which occurs when the pitcher throws four balls that gives the batter a free pass to first base. There is a common expression that "a walk is as good as a hit" but a walk may not give as much advancement to other runners as a single so it may be considered as slightly less valuable than a single.

In the past, batters weren't given much "recognition" for walks and a batter's receiving a walk did not count as an at-bat. Plate appearances count the opportunities for creating a hit or a walk and is sum of at-bats and walks. 

There are a variety of less frequent outcomes of a plate appearance such as a sacrifice fly, an error, or hit by pitch. These are all less common and often an accidental outcome from the batters perspective.  

Over the course of the current 162 game season, most full-time players will have over 500 plate appearances.  


```r
library("Lahman", quietly = TRUE)
```

```
## Warning: package 'Lahman' was built under R version 4.0.3
```

```r
library("dplyr", quietly = TRUE)
library("pander", quietly = TRUE)
library(DiagrammeRsvg, quietly = TRUE)
library(rsvg, quietly = TRUE)
library(htmltools, quietly = TRUE)
source("Helperfiles.R")

# knitr::read_chunk('Helperfiles.R') <<poscolfunct>> This reads in a chunk that
# defines the poscol function This function will filter out columns that are zero
# More precisely, it factors out column with column sums that are zero.  This is
# helpful for tables of lambda values in DEA.
source("Helperfiles.R")
# knitr::read_chunk('Helperfiles.R') <<DrawIOdiagramfunction>>
```

Our exploration will also serve as a review of data manipulation in R. There are many ways of doing this. Feel free to explore further.

As usual, we want to see get familiar with the data. Let's look at the first few rows of the batting data. We are going to want to make a model of baseball batting. A good model is that a batter uses plate appearances to produce singles, doubles, triple, home runs, and walks.  Baseball fans might think of other outcomes such as sacrifice flies but these are generally less common, less desireable, and often not even intentional. These five outcomes constitute a model that fits well enough. The following figure shows what we will want to construct for a model.


```r
XFigNames <- "PA (Plate Appearances)"
YFigNames <- c("BB (Base on Balls or Walks)", "1B (Singles)", "2B (Doubles)", "3B (Triples)", 
    "HR (Home Runs)")
Figure <- DrawIOdiagram(XFigNames, YFigNames, "\"\n\nBatter\n\n \"")

tmp <- capture.output(rsvg_png(charToRaw(export_svg(Figure)), "BaseballBatting.png"))
```

![Model of Baseball Batting](BaseballBatting.png){#fig:BaseballBatting}

Now, let's wrestle with data sources. Sean Lahman's baseball database has been made available as an R package. This is a wonderful resource. http://seanlahman.com/

Now we need to work on getting the data for different players.


```r
pander(head(Lahman::Batting), caption = "Sample of Lahman Baseball Data")
```


-----------------------------------------------------------------------------
 playerID    yearID   stint   teamID   lgID   G    AB    R    H    X2B   X3B 
----------- -------- ------- -------- ------ ---- ----- ---- ---- ----- -----
 abercda01    1871      1      TRO      NA    1     4    0    0     0     0  

 addybo01     1871      1      RC1      NA    25   118   30   32    6     0  

 allisar01    1871      1      CL1      NA    29   137   28   40    4     5  

 allisdo01    1871      1      WS3      NA    27   133   28   44   10     2  

 ansonca01    1871      1      RC1      NA    25   120   29   39   11     3  

 armstbo01    1871      1      FW1      NA    12   49    9    11    2     1  
-----------------------------------------------------------------------------

Table: Sample of Lahman Baseball Data (continued below)

 
-----------------------------------------------------------
 HR   RBI   SB   CS   BB   SO   IBB   HBP   SH   SF   GIDP 
---- ----- ---- ---- ---- ---- ----- ----- ---- ---- ------
 0     0    0    0    0    0    NA    NA    NA   NA    0   

 0    13    8    1    4    0    NA    NA    NA   NA    0   

 0    19    3    1    2    5    NA    NA    NA   NA    1   

 2    27    1    1    0    2    NA    NA    NA   NA    0   

 0    16    6    2    2    1    NA    NA    NA   NA    0   

 0     5    0    1    0    1    NA    NA    NA   NA    0   
-----------------------------------------------------------

What does this all mean? The first column, playerID, is a uniquely coded ID for each player consisting of the first six letters of the last name, first two letters of the first name, and which instance of that eight letter combination the player is. For example, row 5 is ansonca01, which corresponds to the  Hall of Famer, Cap Anson. Each row gives the statistics for a year that he had with a particular team. If the player plays for multiple teams in a year, they will have multiple rows. Also, if their career lasts more than one year, they will have more than one row.

In this case, in 1871 Cap Anson played in 25 Games, had 120 at-bats, scored 29 runs, had 39 hits, and 11 doubles, 3 triples, and no home runs. He also had 16 runs-batted-in, 6 stolen bases while being caught stealing twice. He had 2 walks (base on balls) while striking out once. Other values of intentional base on balls, hit by pitches, sacrifice hits, sacrifice flies, and grounded into double plays are not available.  

This is pretty impressive to have such detailed and specific data going back almost 150 years! 

Using the Summary command will  provide all kinds of interesting information such as that over half of the player seasons occurred after 1970, the maximum number of stints with different teams was 5 and the most player seasons were for the National League's Chicago Cubs (teamID=CHN). I'll leave this for your exploration.  

Alas, most of the columns are not needed and some of those that are listed need some transformations. Hadley Wickham has written an excellent package for wrestling with data called dplyr which we will use for preparing the dataset.  

Let's start by subbsetting the data in terms of including only the columns that we will be using.  


```r
batting <- Lahman::Batting
batting <- dplyr::select(batting, playerID, yearID, teamID, lgID, AB, H, X2B, X3B, 
    HR, BB)
pander(head(batting), caption = "Batting Data Used for Analysis")
```


---------------------------------------------------------------------
 playerID    yearID   teamID   lgID   AB    H    X2B   X3B   HR   BB 
----------- -------- -------- ------ ----- ---- ----- ----- ---- ----
 abercda01    1871     TRO      NA     4    0     0     0    0    0  

 addybo01     1871     RC1      NA    118   32    6     0    0    4  

 allisar01    1871     CL1      NA    137   40    4     5    0    2  

 allisdo01    1871     WS3      NA    133   44   10     2    2    0  

 ansonca01    1871     RC1      NA    120   39   11     3    0    2  

 armstbo01    1871     FW1      NA    49    11    2     1    0    0  
---------------------------------------------------------------------

Table: Batting Data Used for Analysis

Through the 2015 season, this dataset has 101,332 rows or player seasons.  The game of baseball went through a lot of change in teams, rules, and other development and so it may be more useful to focus our attention on the after 1900. We've got plenty of data, let's filter the rows to only to only include years after 1900.  

For the sake of our analysis, we will want to filter the data to only include years after 1900.


```r
batting <- dplyr::filter(batting, yearID > 1900)
pander(head(batting), caption = "Batting Statistics for Players after 1901")
```


----------------------------------------------------------------------
 playerID    yearID   teamID   lgID   AB     H    X2B   X3B   HR   BB 
----------- -------- -------- ------ ----- ----- ----- ----- ---- ----
 anderjo01    1901     MLA      AL    576   190   46     7    8    24 

 bakerbo01    1901     CLE      AL     4     0     0     0    0    0  

 bakerbo01    1901     PHA      AL     3     1     0     0    0    0  

 barreji01    1901     DET      AL    542   159   16     9    4    76 

 barrysh01    1901     BSN      NL    40     7     2     0    0    2  

 barrysh01    1901     PHI      NL    252   62    10     0    1    15 
----------------------------------------------------------------------

Table: Batting Statistics for Players after 1901

As we discussed earlier, At-Bats (AB) is good but let's convert that to plat appearances. Also, let's get the number of singles.


```r
batting <- dplyr::mutate(batting, X1B = H - HR - X3B - X2B)
batting <- dplyr::mutate(batting, PA = AB + BB)
pander(head(batting), caption = "Calculate Singles and Plate Appearances")
```


----------------------------------------------------------------------------------
 playerID    yearID   teamID   lgID   AB     H    X2B   X3B   HR   BB   X1B   PA  
----------- -------- -------- ------ ----- ----- ----- ----- ---- ---- ----- -----
 anderjo01    1901     MLA      AL    576   190   46     7    8    24   129   600 

 bakerbo01    1901     CLE      AL     4     0     0     0    0    0     0     4  

 bakerbo01    1901     PHA      AL     3     1     0     0    0    0     1     3  

 barreji01    1901     DET      AL    542   159   16     9    4    76   130   618 

 barrysh01    1901     BSN      NL    40     7     2     0    0    2     5    42  

 barrysh01    1901     PHI      NL    252   62    10     0    1    15   51    267 
----------------------------------------------------------------------------------

Table: Calculate Singles and Plate Appearances

Lastly, now that we feel confident that our data transformation for calculating singles and plate appearances work, let's drop the old columns for hits and at-bats as well as reordering them.


```r
batting <- dplyr::select(batting, playerID, yearID, teamID, lgID, PA, BB, X1B, X2B, 
    X3B, HR)
pander(head(batting), caption = "Batting Statistics Converted into Inputs and Outputs")
```


----------------------------------------------------------------------
 playerID    yearID   teamID   lgID   PA    BB   X1B   X2B   X3B   HR 
----------- -------- -------- ------ ----- ---- ----- ----- ----- ----
 anderjo01    1901     MLA      AL    600   24   129   46     7    8  

 bakerbo01    1901     CLE      AL     4    0     0     0     0    0  

 bakerbo01    1901     PHA      AL     3    0     1     0     0    0  

 barreji01    1901     DET      AL    618   76   130   16     9    4  

 barrysh01    1901     BSN      NL    42    2     5     2     0    0  

 barrysh01    1901     PHI      NL    267   15   51    10     0    1  
----------------------------------------------------------------------

Table: Batting Statistics Converted into Inputs and Outputs

Now we will trim out player to only include those that have over '$MinPA$' plate appearances to limit the impact of part-time players or  platooning players.


```r
MinPA <- 400
batting <- dplyr::filter(batting, PA > MinPA)
pander(head(batting), caption = "Limit to Full-time Players")
```


----------------------------------------------------------------------
 playerID    yearID   teamID   lgID   PA    BB   X1B   X2B   X3B   HR 
----------- -------- -------- ------ ----- ---- ----- ----- ----- ----
 anderjo01    1901     MLA      AL    600   24   129   46     7    8  

 barreji01    1901     DET      AL    618   76   130   16     9    4  

 beaumgi01    1901     PIT      NL    602   44   158   14     5    8  

 becker01     1901     CLE      AL    562   23   116   26     8    6  

 becklja01    1901     CIN      NL    608   28   126   36    13    3  

 bradlbi01    1901     CLE      AL    542   26   109   28    13    1  
----------------------------------------------------------------------

Table: Limit to Full-time Players

Part of the beauty of dplyr is the ability to consolidate all of this into a single function.


```r
batting <- Lahman::Batting

batting <- batting %>% select(playerID, yearID, teamID, lgID, AB, H, X2B, X3B, HR, 
    BB) %>% mutate(PA = as.numeric(AB + BB)) %>% mutate(X1B = as.numeric(H - HR - 
    X3B - X2B)) %>% transform(BB = as.numeric(BB)) %>% transform(X2B = as.numeric(X2B)) %>% 
    transform(X3B = as.numeric(X3B)) %>% transform(HR = as.numeric(HR)) %>% 
filter(yearID > 1900, PA > MinPA) %>% select(playerID, yearID, teamID, lgID, PA, 
    BB, X1B, X2B, X3B, HR)

pander(head(batting), caption = "Results of Preparing Data using dplyr")
```


----------------------------------------------------------------------
 playerID    yearID   teamID   lgID   PA    BB   X1B   X2B   X3B   HR 
----------- -------- -------- ------ ----- ---- ----- ----- ----- ----
 anderjo01    1901     MLA      AL    600   24   129   46     7    8  

 barreji01    1901     DET      AL    618   76   130   16     9    4  

 beaumgi01    1901     PIT      NL    602   44   158   14     5    8  

 becker01     1901     CLE      AL    562   23   116   26     8    6  

 becklja01    1901     CIN      NL    608   28   126   36    13    3  

 bradlbi01    1901     CLE      AL    542   26   109   28    13    1  
----------------------------------------------------------------------

Table: Results of Preparing Data using dplyr

Now that we have data prepared along with the tools for further manipulation, we are ready to proceed onto the analysis.

## Benchmarking Baseball Batters

Our basic input-output model for baseball batting consists of plate appearances as the sole input and the five most common results of types of hits along with walks. 

In 1920, the American League featured a batter so dominant that he transformed the "industry" of baseball. Let's focus on this year for now. The core model for analysis is described in the following figure. We are going to use an output-oriented, constant returns to scale model. The following figures illustrates the DEA model that we will be using.  

t we will want to construct for a model.


```r
XFigNames <- "PA (Plate Appearances)"
YFigNames <- c("BB (Base on Balls or Walks)", "1B (Singles)", "2B (Doubles)", "3B (Triples)", 
    "HR (Home Runs)")
ModelName <- "\"\n\nCCR\nIO\n\n \""
Figure <- DrawIOdiagram(XFigNames, YFigNames, ModelName)

tmp <- capture.output(rsvg_png(charToRaw(export_svg(Figure)), "BaseballCCRIO.png"))
```

![Basic DEA Model of Baseball Batting](BaseballCCRIO.png){#fig:BaseballCCRIO}


```r
inputs <- c("PA")
outputs <- c("BB", "X1B", "X2B", "X3B", "HR")
batting1920AL <- batting %>% filter(yearID == 1920, lgID == "AL")

x <- batting1920AL %>% select(PA)
row.names(x) <- batting1920AL[, 1]
pander(head(x), caption = "Inputs for the 1920AL")
```


---------------------
    &nbsp;       PA  
--------------- -----
 **bodiepi01**   511 

 **bushdo01**    579 

 **chapmra01**   487 

 **cobbty01**    486 

 **collied01**   671 

 **collish01**   518 
---------------------

Table: Inputs for the 1920AL

```r
y <- batting1920AL %>% select(BB, X1B, X2B, X3B, HR)
row.names(y) <- batting1920AL[, 1]
pander(head(y), caption = "Outputs for the 1920AL")
```


-------------------------------------------
    &nbsp;       BB   X1B   X2B   X3B   HR 
--------------- ---- ----- ----- ----- ----
 **bodiepi01**   40   94    26    12    7  

 **bushdo01**    73   109   18     5    1  

 **chapmra01**   52   94    27     8    3  

 **cobbty01**    58   105   28     8    2  

 **collied01**   69   170   38    13    3  

 **collish01**   23   118   21    10    1  
-------------------------------------------

Table: Outputs for the 1920AL


```r
library(TFDEA, quietly = TRUE)

res1920AL <- DEA(x, y, rts = "CRS", orientation = "output", slack = TRUE, dual = TRUE)
```

```
## Warning, data has DMU's with outputs that are zero, this may cause numerical problems
```

```r
phi <- res1920AL$eff
theta <- 1/phi

pander(cbind(head(phi), head(theta)), caption = "CCR-OO Scores for 1920AL (Phi and Theta)")
```


--------------- ------- --------
 **bodiepi01**   1.252   0.7988 

 **bushdo01**    1.186   0.843  

 **chapmra01**   1.204   0.8308 

 **cobbty01**    1.091   0.9165 

 **collied01**     1       1    

 **collish01**   1.115   0.8966 
--------------- ------- --------

Table: CCR-OO Scores for 1920AL (Phi and Theta)

Success. We have now run DEA using the TFDEA package, principally developed by Tom Shott with important contributions from Dong-Joon Lim, Kevin van Blommestein, and others. Notice that this is an output-oriented model so the values greater than 1.0 indicate that decreasing radial efficiency (increasing inefficiency), and describe the amount of additional outputs that should be acheived at the same level of input usage. In other words, how much more walks, singles, doubles, triples, and home runs the player should be producing in the same number of plate appearances if he was batting _efficiently_. As discussed in the chapter on the output-oriented model, under constant returns to scale, the input and output-oriented models are reciprocals of each other ($\theta=\frac{1}{\phi}$)

Let's dig a little deeper now. Let's start by reviewing the output weights for the first few players. We'll display the table in two ways.  


```r
pander(head(res1920AL$uy), round = 6, caption = "Output Weights for 1920 AL")
```


----------------------------------------------------------------------
    &nbsp;          BB        X1B        X2B        X3B         HR    
--------------- ---------- ---------- ---------- ---------- ----------
 **bodiepi01**   0.004816   0.006478      0       0.01595    0.001019 

 **bushdo01**    0.005676   0.005373      0          0          0     

 **chapmra01**   0.004896   0.006421   0.000242   0.01691       0     

 **cobbty01**    0.004547   0.005889      0       0.01474       0     

 **collied01**   0.000397   0.005721      0          0          0     

 **collish01**      0       0.008269      0       0.002431      0     
----------------------------------------------------------------------

Table: Output Weights for 1920 AL

A few things stand out. First, only one of the first six players puts any weight on home runs. There should be a heirarchy that singles are at least as good as walks, doubles are at least as good singles, triples are at least as good as doubles, and home runs are at least as good triples. Every player violates at least one of these relationships. Any plausible analysis of baseball batting needs to reflect these relationships. While very different, common metrics such as batting average and slugging average satisfy these relationships but our first DEA model does not.

In Anderson and Sharpe's 1997 paper, ordinal weight restrictions were incorporated into the envelopment model for examining baseball batters by accumulating hits.  This created new outputs of Singles or better (BB+X1B), doubles or better (BB+X1B+X2B), _etc._

Another approach is to analyze the data set using the multiplier model and directly incorporating weight restrictions. For this, we will make use of the DEAMultiplier package written by Aurobindh Kalathil Puthanpura.  


```r
library(MultiplierDEA)

res1920ALmult <- DeaMultiplierModel(x, y, rts = "crs", orientation = "output")
```

```
## Warning, data has DMU's with outputs that are zero, this may cause
##       numerical problems
```

```r
pander(head(res1920ALmult$Efficiency), caption = "DEA Output Weights")
```


------------------------
    &nbsp;        Eff   
--------------- --------
 **bodiepi01**   0.7988 

 **bushdo01**    0.843  

 **chapmra01**   0.8308 

 **cobbty01**    0.9165 

 **collied01**     1    

 **collish01**   0.8966 
------------------------

Table: DEA Output Weights

Notice that the scores are up to 1.0 rather than 1.0 and higher as in the TFDEA package.  This is because the TFDEA package reports efficiency as $\phi$ whereas the DEAMultiplier package reports $\frac{1}{\phi}$.  The results are consistent and reciprocals.  The value of $\phi$ is consistent with the formulation of the output-oriented model.  The value of $\frac{1}{\phi}$ has the same interpretation $\theta$ where a value less than 1.0 indicates inefficiency.  In fact, for the case of constant returns to scale (CRS), the orientation does not make a difference in the value of inefficiency found, in other words, $\theta=\frac{1}{\phi}$  For the sake of this discussion, we will interpret the results as $\frac{1}{\phi}$.

Now, let's look at the results.  


```r
library(ggplot2)

qplot(res1920ALmult$Efficiency, geom = "dotplot", main = "1920 American League Batter Efficiency", 
    xlab = "Efficiency Score", fill = I("blue"))
```

```
## `stat_bindot()` using `bins = 30`. Pick better value with `binwidth`.
```


\includegraphics{08-App_Baseball_files/figure-latex/unnamed-chunk-4-1} 

Next, let's review the output weights.  


```r
pander(head(res1920ALmult$uy), round = 6, caption = "Output Weights from Multiplier Model")
```


----------------------------------------------------------------------
    &nbsp;          BB        X1B        X2B        X3B         HR    
--------------- ---------- ---------- ---------- ---------- ----------
 **bodiepi01**   0.004816   0.006478      0       0.01595    0.001019 

 **bushdo01**    0.005676   0.005373      0          0          0     

 **chapmra01**   0.004896   0.006421   0.000242   0.01691       0     

 **cobbty01**    0.004547   0.005889      0       0.01474       0     

 **collied01**   0.000193   0.005687      0       0.001537      0     

 **collish01**      0       0.008269      0       0.002431      0     
----------------------------------------------------------------------

Table: Output Weights from Multiplier Model

```r
pander(head(res1920AL$uy), round = 6, caption = "Output Weights from Envelopment Model")
```


----------------------------------------------------------------------
    &nbsp;          BB        X1B        X2B        X3B         HR    
--------------- ---------- ---------- ---------- ---------- ----------
 **bodiepi01**   0.004816   0.006478      0       0.01595    0.001019 

 **bushdo01**    0.005676   0.005373      0          0          0     

 **chapmra01**   0.004896   0.006421   0.000242   0.01691       0     

 **cobbty01**    0.004547   0.005889      0       0.01474       0     

 **collied01**   0.000397   0.005721      0          0          0     

 **collish01**      0       0.008269      0       0.002431      0     
----------------------------------------------------------------------

Table: Output Weights from Envelopment Model

Again, we see that the results are similar to what was observed earlier.  Note that the results for Eddie Collins (collied01) are different. Eddie Collins was efficient and it is common that efficient players have multiple weighting schemes that still result in being efficient. The MultiplierDEA package puts weight on triples (X3B) while the TFDEA package's solution puts a zero weight on triples and distributes weight among other outputs.  

In any case, the output weights do not meet the requirements of a realistic baseball application. Let's apply weight restrictions.  

We want to enforce the following restrictions on our output weights, _u_.  

$$
 \begin{split}
 \begin{aligned}
    \ & u_{singles} \geq u_{walks}\\
    \ & u_{doubles} \geq u_{singles}\\
    \ & u_{triples} \geq u_{doubles}\\
    \ & u_{home runs} \geq u_{triples}\\
  \end{aligned}
  \end{split}
  (\#eq:BasicWeightRestrictions)
$$

A more generalized data structure for the weight restrictions looks at these as a series of ratios.  

$$
 \begin{split}
 \begin{aligned}
    \ & 1 \leq \frac{u_{singles}} {u_{walks}} \leq \infty \\
    \ & 1 \leq \frac{u_{doubles}} {u_{singles}} \leq \infty \\
    \ & 1 \leq \frac{u_{triples}} {u_{doubles}} \leq \infty \\
    \ & 1 \leq \frac{u_{home runs}} {u_{triples}} \leq \infty \\
  \end{aligned}
  \end{split}
  (\#eq:RatioWeightRestrictions)
$$

We can now specify these ratios in a data frame that will be passed to multiplierDEA package by defining a lower bound, numerator, denominator, and upper bound for each weight restriction ratio relationship. Note that rather than specifying the upper limit of infinity, we declare it as "NaN" to indicate that it is not a number.  


```r
BattingWR <- data.frame(lower = c(1, 1, 1, 1), numerator = c("X1B", "X2B", "X3B", 
    "HR"), denominator = c("BB", "X1B", "X2B", "X3B"), upper = c(NaN, NaN, NaN, NaN))

pander(BattingWR, caption = "Data Structure for Batting Weight Restrictions")
```


-----------------------------------------
 lower   numerator   denominator   upper 
------- ----------- ------------- -------
   1        X1B          BB         NA   

   1        X2B          X1B        NA   

   1        X3B          X2B        NA   

   1        HR           X3B        NA   
-----------------------------------------

Table: Data Structure for Batting Weight Restrictions

```r
res1920ALmultWR <- DeaMultiplierModel(x, y, rts = "crs", orientation = "output", 
    weightRestriction = BattingWR)
```

```
## Warning, data has DMU's with outputs that are zero, this may cause
##       numerical problems
```

Let's talk about a particular hitter, Eddie Collins.  Without weight restrictions, he was efficient.  With weight restrictions, his efficiency was 0.9350071.  In fact, the histogram of efficiency scores is more telling.  


```r
qplot(res1920ALmultWR$Efficiency, geom = "dotplot", main = "1920 American League Batter Efficiency", 
    xlab = "Efficiency Score", fill = I("blue"))
```

```
## `stat_bindot()` using `bins = 30`. Pick better value with `binwidth`.
```


\includegraphics{08-App_Baseball_files/figure-latex/unnamed-chunk-7-1} 


```r
binwidth <- 0.01
hist(res1920ALmult$Efficiency, xlim = c(0.6, 1), col = "red", breaks = seq(0.6, 1, 
    by = binwidth), main = "Impact of Weight Restrictions on Batter Efficiency", 
    xlab = "Efficiency")
hist(res1920ALmultWR$Efficiency, add = T, col = scales::alpha("blue", 0.5), border = F, 
    breaks = seq(0.6, 1, by = binwidth))
```


\includegraphics{08-App_Baseball_files/figure-latex/unnamed-chunk-8-1} 

The weight restrictions have dropped the number of efficient players from seven to two. As might be expected, Babe Ruth was efficient in both models.    

### Cross-Efficiency of Baseball Batters

Now, let's turn our attention to a variation of DEA called cross-efficiency. Cross-efficiency was discussed in an earlier chapter. Proponents of Cross-efficiency contend that it can differentiate between players DMUs that are DEA efficient.  Simple CCR DEA finds nine out of 54 players to be efficient. We will focus on the ten players with the top CCR efficiency scores.  


```r
res1920ALcross<-CrossEfficiency(x,y,rts = "crs", orientation="output")
```

```
## Warning, data has DMU's with outputs that are zero, this may cause
##       numerical problems
```

```r
res1920ALCEWR<-CrossEfficiency(x,y,rts = "crs", orientation="output", 
                                   weightRestriction = BattingWR)
```

```
## Warning, data has DMU's with outputs that are zero, this may cause
##       numerical problems
```

```r
pander(head (t(res1920ALcross$ce_ave)), round=4,
       caption="Cross-efficiency scores for 1920AL")
```


-------------------------
    &nbsp;       Average 
--------------- ---------
 **bodiepi01**   0.7388  

 **bushdo01**     0.708  

 **chapmra01**   0.7775  

 **cobbty01**    0.8539  

 **collied01**   0.9415  

 **collish01**   0.7813  
-------------------------

Table: Cross-efficiency scores for 1920AL

```r
pander(head (res1920ALmult$Efficiency), round=4,
       caption="CCR Efficiency Scores")
```


------------------------
    &nbsp;        Eff   
--------------- --------
 **bodiepi01**   0.7988 

 **bushdo01**    0.843  

 **chapmra01**   0.8308 

 **cobbty01**    0.9165 

 **collied01**     1    

 **collish01**   0.8966 
------------------------

Table: CCR Efficiency Scores

```r
pander(head (t(res1920ALcross$ceva_max)), round=4,
       caption="Maximum Cross-Evaluation Score for Each Player")
```


------------------------
    &nbsp;        Max   
--------------- --------
 **bodiepi01**   0.7988 

 **bushdo01**    0.843  

 **chapmra01**   0.8308 

 **cobbty01**    0.9165 

 **collied01**     1    

 **collish01**   0.8966 
------------------------

Table: Maximum Cross-Evaluation Score for Each Player

```r
collectedeff1 <- data.frame(cbind(res1920ALmult$Efficiency,
                                  res1920ALmultWR$Efficiency,
                                  t(res1920ALcross$ce_ave),
                                  t(res1920ALCEWR$ce_ave))) 

colnames(collectedeff1)<-c("CCRIO", "CCRIOWR", "CE", "CEWR")

pander(head(collectedeff1 
           [order(collectedeff1[,1], decreasing = TRUE),
             1:4], # Display first four columns
          10), # Display top 10 rows
       round=4, caption="1920 AL Top Ten CCR Input-Oriented Efficient Players"
       )
```


----------------------------------------------------
    &nbsp;       CCRIO    CCRIOWR     CE      CEWR  
--------------- -------- --------- -------- --------
 **jacksjo01**     1      0.9524    0.9311   0.9299 

 **speaktr01**     1      0.9854    0.9496   0.9388 

 **sislege01**     1         1      0.9698   0.9873 

 **hoopeha01**     1      0.8252    0.796    0.7813 

 **ricesa01**      1      0.8408    0.8627   0.8106 

 **ruthba01**      1         1      0.766    0.9671 

 **collied01**     1       0.935    0.9415   0.8939 

 **meusebo01**     1      0.8865    0.7782   0.8083 

 **judgejo01**     1      0.8567    0.8521   0.8132 

 **duganjo01**   0.9932   0.8161    0.7999   0.7798 
----------------------------------------------------

Table: 1920 AL Top Ten CCR Input-Oriented Efficient Players

Baseball fans may recognize some of the names:  

* "Shoeless" Joe Jackson (jacksjo01) was a Hall of Fame caliber player but his career was cut short in 1920 after having one of his best seasons after being embroiled in a World Series scandal.
* Tris Speaker (speaktr01) and Eddie Collins (collied01) were not just Hall of Famer but often considered among the very best players of all time.  Despite this, neither of them are well known a century after they started playing by non-baseball fans - their biggest problem was that there were a few colleagues whose stars shown even brighter.
* George Sisler (sislege01), was a Hall of Famer but not generally considered to be at the level of Speaker and Collins except for a brief peak of 1920 and 1922.   
* Harry Hooper (hoopeha01) and Sam Rice (ricesa01) were star players and made the Hall of Fame but was a big step below Speaker and Collins.
* George Herman "Babe" Ruth (ruthba01) has already been discussed at length. 
* Eddie Collins, like Tris Speaker, was among the very best players of all time.
* Bob Meusel (meusebo01), Joe Judge (judgejo01), and Joe Dugan (duganjo01) had good careers but are never thought of as all-time greats.


```r
pander(cor(collectedeff1[, 1:4]), round = 4, caption = "Correlation of DEA Models for the 1920 AL")
```


--------------------------------------------------
   &nbsp;      CCRIO    CCRIOWR     CE      CEWR  
------------- -------- --------- -------- --------
  **CCRIO**      1      0.8885    0.8696   0.858  

 **CCRIOWR**   0.8885      1      0.9102   0.9923 

   **CE**      0.8696   0.9102      1      0.9071 

  **CEWR**     0.858    0.9923    0.9071     1    
--------------------------------------------------

Table: Correlation of DEA Models for the 1920 AL

```r
collectedeff1$name <- row.names(collectedeff1)
# Add column for player names to make labels in ggplot
colnames(res1920ALmult$Efficiency) <- "Efficiency"
colnames(res1920ALmultWR$Efficiency) <- "Efficiency w WR"
# rownames(res1920ALcross$ce_ave)<-'Cross-Efficiency'

pander(cor(cbind(res1920ALmult$Efficiency, t(res1920ALcross$ce_ave), res1920ALmultWR$Efficiency)), 
    round = 4, caption = "Correlation of DEA Models for the 1920 AL")
```


--------------------------------------------------------------
       &nbsp;          Efficiency   Average   Efficiency w WR 
--------------------- ------------ --------- -----------------
   **Efficiency**          1        0.8696        0.8885      

     **Average**         0.8696        1          0.9102      

 **Efficiency w WR**     0.8885     0.9102           1        
--------------------------------------------------------------

Table: Correlation of DEA Models for the 1920 AL

The cross-efficiency and the regular efficiency scores are related - they have a correlation of 0.870 but the cross-efficiency has a 0.910 correlation with the weight restricted DEA results.  This suggests that perhaps cross-efficiency can help deal with decreasing the impact of unrealistic weight schemes but let's take a closer look at the results.

First, let's examine one hitter in particular. In 1920, Babe Ruth had one of the best seasons ever by a baseball hitter. Various statistics demonstrate his dominance but home runs really highlight the impact. His 54 home runs nearly doubled the previous record of 29 in a season he had set the previous year. Alone, he hit more home runs than 14 of the 16 teams in the leagues. Until the recent steroid era, Babe Ruth's 1920 and 1921 seasons are generally considered to be the two best offensive seasons in baseball.  

Babe's cross-efficiency score was 0.765966. Coincidentally, his cross-efficiency score was nearly identical to the average cross-efficiency of other regular baseball batters of 0.765954. In other words, what may have been one of the best batting performances in a century of baseball was wrongly misclassified as being just average by cross-efficiency.

The reason for this can be seen by the cross-efficiency matrix of weights. 


```r
ggplot(collectedeff1, aes(x = CCRIO, y = CCRIOWR)) + xlab("CCR-IO Efficiency") + 
    ylab("CCR-IO Efficiency with Weight Restrictions") + ggtitle("Impact of Weight Restrictions on 1920 AL CC Efficiency") + 
    geom_point(shape = 1) + geom_abline(slope = 1, color = "red") + geom_text(data = subset(collectedeff1, 
    CCRIO > 0.999), nudge_x = 0.03, aes(CCRIO, CCRIOWR, label = name))
```


\includegraphics{08-App_Baseball_files/figure-latex/unnamed-chunk-11-1} 

This chart of efficiency vs. efficiency with weight restrictions clearly shows that no one has their efficiency improved by the imposition of weight resctrictions. In fact, only two players have the same score in both models: sislege01 (George Sisler) and ruthba01 (Babe Ruth). Both Sisler and Ruth are efficient in both models.  


```r
ggplot(collectedeff1, aes(x = CCRIO, y = CE)) + xlab("CCR-IO Efficiency") + ylab("Cross-Efficiency") + 
    ggtitle("Cross-Efficiency vs. CCR-IO Efficiency for 1920 AL") + geom_point(shape = 1) + 
    geom_abline(slope = 1, color = "red") + geom_text(data = subset(collectedeff1, 
    CCRIO > 0.999), nudge_x = 0.03, aes(CCRIO, CE, label = name))
```


\includegraphics{08-App_Baseball_files/figure-latex/unnamed-chunk-12-1} 

Now, let's move on to examine the story of cross-efficiency vs. regular CCR Input-Oriented Efficiency. This chart makes it clear that while they are correlated, the nine players that were originally deemed CCR-IO Efficient are treated quite differently by cross-efficiency. George Sisler is rated highest but is closely followed by Tris Speaker, Eddie Collins, and "Shoeless" Joe Jackson. These four are clearly separated from all of the other players. The next two formerly efficient players, Sam Rice and Joe Judge, still receive cross-efficiency scores over 0.85 but are now even surpassed by one CCR-IO inefficient player.  

This brings us to the last three of the formerly efficient players:  Harry Hooper, Bob Meusel, and Babe Ruth.  All three of these players are outscored in cross-efficiency by many other players.  Their cross-efficiency scores are all approximately the leage average.  All of this despite the fact that as discussed earlier, Babe Ruth was not just inarguably the _best_ batter in 1920 but arguably the best of the century.  


```r
ggplot(collectedeff1, aes(x = CE, y = CEWR)) + xlab("Cross-Efficiency") + ylab("Cross-Efficiency with Weight Restrictions") + 
    ggtitle("Impact of Weight Restrictions on 1920 AL Cross-Efficiency") + geom_point(shape = 1) + 
    geom_abline(slope = 1, color = "red") + geom_text(data = subset(collectedeff1, 
    CEWR > 0.85), nudge_x = -0.03, aes(CE, CEWR, label = name))
```


\includegraphics{08-App_Baseball_files/figure-latex/unnamed-chunk-13-1} 

While cross-efficiency is sometimes used as a crutch to improve discrimination without needing to use application area-expertise, weight restrictions can be used just as readily in cross-efficiency as in regular DEA studies.  This chart highlights shows that unlike regular DEA, adding weight restrictions helps some players' scores and hurts others'.  The biggest beneficiary of weight restrictions is Babe Ruth.  While his weight-restricted cross-efficiency score still trails George Sisler by a small margin, he is no longer considered a mere "average" batter.

Most DEA applications do not have the benefit of a historically trancendent performance such as that of Babe Ruth to highlight a modeling error of using cross-efficiency to easily improve discrimination among DMUs. Cross-efficiency sacrifices DEA's conservative or generous assumption of weight flexibility to opaquely create an alternate scoring model. While it does typically create a unique ranking of all of the DMUs, this does not necessarily make it valid.

This analysis demonstrates that cross-efficiency is not a substitute for the hard work of good modeling.  

### Cross-Efficiency and Fixed Weights

Babe Ruth's scores showed high variability across the different analysis.  Let's explore this in more detail by digging into the actual weights from the multiplier model used.  

The cross-efficiency score for a player, say Babe Ruth, is computed by averaging each cross-evaluation score which is the score that each of the players implicitly give Babe Ruth using their own preferred weighting scheme.

The result is that the only way that Babe Ruth could get a cross-efficiency score of 1.0 would be for every player to say that based on their own weighting scheme, they find that Babe Ruth was efficient.  

Let's look at the calculations for Babe Ruth using his own weighting scheme.  


```r
ybabe <- y["ruthba01", ]
uybabe <- as.data.frame(t(res1920ALcross$uy["ruthba01", ]))
xbabe <- x["ruthba01", ]
vxbabe <- as.data.frame(t(res1920ALcross$vx["ruthba01", ]))
rownames(uybabe) <- "output weights"
pander(rbind(ybabe, uybabe), caption = "Ruth's Outputs and Ruth's Cross-Efficiency Output Weights")
```


---------------------------------------------------------------
       &nbsp;            BB      X1B    X2B     X3B      HR    
-------------------- ---------- ----- -------- ----- ----------
    **ruthba01**        150      73      36      9       54    

 **output weights**   0.001326    0    0.0184    0    0.002568 
---------------------------------------------------------------

Table: Ruth's Outputs and Ruth's Cross-Efficiency Output Weights

Now, we can multiply each output by the corresponding output weight and then add these products together. The result is 1. The input weight for Babe was 0.00164744645799012 while his input (Plate Appearances) was 607. Simply multiplying them together gives us  1. The final result is taking the weighted output divided by the weighted output which gives us 1.  Not surprisingly, Babe Ruth's cross-evaluation score based on his own weights is the same as his CCR output-oriented efficiency score. In this case, simply 1.0.

Now, let's go through the process of seeing the calculation of Babe Ruth's cross-evaluation score using the weights of George Sisler.  



```r
uysisl <- as.data.frame(t(res1920ALcross$uy["sislege01", ]))
vxsisl <- as.data.frame(t(res1920ALcross$vx["sislege01", ]))
rownames(uysisl) <- "output weights"
pander(rbind(ybabe, uysisl), caption = "Ruth's Outputs and Sisler's Cross-Efficiency Output Weights")
```


-------------------------------------------------------------
       &nbsp;         BB      X1B      X2B   X3B      HR     
-------------------- ----- ---------- ----- ----- -----------
    **ruthba01**      150      73      36     9       54     

 **output weights**    0    0.005744    0     0    0.0009335 
-------------------------------------------------------------

Table: Ruth's Outputs and Sisler's Cross-Efficiency Output Weights

Now, we again multiply each output by the corresponding output weight and then add these products together. The result is 0.4697357.The input weight for Sisler was 0.00147710487444609 while Babe's input (Plate Appearances) was 607. Simply multiplying them together gives us  0.8966027  The final result is taking the weighted output divided by the weighted output which gives us 0.5239062. Babe Ruth's cross-evaluation score based on George Sisler's weights results in a much lower score than his own score.  

Both George Sisler's and Babe Ruth's output weights violate the pattern of increasing (or more precisely, non-decreasing) values as you move to the right. In the case of Babe Ruth's efficiency score, it does not hurt him to have this unrealistic scheme because he gave himself a _1.0_. On the other hand, in cross-efficiency, this unrealistic weighting scheme used by George Sisler _hurt_ the final cross-efficiency score of Babe Ruth.  

In fact, a paper by Anderson, Inman, and Hollingsworth found that under certain circumstances, cross-efficiency is effectively a fixed weighting scheme that may assess everyone under the same possibly incorrect weighting scheme. The authors show that in a single-input, output-oriented model or single output, input-oriented model, the cross-efficiency calculations, cross-efficiency just relies on an average of the weights.  

The cross-efficiency mean output weights can be expressed as the following:

$$
\begin{split}
\begin{aligned}
    u_r^{CE} = \frac{1} {N^D} \sum_{j=1}^{N^D} \frac {u_{r,j}} {v_{1,j}}  \\
    \\
    v_1^{CE} = 1 \\
    \end{aligned}
\end{split}
(\#eq:CEFixedWeights)
$$

Let's repeat this exercise one more time based on the mean output and mean input weights for all 54 players in the 1920 American League.



```r
vxmeantemp <- matrix(rep(res1920ALcross$vx, each = 5), ncol = 5, byrow = TRUE)
# Expand vx from one column to as many columns as uy (5)
uymeantemp <- res1920ALcross$uy/vxmeantemp
# Now it is easy to do term by term division of the two matrices
uymean <- as.data.frame(t(colMeans(uymeantemp)))
# Mean cross-efficiency output weights are now just the column means
vxmean <- 1
# Mean cross-efficiency input weight is just unity.  Equivalently, could output
# weights using column sums and input weight of ND

rownames(uymean) <- "output weights"
pander(rbind(ybabe, uymean), caption = "Ruth's Outputs and Mean Cross-Efficiency Output Weights")
```


--------------------------------------------------------------
       &nbsp;           BB      X1B     X2B     X3B      HR   
-------------------- -------- ------- ------- ------- --------
    **ruthba01**       150      73      36       9       54   

 **output weights**   0.9796   2.619   2.154   2.752   0.4544 
--------------------------------------------------------------

Table: Ruth's Outputs and Mean Cross-Efficiency Output Weights

Once again we multiply each output by the corresponding output weight and then add these products together. The result is 464.9413282. The mean input weight was 1 while his input (Plate Appearances) was 607. Simply multiplying them together gives us 607. The final result is taking the weighted output divided by the weighted output which gives us 0.7659659. Babe Ruth's cross-evaluation score based on the league-wide mean weights results in a higher score score than what Sisler gave him but far below his own efficiency score.

Note, this calculated value matches the original cross-efficiency score for Babe Ruth of `r res1920ALcross$ce_ave["ruthba01",] calculated as simply the column average of the cross-evaluation matrix.

The same mean cross-efficiency weights can be used for calculating the cross-efficiency score for each of the other players. This is not a matter of some (or most) players occassionally violating the relationship in some way but a systematic error. What this means is that _every_ player is now being assessed against the same fixed and in this case, implausible weighting scheme. If you look carefully at the mean output weights, the mean weight for Home Runs is just half that of the next lowest output weight (base on balls).   Singles, doubles, and triples are all given four or fives times as much weight as home runs.     

The low weighting of home runs is in effect caused by a _ganging up_ phenomenon where most players do poorly on Home Runs relative to Babe Ruth so they choose to not put weight on that output. On the whole, the league then does not on average puts a low weight on Home Runs. Furthermore, outputs that tend to have low values (such as triples) will tend to have higher output weights than those with higher values such as home runs. Rightly or wrongly, these distributional characteristics of the data set will affect cross-efficiency scores.

Most studies that do cross-efficiency do not take a careful look at the weights.  

## Baseball Team Management

Examining baseball batters is interesting but let's change our perspective the team.  A baseball general manager tries to construct the best team.  Players have different salaries and the Lahman baseball dataset includes salary information.  An interesting statistical analysis of the relationship between team salary and wins can be found at https://rpubs.com/grigory/MLBSalaryPerfLR by Gregory Kanevsky.  Instead of a regression model, we will use a benchmarking approach.

We will draw inspiration from Gregory Kanevsky's analysis and data wrestling to get us started.


```r
library(data.table, quietly=TRUE)
```

```
## Warning: package 'data.table' was built under R version 4.0.3
```

```
## 
## Attaching package: 'data.table'
```

```
## The following objects are masked from 'package:dplyr':
## 
##     between, first, last
```

```r
teams = as.data.table(Teams)
teams = teams[, .(yearID, 
                  lgID = as.character(lgID), 
                  teamID = as.character(teamID), 
                  franchID = as.character(franchID),
                  Rank, G, W, L, R, ERA, SO, 
                  PostW = 4*(LgWin=="Y")+4*(WSWin=="Y"),
                        # Construct Post Season wins based on games to win a series
                        # Would prefer to get actual postseason games won
                  WinPercent = W/(W+L),
                  name, attendance
                  )]
  
salaries = as.data.table(Salaries)
salaries = salaries[, c("lgID", "teamID", "salary1M") := 
                      list(as.character(lgID), as.character(teamID), salary / 1e6L)]
payroll = salaries[, .(payroll = sum(salary1M)), by=.(teamID, yearID)]

teamPayroll = merge(teams, payroll, by=c("teamID","yearID"))

MLB1991AL <- subset (teamPayroll, yearID==1991 & lgID=="AL")

#pander (teamPayroll, caption="1991 Major League Baseball Team Data")
```


```r
res1991MLB <- DEA(MLB1991AL$payroll, MLB1991AL$W, rts = "vrs")
rownames(res1991MLB$eff) <- MLB1991AL$teamID
colnames(res1991MLB$lambda) <- t(MLB1991AL$teamID)
pander(poscol(cbind(res1991MLB$eff, res1991MLB$lambda)), caption = "BCC Efficiency and Lambda Values of 1991 AL Teams")
```


--------------------------------------------
 &nbsp;    &nbsp;   CHA    MIN   SEA    TOR 
--------- -------- ------ ----- ------ -----
 **BAL**   0.8957    0      0     1      0  

 **BOS**   0.4549   0.25    0    0.75    0  

 **CAL**   0.4746    0      0     1      0  

 **CHA**     1       1      0     0      0  

 **CLE**   0.8898    0      0     1      0  

 **DET**   0.6711   0.25    0    0.75    0  

 **KCA**   0.5962    0      0     1      0  

 **MIN**     1       0      1     0      0  

 **ML4**   0.6788    0      0     1      0  

 **NYA**   0.5739    0      0     1      0  

 **OAK**   0.4324   0.25    0    0.75    0  

 **SEA**     1       0      0     1      0  

 **TEX**   0.8947   0.5     0    0.5     0  

 **TOR**     1       0      0     0      1  
--------------------------------------------

Table: BCC Efficiency and Lambda Values of 1991 AL Teams

These results show that only four teams were efficient:  Chicago White Sox (CHA), Minnesota Twins (MIN), Seattle Mariners (SEA), and Toronto Blue Jays (TOR).  All other teams were compared to a combination of these these teams. Since this is a simple, one-input, one-outuput model, it is easy to show graphically.  The _Benchmarking_ package from Bogetoft and Otto does a great job of drawing 2 dimensional DEA plots so we will again use this package.  


```r
library (Benchmarking)
```

```
## Loading required package: ucminf
```

```
## Loading required package: quadprog
```

```r
dea.plot.frontier (MLB1991AL$payroll, MLB1991AL$W, RTS="vrs", 
                   txt=MLB1991AL$teamID,
                   fex = 0.7, # Scales data text label size 
                   xlab = "Team Salary ($Millions)",
                   ylab = "Regular Season Wins")
```


\includegraphics{08-App_Baseball_files/figure-latex/unnamed-chunk-19-1} 

Now, let's rerun it for multiple years.  


```r
teampayroll2 <- as.data.frame(t(c(rep_len("", 17))))

class(teamPayroll$yearID) <- "numeric"

colnames(teampayroll2) <- c(colnames(teamPayroll), "V2")
# Above feels like a kludge to aggregate reesults Feel free to come up with
# cleaner alternatives

class(teampayroll2$payroll) <- "numeric"
class(teampayroll2$W) <- "numeric"
class(teampayroll2$yearID) <- "numeric"
class(teampayroll2$V2) <- "numeric"

lastyear <- 2016
# Note that as of April 2018, the Lahman package only includes data through 2016

for (year in 1991:lastyear) {
    MLBteamAL <- subset(teamPayroll, yearID == year & lgID == "AL")
    
    resMLB <- DEA(MLBteamAL$payroll, MLBteamAL$W, rts = "vrs")
    rownames(resMLB$eff) <- MLBteamAL$teamID
    colnames(resMLB$lambda) <- t(MLBteamAL$teamID)
    teampayroll2 <- rbind(teampayroll2, cbind(subset(teamPayroll, yearID == year & 
        lgID == "AL"), resMLB$eff))
}

# colnames(teampayroll2[,17])<-'Efficiency'
colnames(teampayroll2)[colnames(teampayroll2) == "V2"] <- "Efficiency"
class(teampayroll2$payroll) <- "numeric"
class(teampayroll2$W) <- "numeric"
class(teampayroll2$Efficiency) <- "numeric"

teampayroll2 <- teampayroll2[-1, ]
# pander(poscol(cbind(resMLB$eff,resMLB$lambda)), caption='BCC Efficiency and
# Lambda Values of AL Teams')
```

Now, let's plot the data.


```r
library(ggplot2)

# ggplot (subset (teampayroll2, yearID==1991 & lgID=='AL'),
ggplot(subset(teampayroll2, lgID == "AL"), aes(x = payroll, y = W)) + geom_point() + 
    xlab("Payroll ($Millions") + ylab("Regular Season Wins") + ggtitle("Salary and Wins: American League (1991-2016)")
```


\includegraphics{08-App_Baseball_files/figure-latex/unnamed-chunk-20-1} 

```r
# teampayroll2 <- rbind(cbind (subset (teamPayroll, yearID==year &
# lgID=='AL'),resMLB$eff))

pander(head(subset(teampayroll2, yearID == 1991 & lgID == "AL")))
```


--------------------------------------------------------------------------
 &nbsp;   teamID   yearID   lgID   franchID   Rank    G    W     L     R  
-------- -------- -------- ------ ---------- ------ ----- ---- ----- -----
 **2**     BAL      1991     AL      BAL       6     162   67   95    686 

 **3**     BOS      1991     AL      BOS       2     162   84   78    731 

 **4**     CAL      1991     AL      ANA       7     162   81   81    653 

 **5**     CHA      1991     AL      CHW       2     162   87   75    758 

 **6**     CLE      1991     AL      CLE       7     162   57   105   576 

 **7**     DET      1991     AL      DET       2     162   84   78    817 
--------------------------------------------------------------------------

Table: Table continues below

 
----------------------------------------------------------------------
 &nbsp;   ERA     SO    PostW      WinPercent             name        
-------- ------ ------ ------- ------------------- -------------------
 **2**    4.59   974      0     0.41358024691358    Baltimore Orioles 

 **3**    4.01   820      0     0.518518518518518    Boston Red Sox   

 **4**    3.69   928      0            0.5          California Angels 

 **5**    3.79   896      0     0.537037037037037   Chicago White Sox 

 **6**    4.23   888      0     0.351851851851852   Cleveland Indians 

 **7**    4.51   1185     0     0.518518518518518    Detroit Tigers   
----------------------------------------------------------------------

Table: Table continues below

 
--------------------------------------------
 &nbsp;   attendance   payroll   Efficiency 
-------- ------------ --------- ------------
 **2**     2552753      17.52      0.8957   

 **3**     2562435      35.17      0.4549   

 **4**     2416236      33.06      0.4746   

 **5**     2934154      16.92        1      

 **6**     1051863      17.64      0.8898   

 **7**     1641661      23.84      0.6711   
--------------------------------------------


```r
ggplot(subset(teampayroll2, lgID == "AL"), aes(x = payroll, y = W, color = yearID)) + 
    geom_point() + scale_color_gradient(low = "blue", high = "red") + xlab("Payroll ($Millions") + 
    ylab("Regular Season Wins") + ggtitle("Salary and Wins: American League (1991-2016)")
```


\includegraphics{08-App_Baseball_files/figure-latex/unnamed-chunk-21-1} 

This chart shows that salaries have been going up over time with the colors on the left being generally blue and the colors on the right being red.

Now, let's look at changes for two specific teams over time that are featured in Michael Lewis'  _Moneyball_:  the New York Yankees and the Oakland Athletics.  They Yankees are generally among the biggest highest spending of teams while the Oakland Athletics are among the lowest.


```r
moneyballplot <- ggplot(subset(teampayroll2, lgID == "AL" & (teamID == "NYA" | teamID == 
    "OAK")), aes(x = payroll, y = W, color = yearID)) + geom_point() + scale_color_gradient(low = "blue", 
    high = "red") + xlab("Payroll ($Millions") + ylab("Regular Season Wins") + ggtitle("Salary and Wins: Oakland and New York Yankees (1991-2016)")


# Moneyballplot <- Moneyballplot +
moneyballplot
```


\includegraphics{08-App_Baseball_files/figure-latex/unnamed-chunk-22-1} 



```r
moneyballplot2 <- ggplot(data = teampayroll2) + geom_point(data = teampayroll2[teampayroll2$teamID %in% 
    c("NYA"), ], aes(x = payroll, y = W, group = teamID, color = yearID, shape = "b")) + 
    geom_point(data = teampayroll2[teampayroll2$teamID %in% c("OAK"), ], aes(x = payroll, 
        y = W, group = teamID, color = yearID, shape = "a")) + scale_color_gradient(low = "blue", 
    high = "red") + xlab("Payroll ($Millions") + ylab("Regular Season Wins") + ggtitle("Salary and Wins: Oakland and New York Yankees (1991-2016)")


# Moneyballplot <- Moneyballplot +
moneyballplot2
```


\includegraphics{08-App_Baseball_files/figure-latex/unnamed-chunk-23-1} 



```r
moneyballplot2 <- ggplot(data = teampayroll2) + geom_point(data = teampayroll2[teampayroll2$teamID %in% 
    c("NYA"), ], aes(x = yearID, y = Efficiency, shape = "b")) + geom_point(data = teampayroll2[teampayroll2$teamID %in% 
    c("OAK"), ], aes(x = yearID, y = Efficiency, shape = "a")) + xlab("Year") + ylab("Team Efficiency") + 
    ggtitle("Team Efficiency Oakland and New York Yankees (1991-2016)") + scale_shape_discrete(name = "Team", 
    breaks = c("NYA", "OAK"), labels = c("Yankees", "Athletics"))


# Moneyballplot <- Moneyballplot +
moneyballplot2
```


\includegraphics{08-App_Baseball_files/figure-latex/unnamed-chunk-24-1} 

The book, _Moneyball_ was published in 2003 and tells the story of Billy Beane as the Oakland A's General Manager.  He took over as General Manager at the end of the 1997 season.  The central thesis is that the Oakland A's outcompleted the New York Yankees despite having a much lower salary for players by recognizing a skill that was overlooked by industry conventional wisdom.  We can then divide our salary data and analysis into three periods: Before Billy Beane's General Manager role (1991-1997), Billy Beane before _Moneyball_ (1998-2002), and the after _Moneyball_ era (2004-2010).  This leads to a few potential hypotheses.

Oakland's salary efficiency should have improved with the hiring of Billy Beane. $\theta ^{1991-1997}_{OAK}$=0.6932479<$\theta ^{1998-2002}_{OAK}$=0.9806943: *H1 Supported*

Oakland's salary efficiency should have been higher than New York's before the book was published while Billy Beane was running Oakland. $\theta ^{1998-2002}_{OAK}$=0.9806943>$\theta ^{1998-2002}_{NYA}$=0.5743508: *H2 Supported*

After the book was published, Oakland's strategy was widely known.  The _efficient market hypothesis_ would indicate that Oakland's salary efficiency would decline as the market would then reflect this information in player pricing. $\theta ^{1998-2003}_{OAK}$=0.9806943>$\theta ^{2004-2009}_{OAK}$=0.8228308: *H3 Supported*


```r
# library(dplyr) pander(ddply(teampayroll2, c('teamID'), summarise,
# mean(Efficiency)), caption='Average Team Efficiency', round=4)

# subset(teampayroll2, teamID=='HOU')

# subset(teampayroll2, teamID=='NYA', select=c(teamID, yearID, Efficiency))
# mean(subset(teampayroll2, teamID=='NYA', select=c(teamID,
# Efficiency))[['Efficiency']]) mean(subset(teampayroll2, teamID=='HOU' &
# yearID>2003 )[['Efficiency']])
mean(subset(teampayroll2, teamID == "NYA" & yearID < 2003)[["Efficiency"]])
```

```
## [1] 0.6307145
```

```r
mean(subset(teampayroll2, teamID == "NYA" & yearID > 2003)[["Efficiency"]])
```

```
## [1] 0.5617467
```

```r
mean(subset(teampayroll2, teamID == "OAK" & yearID < 2003)[["Efficiency"]])
```

```
## [1] 0.8130172
```

```r
mean(subset(teampayroll2, teamID == "OAK" & yearID > 2003)[["Efficiency"]])
```

```
## [1] 0.8436331
```

### Allocative Efficiency of Team Budgets

Now, let's demonstrate the use of allocative efficiency in DEA by testing to see whether teams are using their budget efficiently between different categories of players.  

Getting the budget separated by position takes some work.  


```r
appearances = as.data.table(Appearances)  # Create data table of appearances
appearances = appearances[, .(yearID, lgID = as.character(lgID), teamID = as.character(teamID), 
    playerID, G_all, G_batting, G_defense, G_p, G_c, G_1b, G_2b, G_3b, G_ss, G_of)]
# Simplify data table

appearances = appearances[, `:=`(c("P", "B", "C", "B1", "B2", "B3", "SS", "OF"), 
    list(G_p/G_all, ifelse(G_p > 0, 0, G_batting/G_all), ifelse(G_p > 0, 0, G_c/G_defense), 
        ifelse(G_p > 0, 0, G_1b/G_defense), ifelse(G_p > 0, 0, G_2b/G_defense), ifelse(G_p > 
            0, 0, G_3b/G_defense), ifelse(G_p > 0, 0, G_ss/G_defense), ifelse(G_p > 
            0, 0, G_of/G_defense)))]
# Separate by position

positionSalaries = merge(salaries, appearances)
# Combine with salaries and appearances

positionSalaries = positionSalaries[, .(yearID, teamID, lgID, playerID, salary1M, 
    pitcher = salary1M * P, batter = salary1M * B, catcher = salary1M * C, firstBase = salary1M * 
        B1, secondBase = salary1M * B2, thirdBase = salary1M * B3, shortstop = salary1M * 
        SS, outfielder = salary1M * OF)]
# Find salary by position

payrollByPositions = positionSalaries[, .(pitcher = sum(pitcher), batter = sum(batter), 
    catcher = sum(catcher), firstBase = sum(firstBase), secondBase = sum(secondBase), 
    thirdBase = sum(thirdBase), shortstop = sum(shortstop), outfielder = sum(outfielder)), 
    by = .(teamID, yearID)]

teamPayrollByPositions = merge(teams, payrollByPositions, by = c("teamID", "yearID"))
# Aggregate by team
```

There are likely to be more elegant and efficient ways of doing these calculations. 



```r
teampayroll3 <- as.data.frame(t(c(rep_len("", 24))))

class(teamPayrollByPositions$yearID) <- "numeric"

colnames(teampayroll3) <- c(colnames(teamPayrollByPositions), "V2")
# Above feels like a kludge to aggregate reesults Feel free to come up with
# cleaner alternatives

# class(teampayroll3$payroll)<-'numeric'
class(teampayroll3$W) <- "numeric"
class(teampayroll3$yearID) <- "numeric"
class(teampayroll3$V2) <- "numeric"

lastyear <- 2016
# Note that as of April 2018, the Lahman package only includes data through 2016

for (year in 1991:lastyear) {
    MLBteamAL3 <- subset(teamPayrollByPositions, yearID == year & lgID == "AL")
    
    resMLB <- DEA(cbind(MLBteamAL3$pitcher, MLBteamAL3$batter), MLBteamAL3$W, rts = "vrs")
    rownames(resMLB$eff) <- MLBteamAL3$teamID
    # colnames(resMLB$lambda) <- t(MLBteamAL3$teamID)
    teampayroll3 <- rbind(teampayroll3, cbind(subset(teamPayrollByPositions, yearID == 
        year & lgID == "AL"), resMLB$eff))
}

# colnames(teampayroll2[,17]) <- 'Efficiency'
colnames(teampayroll3)[colnames(teampayroll3) == "V2"] <- "Efficiency"
class(teampayroll3$pitcher) <- "numeric"
class(teampayroll3$W) <- "numeric"
class(teampayroll3$Efficiency) <- "numeric"

teampayroll3 <- teampayroll3[-1, ]
# pander(poscol(cbind(resMLB$eff,resMLB$lambda)), caption='BCC Efficiency and
# Lambda Values of AL Teams')

pander(head(teampayroll3))
```


--------------------------------------------------------------------------
 &nbsp;   teamID   yearID   lgID   franchID   Rank    G    W     L     R  
-------- -------- -------- ------ ---------- ------ ----- ---- ----- -----
 **2**     BAL      1991     AL      BAL       6     162   67   95    686 

 **3**     BOS      1991     AL      BOS       2     162   84   78    731 

 **4**     CAL      1991     AL      ANA       7     162   81   81    653 

 **5**     CHA      1991     AL      CHW       2     162   87   75    758 

 **6**     CLE      1991     AL      CLE       7     162   57   105   576 

 **7**     DET      1991     AL      DET       2     162   84   78    817 
--------------------------------------------------------------------------

Table: Table continues below

 
----------------------------------------------------------------------
 &nbsp;   ERA     SO    PostW      WinPercent             name        
-------- ------ ------ ------- ------------------- -------------------
 **2**    4.59   974      0     0.41358024691358    Baltimore Orioles 

 **3**    4.01   820      0     0.518518518518518    Boston Red Sox   

 **4**    3.69   928      0            0.5          California Angels 

 **5**    3.79   896      0     0.537037037037037   Chicago White Sox 

 **6**    4.23   888      0     0.351851851851852   Cleveland Indians 

 **7**    4.51   1185     0     0.518518518518518    Detroit Tigers   
----------------------------------------------------------------------

Table: Table continues below

 
--------------------------------------------------------------
 &nbsp;   attendance   pitcher    batter         catcher      
-------- ------------ --------- ----------- ------------------
 **2**     2552753      4.222    10.925667         NaN        

 **3**     2562435      14.37      18.9            NaN        

 **4**     2416236      13.23    17.027501         NaN        

 **5**     2934154       5.2       11.72           NaN        

 **6**     1051863      9.64       5.835     1.08170212765957 

 **7**     1641661      8.73     15.108333   1.98072987374423 
--------------------------------------------------------------

Table: Table continues below

 
--------------------------------------------------------------------
 &nbsp;       firstBase          secondBase           thirdBase     
-------- ------------------- ------------------- -------------------
 **2**           NaN                 NaN                 NaN        

 **3**           NaN                 NaN                 NaN        

 **4**           NaN                 NaN                 NaN        

 **5**           NaN                 NaN                 NaN        

 **6**    0.427237111292962   0.584062851010076   0.444949961950233 

 **7**    2.43827547464383    2.97261885714286    0.659119590733591 
--------------------------------------------------------------------

Table: Table continues below

 
------------------------------------------------------------
 &nbsp;       shortstop          outfielder      Efficiency 
-------- ------------------- ------------------ ------------
 **2**           NaN                NaN              1      

 **3**           NaN                NaN            0.5121   

 **4**           NaN                NaN            0.5485   

 **5**           NaN                NaN              1      

 **6**    0.577611464968153   2.80778358356436       1      

 **7**     2.4335996023166    4.96915450200565     0.6791   
------------------------------------------------------------

```r
pander(head(cbind(teampayroll2$Efficiency, teampayroll3$Efficiency)), caption = "Sample of BCC-Efficiency vs. Allocative Efficiency")
```


-------- --------
 0.8957     1    

 0.4549   0.5121 

 0.4746   0.5485 

   1        1    

 0.8898     1    

 0.6711   0.6791 
-------- --------

Table: Sample of BCC-Efficiency vs. Allocative Efficiency


### Future Research Opportunities on Team Management

* The above hypotheses were considered based on means. It could be extended for statistical significance.  
* The spread of best practices from the Oakland A's through baseball could be modeled from the perspective of the diffusion of innovation.
* The book _Moneyball_ helped to popularize and legitimize analytics in sports management.  Other industries could be explored to see if they have similar pre- and post-_Moneyball_ effects.
* General managers spend salary between pitchers and position players.  Extending the model by separating salaries between the two players could be used to reveal patterns of allocative inefficiency between teams. 
* Salary efficiency could be used to explore and test the impact of organizational practices and structures.
* One of the open questions in baseball analysis is measuring the impact of being a _good_ teammate.  It has been argued that some players have most of their value come by way of being a positive influence in the team clubhouse but unlike for batting, pitching, and more recently, fielding, no accepted measure of this team influence has been done.  Lessons from sports might then be applicable to areas of greater significance such as new product teams, project management, boards of directors, and other areas.

## Malmquist Productivity Indices


## To-Do Items for this Chapter

* Examine allocative efficiency by way of spending on different positions
* Validate results with previous papers
* Malmquist Productivity Index application in baseball
* Salary and team information benchmarking
* Discuss modeling issues from previous chapter
