classdef MicroscopeAction < handle & matlab.mixin.Heterogeneous
    %basic class for microscope actions
    %   Yao Zhao 11/9/2015
    
    properties (SetAccess = protected)
        label = 'idle';
        isrunning
        microscope_handle
    end
    
    methods
        function obj = MicroscopeAction(microscope)
            obj.microscope_handle=microscope;
            obj.isrunning = false;
        end
        function startAction(obj)
            obj.microscope_handle.lock(obj);
            obj.isrunning = true;
        end
        function stopAction(obj)
        end
        function finishAction(obj)
            obj.microscope_handle.unlock(obj);
            obj.isrunning = false;
        end
    end
    
    events
        DidStart
        DidFinish
    end
    
end

