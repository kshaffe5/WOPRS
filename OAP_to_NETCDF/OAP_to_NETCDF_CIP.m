function [createdfile] = OAP_to_NETCDF_CIP(cipdatapath,outdatapath,outfilename)

% FIRST DELETE CAL AND SONIC CSV FILES FROM CIP DATETIME FOLDER

% This script extracts raw cip files from specified location and outputs
% a NETCDF-4 file.

% Example file paths: 
% cipdatapath = '/kingair_data/pacmice16/cip/20160818/20160818143905/'
% outdatapath = '/kingair_data/pacmice16/cip/20160818/cip_20160818'
% outfilename = 'DIMG.20160818.cip.cdf'

% Edited by Kevin Shaffer as of 7/12/2019 

p = path;
cdir = pwd;
obj = cip(cipdatapath,outdatapath)

unpack(obj)

cip_obj_to_netcdf(obj,[outdatapath,'/DIMG.',outfilename,'.CIP.cdf'])
path(p);

end