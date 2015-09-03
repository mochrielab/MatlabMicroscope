function [  ] = Movie_ZstackAutoFocus( obj, varargin )
% movie of zstack with auto focusing
% should be used for long movies with long intervals

if nargin == 1
    UI_enabled = 0;
elseif nargin == 3
    UI_enabled = 1;
    hobj = varargin{1};
    event = varargin{2};
else
    warning('wrong number of input variables');
end

obj.status = 'movie_running_zstack_autofocus';

if UI_enabled
    set(hobj,'String','Prepare Movie');
    pause(.01)
else
    display('Start Movie');
end

% prepare for save
filename=obj.GetFileHeader('movie');
imgtif=Tiff(filename,'w8');
tagstruct = obj.GetImageTag('Andor Zyla 5.5');

% set scanning parameters
stacks =(-(obj.numstacks-1)/2:(obj.numstacks-1)/2)*obj.stepsize; % stack position
width = obj.mm.getImageWidth(); % image width
height = obj.mm.getImageHeight(); % image height

% initialize ni daq
rate_multiplier = 2;
obj.nidaq.Rate=obj.framerate * rate_multiplier; % set data acquisition rate
obj.nidaq.IsContinuous=0; % continuous writing
% add listener
lh = addlistener(obj.nidaq,'DataAvailable',... % remember to delete pointer
    @(src,event)1);



% camera setting 
andorCam = 'Andor sCMOS Camera';
obj.mm.setProperty(andorCam, 'TriggerMode', 'External'); % set exposure to external
obj.mm.setExposure(obj.exposure); % 
obj.mm.clearCircularBuffer(); % clear the buffer for image storage
obj.mm.initializeCircularBuffer();
obj.mm.prepareSequenceAcquisition(andorCam);
obj.mm.startContinuousSequenceAcquisition(0);

% img_3d for z focus
img_3d = zeros(width,height,obj.numstacks);
for iloop=1:obj.movie_cycles
    if strcmp(obj.status,'movie stopping')
        break;
    end
    
    if UI_enabled
        set(hobj,'String',['Stop at ',num2str(iloop)]);
        pause(.01)
    else
        display(['Movie cycle ',num2str(iloop)])
    end
    
    % prepare data to send
    zdata=stacks*obj.volts_per_pix+obj.zoffset; % data to send
    numdata = length(zdata); % length and data
    zdata = reshape(ones(rate_multiplier,1)*zdata,...
        rate_multiplier*numdata,1); % data for z scan at clock rate
    camtrigger = reshape([0;1+zeros(rate_multiplier-1,1)]*ones(1,numdata),...
        rate_multiplier*numdata,1); % trigger for camera

    % send data
    obj.SwitchLight('on');
    obj.nidaq.queueOutputData([zdata,camtrigger;obj.zoffset,0])
    obj.nidaq.startBackground;
    istack=0;

    % live in background
    while obj.nidaq.IsRunning
        if UI_enabled
            img=obj.mm.getLastImage();
            img = reshape(img, [width, height]); % image should be interpreted as a 2D array
            axes(obj.imageaxis_handle);cla;
            imagesc(img);colormap gray;axis image;axis off
            drawnow;
        end
        if obj.mm.getRemainingImageCount()>0
            istack=istack+1;
            imgtmp=obj.mm.popNextImage();
            img = reshape(imgtmp, [width, height]);
            img_3d(:,:,istack) = double(img);
            imgtif.setTag(tagstruct);
            imgtif.write(img);
            imgtif.writeDirectory;
        end
        pause(.01)
    end
    
    % warning for buffer overflow
    if obj.mm.isBufferOverflowed
        warning('camera buffer over flowed, try set larger memory for the camera');
    end
    
    % ending acquisition
    obj.nidaq.stop;
    obj.SwitchLight('off');
    
    % save data
    while obj.mm.getRemainingImageCount()>0
        istack=istack+1;
        imgtmp=obj.mm.popNextImage();
        img = reshape(imgtmp, [width, height]);
        img_3d(:,:,istack) = double(img);
        imgtif.setTag(tagstruct);
        imgtif.write(img);
        imgtif.writeDirectory;
    end
    
    if istack~=obj.numstacks
    warning(['number of images collected: ',...
        num2str(istack)]);
    end
    %% Autofocusing section
    
    obj.GotoZCenter(img_3d);
    
    %% pause
    for ipause =1:60*obj.movie_interval
        if strcmp(obj.status,'movie stopping')
            break
        end
        pause(1);
    end
end
% close the image saving
imgtif.close();
delete(lh);
obj.mm.stopSequenceAcquisition;

%save setting
setting=obj.GetSetting;
save([filename(1:end-3),'mat'],'setting');
if UI_enabled
    set(hobj,'String','Start Movie')
else
    display('Movie end');
end
obj.status = 'standing';

end