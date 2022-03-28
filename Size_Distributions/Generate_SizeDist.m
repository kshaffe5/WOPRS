function Generate_SizeDist(PROC_files,num_rejects,outfile,tas,timehhmmss,probename,setupfile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is called by run_SizeDist to generate NetCDF files
% containing size distribution data. 
%
% The NetCDF files produced by this function include the following
% information:
% -concentration of particles by rejection type, seperated into bins based
% on diameter size
% -concentrations of particles separated nto bins based on area ratio
% values
% -particle counts for accepted particles seperated into bins based on
% diameter size
% -particle counts for rejected particles seperated into bins based on
% diameter size
% -rejection ratio across all bins for each probe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Begin generating the size distribution
disp(['Generating Size Distribution for the ',probename]);

 
%% Read the setup file with bin edges
[area_ratio_bin_edges,num_ar_bins,answer_status,in_status_selection,kk,num_bins,mid_bin_diams,num_diodes,diodesize,armdst,wavelength]=read_setup(setupfile,probename);


% Seperate probes by manufacturer:
%       1: 2DC/2DP (PMS)
%       2: HVPS/2DS (SPEC)
%       3: CIPG (DMT)
switch probename
    case {'HVPS' , '2DS'}
        probetype=2;
    case 'CIP'
        probetype=3;
    case {'2DC' , '2DP'}
        probetype=1;
end


%% Create outfile and define variables
f = netcdf.create(outfile, 'clobber');
dimid0 = netcdf.defDim(f,'time',length(timehhmmss));
dimid1 = netcdf.defDim(f,'bin_count',num_bins);
dimid2 = netcdf.defDim(f,'reject_status',num_rejects);
dimid3 = netcdf.defDim(f,'ar_bin_count',num_ar_bins);

varid00 = netcdf.defVar(f,'time','double',dimid0);
varid0 = netcdf.defVar(f,'Reject_counts','double',[dimid0 dimid1 dimid2]);
netcdf.putAtt(f, varid0,'long_name',['Binwise counts calculated using ',answer_status,' images']);
varid1 = netcdf.defVar(f,'bin_min','double',dimid1);
netcdf.putAtt(f, varid1,'long_name','Lower end of each diameter bin');
varid2 = netcdf.defVar(f,'bin_max','double',dimid1);
netcdf.putAtt(f, varid2,'long_name','Upper end of each diameter bin');
varid3 = netcdf.defVar(f,'bin_mid','double',dimid1);
netcdf.putAtt(f, varid3,'long_name','Midpoint of each diameter bin');
varid4 = netcdf.defVar(f,'Area_ratio_counts','double',[dimid0 dimid3]);
netcdf.putAtt(f, varid4,'long_name','Binwise counts of area ratio');
switch probename
    case '2DS'
        varid6 = netcdf.defVar(f,'Reject_counts_H','double',[dimid0 dimid1 dimid2]);
        netcdf.putAtt(f, varid6,'long_name',['Binwise counts calculated using ',answer_status,' images from only the horizontal channel of the 2DS']);
        varid7 = netcdf.defVar(f,'Reject_counts_V','double',[dimid0 dimid1 dimid2]);
        netcdf.putAtt(f, varid7,'long_name',['Binwise counts calculated using ',answer_status,' images from only the vertical channel of the 2DS']);
        varid8 = netcdf.defVar(f,'size_dist_2DS_H','double',[dimid0 dimid1 dimid2]);
        netcdf.putAtt(f, varid8,'long_name',['Size distribution for horizontal channel only calculated using ',answer_status,' images']);
        varid9 = netcdf.defVar(f,'size_dist_2DS_V','double',[dimid0 dimid1 dimid2]);
        netcdf.putAtt(f, varid9,'long_name',['Size distribution for vertical channel only calculated using ',answer_status,' images']);
        size_dist_H = zeros(length(timehhmmss),num_bins,num_rejects)*NaN;
        size_dist_V = zeros(length(timehhmmss),num_bins,num_rejects)*NaN;
end
varid10 = netcdf.defVar(f,['size_dist_',probename],'double',[dimid0 dimid1 dimid2]);
netcdf.putAtt(f, varid10,'long_name',['Size distribution calculated using ',answer_status,' images']);

netcdf.endDef(f)


% Create NaN arrays for every second
reject_count  = zeros(length(timehhmmss),num_bins,num_rejects)*NaN;
area_ratio_count = zeros(length(timehhmmss),num_ar_bins)*NaN;
reject_count_H = zeros(length(timehhmmss),num_bins,num_rejects)*NaN;
reject_count_V = zeros(length(timehhmmss),num_bins,num_rejects)*NaN;
sample_volume = zeros(length(timehhmmss),num_bins);
size_dist = zeros(length(timehhmmss),num_bins,num_rejects)*NaN;

min_bin_diams = kk(1:end-1);
max_bin_diams = kk(2:end);


%% Loop over each PROC file in the directory
for x = 1:length(PROC_files)
    
    % Define input and output files and initialize time variable
    disp(['Reading in file: ',PROC_files(x).folder,'/',PROC_files(x).name])
    infile = netcdf.open([PROC_files(x).folder,'/',PROC_files(x).name],'nowrite');
    times = netcdf.getVar(infile,netcdf.inqVarID(infile,'Time'));
    first_PROC_time = times(1);
    last_PROC_time = times(end);

    % Read in other variables
    diameter = netcdf.getVar(infile,netcdf.inqVarID(infile,'diameter'));
    artifacts = netcdf.getVar(infile,netcdf.inqVarID(infile,'artifact_status'));
    area_ratio = netcdf.getVar(infile,netcdf.inqVarID(infile,'area_ratio'));
    switch probename
        case '2DS'
            channel = netcdf.getVar(infile,netcdf.inqVarID(infile,'channel'));
    end
    in_status = netcdf.getVar(infile,netcdf.inqVarID(infile,'in_status'));


    % Fix flight times if they span multiple days
    timehhmmss(find(diff(timehhmmss)<0)+1:end) = timehhmmss(find(diff(timehhmmss)<0)+1:end) + 240000;
    tas_time = floor(timehhmmss/10000)*3600+floor(mod(timehhmmss,10000)/100)*60+floor(mod(timehhmmss,100));
    timehhmmss = mod(timehhmmss, 240000);
    

    % Find the first and last time that is available in both the PROC and
    % aircraft files. We will loop over these times to create the SD file.
    first_time_index = find(timehhmmss >= first_PROC_time);
    first_time = timehhmmss(first_time_index(1));
    last_time = min(last_PROC_time,timehhmmss(end));

    first_time = hhmmss2sec(first_time);
    last_time = hhmmss2sec(last_time);
    
    length_of_times = last_time - first_time;
    end_index = first_time_index(1) + length_of_times - 1;
    end_index = min(end_index,length(timehhmmss));


    
    %% Calculate sample area depending on whether we are considering center-in or only all-in images 
    
    % Calculate for each bin
    switch answer_status
        case {'Center-in','center-in','Centerin','centerin','Center','center'}
            for i=1:length(mid_bin_diams)
                DOF = (4*mid_bin_diams(i)^2) / wavelength;%Calculate depth-of-field
                along_beam = min(armdst,DOF);%If the DOF is larger than the distance between the probe arms, then the DOF is equal to the distance between probe arms
                sample_area(i) = (along_beam * diodesize * (num_diodes-2+1)) / 100; %Convert to cm^2
            end
        case {'All-in','all-in','Allin','allin','All','all'}
            for i=1:length(mid_bin_diams)
                DOF = (4*mid_bin_diams(i)^2) / wavelength;%Calculate depth-of-field
                along_beam = min(armdst,DOF);%If the DOF is larger than the distance between the probe arms, then the DOF is equal to the distance between probe arms
                sample_area(i) = (along_beam * diodesize * (num_diodes-2+1) - mid_bin_diams(i)) / 100; %Convert to cm^2
            end
    end



    %% Loop over every second
    for i = first_time_index(1):end_index
        current_time=(i-first_time_index(1))+first_time; % This is now equivalent to a time in the PROC file and nc file, incrementing by 1 as we go through the for loop
        current_hhmmss = sec2hhmmss(current_time);

        % Find the indices of all the particles that correspond to this time
        good_indices = find(times == current_hhmmss);
        
        % Set the counts to 0 at every time when there is both an aircraft
        % file and a PROC file. NaN's otherwise
        reject_count(i,:,:) = 0;
        area_ratio_count(i,:) = 0;
        reject_count_H(i,:,:) = 0;
        reject_count_V(i,:,:) = 0;
        
        %% Calculate sample volume second-by-second using tas from aircraft data
        sample_volume(i,:) = (tas(i)*100) * sample_area; %In cm^3
        
        % Read in the area ratio and rejection criteria for
        % the particles at this time. Then add to appropriate counts
        if ~isempty(good_indices) % If there is more than 1 particle in this second, continue
            good_diameters = diameter(good_indices); % Find the diameters of all particles in this time
            good_artifacts = artifacts(good_indices); % Find the artifact statuses
            good_area_ratios = area_ratio(good_indices); % Find the area ratios
            switch probename
                case '2DS'
                    good_channel = channel(good_indices); % Find the H or V status
            end
            good_in_status = in_status(good_indices); % Find if the image is center-in, center-out, or all-in
            
            for j=1:length(good_diameters)
                %% Rejection Counts
                % Find which bin the given diameter fits into
                switch good_in_status(j)
                    case in_status_selection
                        switch good_artifacts(j)
                            case 1 % Particle is not rejected
                                %% Rejection counts
                                lower_bin_numbers = find(kk <= good_diameters(j));
                                bin_number = lower_bin_numbers(end); % This is the number of the bin that the diameter fits into
                                reject_count(i,bin_number,good_artifacts(j)) = reject_count(i,bin_number,good_artifacts(j)) + 1;
                                switch probename
                                    case '2DS'
                                        switch good_channel(j)
                                            case 'H'
                                                reject_count_H(i,bin_number,good_artifacts(j)) = reject_count_H(i,bin_number,good_artifacts(j)) + 1;
                                            case 'V'
                                                reject_count_V(i,bin_number,good_artifacts(j)) = reject_count_V(i,bin_number,good_artifacts(j)) + 1;
                                            otherwise
                                                disp('Error')
                                                disp('Shutting down')
                                        end
                                end
                        
                                %% Area ratio counts
                                lower_bin_numbers = find(area_ratio_bin_edges <= good_area_ratios(j));
                                bin_number = lower_bin_numbers(end); % This is the number of the bin that the area ratio fits into
                                % Add counts to area ratio bins
                                area_ratio_count(i,bin_number) = area_ratio_count(i,bin_number) + 1;
                        
                            otherwise
                                bin_number = 1;
                        
                                reject_count(i,bin_number,good_artifacts(j)) = reject_count(i,bin_number,good_artifacts(j)) + 1;
                                switch probename
                                    case '2DS'
                                        if good_channel(j) == 0
                                            reject_count_H(i,bin_number,good_artifacts(j)) = reject_count_H(i,bin_number,good_artifacts(j)) + 1;
                                        else
                                            reject_count_V(i,bin_number,good_artifacts(j)) = reject_count_V(i,bin_number,good_artifacts(j)) + 1;
                                        end
                                end
                        end
                                      
                end
            end
             
        end
        
    end
    
end
    for k=1:num_rejects
        size_dist(:,:,k) = reject_count(:,:,k) ./ sample_volume(:,:);
        switch probename
            case '2DS'
                size_dist(:,:,k) = size_dist(:,:,k) / 2; %Need to divide concentrations by 2 becuase the 2DS has two channels
                size_dist_H(:,:,k) = reject_count_H(:,:,k) ./ sample_volume(:,:);
                size_dist_V(:,:,k) = reject_count_V(:,:,k) ./ sample_volume(:,:);
        end
    end
        
    netcdf.putVar ( f, varid00, timehhmmss);
    netcdf.putVar ( f, varid0, reject_count);
    netcdf.putVar ( f, varid1, min_bin_diams);
    netcdf.putVar ( f, varid2, max_bin_diams);
    netcdf.putVar ( f, varid3, mid_bin_diams);
    netcdf.putVar ( f, varid4, area_ratio_count);
        
    switch probename
        case '2DS'
            netcdf.putVar ( f, varid6, reject_count_H);
            netcdf.putVar ( f, varid7, reject_count_V);
            netcdf.putVar ( f, varid8, size_dist_H);
            netcdf.putVar ( f, varid9, size_dist_V);
    end
    
    netcdf.putVar ( f, varid10, size_dist);

netcdf.close(f);

end