classdef Trigger < handle & matlab.mixin.Heterogeneous
    % trigger class for device synchronization
    %   Yao Zhao 11/10/2015
    properties (Access = protected)
        clock
    end
    properties (SetAccess = protected)
        
        label='trigger';
        clockrate=1000;
        framerate=1;
    end
    
    methods
        function obj=Trigger()
        end
        
        function setClockrate(obj,clockrate)
            if clockrate<0
                throw(MException('Trigger:NegativeClockRate',...
                    'negative clock rate'))
            else
                obj.clockrate=clockrate;
                notify(obj,'ClockrateDidSet');
            end
        end
        
        function setFramerate(obj,framerate)
            if framerate<0
                throw(MException('Trigger:NegativeFrameRate',...
                    'negative frame rate'))
            else
                obj.framerate=framerate;
                notify(obj,'FramerateDidSet');
            end
        end
        
        function delete(obj)
        end
    end
    
    methods (Abstract)
        start(obj)
        finish(obj)
        isRunning(obj)
    end
    
    events
        ClockrateDidSet
        FramerateDidSet
    end
end
