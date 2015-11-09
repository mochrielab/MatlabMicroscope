function [ filename ] = GetFileHeader( obj, option )
%get the file headers for saving file

t=clock;
datepath=fullfile(obj.datasavepath,...
    [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',num2str(t(1))]);
if ~exist(datepath)
    mkdir(datepath);
end
filename=fullfile(datepath,[obj.experiment_name,'_',option,'_',...
    num2str(t(4),'%02d'),'_',num2str(t(5),'%02d'),'_',...
    num2str(round(t(6)),'%02d'),'.tif']);

end

