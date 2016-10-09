% get property value
function value=getProperty(obj,tag)
% get property based an space separated tag

try
    names=strsplit(tag,' ');
    devicename=names{1};
    propname=names{2};
    handle=obj.getDeviceHandle(devicename);
    value=handle.(propname);
catch exception
    warning(['error getProperty:',exception.message])
    value=[];
end
end