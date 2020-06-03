function run_Image_Analysis(infilename, probetype, nChucks, threshold)
%% This function is the lead function in the Image_Analysis processing step.
%% 
%% Inputs: infilename, probetype, nChucks(max of 8), projectname, and threshold
%% (Threshold is only applicable to the CIP-G, and it represents the shading
%% threshold. It defaults to 50 if not provided.)
%%
%% Edited by Adam Majewski and Kevin Shaffer
%% 
%% Last edits made: 7/11/2019
%%
%% Please consult the wiki on Github for more detailed information and instructions

starpos = find(infilename == '*',1,'last');
slashpos = find(infilename == '/',1,'last');
filedir = infilename(1:slashpos);
filename = infilename(slashpos+1:end);

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
    numb=11:10+nChucks;  % Start from 11 to avoid sigle numbers in file name for later convinience

    % Assign the number of CPUs for this program
    if (nChucks > 1)
        parpool(nChucks)% Assign n CPUs to process
    end

    
%     Choose the start and end of chucks to be processed. Remember you can
%     split the chucks into different programs to process, since matlabpool can
%     only use 8 CPUs at once
    perpos = find(infilename == '.',1,'last')

   if (nChucks > 1)
        parfor iii=1:nChucks % 33:40  % iiith chuck will be processed 
            outfilename = [filedir,'PROC.',infilename(1:perpos-1),'_',num2str(iii),'.cdf'];
            Image_Analysis_core(infilename,outfilename, probetype, threshold);  
        end
   else
       outfilename = [filedir,'PROC.',infilename(1:perpos-1),'.cdf'];
       Image_Analysis_core(infilename,outfilename, probetype, iii, nEvery, threshold);
    end

    if (nChucks > 1)
        delete(gcp)
    end
end
end
