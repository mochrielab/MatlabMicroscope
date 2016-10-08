
import YMicroscope.*
t = TriggerNidaq();
display('created trigger')

for i = [1,10,100]
    t.setFramerate(i);
    display(['framerate successfully set for ',num2str(i)]);
end

for i = [1000,5000]
    t.setClockrate(i);
    display(['clockrate successfully set for ',num2str(i)]);
end

numcha = t.getNumChannels();
display(['number of channels ', num2str(numcha)]);

tex = t.getTotalExposure();
display(['total exposure ', num2str(tex)]);

delete(t)