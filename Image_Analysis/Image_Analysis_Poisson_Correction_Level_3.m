function [poisson_corrected,diameter]=Image_Analysis_Poisson_Correction_Level_3(diameter,aspect_ratio,area_ratio,circularity,roundness,filled_image)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the third level of image analysis. The purpose of this level is
% to calculate any parameters that we are interested in.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If the image is somewhat circular and has only 1 hole, we correct it. The
% smaller then image, the less circular the image has to be.
if area_ratio > 0.9
    if num_holes == 1 && num_pieces == 1
        % Find the area of the hole and then the equivalent diameters of the
        % hole and the filled image
        hole_area= filled_area - area;
        hole_diam = sqrt(4*hole_area/pi);
        total_diam = sqrt(4*filled_area/pi);
        diameter = correct_poisson(hole_diam,total_diam); % Call correct_poisson to use the correction from Korolev et al 2007
        poisson_corrected = 1;
    else
        poisson_corrected = 0;
    end
else 
    poisson_corrected = 0;
end

end