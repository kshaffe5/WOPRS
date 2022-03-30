function [aspect_ratio,diameter,perimeter,area,area_ratio,orientation]=Image_Analysis_Calculate_Parameters_Level_3(image_buffer,poisson_hole,diameter,area_original,area_ratio_original)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the third level of image analysis. The purpose of this level is
% to calculate any parameters that we are interested in.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[perimeter,area,image_buffer_reversed]=calculate_perimeter(image_buffer);

% Fill holes in images with Poisson spots
if poisson_hole == 1
    image_buffer_reversed = imfill(image_buffer_reversed,8,'holes');
end
    
% Check a few other stats that are easy to calculate
stats=regionprops(image_buffer_reversed,'MajorAxisLength','MinorAxisLength','Orientation');
max_length =stats.MajorAxisLength;
min_length =stats.MinorAxisLength;
aspect_ratio = max_length / min_length;
orientation = stats.Orientation;

% If the image has a poisson spot, then a corrected diameter has already
% been calculated. Otherwise we set diameter equal to the maximum image
% diameter.
if poisson_hole == 0
    diameter = max_length;
    % Area ratio describes how the real area compares to the area of a circle
    % with the same diameter. Will be a value between 0 and 1.
    equiv_Area = pi * (diameter/2)^2.;
    area_ratio = area / equiv_Area;
else
    area_ratio = area_ratio_original;
    area = area_original;
end

end