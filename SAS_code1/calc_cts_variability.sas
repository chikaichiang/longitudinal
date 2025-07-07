%macro calc_variability(lib=, dataset=, idvar=, var=);

    /* Step 1: Calculate within-subject variance and standard deviation for the specified variable */
    proc means data=&lib..&dataset noprint;
        class &idvar.;
        var &var.;
        output out=within_var(drop=_type_ _freq_) 
            std=&var._within_sd 
            var=&var._within_var;
    run;

    /* The dataset 'within_var' contains one row per subject with their within-subject SD and variance */

    /* Step 2: Calculate average within-subject SD and variance across all subjects */
    proc means data=within_var mean;
        var &var._within_sd &var._within_var;
    run;

    /* Step 3: Calculate the Intraclass Correlation Coefficient (ICC) using a random intercept mixed model */
   
   	ods graphics off;
   	
    proc mixed data=&lib..&dataset method=REML;
        class &idvar.;
        model &var. = / solution;
        random intercept / subject=&idvar. type=vc;
        ods output CovParms=varcomp;
    run;
	
	ods graphics on;
	
    /* Step 4: Calculate ICC from variance components estimated in the mixed model */
    data icc;
        set varcomp;
        retain var_between var_within;
        if CovParm = 'Intercept' then var_between = Estimate;
        else if CovParm = 'Residual' then var_within = Estimate;
        if var_between > 0 and var_within > 0 then do;
            ICC = var_between / (var_between + var_within);
            output;
        end;
        keep ICC;
    run;

    /* Print the ICC estimate */
    proc print data=icc label noobs;
        label ICC = "Intraclass Correlation Coefficient (ICC)";
        title "Estimated ICC for &var. in &dataset";
    run;

%mend calc_variability;

/* Example usage: */
libname mydata '/home/u62057975/CVD/';

%calc_variability(
    lib=mydata,
    dataset=data_cvd,
    idvar=id,
    var=bmi
);
