function Create_NETCDF_SPEC(infilename,outfilename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Read the raw base*.2DS file, and then write into NETCDF file 
%% 
%% 2DS manual : http://www.specinc.com/sites/default/files/software_and_manuals/2D-S_Technical%20Manual_rev3.1_20110228.pdf
%%
%% HVPS manual : http://www.specinc.com/sites/default/files/software_and_manuals/HVPS_Technical%20Manual_rev1.2_20130227.pdf
%%
%% Edited by Kevin Shaffer 6/24/2019
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global tas

% The first 22 lines are used to create the output files: 

starpos = find(infilename == '*',1,'last');
slashpos = find(infilename == '/',1,'last');

if ~isempty(starpos) | outfilename == '1'
    files = dir(infilename);
    filenums = length(files);
    filedir = infilename(1:slashpos);
else
    filenums = 1;
end

for i = 1:filenums
    if filenums > 1 || ~isempty(starpos)
        infilename = [filedir,files(i).name];
    end
    
    if outfilename == '1'
        outfilename = [filedir,'DIMG.',files(i).name];
    end
    
    
    % Naming the output files
    outfilename0=[outfilename, '.HK.cdf']; % Housekeeping data
    outfilename1=[outfilename, '.H.cdf']; % Horizontal image data
    outfilename2=[outfilename, '.V.cdf']; % Vertical image data
    
    
    
    % Overwrite any existing files with the same name as the new files
    
    if exist(outfilename0)
         delete(outfilename0)
    end
    
    if exist(outfilename1)
         delete(outfilename1)
    end
    
    if exist(outfilename2)
         delete(outfilename2)
    end
    
    % Open the input file in read-only ('r') mode for reading in
    % little-endian ('l').
    
    fid=fopen(infilename,'r','l');
    
    tas = 1; % Set tas to 1 before the first set of housekeeping data
    
    %  Create the housekeeping file
    
    f0 = netcdf.create(outfilename0, 'NETCDF4');
    
    dim0 = netcdf.defDim(f0,'time',netcdf.getConstant('NC_UNLIMITED'));
    
    var0 = netcdf.defVar(f0,'year','short',dim0);
    var1 = netcdf.defVar(f0,'month','short',dim0);
    var2 = netcdf.defVar(f0,'day','short',dim0);
    var3 = netcdf.defVar(f0,'hour','short',dim0);
    var4 = netcdf.defVar(f0,'minute','short',dim0);
    var5 = netcdf.defVar(f0,'second','short',dim0);
    var6 = netcdf.defVar(f0,'millisec','short',dim0);
    var7 = netcdf.defVar(f0,'wkday','short',dim0);
    var8 = netcdf.defVar(f0,'horizontal_element_0_voltage','float',dim0);
    var9 = netcdf.defVar(f0,'horizontal_element_64_voltage','float',dim0);
    var10 = netcdf.defVar(f0,'horizontal_element_127_voltage','float',dim0);
    var11 = netcdf.defVar(f0,'vertical_element_0_voltage','float',dim0);
    var12 = netcdf.defVar(f0,'vertical_element_64_voltage','float',dim0);
    var13 = netcdf.defVar(f0,'vertical_element_127_voltage','float',dim0);
    var14 = netcdf.defVar(f0,'raw_positive_power_supply','float',dim0);
    var15 = netcdf.defVar(f0,'raw_negative_power_supply','float',dim0);
    var16 = netcdf.defVar(f0,'horizontal_arm_Tx_temp','float',dim0);
    var17 = netcdf.defVar(f0,'horizontal_arm_Rx_temp','float',dim0);
    var18 = netcdf.defVar(f0,'vertical_arm_Tx_temp','float',dim0);
    var19 = netcdf.defVar(f0,'vertical_arm_Rx_temp','float',dim0);
    var20 = netcdf.defVar(f0,'horizontal_tip_Tx_temp','float',dim0);
    var21 = netcdf.defVar(f0,'horizontal_tip_Rx_temp','float',dim0);
    var22 = netcdf.defVar(f0,'rear_optical_bridge_temp','float',dim0);
    var23 = netcdf.defVar(f0,'DSP_board_temp','float',dim0);
    var24 = netcdf.defVar(f0,'forward_vessel_temp','float',dim0);
    var25 = netcdf.defVar(f0,'horizontal_laser_temp','float',dim0);
    var26 = netcdf.defVar(f0,'vertical_laser_temp','float',dim0);
    var27 = netcdf.defVar(f0,'front_plate_temp','float',dim0);
    var28 = netcdf.defVar(f0,'power_supply_temp','float',dim0);
    var29 = netcdf.defVar(f0,'negative_5_volt_supply','float',dim0);
    var30 = netcdf.defVar(f0,'positive_5_volt_supply','float',dim0);
    var31 = netcdf.defVar(f0,'can_internal_pressure','float',dim0);
    var32 = netcdf.defVar(f0,'horizontal_element_21_voltage','float',dim0);
    var33 = netcdf.defVar(f0,'horizontal_element_42_voltage','float',dim0);
    var34 = netcdf.defVar(f0,'horizontal_element_85_voltage','float',dim0);
    var35 = netcdf.defVar(f0,'horizontal_element_106_voltage','float',dim0);
    var36 = netcdf.defVar(f0,'vertical_element_21_voltage','float',dim0);
    var37 = netcdf.defVar(f0,'vertical_element_42_voltage','float',dim0);
    var38 = netcdf.defVar(f0,'vertical_element_85_voltage','float',dim0);
    var39 = netcdf.defVar(f0,'vertical_element_106_voltage','float',dim0);
    var40 = netcdf.defVar(f0,'vertical_particles_detected','double',dim0);
    var41 = netcdf.defVar(f0,'horizontal_particles_detected','double',dim0);
    var42 = netcdf.defVar(f0,'heater_outputs','short',dim0); % Check the 2DS/HVPS manual for info on how to read this
    var43 = netcdf.defVar(f0,'horizontal_laser_drive','float',dim0);
    var44 = netcdf.defVar(f0,'vertical_laser_drive','float',dim0);
    var45 = netcdf.defVar(f0,'horizontal_masked_bits','double',dim0);
    var46 = netcdf.defVar(f0,'vertical_masked_bits','double',dim0);
    var47 = netcdf.defVar(f0,'number_of_stereo_particles_found','double',dim0);
    var48 = netcdf.defVar(f0,'number_of_timing_word_mismatches','double',dim0);
    var49 = netcdf.defVar(f0,'number_of_slice_count_mismatches','double',dim0);
    var50 = netcdf.defVar(f0,'number_of_horizontal_overload_periods','double',dim0);
    var51 = netcdf.defVar(f0,'number_of_vertical_overload_periods','double',dim0);
    var52 = netcdf.defVar(f0,'compression_configuration','short',dim0); % Check the 2DS/HVPS manual for info on how to read this
    var53 = netcdf.defVar(f0,'number_of_empty_FIFO_faults','double',dim0);
    var54 = netcdf.defVar(f0,'spare2','double',dim0);
    var55 = netcdf.defVar(f0,'spare3','double',dim0);
    var56 = netcdf.defVar(f0,'tas','float',dim0);
    var57 = netcdf.defVar(f0,'timing_word','double',dim0);
    netcdf.endDef(f0)
    
    
    %  Create horizontal image file
    
    f = netcdf.create(outfilename1, 'NETCDF4');
    
    dimid0 = netcdf.defDim(f,'time',netcdf.getConstant('NC_UNLIMITED'));
    dimid1 = netcdf.defDim(f,'ImgRowlen',8);
    dimid2 = netcdf.defDim(f,'ImgBlocklen',1700);
    
    varid0 = netcdf.defVar(f,'year','ushort',dimid0);
    varid1 = netcdf.defVar(f,'month','ushort',dimid0);
    varid2 = netcdf.defVar(f,'day','ushort',dimid0);
    varid3 = netcdf.defVar(f,'hour','ushort',dimid0);
    varid4 = netcdf.defVar(f,'minute','ushort',dimid0);
    varid5 = netcdf.defVar(f,'second','ushort',dimid0);
    varid6 = netcdf.defVar(f,'millisec','ushort',dimid0);
    varid7 = netcdf.defVar(f,'wkday','ushort',dimid0);
    varid8 = netcdf.defVar(f,'data','ushort',[dimid1 dimid2 dimid0]);
    varid9 = netcdf.defVar(f,'tas','float',dimid0);
    netcdf.endDef(f)
    
     
    
    %  Create the vertical image file
    
    f1 = netcdf.create(outfilename2, 'NETCDF4');
    
    dimid01 = netcdf.defDim(f1,'time',netcdf.getConstant('NC_UNLIMITED'));
    dimid11 = netcdf.defDim(f1,'ImgRowlen',8);
    dimid21 = netcdf.defDim(f1,'ImgBlocklen',1700);
    
    varid01 = netcdf.defVar(f1,'year','ushort',dimid01);
    varid11 = netcdf.defVar(f1,'month','ushort',dimid01);
    varid21 = netcdf.defVar(f1,'day','ushort',dimid01);
    varid31 = netcdf.defVar(f1,'hour','ushort',dimid01);
    varid41 = netcdf.defVar(f1,'minute','ushort',dimid01);
    varid51 = netcdf.defVar(f1,'second','ushort',dimid01);
    varid61 = netcdf.defVar(f1,'millisec','ushort',dimid01);
    varid71 = netcdf.defVar(f1,'wkday','ushort',dimid01);
    varid81 = netcdf.defVar(f1,'data','ushort',[dimid11 dimid21 dimid01]);
    varid91 = netcdf.defVar(f1,'tas','float',dimid01);
    netcdf.endDef(f1)
    
    
    kk0=1;
    kk1=1;
    kk2=1;
    endfile = 0; 
    
    disp('Processing...')
    
    % Read in the information until we are at the end of the file
    
    while feof(fid)==0 && endfile == 0 
        
        year=fread(fid,1,'uint16');
        month=fread(fid,1,'uint16');
        wkday=fread(fid,1,'uint16');
        day=fread(fid,1,'uint16');
        hour=fread(fid,1,'uint16');
        minute=fread(fid,1,'uint16');
        second=fread(fid,1,'uint16');
        millisec=fread(fid,1,'uint16');
        data = fread(fid,2048,'uint16');
        discard=fread(fid,1,'uint16');

        year1=fread(fid,1,'uint16');
        month1=fread(fid,1,'uint16');
        wkday1=fread(fid,1,'uint16');
        day1=fread(fid,1,'uint16');
        hour1=fread(fid,1,'uint16');
        minute1=fread(fid,1,'uint16');
        second1=fread(fid,1,'uint16');
        millisec1=fread(fid,1,'uint16');
        data1 = fread(fid,2048,'uint16');
        discard=fread(fid,1,'uint16');
        
        datan=[data' data1'];
        datan=datan';
        
        % Take data and send it to 'get_img' to be decompressed and read
        
        [imgH, imgV, HK, HKon]=get_img(datan, hour*10000+minute*100+second+millisec/1000,outfilename);
        sizeimg= size(imgH);
        if sizeimg(2)>1700
            imgH=imgH(:,1:1700);
            sizeimg(2)
        end
        
        sizeimg= size(imgV);
        if sizeimg(2)>1700
            imgV=imgV(:,1:1700);
            sizeimg(2)
        end
        
        % Housekeeping
        
        if HKon == 1
            
            netcdf.putVar ( f0, var0, kk0-1, 1, year );
            netcdf.putVar ( f0, var1, kk0-1, 1, month );
            netcdf.putVar ( f0, var2, kk0-1, 1, day );
            netcdf.putVar ( f0, var3, kk0-1, 1, hour );
            netcdf.putVar ( f0, var4, kk0-1, 1, minute );
            netcdf.putVar ( f0, var5, kk0-1, 1, second );
            netcdf.putVar ( f0, var6, kk0-1, 1, millisec );
            netcdf.putVar ( f0, var7, kk0-1, 1, wkday );
            
            % See the github wiki or the SPEC manual for the full names of
            % these variables.
            netcdf.putVar ( f0, var8, kk0-1, 1, HK.HE0V );
            netcdf.putVar ( f0, var9, kk0-1, 1, HK.HE64V );
            netcdf.putVar ( f0, var10, kk0-1, 1, HK.HE127V );
            netcdf.putVar ( f0, var11, kk0-1, 1, HK.VE0V );
            netcdf.putVar ( f0, var12, kk0-1, 1, HK.VE64V );
            netcdf.putVar ( f0, var13, kk0-1, 1, HK.VE127V );
            netcdf.putVar ( f0, var14, kk0-1, 1, HK.RPPS );
            netcdf.putVar ( f0, var15, kk0-1, 1, HK.RNPS );
            netcdf.putVar ( f0, var16, kk0-1, 1, HK.HarmTxTemp );
            netcdf.putVar ( f0, var17, kk0-1, 1, HK.HarmRxTemp );
            netcdf.putVar ( f0, var18, kk0-1, 1, HK.VarmTxTemp );
            netcdf.putVar ( f0, var19, kk0-1, 1, HK.VarmRxTemp );
            netcdf.putVar ( f0, var20, kk0-1, 1, HK.HtipTxTemp );
            netcdf.putVar ( f0, var21, kk0-1, 1, HK.HtipRxTemp );
            netcdf.putVar ( f0, var22, kk0-1, 1, HK.ROBTemp );
            netcdf.putVar ( f0, var23, kk0-1, 1, HK.DSPBoardTemp );
            netcdf.putVar ( f0, var24, kk0-1, 1, HK.FVesselTemp );
            netcdf.putVar ( f0, var25, kk0-1, 1, HK.HLTemp );
            netcdf.putVar ( f0, var26, kk0-1, 1, HK.VLTemp );
            netcdf.putVar ( f0, var27, kk0-1, 1, HK.FPTemp );
            netcdf.putVar ( f0, var28, kk0-1, 1, HK.PSTemp );
            netcdf.putVar ( f0, var29, kk0-1, 1, HK.n5Vsupply );
            netcdf.putVar ( f0, var30, kk0-1, 1, HK.p5Vsupply );
            netcdf.putVar ( f0, var31, kk0-1, 1, HK.CanIP );
            netcdf.putVar ( f0, var32, kk0-1, 1, HK.HE21V );
            netcdf.putVar ( f0, var33, kk0-1, 1, HK.HE42V );
            netcdf.putVar ( f0, var34, kk0-1, 1, HK.HE85V );
            netcdf.putVar ( f0, var35, kk0-1, 1, HK.HE106V );
            netcdf.putVar ( f0, var36, kk0-1, 1, HK.VE21V );
            netcdf.putVar ( f0, var37, kk0-1, 1, HK.VE42V );
            netcdf.putVar ( f0, var38, kk0-1, 1, HK.VE85V );
            netcdf.putVar ( f0, var39, kk0-1, 1, HK.VE106V );
            netcdf.putVar ( f0, var40, kk0-1, 1, HK.VPD );
            netcdf.putVar ( f0, var41, kk0-1, 1, HK.HPD );
            netcdf.putVar ( f0, var42, kk0-1, 1, HK.HOs ); % Convert to binary and consult the SPEC manual for how to read
            netcdf.putVar ( f0, var43, kk0-1, 1, HK.HLDrive );
            netcdf.putVar ( f0, var44, kk0-1, 1, HK.VLDrive );
            netcdf.putVar ( f0, var45, kk0-1, 1, HK.HMbits );
            netcdf.putVar ( f0, var46, kk0-1, 1, HK.VMbits );
            netcdf.putVar ( f0, var47, kk0-1, 1, HK.SPF );
            netcdf.putVar ( f0, var48, kk0-1, 1, HK.TWMs );
            netcdf.putVar ( f0, var49, kk0-1, 1, HK.SCMs );
            netcdf.putVar ( f0, var50, kk0-1, 1, HK.HOPs );
            netcdf.putVar ( f0, var51, kk0-1, 1, HK.VOPs );
            netcdf.putVar ( f0, var52, kk0-1, 1, HK.CC ); % Convert to binary and consult the SPEC manual for how to read
            netcdf.putVar ( f0, var53, kk0-1, 1, HK.FIFO );
            netcdf.putVar ( f0, var54, kk0-1, 1, HK.Spare2 );
            netcdf.putVar ( f0, var55, kk0-1, 1, HK.Spare3 );
            netcdf.putVar ( f0, var56, kk0-1, 1, HK.tas );
            netcdf.putVar ( f0, var57, kk0-1, 1, HK.time );
            
            kk0=kk0+1;
        end
            
        % Image Files
        
        if sum(sum(imgH))~=0
            for  mmm=1:8
                img1(mmm,1:1700)=sixteen2int(imgH((mmm-1)*16+1:mmm*16,1:1700));
            end

            netcdf.putVar ( f, varid0, kk1-1, 1, year );
            netcdf.putVar ( f, varid1, kk1-1, 1, month );
            netcdf.putVar ( f, varid2, kk1-1, 1, day );
            netcdf.putVar ( f, varid3, kk1-1, 1, hour );
            netcdf.putVar ( f, varid4, kk1-1, 1, minute );
            netcdf.putVar ( f, varid5, kk1-1, 1, second );
            netcdf.putVar ( f, varid6, kk1-1, 1, millisec );
            netcdf.putVar ( f, varid7, kk1-1, 1, wkday );
            netcdf.putVar ( f, varid8, [0, 0, kk1-1], [8,1700,1], img1 );
            netcdf.putVar ( f, varid9, kk1-1, 1, tas );
            
            kk1=kk1+1;
            if mod(kk1,1000) == 0
                 ['kk1=' num2str(kk1) ', ' datestr(now)]
            end
        end
        
        if sum(sum(imgV))~=0
            for  mmm=1:8
                img2(mmm,1:1700)=sixteen2int(imgV((mmm-1)*16+1:mmm*16,1:1700));
            end

            netcdf.putVar ( f1, varid01, kk2-1, 1, year );
            netcdf.putVar ( f1, varid11, kk2-1, 1, month );
            netcdf.putVar ( f1, varid21, kk2-1, 1, day );
            netcdf.putVar ( f1, varid31, kk2-1, 1, hour );
            netcdf.putVar ( f1, varid41, kk2-1, 1, minute );
            netcdf.putVar ( f1, varid51, kk2-1, 1, second );
            netcdf.putVar ( f1, varid61, kk2-1, 1, millisec );
            netcdf.putVar ( f1, varid71, kk2-1, 1, wkday );
            netcdf.putVar ( f1, varid81, [0, 0, kk2-1], [8,1700,1], img2 );
            netcdf.putVar ( f1, varid91, kk2-1, 1, tas );

            kk2=kk2+1;
            if mod(kk2,1000) == 0
                 ['kk2=' num2str(kk2) ', ' datestr(now)]
            end
        end
        
        % Read in the next byte and see if we are at the end of the file
        bb=fread(fid,1,'int8');
        if feof(fid) == 1
            endfile=1;
            break
        end
        fseek(fid,-4115,'cof');
    end
    
    netcdf.close(f0);
    netcdf.close(f);  
    netcdf.close(f1);      
end

fclose(fid);
end


function [imgH, imgV, HK, HKon]=get_img(buf, timehhmmss,outfilename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Decompress the data blocks
%% Follow the SPEC manual 
%% by Will Wu, 06/20/2013; edited by Kevin Shaffer 6/24/2019
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    global tas

    HKon=0;
    imgH=zeros(128,1700);
    imgV=zeros(128,1700);
    iSlice=0;
    iii=1;
    HK.x=0;
    while iii<=2048 
        if 12883==buf(iii) % '2S' in ascii (Particle Frame Format)
              nH=bitand(buf(iii+1), 4095); %bin2dec('0000111111111111'));
              bHTiming=bitand(buf(iii+1), 4096); %bin2dec('0001000000000000'))/2^13;
              nV=bitand(buf(iii+2), 4095); %bin2dec('0000111111111111'));
              bVTiming=bitand(buf(iii+2), 4096); %bin2dec('0001000000000000'))/2^13;
              PC = buf(iii+3);
              nS = buf(iii+4);
              NHWord=buf(iii+1);
              NVWord=buf(iii+2);
              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % Number of vertical words (Is this necessary?)
              myformatNV = '%f, %d\n';
              fid = fopen([outfilename, '.NV.csv'],'a');
              fprintf(fid, myformatNV, [timehhmmss buf(iii+2)]);
              fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

              if nH~=0 && nV~=0
                  system(['echo ' num2str(nH)  ' ' num2str(nV) ' >> output.txt']);
              end
              
              iii=iii+5;
              if bHTiming~=0 || bVTiming~=0     
                  iii=iii+nH+nV;
              elseif nH~=0
                  jjj=1;
                  kkk=0;
                  while jjj<=nS && kkk<nH-2 % Last two slices are time
                      aa=bitand(buf(iii+kkk),16256)/2^7;  %bin2dec('0011111110000000')
                      bb=bitand(buf(iii+kkk),127); %bin2dec('0000000001111111')
                      imgH(min(128,bb+1):min(aa+bb,128),iSlice+jjj)=1;
                      bBase=min(aa+bb,128);
                      kkk=kkk+1;
                      while( bitand(buf(iii+kkk),16384)==0  && kkk<nH-2) % bin2dec('1000000000000000')
                          aa=bitand(buf(iii+kkk),16256)/2^7;
                          bb=bitand(buf(iii+kkk),127);
                          imgH(min(128,bBase+bb+1):min(bBase+aa+bb,128),iSlice+jjj)=1;
                          bBase=min(bBase+aa+bb,128);
                          kkk=kkk+1;
                      end
                      jjj=jjj+1;
                  end
                  iSlice=iSlice+nS+2;

                  imgH(:,iSlice-1)='10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010';
                  imgH(:,iSlice-1)=imgH(:,iSlice-1)-48;
                  imgH(:,iSlice)=1;
                  tParticle=buf(iii+nH-2)*2^16+buf(iii+nH-1);
                  imgH(:,iSlice)=dec2bin(tParticle,128)-48;
                  imgH(97:128,iSlice)=dec2bin(tParticle,32)-48;
                  imgH(49:64,iSlice)=dec2bin(NHWord,16)-48;
                  imgH(65:80,iSlice)=dec2bin(PC,16)-48;
                  imgH(81:96,iSlice)=dec2bin(nS,16)-48;
                  iii=iii+nH;

              elseif nV~=0
                  jjj=1;
                  kkk=0;
                  while jjj<=nS && kkk<nV-2 % Last two slices are time
                      aa=bitand(buf(iii+kkk),16256)/2^7;  %bin2dec('0011111110000000')
                      bb=bitand(buf(iii+kkk),127); %bin2dec('0000000001111111')
                      imgV(min(128,bb+1):min(aa+bb,128),iSlice+jjj)=1;
                      bBase=min(aa+bb,128);
                      kkk=kkk+1;
                      while( bitand(buf(iii+kkk),16384)==0  && kkk<nV-2) % bin2dec('1000000000000000')
                          aa=bitand(buf(iii+kkk),16256)/2^7;
                          bb=bitand(buf(iii+kkk),127);
                          imgV(min(128,bBase+bb+1):min(bBase+aa+bb,128),iSlice+jjj)=1;
                          bBase=min(bBase+aa+bb,128);
                          kkk=kkk+1;
                      end
                      jjj=jjj+1;
                  end
                  iSlice=iSlice+nS+2;

                  imgV(:,iSlice-1)='10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010';
                  imgV(:,iSlice-1)=imgV(:,iSlice-1)-48;
                  imgV(:,iSlice)=1;
                  tParticle=buf(iii+nV-2)*2^16+buf(iii+nV-1);
                  imgV(:,iSlice)=dec2bin(tParticle,128)-48;
                  imgV(97:128,iSlice)=dec2bin(tParticle,32)-48;
                  imgV(49:64,iSlice)=dec2bin(NVWord,16)-48;
                  imgV(65:80,iSlice)=dec2bin(PC,16)-48;
                  imgV(81:96,iSlice)=dec2bin(nS,16)-48;
                  iii=iii+nV;
              end
              
        elseif 18507==buf(iii) % 'HK' in ascii (housekeeping)
            HKon=1;
            HK.HE0V = buf(iii-1+2) * 0.00244140625;
            HK.HE64V  = buf(iii-1+3) * 0.00244140625;
            HK.HE127V  = buf(iii-1+4) * 0.00244140625;
            HK.VE0V  = buf(iii-1+5) * 0.00244140625;
            HK.VE64V  = buf(iii-1+6) * 0.00244140625;
            HK.VE127V  = buf(iii-1+7) * 0.00244140625;
            HK.RPPS = buf(iii-1+8) * 0.00488400488;
            HK.RNPS = single(typecast(uint16(buf(iii-1+9)),'int16')) * 0.00488400488;
            HK.HarmTxTemp = (single(typecast(uint16(buf(iii-1+10)),'int16')) * 0.00244140625) + 1.6;
            HK.HarmRxTemp = (single(typecast(uint16(buf(iii-1+11)),'int16')) * 0.00244140625) + 1.6;
            HK.VarmTxTemp = (single(typecast(uint16(buf(iii-1+12)),'int16')) * 0.00244140625) + 1.6;
            HK.VarmRxTemp = (single(typecast(uint16(buf(iii-1+13)),'int16')) * 0.00244140625) + 1.6;
            HK.HtipTxTemp = (single(typecast(uint16(buf(iii-1+14)),'int16')) * 0.00244140625) + 1.6;
            HK.HtipRxTemp = (single(typecast(uint16(buf(iii-1+15)),'int16')) * 0.00244140625) + 1.6;
            HK.ROBTemp = (single(typecast(uint16(buf(iii-1+16)),'int16')) * 0.00244140625) + 1.6;
            HK.DSPBoardTemp = (single(typecast(uint16(buf(iii-1+17)),'int16')) * 0.00244140625) + 1.6;
            HK.FVesselTemp = (single(typecast(uint16(buf(iii-1+18)),'int16')) * 0.00244140625) + 1.6;
            HK.HLTemp = (single(typecast(uint16(buf(iii-1+19)),'int16')) * 0.00244140625) + 1.6;
            HK.VLTemp = (single(typecast(uint16(buf(iii-1+20)),'int16')) * 0.00244140625) + 1.6;
            HK.FPTemp = (single(typecast(uint16(buf(iii-1+21)),'int16')) * 0.00244140625) + 1.6;
            HK.PSTemp = (single(typecast(uint16(buf(iii-1+22)),'int16')) * 0.00244140625) + 1.6;
            HK.n5Vsupply = single(typecast(uint16(buf(iii-1+23)),'int16')) * 0.00488400488;
            HK.p5Vsupply = single(typecast(uint16(buf(iii-1+24)),'int16')) * 0.00488400488;
            HK.CanIP = (single(typecast(uint16(buf(iii-1+25)),'int16')) * 0.018356) - 3.846;
            HK.HE21V = buf(iii-1+26) * 0.00244140625;
            HK.HE42V  = buf(iii-1+27) * 0.00244140625;
            HK.HE85V  = buf(iii-1+28) * 0.00244140625;
            HK.HE106V  = buf(iii-1+29) * 0.00244140625;
            HK.VE21V = buf(iii-1+30) * 0.00244140625;
            HK.VE42V  = buf(iii-1+31) * 0.00244140625;
            HK.VE85V  = buf(iii-1+32) * 0.00244140625;
            HK.VE106V  = buf(iii-1+33) * 0.00244140625;
            HK.VPD = buf(iii-1+34);
            HK.HPD = buf(iii-1+35);
            HK.HOs = buf(iii-1+36); % Convert to binary and consult the SPEC manual for how to read
            HK.HLDrive = buf(iii-1+37) * 0.001220703;
            HK.VLDrive = buf(iii-1+38) * 0.001220703;
            HK.HMbits = buf(iii-1+39);
            HK.VMbits = buf(iii-1+40);
            HK.SPF = buf(iii-1+41);
            HK.TWMs = buf(iii-1+42);
            HK.SCMs = buf(iii-1+43);
            HK.HOPs = buf(iii-1+44);
            HK.VOPs = buf(iii-1+45);
            HK.CC = buf(iii-1+46); % Convert to binary and consult the SPEC manual for how to read
            HK.FIFO = buf(iii-1+47);
            HK.Spare2 = buf(iii-1+48);
            HK.Spare3 = buf(iii-1+49);
            HK.tas = typecast( uint32(bin2dec([dec2bin(buf(iii-1+50),16) dec2bin(buf(iii-1+51),16)])) ,'single');
            tas = HK.tas;
            HK.time = buf(iii-1+52)*2^16+buf(iii-1+53);
            
            iii = iii + 53;
        
        elseif 19787==buf(iii) % 'MK' is ascii (Mask data block)
            timeWord = buf(iii-1+2)*2^16+buf(iii-1+3);
            MaskBits = [buf(iii-1+4:iii-1+19)]';
            timeStart = buf(iii-1+20)*2^16+buf(iii-1+21);
            timeEnd = buf(iii-1+22)*2^16+buf(iii-1+23);
            
            myformat2 = '%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d \n';
            fid = fopen([outfilename, '.MK.csv'],'a');
            fprintf(fid, myformat2, [timeWord MaskBits timeStart timeEnd]);
            fclose(fid);
            
            iii = iii + 23;
            
        else
            iii=iii+1;
        end
    end
end

function intres=sixteen2int(original)

intres=zeros(1,1700);
for i=1:16
    temp=original(i,:)*2^(16-i);
    intres=intres+temp;
end
end