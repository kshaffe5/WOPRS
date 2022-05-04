FUNCTION WOPRS_QUICKLOOK_FILES, STARTING_VARIABLES, DELETE_FILE, FILE_DELETE_STOP_VARIABLE, File_run

;this step unpacks the varaibles that we created in WOPRS_quicklook_GETSETUP function
PROC_FILE=STARTING_VARIABLES.FIELD01
DIMG_FILE=STARTING_VARIABLES.FIELD02
DATE=STARTING_VARIABLES.FIELD03
START_TIME_SEC=STARTING_VARIABLES.FIELD04
END_TIME_SEC=STARTING_VARIABLES.FIELD05
OUTPUT_FILE_PATH=STARTING_VARIABLES.FIELD09
OUTPUT_FILE_TYPE=STARTING_VARIABLES.FIELD10

START_TIME_SEC= STARTING_VARIABLES.FIELD04[0]
END_TIME_SEC= STARTING_VARIABLES.FIELD05[0]
Stop_variable= 'off' ;default is off. if it is turned on then the function will return to the main program with out any information

;checks to see if files match up
if (STRPOS(PROC_File, '2DS.H')) NE (STRPOS(DIMG_file, '2DS.H')) THEN Stop_variable = 'on' 
if (STRPOS(PROC_File, '2DS.V')) NE (STRPOS(DIMG_file, '2DS.V')) THEN Stop_variable = 'on' 
if (STRPOS(PROC_File, 'HVPS')) NE (STRPOS(DIMG_file, 'HVPS')) THEN Stop_variable = 'on' 
if (STRPOS(PROC_File, 'CIP')) NE (STRPOS(DIMG_file, 'CIP')) THEN Stop_variable = 'on' 
if (STRPOS(PROC_File, 'cip')) NE (STRPOS(DIMG_file, 'cip')) THEN Stop_variable = 'on' 


IF Stop_variable EQ 'on' THEN BEGIN
  print, '******'
  print, 'DIMG and PROC unmatched, check probe type and spelling'
  PRINT, 'Occured on row ' + STRTRIM(string(FILE_RUN+1),2) + ' of the CSV file' 
  print, '******'
ENDIF


;using file name program checks and sets probe type
IF (STRPOS(PROC_file, '2DS') GE 0) THEN  prbtype = '2DS'
IF (STRPOS(PROC_file, 'HVPS') GE 0) THEN  prbtype = 'HVPS'
IF (STRPOS(PROC_file, 'CIP') GE 0) THEN  prbtype = 'CIP'
IF (STRPOS(PROC_file, 'cip') GE 0) THEN  prbtype = 'CIPG'
IF (STRPOS(PROC_file, 'CIPG') GE 0) THEN  prbtype = 'CIPG'
IF (((STRPOS(PROC_file, '2DS')) AND (STRPOS(PROC_file, 'HVPS'))  AND (STRPOS(PROC_file, 'CIP')) AND (STRPOS(PROC_file, 'cip'))) LT 0) THEN BEGIN
  print, '******'
  PRINT, 'Unsupported probe type, line skipped'
  PRINT, 'Occured on row ' + STRTRIM(string(FILE_RUN+1),2) + ' of the CSV file'
  print, '******'
  Stop_variable= 'on'
ENDIF

If Stop_variable EQ 'on' THEN BEGIN
  FILE_VARIABLES= CREATE_STRUCT('Stop_variable', Stop_variable)
  RETURN, FILE_VARIABLE
Endif


; uses file name again but more specified search used for titles.This matters for 2DS and cip type probes.
IF (STRPOS(PROC_file, '2DS.H') GE 0) THEN  prbtype_t = '2DS.H'
IF (STRPOS(PROC_file, '2DS') GE 0) THEN  prbtype_t = '2DS'
IF (STRPOS(PROC_file, '2DS.V') GE 0) THEN  prbtype_t = '2DS.V'
IF (STRPOS(PROC_file, 'HVPS') GE 0) THEN  prbtype_t = 'HVPS'
IF (STRPOS(PROC_file, 'CIP') GE 0) THEN  prbtype_t = 'CIP'
IF (STRPOS(PROC_file, 'cip') GE 0) THEN  prbtype_t = 'CIPG'
IF (STRPOS(PROC_file, 'CIPG') GE 0) THEN  prbtype_t = 'CIPG'

;turns input times into hhmmss
Start_time= sec2dechhmmss(Start_time_sec)
End_time= sec2dechhmmss(End_time_sec)

;counter is a varaible used to count how many times a specific file name exisit within a directory. It will change in the while loop below. 
;the two if statements change capatilzation of the strings to ensure proper exicution.
counter= 1
IF Delete_file EQ 'off' OR Delete_file EQ 'Off' THEN Delete_file = 'OFF'
IF Delete_file EQ 'on' OR Delete_file EQ 'On' THEN Delete_file = 'ON'

;creates a the final output file name
Output_file_final= Output_file_path + '/' + STRTRIM(string(prbtype_t),2) +'/' + 'CPI_' + STRTRIM(string(date),2) +'_'+ STRTRIM(string(start_time),2) + $
  '-' + STRTRIM(string(End_time),2) + '_UTC_' + STRTRIM(string(prbtype_t),2) +'_'+ Output_file_type

;checks to see if the output file already exist and then out puts a message based on previous selections of delete file
result= FILE_TEST(output_file_final)

;if the file exists and the user doesnt want to delete any files then this will give an output mesage to the idl promp. 
;it will also add a (#) to the end of the output file name. This number will change based on how many times we go through the while loop. 
IF (Result EQ 1) AND (Delete_file EQ 'OFF') THEN BEGIN
  print, '********'
  print, 'This file already exist and File_delete indicates that you do not want to delete file.'  

  
  WHILE (Result EQ 1) DO BEGIN
    Output_file_final= Output_file_path + '/' + STRTRIM(string(prbtype_t),2) + '/' + 'CPI_' + STRTRIM(string(date),2) +'_'+ STRTRIM(string(start_time),2) + $
      '-' + STRTRIM(string(End_time),2) + '_UTC_' + STRTRIM(string(prbtype_t),2)+ '(' + STRTRIM(string(counter),2) +')'+ Output_file_type
    result= FILE_TEST(output_file_final)
    counter= counter+1
  ENDWHILE
  
  PRINT, '(' + STRTRIM(STRING(COUNTER-1),2) + ')  will be added to the output file'
  print, 'Occured on line '  + STRTRIM(string(FILE_RUN+1),2) + ' of the CSV file'
  print, '********'
ENDIF

;if file already exists and delete file is set to yes then the file will be deleted
If (result EQ 1) AND (Delete_file EQ 'ON') THEN BEGIN
  print, '********'
  print, 'The file:   ' + output_file_final 
  print, 'has been deleted because it matches the output files name'
  openu, 1, output_file_final, /DELETE
  close, 1
  print, 'Occured on '  + STRTRIM(string(FILE_RUN+1),2) + ' of the CSV file'
  print, '********'
ENDIF
  
; CREATES A STRUCTURED VARIABLE CONSITING OF; START TIME, END TIME, OUTPUT_FILE_FINAL, AND PRBTYPE
FILE_VARIABLES= CREATE_STRUCT('START_TIME', START_TIME, 'END_TIME', END_TIME, 'OUTPUT_FILE_FINAL', OUTPUT_FILE_FINAL, $
  'PRBTYPE', PRBTYPE, 'PRBTYPE_T', PRBTYPE_T, 'STOP_VARIABLE', STOP_VARIABLE)
RETURN, FILE_VARIABLES


END