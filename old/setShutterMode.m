function [  ] = setShutterMode( obj,str )
%set camera shutter mode

if strcmp(str,'Global')
    obj.mm.setProperty('Andor sCMOS Camera','ElectronicShutteringMode','Global');
elseif strcmp(str,'Rolling')
    obj.mm.setProperty('Andor sCMOS Camera','ElectronicShutteringMode','Rolling');
else
    warning('unsupported mode');
end

end

