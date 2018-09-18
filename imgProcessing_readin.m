function imgProcessing_readin(infile,projectname)
%% Read the particle image files
handles.f = netcdf.open(infile,'nowrite');
[~, dimlen] = netcdf.inqDim(handles.f,2);
[~, handles.img_count] = netcdf.inqDim(handles.f,0);
size_mat = dimlen; 
warning off all
diode_stats = zeros(1,diodenum);

if strcmp(projectname, 'PECAN')  % For example for PECAN dataset 
    disp('Testing...')  %% Add project specific code if you like
end
end