libname mydata '/home/u62057975/CVD/';

/************************************************************************
 * Macro: ordinal_linearity_plot
 *
 * Purpose:
 *   Assess the linearity of a continuous predictor (e.g., age) in an
 *   ordinal logistic regression model using the partial proportional
 *   odds framework. This macro fits three binary logistic models 
 *   corresponding to cumulative thresholds and visualizes predicted 
 *   log-odds against the predictor of interest using LOESS smoothing.
 *
 * Parameters:
 *   dsn        = Input dataset name (e.g., mydata.data_cvd_v1)
 *   visit      = Visit label or suffix for naming outputs (e.g., 1, 2)
 *   xvar       = Continuous covariate to assess (e.g., age, hei2010)
 *   predictors = Full list of model covariates including xvar
 *   classvars  = List of categorical predictors
 *   titletext  = Title for the generated plot
 ************************************************************************/

%macro ordinal_linearity_plot(
    dsn=,
    visit=,
    xvar=age,
    predictors=,
    classvars=,
    titletext=
);

  /* Step 1: Create temporary dataset with thresholded binary outcomes */
  %let workds=work._temp_&visit;

  data &workds;
    set &dsn;
    y1 = (outcome >= 1);
    y2 = (outcome >= 2);
    y3 = (outcome >= 3);
  run;

  /* Step 2: Define inner macro to fit binary logistic model 
     and extract linear predictor (xbeta) for a given threshold */
  %macro fit_one(yvar=, out=);
    ods exclude all;  /* Suppress printed output */
    proc logistic data=&workds noprint;
      class &classvars / param=ref ref=first;
      model &yvar(event='1') = &predictors;
      output out=&out xbeta=logit;
    run;
    ods exclude none;
  %mend;

  /* Fit models for each cumulative threshold */
  %fit_one(yvar=y1, out=pred1);
  %fit_one(yvar=y2, out=pred2);
  %fit_one(yvar=y3, out=pred3);

  /* Step 3: Merge predicted logits across thresholds */
  data merged_preds;
    merge pred1(keep=logit &xvar rename=(logit=logit1))
          pred2(keep=logit rename=(logit=logit2))
          pred3(keep=logit rename=(logit=logit3));
  run;

  /* Step 4: Generate LOESS-smoothed plot of log-odds vs. xvar */
  ods graphics / reset width=6.5in height=5in imagename="OrdinalLogit_LOESS_Visit&visit._&xvar" imagefmt=png;
  title "&titletext";

  proc sgplot data=merged_preds noborder;
    /* Apply JASA-style dark color palette */
    styleattrs datacontrastcolors=(CX1F78B4 CXA00000 CX006400);

    /* Custom legend entries (threshold-specific) */
    legenditem name="thresh1" type=markerline / label="Threshold ≥ 1"
      lineattrs=(color=CX1F78B4 thickness=2)
      markerattrs=(symbol=circlefilled color=CX1F78B4 size=3);
    legenditem name="thresh2" type=markerline / label="Threshold ≥ 2"
      lineattrs=(color=CXA00000 thickness=2)
      markerattrs=(symbol=circlefilled color=CXA00000 size=3);
    legenditem name="thresh3" type=markerline / label="Threshold ≥ 3"
      lineattrs=(color=CX006400 thickness=2)
      markerattrs=(symbol=circlefilled color=CX006400 size=3);

    /* Add LOESS trend lines for each threshold */
    loess x=&xvar y=logit1 / lineattrs=(color=CX1F78B4 thickness=2);
    loess x=&xvar y=logit2 / lineattrs=(color=CXA00000 thickness=2);
    loess x=&xvar y=logit3 / lineattrs=(color=CX006400 thickness=2);

    /* Overlay raw predicted log-odds with transparent markers */
    scatter x=&xvar y=logit1 / markerattrs=(symbol=circlefilled color=CX1F78B4 size=3) transparency=0.85;
    scatter x=&xvar y=logit2 / markerattrs=(symbol=circlefilled color=CXA00000 size=3) transparency=0.85;
    scatter x=&xvar y=logit3 / markerattrs=(symbol=circlefilled color=CX006400 size=3) transparency=0.85;

    /* Format axes in JASA-compliant style */
    xaxis label="&xvar" valueattrs=(family="Arial" size=10) labelattrs=(family="Arial" size=11);
    yaxis label="Predicted Log-Odds" valueattrs=(family="Arial" size=10) labelattrs=(family="Arial" size=11);

    /* Simple, compact legend at bottom of plot */
    keylegend "thresh1" "thresh2" "thresh3" / location=outside position=bottom across=3
                valueattrs=(family="Arial" size=9) noborder;
  run;

  ods graphics / reset=all;

%mend;


/* For Age at Visit 1 */
%ordinal_linearity_plot(
  dsn=mydata.data_cvd_v1,
  visit=1,
  xvar=age,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female educ pag2008 depr1 alcuse smoker,
  titletext=Linearity Assessment of Age in Ordinal Logistic Models - Visit 1
);

/* For Age at Visit 2 */
%ordinal_linearity_plot(
  dsn=mydata.data_cvd_v2,
  visit=2,
  xvar=age,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female educ pag2008 depr1 alcuse smoker,
  titletext=Linearity Assessment of Age in Ordinal Logistic Models - Visit 2
);

/* For Age at Visit 3 */
%ordinal_linearity_plot(
  dsn=mydata.data_cvd_v3,
  visit=3,
  xvar=age,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female educ pag2008 depr1 alcuse smoker,
  titletext=Linearity Assessment of Age in Ordinal Logistic Models - Visit 3
);



/* For HEI2010 at Visit 1 */
%ordinal_linearity_plot(
  dsn=mydata.data_cvd_v1,
  visit=1,
  xvar=hei2010,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female educ pag2008 depr1 alcuse smoker,
  titletext=Linearity Assessment of HEI2010 in Ordinal Logistic Models - Visit 1
);

/* For HEI2010 at Visit 2 */
%ordinal_linearity_plot(
  dsn=mydata.data_cvd_v2,
  visit=2,
  xvar=hei2010,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female educ pag2008 depr1 alcuse smoker,
  titletext=Linearity Assessment of HEI2010 in Ordinal Logistic Models - Visit 2
);

/* For HEI2010 at Visit 3 */
%ordinal_linearity_plot(
  dsn=mydata.data_cvd_v3,
  visit=3,
  xvar=hei2010,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female educ pag2008 depr1 alcuse smoker,
  titletext=Linearity Assessment of HEI2010 in Ordinal Logistic Models - Visit 3
);


/* For BMI at Visit 1 */
%ordinal_linearity_plot(
  dsn=mydata.data_cvd_v1,
  visit=1,
  xvar=bmi,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female educ pag2008 depr1 alcuse smoker,
  titletext=Linearity Assessment of BMI in Ordinal Logistic Models - Visit 1
);

/* For BMI at Visit 2 */
%ordinal_linearity_plot(
  dsn=mydata.data_cvd_v2,
  visit=2,
  xvar=bmi,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female educ pag2008 depr1 alcuse smoker,
  titletext=Linearity Assessment of BMI in Ordinal Logistic Models - Visit 2
);

/* For BMI at Visit 3 */
%ordinal_linearity_plot(
  dsn=mydata.data_cvd_v3,
  visit=3,
  xvar=bmi,
  predictors=female educ hei2010 pag2008 depr1 age alcuse bmi smoker,
  classvars=female educ pag2008 depr1 alcuse smoker,
  titletext=Linearity Assessment of BMI in Ordinal Logistic Models - Visit 3
);



