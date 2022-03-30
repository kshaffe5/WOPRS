function [area_ratio_bin_edges,num_ar_bins,answer_status,in_status_selection,kk,num_bins,mid_bin_diams,num_diodes,diodesize,armdst,wavelength]=read_setup(setupfile,probename)

setup = readlines(setupfile,'EmptyLineRule','skip');

for i=1:length(setup)
    find_area = strfind(setup(i),'Area');
    find_in_status = strfind(setup(i),'In-status');
    find_diam = strfind(setup(i),[probename,' diameter']);
    find_num_diodes = strfind(setup(i),[probename,' number']);
    find_diodesize = strfind(setup(i),[probename,' diode']);
    find_armdst = strfind(setup(i),[probename,' arm']);
    find_wavelength = strfind(setup(i),[probename,' wavelength']);
    
    if find_area ~= 0
        commented = strfind(setup(i), '%');
        if commented == 1 %If the first value of the line is '%', do nothing
            % Line is commented out, so do nothing
        else
            colonpos = strfind(setup(i), ':');
            area_ratio_line = char(setup(i));
            area_ratio_line(colonpos+1:end);
            area_ratio_bin_edges = str2num(area_ratio_line(colonpos+1:end));
            num_ar_bins = length(area_ratio_bin_edges);
        end
    end
    
    
    if find_in_status ~= 0
        commented = strfind(setup(i), '%');
        if commented == 1 %If the first value of the line is '%', do nothing
            % Line is commented out, so do nothing
        else
            colonpos = strfind(setup(i), ':');
            in_status_line = char(setup(i));
            answer_status = strtrim(in_status_line(colonpos+1:end));
            switch answer_status
                case {'Center-in','center-in','Centerin','centerin','Center','center'}
                    in_status_selection = {'A','I'}; %All-in or Center-in
                case {'All-in','all-in','Allin','allin','All','all'}
                    in_status_selection = {'A'}; %All-in only
                otherwise 
                    disp('ERROR: In_status choice does not make sense. Check to make sure center-in or all-in is chosen in the setup file.')
                    return;
            end
        end
    end   
    
    if find_diam ~= 0
        commented = strfind(setup(i), '%');
        if commented == 1 %If the first value of the line is '%', do nothing
            % Line is commented out, so do nothing
        else
            colonpos = strfind(setup(i), ':');
            diam_line = char(setup(i));
            kk = str2num(diam_line(colonpos+1:end));
            num_bins = length(kk) - 1;
            for i=1:num_bins
                mid_bin_diams(i) = mean(kk(i:i+1))/1000; %Get mid_bin_diams in millimeters for sample area calculation
            end
        end
    end   
    
    if find_num_diodes ~= 0
        commented = strfind(setup(i), '%');
        if commented == 1 %If the first value of the line is '%', do nothing
            % Line is commented out, so do nothing
        else
            colonpos = strfind(setup(i), ':');
            num_line = char(setup(i));
            num_diodes = str2num(num_line(colonpos+1:end));
        end
    end   
    
    if find_diodesize ~= 0
        commented = strfind(setup(i), '%');
        if commented == 1 %If the first value of the line is '%', do nothing
            % Line is commented out, so do nothing
        else
            colonpos = strfind(setup(i), ':');
            diodesize_line = char(setup(i));
            diodesize = str2num(diodesize_line(colonpos+1:end));
        end
    end
    
    if find_armdst ~= 0
        commented = strfind(setup(i), '%');
        if commented == 1 %If the first value of the line is '%', do nothing
            % Line is commented out, so do nothing
        else
            colonpos = strfind(setup(i), ':');
            armdst_line = char(setup(i));
            armdst = str2num(armdst_line(colonpos+1:end));
        end
    end
    
    if find_wavelength ~= 0
        commented = strfind(setup(i), '%');
        if commented == 1 %If the first value of the line is '%', do nothing
            % Line is commented out, so do nothing
        else
            colonpos = strfind(setup(i), ':');
            wavelength_line = char(setup(i));
            wavelength = str2num(wavelength_line(colonpos+1:end));
        end
    end
    
end


%Check that all of the info was in the setup file
if area_ratio_bin_edges == 0
    disp(['ERROR: Setup file has no area ratio bins for this probe. Return to setup file and make sure there is a line that begins with Area ratio bin edges: ...'])
    return;
end
if exist(in_status_line) %If in_status doesn't exist
    disp(['ERROR: Setup file has no center-in or all-in choice selected. Return to setup file.'])
    return;
end
if kk == 0
    disp(['ERROR: Setup file has no diameter bins for this probe. Return to setup file and make sure there is a line that begins with ',probename,' diameter bin edges: ...'])
    return;
end
if num_diodes == 0
    disp(['ERROR: Setup file has no number of diodes for this probe. Return to setup file and make sure there is a line that begins with ',probename,' number of diodes: ...'])
    return;
end
if diodesize == 0
    disp(['ERROR: Setup file has no diode size for this probe. Return to setup file and make sure there is a line that begins with ',probename,' diode size: ...'])
    return;
end
if armdst == 0
    disp(['ERROR: Setup file has no arm distance for this probe. Return to setup file and make sure there is a line that begins with ',probename,' arm distance: ...'])
    return;
end
if wavelength == 0
    disp(['ERROR: Setup file has no wavelength for this probe. Return to setup file and make sure there is a line that begins with ',probename,' wavelength: ...'])
    return;
end 

end