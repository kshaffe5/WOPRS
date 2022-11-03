function [f,varid]=define_outfile_SizeDist(probename,num_rejects,timehhmmss,outfile,num_round_bins,num_diam_bins,In_status,num_aspect_ratio_bins)

%% Create outfile and define variables
f = netcdf.create(outfile, 'clobber');
dimid0 = netcdf.defDim(f,'time',length(timehhmmss));
dimid1 = netcdf.defDim(f,'bin_count',num_diam_bins);
dimid2 = netcdf.defDim(f,'reject_status',num_rejects);
dimid3 = netcdf.defDim(f,'roundness_bin_count',num_round_bins);
dimid4 = netcdf.defDim(f,'aspect_ratio_bin_count',num_aspect_ratio_bins);

netcdf.putAtt(f, netcdf.getConstant('NC_GLOBAL'),'In_status',In_status);

varid.time = netcdf.defVar(f,'time','double',dimid0);
netcdf.putAtt(f, varid.time,'long_name','Time in format HHMMSS');
netcdf.putAtt(f, varid.time,'units','unitless');
varid.Accepted_counts= netcdf.defVar(f,'Accepted_counts','double',[dimid0 dimid1]);
netcdf.putAtt(f, varid.Accepted_counts,'long_name','Number of images with an artifact status of 1, sorted into bins based on diameter');
netcdf.putAtt(f, varid.Accepted_counts,'units','unitless');
varid.total_accepted_counts = netcdf.defVar(f,'total_accepted_counts','double',dimid0);
netcdf.putAtt(f, varid.total_accepted_counts,'long_name','Total number of images with an artifact status of 1, not sorted into bins');
netcdf.putAtt(f, varid.total_accepted_counts,'units','unitless');
varid.bin_min = netcdf.defVar(f,'bin_min','double',dimid1);
netcdf.putAtt(f, varid.bin_min,'long_name','Lower edge of each bin');
netcdf.putAtt(f, varid.bin_min,'units','micrometers');
varid.bin_max = netcdf.defVar(f,'bin_max','double',dimid1);
netcdf.putAtt(f, varid.bin_max,'long_name','Upper edge of each bin');
netcdf.putAtt(f, varid.bin_max,'units','micrometers');
varid.bin_mid = netcdf.defVar(f,'bin_mid','double',dimid1);
netcdf.putAtt(f, varid.bin_mid,'long_name','Midpoint of each bin');
netcdf.putAtt(f, varid.bin_mid,'units','micrometers');
varid.roundness_counts = netcdf.defVar(f,'roundness_counts','double',[dimid0 dimid3]);
netcdf.putAtt(f, varid.roundness_counts,'long_name','Binwise counts of roundness. Only all-in images have roundness values');
netcdf.putAtt(f, varid.roundness_counts,'units','unitless');
varid.aspect_ratio_counts = netcdf.defVar(f,'aspect_ratio_counts','double',[dimid0 dimid4]);
netcdf.putAtt(f, varid.aspect_ratio_counts,'long_name','Binwise counts of aspect ratio. Only all-in images have aspect ratio values');
netcdf.putAtt(f, varid.aspect_ratio_counts,'units','unitless');
varid.total_reject_counts = netcdf.defVar(f,'total_reject_counts','double',[dimid0 dimid2]);
netcdf.putAtt(f, varid.total_reject_counts,'long_name','Number of rejected images, sorted by artifact status');
netcdf.putAtt(f, varid.total_reject_counts,'units','unitless');
switch probename
    case '2DS'
        varid.Accepted_counts_H = netcdf.defVar(f,'Accepted_counts_H','double',[dimid0 dimid1]);
        netcdf.putAtt(f, varid.Accepted_counts_H,'long_name',['Number of accepted images calculated using ',In_status,' images from only the horizontal channel of the 2DS']);
        netcdf.putAtt(f, varid.Accepted_counts_H,'units','unitless');
        varid.Accepted_counts_V = netcdf.defVar(f,'Accepted_counts_V','double',[dimid0 dimid1]);
        netcdf.putAtt(f, varid.Accepted_counts_V,'long_name',['Number of accepted images calculated using ',In_status,' images from only the vertical channel of the 2DS']);
        netcdf.putAtt(f, varid.Accepted_counts_V,'units','unitless');
        varid.size_dist_2DS_H = netcdf.defVar(f,'size_dist_2DS_H','double',[dimid0 dimid1]);
        netcdf.putAtt(f, varid.size_dist_2DS_H,'long_name',['Size distribution for horizontal channel only calculated using ',In_status,' images']);
        netcdf.putAtt(f, varid.size_dist_2DS_H,'units','# cm-3 um-1');
        varid.size_dist_2DS_V = netcdf.defVar(f,'size_dist_2DS_V','double',[dimid0 dimid1]);
        netcdf.putAtt(f, varid.size_dist_2DS_V,'long_name',['Size distribution for vertical channel only calculated using ',In_status,' images']);
        netcdf.putAtt(f, varid.size_dist_2DS_V,'units','# cm-3 um-1');
end
varid.size_dist = netcdf.defVar(f,['size_dist_',probename],'double',[dimid0 dimid1]);
netcdf.putAtt(f, varid.size_dist,'long_name',['Size distribution calculated using ',In_status,' images']);
netcdf.putAtt(f, varid.size_dist,'units','# cm-3 um-1');
netcdf.endDef(f)

end