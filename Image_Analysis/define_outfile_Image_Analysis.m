function [f,varid]=define_outfile_Image_Analysis(probetype,outfile,diodesize,diodenum,armdist,wavelength,inter_arrival_threshold)

% Create outfile and define the variables
f = netcdf.create(outfile, 'CLOBBER');
dimid.time = netcdf.defDim(f,'time',netcdf.getConstant('NC_UNLIMITED'));
dimid.pos_count = netcdf.defDim(f,'pos_count',2);

% Variables that are calculated/found for all particles
netcdf.putAtt(f, netcdf.getConstant('NC_GLOBAL'),'Diode size',diodesize);
netcdf.putAtt(f, netcdf.getConstant('NC_GLOBAL'),'Number of diodes',diodenum);
netcdf.putAtt(f, netcdf.getConstant('NC_GLOBAL'),'Arm distance',armdist);
netcdf.putAtt(f, netcdf.getConstant('NC_GLOBAL'),'Wavelength',wavelength);

varid.Date = netcdf.defVar(f,'Date','double',dimid.time);
netcdf.putAtt(f, varid.Date,'long_name','Day, month, and year at the start of the flight');
netcdf.putAtt(f, varid.Date,'units','Not applicable');
varid.Time  = netcdf.defVar(f,'Time','double',dimid.time);
netcdf.putAtt(f, varid.Time,'long_name','UTC time in hhmmss format for the buffer');
netcdf.putAtt(f, varid.Time,'units','Not applicable');
varid.msec  = netcdf.defVar(f,'msec','double',dimid.time);
netcdf.putAtt(f, varid.msec,'long_name','Millisec after the start of the second in "Time" variable for the buffer');
netcdf.putAtt(f, varid.msec,'units','Not applicable');
if probetype == 1 %PMS
    varid.Time_in_seconds  = netcdf.defVar(f,'Time_in_seconds','float',dimid.time);
elseif probetype ==2 %SPEC
    varid.Time_in_seconds  = netcdf.defVar(f,'Time_in_seconds','double',dimid.time);
else %CIP
    varid.Time_in_seconds  = netcdf.defVar(f,'Time_in_seconds','double',dimid.time);
end
netcdf.putAtt(f, varid.Time_in_seconds,'long_name','Time in seconds from the beginning of the day. Does not restart at 2400 hours');
netcdf.putAtt(f, varid.Time_in_seconds,'units','Not applicable');
varid.channel = netcdf.defVar(f,'channel','char',dimid.time);
netcdf.putAtt(f, varid.channel,'long_name','H = horizontal 2DS channel, V = vertical 2DS channel, N = not applicable');
netcdf.putAtt(f, varid.channel,'units','Not applicable');
varid.position  = netcdf.defVar(f,'position','short',[dimid.pos_count dimid.time]);
netcdf.putAtt(f, varid.position,'long_name','Position in the buffer in number of slices from the beginning of the buffer');
netcdf.putAtt(f, varid.position,'units','Not applicable');

varid.particle_time  = netcdf.defVar(f,'particle_time','double',dimid.time);
netcdf.putAtt(f, varid.particle_time,'long_name','Day, month, and year at the start of the flight');
netcdf.putAtt(f, varid.particle_time,'units','Not applicable');
varid.particle_millisec  = netcdf.defVar(f,'particle_millisec','short',dimid.time);
varid.particle_microsec  = netcdf.defVar(f,'particle_microsec','double',dimid.time);

varid.parent_rec_num  = netcdf.defVar(f,'parent_rec_num','double',dimid.time);
netcdf.putAtt(f, varid.parent_rec_num,'long_name','Number of the buffer corresponding to the image. Starts at 1 at the beginning of the file');
netcdf.putAtt(f, varid.parent_rec_num,'units','Not applicable');
if probetype == 1 %PMS
    varid.inter_arrival = netcdf.defVar(f,'inter_arrival','float',dimid.time);
elseif probetype ==2 %SPEC
    varid.inter_arrival = netcdf.defVar(f,'inter_arrival','double',dimid.time);
else %CIP
    varid.inter_arrival = netcdf.defVar(f,'inter_arrival','double',dimid.time);
end
netcdf.putAtt(f, varid.inter_arrival,'long_name','Time between the previous particle leaving the sample area and the current particle entering');
netcdf.putAtt(f, varid.inter_arrival,'units','microseconds');
varid.artifact_status = netcdf.defVar(f,'artifact_status','double',dimid.time); 
netcdf.putAtt(f, varid.artifact_status,'long_name','Value corresponding to rejection criteria that failed the image. 1 = not rejected, >1 = rejected');
netcdf.putAtt(f, varid.artifact_status,'Number of artifact statuses',6);
netcdf.putAtt(f, varid.artifact_status,'Artifact status key','1 = not rejected, 2 = no pixels shadowed, 3 = shattered particle, 4 = streaker, 5 = stuck bit, 6 = sliced image, 7 = multiple particles or broken image. Consult WOPRS github wiki for more info');
varid.diameter = netcdf.defVar(f,'diameter','double',dimid.time);
netcdf.putAtt(f, varid.diameter,'long_name','Diameter of the smallest enclosing circle (aka the maximum diameter)');
netcdf.putAtt(f, varid.diameter,'units','micrometers');
varid.aspect_ratio = netcdf.defVar(f,'aspect_ratio','double',dimid.time);
netcdf.putAtt(f, varid.aspect_ratio,'long_name','Major axis of the ellipse around an image divided by the minor axis');
netcdf.putAtt(f, varid.aspect_ratio,'units','unitless');
varid.orientation = netcdf.defVar(f,'orientation','double',dimid.time);
netcdf.putAtt(f, varid.orientation,'long_name','Angle between the x-axis and the major axis of the ellipse around an image. Values between -90 and 90');
netcdf.putAtt(f, varid.orientation,'units','degrees');
varid.slicecount = netcdf.defVar(f,'slicecount','double',dimid.time);
netcdf.putAtt(f, varid.slicecount,'long_name','Length of the image in number of pixels');
netcdf.putAtt(f, varid.slicecount,'units','unitless');
varid.poisson_corrected = netcdf.defVar(f,'poisson_corrected','double',dimid.time);
netcdf.putAtt(f, varid.poisson_corrected,'long_name','1 = poisson corrected, 0 = not poisson corrected');
netcdf.putAtt(f, varid.poisson_corrected,'units','Not applicable');
varid.perimeter = netcdf.defVar(f,'perimeter','double',dimid.time);
netcdf.putAtt(f, varid.perimeter,'long_name','Distance around the boundary of the image measured in pixels');
netcdf.putAtt(f, varid.perimeter,'units','unitless');
varid.area = netcdf.defVar(f,'area','double',dimid.time);
netcdf.putAtt(f, varid.area,'long_name','Actual number of pixels in the image');
netcdf.putAtt(f, varid.area,'units','unitless');
varid.number_of_holes = netcdf.defVar(f,'number_of_holes','double',dimid.time);
netcdf.putAtt(f, varid.number_of_holes,'long_name','Number of holes in the image');
netcdf.putAtt(f, varid.number_of_holes,'units','unitless');
varid.number_of_pieces = netcdf.defVar(f,'number_of_pieces','double',dimid.time);
netcdf.putAtt(f, varid.number_of_pieces,'long_name','Number of pieces in the image');
netcdf.putAtt(f, varid.number_of_pieces,'units','unitless');
varid.area_ratio = netcdf.defVar(f,'area_ratio','double',dimid.time);
netcdf.putAtt(f, varid.area_ratio,'long_name','Area / area of the smallest enclosing circle. 1 = perfect circle, 0 = perfectly noncircular, -1=poisson corrected');
netcdf.putAtt(f, varid.area_ratio,'units','unitless');
varid.in_status = netcdf.defVar(f,'in_status','char',dimid.time);
netcdf.putAtt(f, varid.in_status,'long_name','How much of the particle is shown in the image. A = all in, I = center in, O = center out');
netcdf.putAtt(f, varid.in_status,'units','Not applicable');
varid.circularity = netcdf.defVar(f,'circularity','double',dimid.time);
netcdf.putAtt(f, varid.in_status,'long_name','Calculated using 4*area*pi / (perimeter^2). Perfect circle = 1. Only calculated for images above a certain size, all others are NaN.');
netcdf.putAtt(f, varid.in_status,'units','unitless');
varid.interarrival_reject = netcdf.defVar(f,'interarrival_reject','double',dimid.time);
netcdf.putAtt(f, varid.interarrival_reject,'long_name',['Flags particles that have an interarrival time less than the threshold value of ',inter_arrival_threshold, ' microseconds. 1 = below the threshold, 0 = above']);
netcdf.putAtt(f, varid.interarrival_reject,'units','Not applicable');
netcdf.endDef(f)

end