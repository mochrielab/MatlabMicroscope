% matlab talking to NI instrument
% initialize

devices = daq.getDevices;
s=daq.createSession('ni');
addAnalogOutputChannel(s,'Dev1',0,'Voltage');

s2 = daq.createSession('ni');
s2.addDigitalChannel('Dev1','Port0/Line1:2','OutputOnly');

% set output voltage zero
s.outputSingleScan(0);
%             obj.nidaq.startForeground();
s2.outputSingleScan([0 0]);

%%
% load java path
dirpath='C:\Program Files\Micro-Manager-1.4\plugins\Micro-Manager';
files=dir(fullfile(dirpath,'*.jar'));
for ifile=1:length(files)
    javaaddpath(fullfile(dirpath,files(ifile).name));
end
display('finished loading java path');


% piezo conversion
um_per_volts=200/10;
um_per_pix=6.5/100;
volts_per_pix= um_per_pix/um_per_volts;

% %
% cameralabel=mmc.getCameraDevice;

%% set up camera
import mmcorej.*;
mmc=CMMCore();
mmc.loadSystemConfiguration ('C:\Program Files\Micro-Manager-1.4\MMConfig_andorzyla.cfg');

%
cameralabel=mmc.getCameraDevice;
%% LIVE
dataoffset=0;
mmc.setExposure(40);
for i=1
s.outputSingleScan(dataoffset);
f=figure('Position',[0 50 1000 900]);
while ishandle(f)
    mmc.snapImage();
    img = mmc.getImage();
    width = mmc.getImageWidth();
    height = mmc.getImageHeight();
    if mmc.getBytesPerPixel == 2
        pixelType = 'uint16';
    else
        pixelType = 'uint8';
    end
    img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
    img = reshape(img, [width, height]); % image should be interpreted as a 2D array
    img = transpose(img);                % make column-major order for MATLAB
    % imshow(img);
    imagesc(img);colormap gray;axis image;axis off
    drawnow;
    %     pause(.3);
end
end
%% scan z
for i=1
s.Rate=3; %Hz
s.IsContinuous=0; % continuous writing

% data
stacks=-45:45;
data=stacks*volts_per_pix+dataoffset;
data=reshape(data,length(data),1);
queueOutputData(s,data)

s.stop;
% mmc.setCircularBufferMemoryFootprint(4000);
mmc.stopSequenceAcquisition();
mmc.clearCircularBuffer();
% setup parameter

% lh = addlistener(s,'DataRequired', ...
%     @(src,event) mmc.stopSequenceAcquisition());

intervalMs=1e3/s.Rate;%-mmc.getExposure();
numImages=length(stacks);
mmc.prepareSequenceAcquisition(cameralabel);
mmc.initializeCircularBuffer();


imgsq=int16(zeros(height*width,length(stacks)));
s.startBackground;
mmc.startSequenceAcquisition(cameralabel,numImages,intervalMs,1);
while mmc.isSequenceRunning
    img=mmc.getLastImage();
    width = mmc.getImageWidth();
    height = mmc.getImageHeight();
    if mmc.getBytesPerPixel == 2
        pixelType = 'uint16';
    else
        pixelType = 'uint8';
    end
    img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
    img = reshape(img, [width, height]); % image should be interpreted as a 2D array
    img = transpose(img);                % make column-major order for MATLAB
    % imshow(img);
    imagesc(img,[0 800]);colormap gray;axis image;axis off
    drawnow;
end
% grab frame
mmc.getRemainingImageCount()
istack=0;
while mmc.getRemainingImageCount()>0
    istack=istack+1;
    imgtmp=mmc.popNextImage();
    imgsq(:,istack)=imgtmp;
end
%%
% convert data
img3=int16(zeros(height,width,length(stacks)));
for ii=1:length(stacks)
%     clf
%     img = typecast(imgsq(:,i), pixelType);      % pixels must be interpreted as unsigned integers
    img = reshape(img, [width, height]); % image should be interpreted as a 2D array
    img = transpose(img);                % make column-major order for MATLAB
    img3(:,:,ii)=img;
%     imagesc(img);
%     
%     axis image;axis off; colormap gray;
    %    pause(.01);
%     drawnow;
end
end
%% save data
t=clock;
save(['image_',num2str(t(1)),'_',num2str(t(2)),'_',num2str(t(3)),'_',...
    num2str(t(4)),'_',num2str(t(5))],'img3');

%% save data to tiff stack
imgs=uint16(img3);
imwrite(imgs(:,:,1), 'stack.tif')
for k = 2:size(imgs,3)
    imwrite(imgs(:,:,k), 'stack.tif', 'writemode', 'append');
end

%%
% convert data
% img3=int16(zeros(height,width,length(stacks)));
% for ii=1:length(stacks)
%     clf
%     img = typecast(imgsq(:,i), pixelType);      % pixels must be interpreted as unsigned integers
%     img = reshape(img, [width, height]); % image should be interpreted as a 2D array
%     img = transpose(img);                % make column-major order for MATLAB
%     img3(:,:,ii)=img;
    imagesc(squeeze(img3(:,:,45)));
    axis image;axis off; colormap gray;
       pause(.01);
    drawnow;
% end
% buffer_not_empty=true;
% i=0;
% while buffer_not_empty
%     i=i+1
%     imgtmp=mmc.getLastImage();
%     if length(imgtmp)>1
%         %save image to stack
%         mmc.popNextImage();
%     else
%         buffer_not_empty=false;
%     end
% end


%% LIVE stack test
% s.Rate=3; %Hz
% s.IsContinuous=0; % continuous writing
% % data
% stacks=1:3:60;
% data=stacks*volts_per_pix;
% data=reshape(data,length(data),1);
% 
% % lh = addlistener(s,'DataRequired', ...
% %     @(src,event) src.queueOutputData(data));
% % 
% s.queueOutputData(data);
% s.startBackground;
% 
% f=figure('Position',[0 50 1000 900]);
% while ishandle(f)
%     mmc.snapImage();
%     img = mmc.getImage();
%     width = mmc.getImageWidth();
%     height = mmc.getImageHeight();
%     if mmc.getBytesPerPixel == 2
%         pixelType = 'uint16';
%     else
%         pixelType = 'uint8';
%     end
%     img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
%     img = reshape(img, [width, height]); % image should be interpreted as a 2D array
%     img = transpose(img);                % make column-major order for MATLAB
%     % imshow(img);
%     imagesc(img);colormap gray;axis image;axis off
%     drawnow;
%     %     pause(.3);
% end
% s.stop;
% lh.delete;
