function run_SizeDist(ncfile,PROC_directory,probe)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Uses the nc file for a given flight and uses the corresponding PROC files
% for a given probe to generate second-by-second size distributions.
%
% Example Inputs:
% ncfile - '/kingair_data/snowie17/work/123456.c1.nc'
% PROC_directory - '/kingair_data/snowie17/OAP_processed/123456'
% probe - '2DS'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
main_nc = netcdf.open(ncfile);
timesec = netcdf.getVar(main_nc, netcdf.inqVarID(main_nc, 'time'), 'double');
tas = netcdf.getVar(main_nc, netcdf.inqVarID(main_nc, 'tas'),'double');
netcdf.close(main_nc);
days = floor(timesec/86400);
hours = floor(mod(timesec,86400)/3600);
minutes = floor(mod(timesec,3600)/60);
seconds = mod(timesec,60);
timehhmmss = double(seconds+minutes*100+hours*10000); 

% Find the date and project directory from the nc file
c1_pos = find(ncfile == '1',1,'last');
date = ncfile(c1_pos-10:c1_pos-3);
PROC_directory = ([PROC_directory,'/']);

% Sanity check to make sure we have true airspeed data for every second
if length(timehhmmss)==length(tas)
    disp(['Length of the nc file is: ',num2str(length(tas)),' seconds'])
else 
    disp('ERROR: Length of the time and true airspeed variables is not equal. Shutting down.')
    return;
end

% Find the appropriate file(s) based on the probetype and then run
% Generate_SizeDist.
switch probe
    case {'2DS','2ds'}

        files = dir([PROC_directory,'PROC.*.2DS.cdf']);
        filenums = length(files);
        if filenums < 1
            disp('No 2DS files found in the provided directory')
            return;
        end
        
%         % Read in the artifact statuses to see how many there are. This
%         % needs to be done so that we can set one of the dimension sizes in
%         % Generate_SizeDist. By reading this in here, artifact statuses can
%         % be added, without affecting the size distribution code.
         PROC_file = netcdf.open([PROC_directory,files(1).name],'nowrite');
         num_rejects = netcdf.getAtt(PROC_file, netcdf.inqVarID(PROC_file,'artifact_status'),'Number of artifact statuses');
        
        inFile = [PROC_directory,files(1).name];
        proc_pos = find(inFile == 'P',1,'last');
        outFile = [inFile(1:proc_pos-1),'SD.',date,'.2DS.cdf']
        Generate_SizeDist(files,outFile,tas,floor(timehhmmss),'2DS',num_rejects);    
    case {'HVPS','hvps'}
        files = dir([PROC_directory,'PROC.*.HVPS.cdf']);
        filenums = length(files);
        if filenums < 1
            disp('No HVPS files found in the provided directory')
            return;
        end
        
        % Read in the artifact statuses to see how many there are. This
        % needs to be done so that we can set one of the dimension sizes in
        % Generate_SizeDist. By reading this in here, artifact statuses can
        % be added, without affecting the size distribution code.
         PROC_file = netcdf.open([PROC_directory,files(1).name],'nowrite');
         num_rejects = netcdf.getAtt(PROC_file, netcdf.inqVarID(PROC_file,'artifact_status'),'Number of artifact statuses');
        
        inFile = [PROC_directory,files(1).name];
        proc_pos = find(inFile == 'P');
        if length(proc_pos) > 1
            proc_pos = proc_pos(end-1);
        else
            proc_pos = proc_pos(end);
        end
        outFile = [inFile(1:proc_pos-1),'SD.',date,'.HVPS.cdf']
        Generate_SizeDist(files,number_of_reject_types,outFile,tas,floor(timehhmmss),'HVPS',num_rejects);
        
    case {'CIPG','cip','cipg','CIP'}

        files = dir([PROC_directory,'PROC.*.CIP.cdf']);
        filenums = length(files);
        if filenums < 1
            disp('No CIP files found in the provided directory')
            return;
        end
        
        % Read in the artifact statuses to see how many there are. This
        % needs to be done so that we can set one of the dimension sizes in
        % Generate_SizeDist. By reading this in here, artifact statuses can
        % be added, without affecting the size distribution code.
         PROC_file = netcdf.open([PROC_directory,files(1).name],'nowrite');
         num_rejects = netcdf.getAtt(PROC_file, netcdf.inqVarID(PROC_file,'artifact_status'),'Number of artifact statuses');
        
        inFile = [PROC_directory,files(1).name];
        proc_pos = find(inFile == 'P');
        if length(proc_pos) > 1
            proc_pos = proc_pos(end-1);
        else
            proc_pos = proc_pos(end);
        end
        outFile = [inFile(1:proc_pos-1),'SD.',date,'.CIP.cdf']
        Generate_SizeDist(files,number_of_reject_types,outFile,tas,floor(timehhmmss),'CIP',num_rejects);

    case {'2DP','2dp'}

        files = dir([PROC_directory,'PROC.*.2DP.cdf']);
        filenums = length(files);
        if filenums < 1
            disp('No 2DP files found in the provided directory')
            return;
        end
        
        % Read in the artifact statuses to see how many there are. This
        % needs to be done so that we can set one of the dimension sizes in
        % Generate_SizeDist. By reading this in here, artifact statuses can
        % be added, without affecting the size distribution code.
         PROC_file = netcdf.open([PROC_directory,files(1).name],'nowrite');
         num_rejects = netcdf.getAtt(PROC_file, netcdf.inqVarID(PROC_file,'artifact_status'),'Number of artifact statuses');
        
        inFile = [PROC_directory,files(1).name];
        proc_pos = find(inFile == 'P');
        if length(proc_pos) > 1
            proc_pos = proc_pos(end-1);
        else
            proc_pos = proc_pos(end);
        end
        outFile = [inFile(1:proc_pos-1),'SD.',date,'.2DP.cdf']
        Generate_SizeDist(files,number_of_reject_types,outFile,tas,floor(timehhmmss),'2DP',num_rejects);
        
    case {'2DC','2dc'}
        
        files = dir([PROC_directory,'PROC.*.2DC.cdf']);
        filenums = length(files);
        if filenums < 1
            disp('No 2DC files found in the provided directory')
            return;
        end
        
        % Read in the artifact statuses to see how many there are. This
        % needs to be done so that we can set one of the dimension sizes in
        % Generate_SizeDist. By reading this in here, artifact statuses can
        % be added, without affecting the size distribution code.
         PROC_file = netcdf.open([PROC_directory,files(1).name],'nowrite');
         num_rejects = netcdf.getAtt(PROC_file, netcdf.inqVarID(PROC_file,'artifact_status'),'Number of artifact statuses');
        
        inFile = [PROC_directory,files(1).name];
        proc_pos = find(inFile == 'P',1,'last');
        outFile = [inFile(1:proc_pos-1),'SD.',date,'.2DC.cdf']
        Generate_SizeDist(files,number_of_reject_types,outFile,tas,floor(timehhmmss),'2DC',num_rejects);
        
end

end
