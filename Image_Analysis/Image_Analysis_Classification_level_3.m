function[eccentricity,circularity,orientation,reject_status]=Image_Analysis_Classification_level_3(image_buffer)

% At level 3, we calculate things like circularity, number of pieces, and
% anything else that we might want to calculate.
% Using this information we elminate all other artifacts.

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

% Check for broken particles
    x2 = bwconncomp(image_buffer_reversed);
    size_pieces=cellfun(@numel,x2.PixelIdxList);
    total_area=sum(size_pieces);
    sorted=sort(size_pieces);

    if x2.NumObjects >1
        smaller_pieces=sum(sorted(1:x2.NumObjects-1));
        if ((sorted(x2.NumObjects) < smaller_pieces*2) && (sorted(x2.NumObjects)<500)) || ((total_area < 300) && (sorted(x2.NumObjects-1)>5))
            reject_status=3;
            return;
        end    
    end
    
 % Check a few other stats that are easy to calculate
        stats=regionprops(image_buffer_reversed, 'Eccentricity','Circularity','Orientation');
        eccentricity=stats.Eccentricity;
        circularity =stats.Circularity;
        orientation =stats.Orientation;
        
reject_status = 0;

end