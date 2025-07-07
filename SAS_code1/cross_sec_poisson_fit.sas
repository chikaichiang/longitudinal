libname mydata '/home/u62057975/CVD/';

proc logistic data=mydata.data_cvd_v1;
  class female(ref='0') educ(ref='1') pag2008(ref='0') depr1(ref='0')
        alcuse(ref='0') smoker(ref='0') / param=ref;
  model outcome (order=internal) = 
        female educ hei2010 pag2008 depr1 age alcuse bmi smoker 
        / link=logit;
  title "Ordinal Logistic Regression Model (Proportional Odds)";
run;

/* Create binary outcomes */
data binary_cvd_v1;
  set mydata.data_cvd_v1;

  outcome_le0 = (outcome <= 0); /* 1 if outcome is 0, else 0 */
  outcome_le1 = (outcome <= 1); /* 1 if outcome is 0 or 1, else 0 */
  outcome_le2 = (outcome <= 2); /* 1 if outcome is 0,1,2, else 0 */
run;

proc logistic data=binary_cvd_v1;
  class female(ref='0') educ(ref='1') pag2008(ref='0') depr1(ref='0')
        alcuse(ref='0') smoker(ref='0') / param=ref;
  model outcome_le0(event='1') = female educ hei2010 pag2008 depr1 age alcuse bmi smoker;
  title "Binary Logistic: outcome <= 0 vs > 0";
run;

proc logistic data=binary_cvd_v1;
  class female(ref='0') educ(ref='1') pag2008(ref='0') depr1(ref='0')
        alcuse(ref='0') smoker(ref='0') / param=ref;
  model outcome_le1(event='1') = female educ hei2010 pag2008 depr1 age alcuse bmi smoker;
  title "Binary Logistic: outcome <= 1 vs > 1";
run;

proc logistic data=binary_cvd_v1;
  class female(ref='0') educ(ref='1') pag2008(ref='0') depr1(ref='0')
        alcuse(ref='0') smoker(ref='0') / param=ref;
  model outcome_le2(event='1') = female educ hei2010 pag2008 depr1 age alcuse bmi smoker;
  title "Binary Logistic: outcome <= 2 vs > 2";
run;


