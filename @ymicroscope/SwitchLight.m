function [ obj ] = SwitchLight( obj, on_or_off )
% turn on or off the light
% accept input value of 'on' or 'off'

if strcmp(on_or_off,'off')
    fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
    obj.nidaq2.outputSingleScan([0 0]);
elseif strcmp(on_or_off,'on')
    if strcmp(obj.illumination_mode,'None')
        fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
        obj.nidaq2.outputSingleScan([0 0]);
    elseif strcmp(obj.illumination_mode,'Brightfield - W')
        fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
        obj.nidaq2.outputSingleScan([1 0]);
        
    elseif strcmp(obj.illumination_mode,'Brightfield - R')
        fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
        obj.nidaq2.outputSingleScan([0 1]);
    elseif strcmp(obj.illumination_mode,'Fluorescent')
        fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7D') hex2dec('50')])); % Enable all channels
        obj.nidaq2.outputSingleScan([0 0]);
    else
        warning('unrecognized movie illumination mode');
    end
else
    warning('unrecognized switch light command');
end


end

