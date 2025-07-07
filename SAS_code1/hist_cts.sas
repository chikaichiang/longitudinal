%macro plot_histogram_panel(lib=, data=);

  /* Step 1: Convert AGE, BMI, HEI-2010 into long format */
  data work.histdata;
    set &lib..&data;
    length variable $10;

    /* Assign variable label and store value */
    value = age;      variable = "Age";      output;
    value = bmi;      variable = "BMI";      output;
    value = hei2010;  variable = "HEI-2010"; output;

    keep id visit variable value;
  run;

  /* Step 2: Generate polished faceted histograms */
  ods graphics / reset width=7in height=4in imagename="Histograms_&data";

  proc sgpanel data=work.histdata;
    title "Distributions of Age, BMI, and HEI-2010 Across All Visits in CVD Data";
    panelby variable / columns=3 spacing=6 novarname headerattrs=(weight=bold size=10pt);

    histogram value / scale=count;

    colaxis label="Value" labelattrs=(weight=bold size=9pt)
            valueattrs=(size=8pt);
    rowaxis label="Frequency" labelattrs=(weight=bold size=9pt)
            valueattrs=(size=8pt);
  run;

  title;

%mend plot_histogram_panel;

libname mydata '/home/u62057975/CVD/';

/* Call the macro on the dataset */
%plot_histogram_panel(lib=mydata, data=data_cvd);


