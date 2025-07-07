libname mydata '/home/u62057975/CVD/';

%macro gee_binary_assoc(data=, subject=ID, response=, predictor=);

  /*
    Macro: gee_binary_assoc
    Purpose: Assess correlation between two binary variables longitudinally
             using a Generalized Estimating Equations (GEE) approach with a logit link.
    
    Parameters:
      data      : Input dataset with repeated measures
      subject   : Subject identifier (e.g., ID)
      response  : Binary outcome variable (e.g., alcuse)
      predictor : Binary predictor variable (e.g., smoker)
    
    Output:
      - GEE model fit statistics
      - Working correlation estimate (exchangeable)
      - Significance of association between predictor and outcome
  */

  proc genmod data=&data;
    class &subject visit;
    model &response = &predictor / dist=bin link=logit;
    repeated subject=&subject / type=exch;
    title "GEE Logistic Model: &response ~ &predictor (Exchangeable Correlation)";
  run;

%mend;


%gee_binary_assoc(
  data=mydata.data_cvd,
  subject=ID,
  response=smoker,
  predictor=alcuse
);

%gee_binary_assoc(
  data=mydata.data_cvd,
  subject=ID,
  response=alcuse,
  predictor=smoker
);

%gee_binary_assoc(
  data=mydata.data_cvd,
  subject=ID,
  response=female,
  predictor=smoker
);

%gee_binary_assoc(
  data=mydata.data_cvd,
  subject=ID,
  response=smoker,
  predictor=female
);

%gee_binary_assoc(
  data=mydata.data_cvd,
  subject=ID,
  response=female,
  predictor=alcuse
);

%gee_binary_assoc(
  data=mydata.data_cvd,
  subject=ID,
  response=alcuse,
  predictor=female
);

%gee_binary_assoc(
  data=mydata.data_cvd,
  subject=ID,
  response=depr1,
  predictor=smoker
);

%gee_binary_assoc(
  data=mydata.data_cvd,
  subject=ID,
  response=smoker,
  predictor=depr1
);

%gee_binary_assoc(
  data=mydata.data_cvd,
  subject=ID,
  response=depr1,
  predictor=alcuse
);

%gee_binary_assoc(
  data=mydata.data_cvd,
  subject=ID,
  response=smoker,
  predictor=alcuse
);




%macro rm_point_biserial_corr(data=, subject=ID, repeated=visit, response=bmi, predictor=obese);
  /*
    Macro: rm_point_biserial_corr
    Purpose: To estimate the repeated measures point-biserial correlation approximation 
             between a continuous response and a binary predictor using PROC MIXED.
             This uses a compound symmetry (CS) covariance structure for repeated measures.
             
    Parameters:
      data      : Input dataset containing repeated measures data.
      subject   : Subject identifier variable (class variable for repeated measures).
      repeated  : Repeated measure time variable (class variable).
      response  : Continuous response variable.
      predictor : Binary predictor variable (class variable).
      
    Output:
      PROC MIXED output showing fixed effects estimates and covariance parameters,
      with ODS output suppressed for cleaner logs and output display.
  */

  /* Suppress graphical output only */
  ods graphics off;

  proc mixed data=&data method=ml;
    class &subject &repeated &predictor;
    model &response = &predictor / solution;
    repeated &repeated / subject=&subject type=cs;
    title "Repeated Measures Point-Biserial Correlation Approximation: &response vs. &predictor";
  run;

  /* Re-enable graphical output */
  ods graphics on;
%mend;

%rm_point_biserial_corr(data=mydata.data_cvd, response=bmi, predictor=obese);




%macro mixed_cts_asst(
  data=,            /* Input dataset containing repeated measurements */
  subject=ID,       /* Subject identifier variable for repeated measures */
  time=visit,       /* Time variable indicating repeated measure occasions */
  outcome=,         /* Continuous outcome variable measured longitudinally */
  predictor=,       /* Continuous predictor variable measured longitudinally */
  corr_type=cs      /* Covariance structure for repeated measures (default: compound symmetry) */
);

  /* 
     PROC MIXED fits a linear mixed-effects model to examine the longitudinal
     association (or within-subject correlation) between two continuous variables.

     - &data: Dataset containing repeated measures on subjects.
     - &subject: Identifier for each subject with multiple observations.
     - &time: Time or visit variable representing measurement occasions.
     - &outcome: Continuous response variable measured repeatedly over time.
     - &predictor: Continuous predictor variable measured repeatedly over time.
     - &corr_type: Covariance structure to model within-subject correlation,
       such as compound symmetry (CS) or unstructured (UN).

     This approach accounts for the non-independence of repeated measurements
     within subjects by specifying a suitable covariance structure via the
     REPEATED statement.

     The SOLUTION option produces fixed effect estimates and tests the null
     hypothesis that the predictor is not associated with the outcome over time.

     The output can be interpreted as the average change in the outcome associated
     with a one-unit change in the predictor, adjusting for correlation due to
     repeated measures.

     This method provides a robust approach to assessing longitudinal association
     between continuous variables beyond simple correlation coefficients.

  */

  ods graphics off;
  
  proc mixed data=&data;
    class &subject &time;
    model &outcome = &predictor / solution;
    repeated &time / subject=&subject type=&corr_type;
    title "Longitudinal association between continuous variables: &outcome (dependent) and &predictor (independent)";
  run;
  
  ods graphics on;
%mend;


%mixed_cts_asst(data=mydata.data_cvd, outcome=BMI, predictor=HEI2010);
%mixed_cts_asst(data=mydata.data_cvd, outcome=age, predictor=HEI2010);
%mixed_cts_asst(data=mydata.data_cvd, outcome=age, predictor=BMI);
%mixed_cts_asst(data=mydata.data_cvd, outcome=BMI, predictor=age);





