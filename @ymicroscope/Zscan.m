function [ img3 ] = Zscan( obj, hobj,event )
% do a zscan
magic_number = 4.4;
if obj.exposure + magic_number >= 1000/obj.framerate
    msgbox('error: exposure is longer than the frame interval')
elseif strcmp(obj.status,'standing')
    obj.status = 'zstack_running';
    set(hobj,'String','Zstack Running')
    pause(.01)

    % set scanning parameters
    stacks =(-(obj.numstacks-1)/2:(obj.numstacks-1)/2)*obj.stepsize; % stack position
    width = obj.mm.getImageWidth(); % image width
    height = obj.mm.getImageHeight(); % image height
    numstacks=length(stacks);

    % initialize ni daq
    rate_multiplier = 2;
    obj.nidaq.Rate=obj.framerate * rate_multiplier; % set data acuisition rate
    obj.nidaq.IsContinuous=0; % continuous writing

    % prepare data to send
    zdata=stacks*obj.volts_per_pix+obj.dataoffset; % data to send
    numdata = length(zdata); % length and data
    zdata = reshape(ones(rate_multiplier,1)*zdata,...
        rate_multiplier*numdata,1); % data for z scan at clock rate
    camtrigger = reshape([1;zeros(rate_multiplier-1,1)]*ones(1,numdata),...
        rate_multiplier*numdata,1); % trigger for camera
    obj.nidaq.queueOutputData([zdata,camtrigger])

    % log piezo position
    piezopos = zeros(size(zdata));
    counter = 0;
    data_pointer = libpointer('doublePtr',piezopos);
    counter_pointer = libpointer('doublePtr',counter);
    lh = addlistener(obj.nidaq,'DataAvailable',... % remember to delete pointer
        @(src,event)Nidaq_Data_log(src,event,data_pointer,counter_pointer));
        
    % camera setting (take 4 seconds!)
    andorCam = 'Andor sCMOS Camera';
    obj.mm.setProperty(andorCam, 'TriggerMode', 'External'); % set exposure to external
    obj.mm.setExposure(obj.exposure); % set exposure time, ????? work or not
    obj.mm.clearCircularBuffer(); % clear the buffer for image storage
    
    %image type
    if obj.mm.getBytesPerPixel == 2
        pixelType = 'uint16';
    else
        pixelType = 'uint8';
    end
    
    % prepare data acquisition
    obj.mm.initializeCircularBuffer();
    obj.mm.prepareSequenceAcquisition(andorCam);

    % start acquisition
    obj.mm.startContinuousSequenceAcquisition(0);
    obj.nidaq.startBackground;    

    % live in background
    while obj.nidaq.IsRunning 
        img=obj.mm.getLastImage();
        img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
        img = reshape(img, [width, height]); % image should be interpreted as a 2D array
        img = transpose(img);                % make column-major order for MATLAB
        axes(obj.imageaxis_handle);cla;
        imagesc(img);colormap gray;axis image;axis off
        drawnow;
    end
    
    % warning for buffer overflow
    if obj.mm.isBufferOverflowed 
        warning('camera buffer over flowed, try set larger memory for the camera');
    end
    display(['number of images in buffer: ',...
        num2str(obj.mm.getRemainingImageCount())]);

    % ending acquisition
    obj.nidaq.outputSingleScan([obj.dataoffset,0]); % reset starting position
    obj.nidaq.stop;
    delete(lh);
    obj.mm.stopSequenceAcquisition;

    set(hobj,'String','prepare Saving')
    pause(.01)
    % grab frame (take 0.7 second)
    istack=0;
    img3=uint16(zeros(height,width,numstacks));
    while obj.mm.getRemainingImageCount()>0
        istack=istack+1;
        imgtmp=obj.mm.popNextImage();
        img = reshape(imgtmp, [width, height]);
        img3(:,:,istack)=img';
    end
    set(hobj,'String','Zstack Saving')
    pause(.01)
    
    
    % save data
    tic
    t=clock;
    datepath=fullfile(obj.datasavepath,...
        [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',num2str(t(1))]);
    if ~exist(datepath)
        mkdir(datepath);
    end
        
    IllumMode = obj.illumination_mode;
    Exposure = obj.exposure;
    DispSize = obj.display_size;
    FrameRate = obj.framerate;
    NumbStacks = obj.numstacks;
    StepSize = obj.stepsize;
    
    save(fullfile(datepath,['zstack_',...
        num2str(t(4),'%02d'),'_',num2str(t(5),'%02d'),'_',...
        num2str(round(t(6)),'%02d')])...
        ,'IllumMode','Exposure','DispSize','FrameRate','NumbStacks'...
        ,'StepSize','img3');

    fid=fopen([obj.datasavepath2,filesep,'ImgLog.txt'],'a+');
    fprintf(fid, '%10s %15s %20s %20d %20s %20d %20d %20d \r\n',...
        [num2str(t(2),'%02d'),'\',num2str(t(3),'%02d'),'\',num2str(t(1))],...
        [num2str(t(4),'%02d'),':',num2str(t(5),'%02d'),':',...
        num2str(round(t(6)),'%02d')],obj.illumination_mode,...
        obj.exposure,obj.display_size,obj.framerate,obj.numstacks,obj.stepsize);
    fclose(fid);
    set(hobj,'String','Zstack')
    toc
    
    obj.status = 'standing';
else
    msgbox(['error: microscope is ',obj.status]);
end

end


