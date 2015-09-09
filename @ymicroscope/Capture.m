function [ img ] = Capture( obj, varargin )
% capture of an image already exist in live

if nargin == 1
    UI_enabled = 0;
elseif nargin == 3
    UI_enabled = 1;
    hobj = varargin{1};
    event = varargin{2};
else
    warning('wrong number of input variables');
end

if nargout == 0
    savedata = 1;
elseif nargout == 1
    savedata = 0;
else
    error('wrong number of output')
end

if strcmp(obj.status,'standing') 
    obj.SwitchLight('on');
    obj.mm.setExposure(obj.exposure);    
    if UI_enabled
        axes(obj.imageaxis_handle);
    end
    andorCam = 'Andor sCMOS Camera';
    obj.mm.setProperty(andorCam, 'TriggerMode', 'Software (Recommended for Live Mode)'); % set exposure to external
    obj.mm.snapImage();
    img = obj.mm.getImage();
    
    width = obj.mm.getImageWidth();
    height = obj.mm.getImageHeight();

    img = reshape(img, [width, height]); % image should be interpreted as a 2D array
%     img = transpose(img);                % make column-major order for MATLAB
    if UI_enabled
        % plot
        cla %clear current axis
        imagesc(img);colormap gray;axis image;axis off
        drawnow;
    end
    obj.SwitchLight('off');
else
    if UI_enabled
        img=getimage(obj.imageaxis_handle);
    else
        img=[];
        warning('can''t capture while running')
    end
end

% save data
if savedata
    filename=obj.GetFileHeader('capture');
    imgtif=Tiff(filename,'a');
    tagstruct = obj.GetImageTag('Andor Zyla 5.5');
    imgtif.setTag(tagstruct);
    imgtif.write(img);
    imgtif.close;
    
    %save setting
    setting=obj.GetSetting;
    save([filename(1:end-3),'mat'],'setting');
    display('image captured')
end
end