
data {
  int<lower=0> COUNTS[3,3];
  int<lower=0> SCORED[3,3];
}

parameters {
  real piLT;
  real PLT;
  real piRT;
  real PRT;
  real muT;

}
transformed parameters {
  real piL = Phi_approx(piLT);
  real PL = piL*Phi_approx(PLT);
  real piR = PL*Phi_approx(piRT);
  real PR = piR*Phi_approx(PRT);
  real mu = Phi_approx(muT)*min([piR,piL,(piL*piR-PL*PR)/(piL+piR-PL-PR)]);
  //real mu = Phi_approx(muT)*piR;
}

model {
  
  piLT~normal(0,1);
  PLT~normal(0,1);
  piRT~normal(0,1);
  PRT~normal(0,1);
  muT~normal(0,1);
  /*
  real loglike;
  
  matrix[3,3] U;
  vector[3] pKicker;
  vector[3] pKeeper;
  
  
  
  U = [[PL,piL,piL],[mu,0.0,mu],[piR,piR,PR]];

  
  pKeeper = U\([1,1,1]') / sum(U\([1,1,1]'));
  pKicker = (1.0-U)'\([1,1,1]') / sum((1.0-U)'\([1,1,1]'));
  
  loglike = 0;
  for (rr in 1:3) {
    loglike += sum(COUNTS[rr,])*log(pKicker[rr]);
    loglike += sum(COUNTS[,rr])*log(pKeeper[rr]);
  }
  
  //target += loglike;
  
  */
}

generated quantities {
  
  matrix[3,3] U;
  vector[3] pKicker;
  vector[3] pKeeper;
  
  /* THE BIG PROBLEM HERE
  It is not always the case that the MSNE involves mixing over all actions.
  When this is the case, solving for MSNE by inverting the matrix gets negative probabilities.
  Not so good. QRE will fix this problem :)
  
  */
  
  U = [[PL,piL,piL],[mu,0.0,mu],[piR,piR,PR]];

  
  pKeeper = (U+5.0)\([1,1,1]') / sum((U+5.0)\([1,1,1]'));
  pKicker = (1.0-U+5.0)'\([1,1,1]') / sum((1.0-U+5.0)'\([1,1,1]'));

}

