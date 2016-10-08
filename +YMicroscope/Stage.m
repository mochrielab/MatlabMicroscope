classdef (Abstract) Stage < handle & matlab.mixin.Heterogeneous
    %Prior XY stage
    
    properties (SetAccess = protected)
        pos_x = 0
        pos_y = 0
        pos_z = 0
        v_x = 0
        v_y = 0
        v_z = 0
    end
    
    methods (Abstract)
        [ pos ] = getPosition( obj )
        setPosition( obj, pos)
        
        setSpeed(obj,vs)
        [ vs ] = getSpeed(obj)
    end
end

