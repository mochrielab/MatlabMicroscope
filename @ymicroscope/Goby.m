function [  ] = Goby( obj,ax,increment )
%tell the stage to go by some increment
% position units are pix
% possible ax : 'x','y','z'

if strcmp(ax,'x')
elseif strcmp(ax,'y')
elseif strcmp(ax,'z')
%     obj.zoffset = obj.zoffset + obj.volts_per_pix * increment;
%     obj.nidaq.outputSingleScan([obj.zoffset, 0]);
else
    error('unsupported axis');
end

end

