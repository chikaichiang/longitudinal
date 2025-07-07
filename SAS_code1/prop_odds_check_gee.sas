libname mydata '/home/u62057975/CVD/';


/* 
  Data Preparation:
  Binary indicator variables corresponding to cumulative thresholds of the ordinal outcome
  are created to facilitate assessment of the proportional odds assumption using GEE. 
  Specifically, y1 indicates outcome ≥ 1, y2 indicates outcome ≥ 2, and y3 indicates 
  membership in the highest category (outcome = 3).
*/
data check_PO;
  set mydata.data_cvd;
  y1 = (outcome >= 1);
  y2 = (outcome >= 2);
  y3 = (outcome = 3);
run;

/*
  Model Specification:
  A macro is defined to fit generalized estimating equations (GEE) logistic regression models
  with an exchangeable working correlation structure to account for within-subject dependence.
  Separate models are fit for each binary threshold outcome to examine the consistency of covariate 
  effects across cumulative levels of the ordinal response, thereby evaluating the proportional odds assumption.
  Covariates include visit number, demographic and clinical predictors, with reference levels specified 
  for categorical variables.
*/
%macro binary_gee(yvar);
  proc genmod data=check_PO descending;
    class id female(ref='0') educ(ref='1') depr1(ref='0') pag2008(ref='0') alcuse(ref='0') smoker(ref='0') visit(ref='1');
    model &yvar = visit female educ hei2010 pag2008 depr1 age alcuse bmi smoker
          / dist=binomial link=logit type3;
    repeated subject=id / type=exch corrw;
  run;
%mend;

/*
  Implementation:
  The macro is executed for each binary outcome representing the ordinal response thresholds.
  Resulting parameter estimates across models are compared to assess the validity of the proportional
  odds assumption in this longitudinal data context.
*/
%binary_gee(y1);
%binary_gee(y2);
%binary_gee(y3);


