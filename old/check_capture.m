function [  ] = check_capture( datapath )
%check all the captured image in a folder

files=dir(fullfile(datapath,'capture*'));

for ifile=1:length(files)
    load(fullfile(datapath,files(ifile).name));
    SI(img);
    title(['exposure = ',num2str(Exposure),' ms']);
    pause
end

end

