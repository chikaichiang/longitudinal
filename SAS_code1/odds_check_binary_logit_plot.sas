/************************************************************************
 * Macro: run_partial_logit_plot
 * Purpose: Fit separate binary logistic regression models to approximate
 *          ordinal logistic regression and visualize coefficient variation
 *          across cumulative thresholds (i.e., test for PO violations).
 *
 * Input parameters:
 *   lib=     - library name of input dataset (e.g., 'mydata')
 *   dsn=     - dataset name (e.g., 'data_cvd_v1')
 *   outcome= - name of ordinal outcome variable (e.g., 'outcome')
 *   outlib=  - output library for intermediate datasets (default: WORK)
 *
 * Steps:
 *   1. Create binary outcomes for cumulative logits
 *   2. Fit logistic models for each cumulative cutpoint
 *   3. Extract, combine, and calculate 95% CI for each coefficient
 *   4. Plot coefficients with confidence intervals by threshold
 ************************************************************************/
%macro run_partial_logit_plot(lib=, dsn=, outcome=, outlib=work, visit=);

  /* -----------------------------------------------------------
   * Step 1: Create binary outcomes and dummy variables
   * -----------------------------------------------------------
   * Converts ordinal outcome into three binary outcomes:
   *   y1: outcome ≥ 1
   *   y2: outcome ≥ 2
   *   y3: outcome = 3 (highest category)
   * Also creates dummy variables for educ=2 and educ=3
   * (reference group is educ=1).
   */
  data &outlib..prep_data;
    set &lib..&dsn;
    y1 = (&outcome >= 1);
    y2 = (&outcome >= 2);
    y3 = (&outcome = 3);
    educ_2 = (educ = 2);
    educ_3 = (educ = 3);
  run;

  /* -----------------------------------------------------------
   * Step 2: Define nested macro to fit binary logistic model
   * -----------------------------------------------------------
   * For each binary threshold variable (y1, y2, y3), fit a
   * logistic regression model using the full set of predictors.
   * Categorical predictors use reference cell coding via CLASS.
   * Results (coefficients, standard errors) are saved via ODS.
   */
  %macro fit_logit(thresh=, yvar=);
    proc logistic data=&outlib..prep_data;
      class female(ref='0') pag2008(ref='0') depr1(ref='0') 
            alcuse(ref='0') smoker(ref='0') / param=ref;
      model &yvar(event='1') = female educ_2 educ_3 hei2010 pag2008 depr1 age alcuse bmi smoker;
      ods output ParameterEstimates=pe_&thresh;
    run;
  %mend;

  /* Apply the model for each cumulative threshold */
  %fit_logit(thresh=y1, yvar=y1)
  %fit_logit(thresh=y2, yvar=y2)
  %fit_logit(thresh=y3, yvar=y3)

  /* -----------------------------------------------------------
   * Step 3: Combine parameter estimates across models
   * -----------------------------------------------------------
   * Label each coefficient by threshold:
   *   ≥1, ≥2, =3
   * Compute 95% confidence intervals:
   *   CI = estimate ± 1.96 × standard error
   */
  data &outlib..all_params;
    set pe_y1(in=a) pe_y2(in=b) pe_y3(in=c);
    length threshold $4;
    if a then threshold = "≥1";
    else if b then threshold = "≥2";
    else if c then threshold = "=3";

    lower = Estimate - 1.96 * StdErr;
    upper = Estimate + 1.96 * StdErr;
  run;

  /* Remove intercept terms for clarity in plotting */
  data &outlib..coef_df_plot;
    set &outlib..all_params;
    if Variable ^= "Intercept";
  run;

  /* -----------------------------------------------------------
   * Step 4: Plot coefficient estimates and confidence intervals
   * -----------------------------------------------------------
   * Uses SGPLOT to generate coefficient plots for each predictor
   * by threshold. JASA-style refinements:
   *   - Confidence intervals shown with highlow plot
   *   - Points and error bars grouped by threshold
   *   - Dashed zero line for reference
   *   - Rotated axis labels for readability
   *   - Clean axis and legend formatting
   */
	
	/* Step 4: Plot with dynamic visit-specific title */
	title "Log-Odds Coefficients by Threshold for Visit &visit";
	
	proc sgplot data=&outlib..coef_df_plot;
	  scatter x=Variable y=Estimate / group=threshold markerattrs=(symbol=CircleFilled size=10);
	  highlow x=Variable low=lower high=upper / group=threshold type=line;
	  refline 0 / axis=y lineattrs=(color=gray pattern=shortdash);
	  xaxis label='Predictor' display=(nolabel) fitpolicy=rotate valuesrotate=diagonal;
	  yaxis label='Log-Odds Coefficient';
	  keylegend / title="Threshold" position=top;
	run;
	
	title;  /* Clear title afterward */


%mend;


libname mydata '/home/u62057975/CVD/';

%run_partial_logit_plot(lib=mydata, dsn=data_cvd_v1, outcome=outcome, outlib=work, visit=1);

%run_partial_logit_plot(lib=mydata, dsn=data_cvd_v2, outcome=outcome, outlib=work, visit=2);

%run_partial_logit_plot(lib=mydata, dsn=data_cvd_v3, outcome=outcome, outlib=work, visit=3);