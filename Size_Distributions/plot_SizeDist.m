function plot_SizeDist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function displays a size distribution histogram using the SD files
% generated from the WOPRS size distribution functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inputs:
infilename_WOPRS = {'/home/username/SD.20170118.2DS.cdf'};% Must be a cell array (like an array but using curly brackets: {} )
infilename_UIOPS = {'/kingair_data/snowie17/2DS/20170118/SD.cat.DIMG.base170118224746.2DS.V.proc.cdf','/kingair_data/snowie17/2DS/20170118/SD.cat.DIMG.base170118224746.2DS.H.proc.cdf'};% Must be a cell array (like an array but using curly brackets: {} )
probename={'2DS WOPRS','2DS UW-UIOPS V','2DS UW-UIOPS H'};
start_time = 82484; % In seconds from the beginning of the day
end_time = 82487; % In seconds from the beginning of the day
colors = {'blue','red','green','yellow'}; % Must have at least as many colors as infilenames
x_dimensions = [1e1 5e3];
y_dimensions = [10e-6 10e3];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:length(infilename_WOPRS) % Read the probenames from the SD file names
    filename = char(infilename_WOPRS(i));
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
    infile = netcdf.open(char(infilename_WOPRS(j)),'nowrite');
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
    
        plot(j) = loglog(x_array(i,:),y_array(i,:),char(colors(j)),'Linewidth',2);
        xlim(x_dimensions);
        ylim(y_dimensions);
        hold on
        if i > 1 %Plot vertical lines to make the plot look like a histogram
            x_vert = [bin_min(i),bin_min(i)];
            y_vert = [avg(i-1),avg(i)];
            loglog(x_vert,y_vert,char(colors(j)),'Linewidth',2)
        end  
    end
end

%% UIOPS:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(infilename_UIOPS) % Read the probenames from the SD file names
    filename = char(infilename_UIOPS(i));
    periodpos = strfind(filename, '.');
    probename(i) = string(filename(periodpos(end-2)-3:periodpos(end-2)-1));
end

start_time_hhmmss = sec2hhmmss(start_time);
end_time_hhmmss = sec2hhmmss(end_time);

for j = 1:length(probename)
    %Read in time, size_dist, bin_min, and bin_max
    infile = netcdf.open(char(infilename_UIOPS(j)),'nowrite');
    time = netcdf.getVar(infile,netcdf.inqVarID(infile,'time'));
    sd = netcdf.getVar(infile,netcdf.inqVarID(infile,'conc_minR'));
    bin_min = netcdf.getVar(infile,netcdf.inqVarID(infile,'bin_min'));
    bin_max = netcdf.getVar(infile,netcdf.inqVarID(infile,'bin_max'));
    bin_min = bin_min *1000;
    bin_max = bin_max *1000;

    start_time_index = find(time == sec2hhmmss(start_time));
    end_time_index = find(time == sec2hhmmss(end_time));

 
    for i=1:length(bin_min)
        avg_new(i) = nanmean(sd(i,start_time_index:end_time_index)); %Take mean over the given time period without including NaN's

        x_array(i,:)=[bin_min(i),bin_max(i)];
        y_array(i,:)=[avg_new(i),avg_new(i)];
    
        plot(j+1) = loglog(x_array(i,:),y_array(i,:),char(colors(j+1)),'Linewidth',2);
        xlim(x_dimensions);
        ylim(y_dimensions);
        %hold on
        if i > 1 %Plot vertical lines to make the plot look like a histogram
            x_vert = [bin_min(i),bin_min(i)];
            y_vert = [avg_new(i-1),avg_new(i)];
            loglog(x_vert,y_vert,char(colors(j+1)),'Linewidth',2)
        end  
    end
end


title(['Size distribution from ',num2str(start_time_hhmmss),' to ',num2str(end_time_hhmmss),' UTC']);
xlabel('Diameter (um)');
ylabel('n(#cm^-3 um^-1)');
legend(plot,probename);

end