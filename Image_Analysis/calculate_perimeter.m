function [perimeter,area,image_buffer_reversed]=calculate_perimeter(image_buffer)

perimeter=0;
area=0;


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

% Check for images with satellites. If they have satellites, then find the
% largest piece and set all satellites to 0 so that all calculations are
% done on the largest piece only.
x2 = bwconncomp(image_buffer_reversed);
num_pixels=cellfun(@numel,x2.PixelIdxList);
[biggest,idx]=max(num_pixels);
for i = 1:x2.NumObjects
    if i ~= idx
        image_buffer_reversed(x2.PixelIdxList{i}) = 0;
    end
end

filled_image = imfill(image_buffer_reversed,8,'holes');

stats=regionprops(filled_image,'Area');
area=stats.Area;

for i=1:n_slices
    for j=1:bits
        if filled_image(i,j) == 1
            %If the shadowed pixels are touching the edge, add 1 to perim
            if i == 1 || i == n_slices
                perimeter=perimeter+1;
            else
                if filled_image(i+1,j) == 0
                    perimeter=perimeter+1;
                end
                if filled_image(i-1,j) == 0
                    perimeter=perimeter+1;
                end
            end
            if j == 1 || j == bits
                perimeter=perimeter+1;
            else
                if filled_image(i,j+1) == 0
                    perimeter=perimeter+1;
                end
                if filled_image(i,j-1) == 0
                    perimeter=perimeter+1;
                end
            end
        end
    end
end

end