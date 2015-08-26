% obj.mm.getCameraDevice
% obj.mm.setCameraDevice(cameLabel)
obj.mm.setProperty('Andor sCMOS Camera', 'TriggerMode', 'External');
% double the clock frequency, trigger camera using ttl
%%
properties = obj.mm.getDevicePropertyNames('Andor sCMOS Camera');
for i=1:properties.size
    display(properties.get(i-1));
end

value = obj.mm.getAllowedPropertyValues('Andor sCMOS Camera', 'TriggerMode')
value = obj.mm.getAllowedPropertyValues('Andor sCMOS Camera', 'Sensitivity/DynamicRange');
value.get(2);
value = obj.mm.getAllowedPropertyValues('Andor sCMOS Camera', 'Ext (Exp) Trigger Timeout[ms]');
value.get(1);

value = obj.mm.getAllowedPropertyValues('Andor sCMOS Camera', 'TransposeXY');
value.get(1);
obj.mm.getProperty('Andor sCMOS Camera','TransposeXY')
obj.mm.setProperty('Andor sCMOS Camera','TransposeXY',0)

