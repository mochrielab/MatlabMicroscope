function [ obj ] = Movie( obj,hobj,event )
%taking a movie

% do a movie
if obj.is_live_running || obj.is_movie_running || obj.is_zstack_runnning
    msgbox('Can not start because other process running');
end

set(hobj,'String','Movie Running')

for iloop=1:30
    %% running it first time!!
    % initialize
    obj.nidaq.Rate=obj.framerate; %Hz
    obj.nidaq.IsContinuous=0; % continuous writing
    obj.mm.setExposure(obj.exposure);
    obj.mm.setCircularBufferMemoryFootprint(4000);
    obj.mm.clearCircularBuffer();
    intervalMs=1e3/obj.nidaq.Rate;%
    stacks=(-(obj.numstacks-1)/2:(obj.numstacks-1)/2)*obj.stepsize;
    cameralabel=obj.mm.getCameraDevice;
    width = obj.mm.getImageWidth();
    height = obj.mm.getImageHeight();
    numstacks=length(stacks);
    if obj.mm.getBytesPerPixel == 2
        pixelType = 'uint16';
    else
        pixelType = 'uint8';
    end
    
    % prepare data to send
    data=stacks*obj.volts_per_pix+obj.dataoffset;
    data=reshape(data,length(data),1);
    queueOutputData(obj.nidaq,data);
    
    % prepare data acquisition
    obj.mm.prepareSequenceAcquisition(cameralabel);
    obj.mm.initializeCircularBuffer();
    
    obj.nidaq.startBackground;
    obj.mm.startSequenceAcquisition(cameralabel,numstacks,intervalMs,1);
    % live in background
    while obj.mm.isSequenceRunning
        img=obj.mm.getLastImage();
        img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
        img = reshape(img, [width, height]); % image should be interpreted as a 2D array
        img = transpose(img);                % make column-major order for MATLAB
        axes(obj.imageaxis_handle);cla;
        imagesc(img);colormap gray;axis image;axis off
        drawnow;
    end
    
    % grab frame
    display(['number of images in buffer: ',...
        num2str(obj.mm.getRemainingImageCount())]);
    istack=0;
    img3=uint16(zeros(height,width,numstacks));
    while obj.mm.getRemainingImageCount()>0
        istack=istack+1;
        imgtmp=obj.mm.popNextImage();
        img = reshape(imgtmp, [width, height]);
        img3(:,:,istack)=img';
    end
    set(hobj,'String','Zstack Saving')
    
    % ending program
    obj.nidaq.stop;
    obj.mm.stopSequenceAcquisition();
    %% Autofocusing section
    Nframes = size(img3,3);
    SumSqGrad = ImgGrad(Nframes,img3); %function that will find the sum
    FocusLoc = LorentzPkFit(Nframes,SumSqGrad);
    startLoc = round(numstacks/2); %initial starting location
    stkDiff = startLoc - FocusLoc; %how many levels apart the in-focus plane is
    TotVolts = stkDiff.*obj.volts_per_pix;
    obj.dataoffset=obj.dataoffset+TotVolts;
    
    %% runing a second time!!!
    % initialize
    obj.nidaq.Rate=obj.framerate; %Hz
    obj.nidaq.IsContinuous=0; % continuous writing
    obj.mm.setExposure(obj.exposure);
    obj.mm.setCircularBufferMemoryFootprint(4000);
    obj.mm.clearCircularBuffer();
    intervalMs=1e3/obj.nidaq.Rate;%
    stacks=(-(obj.numstacks-1)/2:(obj.numstacks-1)/2)*obj.stepsize;
    cameralabel=obj.mm.getCameraDevice;
    width = obj.mm.getImageWidth();
    height = obj.mm.getImageHeight();
    numstacks=length(stacks);
    if obj.mm.getBytesPerPixel == 2
        pixelType = 'uint16';
    else
        pixelType = 'uint8';
    end
    
    % prepare data to send
    data=stacks*obj.volts_per_pix+obj.dataoffset;
    data=reshape(data,length(data),1);
    queueOutputData(obj.nidaq,data)
    
    % prepare data acquisition
    obj.mm.prepareSequenceAcquisition(cameralabel);
    obj.mm.initializeCircularBuffer();
    
    obj.nidaq.startBackground;
    obj.mm.startSequenceAcquisition(cameralabel,numstacks,intervalMs,1);
    % live in background
    while obj.mm.isSequenceRunning
        img=obj.mm.getLastImage();
        img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
        img = reshape(img, [width, height]); % image should be interpreted as a 2D array
        img = transpose(img);                % make column-major order for MATLAB
        axes(obj.imageaxis_handle);cla;
        imagesc(img);colormap gray;axis image;axis off
        drawnow;
    end
    
    % grab frame
    display(['number of images in buffer: ',...
        num2str(obj.mm.getRemainingImageCount())]);
    istack=0;
    img3=uint16(zeros(height,width,numstacks));
    while obj.mm.getRemainingImageCount()>0
        istack=istack+1;
        imgtmp=obj.mm.popNextImage();
        img = reshape(imgtmp, [width, height]);
        img3(:,:,istack)=img';
    end
    set(hobj,'String','Zstack Saving')
    
    % ending program
    obj.nidaq.stop;
    obj.mm.stopSequenceAcquisition();
    
    %% save data
    t=clock;
    datepath=fullfile(obj.datasavepath,...
        [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',num2str(t(1))]);
    if ~exist(datepath)
        mkdir(datepath);
    end
    save(fullfile(datepath,['zstack_',...
        num2str(t(4),'%02d'),'_',num2str(t(5),'%02d'),'_',...
        num2str(round(t(6)),'%02d')])...
        ,'img3');
    
    fid=fopen([obj.datasavepath2,filesep,'ImgLog.txt'],'a+');
    fprintf(fid, '%10s %15s %20s %20d %20s %20d %20d %20d \r\n',...
        [num2str(t(2),'%02d'),'\',num2str(t(3),'%02d'),'\',num2str(t(1))],...
        [num2str(t(4),'%02d'),':',num2str(t(5),'%02d'),':',...
        num2str(round(t(6)),'%02d')],obj.illumination_mode,...
        obj.exposure,obj.display_size,obj.framerate,obj.numstacks,obj.stepsize);
    fclose(fid);
    %% pause
    
    pause(60*30);
end


set(hobj,'String','Movie')

end

