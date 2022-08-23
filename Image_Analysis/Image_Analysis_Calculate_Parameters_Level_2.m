function [diameter,num_holes,num_pieces,perimeter,area,aspect_ratio,roundness,orientation,circularity,filled_image]=Image_Analysis_Calculate_Parameters_Level_2(image_buffer,in_status)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the second level of image analysis. The purpose of this level is
% to correct images that have been distorted dues to Poisson Spots. We will 
% be following the correction method proposed in Korolev 2007. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop over the whole image and translate the characters to numerics
image_size = size(image_buffer);
for i = 1:image_size(1)
    for j = 1:image_size(2)
        image_buffer_reversed(i,j) = str2double(image_buffer(i,j));
    end
end

% Reverse the 0's and 1's so that they can be analyzed via regionprops
image_buffer_reversed = ~image_buffer_reversed;

% Find the number of holes in an image. This is done by finding the
% number of individual pieces in an image, and then subtracting the
% euler number. The euler number is the number of pieces minus the
% number of holes (with 8 pixel connectivity). Thus, the equation boils
% down to: num_pieces - (num_pieces - num_holes) = num_holes
x2 = bwconncomp(image_buffer_reversed);
num_pieces=x2.NumObjects;
eulernum = bweuler(image_buffer_reversed);
num_holes=num_pieces - eulernum;


%% Calculate circularity, roundness, area ratio, and aspect ratio for images
%% that are 'all-in'
[perimeter,area,filled_image]=calculate_perimeter(image_buffer_reversed);


% Find the major axis length (in other words, the maximum diameter) of the
% image. Use the maximum diameter to calculate the area of a perfect circle 
% with the corresponding diameter. Divide the predicted area of a perfect
% circle by the area of the image with any holes filled. The smaller this
% ratio, the less circular the image is.
stats=regionprops(filled_image,'MajorAxisLength','MinorAxisLength','Orientation');
max_length =stats.MajorAxisLength;
min_length =stats.MinorAxisLength;
diameter = max_length;

if in_status ~= 'A'
    aspect_ratio = NaN;
    circularity = NaN;
    roundness = NaN;
    orientation = NaN;
else
    aspect_ratio = max_length / min_length;
    circularity = (4*pi*area) / (perimeter^2);
    roundness = (4*area) / (pi*max_length^2);
    orientation = stats.Orientation;
end
