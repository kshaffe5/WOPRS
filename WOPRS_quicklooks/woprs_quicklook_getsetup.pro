FUNCTION WOPRS_QUICKLOOK_GETSETUP, INPUT_TYPE, FILE_RUN, RECORD_COUNT, INFILE, LINE_READ_VARIABLE, file_directory
;*********************************************************************************************************************************************
;*********************************************************************************************************************************************
;if you are putting in custom data please use the section below to input all the varaibles. 
IF(INPUT_TYPE EQ 'CUSTOM') OR (INPUT_TYPE EQ 'custom')THEN BEGIN 
  DIMG_file= '/home/projectname/DIMG.datetime.2DS.cdf' ;ex. '/kingair_data/hcpi20/OAP_processed/20200811/DIMG.200811193926.2DS.H.cdf'
  PROC_file= '/home/projectname/PROC.datetime.2DS.cdf' ;ex  '/kingair_data/hcpi20/OAP_processed/20200811/PROC.200811193926.2DS.H.cdf'
  DATE= 20170118;ex. 20200811
  Start_time_sec= 77399;these need to be in sec, ex. 72936
  End_time_sec=  82487;make sure start time is less then end time
  Output_file_path= '/home/username' ;the actual name of the file will set at the end of the file automaticaly. We need the start/end times in hhmmss first.
  Output_File_type= '.pdf' ; select the file type you would like your saved file to be. '.pdf' , '.png' , etc.

  ;SET ANY FILTERS BELOW. IF EVERYTHING IS SET TO 'ON', THEN NO FILTERS ARE APPLIED
  Display_rejected_particles= 'off' ; ON= rejected particles ARE SHOWN, OFF=rejected particles ARE NOT SHOWN; assign the desired artifact statuses below
  good_artifacts = [1]
  Display_all_diams = 'on'
  minD= 0  ;minimum particle diameter in microns, default is 0. -999 includes
  maxD= 15000000  ;maximum particle diameter in microns, default 15000
  Display_interarrival_rejected = 'on'
  Display_all_in_statuses = 'off'
  good_in_status = [65] ;only used if Display_all_in_statuses = 'off'. 79='O'=center-out, 73='I'=center-in, 65='A'=all-in
  Display_any_holes = 'on'
  max_holes = 5 ;only used if Display_any_holes = 'off'
  min_holes = 0 ;only used if Display_any_holes = 'off'
  Display_any_pieces = 'on'
  max_pieces = 10 ;only used if Display_any_pieces = 'off'
  min_pieces = 0 ;only used if Display_any_pieces = 'off'
  Display_Poisson_corrected = 'on'
  Display_not_Poisson_corrected = 'on'
  Display_all_aspect_ratios = 'on'
  max_aspect_ratio = 2 ;only used if Display_all_aspect_ratios = 'off'
  min_aspect_ratio = 1 ;only used if Display_all_aspect_ratios = 'off'
  Display_all_circ = 'on'
  max_circ = 1 ;only used if Display_all_circ = 'off'
  min_circ = 0.8 ;only used if Display_all_circ = 'off'
  Display_all_roundness = 'on'
  max_roundness = 0.9 ;only used if Display_all_roundness = 'off'
  min_roundness = 0.5 ;only used if Display_all_roundness = 'off'
  Display_markings_between_images = 'off' ;Display a hash mark at the top of the buffer indicating a break between two images
;*********************************************************************************************************************************************
;*********************************************************************************************************************************************
  
  
  ;This next step creates a structured variable that contains all of the input varaibles above
  STARTING_VARIABLES=CREATE_STRUCT('FIELD01', PROC_FILE, 'FIELD02', DIMG_FILE, 'FIELD03', DATE, 'FIELD04', START_TIME_SEC, 'FIELD05', END_TIME_SEC, 'FIELD06', $
    Display_rejected_particles, 'FIELD07', minD, 'FIELD08', maxD, 'FIELD09', Output_file_path, 'FIELD10', Output_File_type, 'FIELD11', good_artifacts, 'FIELD12', good_in_status, $
    'FIELD13', Display_interarrival_rejected, 'FIELD14', Display_all_diams, 'FIELD15', Display_all_in_statuses,'FIELD16', Display_any_holes,'FIELD17', max_holes,'FIELD18', min_holes, $
    'FIELD19', Display_any_pieces,'FIELD20', max_pieces,'FIELD21', min_pieces,'FIELD22', Display_Poisson_corrected,'FIELD23', Display_not_Poisson_corrected, $
    'FIELD24', Display_all_aspect_ratios,'FIELD25', max_aspect_ratio,'FIELD26', min_aspect_ratio,'FIELD27', Display_all_circ,'FIELD28', max_circ,'FIELD29', min_circ, $
    'FIELD30', Display_all_roundness, 'FIELD31', max_roundness, 'FIELD32', min_roundness, 'FIELD33', Display_markings_between_images)
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

