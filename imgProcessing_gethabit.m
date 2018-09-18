 function imgProcessing_gethabit
%% Determine the Particle Habit
                %  We use the Holroyd algorithm here
                handles.bits_per_slice = diodenum;
                diode_stats = diode_stats + sum(c=='1',1);
                csum = sum(c=='1',1);

                images.holroyd_habit(kk) = holroyd(handles,c,probename);
                
                %% Determine if the particle is rejected or not
                %  Calculate the Particle Length, Width, Area, Auto Reject 
                %  Status And more... See calculate_reject_unified()
                %  funtion for more information
                
                [images.image_length(kk),images.image_width(kk),images.image_area(kk), ...
                    images.longest_y_within_a_slice(kk),images.max_top_edge_touching(kk),images.max_bottom_edge_touching(kk),...
                    images.image_touching_edge(kk), images.auto_reject(kk),images.is_hollow(kk),images.percent_shadow(kk),images.part_z(kk),...
                    images.sf(kk),images.area_hole_ratio(kk),handles]=calculate_reject_unified(c,handles,images.holroyd_habit(kk));

                images.max_hole_diameter(kk) = handles.max_hole_diameter;
                images.edge_at_max_hole(kk) = handles.edge_at_max_hole;

                max_horizontal_length = images.image_length(kk);
                max_vertical_length = images.longest_y_within_a_slice(kk);
                image_area = images.image_area(kk);

                diode_size= handles.diodesize;
                corrected_horizontal_diode_size = handles.diodesize;
                largest_edge_touching  = max(images.max_top_edge_touching(kk), images.max_bottom_edge_touching(kk));
                smallest_edge_touching = min(images.max_top_edge_touching(kk), images.max_bottom_edge_touching(kk));