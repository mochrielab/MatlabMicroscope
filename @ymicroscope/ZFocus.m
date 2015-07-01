function [ obj ] = ZFocus( obj, hobj,event )
% autofocus z direction
if obj.is_live_running || obj.is_movie_running || obj.is_zstack_runnning || obj.is_focusing
    msgbox('Can not start because other process running');
else
    set(hobj,'String','Finding Focal Plane')

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
    data2=stacks*obj.volts_per_pix+obj.dataoffset;
    data2=reshape(data2,length(data2),1);
    queueOutputData(obj.nidaq,data2)
    
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
        obj.nidaq.outputSingleScan(obj.dataoffset);
    end
    
    %reset dataoffset to 1
%     obj.dataoffset = 1;
%%
    set(hobj,'String','Focus');
end
end