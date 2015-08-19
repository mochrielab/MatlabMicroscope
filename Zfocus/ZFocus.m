function [ obj ] = ZFocus( obj, hobj,event )
% autofocus z direction
if obj.exposure >= 1000/obj.framerate
    msgbox('error: exposure is longer than the frame interval')
elseif strcmp(obj.status,'standing')
    obj.status = 'zstack_running';
    set(hobj,'String','Zstack Running')
    pause(.01)

    % set scan parameters
    stacks=(-(obj.numstacks-1)/2:(obj.numstacks-1)/2)*obj.stepsize; %stack position
    width = obj.mm.getImageWidth(); %image width
    height = obj.mm.getImageHeight(); %image height
    numstacks=length(stacks); %number of stacks
    
    % initialize NI Daq
    rate_multiplier = 2;
    obj.nidaq.Rate=obj.framerate * rate_multiplier; %set data acquisition rate (Hz)
    obj.nidaq.IsContinuous=0; %continuous writing
    
    % prepare data to send
    zdata = stacks*obj.volts_per_pix + obj.dataoffset; %data to send
    numdata = length(zdata); %length of data
    zdata = reshape(ones(rate_multiplier,1)*zdata,...
        rate_multiplier*numdata,1); %data for z scan at clock rate
    camtrigger = reshape([1;zeros(rate_multiplier-1,1)] * ones(1,numdata),...
        rate_multiplier*numdata,1); %trigger for camera
    obj.nidaq.queueOutputData([zdata,camtrigger])
    
    % log piezo position
    piezopos = zeros(size(zdata));
    counter = 0;
    data_pointer = libpointer('doublePtr',piezopos);
    counter_pointer = libpointer('doublePtr',counter);
    lh = addlistener(obj.nidaq,'DataAvailable',... %remember to delete pointer
        @(src,event)Nidaq_Data_log(src,event,data_pointer,counter_pointer));
    
    % camera setting (take 4 seconds!)
    andorCam = 'Andor sCMOS Camera';
    obj.mm.setProperty(andorCam, 'TriggerMode', 'External'); %set exposure to external
    obj.mm.setExposure(obj.exposure);
    obj.mm.clearCircularBuffer();
    
    % image type
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
    while obj.mm.nidaq.IsRunning
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
        warning('camera buffer over-flowed, try to set larger memory for the camera');
    end
    display(['number of images in buffer: ',...
        num2str(obj.mm.getRemainingImageCount())]);
    
    % ending acquisition
    obj.nidaq.outputSingleScan([obj.dataoffset,0]); %reset starting position
    obj.nidaq.stop;
    delet(lh);
    obj.mm.stopSequenceAcquisition;
    
    set(hobj,'String','Grabbing images');
    pause(0.01);
    
    % grab frame (takes ~0.7 seconds)
    istack=0;
    img3=uint16(zeros(height,width,numstacks));
    while obj.mm.getRemainingImageCount()>0
        istack=istack+1;
        imgtmp=obj.mm.popNextImage();
        img = reshape(imgtmp, [width, height]);
        img3(:,:,istack)=img';
    end
    set(hobj,'String','Focusing');
    pause(0.01);

%% auto-focusing
    % Sum of Squares of Gradients of Each Image using Sobel method
    Nframes = size(img3,3);
    
    SumSqGrad = ImgGrad(Nframes,img3); %function that will find the sum
    %of the square of the gradients of each stack image
    
    % Fit curve with Lorentzian
    FocusLoc = LorentzPkFit(Nframes,SumSqGrad);
    %func returns max of fit, which is assumed to be location of in-focus plane
    
%% new addition microscope-specific
    startLoc = round(numstacks/2); %initial starting location
    stkDiff = startLoc - FocusLoc; %how many levels apart the in-focus plane is
    %from the current plane
    
    %What is the distance from one plane to another? How many volts does this
    %correspond to?
    TotVolts = stkDiff.*obj.volts_per_pix;
    data2 = obj.dataoffset+TotVolts;
    %feed this value to the piezo stage so that it will move in response to
    %this voltage 
    
    %%% Look at this!!! 06/04/15: Need to do the following???
    % Move the stage and then reset obj.dataoffset to 1?
    if data2 <= 0
        obj.dataoffset=0;
        warning('dataoffset goes below zero');
        msgbox('Data offset was negative!');
    elseif data2 >= 10
        obj.dataoffset=10;
        warning('dataoffset goes above ten');
        msgbox('Data offset was greater than 10V!');
    else
        obj.dataoffset=data2;
        obj.nidaq.outputSingleScan([obj.dataoffset,0]); % ** 07/21/15

    end
    
    %reset dataoffset to 1
%     obj.dataoffset = 1;
%%
    set(hobj,'String','Focus');
        
    obj.status = 'standing';
else
    msgbox(['error: microscope is ',obj.status]);
end
end