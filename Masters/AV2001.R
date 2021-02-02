
## wrangle from Matlab
library(R.matlab)
M <- readMat('ECON4-6260/Masters/AV2001.mat')

head(M)

AV2001choices<-cbind(M$female,M$keep)
colnames(AV2001choices)<-c("female","keep1","keep2","keep3","keep4","keep5","keep6","keep7","keep8")

AV2001parameters<-rbind(M$income,M$self,M$other)
rownames(AV2001parameters)<-c("income","pSelf","pOther")

write.csv(AV2001choices,file="ECON4-6260/Masters/AV2001choices.csv")
write.csv(AV2001parameters,file="ECON4-6260/Masters/AV2001parameters.csv")
