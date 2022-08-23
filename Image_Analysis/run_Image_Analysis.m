function run_Image_Analysis(infilename, probetype, nChucks, threshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This is the lead function in the Image_Analysis processing step.
%% 
%% Inputs: infilename, probetype, nChucks(max of 8), and threshold
%% (Threshold is only applicable to the CIP, and it represents the shading
%% threshold. It defaults to 50 if not provided.)
%%
%% Example inputs:
%% infilename = '/home/username/DIMG.ddmmyyyyhhmmss.2DS.cdf'
%% probetype = '2DS'
%% nchucks = 8
%% threshold = 50
%%
%% Edited by Adam Majewski and Kevin Shaffer
%% 
%% Last edits made: 3/1/2022
%%
%% Please consult the Read_ME.txt file or the wiki on Github for more 
%% detailed information and instructions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

starpos = find(infilename == '*',1,'last');
DIMGpos = find(infilename == '.',1,'first');
cdfpos = find(infilename == '.',1,'last');
slashpos = find(infilename == '/',1,'last');
filedir = infilename(1:slashpos);
filename = infilename(DIMGpos+1:cdfpos-1);

    % Threshold defaults to 50% if it was not provided by the user
    if(~exist('threshold','var'))
        threshold = 50;
    end


if ~isempty(starpos)
    files = dir(infilename);
    filenums = length(files);
else
    filenums = 1;
end

for i = 1:filenums
    if filenums > 1 || ~isempty(starpos)
        infilename = [filedir,files(i).name];
        infilename = infilename(1:slashpos);
    end

    %nChuck*nEvery should equal the total frame number 
    ncid = netcdf.open(infilename,'nowrite');
    time = netcdf.getVar(ncid, netcdf.inqVarID(ncid,'day'));
    nEvery = ceil(length(time)/nChucks);
    netcdf.close(ncid);
    
    
    % Assign the number of CPUs for this program
    if (nChucks > 1)
        parpool(nChucks)% Assign n CPUs to process
    end
    
     %Choose the start and end of chucks to be processed. Remember you can
     %split the chucks into different programs to process, since matlabpool can
     %only use up to 8 CPUs at once.
    
   if (nChucks > 1)
        parfor i=1:nChucks  % iiith chuck will be processed
            outfilename = [filedir,'parPROC.',filename,num2str(i),'.cdf'];
            Image_Analysis_core(infilename,outfilename, i, nEvery, probetype, threshold);  
        end
   else
       outfilename = [filedir,'PROC.',filename,'.cdf'];
       Image_Analysis_core(infilename,outfilename, 1, nEvery, probetype, threshold);
   end

    if (nChucks > 1)
        delete(gcp) % Turns off parallel processing
        mergeNetcdf([filedir,'parPROC.',filename,'*.cdf']) % Combine files after using parallel processing
    end

end
end
