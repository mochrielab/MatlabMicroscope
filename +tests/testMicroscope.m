import YMicroscope.*

mc = Microscope();

%%
for status = mc.status_options
    mc.setStatus(status{1})
    display(['set status ',status{1}])
end

%%
mc.setLightsource(2)
mc.lightsource
mc.setLight('always on')
display('light on')

%%
mc.setLightsource(2)
mc.setLight('off')
display('light off')
%%

mc.setLightsource(1)
% mc.getLightsource.setIntensity(5)
% mc.getLightsource.setColor('Green')
% this fucking pause is essential
% pause(.1)
mc.setLight('always on')
display('light on')

%%
mc.setLightsource(1)
mc.setLight('off')
display('light off')
%%
mc.setIllumination(1)
display('set illumination 1')
mc.setIllumination(2)
display('set illumination 2')
%% 



%%
delete(mc)