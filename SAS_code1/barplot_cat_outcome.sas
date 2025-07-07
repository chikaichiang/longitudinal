%macro barplot_by_outcome(dataset=, outcome=, varlist=, visit=);

  /*
    Macro: barplot_by_outcome
    Purpose: Generate a series of barplots showing the percentage distribution of an outcome
             variable stratified by levels of one or more categorical predictor variables,
             for a specific visit. Each level of each predictor is plotted separately
             using a consistent JASA-style format with a 2:1 horizontal aspect ratio.

    Parameters:
      dataset : Input dataset containing the visit, predictors, and outcome variables.
      outcome : Name of the categorical outcome variable (used to group bars).
      varlist : Space-separated list of categorical predictor variables to process.
      visit   : Visit number used to filter the dataset (e.g., 1, 2, or 3).

    Output:
      For each predictor and each of its levels, a separate plot is produced,
      formatted using publication-style grayscale and typography suitable for JASA.
  */

  /* Map internal variable names to descriptive titles for figure headers */
  %let title_depr1   = Depression Status;
  %let title_female  = Sex (Female);
  %let title_educ    = Education Level;
  %let title_pag2008 = Physical Activity Group (2008);
  %let title_alcuse  = Alcohol Use;
  %let title_obese   = Obesity Status;
  %let title_smoker  = Smoking Status;

  /* Count how many variables are in varlist */
  %let nvars = %sysfunc(countw(&varlist));

  /* Loop through each predictor variable */
  %do i = 1 %to &nvars;
    %let thisvar = %scan(&varlist, &i);        /* Get the i-th variable */
    %let thistitle = &&title_&thisvar;         /* Get the friendly title */

    /* Get distinct, non-missing levels of the predictor at the specified visit */
    proc sql noprint;
      select distinct &thisvar into :levs separated by ' '
      from &dataset
      where visit = &visit and &thisvar is not null;
    quit;

    /* Count the number of levels */
    %let nlevs = %sysfunc(countw(&levs));

    /* Loop through each level to generate separate plots */
    %do j = 1 %to &nlevs;
      %let thislev = %scan(&levs, &j);  /* Current level of the predictor */

      /* Set aspect ratio to 2:3 for wide plots */
      ods graphics / width=4in height=6in;

      /* Generate the barplot */
      proc sgplot data=&dataset;
        where visit = &visit and &thisvar = &thislev;

        /* Bar chart showing % distribution of outcome by current predictor level */
        vbar &outcome / 
          stat=percent
          barwidth=0.5
          fillattrs=(color="#191970")   /* Steel blue color for bars */
          outlineattrs=(color=black);   /* Black border for clarity */

        /* X-axis: category labels in bold, no axis label */
        xaxis display=(nolabel)
              valueattrs=(family="Arial" size=10pt weight=bold);

        /* Y-axis: Percent label, styled */
        yaxis label="Percentage"
              grid
              labelattrs=(family="Arial" size=11pt)
              valueattrs=(family="Arial" size=10pt);

        /* Plot title: variable and level, with visit */
        title height=14pt font="Arial" font=bold
          "&thistitle = &thislev at Visit &visit";

      run;

      /* Reset ODS graphics size after each plot if needed */
      ods graphics / reset=all;

    %end;
  %end;

%mend;



/* Example calls: Generate barplots for specified variables and visits */

libname mydata '/home/u62057975/CVD/';

%barplot_by_outcome(
  dataset=mydata.data_cvd,
  outcome=outcome,
  varlist=alcuse obese smoker female educ pag2008 depr1,
  visit=1
);

%barplot_by_outcome(
  dataset=mydata.data_cvd,
  outcome=outcome,
  varlist=alcuse obese smoker female educ pag2008 depr1,
  visit=2
);

%barplot_by_outcome(
  dataset=mydata.data_cvd,
  outcome=outcome,
  varlist=alcuse obese smoker female educ pag2008 depr1,
  visit=3
);






/* 
  Macro: static_barplots_by_outcome
  Purpose: 
    - For each static categorical variable, plot outcome percentages separately 
      for each level of that variable (no grouping on the bar).
    - Each value of the predictor gets its own chart with an independent y-axis scale.
    - Designed for JASA-style presentation and assumes data has already been filtered 
      appropriately (e.g., by visit).

  Parameters:
    - dataset: Filtered input dataset
    - outcome: Outcome variable (assumed categorical, grouped on bars)
    - varlist: List of static categorical predictors (e.g., female, educ, depr1)
*/

%macro static_barplots_by_outcome(dataset=, outcome=, varlist=);

  /* Custom titles for display in plots */
  %let title_female  = Sex (Female);
  %let title_educ    = Education Level;
  %let title_pag2008 = Physical Activity Group (2008);
  %let title_depr1   = Depression Status;

  /* Count the number of variables specified */
  %let nvars = %sysfunc(countw(&varlist));

  /* Loop through each variable in the varlist */
  %do i = 1 %to &nvars;
    %let thisvar = %scan(&varlist, &i);           /* Extract variable name */
    %let thistitle = &&title_&thisvar;            /* Assign human-readable title */

    /* Retrieve distinct levels of the current predictor */
    proc sql noprint;
      select distinct &thisvar into :levs separated by ' '
      from &dataset
      where &thisvar ne .;
    quit;

    %let nlevs = %sysfunc(countw(&levs));         /* Count levels for this predictor */

    /* For each level (value) of the variable, plot the outcome distribution */
    %do j = 1 %to &nlevs;
      %let thislev = %scan(&levs, &j);

      proc sgplot data=&dataset;
        where &thisvar = &thislev;                /* Filter to this level of predictor */

        /* Plot percentage of outcome values within this subgroup */
        vbar &outcome / stat=percent
                       barwidth=0.5
                       fillattrs=(color="#191970")
                       outlineattrs=(color=black);

        /* Clean X-axis with Arial font, no label */
        xaxis display=(nolabel)
              valueattrs=(family="Arial" size=10pt weight=bold);

        /* Y-axis is specific to this level (not shared across plots) */
        yaxis label="Percentage"
              grid
              labelattrs=(family="Arial" size=11pt)
              valueattrs=(family="Arial" size=10pt);

        /* Add readable title with level info */
        title height=14pt font="Arial, Bold"
          "&thistitle = &thislev: Outcome Distribution";

      run;

    %end;

  %end;

%mend;


/* Create a dataset only for Visit 1 */
data filtered_visit1;
  set mydata.data_cvd;
  where visit = 1;
run;

/* Plot static variables from filtered dataset */
%static_barplots_by_outcome(
  dataset=filtered_visit1,
  outcome=outcome,
  varlist=female educ pag2008 depr1
);
