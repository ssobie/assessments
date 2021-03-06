#!/bin/bash

region='sayward'
title='Sayward'
readloc='vancouver_island' ##'resource_regions/'$region
writeloc='vancouver_island/'$region
echo $writeloc

qsub -N "${region}.tp" -v region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.t.p.wrapper.pbs
qsub -N "${region}.dd" -v region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.dd.wrapper.pbs
qsub -N "${region}.rp5" -v region=$region,title=$title,readloc=$readloc,writeloc=$writeloc,rp="5" run.rp.wrapper.pbs
qsub -N "${region}.rp20" -v region=$region,title=$title,readloc=$readloc,writeloc=$writeloc,rp="20" run.rp.wrapper.pbs
qsub -N "${region}.rp50" -v region=$region,title=$title,readloc=$readloc,writeloc=$writeloc,rp="50" run.rp.wrapper.pbs
qsub -N "${region}.bc" -v region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.build.code.wrapper.pbs

###  climdex.list <- c('idETCCDI','trETCCDI','fdETCCDI',
###                     'txxETCCDI','tnxETCCDI','txnETCCDI','tnnETCCDI','dtrETCCDI',
###                    'rx1dayETCCDI','rx2dayETCCDI','rx5dayETCCDI',
###                    'suETCCDI','su30ETCCDI','gslETCCDI',
###                    'sdiiETCCDI','r10mmETCCDI','r20mmETCCDI','cddETCCDI','cwdETCCDI',
###                    'r95pETCCDI','r99pETCCDI','r95daysETCCDI','r99daysETCCDI',
###                    'prcptotETCCDI')

##qsub -N "cdd90" -v varname='cdd90ETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
##qsub -N "cddmax" -v varname='cddmaxETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs

qsub -N "id" -v varname='idETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "tr" -v varname='trETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "fd" -v varname='fdETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "txx" -v varname='txxETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "tnn" -v varname='tnnETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "tnx" -v varname='tnxETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "txn" -v varname='txnETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "dtr" -v varname='dtrETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "rx1day" -v varname='rx1dayETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "rx2day" -v varname='rx2dayETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "rx5day" -v varname='rx5dayETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "su" -v varname='suETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "su30" -v varname='su30ETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "gsl" -v varname='gslETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "sdii" -v varname='sdiiETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "r10mm" -v varname='r10mmETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "r20mm" -v varname='r20mmETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "cdd" -v varname='cddETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "cwd" -v varname='cwdETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "r95p" -v varname='r95pETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "r99p" -v varname='r99pETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "r95days" -v varname='r95daysETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "r99days" -v varname='r99daysETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
qsub -N "prcptot" -v varname='prcptotETCCDI',region=$region,title=$title,readloc=$readloc,writeloc=$writeloc run.climdex.wrapper.pbs
