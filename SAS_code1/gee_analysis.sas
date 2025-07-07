libname mydata '/home/u62057975/CVD/';

/*------------------------------------------------------------------------------
  Macro: fit_multinomial_gee

  Purpose:
  This macro fits a generalized estimating equations (GEE) model for an ordinal
  multinomial outcome using a cumulative logit link, implemented via PROC GENMOD.

  Methodological Context:
  The GEE approach accounts for within-subject correlation due to repeated 
  measurements using an independent working correlation structure. The cumulative 
  logit link assumes proportional odds across outcome thresholds. The model 
  supports flexible specification of covariates, including optional interaction 
  terms with a visit variable to assess time-varying effects.

  Inputs:
  - lib: Library where the input dataset resides.
  - dsn: Name of the input dataset.
  - id: Subject identifier for repeated measures.
  - outcome: Ordinal response variable.
  - visit: Time or visit indicator.
  - visit_ref: Reference category for the visit variable.
  - predictors: List of fixed-effect covariates to include in the model.
  - classvars: Class variables with reference level specifications.
  - add_interactions: If YES, includes interaction terms between visit and all predictors.
  - outlib: Library in which to store output datasets.

  Model Specification:
  - Distribution: Multinomial
  - Link Function: Cumulative Logit
  - Repeated Structure: Subject-level GEE with independent working correlation
  - Inference: Type 3 score statistics output via ODS for covariate significance testing

------------------------------------------------------------------------------*/

%macro fit_multinomial_gee(
  lib=,
  dsn=,
  id=,
  outcome=,
  visit=,
  visit_ref=,
  predictors=,
  classvars=,
  add_interactions=YES,
  outlib=work
);

  /* Initialize local macro variables for model construction */
  %local i word inter_terms model_vars visit_class;
  %let i = 1;
  %let word = %scan(&predictors, &i);
  %let inter_terms = ;

  /*---------------------------------------------------------------
    Step 1: Automatically construct interaction terms if requested
    Loop through each predictor and create visit*predictor terms
  ---------------------------------------------------------------*/
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

  /*---------------------------------------------------------------
    Step 2: Specify CLASS statement format for visit variable
  ---------------------------------------------------------------*/
  %if %length(&visit_ref) > 0 %then %do;
    %let visit_class = &visit(ref="&visit_ref");
  %end;
  %else %do;
    %let visit_class = &visit;
  %end;

  /*---------------------------------------------------------------
    Step 3: Fit the cumulative logit GEE model
  ---------------------------------------------------------------*/
  title "GEE Model: Ordinal Multinomial with Cumulative Logit Link";

  proc genmod data=&lib..&dsn descending;
    class &id &visit_class &classvars &outcome;

    model &outcome = &model_vars /
      dist=multinomial
      link=cumlogit
      type3;

    /* Repeated subject specification with independent working correlation */
    repeated subject=&id / type=ind corrw;

    /* Save convergence and type III test results */
    ods output
      Type3              = &outlib..gee_type3
      ConvergenceStatus  = &outlib..gee_converge;
  run;

%mend;

/*------------------------------------------------------------------------------
  Model 1: GEE model without interaction terms
  Purpose: Fit a baseline cumulative logit GEE model assuming time-constant
           covariate effects across visits.
------------------------------------------------------------------------------*/
%fit_multinomial_gee(
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

/*------------------------------------------------------------------------------
  Model 2: GEE model with visit-by-covariate interaction terms
  Purpose: Allow covariate effects to vary across time (visits), enabling
           investigation of potential violations of the proportional odds assumption.
------------------------------------------------------------------------------*/
%fit_multinomial_gee(
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




