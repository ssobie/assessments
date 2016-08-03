##Script to map the downscaled output

##Copied from precip.scale.mapping.r and is meant to be a script that
##creates better maps specifically for the BC resource regions.

##----------------------------------------------------------------------

make.fixed.colour.ramps <- function(var.type) {

  ##Annual Precipitation
  pr.ramp <- c(rgb(11,44,122,maxColorValue=256),
               rgb(30,144,148,maxColorValue=256),
               rgb(14,196,65,maxColorValue=256),
               rgb(123,237,0,maxColorValue=256),
               rgb(247,215,7,maxColorValue=256),
               rgb(230,142,28,maxColorValue=256),
               rgb(194,82,60,maxColorValue=256))
  
  temp.ramp <- c(rgb(214,47,39,maxColorValue=256),
                 rgb(237,117,81,maxColorValue=256),
                 rgb(250,185,132,maxColorValue=256),
                 rgb(255,255,191,maxColorValue=256),
                 rgb(192,204,190,maxColorValue=256),
                 rgb(132,158,186,maxColorValue=256),
                 rgb(69,117,181,maxColorValue=256))

  colour.ramp <- switch(var.type,
                        pr=pr.ramp,
                        temp=temp.ramp,
                        fd=temp.ramp)
  
  return(colour.ramp)
  
}
 
##------------------------------------------------------------------------------------------------
##------------------------------------------------------------------------------------------------
##------------------------------------------------------------------------------------------------

reg.ds.maps <- function(data,box.data,region,
                        type,ds.type,region.shp,shp.buffer,
                        plot.file,plot.title,
                        coords=NULL,set.breaks=NULL,proj,
                        overlays=NULL,
                        leg.loc='topright',width=1100,height=900,
                        shared.range=NULL,shared.box=NULL,draft=TRUE) { ##width=1000,height=800) {

  data <- unclass(data)

  ##----------------------------------
  ##One way to reproject the data
  if (1==0) {
    test <- data.frame(x=attr(data,'spatial.coords')[,1],y=attr(data,'spatial.coords')[,2],z=as.numeric(data))
    spg <- test
    coordinates(spg) <- ~x+y
    gridded(spg) <- TRUE
    ras <- raster(spg)
    ras@crs <- CRS("+init=epsg:4326")
    my.raster <- projectRaster(ras,crs=("+init=epsg:4326"))
  }

  ##Previous version for raster
  p4s <- attr(data, "p4s")
  spatial.coords <- attr(data, "spatial.coords")
  my.raster <- SpatialPixelsDataFrame(points=SpatialPoints(spatial.coords, proj4string=CRS(p4s)),
                                      data=data.frame(data),tolerance=5e-05)
  my.raster <- as(my.raster, "SpatialGridDataFrame") 

  bounds <- extent(my.raster)
  xlim.min <- bounds@xmin
  xlim.max <- bounds@xmax
  ylim.min <- bounds@ymin
  ylim.max <- bounds@ymax

  white.box <- box.data - box.data
  white.box[is.na(white.box)] <- 0
  
  ##p <- as(my.raster,'SpatialPixels')
  ##a <- convert.albers.to.lat.lon(p@coords[1,1],p@coords[1,2])

  ##This is now plottable
  ##----------------------------------  
  
  ##Metadata
  var.name <- attr(data, "var.name")
  gcm.name <- attr(data, "gcm")
  rcm.name <- attr(data, "rcm")
  p4s <- attr(data, "p4s")
  spatial.coords <- attr(data, "spatial.coords")

  ##Old Raster method for Lat/Lon grid (before projecting to Albers)
  ##Set up raster
  ##  my.raster <- SpatialPixelsDataFrame(points=SpatialPoints(spatial.coords, proj4string=CRS(p4s)),
  ##                                      data=data.frame(data),tolerance=1e-06)
  ##  my.raster <- as(my.raster, "SpatialGridDataFrame")

  ##  xlim.min <- my.raster@bbox[1,1]
  ##  xlim.max <- my.raster@bbox[1,2]
  ##  ylim.min <- my.raster@bbox[2,1]
  ##  ylim.max <- my.raster@bbox[2,2] 
  
  ##Set plot boundaries
  xlim.adj <- (xlim.max - xlim.min) * 0.035 ##0.025
  ylim.adj <- (ylim.max - ylim.min) * 0.035 ##0.025 

  plot.window.xlim <- c((xlim.min - xlim.adj), (xlim.max + xlim.adj))
  plot.window.ylim <- c((ylim.min - ylim.adj), (ylim.max + ylim.adj))

  if (region=='northeast' | region=='skeena')
    plot.window.ylim <- c((ylim.min - ylim.adj), (ylim.max + ylim.adj*0.25))
  ##if (region=='thompson' | region=='kootenay')
  ##  plot.window.ylim <- c((ylim.min - ylim.adj*0.25), (ylim.max + ylim.adj))
  if (region=='kootenay' | region=='south' | region=='thompson')
    plot.window.ylim <- c((ylim.min - ylim.adj*0.25), (ylim.max + ylim.adj))
  if (region=='cariboo')
    plot.window.xlim <- c((xlim.min - xlim.adj), (xlim.max + xlim.adj*8))
  if (region=='metro_van_lower_fraser') {
    plot.window.xlim <- c((xlim.min - xlim.adj*1), (xlim.max + xlim.adj*1))
    plot.window.ylim <- c((ylim.min - ylim.adj), (ylim.max + ylim.adj*1))
  }
  e <- extent(c(plot.window.xlim,plot.window.ylim))
  #e <- extent(c(-123.5,-121.680,48.99602,49.90))
  #plot.window.xlim <- c(-123.5,-121.680)
  #plot.window.ylim <- c(48.99602,49.90)
  ##Set breakpoints for colour ramp
  
  map.range <- range(my.raster@data,na.rm=TRUE) ##range(my.raster@data@values,na.rm=TRUE) ##Added "@values" for the reprojected raster
  box.range <- range(box.data@data@values,na.rm=TRUE)
  print(map.range)
  
  if (!is.null(shared.range))
    map.range <- shared.range
  class.breaks <- get.class.breaks(var.name,type,map.range,manual.breaks='')

  if (!is.null(shared.box))
    box.range <- shared.box


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
  print(map.class.breaks.labels)

  ##------------------------------------------------------------------------------------------------
  ##Fix the colour.ramp to include greater or less than breaks for the bounding
  ##box if needed
  ##Both
  ##Note: for ranges that are very narrow (i.e. 1 unit or less) or box.ranges and map.ranges that are very close, this
  ##doesn't work as well. The legend repeats intervals as this gets rounded similar values.
  if ((box.range[1] < map.range[1]) & (box.range[2] > map.range[2])) {
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
    if (box.range[1] < map.range[1]) {
      dx <- diff(class.breaks)[1]
      class.breaks <- c(floor(box.range[1]/dx)*dx,class.breaks)
      colour.ramp <- get.legend.colourbar(var.name=var.name,map.range=box.range,
                                          my.bp=0,class.breaks=class.breaks,
                                          type)        
      map.class.breaks.labels <- get.class.break.labels(class.breaks,lesser.sign=TRUE)
    }
  }

##  class.breaks <- c(800,1000,1200,1400,1600,1800,2000,3000,3400,3800,4000,4200,4400,6000) ##Metro Van prism precip
##  class.breaks <- c(0,seq(6,12,by=1.5),12.5,13,13.5,14,14.5,15) ##Metro Van prism tasmax
##  class.breaks <- c(-6,seq(-3,4.5,by=1.5),5,5.5,6,6.5,7,10)
##  class.breaks <- c(0,seq(110,180,by=5),1000)
##  class.breaks <- c(0,seq(100,200,by=10),300,400,500,1000)
  if (var.name=='snowdepth' & !grepl('(anomaly|percent)',type)) {
    class.breaks <- c(0,0.5,1,2,3,4,6,8,10) ##10,1000)
    map.class.breaks.labels <- get.class.break.labels(class.breaks,greater.sign=TRUE,lesser.sign=FALSE)
  } else if (var.name=='snowdepth' & grepl('(anomaly)',type)) {
    class.breaks <- c(-10,-5,-4,-3,-2,-1,-0.5,-0.4,-0.3,-0.2,-0.1,0)
    map.class.breaks.labels <- get.class.break.labels(class.breaks,greater.sign=FALSE,lesser.sign=TRUE)
  } else if (var.name=='snowdepth' & grepl('(percent)',type)) {
    ##class.breaks <- c(-1000,-5,-4,-3,-2,-1,-0.5,-0.4,-0.3,-0.2,-0.1,0)
    class.breaks <- c(-110,-90,-80,-70,-60,-40,-20,-10,0)
    map.class.breaks.labels <- get.class.break.labels(class.breaks,greater.sign=FALSE,lesser.sign=TRUE)    
##    browser()
  } else {
##    map.class.breaks.labels <- get.class.break.labels(class.breaks,greater.sign=TRUE,lesser.sign=TRUE)
  } 
  colour.ramp <- get.legend.colourbar(var.name=var.name,map.range=box.range,
                                      my.bp=0,class.breaks=class.breaks,
                                      type)        
  if (var.name=='snowdepth') {
    colour.ramp <- c(colour.ramp,'#FFFFFF')
    class.breaks <- c(class.breaks,1000)
  }
  ##colour.ramp <- rev(make.fixed.colour.ramps('temp'))
  ##class.breaks <- c(14000,6600,3200,1600,1000,700,500,0) ##For Annual Precipitation
  ##class.breaks <- c(200,90,80,70,60,50,40,0) ##For Precip Return periods (tentative)
  ##class.breaks <- c(100,40,36,32,28,24,22,0) ##Tasmax Return Periods
  ##class.breaks <- c(0,-36,-40,-44,-48,-52,-56,-100) ##Tasmin Return Periods
  ##class.breaks <- c(500,240,200,160,120,80,40,0) ##R95 Precipitation
  ##class.breaks <- c(40,18,16,14,12,10,8,0) ##RX1Day Precipitation
  ##class.breaks <- c(360,300,250,200,150,100,50,0) ##Frost Free Days
  ##class.breaks <- c(50,45,40,35,30,20,10,0) ##TX90p
  ##class.breaks <- c(50,45,40,35,30,20,10,0) ##TN10p Precipitation
  
  ##print('Class Labels')
  ##map.class.breaks.labels <- get.class.break.labels(class.breaks,lesser.sign=FALSE,greater.sign=FALSE)

  ##------------------------------------------------------------------------------------------------

  ##Set up plot image
  png(file=plot.file,width=width,height=height,bg='gray94') ##,width=500,height=1100,bg='white')
  par(mar=c(6,6,7,6))    
  plot(c(),xlim=plot.window.xlim,ylim=plot.window.ylim,xaxs='i',yaxs='i',
     bg='white',
       xlab='Longitude (\u00B0E)',ylab='Latitude (\u00B0N)',main=plot.title,
       cex.axis=2,cex.lab=2,cex.main=2.2)
  ##plot(c(),xlim=plot.window.xlim,ylim=plot.window.ylim,xaxs='i',yaxs='i',
  ##     bg='lightgray',
  ##     xlab='',ylab='',main=plot.title,
  ##     cex.axis=2,cex.lab=2,cex.main=2.2,axes=FALSE)
  
  rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col='lightsteelblue')
  
  ##First plot the entire rectangular region with lighter transparency
##  if (var.name=='snowdepth') {
##    image(white.box, col='white',breaks=c(0,1),ribbon=FALSE,xlim=plot.window.xlim, ylim=plot.window.ylim, add=TRUE)
##  }

  ##First plot the entire rectangular region with lighter transparency
  image(box.data, col=colour.ramp,breaks=class.breaks,ribbon=FALSE,xlim=plot.window.xlim, ylim=plot.window.ylim, add=TRUE,alpha=0.3)   
  ##Add the baselayers for the plot box
  bc.roads <- spTransform(get.region.shape('bc_hwy_geo','/storage/data/gis/basedata/BC_Roads/'),CRS(proj))
  city.dir <- '/storage/data/gis/basedata/BC_Cities/' ##'/home/data/projects/rci/data/forestry/regional_summaries/shapefiles/'
  bc.cities <- spTransform(get.region.shape('bcmjcities_bc',city.dir),CRS(proj)) ## mjrcities2
  whistler.dir <- '/storage/data/projects/rci/data/assessments/whistler/shapefiles/'
  callaghan.rd <- spTransform(get.region.shape('callaghan_valley_road',whistler.dir),CRS(proj)) ## mjrcities2

  pos <- get.region.text.loc(region)

  ##Cover the extra area to diminish its effect
  ##rect(region.shp@bbox[1,1],region.shp@bbox[2,1],region.shp@bbox[1,2],region.shp@bbox[2,2],col="#D3D3D378")
  ##rect(plot.window.xlim[1],plot.window.ylim[1],plot.window.xlim[2],plot.window.ylim[2],col="#D3D3D34B")

  ##Add the region raster data
  image(my.raster, col=colour.ramp,breaks=class.breaks,ribbon=FALSE,xlim=plot.window.xlim, ylim=plot.window.ylim, add=TRUE)  

  ##-------------------------------------------------------------------------------------------------
  ##Add the region overlays to plot
  
  ##Overlays common to all regions    
  bc.overlay <- 'h_land_WGS84'
  coast.overlay <- 'h_coast_WGS84'
  shape.dir <- '/storage/data/projects/rci/data/moti/nrcan-precip_case_studies/moti_shapefiles/'
  bc.shp <- readOGR(shape.dir, bc.overlay, stringsAsFactors=F, verbose=F)
  coast.shp <- readOGR(shape.dir, coast.overlay, stringsAsFactors=F, verbose=F)
  us.shp <- readOGR(shape.dir,'pnw_us_wgs84',stringsAsFactors=F, verbose=F)
  rivers.shp <- readOGR(shape.dir,'h_rivers_WGS84',stringsAsFactors=F, verbose=F)
  lakes.shp <- readOGR('/storage/data/projects/rci/data/assessments/whistler/shapefiles','whistler_lakes',stringsAsFactors=F, verbose=F)
  
  ##plot(spTransform(coast.shp,CRS(proj)),add=TRUE,col='blue')        
  plot(spTransform(us.shp,CRS(proj)),add=TRUE)
  plot(spTransform(bc.shp,CRS(proj)),add=TRUE)
  plot(spTransform(rivers.shp,CRS(proj)),add=TRUE,col='lightblue')
  plot(spTransform(lakes.shp,CRS(proj)),add=TRUE,col='lightblue',border='lightblue')
  lines(callaghan.rd,col='darkgray',lwd=2.5) 
  lines(bc.roads,col='darkgray',lwd=3) 
##  inshuck.shp <- spTransform(readOGR('/home/data/projects/rci/data/forestry/engineering/shapefiles/','inshuck_road',stringsAsFactors=F, verbose=F),CRS(proj))
##  lines(inshuck.shp,col='black',lwd=3)
##  lines(inshuck.shp,col='orange',lwd=2)
##  browser()
  if (!is.null(overlays)) {
    ##for (overlay in overlays)
      plot(spTransform(overlays,CRS(proj)),add=TRUE,lwd=2)
  }

  ##bc.roads.subset <- spTransform(get.intersected.shape(bc.roads,region.shp),CRS(proj))
  ##lines(bc.roads.subset,col='black',lwd=3)
  ##lines(bc.roads.subset,col='yellow',lwd=2)


  ##lines(bc.roads,col='black',lwd=3)
  ##lines(bc.roads,col='yellow',lwd=2)

  plot(spTransform(region.shp,CRS(proj)),add=TRUE,lwd=2)
  plot(shp.buffer[[1]],lwd=0.75,add=TRUE)
  plot(shp.buffer[[2]],lwd=0.5,add=TRUE)
  plot(shp.buffer[[3]],lwd=0.25,add=TRUE)
  plot(shp.buffer[[4]],lwd=0.15,add=TRUE)
  plot(shp.buffer[[5]],lwd=0.25,add=TRUE,border='white')


    cx <- -122.95
    cy <- 50.12  
    points(cx,cy,pch=19,cex=2.5,col='black',bg='black')
    shadowtext(cx+0.01,cy-0.01,'Whistler Village',adj=4,pos=4,cex=2,col='black',bg='white',r=0.2)
    
    ##Whistler Mountains
    points(-123.053,50.179,pch=17,cex=2,col='black')
    shadowtext(-123.052,50.177,'Rainbow Mountain',adj=4,pos=4,cex=1.5,col='black',bg='white',r=0.2)
    points(-122.957,50.059,pch=17,cex=2,col='black')
    shadowtext(-122.956,50.057,'Whistler Mountain',adj=4,pos=4,cex=1.5,col='black',bg='white',r=0.2)
    points(-122.870,50.081,pch=17,cex=2,col='black')
    shadowtext(-122.869,50.079,'Blackcomb Mountain',adj=4,pos=4,cex=1.5,col='black',bg='white',r=0.2)

    ##Olympic Park
    points(-123.126,50.130,pch=19,cex=2,col='black')
    shadowtext(-123.125,50.128,'Whistler Olympic\nPark',adj=4,pos=4,cex=1.5,col='black',bg='white',r=0.2)

  if (draft) {
    text(x = grconvertX(0.5, from = "npc"),  # align to center of plot X axis
         y = grconvertY(0.5, from = "npc"), # align to center of plot Y axis
         labels = "DRAFT", # our watermark
         cex = 10, font = 2, # large, bold font - hard to miss
         col = rgb(1, 1, 1, .4), # translucent (0.2 = 20%) red color
         srt = 45) # srt = angle of text: 45 degree angle to X axis
  }
  
  ##------------------------------------------------------
  ##Plot the grid lines
#  v.cell <- my.raster@grid@cellsize[1]
#  h.cell <- my.raster@grid@cellsize[2]
#  abline(v=spatial.coords[,1]+v.cell/2,lty=2,col='black')
#  abline(h=spatial.coords[,2]+h.cell/2,lty=2,col='black')
  ##------------------------------------------------------ 

  my.label.units <- leg.label.units(var.name,type)

  par(xpd=NA)

  legend(leg.loc, col = "black", legend=map.class.breaks.labels, pch=22, pt.bg = (colour.ramp),
         pt.cex=2.0, y.intersp=0.8, title.adj=0.2, title=my.label.units, xjust=0, cex=1.7)

  box(which='plot',lwd=3)

  dev.off()

}
##-------------------------------------------------------


   

