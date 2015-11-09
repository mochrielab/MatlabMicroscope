classdef (Abstract) MicroscopeAction < handle
    %basic class for microscope actions
    %   Yao Zhao 11/9/2015
    
    properties (SetAccess = protected)
        label
        isrunning
    end
    
    methods
        startAction(obj)
        finishAction(obj)
    end
    
    events
        DidStart
        DidFinish
    end
    
end

