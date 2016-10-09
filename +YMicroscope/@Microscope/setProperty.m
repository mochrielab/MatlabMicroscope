% set property value
function didset=setProperty(obj,name, value)
% set properties for the devices and processes
% name is space separated

try
    % name is space seperated for device and property
    names=strsplit(name,' ');
    devicename=names{1};
    propname=names{2};
    handle=obj.getDeviceHandle(devicename);
    handle.(['set',captalize(propname)])(value);
catch exception
    warning(['error setProperty:',exception.message])
    didset=false;
end
    function Name=captalize(name)
        Name=[upper(name(1)),lower(name(2:end))];
    end
end