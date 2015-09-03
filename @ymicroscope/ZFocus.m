function [  ] = ZFocus( obj, varargin )
% z focus based on a zstack of image

if nargin == 1
    update_button = 0;
elseif nargin == 3
    update_button = 1;
    hobj = varargin{1};
    event = varargin{2};
else
    warning('wrong number of input variables');
end

if update_button
    set(hobj,'String','Focusing')
end

img_3d = obj.Zscan;
obj.GotoZCenter(img_3d);

if update_button
    set(hobj,'String','Focus')
end

end


