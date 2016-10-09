import YMicroscope.*

mc = Microscope();

%%
clc
close all
ax=axes();colormap gray; axis image;
act = MicroscopeActionCapture(mc, ax);
img = act.run();
%
try
    mc.unlock(act)
end
delete(act)
% close all
%%
delete(mc)

%