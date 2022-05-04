PRO WOPRS_QUICKLOOK
;User input is needed for the INPUT_TYPE, file-directory and DELETE_FILE
;would you like to input custom data or read data from a .CSV file
;IF A CSV FILE IS BEING USED PLEASE HAVE THE ORDER OF THE COLLUMS AS FOLLOWS
;PROC_FILE, DIMG_FILE, DATE, START_TIME_SEC, END_TIME_SEC, Display_particles_touching_edge, Display_rejected_particles, minD, maxD, OUTPUT_FILE_PATH, OUTPUT_FILE_TYPE(pdf or png), READ_ROW(SKIP OR RUN)
;if you are doing a custom input, please input your variables into the WOPRS_quicklook_GETSETUP function
INPUT_TYPE='custom' ; the two options for this varaible are 'file' or 'custom'. If file is selected FILE you will be promptED to pic a .csv file
;File_directory is where the diolg box in WOPRS_quicklook_GETSETUP should be looking. this can be a broad search or narrow. 
;It can be left blank if the directory is not know or if INPUT_TYPE= 'custom' 
file_directory='/home/kshaffe5/Thesis/test_files/'
;!!!!!!!!
;If the DELETE_FILE feature is on, and the output_file_final matches an existing file then the file will be deleted to allow for a new one
;The program will pause before a file is deleted and show a message that a file is about to be deleted.
;If you have 'OFF' selected and a file with a matching name exist then the program will show a message and then change the file name to include (#) at the end of the file name
;OFF=no files will be deleted, ON=files will be deleted
DELETE_FILE= 'ON' 


;Intializes varaibles
FILE_RUN=0  ;file_run is tells us which row we should be reading from the csv file, this will increase by 1 each time the file is read.
RECORD_COUNT=1  ;record_count tells us how many rows are in the csv file, this will get changed once the csv file is read in the WOPRS_quicklook_getsetup function 
INFILE='' ;the infile is csv file that we will be reading from, the user will be prompted to choose a csv in the WOPRS_quicklook_getsetup function
FIRST=0 ;this is the start time index, this will be changed in WOPRS_quicklook_READPROC
LAST=1  ;this is the end_time index, this will be changed in WOPRS_quicklook_READPROC
STP=-1  ;this is the last possible particle in the display buffer, this will be changed in WOPRS_quicklook_GET_IMAGE
RUN=1    ;Run tells us how many times we have gone through the while loop. It is set to 2 intially to allow for the buffers to be offest for the intial page
TOT_SLICE = 0 ;this is how many buffers the slice has
STOP_VARIABLE='OFF' ;the stop varaible tells us if there are no more particles in a possible time frame. The default is off, if it is turn to on then the program will act accordingly
LINE_READ_VARIABLE='run' ;this is the default if we want to run through a custom entry. 
page=1 ;this is the page counter for the pdf
Error_variable= 'OFF' ; this is used if there is an issue with the start and end times and how they relate to the file times
Statement= '' ;if the error_variable is on then a statement is attached to the resulting output file 
first_run=1  ;this is used to see if there are any partilces within the given considerations. If there are no particles then a message is added to the output file. 




;Starts a while loop that allows us to run the whole program multiple times. This is useful when a CSV file is used as the input_type. 
;file run is the row which should be read in the csv, if custom data is used file run is just a place holder to get out of the while loop. 
;record count is how many rows there are in the csv file. if custom data is used then it is a place holder to get out of the while loop. 
;this while loop will run until the the lines that we have read from the csv file equals the amount of lines in the csv file. if custom data is used the while loop will only happen once. 
WHILE (FILE_RUN LT RECORD_COUNT) DO BEGIN

  File_run= File_run+1 ;adds another run to our running total of how many lines from the csv file have been read.
 
  ;WOPRS_quicklook_GETSETUP function allows for the user to either put in custom varaibles or use a .csv based on INPUT_TYPE
  ;This function puts all the varaibles to be used into a structured varaible.
  ;This structured varaible will then be used in several other functions.
  ;RETURNS A STRUCTURED VARIABLE CONSISTING OF; PROC FILE, DIMG FILE, DATE, START TIME SEC, END TIME SEC, PARTICLES TOUCHING EDGE,
  ;BAD REJECT, minD, maxD, OUTPUT FILE PATH, OUTPUT FILE TYPE
  ;IF THERE IS A .CSV FILE BEING USED THEN THE FILE RUN, RECORD COUNT, AND INFILE WILL BE IN THE STRUCTURE AS WELL.
   STARTING_VARIABLES= WOPRS_QUICKLOOK_GETSETUP(INPUT_TYPE, FILE_RUN, RECORD_COUNT, INFILE, LINE_READ_VARIABLE, file_directory)

  ;If this is equal to no_file then the user did not put in a input file and so we want to exit the program. 
  IF STARTING_VARIABLES.FIELD01 EQ 'NO_FILE' THEN RETURN
  
  ;THIS TRANSLATES THE STARTING.VARIABLE INTO DIFFERNT VARAIBLES THAT ARE USED IN IF A CSV FILE IS BEING READ. 
  IF INPUT_TYPE EQ 'FILE' OR INPUT_TYPE EQ 'file' THEN BEGIN 
    FILE_RUN=STARTING_VARIABLES.FIELD13
    RECORD_COUNT=STARTING_VARIABLES.FIELD14
    INFILE=STARTING_VARIABLES.FIELD15
  ENDIF 
  
  ;If this line has the keyword skip asssiated with the last collum in the .csv then the program will skip over this line. 
  ;this feature is usefull if the user only wants to read a select few lines from the csv file rather than the whole thing. 
  IF input_type EQ 'file' OR input_type EQ 'FILE' THEN BEGIN
    IF (LINE_READ_VARIABLE EQ 'skip') OR (LINE_READ_VARIABLE EQ 'SKIP') THEN CONTINUE
  ENDIF

  ;checks if times will work, out puts a message and skips that entry if it doesnt
  START_TIME_SEC=STARTING_VARIABLES.FIELD04
  END_TIME_SEC=STARTING_VARIABLES.FIELD05
  IF End_time_sec LT Start_time_sec THEN BEGIN
    PRINT, '*******'
    PRINT, 'Start_time is less than End_time, input new values!'
    PRINT, 'Occured on row ' + STRTRIM(string(FILE_RUN+1),2) + ' of the CSV file' 
    PRINT, '*******'
    Continue
  ENDIF
   

  ;This function reads over the proc and dimg files to make sure that there is good compatiblity. 
  ;It also creates the OUTPUT_FILE_FINAL, which will be used for save function below
  ;it also uses the OUTPUT_FILE_FINAL to check and see if a file alread exists and if it does wheather to delete it or not. 
  ;The conversion of sec to hhmmss can also be found in this program. 
  ;RETURNS A STRUCTURED VARIABLE CONSITING OF; START TIME, END TIME, OUTPUT_FILE_FINAL, PRBTYPE, AND PRBTYPE_T

  FILE_VARIABLES= WOPRS_quicklook_FILES(STARTING_VARIABLES, DELETE_FILE, FILE_DELETE_STOP_VARIABLE, FILE_RUN)
  Stopper=FILE_VARIABLES.STOP_VARIABLE
  IF Stopper EQ 'on' THEN CONTINUE

  ;This function reads through the proc file and finds the discriptions of each of the particles. 
  ;this function also sets the start_time_index and end_time_index. 
  ;It also describes the buffer length and width that should be used based on prop type
  ;RETUNS A STRUCTURED VARIABLE CONSITING OF; HHMMSS, START_TIME_INDEX, END_TIME_INDEX, POSITION, SLICE COUNT, RECORD NUMBER, 
  ;PARTICLES TOUCHING THE EDGE, AUTO REJECT, DIAMETER OF PARTICLES, TIME DISP, POSIBLE DISPLAY, PART COUNT, DIPSLAYED PARTS,
  ;DATA LENGTH, DATA WIDTH, TMP LENGTH, AND TEMP WIDTH
  RUNNING_VARIABLES= WOPRS_quicklook_READPROC(STARTING_VARIABLES, FILE_VARIABLES, FIRST, LAST, Error_variable, File_run)

  ;Unpacks varaibles to use in the title page of the pdf document
  DATE=STARTING_VARIABLES.FIELD03
  START_TIME_SEC=STARTING_VARIABLES.FIELD04
  END_TIME_SEC= STARTING_VARIABLES.FIELD05
  Display_rejected_particles=STARTING_VARIABLES.FIELD06
  minD=STARTING_VARIABLES.FIELD07
  maxD=STARTING_VARIABLES.FIELD08
  
  START_TIME=FILE_VARIABLES.START_TIME
  END_TIME=FILE_VARIABLES.END_TIME
  PRBTYPE_T=FILE_VARIABLES.PRBTYPE_T
  OUTPUT_FILE_FINAL=FILE_VARIABLES.OUTPUT_FILE_FINAL
  
  ;Sets up the first page to display. This will reset each time the program reads a new line from the csv file. 
  ;Puts information at the top of the page including times, date, probe type, pte, bad rejects, and diameter, and a general information sentance in italics
  w=window(dimension=[2550,3330],/buffer)
  n=text(.97,.5, position=[0,.985,.001,.99], font_size= 25, 'PROBE TYPE- ' + prbtype_t)
  n=text(.97,.5, position=[0,.975,.001,.98], font_size= 25, 'DATE-' + STRTRIM(string(Date),2))
  n=text(.97,.5, position=[0,.965,.001,.97], font_size= 25, 'Times in seconds (start-end) ' + STRTRIM(string(Start_time_sec),2) +'-'+ STRTRIM(string(End_time_sec),2) + ' UTC')
  n=text(.97,.5, position=[0,.955,.001,.96], font_size= 25, 'Times in hhmmss (start-end) ' + STRTRIM(string(Start_time),2) + '-' + STRTRIM(string(End_time),2) + ' UTC')
  n=text(.97,.5, position=[0,.945,.001,.95], font_size= 25, 'Diameter in microns (min-max)= ' + STRTRIM(string(minD),2) + '-' + STRTRIM(string(maxD),2))

  IF (Display_rejected_particles EQ 'OFF') OR (Display_rejected_particles EQ 'off') THEN BEGIN
    n=text(.97,.5, position=[0,.925,.001,.93], font_size= 25, 'Only displaying accepted particles (Criteria= (artifact_status[particle]= 0))')
  ENDIF
  IF (Display_rejected_particles EQ 'ON') OR (Display_rejected_particles EQ 'on') THEN BEGIN
     n=text(.97,.5, position=[0,.925,.001,.93], font_size= 25, 'Displaying both accepted and rejected particles') 
  ENDIF  
  n=text(.97,.5, position=[0,.915,.001,.92], font_size= 25,  FONT_STYLE='Italic', 'All particles are displayed when diameters are set to -999-15000, accepted, and rejected particles are displayed')
  
  
  ;If the error_variable is on then there is an issue with the start and end times and how they match up with the proc time file's times
  ;A statement is created and displayed on the output file to tell the user what the issue was with there times. 
  ;The error varaible and statement variables are changed in the WOPRS_quicklook_READPROC function
  IF (ERROR_VARIABLE EQ 'on') THEN BEGIN
    Statement=RUNNING_VARIABLES.STATEMENT
    n=text(.97,.5, position=[0,.8,.001,.85], font_size= 33, 'ISSUE:  ' + STATEMENT)
    w.SAVE, Output_file_final,/close
    CONTINUE
  ENDIF

  ;The while loop will loop over particles till there are no more particles in that given time. This while loop utilizes the WOPRS_quicklook_GET_IMAGE fuction.
  ;The WOPRS_quicklook_GET_IMAGE function utilizes variables all of the above functions. It sends back a structured variable consiting of data records and stt/stp time displays
  ;The WOPRS_quicklook_GET_IMAGE function reads through the PROC and DIMG files to get fill and translate the buffers into data that will be used to build an image. 
  ;After the WOPRS_quicklook_GET_IMAGE function is complete the program then builds an image and writes that to a pdf. No image will be displayed through idl.
  WHILE (STP LE LAST) DO BEGIN
  

    FINAL_VARIABLES= WOPRS_quicklook_GET_IMAGE(STARTING_VARIABLES, FILE_VARIABLES, RUNNING_VARIABLES, FIRST, LAST, STP, TOT_SLICE, STOP_VARIABLE)
    
    ;the stop variable is turned on when there are no more particles to capture during the given time. If the stop_variable is turned on then we break out of this while loop.
    IF (STOP_VARIABLE EQ 'ON')THEN BREAK
    ;if first run equals 2 then we know that we have particles for the given conditions. this will get checked in an if staemnt near the end of the program. 
    first_run=2
    ;prints the page number to the output file
    n=text(.97,.5, position=[.9,.985,.999,.99], font_size= 25, 'Page ' + STRTRIM(string(page),2))

    ;The w.save, /append function is not in a logical place.
    ;There are two issues with having this save function in a more logical place, such as beneath where we create our image. 
    ;we need to use the w.save, /append function to allow us to create multipage pdfs
    ;To use the w.save, /append function we also need to use the w.save,/close function. there are no other closing methods that counter the /append function 
    ;issue 1: because we have to use both the /append and /close function this means that we have to save twice, this leads to duplicate last pages in certain senerios. 
    ;to fix this we tried to not save twice if those senerios we present, this lead to issue 2. 
    ;Issue 2: we didnt want to save twice but we have to use the /append function, but there will be no /close function used. 
    ;this lead to the pdf never being closed and therefore multiple probe types would be on the same pdf document. 
    ;The heart of both of these issues occurs when we have a full page of buffers on the last page on the pdf. 
    ;moving the save function to this location was the best solution that we could find. 
    ;moving the save, /append to here allows the program to save the full window as we normally would and before variables get changed, mainly run, w, and i
    ;It also allows for the program to check to make sure there are more particles before it uses the /append function. 
    ;seeing that the w.save, /append function is beneath the break for the stop variable, 
    ;the program will exit the while loop if there are no more particles before the save, /append is execuited.
    ;When the program breaks out of this while loop, the only save function that can be used is the save, /close.
    IF (run EQ 10) THEN BEGIN
      print, Output_file_final
      w.SAVE, Output_file_final, /Append
      page=page+1
      Run=0
    ENDIF



    ;We unpack the variables that were created from the WOPRS_quicklook_GET_IMAGE fuction below
    DATA_RECORD=FINAL_VARIABLES.DATA_RECORDS
    TIME_DIS_STT=FINAL_VARIABLES.TIME_DIS_STT
    TIME_DIS_STP=FINAL_VARIABLES.TIME_DIS_STP
    Run=Run+1
    
    
    
    ;for the date of the 08/10/2020 the HVPS probe time was behind by about 2 minutes and 20 seconds.
    ;To make up for this, if the date entered is '20200810' then the time for
    ;the HVPS will be moved up by 140s. (The HVPS clock was 140s slow (behind))
    IF ((STARTING_VARIABLES.FIELD03 EQ 20200810) AND (PRBTYPE_T EQ 'HVPS')) THEN BEGIN
      TEMP=HHMMSS2SEC(TIME_DIS_STT)
      TEMP=TEMP+140
      TIME_DIS_STT=SEC2DECHHMMSS(TEMP)
      TEMP=HHMMSS2SEC(TIME_DIS_STP)
      TEMP=TEMP+140
      TIME_DIS_STP=SEC2DECHHMMSS(TEMP)
    ENDIF
    
    ;creates a window for our buffers to be displayed on when doing multiple pages
    IF (Run EQ 1) THEN w=window(dimension=[2550,3330],/buffer)
  
    ;sets up the postion of the buffers based on which run we are on.
    A= (((10.-Run)/10)+.001)
    B= (A+.099) 
   
    ;this puts the buffers in the window
    i=image(transpose(LONG(data_record[*,*])), /current, POSITION=[0,A,1,B], RGB_TABLE=38,  $
      TITLE= STRTRIM(string(time_dis_stt),2) + '-' + STRTRIM(string(time_dis_stp),2) + ' UTC', $
      Font_Size=45)
  
    ;resets variables to allow for another loop
    tot_slice=0
    first= stp + 1
    part_cnt= 0
  ENDWHILE 
  
  ;If first run is equal to 1 when we reach here then that means that there were no particles in the file.
  ;This adds a text to the output file tellign the user why there are no particles
  IF (FIRST_RUN EQ 1) THEN BEGIN
    n=text(.97,.5, position=[0,.8,.001,.85], font_size= 33, 'THERE ARE NO PARTICLES WITHIN THE GIVEN CONDITIONS')
  ENDIF
  
  ;this function saves the window to a pdf. It also closes the pdf, and doesnt allow it to be appended anymore
  w.SAVE, Output_file_final,/close
  page=1

  ;resets the varaibles to allow for another line to be read from a csv file
  STOP_VARIABLE='OFF'
  RUN= 1
  First_run=1
  
ENDWHILE
Print, 'And we are done!!!!!'
END