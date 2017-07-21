---
title: "09-App_Tech_Comm"
author: "Tim Anderson"
date: "July 4, 2017"
output:
  pdf_document: default
  html_document: default
---



# Technology Commercialization 

## Introduction

In 2002, Sten Thore edited a book, Technology Commercialization:  DEA and Related Analytical Methods for Evaluating the Use and Implementation of Technological Innovation.  This book complied a series of cases applying Data envelopment Analysis related to technology management.  This chapter revisits some of those cases. We will provide a snapshot of the cases but the reader is referred to Thore's book for more details.  

## Prioritizing R&D Activities

### Directional Drilling R&D Projects

Chapter 2 of Thore, by Thore and Rich, covers a series of small cases covers around R&D projects.  The first case begins on page 62 with an application from Baker Hughes Corporation.  They were considering 14 cases related "directional drilling", which as a technology, combined with hydraulic facturing, years later resulted in the natural gas boom.  

Thore and Rich use a one-input, four-output variable returns to scale DEA model.  The input was expected cost in millions of dollars.  The outputs are estimated market size in millions of dollars (Y1), strategic compatability with existing products (Y2), projected market demand in millions of dollars (Y3), and competitive intensity (Y4).  

Let's start by defining the data from page 63.  


```r
XBH <- matrix(c(1.07, 1.06, 0.325, 1.60, 0.55, 0.2, 0.35, 0.53, 0.21, 0.16, 0.07, 1.95, 5.59, 3.10),
                  ncol=1,dimnames=list(LETTERS[1:14],c("x1")))

YBH <- matrix(c(32, 50, 40, 30 ,25, 8, 2, 12, 10, 0.8, 3, 300, 60, 240,
                8.2, 7.6, 7.6, 7.1, 7.0, 6.0, 5.9, 5.8, 5.8, 5.4, 5.3, 6.8, 6.2, 6.2,
                7.5, 7.2, 7.1, 7.2, 7.0, 6.1, 6.2, 5.8, 5.8, 5.6, 5.4, 6.1, 6.9, 6.6,
                8.0, 6.4, 5.3, 5.5, 5.1, 6.9, 6.6, 5.4, 4.7, 6.1, 6.5, 6.4, 6.8, 7.1),
                  ncol=4,dimnames=list(LETTERS[1:14],c("y1", "y2", "y3", "y4")))
```

Now, let's run DEA.  Feel free to pick a package.  We explored some packages in chapter 8.  For now, let's try the MultiplierDEA package.  Let's look over the results.


```r
library(MultiplierDEA)
library(xtable)

resBH<-DeaMultiplierModel(XBH,YBH,rts = "vrs", orientation="input")

tableresBHEff <- xtable(head(resBH$Efficiency))
align(tableresBHEff)<-xalign(tableresBHEff)
digits(tableresBHEff)<-xdigits(tableresBHEff)
display(tableresBHEff)<-xdisplay(tableresBHEff)
xtable(head(tableresBHEff))
```

% latex table generated in R 3.4.0 by xtable 1.8-2 package
% Tue Jul 04 17:25:27 2017
\begin{table}[ht]
\centering
\begin{tabular}{rr}
  \hline
 & Eff \\ 
  \hline
A & 1.00 \\ 
  B & 0.65 \\ 
  C & 1.00 \\ 
  D & 0.32 \\ 
  E & 0.56 \\ 
  F & 1.00 \\ 
   \hline
\end{tabular}
\end{table}

```r
tableresBHuy <- xtable(head(resBH$uy))
align(tableresBHuy)<-xalign(tableresBHuy)
digits(tableresBHuy)<-xdigits(tableresBHuy)
display(tableresBHuy)<-xdisplay(tableresBHuy)
xtable(head(tableresBHuy))
```

% latex table generated in R 3.4.0 by xtable 1.8-2 package
% Tue Jul 04 17:25:27 2017
\begin{table}[ht]
\centering
\begin{tabular}{rrrrr}
  \hline
 & y1 & y2 & y3 & y4 \\ 
  \hline
A & 0.01 & 0.19 & 0.00 & 0.23 \\ 
  B & 0.01 & 0.00 & 0.30 & 0.23 \\ 
  C & 0.02 & 0.03 & 0.00 & 0.00 \\ 
  D & 0.00 & 0.00 & 1.16 & 0.00 \\ 
  E & 0.00 & 0.00 & 0.27 & 0.00 \\ 
  F & 0.00 & 0.00 & 0.85 & 0.14 \\ 
   \hline
\end{tabular}
\end{table}

The efficiency scores match those reported by Thore and Rich but they didn't examine the output weights.  A lot of discussion could be had about relative weights.  We will leave that to the interested reader pontificate upon.


```r
tableresBHuy <- xtable(head(resBH$uy))
align(tableresBHuy)<-xalign(tableresBHuy)
digits(tableresBHuy)<-xdigits(tableresBHuy)
display(tableresBHuy)<-xdisplay(tableresBHuy)
xtable(head(tableresBHuy))
```

% latex table generated in R 3.4.0 by xtable 1.8-2 package
% Tue Jul 04 17:25:27 2017
\begin{table}[ht]
\centering
\begin{tabular}{rrrrr}
  \hline
 & y1 & y2 & y3 & y4 \\ 
  \hline
A & 0.01 & 0.19 & 0.00 & 0.23 \\ 
  B & 0.01 & 0.00 & 0.30 & 0.23 \\ 
  C & 0.02 & 0.03 & 0.00 & 0.00 \\ 
  D & 0.00 & 0.00 & 1.16 & 0.00 \\ 
  E & 0.00 & 0.00 & 0.27 & 0.00 \\ 
  F & 0.00 & 0.00 & 0.85 & 0.14 \\ 
   \hline
\end{tabular}
\end{table}

### NASA Areonautical Projects 

The next case discussed was of NASA aeronautics projects.  


```r
XNASA <- matrix(c(15.5, 23.0, 39.5, 80.0, 14.5, 13.5, 30.0, 220.0, 180.0, 980.0, 1050.0, 15.0, 40.0,
                5.5, 110.0, 350.0, 350.0, 110.0),
                  ncol=1,dimnames=list(c("A1", "A2", "A3", "A4", "A5", "A6",
                                         "B1", "B2", "B3", "B4", "C1", "C2", "C3",
                                         "D1", "E1", "E2", "E3", "E4"),c("x1")))

YNASA <- matrix(c(1.8, 2.7, 2.7, 9.0, 1.35, 2.25, 9.6, 16.0, 6.8, 25.2, 20.7, 4.5, 19.8, 0.75, 0, 0, 0, 0,
                7.0,7.0,7.0,7.0,7.0,7.0,8.0,10.0,10.0,9.0,6.0,6.0,6.0,10.0,8.0,8.0,8.0,8.0,
                18.0, 45.0, 7.2, 108.0, 6.3, 40.5, 240.0, 160, 64.0, 560.0, 1170.0, 18.0,
                544.5, 1.0, 0, 0, 0, 0),
                  ncol=3,dimnames=list(c("A1", "A2", "A3", "A4", "A5", "A6",
                                         "B1", "B2", "B3", "B4", "C1", "C2", "C3",
                                         "D1", "E1", "E2", "E3", "E4"),c("y1", "y2", "y3")))
```



```r
resNASA<-DeaMultiplierModel(XNASA,YNASA,rts = "vrs", orientation="input")
```

```
## Warning, data has DMU's with outputs that are zero, this may cause
## numerical problems
```

```r
tableresNASAEff <- xtable(head(resNASA$Efficiency))
align(tableresNASAEff)<-xalign(tableresNASAEff)
digits(tableresNASAEff)<-xdigits(tableresNASAEff)
display(tableresNASAEff)<-xdisplay(tableresNASAEff)
xtable(head(tableresNASAEff))
```

```
## % latex table generated in R 3.4.0 by xtable 1.8-2 package
## % Tue Jul 04 17:25:28 2017
## \begin{table}[ht]
## \centering
## \begin{tabular}{rr}
##   \hline
##  & Eff \\ 
##   \hline
## A1 & 0.48 \\ 
##   A2 & 0.39 \\ 
##   A3 & 0.23 \\ 
##   A4 & 0.26 \\ 
##   A5 & 0.45 \\ 
##   A6 & 0.61 \\ 
##    \hline
## \end{tabular}
## \end{table}
```

```r
tableresNASAuy <- xtable(head(resNASA$uy))
align(tableresNASAuy)<-xalign(tableresNASAuy)
digits(tableresNASAuy)<-xdigits(tableresNASAuy)
display(tableresNASAuy)<-xdisplay(tableresNASAuy)
xtable(head(tableresNASAuy))
```

```
## % latex table generated in R 3.4.0 by xtable 1.8-2 package
## % Tue Jul 04 17:25:28 2017
## \begin{table}[ht]
## \centering
## \begin{tabular}{rrrr}
##   \hline
##  & y1 & y2 & y3 \\ 
##   \hline
## A1 & 0.12 & 0.00 & 0.00 \\ 
##   A2 & 0.08 & 0.00 & 0.00 \\ 
##   A3 & 0.05 & 0.00 & 0.00 \\ 
##   A4 & 0.02 & 0.00 & 0.00 \\ 
##   A5 & 0.12 & 0.00 & 0.00 \\ 
##   A6 & 0.13 & 0.00 & 0.00 \\ 
##    \hline
## \end{tabular}
## \end{table}
```


## To-Do Items for this Chapter
* More data sets

## To-Do Items for Packages (some for later)
* Add data sets to package(s)
