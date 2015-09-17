devices = daq.getDevices;
%%
% s=daq.createSession('ni');
% addAnalogInputChannel(s,'Dev1', 1, 'Voltage');
% addAnalogOutputChannel(s,'Dev1', 0, 'Voltage');
% %%
% % plotData=@(src,event)...
% %     plot(event.TimeStamps, event.Data);
% % lh1 = addlistener(s,'DataAvailable', plotData);
% 
% acel = zeros(1,1000);
% counter = 0;
% data_pointer = libpointer('doublePtr',acel);
% counter_pointer = libpointer('doublePtr',counter);
% lh = addlistener(s,'DataAvailable',... % remember to delete pointer
%     @(src,event)Nidaq_Data_log(src,event,data_pointer,counter_pointer));
% 
% 
% s.Rate=10;
% s.IsContinuous=1;
% s.startBackground;
% pause(3)
% s.stop
% lh.delete;
% lh2.delete;
% plot(acel);

%%
s=daq.createSession('ni');
addAnalogInputChannel(s,'Dev1', 0, 'Voltage');
addAnalogInputChannel(s,'Dev1', 1, 'Voltage');
addAnalogInputChannel(s,'Dev1', 2, 'Voltage');

s.DurationInSeconds = 20;
data = startForeground(s);

plot (data)
% legend('z','x','y')% wrong
legend('x','z','y')
std(data,1)
