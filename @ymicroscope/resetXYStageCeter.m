function [  ] = resetXYStageCeter( obj )
%set the current position of the XY stage to be 0,0

    obj.StageCommand('PS,0,0');

end

