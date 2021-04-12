setwd(dirname(sys.frame(1)$ofile))
library(tidyverse)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = 2)

# Source: kaggle.com/mauryashubham/english-premier-league-penalty-dataset-201617
EPL<-(read.csv("penalty_data.csv") 
      %>% tibble()
      %>% mutate(Y = 1*(Scored=="Scored"))
)
EPLcounts<-matrix(0,3,3)
colnames(EPLcounts)<-c("L","C","R")
rownames(EPLcounts)<-c("L","C","R")
EPLscored<-EPLcounts

for (ii in c("L","C","R")) {
  for (jj in c("L","C","R")) {
    EPLcounts[ii,jj]<-dim(EPL %>% filter(Kick_Direction==ii & Keeper_Direction==jj))[1]
    EPLscored[ii,jj]<-dim(EPL %>% filter(Kick_Direction==ii & Keeper_Direction==jj & Scored=="Scored"))[1]
  }
} 

EPLKickerPayoff<-EPLscored/EPLcounts
colnames(EPLKickerPayoff)<-c("l","c","r")
print(EPLKickerPayoff)

## > Azar, Ofer H., and Michael Bar-Eli. "Do soccer players play the mixed-strategy Nash equilibrium?." Applied Economics 43, no. 25 (2011): 3591-3601.

# Counts
ABcounts<-rbind(c(54,1,37),c(41,10,31),c(46,7,59))
#Stopped kicks
ABstopped<-rbind(c(16,0,0),c(4,6,1),c(0,0,15))

ABKickerPayoff<-1-ABstopped/ABcounts
colnames(ABKickerPayoff)<-c("l","c","r")
rownames(ABKickerPayoff)<-c("L","C","R")
print(ABKickerPayoff)

## > Chiappori, P-A., Steven Levitt, and Timothy Groseclose. "Testing mixed-strategy equilibria when players are heterogeneous: The case of penalty kicks in soccer." American Economic Review 92, no. 4 (2002): 1138-1151.

CLGcounts<-t(rbind(c(117,48,95),c(4,3,4),c(85,28,75)))


CLGKickerPayoff<-t(rbind(c(0.632,0.812,0.895),c(1.00,0,1.00),c(0.941,0.893,0.440)))
colnames(CLGKickerPayoff)<-c("l","c","r")
rownames(CLGKickerPayoff)<-c("L","C","R")
print(CLGKickerPayoff)

## Use AB to test data
d<-list(COUNTS = ABcounts,
        SCORED = ABcounts-ABstopped,
        priorLambda = c(log(0.1),1),
        gridsize = 21,
        nc = 10,
        ftol = 1e-7,
        priorT=c(0,1)
        )


FitQRE<-stan("PenaltyKicksQREUnestricted.stan",data=d)
print(FitQRE)

saveRDS(FitQRE,"PenaltyKicksFitUnrestricted.Rds")

#FitQRER<-stan("PenaltyKicksQRERestricted.stan",data=d)
#print(FitQRER)
