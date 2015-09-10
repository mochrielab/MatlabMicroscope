function [  ] = Go( obj,varargin )
%   Update the stage position
%   take options 'Z', only move z

if nargin==1

% update z position
obj.nidaq.outputSingleScan([obj.zoffset, 0]);

% update x-y position
fprintf(obj.priorXYstage,'%s\r',...
    ['G,',num2str(obj.pos_x),',',num2str(obj.pos_y)]);

elseif nargin ==2
    if strcmp(varargin{1},'Z')
        obj.nidaq.outputSingleScan([obj.zoffset, 0]);
    else
        warning('unsupported mode');
    end
    
end


end

