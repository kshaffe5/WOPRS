function Read_Binary_PMS_New(infilename,outfilename,probetype)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Read the raw .2d file, and then write into NETCDF file 
%%
%% Manual: https://www.eol.ucar.edu/content/pms-2d-raw-data-format
%%
%% Edited by Kevin Shaffer 5/30/2019
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    
    if probetype == '2DC' 
        PT= 67; % P in ascii
        outfilename1=[outfilename, '.2dc.cdf']; % 2DC output file
    elseif probetype == '2DP' 
        PT= 80; % C in ascii
        outfilename1=[outfilename, '.2dp.cdf']; % 2DP output file
    end
    
    fid=fopen(infilename,'r','b');
    
    
    % Create the output file
    f = netcdf.create(outfilename1, 'clobber');
    
    dimid0 = netcdf.defDim(f,'time',netcdf.getConstant('NC_UNLIMITED'));
    dimid1 = netcdf.defDim(f,'ImgRowlen',4);
    dimid2 = netcdf.defDim(f,'ImgBlocklen',1024);
    
    varid0 = netcdf.defVar(f,'year','short',dimid0);
    varid1 = netcdf.defVar(f,'month','short',dimid0);
    varid2 = netcdf.defVar(f,'day','short',dimid0);
    varid3 = netcdf.defVar(f,'hour','short',dimid0);
    varid4 = netcdf.defVar(f,'minute','short',dimid0);
    varid5 = netcdf.defVar(f,'second','short',dimid0);
    varid6 = netcdf.defVar(f,'millisec','short',dimid0);
    varid7 = netcdf.defVar(f,'wkday','short',dimid0);
    varid8 = netcdf.defVar(f,'data','int',[dimid1 dimid2 dimid0]);
    varid9 = netcdf.defVar(f,'tas','float',dimid0);
    netcdf.endDef(f)
    end

    kk=1;
    
    endfile = 0;
    
    xmldoc = '<>';
    while ~isequal('</OAP>',strtrim(xmldoc))
       xmldoc=fgetl(fid);
       disp(xmldoc)
    end
    
    
    while feof(fid)==0 && endfile == 0

        % Read in the data from the input file
        
        probe=fread(fid,2,'uchar'); 
        hour=fread(fid,1,'uint16');
        minute=fread(fid,1,'uint16');
        second=fread(fid,1,'uint16');
        year=fread(fid,1,'uint16');
        month=fread(fid,1,'uint16');
        day=fread(fid,1,'uint16');
        tas=fread(fid,1,'uint16');
        millisec=fread(fid,1,'uint16');
        wkday=fread(fid,1,'uint16');
        data = fread(fid,4096,'uchar');

            % Assign data to the appropriate variables in the output file
            
            if probe(1) == PT && ((probe(2) == 49) || (probe(2) == 50)) % Check that the probetype is correct first
                % The probetype keyword should be 'C1' or 'C2' for the 2DC
                % and 'P1' or 'P2' for the 2DP. Consult the manual.
            
            netcdf.putVar ( f, varid0, kk-1, 1, year );
            netcdf.putVar ( f, varid1, kk-1, 1, month );
            netcdf.putVar ( f, varid2, kk-1, 1, day );
            netcdf.putVar ( f, varid3, kk-1, 1, hour );
            netcdf.putVar ( f, varid4, kk-1, 1, minute );
            netcdf.putVar ( f, varid5, kk-1, 1, second );
            netcdf.putVar ( f, varid6, kk-1, 1, millisec );
            netcdf.putVar ( f, varid7, kk-1, 1, wkday );
            netcdf.putVar ( f, varid9, kk-1, 1, tas );

            netcdf.putVar ( f, varid8, [0, 0, kk-1], [4,1024,1], reshape(data,4,1024) );

            kk=kk+1;
            if mod(kk,1000) == 0
                kk
                datestr(now)
            end
            clear decomp dd k2 b1 b2
            
            end
        
        
        for j=1:4116
            bb=fread(fid,1,'int8');
            if feof(fid) == 1
                endfile=1;
                break
            end
        end
        fseek(fid,-4116,'cof');
        
    end
    
    fclose(fid);
    netcdf.close(f);   
end

