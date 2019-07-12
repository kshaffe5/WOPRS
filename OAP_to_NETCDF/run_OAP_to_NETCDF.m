function run_OAP_to_NETCDF(infilename, outfilename, probetype, outfilepath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Read the raw file, and then write into a NETCDF file 
%% 
%% Inputs: infilename, outfilename (Use '1' if the desired outfilename is 
%%         the same as the infilename), and probetype. Outfilepath is only
%%         used for the CIPG (see details below).
%%
%% IMPORTANT INFO ABOUT THE CIPG: The inputs necessary for the CIPG are 
%%      different than for the other probetypes. Infilename should instead
%%      be just the path of the input file with a slash at the end. 
%%      Outfilename should just be the name of the file without the path.
%%      Probetype should be treated as normal. The CIPG also requires a 
%%      separate input called outfilepath which is just the path of the 
%%      output file without the actual filename.
%%
%%      Examples of inputs (applicable to the CIPG only!):
%%      infilename = '/kingair_data/pacmice16/cip/20160818/20160818143905/'
%%      outfilename = 'DIMG.20160818.cip.cdf'
%%      probetype = 'CIPG'
%%      outfilepath = '/kingair_data/pacmice16/cip/20160818/cip_20160818'
%%
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
    OAP_to_NETCDF_SPEC(infilename,outfilename);
elseif strcmpi('HVPS',probetype)
    OAP_to_NETCDF_SPEC(infilename,outfilename);
elseif strcmpi('CIPG',probetype)
    OAP_to_NETCDF_CIPG(infilename,outfilepath,outfilename);
elseif strcmpi('2DC',probetype)
    OAP_to_NETCDF_PMS(infilename,outfilename,probetype);
elseif strcmpi('2DP',probetype)
    OAP_to_NETCDF_PMS(infilename,outfilename,probetype);
elseif strcmpi('2D',probetype)
    OAP_to_NETCDF_PMS(infilename,outfilename,'2DC');
    OAP_to_NETCDF_PMS(infilename,outfilename,'2DP');
else
    disp('Error: Probetype is not supported')
    return;
end
end