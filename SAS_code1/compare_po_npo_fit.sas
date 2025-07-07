libname mydata '/home/u62057975/CVD/';

%macro compare_po_npo_fit(lib=, dsn=, outcome=, predictors=, classvars=, outlib=work);

  /**********************************************************************
  * Macro: compare_po_npo_fit
  * Purpose:
  *   Fits and compares a proportional odds model (ordinal logistic)
  *   and a non-proportional odds model (nominal logistic) using the 
  *   same predictors. Extracts only the model fit statistics.
  * 
  * Inputs:
  *   lib        = Library where the dataset is located (e.g., mydata)
  *   dsn        = Dataset name (e.g., data_cvd_v2)
  *   outcome    = Name of the ordinal outcome variable (e.g., outcome)
  *   predictors = List of predictors (space-separated, e.g., female educ hei2010 ...)
  *   classvars  = List of categorical variables (space-separated, e.g., female educ ...)
  *   outlib     = Library to store the output datasets (default = work)
  **********************************************************************/

  ods exclude all;  /* Suppress all output for cleaner log */

  /* Step 1: Fit Proportional Odds Model (Ordinal Logistic with Cumulative Logit Link) */
  proc logistic data=&lib..&dsn;
    class &classvars / param=ref ref=first;
    model &outcome (order=internal) = &predictors / link=logit;
    ods output FitStatistics=&outlib..po_stats
    		   GlobalTests   = &outlib..po_global;;
  run;

  /* Step 2: Fit Non-Proportional Odds Model (Nominal Logistic Model) */
  proc logistic data=&lib..&dsn;
    class &outcome(ref='0') &classvars / param=ref ref=first;
    model &outcome = &predictors / link=glogit;
    ods output FitStatistics=&outlib..npo_stats
    		   GlobalTests   = &outlib..npo_global;;
  run;

  ods exclude none;  /* Resume output */

  /* Step 3: Print Model Fit Statistics and Global Null Hypothesis Tests */
  title "Model Fit Statistics for Proportional Odds Model";
  proc print data=&outlib..po_stats noobs label;
  run;

  title "Global Null Hypothesis Tests for Proportional Odds Model";
  proc print data=&outlib..po_global noobs label;
  run;

  title "Model Fit Statistics for Non-Proportional Odds Model";
  proc print data=&outlib..npo_stats noobs label;
  run;

  title "Global Null Hypothesis Tests for Non-Proportional Odds Model";
  proc print data=&outlib..npo_global noobs label;
  run;

  title;

%mend;


%compare_po_npo_fit(
  lib=mydata,
  dsn=data_cvd_v1,
  outcome=outcome,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female educ pag2008 depr1 alcuse smoker,
  outlib=work
);

%compare_po_npo_fit(
  lib=mydata,
  dsn=data_cvd_v2,
  outcome=outcome,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female educ pag2008 depr1 alcuse smoker,
  outlib=work
);

%compare_po_npo_fit(
  lib=mydata,
  dsn=data_cvd_v3,
  outcome=outcome,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female educ pag2008 depr1 alcuse smoker,
  outlib=work
);