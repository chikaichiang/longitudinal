libname mydata '/home/u62057975/CVD/';

/*=======================================================================================
  Macro: point_biserial
  Purpose: Computes the point-biserial correlation between a binary and a continuous variable.
  Inputs:
    - data       : Input dataset name
    - continuous : Name of the continuous variable
    - binary     : Name of the binary variable (coded 0/1 or two levels)
  Output:
    - Pearson correlation between the continuous and binary variable
  Notes:
    - Point-biserial correlation is a special case of Pearson correlation for binary-continuous.
========================================================================================*/
%macro point_biserial(data=, continuous=, binary=);
  proc corr data=&data pearson nosimple;
    var &continuous;
    with &binary;
    title "Point-Biserial Correlation between &continuous and &binary in &data";
  run;
%mend;


/*=======================================================================================
  Macro: spearman_corr
  Purpose: Computes the Spearman rank correlation between two continuous or ordinal variables.
  Inputs:
    - data : Input dataset name
    - var1 : First continuous or ordinal variable
    - var2 : Second continuous or ordinal variable
  Output:
    - Spearman correlation coefficient and p-value
  Notes:
    - Spearman correlation assesses monotonic association between two variables.
========================================================================================*/
%macro spearman_corr(data=, var1=, var2=);
  proc corr data=&data spearman nosimple;
    var &var1 &var2;
    title "Spearman Correlation between &var1 and &var2 in &data";
  run;
%mend;


/*=======================================================================================
  Macro: chi_squared
  Purpose: Performs a chi-squared test of association between two categorical or binary variables.
  Inputs:
    - data : Input dataset name
    - var1 : First categorical or binary variable
    - var2 : Second categorical or binary variable
  Output:
    - Chi-square statistic and p-value for association between the two variables
  Notes:
    - For sparse tables or small cell counts, consider Fisher’s exact test.
========================================================================================*/
%macro chi_squared(data=, var1=, var2=);
  proc freq data=&data;
    tables &var1*&var2 / chisq;
    title "Chi-Squared Test between &var1 and &var2 in &data";
  run;
%mend;



/* Run Point-Biserial Correlation */
%point_biserial(data=mydata.data_cvd_v1, continuous=bmi, binary=obese);
%point_biserial(data=mydata.data_cvd_v2, continuous=bmi, binary=obese);
%point_biserial(data=mydata.data_cvd_v3, continuous=bmi, binary=obese);

/* Run Spearman Correlation */
%spearman_corr(data=mydata.data_cvd_v1, var1=hei2010, var2=bmi);
%spearman_corr(data=mydata.data_cvd_v2, var1=hei2010, var2=bmi);
%spearman_corr(data=mydata.data_cvd_v3, var1=hei2010, var2=bmi);

%spearman_corr(data=mydata.data_cvd_v1, var1=age, var2=bmi);
%spearman_corr(data=mydata.data_cvd_v2, var1=age, var2=bmi);
%spearman_corr(data=mydata.data_cvd_v3, var1=age, var2=bmi);

%spearman_corr(data=mydata.data_cvd_v1, var1=hei2010, var2=age);
%spearman_corr(data=mydata.data_cvd_v2, var1=hei2010, var2=age);
%spearman_corr(data=mydata.data_cvd_v3, var1=hei2010, var2=age);

%spearman_corr(data=mydata.data_cvd_v1, var1=hei2010, var2=educ);

/* Run Chi-Square Test */
%chi_squared(data=mydata.data_cvd_v1, var1=smoker, var2=alcuse);
%chi_squared(data=mydata.data_cvd_v2, var1=smoker, var2=alcuse);
%chi_squared(data=mydata.data_cvd_v3, var1=smoker, var2=alcuse);

%chi_squared(data=mydata.data_cvd_v1, var1=smoker, var2=female);
%chi_squared(data=mydata.data_cvd_v2, var1=smoker, var2=female);
%chi_squared(data=mydata.data_cvd_v3, var1=smoker, var2=female);

%chi_squared(data=mydata.data_cvd_v1, var1=alcuse, var2=female);
%chi_squared(data=mydata.data_cvd_v2, var1=alcuse, var2=female);
%chi_squared(data=mydata.data_cvd_v3, var1=alcuse, var2=female);

%chi_squared(data=mydata.data_cvd_v1, var1=smoker, var2=depr1);
%chi_squared(data=mydata.data_cvd_v2, var1=smoker, var2=depr1);
%chi_squared(data=mydata.data_cvd_v3, var1=smoker, var2=depr1);

%chi_squared(data=mydata.data_cvd_v1, var1=alcuse, var2=depr1);
%chi_squared(data=mydata.data_cvd_v2, var1=alcuse, var2=depr1);
%chi_squared(data=mydata.data_cvd_v3, var1=alcuse, var2=depr1);

%chi_squared(data=mydata.data_cvd_v1, var1=pag2008, var2=educ);