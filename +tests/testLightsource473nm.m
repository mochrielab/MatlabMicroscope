import YMicroscope.*
lsrc = Lightsource473nm(obj.trigger, 'laser473');
display('473nm laser successfully connected');

%% test exposure
for i = 0:100:400
    lsrc.setExposure(i);
    display(['exposure successfully set for ',num2str(i)]);
end
%% turn on
lsrc.turnOn();
display('successfully turned on go check light and press enter');
if lsrc.ison == 0
    error('ison should be 1')
end
% pause;
%% turn off
lsrc.turnOff();
display('successfully turned off go check light and press enter');
if lsrc.ison == 1
    error('ison should be 0')
end
% pause;
%% delete
delete(lsrc)