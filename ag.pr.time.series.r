##Script to plot time series of frost free days for Vancouver Intl.

library(ncdf4)
library(PCICt)
library(rgdal)
library(rgeos)
library(zoo)
library(scales)


source('/storage/data/projects/rci/stat.downscaling/bccaq2/code/new.netcdf.calendar.R',chdir=T)
source('/storage/data/projects/rci/bcgov/moti/nrcan-precip_case_studies/code/moti.climdex.robjects.r',chdir=T)

read.gcm.data <- function(gcm.list,scenario,type,season,region) {
  if (type=='ann') {
    read.dir <- paste0('/storage/data/climate/downscale/BCCAQ2+PRISM/high_res_downscaling/bccaq_gcm_bc_subset/',scenario,'/annual/')
  }
  if (type=='seas') {
    read.dir <- paste0('/storage/data/climate/downscale/BCCAQ2+PRISM/high_res_downscaling/bccaq_gcm_bc_subset/',scenario,'/seasonal/')
  }

  clip.shp <- readOGR(paste0('/storage/data/projects/rci/data/assessments/shapefiles/',region,'/'),region, stringsAsFactors=F)
  data <- matrix(NA,nrow=150,ncol=length(gcm.list))
        
  for (g in seq_along(gcm.list)) {
    gcm <- gcm.list[g]
    pr.files <- list.files(path=paste0(read.dir,gcm),pattern=paste0('pr_',type,'_'),full.name=TRUE)
    pr.past <- pr.files[grep('1951-2000',pr.files)]
    pr.proj <- pr.files[grep('2001-2100',pr.files)]

    pr.past <- gcm.netcdf.climatologies(pr.past,'pr',gcm,NULL,clip.shp)
    pr.proj <- gcm.netcdf.climatologies(pr.proj,'pr',gcm,NULL,clip.shp)

    past.series <- apply(pr.past,2,mean,na.rm=T)
    proj.series <- apply(pr.proj,2,mean,na.rm=T)

    if (type=='ann') {
      full.series <- c(past.series[1:50],proj.series[1:100])
      full.anoms <- (full.series - mean(full.series[21:50]))  / mean(full.series[21:50]) * 100
    } 
    if (type=='seas') {
      full.series <- c(past.series[1:200],proj.series[1:400])
      seas.ix <- switch(season,winter=1,spring=2,summer=3,fall=4)
      full.matrix <- matrix(full.series,150,4,byrow=T)
      full.anoms <- (full.matrix[,seas.ix] - mean(full.matrix[21:50,seas.ix])) / mean(full.matrix[21:50,seas.ix]) *100 
    }

    data[,g] <- full.anoms

  }
  
  return(data)
}

##---------------------------------------------------------------------
##PCDS Data

area <- 'ALBERNI-CLAYOQUOT' ##'CENTRAL' ##
area.title <- 'Alberni-Clayoquot' ##'Central Interior' ##
##regions <- list(c('BULKLEY-NECHAKO','0.6'),c('FRASER-FORT GEORGE','0.4'))
regions <- list(c('ALBERNI-CLAYOQUOT','1'))  ##list(c('CENTRAL KOOTENAY','0.39'),c('EAST KOOTENAY','0.47'),c('KOOTENAY BOUNDARY','0.14'))

seasons <- 'annual' ##c('winter','spring','summer','fall') ##'annual' ##
season.titles <- 'Annual' ##c('Winter','Spring','Summer','Fall') ##'Annual' ##
type <- 'ann' ##'seas' 

for (s in seq_along(seasons)) {
  season <- seasons[s]
  season.title <- season.titles[s]
  obs.dir <- paste0('/storage/data/projects/rci/data/assessments/bc/pcds/',season,'/')

  obs.data <- read.csv(paste0(obs.dir,season,'_ppt_anoms_tseries_0017_',regions[[1]][1],'.csv'),header=TRUE,as.is=TRUE)
  obs.years <- obs.data[,1]

  pr.anoms <- matrix(0,nrow=length(obs.years),ncol=length(regions))

  for (i in seq_along(regions)) {
    obs.pr <- read.csv(paste0(obs.dir,season,'_ppt_anoms_tseries_0017_',regions[[i]][1],'.csv'),header=TRUE,as.is=TRUE)
    pr.anoms[,i] <- obs.pr[,3]*as.numeric(regions[[i]][2])*100 ##To convert relative anomalies into percent change
  }

  obs.anoms <- apply(pr.anoms,1,sum)
  obs.anoms <- obs.anoms ##- mean(obs.anoms[72:101])

  rcp26.list <- c('CanESM2','CCSM4','CNRM-CM5','CSIRO-Mk3-6-0','GFDL-ESM2G','HadGEM2-ES','MIROC5','MPI-ESM-LR','MRI-CGCM3')
  rcp45.list <- c('ACCESS1-0','CanESM2','CCSM4','CNRM-CM5','CSIRO-Mk3-6-0','GFDL-ESM2G','HadGEM2-CC','HadGEM2-ES','inmcm4','MIROC5','MPI-ESM-LR','MRI-CGCM3')
  rcp85.list <- c('ACCESS1-0','CanESM2','CCSM4','CNRM-CM5','CSIRO-Mk3-6-0','GFDL-ESM2G','HadGEM2-CC','HadGEM2-ES','inmcm4','MIROC5','MPI-ESM-LR','MRI-CGCM3')

  rcp26.data <- read.gcm.data(rcp26.list,'rcp26',type,season,tolower(area))
  rcp45.data <- read.gcm.data(rcp45.list,'rcp45',type,season,tolower(area))
  rcp85.data <- read.gcm.data(rcp85.list,'rcp85',type,season,tolower(area))

  save(rcp26.data,file=paste0('/storage/data/projects/rci/data/assessments/bc/pcds/data_files/pr.',tolower(area),'.',season,'.rcp26.gcm.RData'))
  save(rcp45.data,file=paste0('/storage/data/projects/rci/data/assessments/bc/pcds/data_files/pr.',tolower(area),'.',season,'.rcp45.gcm.RData'))
  save(rcp85.data,file=paste0('/storage/data/projects/rci/data/assessments/bc/pcds/data_files/pr.',tolower(area),'.',season,'.rcp85.gcm.RData'))

  ##load(paste0('/storage/data/projects/rci/data/assessments/bc/pcds/data_files/pr.',tolower(area),'.',season,'.rcp26.gcm.RData'))
  ##load(paste0('/storage/data/projects/rci/data/assessments/bc/pcds/data_files/pr.',tolower(area),'.',season,'.rcp45.gcm.RData'))
  ##load(paste0('/storage/data/projects/rci/data/assessments/bc/pcds/data_files/pr.',tolower(area),'.',season,'.rcp85.gcm.RData'))

  rcp26.series <- apply(rcp26.data,1,mean,na.rm=T)
  rcp45.series <- apply(rcp45.data,1,mean,na.rm=T)
  rcp85.series <- apply(rcp85.data,1,mean,na.rm=T)

  
  ix <- 52:140
  px <- 1:52
  rx <- 11
  yrs <- 2007:2095
  hys <- 1956:2007

  rcp26.mean <- rollmean(rcp26.series,rx)
  rcp45.mean <- rollmean(rcp45.series,rx)
  rcp85.mean <- rollmean(rcp85.series,rx)

  hist.90 <- rollmean(apply(rcp45.data,1,quantile,0.9,na.rm=T),rx)[px]
  hist.10 <- rollmean(apply(rcp45.data,1,quantile,0.1,na.rm=T),rx)[px]

  rcp26.90 <- rollmean(apply(rcp26.data,1,quantile,0.9),rx)[ix]
  rcp26.10 <- rollmean(apply(rcp26.data,1,quantile,0.1),rx)[ix]

  rcp45.90 <- rollmean(apply(rcp45.data,1,quantile,0.9,na.rm=T),rx)[ix]
  rcp45.10 <- rollmean(apply(rcp45.data,1,quantile,0.1,na.rm=T),rx)[ix]
  rcp85.90 <- rollmean(apply(rcp85.data,1,quantile,0.9,na.rm=T),rx)[ix]
  rcp85.10 <- rollmean(apply(rcp85.data,1,quantile,0.1,na.rm=T),rx)[ix]

  plot.dir <- '/storage/data/projects/rci/data/assessments/bc/'
  plot.file <- paste0(plot.dir,tolower(area),'.',season,'.pr.2017.png')

  png(plot.file,width=1200,height=900)
  par(mar=c(5,5,5,3))
  plot(1951:2100,rcp45.series,type='l',lwd=4,col='white',ylim=c(-45,45.0),xlim=c(1950,2095),
  main=paste0(season.title,' Average Precipitation Anomalies in ',area.title),xlab='Year',ylab='Precipitation Change (%)',
  cex.axis=2,cex.lab=2,cex.main=2.5)

  polygon(c(yrs,rev(yrs)),c(rcp85.10,rev(rcp85.90)),col=alpha('blue',0.3),border=alpha('blue',0.2))
  polygon(c(yrs,rev(yrs)),c(rcp45.10,rev(rcp45.90)),col=alpha('green',0.3),border=alpha('green',0.2))
  polygon(c(yrs,rev(yrs)),c(rcp26.10,rev(rcp26.90)),col=alpha('yellow',0.3),border=alpha('yellow',0.2))
  polygon(c(hys,rev(hys)),c(hist.10,rev(hist.90)),col=alpha('gray',0.3),border=alpha('gray',0.5))

  lines(yrs,rcp85.mean[ix],lwd=4,col='blue')
  lines(yrs,rcp45.mean[ix],lwd=4,col='green')
  lines(yrs,rcp26.mean[ix],lwd=4,col='yellow')
  lines(hys,rcp45.mean[px],lwd=4,col='darkgray')

  lines(c(1985,2010),rep(mean(rcp45.series[35:60]),2),col='black',lwd=6)

  abline(h=seq(-100,100,10),col='gray',lty=3,lwd=2)

  lines(obs.years,obs.anoms,lwd=4,col='black')

  box(which='plot')
  legend('topleft',legend=c('PCDS','RCP8.5','RCP4.5','RCP2.6'),col=c('black','blue','green','yellow'),cex=2,pch=15)
  dev.off()

}


browser()

rcp26.mean <- rollmean(rcp26.series,11)
rcp45.mean <- rollmean(rcp45.series,11)
rcp85.mean <- rollmean(rcp85.series,11)


plot.file <- paste0(plot.dir,'nfld.annual.tas.smoothed.png')
##png(plot.file,width=900,height=900)
par(mar=c(5,5,5,3))
plot(1955:2095,rcp26.mean,type='l',lwd=4,col='green',ylim=c(0,15),
     main='NFLD Smoothed Annual Average Temperatures',xlab='Year',ylab='TAS (degC)',
     cex.axis=2,cex.lab=2,cex.main=2.5)
lines(1955:2095,rcp45.mean,lwd=4,col='orange')
lines(1955:2094,rcp85.mean,lwd=4,col='red')
abline(h=seq(0,20,5),col='gray',lty=3,lwd=3)
legend('topleft',legend=c('RCP8.5','RCP4.5','RCP2.6'),col=c('red','orange','green'),cex=2,pch=15)
box(which='plot')
##dev.off()
