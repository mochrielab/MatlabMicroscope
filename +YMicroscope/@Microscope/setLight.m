% switch the light on or off
function setLight(obj, mode)
% mode for both numeric and char
if isnumeric(mode)
    try
        mode = obj.lighton_options{mode};
    catch
        throw(MException('Microscope:setLightOn',...
            'unrecognized LightonOption'));
    end
elseif ischar(mode)
    if sum(strcmp(mode, obj.lighton_options)) ~= 1
        throw(MException('Microscope:setLightOn',...
            'unrecognized LightonOption'));
    end
else
    throw(MException('Microscope:setLightOn',...
        'unrecognized LightonOption'));
end
% set mode
obj.lighton=mode;
% set trigger for light source
obj.trigger.setLightsources([obj.getLightsource]);
% check mode
switch mode
    case 'always on'
        obj.getLightsource.turnOn;
        singleTrigger(obj.trigger, obj.zstage.zoffset, 1);
    case 'minimal exposure'
        obj.getLightsource.turnOn;
        
        singleTrigger(obj.trigger, obj.zstage.zoffset, 0)
    case 'off'
        obj.getLightsource.turnOff;
        singleTrigger(obj.trigger, obj.zstage.zoffset, 0)
end
end