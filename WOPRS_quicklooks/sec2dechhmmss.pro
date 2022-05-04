;*******************************************************************************
;
Function sec2dechhmmss, hhmmss

  hours=floor(hhmmss/3600L)
  minutes=floor((hhmmss-(hours*3600))/60L)
  seconds=(hhmmss-(hours*3600)-(minutes*60))
  new_val=(hours*10000)+(minutes*100)+seconds
  Return, new_val

END
