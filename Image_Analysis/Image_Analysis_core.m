function Image_Analysis_core(infile, outfile, probename, threshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is the base function for the image processsing step of OAP 
% processing. This step utilizes parallel processing to speed up the 
% processing speed. All probetypes are compatible with this function.
% 
% Inputs:
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
%    use ProbeType to indicate three types of probes:
%       1: 2DC/2DP 
%       2: HVPS/2DS
%       3: CIPG 

switch probename
    case '2DC'
        boundary=[255 255 255 255];
        boundarytime=85;

        handles.diodesize = 0.025;  % Size of diode in millimeters
        handles.diodenum  = 32;  % Diode number
        probetype=1;

    case '2DP'
        boundary=[255 255 255 255];
        boundarytime=0
        
        handles.diodesize = 0.200;  % Size of diode in millimeters 
        handles.diodenum  = 32;  % Diode number
        probetype=1;
        clockfactor = 2.; %Correction in clock cycles in timer word for 2DP probe and King Air data system in conjunction
 
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
        
    case 'CIPG'
        boundary=3*ones(1,64);
        boundarytime=3;
		    
        handles.diodesize = 0.025;  % Size of diode in millimeters
        handles.diodenum  = 64;  % Diode number
        probetype=3;
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

diodenum = handles.diodenum;

% Read the particle image files
handles.f = netcdf.open(infile,'nowrite');
[~, handles.img_count] = netcdf.inqDim(handles.f,0); 
warning off all


% Create output NETCDF file and define the variables

f = netcdf.create(outfile, 'CLOBBER');
dimid0 = netcdf.defDim(f,'time',netcdf.getConstant('NC_UNLIMITED'));
dimid1 = netcdf.defDim(f,'pos_count',2);
dimid2 = netcdf.defDim(f,'bin_count',diodenum);

% Variables that are calculated/found for all particles
varid0 = netcdf.defVar(f,'Date','short',dimid0);
varid1  = netcdf.defVar(f,'Time','short',dimid0);
varid2  = netcdf.defVar(f,'msec','short',dimid0);
varid3  = netcdf.defVar(f,'Time_in_seconds','short',dimid0);
varid4  = netcdf.defVar(f,'SliceCount','short',dimid0);
varid5  = netcdf.defVar(f,'PMS_overload_SPEC_wkday','double',dimid0);
varid6  = netcdf.defVar(f,'Particle_number_all','double',dimid0);
varid7  = netcdf.defVar(f,'position','short',[dimid1 dimid0]);
varid8  = netcdf.defVar(f,'particle_time','short',dimid0);
varid9  = netcdf.defVar(f,'particle_millisec','short',dimid0);
varid10  = netcdf.defVar(f,'particle_microsec','short',dimid0);
varid11  = netcdf.defVar(f,'parent_rec_num','short',dimid0);
varid12 = netcdf.defVar(f,'height','short',dimid0);  
varid13 = netcdf.defVar(f,'inter_arrival','short',dimid0);
varid14 = netcdf.defVar(f,'reject_status','short',dimid0); 
varid15 = netcdf.defVar(f,'equiv_diam','short',dimid0);
varid16 = netcdf.defVar(f,'area','ushort',dimid0);
varid17 = netcdf.defVar(f,'num_holes','ushort',dimid0);
varid18 = netcdf.defVar(f,'hole_area','ushort',dimid0); 
varid19 = netcdf.defVar(f,'eccentricity','ushort',dimid0);
varid20 = netcdf.defVar(f,'circularity','ushort',dimid0);
varid21 = netcdf.defVar(f,'orientation','ushort',dimid0);

netcdf.endDef(f)

% Variables initialization 
kk=1;
w=-1;
wstart = 0;

% Begin the processing by reading in the variable information 
% This is the start of our loop over every individual particle
%for i=((n-1)*nEvery+1):min(n*nEvery,handles.img_count)
handles.img_count
for i=(1:handles.img_count)

    handles.year     = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'year'    ),i-1,1);
    handles.month    = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'month'  ),i-1,1);
    handles.day      = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'day'  ),i-1,1);
    handles.hour     = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'hour'    ),i-1,1);
    handles.minute   = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'minute'  ),i-1,1);
    handles.second   = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'second'  ),i-1,1);
    handles.millisec = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'millisec'),i-1,1);
    handles.tas      = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'tas'),i-1,1);
    if probetype == 1 %PMS
        handles.overload    = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'overload'),i-1,1);
    elseif probetype ==2 %SPEC
        handles.wkday       = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'wkday'),i-1,1);
    else %CIPG
        handles.empty       = netcdf.getVar(handles.f,netcdf.inqVarID(handles.f,'empty'),i-1,1);
    end
     if mod(i,100) == 0
        [num2str(i),'/',num2str(handles.img_count), ', ',datestr(now)]
     end
    
    % Data sizes vary between the probetypes
    varid = netcdf.inqVarID(handles.f,'data');
    if probetype==1 %PMS
        temp = netcdf.getVar(handles.f,varid,[0, 0, i-1], [4,1024,1]);
    elseif(probetype == 2) %SPEC
        temp = netcdf.getVar(handles.f,varid,[0, 0, i-1], [8,1700,1]);
    else %CIPG
        temp = netcdf.getVar(handles.f,varid,[0, 0, i-1], [64,512,1]);
    end
    data(:,:) = temp';  
    
    j=1;
    start=0;
    firstpart = 1;
    
    while data(j,1) ~= -1 && j < size(data,1)
        if (isequal(data(j,:), boundary) && ( (isequal(data(j+1,1), boundarytime) || probetype==1) ) )
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
                
                
% NOW WE NEED TO CLASSIFY PARTCILES AND CALCULATE PERIMETER, AREA, ETC... 
            
                % Just to test if there is bad images, usually 0 area images
                figsize = size(c);
                if figsize(2)~=diodenum
                    disp('Not equal to doide number');
                    return
                end
                
                images.position(kk,:) = [start, j-1];
                parent_rec_num(kk)=i;
                if(probetype < 2)
                   particle_num(kk) = mod(kk,66536); 
                end
                
                %  Get the particle time 
                if probetype==1 %PMS
                    bin_convert = [dec2bin(data(header_loc,2),8),dec2bin(data(header_loc,3),8),dec2bin(data(header_loc,4),8)];
                    part_time = bin2dec(bin_convert)*clockfactor;       % Interarrival time in tas clock cycles -- needs to be multiplied by 2 for the 2DP probe
                    part_time = part_time/tas*handles.diodesize/(10^3);                    
                    time_in_seconds(kk) = part_time;
                    PMSoverload_SPECwkday(kk)= handles.overload; 
                    
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
                        
                    else
                        frac_time = part_time - floor(part_time);
                        frac_time = frac_time * 1000;
                        part_micro(kk) = part_micro(kk-1) + (frac_time - floor(frac_time))*1000;
                        part_mil(kk) = part_mil(kk-1) + floor(frac_time);
                        part_sec(kk) = part_sec(kk-1) + floor(part_time);
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
                    
                elseif probetype==3 %CIPG
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
                     
                     PMSoverload_SPECwkday(kk)= handles.empty;
                     
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
                
                % Now we have to go through the three levels of image
                % analysis. Images will continue to levels 2 and 3 only if
                % they pass our criteria of the previous level(s)
                
                num_holes = -999;
                hole_area = -999;
                eccentricity = -999;
                circularity = -999;
                orientation = -999;
                
                [slicecount,height,reject_status,equiv_diam,area]=Image_Analysis_Classification_level_1(c);
            
                if reject_status==0
                    [num_holes,hole_area,reject_status]=Image_Analysis_Classification_level_2(c);
                end
                
                if reject_status==0
                    [eccentricity,circularity,orientation,reject_status]=Image_Analysis_Classification_level_3(c);
                end

                
                
        netcdf.putVar ( f, varid0, wstart, w-wstart+1, rec_date(:) );
        netcdf.putVar ( f, varid1, wstart, w-wstart+1, rec_time(:) );
        netcdf.putVar ( f, varid2, wstart, w-wstart+1, rec_millisec(:) );
        netcdf.putVar ( f, varid3, wstart, w-wstart+1, time_in_seconds(:) );
        netcdf.putVar ( f, varid4, wstart, w-wstart+1, slicecount );
        netcdf.putVar ( f, varid5, wstart, w-wstart+1, PMSoverload_SPECwkday );
        netcdf.putVar ( f, varid6, wstart, w-wstart+1, particle_num(:) );
        netcdf.putVar ( f, varid7, [0 wstart], [2 w-wstart+1], images.position );
        netcdf.putVar ( f, varid8, wstart, w-wstart+1, part_hour(:)*10000+part_min(:)*100+part_sec(:) );
        netcdf.putVar ( f, varid9, wstart, w-wstart+1, part_mil(:) );
        netcdf.putVar ( f, varid10, wstart, w-wstart+1, part_micro(:) );
        netcdf.putVar ( f, varid11, wstart, w-wstart+1, parent_rec_num );
        netcdf.putVar ( f, varid12, wstart, w-wstart+1, height );
        netcdf.putVar ( f, varid13, wstart, w-wstart+1, images.int_arrival );
        netcdf.putVar ( f, varid14, wstart, w-wstart+1, reject_status );
        netcdf.putVar ( f, varid15, wstart, w-wstart+1, equiv_diam );
        netcdf.putVar ( f, varid16, wstart, w-wstart+1, area );
        netcdf.putVar ( f, varid17, wstart, w-wstart+1, num_holes );
        netcdf.putVar ( f, varid18, wstart, w-wstart+1, hole_area );
        netcdf.putVar ( f, varid19, wstart, w-wstart+1, eccentricity );
        netcdf.putVar ( f, varid20, wstart, w-wstart+1, circularity );
        netcdf.putVar ( f, varid21, wstart, w-wstart+1, orientation );
        
        
        wstart = w+1;
        kk = 1;
        clear rec_time rec_date rec_millisec part_hour part_min part_sec part_mil part_micro parent_rec_num particle_num images time_in_seconds slicecount

    end
    clear images
end
warning on all

netcdf.close(handles.f);
netcdf.close(f);
end