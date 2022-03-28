function [outfilename1]=OAP_to_NETCDF_PMS(infilename,filedir,filename,probetype)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Read the raw .2d file, and then write into a NETCDF-4 file 
%%
%% 'assigned_data' is a count of the data that being assigned to the output
%% file. 'skipped_data' is data that is from a different probetype, and 
%% thus it gets skipped over and not assigned to the output file.
%%
%% PMS Manual: https://www.eol.ucar.edu/content/pms-2d-raw-data-format
%%
%% Edited by Kevin Shaffer 8/1/2019
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We first need to see how many records there are so that the time
% dimension in the output file can be appropriately sized.

record_counter = 0;
endfile = 0;
fid=fopen(infilename,'r','b');

% Skips XML data that is found at the beginning of .2D files (it will be
% displayed later).
    
    xmldoc = '<>';
    while ~isequal('</OAP>',strtrim(xmldoc))
       xmldoc=fgetl(fid);
    end
    
    
% Sets 'ID' to the probetype keyword appropriate for that probetype.
    % The probetype keyword should be 'C1' or 'C2' for the 2DC
    % and 'P1' or 'P2' for the 2DP. Consult the manual or the wiki.
    switch probetype
        case '2DC'
            ID(1) = 'C';
            ID(2) = '1';
            ID(3) = '2';
            outfilename1=[filedir,'DIMG.',filename,'.2DC.cdf']; % 2DC output file
        case '2DP'
            ID(1) = 'P';
            ID(2) = '1';
            ID(3) = '2';
            outfilename1=[filedir,'DIMG.',filename,'.2DP.cdf']; % 2DP output file
    end

while feof(fid)==0 && endfile == 0
        
        probe=fread(fid,2,'uchar'); % Retrieves the 2 character probe ID of the data block
        
        probechar = char(probe'); % This just makes it easier to read the probetype keyword by turning into a character
        
        % If the probe ID is of the correct probetype, then we add 1 to the
        % record count, otherwise we just skip over it
        if (probe(1) == ID(1)) && ((probe(2) == ID(2)) || (probe(2) == ID(3)))
        
            record_counter =record_counter + 1;
            skip  = fread(fid,4114,'int8');
            
        else 
            
            skip  = fread(fid,4114,'int8');
                     
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


    % Variables that will change if certain actions occur later on
    assigned_data=1;
    skipped_data=1;
    endfile = 0;
    outfile_created=1;
    
    
    while feof(fid)==0 && endfile == 0
        
        probe=fread(fid,2,'uchar'); % Retrieves the probe ID of the data block
        
        probechar = char(probe'); % This just makes it easier to read the probetype keyword
        
        % Make sure that the probetype keyword corresponding to the data block is
        % the same as the probetype that was used to call this function run.
        % If it is then we enter the following loop.
        if (probe(1) == ID(1)) && ((probe(2) == ID(2)) || (probe(2) == ID(3)))
            
            
          if outfile_created == 1
             % Create the output file as a Netcdf-4 file type and overwrite any
             % existing file with the same name
             if exist(outfilename1)
                 delete(outfilename1)
             end
             f = netcdf.create(outfilename1, 'netcdf4');

    
             dimid0 = netcdf.defDim(f,'time',record_counter);
             dimid1 = netcdf.defDim(f,'ImgRowlen',4);
             dimid2 = netcdf.defDim(f,'ImgBlocklen',1024);
     
             varid0 = netcdf.defVar(f,'year','ushort',dimid0);
             varid1 = netcdf.defVar(f,'month','ushort',dimid0);
             varid2 = netcdf.defVar(f,'day','ushort',dimid0);
             varid3 = netcdf.defVar(f,'hour','ushort',dimid0);
             varid4 = netcdf.defVar(f,'minute','ushort',dimid0);
             varid5 = netcdf.defVar(f,'second','ushort',dimid0);
             varid6 = netcdf.defVar(f,'millisec','ushort',dimid0);
             varid7 = netcdf.defVar(f,'overload','ushort',dimid0);
             varid8 = netcdf.defVar(f,'data','ubyte',[dimid1 dimid2 dimid0]);
             varid9 = netcdf.defVar(f,'tas','float',dimid0); % True air speed
             netcdf.endDef(f)
        
             % Now that a file has been created, we set this to 2 so that
             % we dont create another file.
             outfile_created=2;
            
          end
        
            %Read in data from the OAP file. 'Data' is where the image data
            %is stored.
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
            
            % Image data has to be reshaped to fit the buffers
            netcdf.putVar ( f, varid8, [0, 0, assigned_data-1], [4,1024,1], reshape(data,4,1024) );
            
            % Prints out whenever 10,000 useable data sets have been
            % assigned to the NETCDF-4 file.
            assigned_data=assigned_data+1;
            if mod(assigned_data,10000) == 0
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
            
            % Prints out when 10,000 data blocks were skipped over because
            % they had the wrong probetype
            skipped_data=skipped_data+1;
            if mod(skipped_data,10000) == 0
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
    
    % Here I check to make sure that an output file was created. If it was,
    % we can now close it. If not, we give the user an error message
    % letting them know that none of the data fit the called probetype.
    if outfile_created == 2
          netcdf.close(f); 
    else 
        disp('******************************************************************************')
        disp('No file has been created because none of the input data matched the probetype.')
        disp('******************************************************************************')
    end
end

