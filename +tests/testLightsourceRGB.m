import YMicroscope.*
lsrc = LightsourceRGB('com6', 'brightfield');
display('MVI RGB light successfully loaded');

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
%% set color
% pause(2)
for i = 1:length(lsrc.color_options)
    color = lsrc.color_options{i};
    lsrc.setColor(color);
    display(['set color successfully ', color]);
%     pause(1)
end
%% turn off
lsrc.turnOff();
display('successfully turned off go check light and press enter');
if lsrc.ison == 1
    error('ison should be 0')
end
% pause;
%% delete
delete(lsrc)