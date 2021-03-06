##Plotting script for the Kootenay Regional Districts

##------------------------------------------------------------------------------------------------
##------------------------------------------------------------------------------------------------

get.projection <- function(region) {
  return("+init=epsg:3005")
}

get.region.title <- function(region) {
  return('Northeast')
}

get.region.names <- function(region) {
  return(list(area='northeast',subset='northeast',region='northeast'))
}

get.leg.loc <- function(region) {
  return('bottomleft')
}

get.crop.box <- function(region) {
  return(c(-128.0,-120.0,54.5,60.0))
}

get.file.type <- function(region) {
  return('.png')
}

get.plot.size <- function(region) {
  return(c(7,7))
}

##Set plot boundaries

make.plot.window <- function(bounds,region.shp) {

  xleft  <- 0.1
  xright <- -0.00
  ybot   <- 0.05
  ytop   <- -0.00

  xlim.min <- bounds@xmin
  xlim.max <- bounds@xmax
  ylim.min <- bounds@ymin
  ylim.max <- bounds@ymax

  ##Set plot boundaries
  xlim.adj <- (xlim.max - xlim.min)
  ylim.adj <- (ylim.max - ylim.min)
  plot.window.xlim <- c((xlim.min + xlim.adj*xleft), (xlim.max + xlim.adj*xright))
  plot.window.ylim <- c((ylim.min + ylim.adj*ybot),  (ylim.max + ylim.adj*ytop))
  rv <- list(xlim=plot.window.xlim,
             ylim=plot.window.ylim)
  return(rv)
}

add.graticules <- function(crs) {   

  lons <- c(-130.0, -128.0, -126.0,-124.0,-122.0,-120.0,-118.0)
  lats <- c(54.0,55.0,56.0,57.0,58.0,59.0,60.0)

  grat <- graticule(lons, lats, proj = CRS(crs))
  labs <- graticule_labels(lons = lons, lats = lats, xline = -129, yline = 54, proj = CRS(crs))

  rv <- list(grat=grat,labs=labs,lons=lons,lats=lats)
  return(rv)
}

##Additional overlays to add specific to the region
add.plot.overlays <- function(crs,region) {
  shape.dir <- '/storage/data/projects/rci/data/assessments/shapefiles/bc_common/'
  bc.shp <- readOGR(shape.dir,'h_land_WGS84',stringsAsFactors=F, verbose=F)

  shape.dir <- '/storage/data/projects/rci/data/assessments/northeast/shapefiles/'
  region.shp <- readOGR(shape.dir,'northeast',stringsAsFactors=F, verbose=F)
  nr.shp <- readOGR(shape.dir,'northern_rockies_muni',stringsAsFactors=F, verbose=F)
  tr.shp <- readOGR(shape.dir,'tumbler_ridge',stringsAsFactors=F, verbose=F)
  us.shp <- readOGR(shape.dir,'pnw_us_wgs84',stringsAsFactors=F, verbose=F)
  coast.shp <- readOGR(shape.dir,'west_coast_ocean',stringsAsFactors=F, verbose=F)

  plot(spTransform(coast.shp,CRS(crs)),add=TRUE,col='lightgray')
  plot(spTransform(us.shp,CRS(crs)),add=TRUE,col='gray')
  plot(spTransform(bc.shp,CRS(crs)),add=TRUE,lwd=1.5)  
  plot(spTransform(region.shp,CRS(crs)),add=TRUE,lwd=3)
  plot(spTransform(nr.shp,CRS(crs)),add=TRUE,lwd=1.5,lty=2)
  plot(spTransform(tr.shp,CRS(crs)),add=TRUE,lwd=1.5,lty=2)

}

add.cities <- function(crs,region) {
  ##Coordinates of cities to plot on the map

  city.coords <- list(
                     list(name='Fort St. John',lon=-120.84773,lat=56.25600,xoffset=-0.00,yoffset=15000,        
                          xline=c(0,-0.05),yline=c(0.0,-0.01)),
                     list(name='Fort Nelson',lon=-122.68722,lat=58.80452,xoffset=0.0,yoffset=-35000,
                          xline=c(0,+0.025),yline=c(0.0,0.009)),
                     list(name='Dawson Creek',lon=-120.23144,lat=55.76058,xoffset=-8000,yoffset=10000,
                          xline=c(0,0.0),yline=c(0.0,-0.02)),   
                     list(name='Chetwynd',lon=-121.62955,lat=55.70771,xoffset=-35000,yoffset=-8000,
                          xline=c(0,0.01),yline=c(0.005,-0.015)),
                     list(name='Pouce Coupe',lon=-120.13359,lat=55.71034,xoffset=-10000,yoffset=-30000,
                          xline=c(0.01,0.0),yline=c(0.00,0.025)))


  for (cc in seq_along(city.coords)) {
      city <- unclass(city.coords[[cc]])
      coords <- convert.to.alb.coords(city$lon,city$lat,alb.crs=crs)
      cx <- coords[1]
      cy <- coords[2]
      xoffset <- city$xoffset
      yoffset <- city$yoffset
      city.name <- city$name
      points(cx,cy,pch=17,cex=1.75,col='black')
      ##lines(city$lon+city$xline,city$lat+city$yline,col='white',lwd=3)
      shadowtext(cx+xoffset,cy+yoffset,city.name,adj=4,pos=3,cex=1.55,col='black',bg='white',r=0.1)
  }
}

add.districts <- function(crs,region) {

  district.coords <- list(
                         list(name='Northern Rockies Regional Municipality',lon=-122.64943,lat=59.40487,size=1.75),
                         list(name='Tumbler Ridge',lon=-121.1,lat=55.4,size=1.75))

  for (dc in seq_along(district.coords)) {
      district <- unclass(district.coords[[dc]])
      coords <- convert.to.alb.coords(district$lon,district$lat,alb.crs=crs)
      cx <- coords[1]
      cy <- coords[2]
      district.name <- district$name      
      text(cx,cy,district.name,font=2,adj=4,pos=1,cex=district$size,col='black',bg='white')
  }
}

get.title.info <- function(crs,plot.title) {
  ##Upper Title
  lower <- FALSE
  title.mar <- c(4.5,4.75,5.2,4)   
  upper.title <- plot.title
  lower.title <- ''

  ##lower <- TRUE
  ##title.mar <- c(6,4.75,4,4)   
  ##upper.title <- ''
  ##lower.title <- gsub('\n','',plot.title) 
  
  rv <- list(lower=lower,
             mar=title.mar,
             upper.title=upper.title,
             lower.title=lower.title)
  return(rv)
}
##-------------------------------------------------------


   

