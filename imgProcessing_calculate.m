 function imgProcessing_calculate
%% Calculate more size deciptor using more advanced techniques
                %  See dropsize for more information
                [images.center_in(kk),images.axis_ratio(kk),images.diam_circle_fit(kk),images.diam_horiz_chord(kk),images.diam_vert_chord(kk),...
                    images.diam_horiz_mean(kk), images.diam_spheroid(kk)]=dropsize(max_horizontal_length,max_vertical_length,image_area...
                    ,largest_edge_touching,smallest_edge_touching,diode_size,corrected_horizontal_diode_size, diodenum);
                
                %% Calculate size deciptor using bamex code
                %  See dropsize_new for more information
                % images.diam_bamex(kk) = dropsize_new(c, largest_edge_touching, smallest_edge_touching, diodenum, corrected_horizontal_diode_size, handles.diodesize, max_vertical_length);
                
                %% Using OpenCV C program to calculate length, width and radius. This                 
                %% Get diameter of the smallest-enclosing circle, rectangle and ellipse
                %images.minR(kk)=particlesize_cgal(c);
                images.minR(kk)=CGAL_minR(c);
                images.AreaR(kk)=2*sqrt(images.image_area(kk)/3.1415926);  % Calculate the Darea (area-equivalent diameter)
                images.Perimeter(kk)=ParticlePerimeter(c);
                
                if 1==iRectEllipse 
                    [images.RectangleL(kk), images.RectangleW(kk), images.RectangleAngle(kk)] = CGAL_RectSize(c);
                    [images.EllipseL(kk), images.EllipseW(kk), images.EllipseAngle(kk)]       = CGAL_EllipseSize(c);
                end
                %% Get the area ratio using the DL=max(DT,DP), only observed area are used
                if images.image_length(kk) > images.image_width(kk)
                    images.percent_shadow(kk) = images.image_area(kk) / (pi * images.image_length(kk).^ 2 / 4);
                elseif images.image_width(kk) ~= 0
                    images.percent_shadow(kk) = images.image_area(kk) / (pi * images.image_width(kk).^ 2 / 4);
                else
                    images.percent_shadow(kk) = 0;
                end
                
                if probetype == 3
                    start = j + 3;
                else
                    start = j + 2;
                end
                kk = kk + 1;
                clear c ind_matrix
           %end
        end

        j = j + 1;
    end
