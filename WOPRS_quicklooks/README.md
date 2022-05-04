# OAP_Quicklook

To run: Download all idl (.pro) files

Procedure to run: 'OAP_Quicklook' -- two options: 
    Option 1: Place all procedures within your idl path and compile/run OAP_quicklook, all procedures within package will be compiled at runtime 
    OR 
    Option 2: Open and compile individually all of the procedure files in the package. And then run OAP_quicklook
    
OAP_Quicklook can either use 'custom' mode, in which files, times, and parameters are set (hardwired) in code procedure 'oap_quicklook_getsetup.pro'
    OR
    run in file mode where a setup file (.csv) is used to define input files, times, and parameters are set within the file. This is useful for running in a 'batch' mode with several runs per flight.

   
The word document: 'OAP-Quicklook-Progam-Guide.docx' provides detailed instrunctions and descriptions of use and modification of code.

The file 'Sample-Setup-File.csv' is an example csv file for setting up OAP_Quicklook in batch mode
