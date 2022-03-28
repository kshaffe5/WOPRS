function [corrected_diameter,poisson_corrected,num_holes,num_pieces,filled_area]=Image_Analysis_Distortion_Correction_Level_2(image_buffer)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the second level of image analysis. The purpose of this level is
% to correct images that have been distorted dues to Poisson Spots. We will 
% be following the correction method proposed in Korolev 2007. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
poisson_corrected=0;
corrected_diameter = -999;

% Loop over the whole image and translate the characters to numerics
image_size = size(image_buffer);
for i = 1:image_size(1)
    for j = 1:image_size(2)
        image_buffer_reversed(i,j) = str2double(image_buffer(i,j));
    end
end

% Reverse the 0's and 1's so that they can be analyzed via regionprops
image_buffer_reversed = ~image_buffer_reversed;

% Find the normal area and the area with any holes filled. Also, get the
% image with any holes filled so that we can find the major axis length.
stats=regionprops(image_buffer_reversed,'FilledImage','FilledArea','Area');
filled_image=stats.FilledImage;
area= stats.Area;
filled_area=stats.FilledArea;

% Find the major axis length (in other words, the maximum diameter) of the
% image. Use the maximum diameter to calculate the area of a perfect circle 
% with the corresponding diameter. Divide the predicted area of a perfect
% circle by the area of the image with any holes filled. The smaller this
% ratio, the less circular the image is.
stats=regionprops(filled_image,'MajorAxisLength');
max_length =stats.MajorAxisLength;
predicted_area = pi * (max_length/2)^2;
area_fraction = filled_area / predicted_area;

% Find the number of holes in an image. This is done by finding the
% number of individual pieces in an image, and then subtracting the
% euler number. The euler number is the number of pieces minus the
% number of holes (with 8 pixel connectivity). Thus, the equation boils
% down to: num_pieces - (num_pieces - num_holes) = num_holes
x2 = bwconncomp(image_buffer_reversed);
num_pieces=x2.NumObjects;
eulernum = bweuler(image_buffer_reversed);
num_holes=num_pieces - eulernum;


% If the image is somewhat circular and has only 1 hole, we correct it. The
% smaller then image, the less circular the image has to be.
if ((area_fraction > 0.7) && (filled_area > 150)) || ((area_fraction > 0.6) && (filled_area <= 150) && (filled_area > 50)) || (filled_area <= 50)
    if num_holes == 1 && num_pieces == 1
        % Find the area of the hole and then the equivalent diameters of the
        % hole and the filled image
        hole_area= filled_area - area;
        hole_diam = sqrt(4*hole_area/pi);
        total_diam = sqrt(4*filled_area/pi);
        corrected_diameter = correct_poisson(hole_diam,total_diam); % Call correct_poisson to use the correction from Korolev et al 2007
        poisson_corrected = 1;
    end
end