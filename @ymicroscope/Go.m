function [  ] = Go( obj )
%Update the stage position

% update z position
obj.nidaq.outputSingleScan([obj.zoffset, 0]);

end

