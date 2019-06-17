function Read_Binary_PMS_New(infilename,outfilename,probetype)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Read the raw .2d file, and then write into NETCDF file 
%%
%% 'assigned_data' is a count of the data that being assigned to the output
%% file. 'skipped_data' is data that is from a different probetype, and 
%% thus it gets skipped over and not assigned to the output file.
%%
%% Manual: https://www.eol.ucar.edu/content/pms-2d-raw-data-format
%%
%% Edited by Kevin Shaffer 6/17/2019
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The next 20 lines are just for naming the output file:

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
    
    
    % Sets 'ID' to the probetype keyword appropriate for that probetype.
    % The probetype keyword should be 'C1' or 'C2' for the 2DC
    % and 'P1' or 'P2' for the 2DP. Consult the manual or the wiki.
    switch probetype
        case '2DC'
            ID(1) = 'C';
            ID(2) = '1';
            ID(3) = '2';
            outfilename1=[outfilename, '.2dc.cdf']; % 2DC output file
        case '2DP'
            ID(1) = 'P';
            ID(2) = '1';
            ID(3) = '2';
            outfilename1=[outfilename, '.2dp.cdf']; % 2DP output file
    end
    
    
    fid=fopen(infilename,'r','b');

end 

    assigned_data=1;
    skipped_data=1;
    
    endfile = 0;
    
    xmldoc = '<>';
    while ~isequal('</OAP>',strtrim(xmldoc))
       xmldoc=fgetl(fid);
       disp(xmldoc)
    end
    
    outfile_created=1;
    
    
    while feof(fid)==0 && endfile == 0
        
        probe=fread(fid,2,'uchar'); % Retrieves the probe ID of the data block
        
        probechar = char(probe'); % This just makes it easier to read the probetype keyword
        
        % Make sure that the probetype keyword corresponding to the data block is
        % the same as the probetype the was used to call this function run.
        % If it is then we can read in the rest of the data block and
        % assign it to the outfile.
        if (probe(1) == ID(1)) && ((probe(2) == ID(2)) || (probe(2) == ID(3)))
            
            
          if outfile_created == 1
             % Create the output file as a Netcdf-4 file type and overwrite any
             % existing file with the same name
             if exist(outfilename1)
                 delete(outfilename1)
             end
             f = netcdf.create(outfilename1, 'netcdf4');

    
             dimid0 = netcdf.defDim(f,'time',netcdf.getConstant('NC_UNLIMITED'));
             dimid1 = netcdf.defDim(f,'ImgRowlen',2);
             dimid2 = netcdf.defDim(f,'ImgBlocklen',2048);
     
             varid0 = netcdf.defVar(f,'year','ushort',dimid0);
             varid1 = netcdf.defVar(f,'month','ushort',dimid0);
             varid2 = netcdf.defVar(f,'day','ushort',dimid0);
             varid3 = netcdf.defVar(f,'hour','ushort',dimid0);
             varid4 = netcdf.defVar(f,'minute','ushort',dimid0);
             varid5 = netcdf.defVar(f,'second','ushort',dimid0);
             varid6 = netcdf.defVar(f,'millisec','ushort',dimid0);
             varid7 = netcdf.defVar(f,'wkday','ushort',dimid0);
             varid8 = netcdf.defVar(f,'data','ubyte',[dimid1 dimid2 dimid0]);
             varid9 = netcdf.defVar(f,'tas','float',dimid0);
             netcdf.endDef(f)
        
             outfile_created=2;
            
          end
        
            
            hour=fread(fid,1,'uint16');
            minute=fread(fid,1,'uint16');
            second=fread(fid,1,'uint16');
            year=fread(fid,1,'uint16');
            month=fread(fid,1,'uint16');
            day=fread(fid,1,'uint16');
            tas=fread(fid,1,'uint16');
            millisec=fread(fid,1,'uint16');
            overload=fread(fid,1,'uint16');
            data = fread(fid,4096,'uchar');
            
            netcdf.putVar ( f, varid0, assigned_data-1, 1, year );
            netcdf.putVar ( f, varid1, assigned_data-1, 1, month );
            netcdf.putVar ( f, varid2, assigned_data-1, 1, day );
            netcdf.putVar ( f, varid3, assigned_data-1, 1, hour );
            netcdf.putVar ( f, varid4, assigned_data-1, 1, minute );
            netcdf.putVar ( f, varid5, assigned_data-1, 1, second );
            netcdf.putVar ( f, varid6, assigned_data-1, 1, millisec );
            netcdf.putVar ( f, varid7, assigned_data-1, 1, overload );
            netcdf.putVar ( f, varid9, assigned_data-1, 1, tas );

            netcdf.putVar ( f, varid8, [0, 0, assigned_data-1], [2,2048,1], reshape(data,2,2048) );
            
            assigned_data=assigned_data+1;
            if mod(assigned_data,1000) == 0
                assigned_data
                datestr(now)
            end
            
        else 
            % If the probetype keyword and the 'probetype' assigned at the function call
            % are not the same then it comes here. We then check to see if
            % the probetype keyword makes sense given how the files are
            % supposed to be written. If the keyword is P1, P2, C1, C2, C4,
            % C5, or C6 then the keyword makes sense and we just skip over
            % the data and move to the next data block. Otherwise we assume
            % that there is an error in the data and we end the function.
            
            skipped_data=skipped_data+1;
            if mod(skipped_data,1000) == 0
                skipped_data
                datestr(now)
            end
            
            switch probechar
                case { 'P1', 'P2', 'C1', 'C2', 'C4', 'C5', 'C6' }
                    skip  = fread(fid,4114,'int8');
                otherwise
                    disp('ERROR: Probetype keyword associated with the data is unexpected. The input file may be contain errors.')
                    return;
            end
                     
        end
        

            % Read in the next byte to see if we are at the end of the file
            bb=fread(fid,1,'int8');
            if feof(fid) == 1
                endfile=1;
                break
            end
            fseek(fid,-1,'cof');
        
    end
    
    fclose(fid);
    if outfile_created == 2
          netcdf.close(f); 
    end
end

