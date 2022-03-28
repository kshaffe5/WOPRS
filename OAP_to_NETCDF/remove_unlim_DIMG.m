function remove_unlim_DIMG(infile,probetype)

disp('Removing the unlimited time dimension from the DIMG file')
% Read in the PROC file
file = netcdf.open(infile,'nowrite');

% Read in all of the variables
year = netcdf.getVar(file,netcdf.inqVarID(file,'year'));
month = netcdf.getVar(file,netcdf.inqVarID(file,'month'));
day = netcdf.getVar(file,netcdf.inqVarID(file,'day'));
hour = netcdf.getVar(file,netcdf.inqVarID(file,'hour'));
minute = netcdf.getVar(file,netcdf.inqVarID(file,'minute'));
second = netcdf.getVar(file,netcdf.inqVarID(file,'second'));
millisec = netcdf.getVar(file,netcdf.inqVarID(file,'millisec'));
data = netcdf.getVar(file,netcdf.inqVarID(file,'data'));
tas = netcdf.getVar(file,netcdf.inqVarID(file,'tas'));

if strcmpi('2DC',probetype) || strcmpi('2DP',probetype) || strcmpi('2D',probetype) %PMS
    overload = netcdf.getVar(file,netcdf.inqVarID(file,'overload'));
elseif strcmpi('2DS',probetype) || strcmpi('HVPS',probetype) %SPEC
    wkday = netcdf.getVar(file,netcdf.inqVarID(file,'wkday'));
else %CIPG
    empty = netcdf.getVar(file,netcdf.inqVarID(file,'empty'));
end

% Find the dimension lengths
[time, time_length] = netcdf.inqDim(file,0);
[ImgRowLen, ImgRowLen_length] = netcdf.inqDim(file,1);
[ImgBlockLen, ImgBlockLen_length] = netcdf.inqDim(file,2);
netcdf.close(file);


% Create new NETCDF file and define the dimensions and variables

if exist(infile, 'file') == 2
    delete(infile);
end

f = netcdf.create(infile, 'NETCDF4');
dimid0 = netcdf.defDim(f,'time',time_length);
dimid1 = netcdf.defDim(f,'ImgRowLen',ImgRowLen_length);
dimid2 = netcdf.defDim(f,'ImgBlockLen',ImgBlockLen_length);

% Variables that are calculated/found for all particles
varid0 = netcdf.defVar(f,'year','short',dimid0);
varid1 = netcdf.defVar(f,'month','short',dimid0);
varid2 = netcdf.defVar(f,'day','short',dimid0);
varid3 = netcdf.defVar(f,'hour','short',dimid0);
varid4 = netcdf.defVar(f,'minute','short',dimid0);
varid5 = netcdf.defVar(f,'second','short',dimid0);
varid6 = netcdf.defVar(f,'millisec','short',dimid0);
if strcmpi('2DC',probetype) || strcmpi('2DP',probetype) || strcmpi('2D',probetype) %PMS
    varid7 = netcdf.defVar(f,'overload','short',dimid0);
elseif strcmpi('2DS',probetype) || strcmpi('HVPS',probetype) %SPEC
    varid7 = netcdf.defVar(f,'wkday','short',dimid0);
else %CIPG
    varid7 = netcdf.defVar(f,'empty','short',dimid0);
end
varid8 = netcdf.defVar(f,'data','double',[dimid1 dimid2 dimid0]);
varid9 = netcdf.defVar(f,'tas','float',dimid0);
netcdf.endDef(f)

% Add the variables to the new file
netcdf.putVar ( f, varid0, year );
netcdf.putVar ( f, varid1, month );
netcdf.putVar ( f, varid2, day );
netcdf.putVar ( f, varid3, hour );
netcdf.putVar ( f, varid4, minute );
netcdf.putVar ( f, varid5, second );
netcdf.putVar ( f, varid6, millisec );
if strcmpi('2DC',probetype) || strcmpi('2DP',probetype) || strcmpi('2D',probetype) %PMS
    netcdf.putVar ( f, varid7, overload );
elseif strcmpi('2DS',probetype) || strcmpi('HVPS',probetype) %SPEC
    netcdf.putVar ( f, varid7, wkday );
else %CIPG
    netcdf.putVar ( f, varid7, empty );
end
netcdf.putVar ( f, varid8,  data);
netcdf.putVar ( f, varid9, tas );

netcdf.close(f);
end