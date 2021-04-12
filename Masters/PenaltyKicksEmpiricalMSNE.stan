
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
  matrix<lower = 0,upper=1>[3,3] U;
  
  U = [[PL,piL,piL],[mu,muC,mu],[piR,piR,PR]];
}

model {
  
  for (rr in 1:3) {
    for (cc in 1:3) {
      SCORED[rr,cc] ~ binomial(COUNTS[rr,cc],U[rr,cc]);
    }
  }
}

generated quantities {
  vector[3] pKicker;
  vector[3] pKeeper;
  
  pKeeper = U\([1,1,1]') / sum(U\([1,1,1]'));
  pKicker = (1.0-U)'\([1,1,1]') / sum((1.0-U)'\([1,1,1]'));
}

