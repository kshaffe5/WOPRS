function [hhmmss]=sec2hhmmss(seconds)

hours = floor(seconds/3600);
minutes = floor((seconds-hours*3600)/60);
seconds = seconds - (hours*3600) - (minutes*60);

hhmmss = hours*10000 + minutes*100 + seconds;

end