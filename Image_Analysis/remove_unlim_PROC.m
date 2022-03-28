function remove_unlim_PROC(infile)

disp('Removing the unlimited time dimension from the PROC file')
% Read in the PROC file
file = netcdf.open(infile,'nowrite');

% Read in all of the variables
Date = netcdf.getVar(file,netcdf.inqVarID(file,'Date'));
Time = netcdf.getVar(file,netcdf.inqVarID(file,'Time'));
msec = netcdf.getVar(file,netcdf.inqVarID(file,'msec'));
Time_in_seconds = netcdf.getVar(file,netcdf.inqVarID(file,'Time_in_seconds'));
PMS_overload_SPEC_wkday = netcdf.getVar(file,netcdf.inqVarID(file,'PMS_overload_SPEC_wkday'));
H_or_V = netcdf.getVar(file,netcdf.inqVarID(file,'H_or_V'));
position = netcdf.getVar(file,netcdf.inqVarID(file,'position'));
particle_time = netcdf.getVar(file,netcdf.inqVarID(file,'particle_time'));
particle_millisec = netcdf.getVar(file,netcdf.inqVarID(file,'particle_millisec'));
particle_microsec = netcdf.getVar(file,netcdf.inqVarID(file,'particle_microsec'));
parent_rec_num = netcdf.getVar(file,netcdf.inqVarID(file,'parent_rec_num'));
inter_arrival = netcdf.getVar(file,netcdf.inqVarID(file,'inter_arrival'));
artifact_status = netcdf.getVar(file,netcdf.inqVarID(file,'artifact_status'));
diameter = netcdf.getVar(file,netcdf.inqVarID(file,'diameter'));
aspect_ratio = netcdf.getVar(file,netcdf.inqVarID(file,'aspect_ratio'));
circularity = netcdf.getVar(file,netcdf.inqVarID(file,'circularity'));
slicecount = netcdf.getVar(file,netcdf.inqVarID(file,'slicecount'));
poisson_corrected = netcdf.getVar(file,netcdf.inqVarID(file,'poisson_corrected'));
perimeter = netcdf.getVar(file,netcdf.inqVarID(file,'perimeter'));
area = netcdf.getVar(file,netcdf.inqVarID(file,'area'));
number_of_holes = netcdf.getVar(file,netcdf.inqVarID(file,'number_of_holes'));
number_of_pieces = netcdf.getVar(file,netcdf.inqVarID(file,'number_of_pieces'));

% Find the dimension lengths
[time, time_length] = netcdf.inqDim(file,0);
[pos_count, pos_count_length] = netcdf.inqDim(file,1);

netcdf.close(file);


% Create new NETCDF file and define the dimensions and variables
f = netcdf.create(infile, 'CLOBBER');
dimid0 = netcdf.defDim(f,'time',time_length);
dimid1 = netcdf.defDim(f,'pos_count',pos_count_length);

% Variables that are calculated/found for all particles
varid0 = netcdf.defVar(f,'Date','double',dimid0);
varid1  = netcdf.defVar(f,'Time','double',dimid0);
varid2  = netcdf.defVar(f,'msec','double',dimid0);
varid3  = netcdf.defVar(f,'Time_in_seconds','double',dimid0);
varid5  = netcdf.defVar(f,'PMS_overload_SPEC_wkday','double',dimid0);
varid6 = netcdf.defVar(f,'H_or_V','double',dimid0);
varid7  = netcdf.defVar(f,'position','double',[dimid1 dimid0]);
varid8  = netcdf.defVar(f,'particle_time','double',dimid0);
varid9  = netcdf.defVar(f,'particle_millisec','double',dimid0);
varid10  = netcdf.defVar(f,'particle_microsec','double',dimid0);
varid11  = netcdf.defVar(f,'parent_rec_num','double',dimid0);
varid13 = netcdf.defVar(f,'inter_arrival','double',dimid0);
varid14 = netcdf.defVar(f,'artifact_status','double',dimid0); 
varid15 = netcdf.defVar(f,'diameter','double',dimid0);
varid19 = netcdf.defVar(f,'aspect_ratio','double',dimid0);
varid20 = netcdf.defVar(f,'circularity','double',dimid0);
varid21 = netcdf.defVar(f,'slicecount','double',dimid0);
varid22 = netcdf.defVar(f,'poisson_corrected','double',dimid0);
varid23 = netcdf.defVar(f,'perimeter','double',dimid0);
varid24 = netcdf.defVar(f,'area','double',dimid0);
varid25 = netcdf.defVar(f,'number_of_holes','double',dimid0);
varid26 = netcdf.defVar(f,'number_of_pieces','double',dimid0);
netcdf.endDef(f)


% Add the variables to the new file
netcdf.putVar ( f, varid0, Date);
netcdf.putVar ( f, varid1, Time);
netcdf.putVar ( f, varid2, msec);
netcdf.putVar ( f, varid3, Time_in_seconds);
netcdf.putVar ( f, varid5, PMS_overload_SPEC_wkday);
netcdf.putVar ( f, varid6, H_or_V);
netcdf.putVar ( f, varid7, position);
netcdf.putVar ( f, varid8, particle_time);
netcdf.putVar ( f, varid9, particle_millisec);
netcdf.putVar ( f, varid10, particle_microsec);
netcdf.putVar ( f, varid11, parent_rec_num );
netcdf.putVar ( f, varid13, inter_arrival);
netcdf.putVar ( f, varid14, artifact_status);
netcdf.putVar ( f, varid15, diameter);
netcdf.putVar ( f, varid19, aspect_ratio);
netcdf.putVar ( f, varid20, circularity);
netcdf.putVar ( f, varid21, slicecount);
netcdf.putVar ( f, varid22, poisson_corrected);
netcdf.putVar ( f, varid23, perimeter);
netcdf.putVar ( f, varid24, area);
netcdf.putVar ( f, varid25, number_of_holes);
netcdf.putVar ( f, varid26, number_of_pieces);

netcdf.close(f);
end