function Image_Analysis_core(infile, outfile, n, nEvery, probename, threshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This function is the base function for the image processsing step of OAP 
%% processing. This step utilizes parallel processing to speed up the 
%% processing speed. All probetypes are compatible with this function.
%% 
%% Inputs:
%% infile - full directory listing of the image file created during the OAP_to_NETCDF step.
%% outfile - infilename with '.proc.cdf' at the end of the file name
%% probetype - the shorthand name of the probe (ex. '2DS', 'CIP', etc...)
%% n - the starting point to start processing
%% nEvery - the size of the data to be processed
%% threshold - shaded cip threshold percentage (defaults to 50 if not provided)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting probe information according to probe type
%    use probetype to indicate three probe manufacturers:
%       1: 2DC/2DP (PMS)
%       2: HVPS/2DS (SPEC)
%       3: CIP (DMT)

%% Start by reading the setup file to retrieve information about the probe
[boundary,boundarytime,diodesize,diodenum,armdist,wavelength,probetype,inter_arrival_threshold] = setup_Image_Analysis(probename);

% Only the 2DP has a clockfactor, otherwise it is just 1
if(~exist('clockfactor'))
    clockfactor = 1.;
end

%% Read the DIMG file
handles.f = netcdf.open(infile,'nowrite');
[~, handles.img_count] = netcdf.inqDim(handles.f,0); 
warning off all

%% Define the PROC file
[f,varid]=define_outfile_Image_Analysis(probetype,outfile,diodesize,diodenum,armdist,wavelength,inter_arrival_threshold);

% Variable initialization 
kk=1;
w=-1;
wstart = 0;
buffer_end = 1;
last_H = -1;
last_V = -1;

%% Begin the processing by reading in the variable information. 
%% This is the start of our loop over every individual particle.
%% n and nEvery depend on the use of parallel processing.
for i=((n-1)*nEvery+1):min(n*nEvery,handles.img_count)

    handles.year     = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'year'    ),i-1,1);
    handles.month    = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'month'  ),i-1,1);
    handles.day      = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'day'  ),i-1,1);
    handles.hour     = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'hour'    ),i-1,1);
    handles.minute   = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'minute'  ),i-1,1);
    handles.second   = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'second'  ),i-1,1);
    handles.millisec = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'millisec'),i-1,1);
    if probetype == 1 %PMS
        handles.overload    = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'overload'),i-1,1);
        handles.tas         = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'tas'),i-1,1);
    elseif probetype ==2 %SPEC
        handles.wkday       = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'wkday'),i-1,1);
%     else %CIP
%         handles.empty       = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'empty'),i-1,1);
    end
     if mod(i,10000) == 0
        [num2str(i),'/',num2str(handles.img_count)]
     end
    
    % Read in the buffers. Buffer sizes vary between the probetypes.
    data_varid = netcdf.inqVarID(handles.f,'data');
    if probetype==1 %PMS
        temp = netcdf.getVar(handles.f,data_varid,[0, 0, i-1], [4,1024,1]);
    elseif(probetype == 2) %SPEC
        temp = netcdf.getVar(handles.f,data_varid,[0, 0, i-1], [8,1700,1]);
    else %CIP
        temp = netcdf.getVar(handles.f,data_varid,[0, 0, i-1], [64,512,1]);
    end
    data(:,:) = temp';  
    
    j=1;
    start=0;
    firstpart = 1;
    
    %% Here we loop over each buffer
    while data(j,1) ~= -1 && j < size(data,1)
        % Loop over every particle in the buffer
        if (isequal(data(j,:), boundary) && ( (isequal(data(j+1,2), boundarytime) ) ) )
           if start ==0
                   start = 1;
           end
              if probetype==1
                   if start+1 > (j-1)  % Remove Corrupted Data
                        start = j + 2;
                        j = j + 1;
                        continue;
                   end
               else
                   if start > (j-1)  % Remove Corrupted Data
                        if probetype==3
                            start = j + 3;
                        else
                            start = j + 2;
                        end
                        j = j + 1;
                        continue;
                   end
               end 
                
                if(probetype == 3)
                   header_loc = j+2;
                else
                   header_loc = j+1;
                end
                w=w+1;
                
                % Create binary image according to probe type             
                if probetype==1    
                    ind_matrix(1:j-start-1,:) = data(start+1:j-1,:);  % 2DC has 3 slices between particles (sync word, timing word, and end of particle words)
                    c=[dec2bin(ind_matrix(:,1),8),dec2bin(ind_matrix(:,2),8),dec2bin(ind_matrix(:,3),8),dec2bin(ind_matrix(:,4),8)];
                    channel(kk) = 'N'; % 'N' for not applicable
                elseif probetype==2
                    ind_matrix(1:j-start,:) = 65535 - data(start:j-1,:); % I used 1 to indicate the illuminated doides for HVPS
                    c=[dec2bin(ind_matrix(:,1),16), dec2bin(ind_matrix(:,2),16),dec2bin(ind_matrix(:,3),16),dec2bin(ind_matrix(:,4),16), ...
                    dec2bin(ind_matrix(:,5),16), dec2bin(ind_matrix(:,6),16),dec2bin(ind_matrix(:,7),16),dec2bin(ind_matrix(:,8),16)];
                             
                    % At the start of every new buffer,  read in the entire
                    % buffer here. Then at each header location, I find the
                    % H or V 'stamp', which is a 1 or a 0 in the first bit
                    % of the timing word. 
                    if buffer_end == 1
                        buffer_end = 0;
                        jj=1700;
                        ind_matrix(1:jj-start+1,:) = 65535 - data(start:jj,:); % I used 1 to indicate the illuminated doides for HVPS
                        test_channel=[dec2bin(ind_matrix(:,1),16), dec2bin(ind_matrix(:,2),16),dec2bin(ind_matrix(:,3),16),dec2bin(ind_matrix(:,4),16), ...
                        dec2bin(ind_matrix(:,5),16), dec2bin(ind_matrix(:,6),16),dec2bin(ind_matrix(:,7),16),dec2bin(ind_matrix(:,8),16)];
                    end
                    % Read in the first bit of the timing word, where the H
                    % or V flag is located.
                    H_V(kk) = str2double(test_channel(j+1,1));
                    % H=0, V=1
                    switch H_V(kk)
                        case 0
                            channel(kk) = 'H';
                        case 1
                            channel(kk) = 'V';
                    end
                    
                elseif probetype==3
                    % Set thresholding
                    
                    ind_matrix = data(start:j-1,:)';
					if(threshold == 50)
						ind_matrix(ind_matrix < 2) = 0;
						ind_matrix(ind_matrix > 1) = 1;
                    elseif(threshold == 75)
					    ind_matrix(ind_matrix > 0) = 1;
					else
					    ind_matrix(ind_matrix < 3) = 0;
						ind_matrix(ind_matrix > 2) = 1;
					end	
                    
                    c = num2str(ind_matrix, '%1d');
                    c = c';
                    
                    channel(kk) = 'N'; % 'N' for not applicable
                end
                
                % Just to test if there is bad images, usually 0 area images
                figsize = size(c);
                if figsize(2)~=diodenum
                    disp('Not equal to doide number');
                    return
                end
                
                images.position(kk,:) = [start, j-1];
                parent_rec_num(kk)=i;
                
                % Retrieve the particle time 
                if probetype==1 %PMS
                    bin_convert = [dec2bin(data(header_loc,2),8),dec2bin(data(header_loc,3),8),dec2bin(data(header_loc,4),8)];
                    part_time = bin2dec(bin_convert)*clockfactor;       % Interarrival time in tas clock cycles -- needs to be multiplied by 2 for the 2DP probe
                    part_time = part_time/handles.tas*diodesize/(10^3);               
                    time_in_seconds(kk) = part_time;
                    PMSoverload_SPECwkday(kk)= handles.overload; 
                    
                    images.int_arrival(kk) = part_time * 1000000; % Convert to microseconds
                    
                    % Fix interarrival times if the time variable gets too
                    % large for MATLAB, and the times rollover.
                    if images.int_arrival(kk) < 0
                        images.int_arrival(kk) = images.int_arrival(kk) +  (2^32 - 1)
                    end
                    
                    if(firstpart == 1)
                        firstpart = 0;
                        start_hour = handles.hour;
                        start_minute = handles.minute;
                        start_second = handles.second;
                        start_msec = handles.millisec;
                        start_microsec = 0;

                        part_hour(kk) = start_hour;
                        part_min(kk) = start_minute;
                        part_sec(kk) = start_second;
                        part_mil(kk) = start_msec;
                        part_micro(kk) = start_microsec;
                        
                    else
                        frac_time = part_time - floor(part_time);
                        frac_time = frac_time * 1000;
                        part_micro(kk) = part_micro(kk-1) + (frac_time - floor(frac_time))*1000;
                        part_mil(kk) = part_mil(kk-1) + uint16(floor(frac_time));
                        part_sec(kk) = part_sec(kk-1) + uint16(floor(part_time));
                        part_min(kk) = part_min(kk-1);
                        part_hour(kk) = part_hour(kk-1);
                        
                    end
                    part_mil(part_micro >= 1000) = part_mil(part_micro >= 1000) + 1;
                    part_micro(part_micro >= 1000) = part_micro(part_micro >= 1000) - 1000;
                    
                    part_sec(part_mil >= 1000) = part_sec(part_mil >= 1000) + 1;
                    part_mil(part_mil >= 1000) = part_mil(part_mil >= 1000) - 1000;

                    part_min(part_sec >= 60) = part_min(part_sec >= 60) + 1;
                    part_sec(part_sec >= 60) = part_sec(part_sec >= 60) - 60;

                    part_hour(part_min >= 60) = part_hour(part_min >= 60) + 1;
                    part_min(part_min >= 60) = part_min(part_min >= 60) - 60;
                    part_hour(part_hour >= 24) = part_hour(part_hour >= 24) - 24;
       

                elseif probetype==2 %SPEC
                    
                    PMSoverload_SPECwkday(kk)= handles.wkday;
                    part_time = double(data(header_loc,7))*2^16+double(data(header_loc,8)); % Interarrival time in tas clock cycles

                    part_micro(kk) = part_time;
                    part_mil(kk)   = 0;
                    part_sec(kk)   = 0;
                    part_min(kk)   = 0;
                    part_hour(kk)  = 0;
                    time_in_seconds(kk) = part_micro(kk)*(diodesize/(10^3)/170);
                    %time_in_seconds(kk) = part_micro(kk)/1e6;

                    %*************************************
                    % If the image is not the first image in the data set,
                    % calculate the interarrival time by subtracting the
                    % previous particle time (in microseconds) from the
                    % current particle time (in microseconds).
                    switch channel(kk)
                        case 'H'
                            if last_H == -1
                                images.int_arrival(kk) = NaN;
                            else 
                                images.int_arrival(kk) = part_micro(kk) - last_H;
                            end
                            last_H = part_micro(kk);
                    
                        case 'V'
                            if last_V == -1
                                images.int_arrival(kk) = NaN;
                            else 
                                images.int_arrival(kk) = part_micro(kk) - last_V;
                            end
                            last_V = part_micro(kk);
                    end
        
                    % Fix interarrival times if the time variable gets too
                    % large for MATLAB, and the times rollover.
                    if images.int_arrival(kk) < 0
                        images.int_arrival(kk) = images.int_arrival(kk) +  (2^32 - 1)
                    end
        
                    %**************************************
                elseif probetype==3 %CIP
                     %slice[127:120] 8-bit slice count
                     %slice[119:115] 5-bit hours
                     %slice[114:109] 6-bit minutes
                     %slice[108:103] 6-bit seconds
                     %slice[102:93] 10-bit milliseconds
                     %slice[92:83] 10-bit microseconds
                     %slice[82:80] 3-eights of microseconds (125 ns)
                     %slice[79:64] 16-bit particle count
                     %slice[63:56] 8-bit true airspeed (in meters per second)
                     %slice[55:0] 56-bit 0's
                      
                     part_hour(kk) = data(header_loc,60)*8+data(header_loc,59)*2+bitshift(data(header_loc,58),-1);
                     if mod((part_hour(kk) - handles.hour),24) >= 11
                        part_hour(kk) = mod(part_hour(kk)+12,12);
                     end
                     part_min(kk) = bitget(data(header_loc,58),1)*32+data(header_loc,57)*8+data(header_loc,56)*2+bitshift(data(header_loc,55),-1);
                     part_sec(kk) = bitget(data(header_loc,55),1)*32+data(header_loc,54)*8+data(header_loc,53)*2+bitshift(data(header_loc,52),-1);
                     part_mil(kk) = bitget(data(header_loc,52),1)*512+data(header_loc,51)*128+data(header_loc,50)*32+data(header_loc,49)*8+data(header_loc,48)*2+bitshift(data(header_loc,47),-1);
                     part_micro(kk) = bitget(data(header_loc,47),1)*512+data(header_loc,46)*128+data(header_loc,45)*32+data(header_loc,44)*8+data(header_loc,43)*2+bitshift(data(header_loc,42),-1);
                     part_micro(kk) = part_micro(kk) + 3/8*(bitget(data(header_loc,42),1)*4+data(header_loc,41));
                     
                     
                     fours = power(4,0:7);
                     fours = power(4,0:3);
                     part_tas = sum(data(header_loc, 29:32).*fours);
                     time_in_seconds(kk) = part_hour(kk) * 3600 + part_min(kk) * 60 + part_sec(kk) + part_mil(kk)/1000 + part_micro(kk)/1e6;
                     time_in_microsecs(kk) = time_in_seconds(kk) * 10^6;
                     

                     if w > 0
                        images.int_arrival(kk) = time_in_microsecs(kk) - last_inter_arrival;
                     else
                        images.int_arrival(kk) =  999999999;
                     end
                     
                     last_inter_arrival = time_in_microsecs(kk); % Save the particle time so that we can use it to calculate the next particle's interarrival time
                     
                    % Fix interarrival times if the time variable gets too
                    % large for MATLAB, and the times rollover.
                    if images.int_arrival(kk) < 0
                        images.int_arrival(kk) = images.int_arrival(kk) +  (2^32 - 1)
                    end
                end
                
                rec_time(kk)=double(handles.hour)*10000+double(handles.minute)*100+double(handles.second);
                rec_date(kk)=double(handles.year)*10000+double(handles.month)*100+double(handles.day);
                rec_millisec(kk)=handles.millisec;
                
%                 % Set the interarrival reject variable to 1 or 0
%                 if images.int_arrival(kk) < inter_arrival_threshold
%                     interarrival_reject(kk) = 1; %Below the threshold
%                 else
%                     interarrival_reject(kk) = 0; %Above the threshold
%                 end
                
                %% Now we have to go through the three levels of image
                %% analysis. Images will continue to levels 2 and 3 only if
                %% they pass our rejection criteria.
                
                % Set these variables to -999. They will stay -999 if the
                % particle is rejected.
                diameter(kk) = -999;
                aspect_ratio(kk) = -999;
                poisson_corrected(kk) = -999;
                number_of_holes(kk) = -999;
                number_of_pieces(kk) = -999;
                perimeter(kk) = -999;
                area(kk) = -999;
                area_ratio(kk) = -999;
                orientation(kk) = -999;
                circularity(kk) = NaN;
                
               % Send image to level 1 to determine if the image is
               % to be rejected or not.
               [artifact_status(kk),slicecount(kk),in_status(kk)]=Image_Analysis_Artifact_Reject_Level_1(c);
                   
                % Pass to level 2 if image has not been identified as an
                % artifact. We identify and correct Poisson spots in this
                % level. If the image is not corrected for a Poisson spot,
                % then the diameter is still -999.
                if artifact_status(kk)==1
                    [diameter(kk),poisson_corrected(kk),number_of_holes(kk),number_of_pieces(kk),area(kk),area_ratio(kk)]=Image_Analysis_Distortion_Correction_Level_2(c);
                end
                
                % Pass to level 3 if the image has not been rejected. 
                if artifact_status(kk)==1 
                    [aspect_ratio(kk),diameter(kk),perimeter(kk),area(kk),area_ratio(kk),orientation(kk),circularity(kk)]=Image_Analysis_Calculate_Parameters_Level_3(c,poisson_corrected(kk),diameter(kk),area(kk),area_ratio(kk));
                end
                
                if diameter(kk) ~= -999
                    diameter(kk) = diameter(kk) * diodesize * 1000; %Convert diameter to microns
                end
                
            if probetype == 3
                start = j + 3;
            else
                start = j + 2;
            end
            
            kk = kk + 1;
            clear c ind_matrix
        end
        j = j+1;
    end
    
    %% Add data to the PROC file
        if kk > 1
        netcdf.putVar ( f, varid.Date, wstart, w-wstart+1, rec_date(:) );
        netcdf.putVar ( f, varid.Time, wstart, w-wstart+1, rec_time(:) );
        netcdf.putVar ( f, varid.msec, wstart, w-wstart+1, rec_millisec(:) );
        netcdf.putVar ( f, varid.Time_in_seconds, wstart, w-wstart+1, time_in_seconds(:) );
        netcdf.putVar ( f, varid.channel, wstart, w-wstart+1, channel);
        netcdf.putVar ( f, varid.position, [0 wstart], [2 w-wstart+1], images.position' );
%         netcdf.putVar ( f, varid.particle_time, wstart, w-wstart+1, part_hour(:)*10000+part_min(:)*100+part_sec(:) );
%         netcdf.putVar ( f, varid.millisec, wstart, w-wstart+1, part_mil(:) );
%         netcdf.putVar ( f, varid.microsec, wstart, w-wstart+1, part_micro(:) );
        netcdf.putVar ( f, varid.parent_rec_num, wstart, w-wstart+1, parent_rec_num );
        netcdf.putVar ( f, varid.inter_arrival, wstart, w-wstart+1, images.int_arrival );
        netcdf.putVar ( f, varid.artifact_status, wstart, w-wstart+1, artifact_status);        
        netcdf.putVar ( f, varid.diameter, wstart, w-wstart+1, diameter);
        netcdf.putVar ( f, varid.aspect_ratio, wstart, w-wstart+1, aspect_ratio);
        netcdf.putVar ( f, varid.orientation, wstart, w-wstart+1, orientation);
        netcdf.putVar ( f, varid.slicecount, wstart, w-wstart+1, slicecount);
        netcdf.putVar ( f, varid.poisson_corrected, wstart, w-wstart+1, poisson_corrected);
        netcdf.putVar ( f, varid.perimeter, wstart, w-wstart+1, perimeter);
        netcdf.putVar ( f, varid.area, wstart, w-wstart+1, area);
        netcdf.putVar ( f, varid.number_of_holes, wstart, w-wstart+1, number_of_holes);
        netcdf.putVar ( f, varid.number_of_pieces, wstart, w-wstart+1, number_of_pieces);
        netcdf.putVar ( f, varid.area_ratio, wstart, w-wstart+1, area_ratio);
        netcdf.putVar ( f, varid.in_status, wstart, w-wstart+1, in_status);
        netcdf.putVar ( f, varid.circularity, wstart, w-wstart+1, circularity);
%        netcdf.putVar ( f, varid.interarrival_reject, wstart, w-wstart+1, interarrival_reject);

        wstart = w+1;
        kk = 1;
        buffer_end = 1;
        
        % Clear the variables for the next buffer
        clear rec_time rec_date rec_millisec part_hour part_min part_sec part_mil part_micro parent_rec_num images time_in_seconds in_status circularity slicecount PMSoverload_SPECwkday height artifact_status diameter aspect_ratio poisson_corrected perimeter area area_ratio number_of_holes number_of_pieces orientation channel inter_arrival_H inter_arrival_V
        end
        clear images
end
warning on all 
netcdf.close(handles.f);
netcdf.close(f);

%% After the file has been generated, we open the newly created file and read in the interarrival times.
%% Any image with an interarrival time below the threshold is assigned a value of 1 to the interarrival_reject
%% variable.
infile = netcdf.open(outfile,'WRITE');
inter_arrival = netcdf.getVar(infile,netcdf.inqVarID(infile,'inter_arrival'));
interarrival_reject = zeros(length(inter_arrival),1);
below_threshold = find(inter_arrival <= inter_arrival_threshold);
interarrival_reject(below_threshold) = 1;
netcdf.putVar ( infile, varid.interarrival_reject, interarrival_reject);
netcdf.close(infile);
end