function [ img ] = Capture( obj, varargin )
% capture of an image already exist in live

if nargin == 1
    update_button = 0;
elseif nargin == 3
    update_button = 1;
    hobj = varargin{1};
    event = varargin{2};
else
    warning('wrong number of input variables');
end

if strcmp(obj.status,'standing') 
    obj.SwitchLight('on');
    obj.mm.setExposure(obj.exposure);    
    axes(obj.imageaxis_handle);
    andorCam = 'Andor sCMOS Camera';
    obj.mm.setProperty(andorCam, 'TriggerMode', 'Software (Recommended for Live Mode)'); % set exposure to external
    obj.mm.snapImage();
    img = obj.mm.getImage();
    
    width = obj.mm.getImageWidth();
    height = obj.mm.getImageHeight();

    img = reshape(img, [width, height]); % image should be interpreted as a 2D array
%     img = transpose(img);                % make column-major order for MATLAB
    % plot
    cla %clear current axis
    imagesc(img);colormap gray;axis image;axis off
    drawnow;
    obj.SwitchLight('off');
else
    img=getimage(obj.imageaxis_handle);
end

% save data
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