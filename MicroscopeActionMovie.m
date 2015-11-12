classdef (Abstract) MicroscopeActionMovie < MicroscopeActionSequence
    %zstack class for microscope actions
    %   Yao Zhao 11/10/2015
    
    properties (SetAccess = protected)
        icycle
    end
    
    methods
        %constructor
        function obj = MicroscopeActionMovie(microscope,image_axes)
            obj@MicroscopeActionSequence(microscope,image_axes);
            obj.label = 'movie';
            obj.file_handle=TiffIO(microscope.datapath,obj.label);
        end
        
        % start movie acquisition
        function start(obj)
            % call super
            start@MicroscopeActionSequence(obj);
        end
        
        % run acquisition
        function run (obj)
            obj.start
            % refresh cycle
            obj.icycle=1;
            % set movie interval
            obj.eventloop.setRate(1/obj.microscope_handle.movieinterval);
            % run event loop
            obj.eventloop.run(@()callbackSingleLoop(obj));
            %finish
            obj.finish
            % call back function
            function callbackSingleLoop (obj)
                if obj.icycle<=obj.microscope_handle.moviecycles
                    obj.eventloop.stop;
                else
                    obj.runSingleLoop;
                end
            end
        end
                
        % get event display for UI
        function dispstr=getEventDisplay(obj,eventstr)
            switch eventstr
                case 'DidStart'
                    dispstr = 'Stop Zstack';
                case 'DidFinish'
                    dispstr = 'Zstack';
                otherwise
                    dispstr=getEventDisplay@MicroscopeAction(obj,eventstr);
            end
        end

    end
    
    methods (Abstract)
        % things to be done in the single loop
        runSingleLoop(obj)
    end
    
    events
    end
    
end

