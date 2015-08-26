function [ img3 ] = Zscan( obj, hobj,event )
% do a zscan

magic_number = 0; % guessing the milli second take to stablily wrap up exposure

if obj.exposure + magic_number >= 1000/obj.framerate
    msgbox('error: exposure is longer than the frame interval')
elseif strcmp(obj.status,'standing')
    obj.status = 'zstack_running';
    obj.SwitchLight('on');
    set(hobj,'String','Zstack Running')
    pause(.01)

    % set scanning parameters
    stacks =(-(obj.numstacks-1)/2:(obj.numstacks-1)/2)*obj.stepsize; % stack position
    width = obj.mm.getImageWidth(); % image width
    height = obj.mm.getImageHeight(); % image height
    
    % initialize ni daq
    rate_multiplier = 2;
    obj.nidaq.Rate=obj.framerate * rate_multiplier; % set data acuisition rate
    obj.nidaq.IsContinuous=0; % continuous writing

    % prepare data to send
    zdata=stacks*obj.volts_per_pix+obj.zoffset; % data to send
    numdata = length(zdata); % length and data
    zdata = reshape(ones(rate_multiplier,1)*zdata,...
        rate_multiplier*numdata,1); % data for z scan at clock rate
    camtrigger = reshape([0;1+zeros(rate_multiplier-1,1)]*ones(1,numdata),...
        rate_multiplier*numdata,1); % trigger for camera
%     camtrigger = reshape([1;zeros(rate_multiplier-1,1)]*ones(1,numdata),...
%         rate_multiplier*numdata,1); % trigger for camera
    
    obj.nidaq.queueOutputData([zdata,camtrigger;zdata(end),0])
%     obj.nidaq.queueOutputData([zdata,camtrigger;zdata(end),1])

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
    
    % prepare data acquisition
    obj.mm.initializeCircularBuffer();
    obj.mm.prepareSequenceAcquisition(andorCam);

    % start acquisition
    obj.mm.startContinuousSequenceAcquisition(0);
    obj.nidaq.startBackground;    

    % save data header
    t=clock;
    istack=0;
    datepath=fullfile(obj.datasavepath,...
        [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',num2str(t(1))]);
    if ~exist(datepath)
        mkdir(datepath);
    end
    filename=fullfile(datepath,['zstack_',...
        num2str(t(4),'%02d'),'_',num2str(t(5),'%02d'),'_',...
        num2str(round(t(6)),'%02d'),'.tif']);
    imgtif=Tiff(filename,'w8');
    tagstruct = obj.GetImageTag('Andor Zyla 5.5');
    
    % live in background
    while obj.nidaq.IsRunning 
        img=obj.mm.getLastImage();
        img = reshape(img, [width, height]); % image should be interpreted as a 2D array
        axes(obj.imageaxis_handle);cla;
        imagesc(img);colormap gray;axis image;axis off
        if obj.mm.getRemainingImageCount()>0
            istack=istack+1;
            imgtmp=obj.mm.popNextImage();
            img = reshape(imgtmp, [width, height]);
            imgtif.setTag(tagstruct);
            imgtif.write(img);
            imgtif.writeDirectory;
        end
        drawnow;
    end
    tic

    % warning for buffer overflow
    if obj.mm.isBufferOverflowed 
        warning('camera buffer over flowed, try set larger memory for the camera');
    end

    % ending acquisition
    obj.nidaq.outputSingleScan([obj.zoffset,0]); % reset starting position
    obj.nidaq.stop;
    delete(lh);
    obj.mm.stopSequenceAcquisition;
    obj.SwitchLight('off');
%   display(['number of images in buffer: ',...
%         num2str(obj.mm.getRemainingImageCount)]);
    
    % continue to save
    set(hobj,'String','Zstack Saving')
    pause(.01)
    while obj.mm.getRemainingImageCount()>0
        istack=istack+1;
        imgtmp=obj.mm.popNextImage();
        img = reshape(imgtmp, [width, height]);
        imgtif.setTag(tagstruct);
        imgtif.write(img);
        imgtif.writeDirectory;   
    end
    imgtif.close();
    toc
    
    display(['number of images in collected: ',...
        num2str(istack)]);  
    
    set(hobj,'String','Zstack')    
    obj.status = 'standing';
else
    msgbox(['error: microscope is ',obj.status]);
end

end


