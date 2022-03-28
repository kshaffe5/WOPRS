function [outfilename1]=OAP_to_NETCDF_SPEC(infilename,outfilename0,outfilename1,outfilename2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Read the raw base*.2DS file, and then write into NETCDF file 
%% 
%% 2DS manual : http://www.specinc.com/sites/default/files/software_and_manuals/2D-S_Technical%20Manual_rev3.1_20110228.pdf
%%
%% HVPS manual : http://www.specinc.com/sites/default/files/software_and_manuals/HVPS_Technical%20Manual_rev1.2_20130227.pdf
%%
%% Last edited by: Kevin Shaffer 9/16/2021
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global tas
    
% Open the input file in read-only ('r') mode for reading in little-endian ('l').
fid=fopen(infilename,'r','l');
    
tas = 1; % Set tas to 1 before the first set of housekeeping data
    
    
    %%  Create the housekeeping file
    f0 = netcdf.create(outfilename0, 'CLOBBER');

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
    var42 = netcdf.defVar(f0,'heater_outputs','double',dim0); % Check the 2DS/HVPS manual for info on how to read this
    var43 = netcdf.defVar(f0,'horizontal_laser_drive','float',dim0);
    var44 = netcdf.defVar(f0,'vertical_laser_drive','float',dim0);
    var45 = netcdf.defVar(f0,'horizontal_masked_bits','double',dim0);
    var46 = netcdf.defVar(f0,'vertical_masked_bits','double',dim0);
    var47 = netcdf.defVar(f0,'number_of_stereo_particles_found','double',dim0);
    var48 = netcdf.defVar(f0,'number_of_timing_word_mismatches','double',dim0);
    var49 = netcdf.defVar(f0,'number_of_slice_count_mismatches','double',dim0);
    var50 = netcdf.defVar(f0,'number_of_horizontal_overload_periods','double',dim0);
    var51 = netcdf.defVar(f0,'number_of_vertical_overload_periods','double',dim0);
    var52 = netcdf.defVar(f0,'compression_configuration','double',dim0); % Check the 2DS/HVPS manual for info on how to read this
    var53 = netcdf.defVar(f0,'number_of_empty_FIFO_faults','double',dim0);
    var54 = netcdf.defVar(f0,'spare2','double',dim0);
    var55 = netcdf.defVar(f0,'spare3','double',dim0);
    var56 = netcdf.defVar(f0,'tas','float',dim0);
    var57 = netcdf.defVar(f0,'timing_word','double',dim0);
    netcdf.endDef(f0)
    

    
    %%  Create the image file
    f = netcdf.create(outfilename1,'CLOBBER');
    
    % Set the time dimension to a limited size if we found the record count
    dimid0 = netcdf.defDim(f,'time',netcdf.getConstant('NC_UNLIMITED'));
    dimid1 = netcdf.defDim(f,'ImgRowlen',8);
    dimid2 = netcdf.defDim(f,'ImgBlocklen',1700);
    
    varid0 = netcdf.defVar(f,'year','short',dimid0);
    varid1 = netcdf.defVar(f,'month','short',dimid0);
    varid2 = netcdf.defVar(f,'day','short',dimid0);
    varid3 = netcdf.defVar(f,'hour','short',dimid0);
    varid4 = netcdf.defVar(f,'minute','short',dimid0);
    varid5 = netcdf.defVar(f,'second','short',dimid0);
    varid6 = netcdf.defVar(f,'millisec','short',dimid0);
    varid7 = netcdf.defVar(f,'wkday','short',dimid0);
    varid8 = netcdf.defVar(f,'data','double',[dimid1 dimid2 dimid0]);
    varid9 = netcdf.defVar(f,'tas','float',dimid0);
    netcdf.endDef(f)
    

    kk0=1;
    kk1=1;
    endfile = 0; 
    
    disp('Processing...')
    
    %% Read in the information until we are at the end of the file
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
        
        %[img, HK, HKon]=get_img(datan, hour*10000+minute*100+second+millisec/1000,outfilename);
        [img, HK, HKon]=get_img(datan,outfilename2);
        sizeimg= size(img);
        if sizeimg(2)>1700
            img=img(:,1:1700);
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
            
        % Image File
        if sum(sum(img))~=0
            for  mmm=1:8
                img1(mmm,1:1700)=sixteen2int(img((mmm-1)*16+1:mmm*16,1:1700));
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


fclose(fid);
end


function [img, HK, HKon]=get_img(buf,outfilename2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Decompress the data blocks
%% Follow the SPEC manual 
%% by Will Wu, 06/20/2013; edited by Kevin Shaffer 6/24/2019
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    global tas

    HKon=0;
    img=zeros(128,1700);

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
              
              if nH~=0
                  n = nH;
                  bTiming = bHTiming;
                  NWord = NHWord;
                  channel = 1;
              elseif nV~=0
                  n = nV;
                  bTiming = bVTiming;
                  NWord = NVWord;
                  channel = 0;
              else
                  disp('NH and NV ~= 0. This should not have happened')
              end
              
              if nH~=0 && nV~=0
                  system(['echo ' num2str(nH)  ' ' num2str(nV) ' >> output.txt']);
              end
              
              iii=iii+5;
              
              if bHTiming~=0 || bVTiming~=0     
                  iii=iii+nH+nV;
              else
              jjj=1;
              kkk=0;
              while jjj<=nS && kkk<n-2 % Last two slices are time
                  aa=bitand(buf(iii+kkk),16256)/2^7;  %bin2dec('0011111110000000'   
                  bb=bitand(buf(iii+kkk),127); %bin2dec('0000000001111111')
                  img(min(128,bb+1):min(aa+bb,128),iSlice+jjj)=1;
                  bBase=min(aa+bb,128);
                  kkk=kkk+1;
                  while( bitand(buf(iii+kkk),16384)==0  && kkk<n-2) % bin2dec('1000000000000000')
                      aa=bitand(buf(iii+kkk),16256)/2^7;
                      bb=bitand(buf(iii+kkk),127);
                      img(min(128,bBase+bb+1):min(bBase+aa+bb,128),iSlice+jjj)=1;
                      bBase=min(bBase+aa+bb,128);
                      kkk=kkk+1;
                  end
                  jjj=jjj+1;
              end
              iSlice=iSlice+nS+2;
              img(:,iSlice-1)='10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010';
              img(:,iSlice-1)=img(:,iSlice-1)-48;
              img(:,iSlice)=1;
              tParticle=buf(iii+n-2)*2^16+buf(iii+n-1);
              img(:,iSlice)=dec2bin(tParticle,128)-48;
              img(97:128,iSlice)=dec2bin(tParticle,32)-48;
              img(49:64,iSlice)=dec2bin(NWord,16)-48;
              img(65:80,iSlice)=dec2bin(PC,16)-48;
              img(81:96,iSlice)=dec2bin(nS,16)-48;
              img(1,iSlice)=dec2bin(channel)-48; % Set the first bit of iSlice to 1 for H particles. When 1's and 0's are reversed, this becomes a 0.
              iii=iii+n;
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
            fid = fopen(outfilename2,'a');
            fprintf(fid, myformat2, [timeWord MaskBits timeStart timeEnd]);
            fclose(fid);
            
            iii = iii + 23;
            
        else
            iii=iii+1; % If the heading isn't any known options, skip to the next line
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
