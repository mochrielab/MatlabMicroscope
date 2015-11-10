classdef MicroscopeAction < handle & matlab.mixin.Heterogeneous
    %basic class for microscope actions
    %   Yao Zhao 11/9/2015
    
    properties (SetAccess = protected)
        label = 'idle';
    end
    
    properties (Access = protected)
        isrunning
        microscope_handle
        image_axes;
        eventloop
        has_ui
    end
    
    methods
        % constructor
        function obj = MicroscopeAction(microscope,image_axes)
            obj.microscope_handle=microscope;
            obj.isrunning = false;
            obj.image_axes=image_axes;
            if ishandle(obj.image_axes)
                obj.has_ui=true;
            else
                obj.has_ui=false;
            end
            obj.eventloop=EventLoop(10);
        end
        
        % start action
        function startAction(obj)
            obj.microscope_handle.lock(obj);
            obj.isrunning = true;
            % notify event
            notify(obj,'DidStart');
        end
        
        % interrupt action
        function stopAction(obj)
        end
        
        % finish action
        function finishAction(obj)
            obj.microscope_handle.unlock(obj);
            obj.isrunning = false;
            notify(obj,'DidFinish');
        end
        
        % test if action is running
        function bool=isRunning(obj)
            bool=obj.isrunning;
        end
        
        % get event display for ui
        function dispstr=getEventDisplay(obj,eventstr)
            switch eventstr
                case 'ObjectBeingDestroyed'
                    dispstr='default';
                case 'DidStart'
                    dispstr='default';
                case 'DidFinish'
                    dispstr='default';
                otherwise
                    warning(['no events has been set for: ',eventstr]);
                    dispstr=[];
            end
        end
    end
    
    events
        DidStart
        DidFinish
    end
    
end

