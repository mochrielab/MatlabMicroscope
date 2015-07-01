% obj.mm.getCameraDevice
% obj.mm.setCameraDevice(cameLabel)
obj.mm.setProperty('Andor sCMOS Camera', 'TriggerMode', 'External');
% double the clock frequency, trigger camera using ttl
%%
properties = obj.mm.getDevicePropertyNames('Andor sCMOS Camera');
for i=1:properties.size
    display(properties.get(i-1));
end

value = obj.mm.getAllowedPropertyValues('Andor sCMOS Camera', 'TriggerMode');