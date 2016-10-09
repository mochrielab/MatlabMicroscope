
function setLightsource(obj,str)
% select light source with index
% can only set a single source
% add support for multiple setting later

% check if string or numeric
if ischar(str)
    value=find(strcmp(str,{obj.lightsources.label}));
elseif isnumeric(str)
    value = str;
end
% set value
try
    obj.lightsource = obj.lightsources(value);
    obj.camera.setExposure(...
        obj.lightsources(value).exposure);
catch
    throw(MException('Microscope:IlluminationNotSupported',...
        ['illumination mode not supported for ',str]))
end
end