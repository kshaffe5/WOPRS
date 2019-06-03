function Read_Binary_New(infilename, outfilename, probetype)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Read the raw file, and then write into NETCDF file 
%% 
%% Inputs: infilename, outfilename ('1' if the desired outfilename is  the 
%%         same as the infilename), and probetype.
%%
%% Supported probetypes: '2DS', 'HVPS', 'CIPG', '2DC', or '2DP'
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(infilename)
    disp('Error: Infilename does not exist.')
    return;
end

if probetype == '2DS'
    Read_Binary_SPEC_New(infilename,outfilename);
elseif strcmpi('HVPS',probetype)
    Read_Binary_SPEC_New(infilename,outfilename);
elseif strcmpi('CIPG',probetype)
    Read_Binary_CIPG(infilename,outfilename);
elseif strcmpi('2DC',probetype)
    Read_Binary_PMS_New(infilename,outfilename,probetype);
elseif strcmpi('2DP',probetype)
    Read_Binary_PMS_New(infilename,outfilename,probetype);
else
    disp('Error: Probetype is not supported')
    return;
end
end