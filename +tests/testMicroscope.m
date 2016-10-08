import YMicroscope.*

mc = Microscope();

%%
for status = mc.status_options
    mc.setStatus(status{1})
    display(['set status ',status{1}])
end

%%
mc.switchLight('on')
display('light on')
mc.switchLight('off')
display('light off')
%%
mc.setIllumination(1)
display('set illumination 1')
mc.setIllumination(2)
display('set illumination 2')
%% 
delete(mc)