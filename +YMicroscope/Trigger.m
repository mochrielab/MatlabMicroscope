classdef (Abstract) Trigger < handle & matlab.mixin.Heterogeneous
    % trigger class for device synchronization
    %   Yao Zhao 11/10/2015
    
%     properties (Access = public)
%         clock
%     end

    properties (SetAccess = protected)
        % class label
        label = 'trigger';
        % sampling rate
        clockrate = 1000;
        % frame rate of acquisition
        framerate = 1;
        % current state of output
        states = []
    end
    
    methods
        % constructor
        function obj=Trigger()
        end
        % set clock rate
        function setClockrate(obj,clockrate)
            if clockrate<0
                throw(MException('Trigger:NegativeClockRate',...
                    'negative clock rate'))
            else
                obj.clockrate=clockrate;
                notify(obj,'ClockrateDidSet');
            end
        end
        % set frame rate
        function setFramerate(obj,framerate)
            if framerate<0
                throw(MException('Trigger:NegativeFrameRate',...
                    'negative frame rate'))
            else
                obj.framerate=framerate;
                notify(obj,'FramerateDidSet');
            end
        end
        % delete obj
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
