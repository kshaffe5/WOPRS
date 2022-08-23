FUNCTION WOPRS_QUICKLOOK_READPROC, STARTING_VARIABLES, FILE_VARIABLES, FIRST, LAST, Error_variable, File_run 
;Unpacks variable from starting_variables
PROC_FILE=STARTING_VARIABLES.FIELD01
;Unpacks variables from File_variables
START_TIME=FILE_VARIABLES.START_TIME
END_TIME=FILE_VARIABLES.END_TIME
PRBTYPE=FILE_VARIABLES.PRBTYPE
OUTPUT_FILE_FINAL=FILE_VARIABLES.OUTPUT_FILE_FINAL
START_TIME=LONG(START_TIME)

;Opens the PROC file 
PROC= ncdf_open(PROC_file)

;finds time variable in procfile and grabs data
PROC= ncdf_open(PROC_file)
varid1 = ncdf_varid(PROC,'Time')
ncdf_varget, PROC, varid1, proc_time
hhmmss = long(proc_time)

;Note: On the August 10th flight the HVPS time was behind by about 2 minutes and 20 seconds.
;To make up for this, if the date entered is '20200810' then the time for
;the HVPS will be moved up by 140s. (The HVPS clock was 140s slow (behind))
;the following if statement fixes that
If ((Starting_variables.field03 EQ 20200810) AND (PRBTYPE EQ 'HVPS')) THEN BEGIN
    TEMP=HHMMSS2SEC(Start_time)
    TEMP=TEMP-140
    Start_time=SEC2DECHHMMSS(TEMP)
    TEMP=HHMMSS2SEC(End_time)
    TEMP=TEMP-140
    End_time=SEC2DECHHMMSS(TEMP)
Endif

;sets start particle and end particle based on input times
Start_time_index=where(hhmmss GE Start_time)
start_time_index = start_time_index[0]
End_time_index=where(hhmmss LE end_time)
End_time_index = End_time_index[-1]
STATEMENT= '' 
Error_variable='off' ;default is 'off' if it is turn on then there is an error that has occured with the inputs. See the if statements below for more clarity. 



; The next if statement and case statement are meant to evaluate the start and end times. 
; If the start or end times (or both) are out side of the files time ranges then a multitude of errors can occur. 
; the following staments check for the issues and alerts the user of the issue. 
; It skips over the rendition that had the erorr and and prints a report on the output file
; the program will not stop when these errors occur 
 
IF ((START_TIME_INDEX EQ -1) OR (END_TIME_INDEX EQ -1)) THEN BEGIN
  Error_variable= 'on'
  Statement= 'The desired start and end times are outside of the proc files times.'
ENDIF

CASE 1 OF
  ((Start_time_index EQ 0) AND (End_time_index EQ N_ELEMENTS(hhmmss)-1)) : BEGIN
    PRINT, '********'
    PRINT, 'The start time is less than the start time of the proc file and the end time is greater than the end time of the proc file.' 
    PRINT, 'The whole proc file will be read. This may take a while'
    PRINT, 'Occured on row ' + STRTRIM(string(FILE_RUN+1),2) + ' of the CSV file' 
    PRINT, '********'
  END
  
  (Start_time_index EQ 0) AND STATEMENT EQ '' : BEGIN
    Error_variable= 'on'
    Statement= 'The start time is less than or equal to the first particle in the file, but the end time is ok.'
  END
  
  (End_time_index EQ N_ELEMENTS(hhmmss)-1) AND STATEMENT EQ '': BEGIN
    Error_variable= 'on'
    Statement= 'The end time is greater then or equal to the last particle in the proc file, but the start time is ok.'
  END
  
  ELSE : BREAK
ENDCASE


IF (Error_variable EQ 'on') THEN BEGIN
  PRINT, '********'
  PRINT, 'An issue occured on row ' + STRTRIM(string(FILE_RUN+1),2) + ' of the CSV file'
  PRINT, 'Please see ' + OUTPUT_FILE_FINAL + ' for more information'
  PRINT, '********'
  RUNNING_VARIABLES = CREATE_STRUCT('STATEMENT', STATEMENT)
  RETURN, RUNNING_VARIABLES
ENDIF


; finds postion of the particle
varid = NCDF_VARID(PROC, 'position')
NCDF_VARGET, PROC, varid, pos
pos=pos-1

;finds slice count of the particles
varid = NCDF_VARID(PROC, 'slicecount')
NCDF_VARGET, PROC, varid, scnt

;finds the parent rec number for the particles
varid = NCDF_VARID(PROC, 'parent_rec_num')
NCDF_VARGET, PROC, varid, rec
rec=rec-1 ;idl counts from zero, the files count from 1

varid = NCDF_VARID(PROC, 'artifact_status')
NCDF_VARGET, PROC, varid, artifact_status
varid = NCDF_VARID(PROC, 'interarrival_reject')
NCDF_VARGET, PROC, varid, interarrival_reject
varid = NCDF_VARID(PROC, 'poisson_corrected')
NCDF_VARGET, PROC, varid, poisson_corrected
varid = NCDF_VARID(PROC, 'channel')
NCDF_VARGET, PROC, varid, channel
varid = NCDF_VARID(PROC, 'number_of_holes')
NCDF_VARGET, PROC, varid, num_holes
varid = NCDF_VARID(PROC, 'number_of_pieces')
NCDF_VARGET, PROC, varid, num_pieces
varid = NCDF_VARID(PROC, 'diameter')
NCDF_VARGET, PROC, varid, diam
varid = NCDF_VARID(PROC, 'in_status')
NCDF_VARGET, PROC, varid, in_status
varid = NCDF_VARID(PROC, 'area_ratio')
NCDF_VARGET, PROC, varid, area_ratio
varid = NCDF_VARID(PROC, 'roundness')
NCDF_VARGET, PROC, varid, roundness
varid = NCDF_VARID(PROC, 'circularity')
NCDF_VARGET, PROC, varid, circularity
varid = NCDF_VARID(PROC, 'aspect_ratio')
NCDF_VARGET, PROC, varid, aspect_ratio


;Loop over all particles -- first and last are provided and currently represent the first
;  and last *possible* particle to be displayed based on start and end times and what is
;  being currently displayed (if anything)
time_disp= LONARR(1700)-999
pos_disp = LONARR(1700)-999
part_cnt = 0L
disp_parts=(0L)

;sets data length and width based on probe type
CASE 1 OF
  prbtype EQ '2DS' or prbtype EQ 'HVPS': BEGIN
    data_length = 1700
    data_width = 8
    tmp_length = 1700
    tmp_width = 8
  END
  prbtype EQ 'CIP' : BEGIN
    data_length = 1700
    data_width = 8
    tmp_length = 850
    tmp_width = 8
  END
  prbtype EQ 'CIPG' : BEGIN
    data_length = 512
    data_width = 64
    tmp_length = 850
    tmp_width = 64
  END
ENDCASE

;Creates a structured variable consisting of; HHMMSS, START_TIME_INDEX, END_TIME_INDEX, POSITION, SLICE COUNT, RECORD NUMBER, $
  ;PARTICLES TOUCHING THE EDGE, AUTO REJECT, DIAMETER OF PARTICLES, TIME DISP, POSIBLE DISPLAY, PART COUNT, DIPSLAYED PARTS, 
  ;DATA LENGTH, DATA WIDTH, TMP LENGTH, AND TEMP WIDTH
RUNNING_VARIABLES=CREATE_STRUCT('HHMMSS', HHMMSS, 'START_TIME_INDEX', START_TIME_INDEX, 'END_TIME_INDEX', END_TIME_INDEX, $
  'POS', POS, 'SCNT', SCNT, 'REC', REC, 'ARTIFACT_STATUS', artifact_status, 'interarrival_reject', interarrival_reject, 'DIAMETER', DIAM, 'POISSON_CORRECTED',poisson_corrected, $
  'TIME_DISP', TIME_DISP, 'POS_DISP', POS_DISP, 'PART_CNT', PART_CNT, 'DISP_PARTS', DISP_PARTS, 'DATA_LENGTH', DATA_LENGTH,'roundness',roundness, 'num_pieces', num_pieces, $
  'DATA_WIDTH', DATA_WIDTH, 'TMP_LENGTH', TMP_LENGTH, 'TMP_WIDTH', TMP_WIDTH,'num_holes',num_holes,'channel', channel,'in_status',in_status,'area_ratio',area_ratio,'circularity',circularity,'aspect_ratio',aspect_ratio)

; CREATES THE FIRST AND LAST VARIABLE, THESE REPRESENT THE FIRST AND LAST POSSIBLE PARTICLES WITHIN THE GIVEN TIME
;THESE GET SENT BACK TO THE MASTER PROGRAM
first= Start_time_index
last= End_time_index

;sends the structured varaible back to the master program  
RETURN, RUNNING_VARIABLES

END