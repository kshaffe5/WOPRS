function imgProcessing_outfile(outfile)
%% Create output NETCDF file and variables
f = netcdf.create(outfile, 'clobber');
dimid0 = netcdf.defDim(f,'time',netcdf.getConstant('NC_UNLIMITED'));
dimid1 = netcdf.defDim(f,'pos_count',2);
dimid2 = netcdf.defDim(f,'bin_count',diodenum);

varid1 = netcdf.defVar(f,'Date','double',dimid0);
varid0  = netcdf.defVar(f,'Time','double',dimid0);
varid2  = netcdf.defVar(f,'msec','double',dimid0);
varid101  = netcdf.defVar(f,'Time_in_seconds','double',dimid0);

varid102  = netcdf.defVar(f,'SliceCount','double',dimid0);
varid103  = netcdf.defVar(f,'DMT_DOF_SPEC_OVERLOAD','double',dimid0);
varid104  = netcdf.defVar(f,'Particle_number_all','double',dimid0);

varid3 = netcdf.defVar(f,'wkday','double',dimid0);
varid4  = netcdf.defVar(f,'position','double',[dimid1 dimid0]);
varid5  = netcdf.defVar(f,'particle_time','double',dimid0);
varid6  = netcdf.defVar(f,'particle_millisec','double',dimid0);
varid7  = netcdf.defVar(f,'particle_microsec','double',dimid0);
varid8  = netcdf.defVar(f,'parent_rec_num','double',dimid0);
varid9  = netcdf.defVar(f,'particle_num','double',dimid0);
varid10 = netcdf.defVar(f,'image_length','double',dimid0);                                
varid11 = netcdf.defVar(f,'image_width','double',dimid0);                                 
varid12 = netcdf.defVar(f,'image_area','double',dimid0);                                  
varid13 = netcdf.defVar(f,'image_longest_y','double',dimid0);                             
varid14 = netcdf.defVar(f,'image_max_top_edge_touching','double',dimid0);                 
varid15 = netcdf.defVar(f,'image_max_bottom_edge_touching','double',dimid0);              
varid16 = netcdf.defVar(f,'image_touching_edge','double',dimid0);                         
varid17 = netcdf.defVar(f,'image_auto_reject','double',dimid0);                           
varid18 = netcdf.defVar(f,'image_hollow','double',dimid0);                                
varid19 = netcdf.defVar(f,'image_center_in','double',dimid0);                             
varid20 = netcdf.defVar(f,'image_axis_ratio','double',dimid0);                            
varid21 = netcdf.defVar(f,'image_diam_circle_fit','double',dimid0);                       
varid22 = netcdf.defVar(f,'image_diam_horiz_chord','double',dimid0);                      
varid23 = netcdf.defVar(f,'image_diam_horiz_chord_corr','double',dimid0);                 
varid24 = netcdf.defVar(f,'image_diam_following_bamex_code','double',dimid0);             
varid25 = netcdf.defVar(f,'image_diam_vert_chord','double',dimid0);                       
varid26 = netcdf.defVar(f,'image_diam_minR','double',dimid0);                       
varid27 = netcdf.defVar(f,'image_diam_AreaR','double',dimid0);     
varid45 = netcdf.defVar(f,'image_perimeter','double',dimid0);
if 1==iRectEllipse 
    varid46 = netcdf.defVar(f,'image_RectangleL','double',dimid0);                       
    varid47 = netcdf.defVar(f,'image_RectangleW','double',dimid0);                         
    varid67 = netcdf.defVar(f,'image_RectangleAngle','double',dimid0);                         
    varid48 = netcdf.defVar(f,'image_EllipseL','double',dimid0);                         
    varid49 = netcdf.defVar(f,'image_EllipseW','double',dimid0);                            
    varid69 = netcdf.defVar(f,'image_EllipseAngle','double',dimid0);   
end
varid28 = netcdf.defVar(f,'percent_shadow_area','double',dimid0);                         
varid29 = netcdf.defVar(f,'edge_at_max_hole','double',dimid0);                            
varid30 = netcdf.defVar(f,'max_hole_diameter','double',dimid0);                           
varid31 = netcdf.defVar(f,'part_z','double',dimid0);                                      
varid32 = netcdf.defVar(f,'size_factor','double',dimid0);                                 
varid33 = netcdf.defVar(f,'holroyd_habit','double',dimid0);                               
varid34 = netcdf.defVar(f,'area_hole_ratio','double',dimid0);                             
varid35 = netcdf.defVar(f,'inter_arrival','double',dimid0);                               
varid36 = netcdf.defVar(f,'bin_stats','double',dimid2);                                   
netcdf.endDef(f)

%% Variables initialization 
kk=1;
w=-1;
wstart = 0;

time_offset_hr = 0;
time_offset_mn = 0;
time_offset_sec = 0;
time_offset_ms = 0;
timeset_flag = 0;

end