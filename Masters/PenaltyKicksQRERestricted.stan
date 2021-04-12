
functions {
  
  vector TraceQRE(matrix U,real lambda,data matrix A,data matrix B,data real[] lgrid,data int nc,data real ftol) {
  vector[6] lp;
  matrix[6,6] UBoth;
  vector[6] H;
  vector[6] Hl;
  matrix[6,6] Hq;
  
  
  // set up problem so that EU_a = UBoth*exp(lp)
  for (rr in 1:3) {
    UBoth[rr,] = [0,0,0,U[rr,1],U[rr,2],U[rr,3]];
    UBoth[rr+3,] = [1.0-U[1,rr],1.0-U[2,rr],1.0-U[3,rr],0,0,0];
  }
  
  
  // initialization at lambda = 0
    lp = rep_vector(1.0/3.0,6);
    
    for (ll in 2:num_elements(lgrid)) {
      // predictor step
      
      
      Hl[1:4] = -A*UBoth*exp(lp);
      Hl[5:6] = [0,0]';
      Hq = append_row(A*(diag_matrix(rep_vector(1.0,6))-lambda*0.5*(lgrid[ll]+lgrid[ll-1])*UBoth*diag_matrix(exp(lp))), -B*diag_matrix(exp(lp)));
      lp = lp+Hq\Hl*lambda*(lgrid[ll]-lgrid[ll-1]);
      
      // corrector step
      H = append_row(A*(lp-lambda*lgrid[ll]*UBoth*exp(lp)),1-B*exp(lp));
      for (cc in 1:nc) {

        Hq = append_row(A*(diag_matrix(rep_vector(1.0,6))-lambda*0.5*(lgrid[ll]+lgrid[ll-1])*UBoth*diag_matrix(exp(lp))), -B*diag_matrix(exp(lp)));
        lp = lp-Hq\H;
        
        H = append_row(A*(lp-lambda*lgrid[ll]*UBoth*exp(lp)),1-B*exp(lp));
        if (sqrt(sum( H .* H ))<ftol) { // stop if we are close enough
          break;
        }
      }
    }
    return lp;
    
  }
  
  
}

data {
  matrix[3,3] COUNTS;
  matrix[3,3] SCORED;
  int<lower=1> gridsize;
  int<lower=0> nc;
  real priorLambda[2];
  real ftol;
  real priorT[2];
}

transformed data {
  real lgrid[gridsize];
  matrix[4,6] A;
  matrix[2,6] B;
  vector[6] CountVector;
  
  CountVector = append_row((COUNTS*rep_vector(1.0,3)),(COUNTS'*rep_vector(1.0,3)));
  
  for (gg in 1:gridsize) {
    lgrid[gg] = (gg-1.0)/(gridsize-1.0);
  }
  
  A = [[1,0,-1,0,0,0],[0,1,-1,0,0,0],[0,0,0,1,0,-1],[0,0,0,0,1,-1]];
  B = [[1,1,1,0,0,0],[0,0,0,1,1,1]];
  
}

parameters {
  real TpiL;
  real TPL;
  real TpiR;
  real TPR;
  real Tmu;

  real<lower=0> lambda;

}
transformed parameters {
  matrix[3,3] log_lik_payoffs;
  matrix[3,3] U;
  vector[6] lp;
  vector[6] log_lik_decisions;
  
  // imposes assumptions SC SC' and NS, i.e. all except KS
  real<lower=0,upper=1> piL;
  real<lower=0,upper=1> piR;
  real<lower=0,upper=1> PL;
  real<lower=0,upper=1> PR;
  real<lower=0,upper=1> mu;

  piL = Phi_approx(TpiL);
  piR = Phi_approx(TpiR)*piL;
  PL = piL*Phi_approx(TPL);
  PR = PL*Phi_approx(TPR);
  mu = fmin(piR,piL)*Phi_approx(Tmu);
  
  
  U = [[PL,piL,piL],[mu,0,mu],[piR,piR,PR]];
  
  log_lik_payoffs = SCORED .* log(U)+(COUNTS - SCORED) .* log(1-U);
  lp = TraceQRE(U,lambda,A, B,lgrid,nc,ftol);
  log_lik_decisions = CountVector .* lp;
  

  
}

model {
  
  
  
  
  
  
  lambda~lognormal(priorLambda[1],priorLambda[2]);
  
  TpiL~normal(priorT[1],priorT[2]);
  TPL~normal(priorT[1],priorT[2]);
  TpiR~normal(priorT[1],priorT[2]);
  TPR~normal(priorT[1],priorT[2]);
  Tmu~normal(priorT[1],priorT[2]);

  
  target += log_lik_payoffs;
  target += log_lik_decisions;
}

generated quantities {
  
  
  
  
}

