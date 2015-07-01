function [ ] = Nidaq_Data_log( src,event,data_pointer,counter_pointer )
% log data 
% input: src, event, data pointer, counter pointer
[numdata,numchannel]=size(event.Data);
data_pointer.Value(counter_pointer.Value+(1:numdata),:) = event.Data;
counter_pointer.Value = counter_pointer.Value + numdata;

end

