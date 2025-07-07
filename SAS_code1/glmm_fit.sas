libname mydata '/home/u62057975/CVD/';

/* 
Macro: fit_multinomial_glmm
Fits a multinomial generalized linear mixed model (GLMM) with a cumulative logit link function using PROC GLIMMIX.
The model accommodates repeated measures or clustered data via subject-specific random intercepts.

Arguments:
- lib:          Library containing the dataset.
- dsn:          Name of the input dataset.
- id:           Subject identifier for clustering.
- outcome:      Ordinal or nominal outcome variable.
- visit:        Repeated-measures time variable (e.g., visit number).
- visit_ref:    Reference category for the visit variable (optional).
- predictors:   List of fixed-effect covariates to include in the model.
- classvars:    List of categorical variables with specified reference levels.
- add_interactions: Logical indicator (YES/NO). If YES, includes visit-by-covariate interactions.
- outlib:       Output library to store results.

This macro supports flexible modeling of time-varying covariate effects via interaction terms and enables specification
of reference levels for both visit and other categorical covariates.
*/

%macro fit_multinomial_glmm(
  lib=,
  dsn=,
  id=,
  outcome=,
  visit=,
  visit_ref=,            /* Reference category for visit; leave blank for default */
  predictors=,
  classvars=,
  add_interactions=YES,  /* Set to NO to exclude visit-by-covariate interactions */
  outlib=work
);

  %local i word inter_terms model_vars visit_class;
  %let i = 1;
  %let word = %scan(&predictors, &i);
  %let inter_terms = ;

  /* Construct interaction terms between visit and each covariate, if requested */
  %if %upcase(&add_interactions) = YES %then %do;
    %do %while(%length(&word));
      %let inter_terms = &inter_terms &visit*&word;
      %let i = %eval(&i + 1);
      %let word = %scan(&predictors, &i);
    %end;
    %let model_vars = &visit &predictors &inter_terms;
  %end;
  %else %do;
    %let model_vars = &visit &predictors;
  %end;

  /* Specify reference level for visit, if provided */
  %if %length(&visit_ref) > 0 %then %do;
    %let visit_class = &visit(ref="&visit_ref");
  %end;
  %else %do;
    %let visit_class = &visit;
  %end;

  proc glimmix data=&lib..&dsn method=quad(qpoints=10);
    class &id &visit_class &classvars &outcome;

    model &outcome = &model_vars
          / dist=mult link=clogit solution;
    output out=estimates_glmmB pred(noblup ilink)=mean;
    ods output SolutionR = &outlib..random_effects;

    random intercept / subject=&id solution;

    /* Estimate contrasts among visit levels (may require adjustment if visit_ref is changed) */
    estimate "Visit 2 vs 1" visit 1 -1 / exp;
    estimate "Visit 3 vs 1" visit 0 1 -1 / exp;
    estimate "Visit 3 vs 2" visit -1 1 0 / exp;

    ods output
      ParameterEstimates = &outlib..glmm_params
      FitStatistics      = &outlib..glmm_fitstats
      CovParms           = &outlib..glmm_cov;
  run;

%mend;

/* 
Example 1: Fit model without visit-by-covariate interactions.
Categorical reference levels are specified explicitly.
Visit reference is set to category "1".
*/
%fit_multinomial_glmm(
  lib=mydata,
  dsn=data_cvd,
  id=id,
  outcome=outcome,
  visit=visit,
  visit_ref=1,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female(ref='0') educ(ref='1') pag2008(ref='0') depr1(ref='0') alcuse(ref='0') smoker(ref='0'),
  add_interactions=NO,
  outlib=work
);

/* 
Example 2: Fit model including all visit-by-covariate interaction terms.
Same reference levels as above.
*/
%fit_multinomial_glmm(
  lib=mydata,
  dsn=data_cvd,
  id=id,
  outcome=outcome,
  visit=visit,
  visit_ref=1,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female(ref='0') educ(ref='1') pag2008(ref='0') depr1(ref='0') alcuse(ref='0') smoker(ref='0'),
  add_interactions=YES,
  outlib=work
);







/**
  Macro: %plot_random_effects_diagnostics
  Purpose:
    Visualizes and assesses the distributional assumptions of subject-specific random intercepts 
    estimated from a mixed-effects model (e.g., GLMM). This includes:
      1. Histogram with overlaid normal density curve.
      2. Normal Q–Q plot using empirical Bayes estimates.

  Arguments:
    data=           Input dataset containing empirical Bayes estimates (typically from SolutionR).
    estimate_var=   Name of the variable containing the random effect estimates.
                    Default is "estimate", which aligns with PROC GLIMMIX output.
    outprefix=      Prefix for intermediate output datasets. Default is "re_diag".

  Notes:
    This macro assumes the random effects are normally distributed and provides 
    diagnostic graphics for evaluating this assumption. All plots use standardized formatting.
**/

%macro plot_random_effects_diagnostics(
  data=work.random_effects,
  estimate_var=estimate,
  outprefix=re_diag
);

  /* Set global ODS graphics parameters for consistent figure dimensions */
  ods graphics / width=5in height=4in imagemap;

  /*-----------------------------*
   |  Histogram with Normal Curve |
   *-----------------------------*/
  title "Distribution of Empirical Bayes Estimates for Random Intercepts";

  proc sgplot data=&data;
    styleattrs datasymbols=(CircleFilled) datacolors=(gray black);
    
    histogram &estimate_var / 
      fillattrs=(color=gray transparency=0.1) 
      binwidth=0.25 scale=count;

    density &estimate_var / 
      type=normal 
      lineattrs=(color=black thickness=2 pattern=solid);

    xaxis label="Estimate" values=(-4 to 4 by 1) labelattrs=(size=10pt weight=bold);
    yaxis label="Frequency" labelattrs=(size=10pt weight=bold);
  run;

  /*----------------------------------------------*
   |  Compute Mean and SD of Random Effect Estimates |
   *----------------------------------------------*/
  proc means data=&data noprint;
    var &estimate_var;
    output out=&outprefix._stats mean=mu std=sd;
  run;

  /* Sort estimates for quantile plot construction */
  proc sort data=&data out=&outprefix._sorted;
    by &estimate_var;
  run;

  /*---------------------------------------------*
   |  Construct dataset for Q–Q plot of estimates |
   *---------------------------------------------*/
  data &outprefix._qq;
    if _n_ = 1 then set &outprefix._stats;
    set &outprefix._sorted nobs=nobs;
    /* Median rank method for plotting positions */
    p = (_n_ - 0.375) / (nobs + 0.25);
    /* Theoretical quantile from estimated normal */
    theor_quant = quantile('NORMAL', p, mu, sd);
    emp_quant = &estimate_var;
  run;

  /*----------------------------------*
   |  Q–Q Plot for Normality Assessment |
   *----------------------------------*/
  ods graphics / reset width=5in height=4in imagename="qqplot_random_intercepts" imagefmt=png;

  title "Q–Q Plot for Assessing Normality of Empirical Bayes Estimates of Random Intercepts";

  proc sgplot data=&outprefix._qq noautolegend;
    scatter x=theor_quant y=emp_quant / 
      markerattrs=(symbol=circlefilled color=black size=8);
    lineparm x=0 y=0 slope=1 / 
      lineattrs=(color=black thickness=2 pattern=solid);

    xaxis label="Theoretical Quantiles" 
          valueattrs=(family="Times New Roman" size=12pt);
    yaxis label="Empirical Quantiles" 
          valueattrs=(family="Times New Roman" size=12pt);
  run;

%mend;

/* Example call using default settings */
%plot_random_effects_diagnostics(
  data=work.random_effects,
  estimate_var=estimate,
  outprefix=re_diag
);

















