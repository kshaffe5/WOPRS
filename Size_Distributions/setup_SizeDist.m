function [roundness_bin_edges,num_round_bins,In_status,in_status_value,diam_bin_edges,num_diam_bins,mid_bin_diams]=setup_SizeDist(probename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function sets all the bin edges for generating size distributions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% All probetypes:
roundness_bin_edges= [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];

%The following should have a value of ‘center-in’ or ‘all-in’
In_status = 'center-in';

%% Probetype-specific:
switch probename
    case '2DC'
        diam_bin_edges = [30 50 100 150 200 250 300 350 400 500 600 700 800 900 1000 1150 1300 1500 1750 2000 2500 3000 4000 5000 7500 9600 15000];

    case '2DP'
        diam_bin_edges = [200 400 600 800 1000 1250 1500 1750 2000 2500 3000 3750 4500 5500 6750 8250 10000 15000 20000 30000 45000 64000 100000];
 
    case 'HVPS'
        diam_bin_edges = [150 250 400 600 800 1000 1250 1500 1750 2000 2500 3000 3750 4500 5500 6750 8250 10000 15000 20000 30000 50000 100000 192000 500000];

    case '2DS'
        diam_bin_edges = [10 25 50 100 150 200 400 600 800 1000 1250 1500 1750 2000 2500 3000 3750 4500 5500 6750 8250 10000 15000 20000];
        
    case 'CIP'
        diam_bin_edges = [25 50 100 150 200 250 300 350 400 500 600 700 800 900 1000 1150 1300 1500 1750 2000 2500 3000 4000 5000 7500 16000];
        
    otherwise 
        disp('ERROR: Probetype is not supported. Please enter one of the following: 2DP, 2DC, 2DS, HVPS, or CIP. Note: Matlab is case sensitive')
        return;
end


switch In_status
    case {'Center-in','center-in','Centerin','centerin','Center','center'}
        in_status_value = {'A','I'}; %All-in or Center-in
    case {'All-in','all-in','Allin','allin','All','all'}
        in_status_value = {'A'}; %All-in only
    otherwise 
        disp('ERROR: In_status choice does not make sense. Check to make sure center-in or all-in is chosen in the setup file.')
        return;
end

num_round_bins = length(roundness_bin_edges) -1;
num_diam_bins = length(diam_bin_edges) -1;

for i=1:num_diam_bins
    mid_bin_diams(i) = mean(diam_bin_edges(i:i+1))/1000; %Get mid_bin_diams in millimeters for sample area calculation
end

end