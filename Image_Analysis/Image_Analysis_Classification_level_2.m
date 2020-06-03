function [num_holes,hole_area,reject_status]=Image_Analysis_Classification_level_2(image_buffer)

% At level 2, we need to calculate the number of holes and the area of the
% hole(s).
% Using this information we elminate donuts created by Poisson spots.

    image_size = size(image_buffer);
	n_slices  = image_size(1);
    bits = image_size(2);
    
    for i=1:n_slices
        for j=1:bits
            if ((image_buffer(i,j))=='0')
                image_buffer_reversed(i,j)=1;
            else
                image_buffer_reversed(i,j)=0;
            end
        end
    end

    % Find the area of the hole(s) if any are present
    stats=regionprops(image_buffer_reversed, 'FilledArea','Area');
    area=stats.Area;
    FilledArea=stats.FilledArea;
    hole_area=FilledArea - area;
    
    
    % Find the number of holes in an image. This is done by finding the
    % number of individual pieces in an image, and then subtracting the
    % euler number. The euler number is the number of pieces minus the
    % number of holes (with 8 pixel connectivity). Thus, the equation boils
    % down to: num_pieces - (num_pieces - num_holes) = num_holes
    x2 = bwconncomp(image_buffer_reversed);
    num_pieces=cellfun(@numel,x2.NumObjects);
    eulernum = bweuler(image_buffer_reversed);
    num_holes=num_pieces - eulernum;
    
    if num_holes == 1
        if hole_area >= area
            reject_status=2;
            return;
        end
    end

    
    if num_holes >= 2
        if hole_area >= (2*area)
            reject_status=2;
            return;
        end
    end
    
end