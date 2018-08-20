##Script to map the downscaled output
library(graticule)

##Plotting script for maps in the BC Albers Projection

##------------------------------------------------------------------------------------------------
##------------------------------------------------------------------------------------------------

convert.to.alb.coords <- function(lon,lat,alb.crs=CRS("+init=epsg:3005")) {
 
  d <- data.frame(lon=lon,lat=lat)
  coordinates(d) <- c('lon','lat')
  proj4string(d) <- CRS("+init=epsg:4326")
  d.albers <- spTransform(d,CRS(alb.crs))
  rv <- d.albers@coords
  return(rv)
}



reg.ds.maps <- function(box.data,region,region.range,box.range,
                        var.name,type,ds.type,region.shp,shp.buffer,
                        plot.file,plot.title,
                        make.plot.window=NULL,
                        set.breaks=NULL,
                        add.overlays=NULL,
                        add.cities=NULL,
                        add.districts=NULL,
                        add.graticules=NULL,
                        leg.loc='topright',width=800,height=800,                        
                        shared.range=NULL,shared.box=NULL,draft=TRUE) { 

  alb.crs <- "+init=epsg:3005"

  box.data <-projectRaster(box.data,crs=CRS(alb.crs))
  bounds <- extent(box.data)

  plot.window <- make.plot.window(bounds)

  white.box <- box.data - box.data
  white.box[is.na(white.box)] <- 0

  map.range <- region.range
  
  if (!is.null(shared.range))
    map.range <- shared.range

  if (!is.null(shared.box))
    box.range <- shared.box

  class.breaks <- get.class.breaks(var.name,type,map.range,manual.breaks='')

  if (!is.null(set.breaks)) {
    old.breaks <- get.class.breaks(var.name,type,map.range,manual.breaks='')
    class.breaks <- set.breaks
    colour.subset <- class.breaks %in% old.breaks
    colour.ramp <- get.legend.colourbar(var.name=var.name,map.range=map.range,
                                        my.bp=0,class.breaks=class.breaks,
                                        type)    
  } else {
    class.breaks <- get.class.breaks(var.name,type,map.range,manual.breaks='')
    colour.ramp <- get.legend.colourbar(var.name=var.name,map.range=map.range,
                                        my.bp=0,class.breaks=class.breaks,
                                        type)    
  }

  map.class.breaks.labels <- get.class.break.labels(class.breaks)

  ##------------------------------------------------------------------------------------------------
  ##Fix the colour.ramp to include greater or less than breaks for the bounding
  ##box if needed
  ##Both
  ##Note: for ranges that are very narrow (i.e. 1 unit or less) or box.ranges and map.ranges that are very close, this
  ##doesn't work as well. The legend repeats intervals as this gets rounded similar values.
  if ((box.range[1] < map.range[1]) & (box.range[2] > map.range[2]) & (class.breaks[1] != 0)) {
    dx <- diff(class.breaks)[1]
    class.breaks <- c(floor(box.range[1]/dx)*dx,class.breaks,ceiling(box.range[2]/dx)*dx)
    colour.ramp <- get.legend.colourbar(var.name=var.name,map.range=box.range,
                                        my.bp=0,class.breaks=class.breaks,
                                        type)        
    map.class.breaks.labels <- get.class.break.labels(class.breaks,lesser.sign=TRUE,greater.sign=TRUE)
  } else {  
    ##Greater than
    if (box.range[2] > map.range[2]) {
      dx <- diff(class.breaks)[1]
      class.breaks <- c(class.breaks,ceiling(box.range[2]/dx)*dx)
      colour.ramp <- get.legend.colourbar(var.name=var.name,map.range=box.range,
                                          my.bp=0,class.breaks=class.breaks,
                                          type)        
      map.class.breaks.labels <- get.class.break.labels(class.breaks,greater.sign=TRUE)
    }
    ##Less than
    if ((box.range[1] < map.range[1]) & (class.breaks[1] !=0) ) {
      dx <- diff(class.breaks)[1]
      class.breaks <- c(floor(box.range[1]/dx)*dx,class.breaks)
      colour.ramp <- get.legend.colourbar(var.name=var.name,map.range=box.range,
                                          my.bp=0,class.breaks=class.breaks,
                                          type)        
      map.class.breaks.labels <- get.class.break.labels(class.breaks,lesser.sign=TRUE)

    }
  }

  map.class.breaks.labels <- get.class.break.labels(class.breaks,lesser.sign=FALSE,greater.sign=TRUE)
  colour.ramp <- get.legend.colourbar(var.name=var.name,map.range=box.range,
                                      my.bp=0,class.breaks=class.breaks,
                                      type)        

  map.class.breaks.labels <- rev(map.class.breaks.labels)
  class.breaks <- rev(class.breaks)
  colour.ramp < rev(colour.ramp)

  grats <- add.gratucules(alb.crs)

  ##------------------------------------------------------------------------------------------------

  ##Set up plot image
  png(file=plot.file,width=width,height=height,bg='gray94')
  par(mar=c(6,6,7,6))    
  plot(c(),xlim=plot.window$xlim,ylim=plot.window$ylim,xaxs='i',yaxs='i',
     bg='lightgray',axes=FALSE,
       xlab='Longitude (\u00B0E)',ylab='Latitude (\u00B0N)',main=plot.title,
       cex.axis=2,cex.lab=2,cex.main=2.1)
  axis(1,at=unclass(grats$labs@coords)[1:7,1],label=grats$lons,cex.axis=2)  
  axis(2,at=unclass(grats$labs@coords)[8:14,2],label=grats$lats,cex.axis=2)  

  rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col='lightgray')
  
  ##First plot the entire rectangular region with lighter transparency
  image(box.data, col=colour.ramp,breaks=class.breaks,xlim=plot.window.xlim, ylim=plot.window.ylim, add=TRUE)   

  ##-------------------------------------------------------------------------------------------------

  ##Add the region overlays to plot 
  ##Overlays common to all regions    

  shape.dir <- '/storage/data/projects/rci/data/assessments/shapefiles/bc_common/'

  bc.overlay <- 'h_land_WGS84'
  coast.overlay <- 'west_coast_ocean'
  rivers.overlay <- 'h_rivers_WGS84'
  us.overlay <- 'pnw_us_wgs84'
  bc.shp <- readOGR(shape.dir, bc.overlay, stringsAsFactors=F, verbose=F)
  coast.shp <- readOGR(shape.dir, coast.overlay, stringsAsFactors=F, verbose=F)
  us.shp <- readOGR(shape.dir,us.overlay,stringsAsFactors=F, verbose=F)
  rivers.shp <- readOGR(shape.dir,rivers.overlay,stringsAsFactors=F, verbose=F)

  plot(spTransform(coast.shp,CRS(alb.crs)),add=TRUE,col='lightgray')                
  plot(spTransform(us.shp,CRS(alb.crs)),add=TRUE,col='gray')
  plot(spTransform(bc.shp,CRS(alb.crs)),add=TRUE)
##plot(spTransform(rivers.shp,CRS(alb.crs)),add=TRUE,col='lightblue')

  ##Plot additional overlays if necessay
  add.plot.overlays(crs)

  ##Add the lon/lat lines
  plot(grats$grat,add=TRUE,lty=3,col='gray')

  if (draft) {
    text(x = grconvertX(0.5, from = "npc"),  # align to center of plot X axis
         y = grconvertY(0.5, from = "npc"), # align to center of plot Y axis
         labels = "DRAFT", # our watermark
         cex = 10, font = 2, # large, bold font - hard to miss
         col = rgb(1, 1, 1, .4), # translucent (0.2 = 20%) red color
         srt = 45) # srt = angle of text: 45 degree angle to X axis
  }
  
  ##------------------------------------------------------ 

  my.label.units <- leg.label.units(var.name,type)

  ##Functions to add city and regional district lines
  add.cities(crs)
  add.districts(crs)

  par(xpd=NA)
  legend(leg.loc, col = "black", legend=map.class.breaks.labels, pch=22, pt.bg = rev(colour.ramp),
         pt.cex=2.0, y.intersp=0.8, title.adj=0.2, title=my.label.units, xjust=0, cex=1.7)

  box(which='plot',lwd=3)

  dev.off()


}
##-------------------------------------------------------


   
