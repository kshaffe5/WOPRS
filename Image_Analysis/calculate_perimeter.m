function [perimeter,area,filled_image]=calculate_perimeter(image_buffer_reversed)
perimeter = 0;
unshadowed_edges = 0;

image_size = size(image_buffer_reversed);
n_slices  = image_size(1);
bits = image_size(2);


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

% Fill all holes in the image before calculating area. Filling the hole
% here just applies to calculations; it does not change the actual image 
% when viewed.
filled_image = imfill(image_buffer_reversed,8,'holes');
stats=regionprops(filled_image,'Area');
area=stats.Area;


for i=1:n_slices
    for j=1:bits
        if filled_image(i,j) == 1
            %If the shadowed pixels are touching the edge, add 1 to perim
            if i == 1 || i == n_slices
                if i == 1
                    unshadowed_edges=unshadowed_edges+1;
                end
                if i == n_slices
                    unshadowed_edges=unshadowed_edges+1;
                end
            else
                if filled_image(i+1,j) == 0
                    unshadowed_edges=unshadowed_edges+1;
                end
                if filled_image(i-1,j) == 0
                    unshadowed_edges=unshadowed_edges+1;
                end
            end
            if j == 1 || j == bits
                if j == 1
                    unshadowed_edges=unshadowed_edges+1;
                end
                if j == bits
                    unshadowed_edges=unshadowed_edges+1;
                end
            else
                if filled_image(i,j+1) == 0
                    unshadowed_edges=unshadowed_edges+1;
                end
                if filled_image(i,j-1) == 0
                    unshadowed_edges=unshadowed_edges+1;
                end
            end
            
            % Test
            if unshadowed_edges == 0
                perimeter = perimeter + 0;
            elseif unshadowed_edges == 1
                perimeter = perimeter + 1;
            elseif unshadowed_edges == 2
                perimeter = perimeter + 1.5;
            elseif unshadowed_edges == 3
                perimeter = perimeter + 1.75;
            elseif unshadowed_edges == 4
                perimeter = perimeter + pi;
            end
            
            unshadowed_edges = 0;
        end
    end
end

end