function [  ] = ZFocus( obj, varargin )
% z focus based on a zstack of image

if strcmp(obj.status,'standing')

if nargin == 1
    UI_enabled = 0;
elseif nargin == 3
    UI_enabled = 1;
    hobj = varargin{1};
    event = varargin{2};
else
    warning('wrong number of input variables');
end

img=obj.Capture(hobj,event);

if UI_enabled
    set(hobj,'String','Focusing')
end

img_3d = obj.Zscan;

obj.GotoZCenter(img_3d);

img=obj.Capture(hobj,event);

if UI_enabled
    set(hobj,'String','Focus')
end

else
    msgbox(['microscope status: ',obj.status]);
end

end


