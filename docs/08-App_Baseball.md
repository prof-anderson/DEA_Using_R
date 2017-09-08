---
output:
  pdf_document: default
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

The range of applications can cover benchmarking individual players, managers, general managers, and teams.  Analyzing individual players is the most common type of baseball application and will be the bulk of this chapter.  Each baseball player typically plays a role as a batter, a fielder, and/or a pitcher.  We will focus on batting for this first section.

## Baseball Data, R, and dplyr

For the sake of readers unfamiliar with baseball, we will provide a brief introduction.  In general, you can think of these 
Batting is in many ways the simplest to examine.  In the abstract, a batter uses their at-bats or plate appearances as opportunities to create events that help create runs for their team.  In each game, a batter typically has four to six at-bats.  These at-bats may be framed as a contest between a pitcher trying to make the batter create an out and the batter trying to get a hit.  Hits include singles, doubles, triples, and home runs, in increasing order of value. A fifth common outcome is a walk or "base-on-balls" which occurs when the pitcher throws four balls that gives the batter a free pass to first base.  There is a common expression that "a walk is as good as a hit" but a walk may not give as much advancement to other runners as a single so it may be considered as slightly less valuable than a single.  

In the past, batters weren't given much "recognition" for walks and a batter's receiving a walk did not count as an at-bat. Plate appearances count the opportunities for creating a hit or a walk and is sum of at-bats and walks. 

There are a variety of less frequent outcomes of a plate appearance such as a sacrifice fly, an error, or hit by pitch.  These are all less common and often an accidental outcome from the batters perspective.  

Over the course of the current 162 game season, most full-time players will have over 500 plate appearances.  

In general, a model of a baseball batter can e thought of as equivalent to a factory converting plate appearances 

One way to approach DEA modeling is to examine a series of questions.
“What is the goal of the analysis?”  A DEA evaluation can be used in a variety of ways but it is important decide on a goal to lead the rest of the modeling.  Goals include but are not limited to evaluating management, setting targets, and determining best practices.

Now, let's wrestle with data sources.  Sean Lahman's baseball database has been made available as an R package.  This is a wonderful resource.  http://seanlahman.com/



```r
library ("Lahman")
library ("dplyr")
library("pander")
```

Our exploration will also serve as a review of data manipulation in R. There are many ways of doing this.  Feel free to explore further.

As usual, we want to see get familiar with the data.  Let's look at the first few rows of the batting data.


```r
pander(head(Lahman::Batting), caption="Sample of Lahman Baseball Data")
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
 0     0    0    0    0    0    NA    NA    NA   NA    NA  

 0    13    8    1    4    0    NA    NA    NA   NA    NA  

 0    19    3    1    2    5    NA    NA    NA   NA    NA  

 2    27    1    1    0    2    NA    NA    NA   NA    NA  

 0    16    6    2    2    1    NA    NA    NA   NA    NA  

 0     5    0    1    0    1    NA    NA    NA   NA    NA  
-----------------------------------------------------------

What does this all mean?  The first column, playerID, is a uniquely coded ID for each player consisting of the first six letters of the last name, first two letters of the first name, and which instance of that eight letter combination the player is.  For example, row 5 is ansonca01, which corresponds to the  Hall of Famer, Cap Anson.  Each row gives the statistics for a year that he had with a particular team.  If the player plays for multiple teams in a year, they will have multiple rows.  Also, if their career lasts more than one year, they will have more than one row.

In this case, in 1871 Cap Anson played in 25 Games, had 120 at-bats, scored 29 runs, had 39 hits, and 11 doubles, 3 triples, and no home runs.  He also had 16 runs-batted-in, 6 stolen bases while being caught stealing twice.  He had 2 walks (base on balls) while striking out once.  Other values of intentional base on balls, hit by pitches, sacrifice hits, sacrifice flies, and grounded into double plays are not available.  

This is pretty impressive to have such detailed and specific data going back almost 150 years! 

Using the Summary command will  provide all kinds of interesting information such as that over half of the player seasons occurred after 1970, the maximum number of stints with different teams was 5 and the most player seasons were for the National League's Chicago Cubs (teamID=CHN).  I'll leave this for your exploration.  

Hadley Wickham has written an excellent package for wrestling with data called dplyr.  

Most of the columns are not needed so let's subset the variables.  


```r
batting<-Lahman::Batting
batting <- dplyr::select(batting,playerID,yearID,teamID,lgID,AB,H,X2B,X3B,HR,BB)
pander(head(batting), caption="Batting Data Used for Analysis")
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
batting<-dplyr::filter(batting,yearID>1900)
pander(head(batting), caption="Batting Statistics for Players after 1901")
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

As we discussed earlier, At-Bats (AB) is good but let's convert that to plat appearances.  Also, let's get the number of singles.


```r
batting<-dplyr::mutate(batting,X1B=H-HR-X3B-X2B)
batting<-dplyr::mutate(batting,PA=AB+BB)
pander(head(batting), caption="Calculate Singles and Plate Appearances")
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
batting <- dplyr::select(batting,playerID,yearID,teamID,lgID,PA,BB,X1B,X2B,X3B,HR)
pander(head(batting), caption="Batting Statistics Converted into Inputs and Outputs")
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
batting <- dplyr::filter(batting,PA>MinPA)
pander(head(batting), caption="Limit to Full-time Players")
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
batting<-Lahman::Batting

batting <- batting %>% 
  select(playerID,yearID,teamID,lgID,AB,H,X2B,X3B,HR,BB) %>%
  mutate(PA=as.numeric(AB+BB)) %>%
  mutate(X1B=as.numeric(H-HR-X3B-X2B)) %>%
  transform(BB=as.numeric(BB)) %>%
  transform(X2B=as.numeric(X2B)) %>%
  transform(X3B=as.numeric(X3B)) %>%
  transform(HR=as.numeric(HR)) %>%
  
  filter(yearID>1900, PA>MinPA) %>%
  select(playerID,yearID,teamID,lgID,PA,BB,X1B,X2B,X3B,HR)

pander (head(batting), caption="Results of Preparing Data using dplyr")
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

In 1920, the American League featured a batter so dominant that he transformed the "industry" of baseball.  Let's focus on this year for now.


```r
inputs <- c("PA")
outputs <- c("BB", "X1B", "X2B", "X3B", "HR")
batting1920AL <- batting %>% filter(yearID==1920, lgID=="AL")

x <- batting1920AL %>% select( PA)
row.names(x)<-batting1920AL[,1]
pander (head (x), caption="Inputs for the 1920AL")
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
row.names(y)<-batting1920AL[,1]
pander (head (y), caption="Outputs for the 1920AL")
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
library(TFDEA)
```

```
## Loading required package: lpSolveAPI
```

```r
res1920AL<-DEA(x,y, rts="CRS", orientation="output", slack=TRUE, dual=TRUE)
```

```
## Warning, data has DMU's with outputs that are zero, this may cause numerical problems
```

```r
pander (head(res1920AL$eff), caption="Efficiency Scores for 1920AL")
```


---------------------------------------------------------------------
 bodiepi01   bushdo01   chapmra01   cobbty01   collied01   collish01 
----------- ---------- ----------- ---------- ----------- -----------
   1.252      1.186       1.204      1.091         1         1.115   
---------------------------------------------------------------------

Success.  We have now run DEA using the TFDEA package, principally developed by Tom Shott with important contributions from Dong-Joon Lim, Kevin van Blommestein, and others.  Notice that this is an output-oriented model so the values greater than 1.0 indicate that decreasing radial efficiency (increasing inefficiency), and describe the amount of additional outputs that should be acheived at the same level of input usage.  In other words, how much more walks, singles, doubles, triples, and home runs the player should be producing in the same number of plate appearances if he was batting _efficiently_.

Let's dig a little deeper now.  Let's start by reviewing the output weights for the first few players.  We'll display the table in two ways.  


```r
pander(head(res1920AL$uy), round=6, caption = "Output Weights for 1920 AL")
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

A few things stand out.  First, only one of the first six players puts any weight on home runs.  There should be a heirarchy that singles are at least as good as walks, doubles are at least as good singles, triples are at least as good as doubles, and home runs are at least as good triples.  Every player violates at least one of these relationships.  Any plausible analysis of baseball batting needs to reflect these relationships.  While very different, common metrics such as batting average and slugging average satisfy these relationships but our first DEA model does not.

In Anderson and Sharpe's 1997 paper, ordinal weight restrictions were incorporated into the envelopment model for examining baseball batters by accumulating hits.  This created new outputs of Singles or better (BB+X1B), doubles or better (BB+X1B+X2B), etc.  

Another approach is to analyze the data set using the multiplier model and directly incorporating weight restrictions.  For this, we will make use of the DEAMultiplier package written by Aurobindh Kalathil Puthanpura.  


```r
library(MultiplierDEA)

res1920ALmult<-DeaMultiplierModel(x,y,rts = "crs", orientation="output")
```

```
## Warning, data has DMU's with outputs that are zero, this may cause
##       numerical problems
```

```r
pander(head (res1920ALmult$Efficiency), caption="DEA Output Weights")
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

qplot (res1920ALmult$Efficiency, 
       geom="histogram")
```

```
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

![](08-App_Baseball_files/figure-latex/unnamed-chunk-2-1.pdf)<!-- --> 

```r
qplot (res1920ALmult$Efficiency, 
       geom="dotplot",
       main = "1920 American League Batter Efficiency",
       xlab = "Efficiency Score",
       fill = I("blue")
)
```

```
## `stat_bindot()` using `bins = 30`. Pick better value with `binwidth`.
```

![](08-App_Baseball_files/figure-latex/unnamed-chunk-2-2.pdf)<!-- --> 

Next, let's review the output weights.  


```r
pander(head(res1920ALmult$uy), round=6, caption="Output Weights from Multiplier Model")
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
pander(head (res1920AL$uy), round=6, caption="Output Weights from Envelopment Model")
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


Again, we see that the results are similar to what was observed earlier.  Note that the results for Eddie Collins (collied01) are different.  Eddie Collins was efficient and it is common that efficient players have multiple weighting schemes that still result in being efficient.  The MultiplierDEA package puts weight on triples (X3B) while the TFDEA package's solution puts a zero weight on triples and distributes weight among other outputs.  

In any case, the output weights do not meet the requirements of a realistic baseball application.  Let's apply weight restrictions.  


```r
MaxWR <- 1000  #This is a temporary value until Inf or NaN is implemented

BattingWR<-data.frame(lower = c(1.0,1.0,1.0,1.0), 
                      numerator = c("X1B", "X2B","X3B", "HR"), 
                      denominator = c("BB", "X1B", "X2B","X3B"), 
                      upper = c(NaN, NaN, NaN, NaN))

res1920ALmultWR<-DeaMultiplierModel(x,y,rts = "crs", orientation="output", 
                                  weightRestriction = BattingWR)
```

```
## Warning, data has DMU's with outputs that are zero, this may cause
##       numerical problems
```

Let's talk about a particular hitter, Eddie Collins.  Without weight restrictions, he was efficient.  With weight restrictions, his efficiency was 0.9350071.  In fact, the histogram of efficiency scores is more telling.  


```r
qplot (res1920ALmultWR$Efficiency, 
       geom="dotplot",
       main = "1920 American League Batter Efficiency",
       xlab = "Efficiency Score",
       fill = I("blue")
)
```

```
## `stat_bindot()` using `bins = 30`. Pick better value with `binwidth`.
```

![](08-App_Baseball_files/figure-latex/unnamed-chunk-5-1.pdf)<!-- --> 


```r
binwidth <- 0.01
hist(res1920ALmult$Efficiency, xlim=c(0.6,1.0),
     col="red", breaks=seq(0.6,1.0,by=binwidth), 
     main="Impact of Weight Restrictions on Batter Efficiency",
     xlab="Efficiency")
hist(res1920ALmultWR$Efficiency,
     add=T,col=scales::alpha('blue',.5),border=F,
     breaks=seq(0.6,1.0,by=binwidth) )
```

![](08-App_Baseball_files/figure-latex/unnamed-chunk-6-1.pdf)<!-- --> 

The weight restrictions have dropped the number of efficient players from seven to two.  As might be expected, Babe Ruth was efficient in both models.    

### Cross-Efficiency of Baseball Batters
Now, let's turn our attention to a variation of DEA called cross-efficiency.  Cross-efficiency was discussed in an earlier chapter.  


```r
res1920ALcross<-CrossEfficiency(x,y,rts = "crs", orientation="output")
```

```
## Warning, data has DMU's with outputs that are zero, this may cause
##       numerical problems
```

```r
pander(head (res1920ALcross$ce_ave),round=4,caption="Cross-efficiency scores for 1920AL")
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
pander(head (res1920ALmult$Efficiency),round=4,caption="CCR Efficiency Scores")
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
pander(head (res1920ALcross$ceva_max),round=4,caption="Maximum Cross Evaluation Score for Each Player")
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

Table: Maximum Cross Evaluation Score for Each Player

```r
pander(cor(cbind(res1920ALmult$Efficiency, res1920ALcross$ce_ave, res1920ALmultWR$Efficiency)),round=4,caption="Correlation between Scores")
```


-----------------------------------------
   &nbsp;       Eff     Average    Eff   
------------- -------- --------- --------
   **Eff**       1      0.8696    0.8885 

 **Average**   0.8696      1      0.9102 

   **Eff**     0.8885   0.9102      1    
-----------------------------------------

Table: Correlation between Scores

The cross-efficiency and the regular efficiency scores are related - they have a correlation of 0.870 but the cross-efficiency has a 0.910 correlation with the weight restricted DEA results.  This suggests that perhaps cross-efficiency can help deal with decreasing the impact of unrealistic weight schemes but let's take a closer look at the results.

First, let's examine one hitter in particular.  In 1920, Babe Ruth had one of the best seasons ever by a baseball hitter. Various statistics demonstrate his dominance but home runs really highlight the impact.  His 54 home runs nearly doubled the previous record of 29 in a season he had set the previous year. Alone, he hit more home runs than 14 of the 16 teams in the leagues. Until the recent steroid era, Babe Ruth's 1920 and 1921 seasons are generally considered to be the two best offensive seasons in baseball.  

Babe's cross-efficiency score was 0.765966.  Coincidentally, his cross-efficiency score was nearly identical to the average cross-efficiency of other regular baseball batters of 0.765954.  In other words, what may have been one of the best batting performances in a century of baseball was wrongly misclassified as being just average by cross-efficiency.

The reason for this can be seen by the cross-efficiency matrix of weights. 


```r
collectedeff <- c(res1920ALmult$Efficiency, res1920ALcross$ce_ave)
qplot(res1920ALmult$Efficiency, res1920ALmultWR$Efficiency, 
      xlab="Efficiency", ylab="Efficiency with Weight Restrictions",
      main="Impact of Weight Restrictions on 1920 AL CC Efficiency",
      xlim=c(0.6,1.01), ylim=c(0.6,1.01)
      )
```

![](08-App_Baseball_files/figure-latex/unnamed-chunk-8-1.pdf)<!-- --> 

Okay, this plot shows that that the data is quite a bit different. If the models produced the same results for each player, the efficiency scores would fall along a single diagonal line.  It would be nice plot this line.  Apparently qplot doesn't allow for this.  It would also be nice to be able to label specific points.  Also, to be able to show the cross-efficiency scores as a second set of points.  Let's start redrawing it using ggplot2.


```r
library("ggplot2")

collectedeff <- c(res1920ALmult$Efficiency, res1920ALcross$ce_ave)
# ggplot2(collectedeff, aes(res1920ALmult$Efficiency, res1920ALmultWR$Efficiency, 
#      xlab="Efficiency", ylab="Efficiency with Weight Restrictions",
#      main="Impact of Weight Restrictions on 1920 AL CC Efficiency",
#      xlim=c(0.6,1.01), ylim=c(0.6,1.01)
#      ))
```

## To-Do Items for this Chapter
* Validate results with previous papers
* Better format tables of results
* Malmquist Productivity Index application
* Salary and team information benchmarking
* Add more on weights in cross-efficiency
* Discuss modeling issues from previous chapter

## To-Do Items for DEAMultiplier Model (some for later)
* Secondary objective functions for cross-efficiency (benev vs. malev formulations)
* Unbounded side for weight restrictions
* A switch for phi vs/ 1/phi interpretations
* Results of cross-efficiency should include matrix of vx and uy weights
* Fix documentation links
* Super-efficiency option
* Cross-efficiency should include option for passing in weight restrictions


