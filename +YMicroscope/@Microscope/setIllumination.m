% set illumination
function setIllumination(obj, str)
% set to string
if isnumeric(str)
    try
        obj.illumination = obj.illumination_options{str};
    catch
        throw(MException('Microscope:set.illumination',...
            ['unrecognizable value', str]));
    end
elseif ischar(str)
    if sum(strcmp(str, obj.illumination_options)) == 1
        obj.illumination = str;
    end
else
    throw(MException('Microscope:set.illumination',...
        ['unrecognizable value', str]));
end
% set light bulb
names = strsplit(obj.illumination, ' - ');
obj.lightsource.turnOff();
obj.setLightsource(names{1});
obj.lightsource.setColor(names{2});
obj.lightsource.turnOn();

% notify
notify(obj, 'IlluminationDidSet');
end