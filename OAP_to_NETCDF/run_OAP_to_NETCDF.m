function run_OAP_to_NETCDF(infilename, probetype, outfilename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Read the raw file, and then write into a NETCDF file 
%% 
%% Inputs: infilename,probetype, and outfilename
%%
%% *For all probetypes except the CIP, you can leave outfilename blank*
%%
%% Example inputs: 
%% Infilename: '/home/username/base170103205633.2DS'
%% Probetype: '2DS'
%% Outfilename: *leave blank*
%%
%% Example outputs:
%% '/home/username/DIMG.170103205633.2DS.cdf'
%% '/home/username/DIMG.170103205633.2DS.HK.cdf'
%% '/home/username/170103205633.MK.2DS.csv'
%%
%%
%% IMPORTANT INFO ABOUT THE CIP: The inputs necessary for the CIP are 
%%      different than for the other probetypes. Infilename should instead
%%      be just the path of the input file with a slash at the end. 
%%      Outfilename should just be the name of the file without the path.
%%      Probetype should be treated as normal. The CIP also requires a 
%%      separate input called outfilepath which is just the path of the 
%%      output file without the actual filename. Make sure to move/delete
%%      cal and sonic csv files from the datetime folder, otherwise you
%%      will encounter an error. 
%%
%%      Examples of inputs (applicable to CIP only!):
%%      infilename = '/kingair_data/pacmice16/cip/20160818/20160818143905/'
%%      probetype = 'CIP'
%%      outfilename = '/kingair_data/pacmice16/cip/20160818/cip_20160818/20160818'
%%
%%
%% Supported probetypes: '2DS', 'HVPS', 'CIP', '2DC', and '2DP'.
%%       Call '2D' for files that may include both '2DC' and '2DP' data.
%%
%% Last updated by: Kevin Shaffer 3/1/2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(infilename)
    disp('Error: Infilename does not exist.')
    return;
end

    
if strcmpi('2DS',probetype)
    periodpos = find(infilename == '.',1,'last')
    basepos = find(infilename == 'e',1,'last')
    slashpos = find(infilename == '/',1,'last')
    filedir = infilename(1:slashpos)
    filename = infilename(basepos+1:periodpos-1)
    outfilename0=[filedir,'DIMG.',filename,'.2DS.HK.cdf'] % Housekeeping data
    outfilename1=[filedir,'DIMG.',filename,'.2DS.cdf'] % Image data   
    outfilename2=[filedir,filename,'.MK.2DS.csv'] % Automask data
    createdfile = OAP_to_NETCDF_SPEC(infilename,outfilename0,outfilename1,outfilename2)
elseif strcmpi('HVPS',probetype)
    periodpos = find(infilename == '.',1,'last');
    basepos = find(infilename == 'e',1,'last');
    slashpos = find(infilename == '/',1,'last');
    filedir = infilename(1:slashpos);
    filename = infilename(basepos+1:periodpos-1);
    outfilename0=[filedir,'DIMG.',filename,'.HVPS.HK.cdf'] % Housekeeping data
    outfilename1=[filedir,'DIMG.',filename,'.HVPS.cdf'] % Image data   
    outfilename2=[filedir,filename,'.MK.HVPS.csv'] % Automask data
    created_file = OAP_to_NETCDF_SPEC(infilename,outfilename0,outfilename1,outfilename2)  
elseif strcmpi('CIP',probetype)
    DIMGname = infilename(end-14:end-1)
    OAP_to_NETCDF_CIP(infilename,outfilename,DIMGname)
elseif strcmpi('2DC',probetype)
    periodpos = find(infilename == '.',1,'last');
    filedir = infilename(1:slashpos)
    filename = infilename(slashpos+1:periodpos-1)
    createdfile = OAP_to_NETCDF_PMS(infilename,outfilename,'2DC')
elseif strcmpi('2DP',probetype)
    periodpos = find(infilename == '.',1,'last');
    filedir = infilename(1:slashpos)
    filename = infilename(slashpos+1:periodpos-1)
    createdfile = OAP_to_NETCDF_PMS(infilename,outfilename,'2DP')
elseif strcmpi('2D',probetype)
    periodpos = find(infilename == '.',1,'last');
    filedir = outfilename(1:slashpos)
    filename = outfilename(slashpos+1:periodpos-1)
    createdfile = OAP_to_NETCDF_PMS(infilename,filedir,filename,'2DC')
    createdfile = OAP_to_NETCDF_PMS(infilename,filedir,filename,'2DP')
else
    disp('Error: Probetype is not supported')
    return;
end

end
