function Read_Binary_New(infilename, outfilename, probetype)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Read the raw file, and then write into a NETCDF file 
%% 
%% Inputs: infilename, outfilename (Use '1' if the desired outfilename is 
%%         the same as the infilename), and probetype.
%%
%% Supported probetypes: '2DS', 'HVPS', 'CIPG', '2DC', and '2DP'.
%%       Call '2D' for files that may include both '2DC' and '2DP' data.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(infilename)
    disp('Error: Infilename does not exist.')
    return;
end

if strcmpi('2DS',probetype)
    Read_Binary_SPEC_New(infilename,outfilename);
elseif strcmpi('HVPS',probetype)
    Read_Binary_SPEC_New(infilename,outfilename);
elseif strcmpi('CIPG',probetype)
    Read_Binary_CIPG(infilename,outfilename);
elseif strcmpi('2DC',probetype)
    Read_Binary_PMS_New(infilename,outfilename,probetype);
elseif strcmpi('2DP',probetype)
    Read_Binary_PMS_New(infilename,outfilename,probetype);
elseif strcmpi('2D',probetype)
    Read_Binary_PMS_New(infilename,outfilename,'2DC');
    Read_Binary_PMS_New(infilename,outfilename,'2DP');
else
    disp('Error: Probetype is not supported')
    return;
end
end