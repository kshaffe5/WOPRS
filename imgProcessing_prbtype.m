function imgProcessing_prbtype(probename)
%% Setting probe information according to probe type
%    use ProbeType to indicate three type of probes:
%       0: 2DC/2DP, 32 doides, boundary 85, 
%       1: CIP/PIP, 64 doides, boundary 170
%       2: HVPS/2DS, 128 doides, boundary 170
 
switch probename
    case '2DC'
        boundary=[255 255 255 255];
        boundarytime=85;

        ds = 0.025;			     % Size of diode in millimeters
        handles.diodesize = ds;  
        handles.diodenum  = 32;  % Diode number
        handles.current_image = 1;
        probetype=0;

    case '2DP'
        boundary=[255 255 255 255];
        boundarytime=0;

        ds = 0.200;			     % Size of diode in millimeters
        handles.diodesize = ds;  
        handles.diodenum  = 32;  % Diode number
        handles.current_image = 1;
        probetype=0;
        clockfactor = 2.; %Correction in clock cycles in timer word for 2DP probe and King Air data system in conjunction
    case 'CIP'
        boundary=[170, 170, 170, 170, 170, 170, 170, 170];
        boundarytime=NaN;

        ds = 0.025;			     % Size of diode in millimeters
        handles.diodesize = ds;
        handles.diodenum  = 64;  % Diode number
        handles.current_image = 1;
        probetype=1;

    case 'CIPG'
        boundary=3*ones(1,64);
        boundarytime=3;

        ds = 0.025;			     % Size of diode in millimeters
        handles.diodesize = ds;
        handles.diodenum  = 64;  % Diode number
        handles.current_image = 1;
        probetype=3;
        
    case 'PIP'
        boundary=[170, 170, 170, 170, 170, 170, 170, 170];
        boundarytime=NaN;

        ds = 0.100;			     % Size of diode in millimeters
        handles.diodesize = ds;
        handles.diodenum  = 64;  % Diode number
        handles.current_image = 1;
        probetype=1;
        
    case 'HVPS'
        boundary=[43690, 43690, 43690, 43690, 43690, 43690, 43690, 43690];
        boundarytime=0;

        ds = 0.150;			     % Size of diode in millimeters
        handles.diodesize = ds;
        handles.diodenum  = 128; % Diode number
        handles.current_image = 1;
        probetype=2;

    case '2DS'
        boundary=[43690, 43690, 43690, 43690, 43690, 43690, 43690, 43690];
        boundarytime=0;

        ds = 0.010;			     % Size of diode in millimeters
        handles.diodesize = ds;
        handles.diodenum  = 128; % Diode number
        handles.current_image = 1;
        probetype=2;
end
if(~exist('threshold','var'))
	threshold = 50;
end
if(~exist('clockfactor'))
    clockfactor = 1.;
end
diodenum = handles.diodenum;
byteperslice = diodenum/8;  
handles.disagree = 0;



end