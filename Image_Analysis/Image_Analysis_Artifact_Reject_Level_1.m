function [artifact_status,slicecount,in_status]=Image_Analysis_Artifact_Reject_Level_1(image_buffer)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the first level of image analysis. The purpose of this level is
% identify and reject artifacts. Images are rejected as one of four
% artifact types: shattered particles, streakers, stuck bits, and multiple
% images. If an image is identified as an artifact, 'artifact_status' is
% set to a value different than 0, and then we know that the image is to be
% rejected. Each artifact type corresponds to a different value of
% 'artifact_status'. If an image is identified as an artifact, it is then
% returned from this function, and it does not pass to levels 2 or 3. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize variables
notempty=0;
slicecount = -999;
artifact_status=1;
min_y = 0;
max_y = 0;
min_x = 0;
max_x = 0;
    
image_size = size(image_buffer);
n_slices  = image_size(1);
bits = image_size(2);

% Loop over the entire image looking for the dimensions of the image. 
% This is important because images can sometimes contain empty slices
% at the end of an image, making the slicecount larger than it should be.
for i=1:n_slices
    for j=1:bits
        if ((image_buffer(i,j))=='0')
            notempty=1;
            image_buffer_reversed(i,j)=1;
            if min_y == 0 || j < min_y
                min_y = j;
            end
            if j > max_y
                max_y = j;
            end
            if min_x == 0 || i < min_x
                min_x = i;
            end
            if i > max_x
                max_x = i;
            end    
        else
            image_buffer_reversed(i,j)=0;
        end
    end        
end
    
for j=1:bits
    shadowed(j)=sum(image_buffer_reversed(:,j));
end
    
%Find if the image is center-in, center-out, or all-in
if (shadowed(1) > 0) || (shadowed(end) > 0)
    if (shadowed(1) >= max_y) || (shadowed(end) >= max_y)
        in_status = 'O'; %Center-out
    else
        in_status = 'I'; %Center-in
    end
else
    in_status = 'A'; %All-in
end
    
if (notempty==0) %If the image has no shadowed pixels, then reject it
    artifact_status = 2;
    return;
end

% Calculate the x/y aspect ratio
slicecount= max_x - min_x + 1;
width = max_y - min_y + 1;
aspect_ratio = slicecount / width;

% If the image is 10+ times longer than it is wide, reject it. This is supposed
% to catch 'streakers', but may also catch stuck bits.
if aspect_ratio >= 10
    artifact_status = 3;
    return;
end

%If the image is 4+ pixels in length, and only one diode is shadowed,
%reject it. This is supposed to catch stuck bits.
if width==1 && slicecount>=4 
    artifact_status = 4;
    return;
end

num_shadowed_first_slice = sum(image_buffer_reversed(1,:));
fraction_shadowed = num_shadowed_first_slice / bits;
% If the first slice in the image is at least 10% shadowed, we reject
% it as a 'sliced' image.
if fraction_shadowed >= 0.1
    artifact_status = 5;
    return;
end

% Check for images with multiple particles. BWCONNCOMP finds the individual
% pieces of an image. I then find the total area of all of the pieces put
% together, and then sort the pieces by size. 
x2 = bwconncomp(image_buffer_reversed);
size_pieces=cellfun(@numel,x2.PixelIdxList);
total_area=sum(size_pieces);
sorted=sort(size_pieces);
test_ratio = sorted(x2.NumObjects) / total_area; % Largest piece divided by total area of all pieces combined

if x2.NumObjects >1
    % Calculate the combined area of all of the pieces other than the
    % largest piece.
    smaller_pieces=sum(sorted(1:x2.NumObjects-1));
        
    % Reject if the largest piece is smaller than all the smaller pieces 
    % combined and the largest piece is smaller than 300 pixels in area. OR
    % reject if the image is less than 300 pixels in area, the largest piece 
    % is smaller than 75 pixels in area, and the largest piece accounts for 
    % less than 80% of the total image area. OR reject if the largest piece
    % is smaller than all of the smaller pieces multiplied by 1.25, and
    % there are more than 5 pieces.
    % This is supposed to reject images with multiple particles, and/or 
    % broken images.
    if (((total_area < 300) && (sorted(x2.NumObjects) < 75) && (test_ratio < 0.8)) || ((sorted(x2.NumObjects) < smaller_pieces*1.25) && (x2.NumObjects > 5) && (sorted(x2.NumObjects) < 200)))
        artifact_status=6; 
    end
end

end

