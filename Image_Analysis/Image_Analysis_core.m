function Image_Analysis_core(infile, outfile, probetype, n, nEvery, threshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is the base function for the image processsing step of OAP 
% processing. This step utilizes parallel processing to speed up the 
% processing speed. All probetypes are compatible with this function.
% 
% User Inputs:
% infile - full directory listing of the image file created during the
%          OAP_to_NETCDF step.
% outfile - infilename with '.proc.cdf' at the end of the file name
% probetype - the shorthand name of the probe (ex. '2DS', 'CIPG', etc...)
% n - the starting point to start processing
% nEvery - the size of the data to be processed
% threshold - shaded cip-gray threshold percentage (defaults to 50 if not
%             provided)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setting probe information according to probe type
%    use ProbeType to indicate four types of probes:
%       0: 2DC/2DP 
%       1: CIP/PIP **(Currently not in use)**
%       2: HVPS/2DS
%       3: CIPG 

switch probename
    case '2DC'
        boundary=[255 255 255 255];
        boundarytime=85;

        handles.diodesize = 0.025;  % Size of diode in millimeters
        handles.diodenum  = 32;  % Diode number
        probetype=0;

    case '2DP'
        boundary=[255 255 255 255];
        boundarytime=0
        
        handles.diodesize = 0.200;  % Size of diode in millimeters 
        handles.diodenum  = 32;  % Diode number
        probetype=0;
        clockfactor = 2.; %Correction in clock cycles in timer word for 2DP probe and King Air data system in conjunction

    case 'CIPG'
        boundary=3*ones(1,64);
        boundarytime=3;
		    
        handles.diodesize = 0.025;  % Size of diode in millimeters
        handles.diodenum  = 64;  % Diode number
        probetype=3;
 
    case 'HVPS'
        boundary=[43690, 43690, 43690, 43690, 43690, 43690, 43690, 43690];
        boundarytime=0;

        handles.diodesize = 0.150;  % Size of diode in millimeters
        handles.diodenum  = 128;  % Diode number
        probetype=2;

    case '2DS'
        boundary=[43690, 43690, 43690, 43690, 43690, 43690, 43690, 43690];
        boundarytime=0;
			     
        handles.diodesize = 0.010;  % Size of diode in millimeters
        handles.diodenum  = 128;  % Diode number
        probetype=2;
    otherwise 
        disp('ERROR: Probetype is not supported. Please enter one of the following: 2DP, 2DC, 2DS, HVPS, or CIPG.')
        return;
end

% Threshold defaults to 50% if it was not provided by the user
if(~exist('threshold','var'))
	threshold = 50;
end

% Only the 2DP has a clockfactor, otherwise it is just 1
if(~exist('clockfactor'))
    clockfactor = 1.;
end


% Read the particle image files
handles.f = netcdf.open(infile,'nowrite');
[~, dimlen] = netcdf.inqDim(handles.f,2);
[~, handles.img_count] = netcdf.inqDim(handles.f,0); 
warning off all
diode_stats = zeros(1,diodenum);


% Create output NETCDF-4 file and define the variables
if exist(outfile)
    delete(outfile)
end
f = netcdf.create(outfile, 'NETCDF4');
dimid0 = netcdf.defDim(f,'time',netcdf.getConstant('NC_UNLIMITED'));
dimid1 = netcdf.defDim(f,'pos_count',2);
dimid2 = netcdf.defDim(f,'bin_count',diodenum);

varid0 = netcdf.defVar(f,'Date','ushort',dimid0);
varid1  = netcdf.defVar(f,'Time','ushort',dimid0);
varid2  = netcdf.defVar(f,'msec','ushort',dimid0);
varid3  = netcdf.defVar(f,'Time_in_seconds','ushort',dimid0);
varid4  = netcdf.defVar(f,'SliceCount','ushort',dimid0);
varid5  = netcdf.defVar(f,'PMS_overload_SPEC_wkday','double',dimid0);
varid6  = netcdf.defVar(f,'Particle_number_all','double',dimid0);
varid7  = netcdf.defVar(f,'position','ushort',[dimid1 dimid0]);
varid8  = netcdf.defVar(f,'particle_time','ushort',dimid0);
varid9  = netcdf.defVar(f,'particle_millisec','ushort',dimid0);
varid10  = netcdf.defVar(f,'particle_microsec','ushort',dimid0);
varid11  = netcdf.defVar(f,'parent_rec_num','ushort',dimid0);
varid12  = netcdf.defVar(f,'particle_num','ushort',dimid0);
varid13 = netcdf.defVar(f,'image_length','ushort',dimid0);                                
varid14 = netcdf.defVar(f,'image_width','ushort',dimid0);                                 
varid15 = netcdf.defVar(f,'image_area','ushort',dimid0); 
varid16 = netcdf.defVar(f,'image_perimeter','ushort',dimid0);
varid17 = netcdf.defVar(f,'image_max_top_edge_touching','ushort',dimid0);                 
varid18 = netcdf.defVar(f,'image_max_bottom_edge_touching','ushort',dimid0);              
varid19 = netcdf.defVar(f,'image_touching_edge','ushort',dimid0); 
varid20 = netcdf.defVar(f,'percent_shadow_area','ushort',dimid0);
varid21 = netcdf.defVar(f,'particle_class','ushort',dimid0);  % Replacing holroyd habits and reject statuses

% Undecided on these:
%***************************************************************
varid13 = netcdf.defVar(f,'image_longest_y','short',dimid0);                                                                                                               
varid19 = netcdf.defVar(f,'image_center_in','short',dimid0);                             
varid20 = netcdf.defVar(f,'image_axis_ratio','short',dimid0);                            
varid21 = netcdf.defVar(f,'image_diam_circle_fit','short',dimid0);                       
varid22 = netcdf.defVar(f,'image_diam_horiz_chord','short',dimid0);                      
varid23 = netcdf.defVar(f,'image_diam_horiz_chord_corr','short',dimid0);                              
varid25 = netcdf.defVar(f,'image_diam_vert_chord','short',dimid0);                       
varid26 = netcdf.defVar(f,'image_diam_minR','short',dimid0);                       
varid27 = netcdf.defVar(f,'image_diam_AreaR','short',dimid0);                              
varid29 = netcdf.defVar(f,'edge_at_max_hole','short',dimid0);                            
varid30 = netcdf.defVar(f,'max_hole_diameter','short',dimid0);                                                                 
varid32 = netcdf.defVar(f,'size_factor','short',dimid0);                                                                
varid34 = netcdf.defVar(f,'area_hole_ratio','short',dimid0);                             
varid35 = netcdf.defVar(f,'inter_arrival','short',dimid0);                               
varid36 = netcdf.defVar(f,'bin_stats','short',dimid2);   
%***************************************************************

netcdf.endDef(f)

% Variables initialization 
kk=1;
w=-1;
wstart = 0;

% Begin the processing by reading in the variable information  
for i=((n-1)*nEvery+1):min(n*nEvery,handles.img_count)

    handles.year     = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'year'    ),i-1,1);
    handles.month    = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'month'  ),i-1,1);
    handles.day      = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'day'  ),i-1,1);
    handles.hour     = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'hour'    ),i-1,1);
    handles.minute   = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'minute'  ),i-1,1);
    handles.second   = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'second'  ),i-1,1);
    handles.millisec = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'millisec'),i-1,1);
    handles.tas      = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'tas'),i-1,1);
    if probetype == 0
        handles.overload    = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'overload'),i-1,1);
    elseif probetype ==2
        handles.wkday       = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'wkday'),i-1,1);
    else
        handles.empty       = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'wkday'),i-1,1);
    end
     if mod(i,100) == 0
        [num2str(i),'/',num2str(handles.img_count), ', ',datestr(now)]
     end
    
    % Data sizes vary between the probetypes
    varid = netcdf.inqVarID(handles.f,'data');
    if probetype==0 %PMS
        temp = netcdf.getVar(handles.f,varid,[0, 0, i-1], [4,1024,1]);
    elseif(probetype == 3) %CIPG
        temp = netcdf.getVar(handles.f,varid,[0, 0, i-1], [64,512,1]);
    else %SPEC
        temp = netcdf.getVar(handles.f,varid,[0, 0, i-1], [8,1700,1]);
    end
    data(:,:) = temp';  
    
    j=1;
    start=0;
    firstpart = 1;
    
    while data(j,1) ~= -1 && j < size(data,1)
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
                   header_loc = j+2;
                else
                   header_loc = j+1;
                end
                w=w+1;
                
                % Create binary image according to probe type
                   
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
                end
                
                % Just to test if there is bad images, usually 0 area images
                figsize = size(c);
                if figsize(2)~=diodenum
                    disp('Not equal to doide number');
                    return
                end
                
                images.position(kk,:) = [start, j-1];
                parent_rec_num(kk)=i;
                if(probetype < 3)
                   particle_num(kk) = mod(kk,66536); 
                end
                
                %  Get the particle time 
                if probetype==0 %PMS
                    bin_convert = [dec2bin(data(header_loc,2),8),dec2bin(data(header_loc,3),8),dec2bin(data(header_loc,4),8)];
                    part_time = bin2dec(bin_convert)*clockfactor;       % Interarrival time in tas clock cycles -- needs to be multiplied by 2 for the King Air 2DP probe
                    part_time = part_time/tas*handles.diodesize/(10^3);                    
                    time_in_seconds(kk) = part_time;
                    particle_sliceCount(kk) = size(ind_matrix,1); %Needs to be changed
                    particle_misc(kk)= handles.overload; 
                    
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
                    particle_partNum(kk)=bin2dec([dec2bin(data(start-1,7),8),dec2bin(data(start-1,8),8)]);

                    time_in_seconds(kk) = part_hour(kk) * 3600 + part_min(kk) * 60 + part_sec(kk) + part_mil(kk)/1000 + part_micro(kk);
                    if kk > 1
                        images.int_arrival(kk) = time_in_seconds(kk) - time_in_seconds(kk-1);
                    else
                        images.int_arrival(kk) = time_in_seconds(kk);
                    end


                elseif probetype==2 %SPEC

                    particle_partNum(kk)=double(data(header_loc,5));
                    particle_sliceCount(kk)=double(data(header_loc,6));
                    particle_misc(kk)= handles.wkday;

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
                     particle_partNum(kk)=0;
                     particle_misc(kk)= handles.empty;
                     
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
                
                rec_time(kk)=double(handles.hour)*10000+double(handles.minute)*100+double(handles.second);
                rec_date(kk)=double(handles.year)*10000+double(handles.month)*100+double(handles.day);
                rec_millisec(kk)=handles.millisec;
   
% NOW WE NEED TO CLASSIFY PARTCILES AND CALCULATE PERIMETER, AREA, ETC...   