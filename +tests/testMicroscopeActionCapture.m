import YMicroscope.*

mc = Microscope();

%%
clc
close all
ax=axes();
act = MicroscopeActionCapture('Capture', mc, ax);
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