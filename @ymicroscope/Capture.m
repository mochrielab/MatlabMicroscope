function [ img ] = Capture( obj, hobj, event )
% capture of an image already exist in live

if strcmp(obj.status,'standing') 
    obj.mm.setExposure(obj.exposure);    
    axes(obj.imageaxis_handle);
    obj.mm.snapImage();
    img = obj.mm.getImage();
    
    width = obj.mm.getImageWidth();
    height = obj.mm.getImageHeight();

    if obj.mm.getBytesPerPixel == 2
        pixelType = 'uint16';
    else
        pixelType = 'uint8';
    end
    img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
    img = reshape(img, [width, height]); % image should be interpreted as a 2D array
    img = transpose(img);                % make column-major order for MATLAB
    % plot
    cla %clear current axis
    imagesc(img);colormap gray;axis image;axis off
    drawnow;
else
    img=getimage(obj.imageaxis_handle);
end

% save data
t=clock;
datepath=fullfile(obj.datasavepath,...
    [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',num2str(t(1))]);
if ~exist(datepath)
    mkdir(datepath);
end

    %%% Modified/Added 06/07/15 %%%

    IllumMode = obj.illumination_mode;
    Exposure = obj.exposure;
    DispSize = obj.display_size;

% save(fullfile(datepath,['capture_',...
%     num2str(t(4),'%02d'),'_',num2str(t(5),'%02d'),'_',...
%     num2str(round(t(6)),'%02d')])...
%     ,'img');

save(fullfile(datepath,['capture_',...
    num2str(t(4),'%02d'),'_',num2str(t(5),'%02d'),'_',...
    num2str(round(t(6)),'%02d')])...
    ,'IllumMode','Exposure','DispSize','img');


fid=fopen([obj.datasavepath2,filesep,'ImgLog.txt'],'a+');
fprintf(fid, '%10s %15s %20s %20d %20s %20s %20s %20s \r\n',...
    [num2str(t(2),'%02d'),'\',num2str(t(3),'%02d'),'\',num2str(t(1))],...
    [num2str(t(4),'%02d'),':',num2str(t(5),'%02d'),':',...
    num2str(round(t(6)),'%02d')],obj.illumination_mode,...
    obj.exposure,obj.display_size,'N/A','N/A','N/A');
fclose(fid);


end