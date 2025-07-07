/* 
   Macro: import_csv
   Purpose: To flexibly import a CSV file into a specified SAS library with user-defined parameters.
   Parameters:
     lib      = The name of the library to assign (e.g., cvdlib)
     libpath  = The directory path for the library (must be a valid SAS file path)
     filepath = Full path to the CSV file to be imported
     dataset  = The name to assign to the output SAS dataset
*/
%macro import_csv(lib=, libpath=, filepath=, dataset=);

    /* Step 1: Assign the SAS library using the specified path */
    libname &lib. "&libpath.";  /* Creates a permanent library reference */

    /* Step 2: Import the CSV file into the specified library and dataset */
    proc import datafile="&filepath."  /* Path to the input CSV file */
        out=&lib..&dataset.             /* Output dataset saved as libref.datasetname */
        dbms=csv                       /* Specifies the input file format */
        replace;                       /* Overwrites the dataset if it already exists */
        guessingrows=max;              /* Uses all rows to guess variable types and lengths */
    run;

%mend import_csv;

/* 
   Example usage of the macro:
   This call assigns the 'cvdlib' library to '/home/u62057975/CVD' and
   imports 'data_cvd.csv' into 'cvdlib.data_cvd'
*/
%import_csv(
    lib=cvdlib,
    libpath=/home/u62057975/CVD,
    filepath=/home/u62057975/CVD/data_cvd.csv,
    dataset=data_cvd
);


%macro create_outcome_var(lib=, dataset=);

    /* Add an outcome variable as the sum of high cholesterol, high blood pressure, and diabetes */
    data &lib..&dataset.;
        set &lib..&dataset.;

        /* Create outcome variable as the total number of CVD risk conditions */
        outcome = sum(of highchol, highbp, diabetes);
    run;

%mend create_outcome_var;

/* Example usage */
%create_outcome_var(
    lib=cvdlib,
    dataset=data_cvd
);


%macro remove_id(lib=, dataset=, remove_id=1695);
  /* Create a new dataset excluding the specified ID */
  data &lib..&dataset.;
    set &lib..&dataset.;
    if ID ^= &remove_id;
  run;
%mend remove_id;

/* Example usage */
%remove_id(lib=cvdlib, dataset=data_cvd, remove_id=1695);



%macro split_by_visit(lib=, dataset=, visit_var=visit);

    /********************************************************************
    Macro: split_by_visit
    Purpose:
        This macro takes a dataset containing a longitudinal structure
        (i.e., repeated measures across visits) and splits it into 
        separate datasets for each specified visit number. Specifically,
        this version creates three datasets for visit values 1, 2, and 3.

    Parameters:
        lib       - The name of the library where the input and output 
                    datasets are or will be stored (must be assigned).
        dataset   - The name of the input dataset within the specified lib.
        visit_var - The name of the variable in the dataset that indicates 
                    the visit number. Defaults to "visit".

    Output:
        Creates the following permanent datasets in the specified library:
            - lib.dataset_v1: Contains only records with visit = 1
            - lib.dataset_v2: Contains only records with visit = 2
            - lib.dataset_v3: Contains only records with visit = 3
    ********************************************************************/

    data &lib..&dataset._v1 
         &lib..&dataset._v2 
         &lib..&dataset._v3;

        /* Read the input dataset from the specified library */
        set &lib..&dataset;

        /* Direct each observation to the corresponding dataset 
           based on the value of the visit variable */
        if &visit_var. = 1 then output &lib..&dataset._v1;
        else if &visit_var. = 2 then output &lib..&dataset._v2;
        else if &visit_var. = 3 then output &lib..&dataset._v3;
    run;

%mend split_by_visit;

/* Example usage: Splits the dataset 'data_cvd' stored in 'cvdlib' 
   by the 'visit' variable into three separate permanent datasets */
%split_by_visit(
    lib=cvdlib,
    dataset=data_cvd,
    visit_var=visit
);
