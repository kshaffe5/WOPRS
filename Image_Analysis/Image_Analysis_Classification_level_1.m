function [slicecount,height,reject_status,equiv_diam,area]=Image_Analysis_Classification_level_1(image_buffer)

% At level 1, we need to calculate length, height, area, and maximum
% diameter.
% Using this information we elminate streakers and stuck bits.

    notempty=0;
    
    image_size = size(image_buffer);
	n_slices  = image_size(1);
    bits = image_size(2);

    slicecount=n_slices;
    height=bits;
    
    for i=1:n_slices
        for j=1:bits
            if ((image_buffer(i,j))=='0')
                notempty=1;
                image_buffer_reversed(i,j)=1;
            else
                image_buffer_reversed(i,j)=0;
            end
        end
    end
    
    stats=regionprops(image_buffer_reversed, 'EquivDiameter','Area');
    equiv_diam=stats.EquivDiameter;
    area=stats.Area;
    
    if (notempty==1) %If the image has no shadowed pixels, then reject it
        [row,col]=find(image_buffer_reversed);
        height=max(col)-min(col)+1;
    else 
        reject_status=1;
        return;
    end
    
    
    if n_slices >500 % Assume that the particle is a streaker or a stuck bit and reject the particle
        reject_status = 1;
        return;
    end
    
    
    aspect_ratio = n_slices/height;
    
    if (aspect_ratio < 0.2) || (aspect_ratio > 5)
        reject_status=1;
        return;
    end
     
reject_status = 0;

end