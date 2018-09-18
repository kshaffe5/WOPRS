function imgProcessing_writeout
%% Write out the processed information on NETCDF
    if kk > 1
        
       
        netcdf.putVar ( f, varid0, wstart, w-wstart+1, rec_time(:) );
        netcdf.putVar ( f, varid1, wstart, w-wstart+1, rec_date(:) );
        
        netcdf.putVar ( f, varid101, wstart, w-wstart+1, time_in_seconds(:) );
        netcdf.putVar ( f, varid102, wstart, w-wstart+1, particle_sliceCount );
        netcdf.putVar ( f, varid103, wstart, w-wstart+1, particle_DOF );
        netcdf.putVar ( f, varid104, wstart, w-wstart+1, particle_partNum );

        
        netcdf.putVar ( f, varid2, wstart, w-wstart+1, rec_millisec(:) );
        netcdf.putVar ( f, varid3, wstart, w-wstart+1, rec_wkday(:) );
        netcdf.putVar ( f, varid4, [0 wstart], [2 w-wstart+1], images.position' );
        netcdf.putVar ( f, varid5, wstart, w-wstart+1, part_hour(:)*10000+part_min(:)*100+part_sec(:) );
        netcdf.putVar ( f, varid6, wstart, w-wstart+1, part_mil(:) );
        netcdf.putVawarning on allr ( f, varid7, wstart, w-wstart+1, part_micro(:) );
        netcdf.putVar ( f, varid8, wstart, w-wstart+1, parent_rec_num );    
        netcdf.putVar ( f, varid9, wstart, w-wstart+1, particle_num(:) );
        netcdf.putVar ( f, varid10, wstart, w-wstart+1, images.image_length);                         
        netcdf.putVar ( f, varid11, wstart, w-wstart+1, images.image_width);                          
        netcdf.putVar ( f, varid12, wstart, w-wstart+1, images.image_area*diode_size*diode_size);                           
        netcdf.putVar ( f, varid13, wstart, w-wstart+1, images.longest_y_within_a_slice);             
        netcdf.putVar ( f, varid14, wstart, w-wstart+1, images.max_top_edge_touching);                
        netcdf.putVar ( f, varid15, wstart, w-wstart+1, images.max_bottom_edge_touching); 
        netcdf.putVar ( f, varid16, wstart, w-wstart+1, images.image_touching_edge-'0');                  
        netcdf.putVar ( f, varid17, wstart, w-wstart+1, double(images.auto_reject));                  
        netcdf.putVar ( f, varid18, wstart, w-wstart+1, images.is_hollow);                            
        netcdf.putVar ( f, varid19, wstart, w-wstart+1, images.center_in);                            
        netcdf.putVar ( f, varid20, wstart, w-wstart+1, images.axis_ratio);                           
        netcdf.putVar ( f, varid21, wstart, w-wstart+1, images.diam_circle_fit);                      
        netcdf.putVar ( f, varid22, wstart, w-wstart+1, images.diam_horiz_chord);                     
        netcdf.putVar ( f, varid23, wstart, w-wstart+1, images.diam_horiz_chord ./ images.sf);        
        netcdf.putVar ( f, varid24, wstart, w-wstart+1, images.diam_horiz_mean);              
        netcdf.putVar ( f, varid25, wstart, w-wstart+1, images.diam_vert_chord);                           
        netcdf.putVar ( f, varid26, wstart, w-wstart+1, images.minR*diode_size);                      
        netcdf.putVar ( f, varid27, wstart, w-wstart+1, images.AreaR*diode_size);       
        netcdf.putVar ( f, varid45, wstart, w-wstart+1, images.Perimeter*diode_size); 
        if 1==iRectEllipse 
            netcdf.putVar ( f, varid46, wstart, w-wstart+1, images.RectangleL*diode_size);                      
            netcdf.putVar ( f, varid47, wstart, w-wstart+1, images.RectangleW*diode_size);         
            netcdf.putVar ( f, varid67, wstart, w-wstart+1, images.RectangleAngle);         
            netcdf.putVar ( f, varid48, wstart, w-wstart+1, images.EllipseL*diode_size);                      
            netcdf.putVar ( f, varid49, wstart, w-wstart+1, images.EllipseW*diode_size); 
            netcdf.putVar ( f, varid69, wstart, w-wstart+1, images.EllipseAngle); 
        end
        netcdf.putVar ( f, varid28, wstart, w-wstart+1, images.percent_shadow);                       
        netcdf.putVar ( f, varid29, wstart, w-wstart+1, images.max_hole_diameter);                    
        netcdf.putVar ( f, varid30, wstart, w-wstart+1, images.edge_at_max_hole);                     
        netcdf.putVar ( f, varid31, wstart, w-wstart+1, images.part_z);                               
        netcdf.putVar ( f, varid32, wstart, w-wstart+1, images.sf);                                   
        netcdf.putVar ( f, varid33, wstart, w-wstart+1, double(images.holroyd_habit));                
        netcdf.putVar ( f, varid34, wstart, w-wstart+1, images.area_hole_ratio);                      
        netcdf.putVar ( f, varid35, wstart, w-wstart+1, images.int_arrival);                          
        netcdf.putVar ( f, varid36, diode_stats );
        
        wstart = w+1;
        kk = 1;
        clear rec_time rec_date rec_millisec part_hour part_min part_sec part_mil part_micro parent_rec_num particle_num images time_in_seconds particle_sliceCount particle_DOF particle_partNum

    end
    clear images
end
