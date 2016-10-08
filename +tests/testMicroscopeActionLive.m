import YMicroscope.*

mc = Microscope();

%%
clc
close all
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