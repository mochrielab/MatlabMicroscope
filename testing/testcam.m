% obj.mm.getCameraDevice
% obj.mm.setCameraDevice(cameLabel)
obj.mm.setProperty('Andor sCMOS Camera', 'TriggerMode', 'External');
% double the clock frequency, trigger camera using ttl
%%
properties = obj.mm.getDevicePropertyNames('Andor sCMOS Camera');
for i=1:properties.size
    property_name = properties.get(i-1);
    display(['property name: ',char(property_name)]);
    value = obj.mm.getAllowedPropertyValues('Andor sCMOS Camera', property_name);
    for ii=0:value.size-1
        display(['value ',num2str(ii),': ',char(value.get(ii))])
    end
    if value.size == 0
        display('empty')
    end
    disp(['current value is: ',...
        char(obj.mm.getProperty('Andor sCMOS Camera',property_name))]);
    fprintf('\n\n')
end
%%
value = obj.mm.getAllowedPropertyValues('Andor sCMOS Camera', 'TriggerMode')
value = obj.mm.getAllowedPropertyValues('Andor sCMOS Camera', 'Sensitivity/DynamicRange');
value.get(2);
value = obj.mm.getAllowedPropertyValues('Andor sCMOS Camera', 'Ext (Exp) Trigger Timeout[ms]');
value.get(1);

value = obj.mm.getAllowedPropertyValues('Andor sCMOS Camera', 'TransposeXY');
value.get(1);
obj.mm.getProperty('Andor sCMOS Camera','TransposeXY')
obj.mm.setProperty('Andor sCMOS Camera','TransposeXY',0)

%%

value = obj.mm.getAllowedPropertyValues('Andor sCMOS Camera', 'FanSpeed');
obj.mm.setProperty('Andor sCMOS Camera','FanSpeed','On')
