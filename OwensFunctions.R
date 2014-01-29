
makeFootnote <- function(footnoteText=format(Sys.time(), "%d %b %Y"), size= .7, color= grey(.5)) {
  require(grid)
  pushViewport(viewport())
  grid.text(label= footnoteText ,
            x = unit(1,"npc") - unit(2, "mm"),
            y= unit(2, "mm"),
            just=c("right", "bottom"),
            gp=gpar(cex= size, col=color))
  popViewport()
}


iqr <- function(x, ...) {
  q2 <- quantile(x, .25, na.rm=TRUE)
  q3 <- quantile(x, .75, na.rm=TRUE)
  return(paste(as.character(round(q2, 2)), as.character(round(q3, 2)), sep="-"))
}

refactor <- function(x) {
  x <- factor(x, levels=levels(x)[levels(x) %in% x] )
  return(x)
}

getAnnotation <- function(fit, plots) {
  PROBE <- rownames(fit)
  SYMBOL <- as.vector(unlist(fit$genes$SYMBOL))
  SYMBOL[which(!is.na(SYMBOL))] <- paste("<a href=http://www.genecards.org/cgi-bin/carddisp.pl?gene=",SYMBOL[which(!is.na(SYMBOL))], ">", SYMBOL[which(!is.na(SYMBOL))], "</a>", sep="")
  GENENAME <- as.vector(unlist(fit$genes$GENENAME))
  ENTREZID <- as.vector(unlist(fit$genes$ENTREZID))
  ENTREZID[which(!is.na(ENTREZID))] <- paste("<a href=http://www.ncbi.nlm.nih.gov/sites/entrez?cmd=search&db=gene&term=", ENTREZID[which(!is.na(ENTREZID))], ">", ENTREZID[which(!is.na(ENTREZID))], "</a>", sep="")
  PLOT <- paste("<a href=plots/PLOTPREFIX_",sub("/","_",PROBE),".png>plot</a>", sep="")
  PLOTDF <- data.frame(matrix(nrow=length(PROBE), ncol=length(plots)))
  colnames(PLOTDF) <- plots
  for (p in plots) {
    PLOTDF[,p] <- sub("PLOTPREFIX",p, PLOT)
  }
  annotation <- data.frame(PROBE,SYMBOL,GENENAME,ENTREZID,PLOTDF)
  return(annotation)
}


midpoint <- function(v) {
  midpoint <- ((max(v, na.rm=TRUE)-min(v, na.rm=TRUE))/2)+min(v, na.rm=TRUE)
  return(midpoint)
}



## this function spreads out a vector, so that each element is at
## least buff separated from the next element
disperse <- function(x,buff) {
  if (length(x)<2) {return(x)}
  y <- sort(x)
  unsort <- order(order(x))
  continue <- TRUE
  counter <- 0
  while (continue==TRUE) {
    y <- sort(y)
    continue <- FALSE
    for (i in 1:length(y)) {
      if (i==length(y)) {
        diff <- y[i]-y[i-1]
        if (diff < buff) {
          adj <- max(((buff-diff)/2), buff/100)
          y[i] <- y[i] + adj
          y[i-1] <- y[i-1] - adj
          continue <- TRUE
        }
      } else {
        diff <- y[i+1]-y[i]
        if (diff < buff) {
          adj <- max(((buff-diff)/2), buff/100)
          y[i] <- y[i] - adj
          y[i+1] <- y[i+1] + adj
          continue <- TRUE
        }
      }
    }
  }
return(y[unsort])
}


vpl <- function(x,y) viewport(layout.pos.row=x, layout.pos.col=y)



## Venn functions by David States, see http://tolstoy.newcastle.edu.au/R/help/03a/1115.html
venn.overlap <-
function(r, a, b, target = 0)
{
#
# calculate the overlap area for circles of radius a and b
# with centers separated by r
# target is included for the root finding code
#
        pi = acos(-1)
        if(r >= a + b) {
                return( - target)
        }
        if(r < a - b) {
                return(pi * b * b - target)
        }
        if(r < b - a) {
                return(pi * a * a - target)
        }
        s = (a + b + r)/2
        triangle.area = sqrt(s * (s - a) * (s - b) * (s - r))
        h = (2 * triangle.area)/r
        aa = 2 * atan(sqrt(((s - r) * (s - a))/(s * (s - b))))
        ab = 2 * atan(sqrt(((s - r) * (s - b))/(s * (s - a))))
        sector.area = aa * (a * a) + ab * (b * b)
        overlap = sector.area - 2 * triangle.area
        return(overlap - target)
}

plot.venn.diagram <-
function(d)
{
#
# Draw Venn diagrams with proportional overlaps
# d$table = 3 way table of overlaps
# d$labels = array of character string to use as labels
#
pi = acos(-1)
csz = 0.1
# Normalize the data
n = length(dim(d$table))
c1 = vector(length = n)
c1[1] = sum(d$table[2, , ])
c1[2] = sum(d$table[, 2, ])
c1[3] = sum(d$table[, , 2])
n1 = c1
#
c2 = matrix(nrow = n, ncol = n, 0)
c2[1, 2] = sum(d$table[2, 2, ])
c2[2, 1] = c2[1, 2]
c2[1, 3] = sum(d$table[2, , 2])
c2[3, 1] = c2[1, 3]
c2[2, 3] = sum(d$table[, 2, 2])
c2[3, 2] = c2[2, 3]
n2 = c2
#
c3 = d$table[2, 2, 2]
n3 = c3
c2 = c2/sum(c1)
c3 = c3/sum(c1)
c1 = c1/sum(c1)
n = length(c1)
# Radii are set so the area is proporitional to number of counts
pi = acos(-1)
r = sqrt(c1/pi)
r12 = uniroot(venn.overlap, interval = c(max(r[1] - r[2], r[2] - r[1],
0) + 0.01, r[1] + r[2] - 0.01), a = r[1], b = r[
2], target = c2[1, 2])$root
r13 = uniroot(venn.overlap, interval = c(max(r[1] - r[3], r[3] - r[1],
0) + 0.01, r[1] + r[3] - 0.01), a = r[1], b = r[
3], target = c2[1, 3])$root
r23 = uniroot(venn.overlap, interval = c(max(r[2] - r[3], r[3] - r[2],
0) + 0.01, r[2] + r[3] - 0.01), a = r[2], b = r[
3], target = c2[2, 3])$root
s = (r12 + r13 + r23)/2
x = vector()
y = vector()
x[1] = 0
y[1] = 0
x[2] = r12
y[2] = 0
angle = 2 * atan(sqrt(((s - r12) * (s - r13))/(s * (s - r13))))
x[3] = r13 * cos(angle)
y[3] = r13 * sin(angle)
xc = cos(seq(from = 0, to = 2 * pi, by = 0.01))
yc = sin(seq(from = 0, to = 2 * pi, by = 0.01))
cmx = sum(x * c1)
cmy = sum(y * c1)
x = x - cmx
y = y - cmy
rp=sqrt(x*x + y*y)
frame()
par(usr = c(-1, 1, -1, 1), pty = "s")
box()
for(i in 1:3) {
lines(xc * r[i] + x[i], yc * r[i] + y[i])
}
xl = (rp[1] + (0.7 * r[1])) * x[1]/rp[1]
yl = (rp[1] + (0.7 * r[1])) * y[1]/rp[1]
text(xl, yl, d$labels[1])
text(xl, yl - csz, d$table[2, 1, 1])
xl = (rp[2] + (0.7 * r[2])) * x[2]/rp[2]
yl = (rp[2] + (0.7 * r[2])) * y[2]/rp[2]
text(xl, yl, d$labels[2])
text(xl, yl - csz, d$table[1, 2, 1])
xl = (rp[3] + (0.7 * r[3])) * x[3]/rp[3]
yl = (rp[3] + (0.7 * r[3])) * y[3]/rp[3]
text(xl, yl, d$labels[3])
text(xl, yl - csz, d$table[1, 1, 2])
#
text((x[1] + x[2])/2, (y[1] + y[2])/2, d$table[2, 2, 1])
text((x[1] + x[3])/2, (y[1] + y[3])/2, d$table[2, 1, 2])
text((x[2] + x[3])/2, (y[2] + y[3])/2, d$table[1, 2, 2])
#
text(0, 0, n3)
list(r = r, x = x, y = y, dist = c(r12, r13, r23), count1 = c1, count2 =
c2, labels = d$labels)
}



# improved list of objects
# written by dirk eddelbuettel http://stackoverflow.com/questions/1358003/tricks-to-manage-the-available-memory-in-an-r-session
.ls.objects <- function (pos = 1, pattern, order.by,
                        decreasing=FALSE, head=FALSE, n=5) {
    napply <- function(names, fn) sapply(names, function(x)
                                         fn(get(x, pos = pos)))
    names <- ls(pos = pos, pattern = pattern)
    obj.class <- napply(names, function(x) as.character(class(x))[1])
    obj.mode <- napply(names, mode)
    obj.type <- ifelse(is.na(obj.class), obj.mode, obj.class)
    obj.size <- napply(names, object.size)
    obj.dim <- t(napply(names, function(x)
                        as.numeric(dim(x))[1:2]))
    vec <- is.na(obj.dim)[, 1] & (obj.type != "function")
    obj.dim[vec, 1] <- napply(names, length)[vec]
    out <- data.frame(obj.type, obj.size, obj.dim)
    names(out) <- c("Type", "Size", "Rows", "Columns")
    if (!missing(order.by))
        out <- out[order(out[[order.by]], decreasing=decreasing), ]
    if (head)
        out <- head(out, n)
    out
}
# shorthand
lsos <- function(..., n=10) {
    .ls.objects(..., order.by="Size", decreasing=TRUE, head=TRUE, n=n)
}




## m=matrix(data=sample(rnorm(100,mean=0,sd=2)), ncol=10)
## this function makes a graphically appealing heatmap (no dendrogram) using ggplot
## whilst it contains fewer options than gplots::heatmap.2 I prefer its style and flexibility
 
ggheat=function(m, rescaling='none', clustering='none', labCol=T, labRow=T, border=FALSE, heatscale= c(low='blue',high='red'))
{
  ## the function can be be viewed as a two step process
  ## 1. using the rehape package and other funcs the data is clustered, scaled, and reshaped
  ## using simple options or by a user supplied function
  ## 2. with the now resahped data the plot, the chosen labels and plot style are built
 
  require(reshape)
  require(ggplot2)
 
  ## you can either scale by row or column not both! 
  ## if you wish to scale by both or use a differen scale method then simply supply a scale
  ## function instead NB scale is a base funct
 
  if(is.function(rescaling))
  { 
    m=rescaling(m)
  } 
  else 
  {
    if(rescaling=='column') 
      m=scale(m, center=T)
    if(rescaling=='row') 
      m=t(scale(t(m),center=T))
  }
 
  ## I have supplied the default cluster and euclidean distance- and chose to cluster after scaling
  ## if you want a different distance/cluster method-- or to cluster and then scale
  ## then you can supply a custom function 
 
  if(is.function(clustering)) 
  {
    m=clustering(m)
  }else
  {
  if(clustering=='row')
    m=m[hclust(dist(m))$order, ]
  if(clustering=='column')  
    m=m[,hclust(dist(t(m)))$order]
  if(clustering=='both')
    m=m[hclust(dist(m))$order ,hclust(dist(t(m)))$order]
  }
	## this is just reshaping into a ggplot format matrix and making a ggplot layer
 
  rows=dim(m)[1]
  cols=dim(m)[2]
  melt.m=cbind(rowInd=rep(1:rows, times=cols), colInd=rep(1:cols, each=rows) ,melt(m))
	g=ggplot(data=melt.m)
 
  ## add the heat tiles with or without a white border for clarity
 
  if(border==TRUE)
    g2=g+geom_rect(aes(xmin=colInd-1,xmax=colInd,ymin=rowInd-1,ymax=rowInd, fill=value),colour='white')
  if(border==FALSE)
    g2=g+geom_rect(aes(xmin=colInd-1,xmax=colInd,ymin=rowInd-1,ymax=rowInd, fill=value))
 
  ## add axis labels either supplied or from the colnames rownames of the matrix
 
  if(labCol==T) 
    g2=g2+scale_x_continuous(breaks=(1:cols)-0.5, labels=colnames(m))
  if(labCol==F) 
    g2=g2+scale_x_continuous(breaks=(1:cols)-0.5, labels=rep('',cols))
 
  if(labRow==T) 
    g2=g2+scale_y_continuous(breaks=(1:rows)-0.5, labels=rownames(m))	
	if(labRow==F) 
    g2=g2+scale_y_continuous(breaks=(1:rows)-0.5, labels=rep('',rows))	
 
  ## get rid of grey panel background and gridlines
 
  g2=g2+opts(panel.grid.minor=theme_line(colour=NA), panel.grid.major=theme_line(colour=NA),
  panel.background=theme_rect(fill=NA, colour=NA))
 
  ## finally add the fill colour ramp of your choice (default is blue to red)-- and return
  return(g2+scale_fill_continuous("", heatscale[1], heatscale[2]))
 
}
 
  ## NB because ggheat returns an ordinary ggplot you can add ggplot tweaks post-production e.g. 
  ## data(mtcars)
  ## x= as.matrix(mtcars)
  ## ggheat(x, clustCol=T)+ opts(panel.background=theme_rect(fill='pink'))

