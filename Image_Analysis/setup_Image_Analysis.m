function [boundary,boundarytime,diodesize,diodenum,armdist,wavelength,probetype,interarrival_time_threshold]=setup_Image_Analysis(probename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function contains all of the probe-specific information needed for
% generating the PROC files. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the threshold time for flagging particles with too small of an
% interarrival time.
interarrival_time_threshold = 10; % In units of microseconds

switch probename
    case '2DC'
        boundary=[255 255 255 255];
        boundarytime=85;

        diodesize = 0.025;  % Size of diode in millimeters
        diodenum  = 32;  % Number of diodes
        armdist = 61; % Distance between probearms in millimeters
        wavelength = 633*1e-6;
        
        probetype=1;

    case '2DP'
        boundary=[255 255 255 255];
        boundarytime=0;
        
        diodesize = 0.200;  % Size of diode in millimeters 
        diodenum  = 32;  % Number of diodes
        armdist = 260; % Distance between probearms in millimeters
        wavelength = 633*1e-6;
        
        probetype=1;
        clockfactor = 2.; %Correction in clock cycles in timer word for 2DP probe and King Air data system in conjunction
 
    case 'HVPS'
        boundary=[43690, 43690, 43690, 43690, 43690, 43690, 43690, 43690];
        boundarytime=0;

        diodesize = 0.150;  % Size of diode in millimeters
        diodenum  = 128;  % Number of diodes
        armdist = 161; % Distance between probearms in millimeters
        wavelength = 785*1e-6;
        
        probetype=2;

    case '2DS'
        boundary=[43690, 43690, 43690, 43690, 43690, 43690, 43690, 43690];
        boundarytime=0;
			     
        diodesize = 0.010;  % Size of diode in millimeters
        diodenum  = 128;  % Number of diodes
        armdist = 61; % Distance between probearms in millimeters
        wavelength = 785*1e-6;
        
        probetype=2;
        
    case 'CIP'
        boundary=3*ones(1,64);
        boundarytime=3;
		    
        diodesize = 0.025;  % Size of diode in millimeters
        diodenum  = 64;  % Number of diodes
        armdist = 61; % Distance between probearms in millimeters
        wavelength = 658*1e-6;
        
        probetype=3;
    otherwise 
        disp('ERROR: Probetype is not supported. Please enter one of the following: 2DP, 2DC, 2DS, HVPS, or CIP. Note: Matlab is case sensitive')
        return;
end

end