/*  
  Macro: boxplot_vars_static_hei2010
  Purpose: Generate boxplots for multiple numeric variables stratified by a categorical outcome variable.
           The variable 'hei2010' is always plotted using the full dataset (no visit filter),
           while other variables are filtered by the specified visit value.
           Applies clean JASA-style formatting.
  
  Parameters:
    - dataset: The input dataset name (with library if applicable).
    - outcome: The categorical grouping variable to stratify boxplots by.
    - var:     One or more numeric variables (space-separated), including 'hei2010' and others.
    - visit:   Numeric or character value to filter dataset by 'visit' for all variables except 'hei2010'.
  
  Behavior:
    - For 'hei2010', plots boxplots over the entire dataset ignoring 'visit'.
    - For other variables, plots boxplots filtered by 'visit'.
    - Produces one boxplot per variable.
*/

%macro boxplot_vars_static_hei2010(dataset=, outcome=, var=, visit=);

  /* Count the number of variables specified */
  %let nvars = %sysfunc(countw(&var));

  /* Loop over each variable */
  %do i = 1 %to &nvars;
    %let thisvar = %scan(&var, &i);

    proc sgplot data=&dataset;
      /* Apply visit filter except for hei2010 */
      %if &thisvar = hei2010 %then %do;
        /* No WHERE clause: include all visits */
      %end;
      %else %do;
        where visit = &visit;
      %end;

      /* Draw boxplot stratified by outcome */
      vbox &thisvar / category=&outcome
         fillattrs=(color=lightgray)
         lineattrs=(color=black thickness=1)
         whiskerattrs=(color=black thickness=1)
         medianattrs=(color=black thickness=2)
         boxwidth=0.4;

      /* X-axis formatting */
      xaxis discreteorder=formatted
            display=(nolabel)
            valueattrs=(family="Arial" size=10pt weight=bold);

      /* Y-axis formatting */
      yaxis label="%upcase(&thisvar)"
            grid
            labelattrs=(family="Arial" size=11pt)
            valueattrs=(family="Arial" size=10pt);

      /* Plot title with conditional text */
      title height=14pt font="Arial Bold"
        %if &thisvar = hei2010 %then %do;
          "Boxplot of %upcase(&thisvar) by Outcome (All Visits)"
        %end;
        %else %do;
          "Boxplot of %upcase(&thisvar) by Outcome at Visit &visit"
        %end;
      ;

    run;

  %end;

%mend;



/* Example usage */
libname mydata '/home/u62057975/CVD/';

%boxplot_vars_static_hei2010(
  dataset=mydata.data_cvd,
  outcome=outcome,
  var=hei2010 bmi age,
  visit=1
);

%boxplot_vars_static_hei2010(
  dataset=mydata.data_cvd,
  outcome=outcome,
  var=hei2010 bmi age,
  visit=2
);

%boxplot_vars_static_hei2010(
  dataset=mydata.data_cvd,
  outcome=outcome,
  var=hei2010 bmi age,
  visit=3
);


