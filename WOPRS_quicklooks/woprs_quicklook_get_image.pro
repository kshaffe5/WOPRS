
FUNCTION WOPRS_QUICKLOOK_GET_IMAGE, STARTING_VARIABLES, FILE_VARIABLES, RUNNING_VARIABLES, FIRST, LAST, STP, TOT_SLICE, STOP_VARIABLE
  ;Unpacks structured varaibles that were defined by the previous functions
  ;This first block is from STARTING_VARIABLES
  PROC_FILE=STARTING_VARIABLES.FIELD01
  DIMG_FILE=STARTING_VARIABLES.FIELD02

  Display_rejected_particles=STARTING_VARIABLES.FIELD06
  minD=LONG(STARTING_VARIABLES.FIELD07)
  maxD=LONG(STARTING_VARIABLES.FIELD08)
  ;The next variable is from FILE_VARAIBLES
  PRBTYPE=FILE_VARIABLES.PRBTYPE
  ;The last block is from RUNNING_VARIABLES
  POS=RUNNING_VARIABLES.POS
  REC=RUNNING_VARIABLES.REC

  POISSON_CORRECTED=RUNNING_VARIABLES.POISSON_CORRECTED
  ARTIFACT_STATUS=RUNNING_VARIABLES.ARTIFACT_STATUS
  
  interarrival_reject=RUNNING_VARIABLES.interarrival_reject
  
  channel=RUNNING_VARIABLES.channel
  in_status=RUNNING_VARIABLES.in_status
  num_holes=RUNNING_VARIABLES.num_holes
  SCNT=RUNNING_VARIABLES.SCNT
  diam=RUNNING_VARIABLES.diameter
  DISP_PARTS=RUNNING_VARIABLES.DISP_PARTS
  POS_DISP=RUNNING_VARIABLES.POS_DISP
  PART_CNT=RUNNING_VARIABLES.PART_CNT
  TIME_DISP=RUNNING_VARIABLES.TIME_DISP
  TMP_LENGTH=RUNNING_VARIABLES.TMP_LENGTH
  TMP_WIDTH=RUNNING_VARIABLES.TMP_WIDTH
  DATA_WIDTH=RUNNING_VARIABLES.DATA_WIDTH
  DATA_LENGTH=RUNNING_VARIABLES.DATA_LENGTH
  HHMMSS=RUNNING_VARIABLES.HHMMSS

  ;makes array for use later
  position= make_array(1701, VALUE=-999)

  ;opens up DIMG and PROC files
  PROC= ncdf_open(PROC_file)
  DIMG= ncdf_open(DIMG_file)

  ;Intializes/resets varaibles
  stp= -1
  stt= -1

  FOR i = first, last DO BEGIN
    IF (scnt[i] LT 1) THEN CONTINUE ;particle has no slice count, skip it
    
    IF (Display_rejected_particles EQ 'off') OR (Display_rejected_particles EQ 'OFF') THEN BEGIN
        ;with our data sets we found that the following particle rejections were ok and should be included: 48,104,72,117,82
;        IF ((ARTIFACT_STATUS[I] NE 1) OR (in_status[I] NE 65)) THEN CONTINUE
;        IF (num_holes[I] NE 1) THEN CONTINUE
;        IF (H_or_V[I] NE 1) THEN CONTINUE
;        IF (ARTIFACT_STATUS[I] NE 1) THEN CONTINUE
;        IF (DIAM[I] LT 50) THEN CONTINUE
;        IF (POISSON_CORRECTED[I] NE 1) THEN CONTINUE
        IF (interarrival_reject[I] NE 1) THEN CONTINUE ;NE 1 for below threshold, NE 0 for above
    ENDIF 

    ;If auto_reject is equal to 122 then this means that particle has a zero diameter image(in other words it should be a blank space). But that is not always the case.
    ;Due to the computer thinking that it is a zero diameter image it has a diameter of not a number (NaN).
    ;If we want to display rejected particles and set a minium or maxium diameter past 0 or 15000 then we want to be able to read the diameter of every particle
    ;The following lines allow use to not display a particle if we are setting a set of diameters and if we are displaying rejected particles.
    ;If we do not want to display rejected particles then we will dismiss all paticles that have a auto_reject of 50 or higher thus stopping this issues befor it occurs.
    IF (minD GT 0) OR (maxD LT 15000) THEN BEGIN
      IF (ARTIFACT_STATUS[i] EQ 2) THEN CONTINUE

    ENDIF
    
    IF (diam[i] LT minD) THEN CONTINUE        ;particle is too small, skip it
    IF (diam[i] GT maxD) THEN CONTINUE        ;particle is too large, skip it
    disp_parts=temporary(disp_parts)+1
    pos_disp[part_cnt] = tot_slice
    tot_slice = tot_slice+scnt[i]+1        ;particle is accepted add slices to the buffer, plus 1 for an empty slice


    IF (stt EQ -1) THEN Stt = i   ;if this is the first particle in buffer, set stt
    stp = i                     ;assume it is last particle in buffer (this will get overwritten on next iteration if it is not)

    ;If we have more than tmp_length slices, our buffer is full (this depends on probe type)
    IF (TOT_SLICE GE tmp_length) THEN BEGIN
      stp=i-1
      time_disp[part_cnt] = -999
      pos_disp[part_cnt] = -999
      BREAK
    ENDIF
    part_cnt=temporary(part_cnt)+1
  ENDFOR

  ;figures out what times the particles are at, this is used in the buffer titles
  time_dis_stt= hhmmss(stt)
  time_dis_stp= hhmmss(stp)

  ;Determine how many data records to retrieve
  rec_cnt = rec[[stp]]-rec[[stt]]+1
  ;if the program gets here and the stp is still -1 then it will repeat this while loop forever, the following fixes that before a buffer is drawn
  IF (STP EQ -1) THEN BEGIN
    STOP_VARIABLE='ON'
    RETURN, 0
  ENDIF


  ;get the data and put the good particles in the display buffers
  varid = NCDF_VARID(DIMG, 'data')
  NCDF_VARGET, DIMG, varid, tmp_data, OFFSET=[0,0,rec[Stt]],COUNT=[data_width,data_length,rec_cnt]
  IF prbtype EQ 'CIPG' THEN tmp = LONARR(tmp_width, tmp_length)+3 ELSE tmp = LONARR(tmp_width, tmp_length)

  x=0
  arr_pos = 0
  FOR i = stt, stp DO BEGIN
    IF (scnt[i] LT 1) THEN CONTINUE ;particle has no slice count, skip it

    IF (Display_rejected_particles EQ 'off') OR (Display_rejected_particles EQ 'OFF') THEN BEGIN
      ;with our data sets we found that the following particle rejections were ok and should be included: 48,104,72,117,82
;        IF ((ARTIFACT_STATUS[I] NE 1) OR (in_status[I] NE 65)) THEN CONTINUE
;        IF (num_holes[I] NE 1) THEN CONTINUE
;        IF (H_or_V[I] NE 1) THEN CONTINUE
;        IF (ARTIFACT_STATUS[I] NE 1) THEN CONTINUE
;        IF (DIAM[I] LT 50) THEN CONTINUE
;        IF (POISSON_CORRECTED[I] NE 1) THEN CONTINUE
        IF (interarrival_reject[I] NE 1) THEN CONTINUE ;NE 1 for below threshold, NE 0 for above
    ENDIF
   
   ;If auto_reject is equal to 122 then this means that particle has a zero diameter image(in other words it should be a blank space). But that is not always the case. 
   ;Due to the computer thinking that it is a zero diameter image it has a diameter of not a number (NaN). 
   ;If we want to display rejected particles and set a minium or maxium diameter past 0 or 15000 then we want to be able to read the diameter of every particle
   ;The following lines allow use to not display a particle if we are setting a set of diameters and if we are displaying rejected particles. 
   ;If we do not want to display rejected particles then we will dismiss all paticles that have a auto_reject of 50 or higher thus stopping this issues befor it occurs.   
   IF (minD GT 0) OR (maxD LT 15000) THEN BEGIN
    IF (ARTIFACT_STATUS[i] EQ 2) THEN CONTINUE
   ENDIF
    
    IF (diam[i] LT minD) THEN CONTINUE        ;particle is too small, skip it
    IF (diam[i] GT maxD) THEN CONTINUE        ;particle is too large, skip it

    tmp[*,arr_pos:arr_pos+scnt[i]-1] = tmp_data[*,pos[1,i]-scnt[i]+1:pos[1,i],rec[i]-rec[stt]]

    ;for 2DS data, if all diodes are blocked, the cdf file shows everything unblocked....following fixes that
    inds = WHERE( TOTAL(tmp[*,arr_pos:arr_pos+scnt[i]-1],1) EQ 0)
    IF (inds[0] NE -1) THEN tmp[*,arr_pos+inds] = 65535
   
    arr_pos = arr_pos+scnt[i]+1               ;the 1 is to add an empty slice between particles to make it easier to see on paper

    position[x,0]=arr_pos
    x=x+1
  ENDFOR
  


  ;now that we have filled the buffer with our data, we will transpose the data into displayable images.
  ;The following statements build the data records based on probe type
  CASE 1 of
    prbtype EQ '2DS' or prbtype EQ 'HVPS': BEGIN
      if (stp eq -1) then break
      data_record = BYTARR(128,1700)
      ;close,1
      ;convert to binary
      FOR k=0,1700-1 DO BEGIN
        FOR j=0,7 DO BEGIN
          FOR i = 16, 31 DO BEGIN
            pow2 = 2L^(i-16)
            IF (LONG(tmp[j,k]) AND pow2) NE 0 THEN $
              data_record[j*16L+(i-16),k]=0 ELSE data_record[j*16L+(i-16),k]=255
          ENDFOR
          data_record[j*16L:j*16L+15,k] = REVERSE(data_record[j*16L:j*16L+15,k],1)
        ENDFOR
      ENDFOR

      data_record = REFORM(data_record)
      tmp = data_record
      data_record=LONARR(134,1706)
      data_record[3:130,3:1702]=tmp
      

    END
    ; if using CIP rather than CIPG data you will need to uncomment this section below, it is folded up
    ;    prbtype EQ 'CIP' : BEGIN
    ;      data_record=BYTARR(32,512)
    ;      ;convert to binary
    ;      FOR k=0,512-1 DO BEGIN
    ;        FOR j=0,31 DO BEGIN
    ;          FOR i = 24, 31 DO BEGIN
    ;            pow2 = 2L^(i-24)
    ;            IF (LONG(tmp[j,k]) AND pow2) NE 0 THEN $
    ;              data_record[j*8L+(i-24),k]=0 ELSE data_record[j*8L+(i-24),k]=255
    ;          ENDFOR
    ;          data_record[j*8L:j*8L+7,k] = REVERSE(data_record[j*8L:j*8L+7,k],1)
    ;        ENDFOR
    ;      ENDFOR
    ;
    ;      data_record = REFORM(data_record)
    ;      ;for CIP data, if all diodes are blocked, the cdf file shows everything unblocked....following fixes that
    ;      end_buf=1
    ;      FOR i=850-1,0,-1 DO BEGIN
    ;        IF(TOTAL(data_record[*,i]) EQ 64 ) THEN data_record[*,i]=0
    ;      ENDFOR
    ;
    ;      ;the following draws a border around the buffer
    ;      tmp = data_record
    ;      data_record=LONARR(68,854)
    ;      data_record[2:65,2:851]=tmp
    ;    END

    prbtype EQ 'CIPG' : BEGIN
      data_record=BYTARR(64,850)
      ;convert to binary
      FOR k=0,850-1 DO BEGIN
        FOR j=0,63 DO BEGIN
          IF (LONG(tmp[j,k]) LE 2) THEN $
            data_record[j,k]=0 ELSE data_record[j,k]=255
          data_record[j,k] = REVERSE(data_record[j,k],1)
        ENDFOR
      ENDFOR

      data_record = REFORM(data_record)

      ;for CIP data, if all diodes are blocked, the cdf file shows everything unblocked....following fixes that
      end_buf=1
      FOR i=850-1,0,-1 DO BEGIN
        IF(TOTAL(data_record[*,i]) EQ 64 ) THEN data_record[*,i]=1
      ENDFOR

      ;the following draws a border around the buffer
      tmp = data_record
      data_record=LONARR(68,854)
      data_record[2:65,2:851]=tmp
    END
  ENDCASE
  FINAL_VARIABLES=CREATE_STRUCT('DATA_RECORDS', DATA_RECORD, 'TIME_DIS_STT', TIME_DIS_STT, 'TIME_DIS_STP', TIME_DIS_STP)

  RETURN, FINAL_VARIABLES
END