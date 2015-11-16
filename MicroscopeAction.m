classdef (Abstract) MicroscopeAction < handle & matlab.mixin.Heterogeneous 
    %basic class for microscope actions
    %   Yao Zhao 11/9/2015
    
    properties (SetAccess = protected)
        label;
    end
    
    properties (Access = protected)
        isrunning
        microscope_handle
        image_axes
        eventloop
        file_handle
    end
    
    methods
        % constructor
        function obj = MicroscopeAction(label,microscope,image_axes)
            obj.label=label;
            obj.microscope_handle=microscope;
            obj.isrunning = false;
            obj.image_axes=image_axes;
            obj.eventloop=EventLoop(10);
            obj.file_handle=TiffIO(microscope.datapath,obj.label);
        end
        
        % start action
        function start(obj)
            obj.microscope_handle.lock(obj);
            obj.isrunning = true;
            % notify event
            notify(obj,'DidStart');
        end
        
        % interrupt action
        function stop(obj)
            obj.eventloop.stop;
            notify(obj,'WillStop');
        end
        
        % finish action
        function finish(obj)
            obj.microscope_handle.unlock(obj);
            obj.isrunning = false;
            notify(obj,'DidFinish');
        end
        
        % draw image to ui
        function drawImage(obj,img)
            if ishandle(obj.image_axes)
                cla(obj.image_axes);
                imagesc(img);
            end
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
                    dispstr='Started';
                case 'DidFinish'
                    dispstr='Ready';
                case 'WillStop'
                    dispstr='Stopping';
                otherwise
                    warning(['no events has been set for: ',eventstr]);
                    dispstr=[];
            end
        end
    end
    
    methods (Abstract)
        run(obj)
    end
    
    events
        DidStart
        DidFinish
        WillStop
    end
    
end

