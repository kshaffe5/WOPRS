function plot_SizeDist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function displays a size distribution histogram using the SD files
% generated from the WOPRS size distribution functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inputs:
infilename = {'/home/kshaffe5/test_proc_dir/20170118/SD.20170118.2DS.cdf'};% Must be a cell array (like an array but using curly brackets: {} )
start_time = 82500; % In seconds from the beginning of the day
end_time = 83000; % In seconds from the beginning of the day
colors = {'blue','red','black','green','yellow'}; % Must have at least as many colors as infilenames
x_dimensions = [1e1 1e5];
y_dimensions = [10e-12 10e3];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:length(infilename) % Read the probenames from the SD file names
    filename = char(infilename(i));
    periodpos = strfind(filename, '.');
    probename(i) = string(filename(periodpos(end)-4:periodpos(end)-1));
    periodinprobename = strfind(char(probename(i)), '.');
    if ~isempty(periodinprobename)
        probename(i) = string(filename(periodpos(end)-3:periodpos(end)-1));
    end
end

start_time_hhmmss = sec2hhmmss(start_time);
end_time_hhmmss = sec2hhmmss(end_time);

for j = 1:length(probename)
    %Read in time, size_dist, bin_min, and bin_max
    infile = netcdf.open(char(infilename(j)),'nowrite');
    time = netcdf.getVar(infile,netcdf.inqVarID(infile,'time'));
    sd = netcdf.getVar(infile,netcdf.inqVarID(infile,['size_dist_',char(probename(j))]));
    bin_min = netcdf.getVar(infile,netcdf.inqVarID(infile,'bin_min'));
    bin_max = netcdf.getVar(infile,netcdf.inqVarID(infile,'bin_max'));

    start_time_index = find(time == sec2hhmmss(start_time));
    end_time_index = find(time == sec2hhmmss(end_time));


    for i=1:length(bin_min)
        avg(i) = nanmean(sd(start_time_index:end_time_index,i,1)); %Take mean over the given time period without including NaN's
        x_array(i,:)=[bin_min(i),bin_max(i)];
        y_array(i,:)=[avg(i),avg(i)];
    
        plot(j) = loglog(x_array(i,:),y_array(i,:),char(colors(j)));
        xlim(x_dimensions);
        ylim(y_dimensions);
        hold on
        if i > 1 %Plot vertical lines to make the plot look like a histogram
            x_vert = [bin_min(i),bin_min(i)];
            y_vert = [avg(i-1),avg(i)];
            loglog(x_vert,y_vert,char(colors(j)))
        end  
    end
end

title(['Size distribution from ',num2str(start_time_hhmmss),' to ',num2str(end_time_hhmmss),' UTC']);
xlabel('Diameter (um)');
ylabel('n(#cm^-3 um^-1)');
legend(plot,probename);

end