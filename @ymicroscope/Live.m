function [  ] = Live( obj,varargin )
%show live image

if nargin == 1
    update_button = 0;
elseif nargin == 3
    update_button = 1;
    hobj = varargin{1};
    event = varargin{2};
else
    warning('wrong number of input variables');
end

if strcmp(obj.status,'live_running')
    if update_button
        set(hobj,'String','Start Live');
    end
    obj.status = 'standing';
    obj.SwitchLight('off');
elseif strcmp(obj.status,'standing')
    if update_button
        set(hobj,'String','Stop Live');
    end
    obj.status = 'live_running';
    obj.SwitchLight('on');
    % set camera to be triggered by the computer
    obj.nidaq.outputSingleScan([obj.zoffset, 0]);
    andorCam = 'Andor sCMOS Camera';
    obj.mm.setProperty(andorCam, 'TriggerMode', 'Software (Recommended for Live Mode)'); % set exposure to external
    while strcmp(obj.status,'live_running')
        try
            obj.mm.setExposure(obj.exposure);
            obj.mm.snapImage();
            img = obj.mm.getImage();
            width = obj.mm.getImageWidth();
            height = obj.mm.getImageHeight();

            img = reshape(img, [width, height]); % image should be interpreted as a 2D array
            % plot
            axes(obj.imageaxis_handle);
            cla
            imagesc(img);colormap gray;axis image;axis off
            drawnow;
        catch error
            axes(obj.imageaxis_handle);
            cla
            imagesc(0);colormap gray;axis image;axis off
            drawnow;
            warning(['error in live: ',error.identifier]);
        end
    end
else
    msgbox(['error: microscope is ',obj.status]);
end



end


