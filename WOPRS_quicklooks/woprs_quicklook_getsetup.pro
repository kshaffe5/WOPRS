FUNCTION WOPRS_QUICKLOOK_GETSETUP, INPUT_TYPE, FILE_RUN, RECORD_COUNT, INFILE, LINE_READ_VARIABLE, file_directory

;if you are putting in custom data please use the section below to input all the varaibles. 
IF(INPUT_TYPE EQ 'CUSTOM') OR (INPUT_TYPE EQ 'custom')THEN BEGIN 
  DIMG_file= '/home/kshaffe5/test_proc_dir/20170118/DIMG.170118224746.2DS.cdf' ;ex. '/kingair_data/hcpi20/OAP_processed/20200811/DIMG.200811193926.2DS.H.cdf'
  PROC_file= '/home/kshaffe5/test_proc_dir/20170118/PROC.170118224746.2DS.cdf' ;ex  '/kingair_data/hcpi20/OAP_processed/20200811/PROC.200811193926.2DS.H.cdf'
  DATE= 20170118 ;ex. 20200811
  Start_time_sec= 82500;these need to be in sec, ex. 72936
  End_time_sec=  82501;make sure start time is less then end time
  Output_file_path= '/home/kshaffe5' ;the actuall name of the file will set at the end of the file automaticaly. We need the start/end times in hhmmss first.
  Output_File_type= '.pdf' ; select the file type you would like your saved file to be. '.pdf' , '.png' , etc.

  Display_rejected_particles= 'off' ; ON= rejected particles ARE SHOWN, OFF=rejected particles ARE NOT SHOWN.
  ;Having Display_rejected_particles and Display_particles_touching_edge both ON and default diameters will result in the most amount of particles
  minD= -999  ;minimum particle diameter in microns, default is 0
  maxD= 15000000  ;maximum particle diameter in microns, default 15000
  ;This next step creates a structured variable that contains all of the input varaibles above
  STARTING_VARIABLES=CREATE_STRUCT('FIELD01', PROC_FILE, 'FIELD02', DIMG_FILE, 'FIELD03', DATE, 'FIELD04', START_TIME_SEC, 'FIELD05', END_TIME_SEC, 'FIELD06', $
    Display_rejected_particles, 'FIELD07', minD, 'FIELD08', maxD, 'FIELD09', Output_file_path, 'FIELD10', Output_File_type)
ENDIF ELSE BEGIN

  ;opens a dialog box that allows the user to select which document to choose from. 
  IF (FILE_RUN EQ 1) THEN BEGIN
    INFILE= DIALOG_PICKFILE(PATH=file_directory, /READ, /MUST_EXIST)
  ENDIF
  
  ;if not infile is slected then the progam will quit and display the message below 
  IF (INFILE EQ '') THEN BEGIN
    PRINT, 'A FILE MUST BE SELECTED' 
    PRINT, 'ENDING PROGRAM' 
    STARTING_VARIABLES= CREATE_STRUCT('FIELD01','NO_FILE')
    RETURN, STARTING_VARIABLES
  ENDIF
  
  
  ;record count is how many lines are in the CSV, this tells the function when to stop reading the file.  
  RECORD=READ_CSV(INFILE, COUNT=RECORD_COUNT)
  ;this time we read the csv at the desired line(file_run) one at a time
  STARTING_VARIABLE= READ_CSV(INFILE, NUM_RECORDS=1, RECORD_START=FILE_RUN)
  ;this adds some important variables to the structured variable so they can be passed back. 
  STARTING_VARIABLES= CREATE_STRUCT(STARTING_VARIABLE, 'FIELD13', FILE_RUN, 'FIELD14', RECORD_COUNT, 'FIELD15', INFILE)
  LINE_READ_VARIABLE=starting_variables.field12
ENDELSE



;RETURNS A STRUCTURED VARIABLE CONSISTING OF; PROC FILE, DIMG FILE, DATE, START TIME SEC, END TIME SEC, PARTICLES TOUCHING EDGE,
;BAD REJECT, minD, maxD, OUTPUT FILE PATH, OUTPUT FILE TYPE
;IF THERE IS A .CSV FILE BEING USED THEN THE LINE_READ_VARIABLE, FILE RUN, RECORD COUNT, AND INFILE WILL BE IN THE STRUCTURE AS WELL. 
RETURN, STARTING_VARIABLES

END

