# These are helper functions for R and the DEA
#    book.  

## ---- poscolfunct ----
# Accepts a dataframe and returns only columns that do not sum to zero.

library(DiagrammeR)

poscol<-function(df) {
  positive.columns <- df[, colSums(df) != 0]
  return (positive.columns)
}  

## ---- DEAnamesfunction ----
# Generates a generic set of names for all objects that might be used by DEA.

  DEAnames<-function(NX, NY, ND) {
    
    DMUnames <- list(c(LETTERS[1:ND]))               # DMU names: A, B, ...
    Xnames<- lapply(list(rep("X",NX)),paste0,1:NX)   # Input names: x1, ...
    Ynames<- lapply(list(rep("Y",NY)),paste0,1:NY)   # Output names: y1, ...
    Vnames<- lapply(list(rep("v",NX)),paste0,1:NX)   # Input weight names: v1, ...
    Unames<- lapply(list(rep("u",NY)),paste0,1:NY)   # Output weight names: u1, ...
    SXnames<- lapply(list(rep("sx",NX)),paste0,1:NX) # Input slack names: sx1, ...
    SYnames<- lapply(list(rep("sy",NY)),paste0,1:NY) # Output slack names: sy1, ...
    Lambdanames<- lapply(list(rep("L_",ND)),paste0,LETTERS[1:ND])
    
    allnames<-list(DMUnames=DMUnames,
                   Xnames=Xnames,Ynames=Ynames,
                   Vnames=Vnames,
                   Unames=Unames,
                   SXnames=SXnames,
                   SYnames=SYnames,
                   Lambdanames=Lambdanames)
    
    return(allnames)
  }
  
## ---- DrawIOdiagramfunction ----
# Accepts a list of inputs, outputs, and model description
#    Draws an input-output diagram
  
  DrawIOdiagram<-function(Xnames="1",Ynames="1", Modeldescrip="DEA") {
  
    a <- "'"
    
    NX <- lengths(Xnames)     # Number of inputs
    NY <- lengths(Ynames)     # Number of outputs
    
    Xlabels <- c(mapply(paste0, a, Xnames, a)) # Surround text with '
    
    Ylabels <- c(mapply(paste0, a, Ynames, a))
    
    nboxpad <- max(floor(1+NX/2), floor(1+NY/2)) # Pad height of model box
    
    boxpadding <- paste(rep("\n",nboxpad),collapse='')  
    # Build line returns 
    
    Modellabel <- paste(boxpadding, Modeldescrip, boxpadding,
                        collapse="")
    # Want to vertically pad returns, \n's top and bottom to 
    #    balance the height of the boxspace figure
    
    # Define the nodes for the inputs and outputs
    nodelabels <- paste(c(Xlabels,Ylabels), collapse="; ")
    
    # Define the edges (arrows) for inputs and outputs
    Xedges <- paste(c(mapply(paste0, Xlabels,"->", Modellabel [1], " " )),collapse="")
    Yedges <- paste(c(mapply(paste, Modellabel [1], "->", Ylabels," "  )),collapse="")
    # Note:  I'm sure the above two lines are pretty inefficient but they work!
    
    # Combine edges for inputs and outputs
    edges <- paste0( 
      Xedges, Yedges    # All edges or arrows are for inputs or outputs
    )
    
    ##  Plot graph:
    IOGraph <- grViz(
      paste0(" digraph Input_Output_Diagram {

    # a 'graph' statement
    graph [overlap = false, # True or false both work fine
           fontsize = 10, 
           rankdir = LR,    # Left to right structure
           layout = dot]    # dot layout is best for this, 
                            # neato, twopi, circo are not suitable

    # several 'node' statements
    node [shape = plaintext,  # Avoids any outline or shape
    fontname = Helvetica]
    ", nodelabels, "

    node [shape = box, fillcolor = green,
    fontname = Helvetica]
    ", Modellabel, "

    # several 'edge' statements
    ", edges, "
    }"
      )
    )
    
    return (IOGraph)
  }  
  
  