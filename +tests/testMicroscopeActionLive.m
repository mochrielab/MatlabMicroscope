import YMicroscope.*

mc = Microscope();

%%
clc
close all
% mc.setLightsource(1)
mc.getLightsource().setColor('White')
mc.getLightsource().setIntensity(5);
% pause(0.2)
ax=axes();
% delete(act)
act = MicroscopeActionLive('Live', mc, ax);
act.run();
%
try
    mc.unlock(act)
end
delete(act)
close all
%%
delete(mc)

%