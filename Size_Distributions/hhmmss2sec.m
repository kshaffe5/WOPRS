function [seconds]=hhmmss2sec(hhmmss_time)

hours = floor(hhmmss_time/10000);
minutes = floor(rem(hhmmss_time,10000)/100);
seconds = rem(hhmmss_time,100);

seconds = hours*3600 + minutes*60 + seconds;

end