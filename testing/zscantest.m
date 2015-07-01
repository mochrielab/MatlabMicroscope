% zscan test

obj.nidaq.Rate=40;
stacks =(-(obj.numstacks-1)/2:(obj.numstacks-1)/2)*obj.stepsize;

% prepare data to send
data=stacks*obj.volts_per_pix+obj.dataoffset;
data=reshape(data,length(data),1);
queueOutputData(obj.nidaq,data)

piezopos = zeros(size(data));
counter = 1;
data_pointer = libpointer('doublePtr',piezopos);
counter_pointer = libpointer('doublePtr',counter);
lh = addlistener(obj.nidaq,'DataAvailable',...
    @(src,event)Nidaq_Data_log(src,event,data_pointer,counter_pointer));

% piezopos = NIDAQ_Input_Wrapper(data);
% lh = addlistener(obj.nidaq,'DataAvailable',@(src,event)piezopos.datalistener(src,event));

obj.nidaq.startBackground;
obj.nidaq.wait;

plot(data,data_pointer.Value);
axis equal;

delete(lh)
display('finished')

