classdef (Abstract) Controller < handle & matlab.mixin.Heterogeneous 
    % base class for control module
    % controller methods such as keyboard and joystick should inherit this
    % class
    
    properties (Access = private)
    end
    
    methods (Abstract)
        emitMotionEvents(obj)
        emitActionEvents(obj)
    end
    
    
    events
        MoveXYStage
        MoveZStage
        ToggleLightSelection
        ToggleLight
        Capture
        ZoomIn
        ZoomOut
    end
    
end

