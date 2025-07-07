libname mydata '/home/u62057975/CVD/';

/*------------------------------------------------------------------------------
  Data preparation:
  Create binary variables for cumulative thresholds of the ordinal outcome
  to assess the proportional odds assumption via separate binary mixed models.

  y1 = indicator for outcome >= 1
  y2 = indicator for outcome >= 2
  y3 = indicator for outcome = 3 (highest category)
------------------------------------------------------------------------------*/
data check_PO;
  set mydata.data_cvd;
  y1 = (outcome >= 1);
  y2 = (outcome >= 2);
  y3 = (outcome = 3);
run;

/*------------------------------------------------------------------------------
  Macro: binary_glmm
  Purpose: Fit a generalized linear mixed model (GLMM) with a random intercept
           for the binary outcome specified by &yvar.

  Model details:
  - Distribution: Binomial (logistic regression)
  - Link function: Logit
  - Random effects: Random intercept for subject id to account for within-subject correlation
  - Covariates: visit, female, educ, hei2010, pag2008, depr1, age, alcuse, bmi, smoker
  - Method: Adaptive Gaussian Quadrature with 30 quadrature points for better accuracy

  This macro facilitates fitting separate models for each binary threshold outcome
  to compare predictor effects across outcome levels and assess the proportional
  odds assumption.
------------------------------------------------------------------------------*/
%macro binary_glmm(yvar);
  proc glimmix data=check_PO method=quad(qpoints=30);
    class id female (ref='0') educ (ref='1') depr1 (ref='0') pag2008 (ref='0') alcuse (ref='0') smoker (ref='0') visit (ref='1');
    model &yvar = visit female educ hei2010 pag2008 depr1 age alcuse bmi smoker
          / dist=binomial link=logit solution;
    random intercept / subject=id;
  run;
%mend;

/*------------------------------------------------------------------------------
  Fit binary GLMMs at each threshold to evaluate the consistency of covariate effects
  across the ordinal outcome levels.
------------------------------------------------------------------------------*/
%binary_glmm(y1);  /* Model for outcome >= 1 */

%binary_glmm(y2);  /* Model for outcome >= 2 */

%binary_glmm(y3);  /* Model for outcome = 3 */
