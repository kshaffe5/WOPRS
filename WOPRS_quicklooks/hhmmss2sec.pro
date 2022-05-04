;*******************************************************************************
;
Function hhmmss2sec, time

  hours=floor(time/10000L)
  time_minus_hours=time-(hours*10000L)
  minutes=floor(time_minus_hours/100L)
  seconds=time - (hours*10000L) - (minutes*100L)
  time=(hours*3600L)+(minutes*60L)+seconds
  Return, time

END
