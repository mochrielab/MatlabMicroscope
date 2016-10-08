devices = daq.getDevices;
%%
s=daq.createSession('ni');
% addAnalogInputChannel(s,'Dev1', 0, 'Voltage');
% addAnalogInputChannel(s,'Dev1', 1, 'Voltage');
addAnalogOutputChannel(s,'Dev1',0,'Voltage');
% plotData=@(src,event)...
%     plot(event.TimeStamps, event.Data);
% lh1 = addlistener(s,'DataAvailable', plotData);
% data=linspace(-1, 1, 5000)';

lh2 = addlistener(s,'DataRequired', ...
    @(src,event) src.queueOutputData(data));
data=[0 0 0 0 0 0 0 0 0 0 0 0]'+0;
queueOutputData(s,data)
s.Rate=10;
s.IsContinuous=1;
% data=s.inputSingleScan;
% [data,time] = s.startForeground;
% plot(time,data);
% xlabel('Time (secs)');
% ylabel('Voltage')
% s.queueOutputData(ones(100,1));.
s.startBackground;
pause
% lh1.delete;
lh2.delete;
