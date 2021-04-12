
data {
  int<lower=0> COUNTS[3,3];
  int<lower=0> SCORED[3,3];
}

parameters {
  real<lower=0,upper=1> PL;
  real<lower=0,upper=1> piL;
  real<lower=0,upper=1> PR;
  real<lower=0,upper=1> piR;
  real<lower=0,upper=1> mu;
  real<lower=0,upper=1> muC;
}

transformed parameters {
  
}

model {
  real loglike;
  
  matrix[3,3] U;
  vector[3] pKicker;
  vector[3] pKeeper;
  
  U = [[PL,piL,piL],[mu,muC,mu],[piR,piR,PR]];

  
  pKeeper = U\([1,1,1]') / sum(U\([1,1,1]'));
  pKicker = (1.0-U)'\([1,1,1]') / sum((1.0-U)'\([1,1,1]'));
  
  loglike = 0;
  for (rr in 1:3) {
    loglike += sum(COUNTS[rr,])*log(pKicker[rr]);
    loglike += sum(COUNTS[,rr])*log(pKeeper[rr]);
  }
  
  target += loglike;
  
  
}

generated quantities {

}

