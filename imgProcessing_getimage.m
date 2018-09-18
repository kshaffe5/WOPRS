function imgProcessing_getimage(n,nEvery,threshold)
%% Processing nth chuck. Every chuck is nEvery frame
%% Analyze each individual particle image and Output the particle by particle information
for i=((n-1)*nEvery+1):min(n*nEvery,handles.img_count)

    handles.year     = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'year'    ),i-1,1);
    handles.month    = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'month'  ),i-1,1);
    handles.day      = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'day'  ),i-1,1);
    handles.hour     = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'hour'    ),i-1,1);
    handles.minute   = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'minute'  ),i-1,1);
    handles.second   = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'second'  ),i-1,1);
    handles.millisec = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'millisec'),i-1,1);
    if probetype == 0
        handles.wkday    = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'wkday'),i-1,1);
    end
    if mod(i,100) == 0
        [num2str(i),'/',num2str(handles.img_count), ', ',datestr(now)]
    end
    varid = netcdf.inqVarID(handles.f,'data');
    
    if probetype==0
        temp = netcdf.getVar(handles.f,varid,[0, 0, i-1], [4,1024,1]);
    elseif(probetype == 3)
        temp = netcdf.getVar(handles.f,varid,[0, 0, i-1], [64,512,1]);
    else
        temp = netcdf.getVar(handles.f,varid,[0, 0, i-1], [8,1700,1]);
    end
    data(:,:) = temp';  
    
    j=1;
    start=0;
    firstpart = 1;
    
    %c=[dec2bin(data(:,1),8),dec2bin(data(:,2),8),dec2bin(data(:,3),8),dec2bin(data(:,4),8)];
    while data(j,1) ~= -1 && j < size(data,1)
        % Calculate every particle
        if (isequal(data(j,:), boundary) && ( (isequal(data(j+1,1), boundarytime) || probetype==1) ) )
           if start ==0
               if 1 == probetype 
                   start = 2;
               elseif 2 == probetype
                   start = 1;
               else
                   start = 1;
               end
           end
            
               if probetype==0
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
                   header_loc = j+2; % Previously j=2+2 if encountered on first iteration
                else
                   header_loc = j+1;
                end
                w=w+1;
                %% Create binary image according to probe type
                   
                if probetype==0    
                    ind_matrix(1:j-start-1,:) = data(start+1:j-1,:);  % 2DC has 3 slices between particles (sync word, timing word, and end of particle words)
                    c=[dec2bin(ind_matrix(:,1),8),dec2bin(ind_matrix(:,2),8),dec2bin(ind_matrix(:,3),8),dec2bin(ind_matrix(:,4),8)];
                elseif probetype==1
                    ind_matrix(1:j-start,:) = data(start:j-1,:);
                    c=[dec2bin(ind_matrix(:,1),8), dec2bin(ind_matrix(:,2),8),dec2bin(ind_matrix(:,3),8),dec2bin(ind_matrix(:,4),8), ...
                    dec2bin(ind_matrix(:,5),8), dec2bin(ind_matrix(:,6),8),dec2bin(ind_matrix(:,7),8),dec2bin(ind_matrix(:,8),8)];
                elseif probetype==2
                    ind_matrix(1:j-start,:) = 65535 - data(start:j-1,:); % I used 1 to indicate the illuminated doides for HVPS
                    c=[dec2bin(ind_matrix(:,1),16), dec2bin(ind_matrix(:,2),16),dec2bin(ind_matrix(:,3),16),dec2bin(ind_matrix(:,4),16), ...
                    dec2bin(ind_matrix(:,5),16), dec2bin(ind_matrix(:,6),16),dec2bin(ind_matrix(:,7),16),dec2bin(ind_matrix(:,8),16)];
                elseif probetype==3
                    %% Set thresholding
                    
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
                end
                
                % Just to test if there is bad images, usually 0 area images
                figsize = size(c);
                if figsize(2)~=diodenum
                    disp('Not equal to doide number');
                    return
                end
                
                
                images.position(kk,:) = [start, j-1];
                parent_rec_num(kk)=i;
                %particle_num(kk) = mod(kk,66536); %hex2dec([dec2hex(data(start-1,7)),dec2hex(data(start-1,8))]);
                if(probetype < 3)
                   particle_num(kk) = mod(kk,66536); %hex2dec([dec2hex(data(start-1,7)),dec2hex(data(start-1,8))]);
                end
                %  Get the particle time 
                if probetype==0 
                    bin_convert = [dec2bin(data(header_loc,2),8),dec2bin(data(header_loc,3),8),dec2bin(data(header_loc,4),8)];
                    part_time = bin2dec(bin_convert)*clockfactor;       % Interarrival time in tas clock cycles -- needs to be multiplied by 2 for the King Air 2DP probe
                    tas2d = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'tas'),i-1, 1);
                    part_time = part_time/tas2d*handles.diodesize/(10^3);                    
                    time_in_seconds(kk) = part_time;
                    particle_sliceCount(kk) = size(ind_matrix,1); %Needs to be changed
                    particle_DOF(kk) = handles.wkday;
                    
                    images.int_arrival(kk) = part_time;
                    
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
                        
                        particle_partNum(kk) = 1;
                    else
                        frac_time = part_time - floor(part_time);
                        frac_time = frac_time * 1000;
                        part_micro(kk) = part_micro(kk-1) + (frac_time - floor(frac_time))*1000;
                        part_mil(kk) = part_mil(kk-1) + floor(frac_time);
                        part_sec(kk) = part_sec(kk-1) + floor(part_time);
                        part_min(kk) = part_min(kk-1);
                        part_hour(kk) = part_hour(kk-1);
                        
                        particle_partNum(kk) = particle_partNum(kk-1) + 1;
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
                elseif probetype==1
                    bin_convert = [dec2bin(data(start-1,2),8),dec2bin(data(start-1,3),8),dec2bin(data(start-1,4),8), ...
                        dec2bin(data(start-1,5),8), dec2bin(data(start-1,6),8)];

                    part_hour(kk) = bin2dec(bin_convert(1:5));
                    part_min(kk) = bin2dec(bin_convert(6:11));
                    part_sec(kk) = bin2dec(bin_convert(12:17));
                    part_mil(kk) = bin2dec(bin_convert(18:27));
                    part_micro(kk) = bin2dec(bin_convert(28:40))*125e-9;
                
                    particle_sliceCount(kk)=bitand(data(start-1,1),127);
                    particle_DOF(kk)=bitand(data(start-1,1),128);
                    particle_partNum(kk)=bin2dec([dec2bin(data(start-1,7),8),dec2bin(data(start-1,8),8)]);

                    time_in_seconds(kk) = part_hour(kk) * 3600 + part_min(kk) * 60 + part_sec(kk) + part_mil(kk)/1000 + part_micro(kk);
                    if kk > 1
                        images.int_arrival(kk) = time_in_seconds(kk) - time_in_seconds(kk-1);
                    else
                        images.int_arrival(kk) = time_in_seconds(kk);
                    end


                elseif probetype==2

                    particle_DOF(kk)=bitand(data(header_loc,4), 32768);
                    particle_partNum(kk)=double(data(header_loc,5));
                    particle_sliceCount(kk)=double(data(header_loc,6));

                    part_time = double(data(header_loc,7))*2^16+double(data(header_loc,8));       % Interarrival time in tas clock cycles
                    part_micro(kk) = part_time;
                    part_mil(kk)   = 0;
                    part_sec(kk)   = 0;
                    part_min(kk)   = 0;
                    part_hour(kk)  = 0;
                    time_in_seconds(kk) = part_time*(handles.diodesize/(10^3)/170);
                    if(kk>1)
                        images.int_arrival(kk) = part_time-part_micro(kk-1); 
                    else
                        images.int_arrival(kk) = 0;
                    end
                elseif probetype==3
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
                     
                     fours = power(4,0:2);
                     particle_sliceCount(kk)= 2*sum(data(header_loc,60:62).*fours)+floor(data(header_loc,63)/2);%bitand(data(header_loc,1),127);
                     particle_DOF(kk)=mod(data(header_loc,63),2);
                     particle_partNum(kk)=0;
                     
                     fours = power(4,0:7);
                     particle_num(kk) = sum(data(header_loc,33:40).*fours);
                     fours = power(4,0:3);
                     part_tas = sum(data(header_loc, 29:32).*fours);
                     time_in_seconds(kk) = part_hour(kk) * 3600 + part_min(kk) * 60 + part_sec(kk) + part_mil(kk)/1000 + part_micro(kk)/1e6;
                     if kk > 1
                        images.int_arrival(kk) = time_in_seconds(kk) - time_in_seconds(kk-1);
                     else
                        images.int_arrival(kk) = time_in_seconds(kk);
                     end
                end
                
                temptimeinhhmmss = part_hour(kk) * 10000 + part_min(kk) * 100 + part_sec(kk);
                
                slices_ver = length(start:j-1);
                rec_time(kk)=double(handles.hour)*10000+double(handles.minute)*100+double(handles.second);
                rec_date(kk)=double(handles.year)*10000+double(handles.month)*100+double(handles.day);
                rec_millisec(kk)=handles.millisec;
                rec_wkday(kk)=handles.wkday(i);

end