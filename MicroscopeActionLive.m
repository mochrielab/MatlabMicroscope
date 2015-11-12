classdef MicroscopeActionLive < MicroscopeAction
    %basic class for microscope actions
    %   Yao Zhao 11/9/2015
    
    properties (SetAccess = protected)

    end
    
    methods
        function obj = MicroscopeActionLive(microscope,image_axes)
            obj@MicroscopeAction(microscope,image_axes);
            obj.label = 'live';
        end
        
        function start(obj)
            if ~ishandle(obj.image_axes)
                throw(MException('MicroscopeActionLive:UINeed',...
                    'can''t run without UI'));
            end
            % call super
            start@MicroscopeAction(obj);
            % start camera
            obj.microscope_handle.camera.prepareModeSnapshot();
            % create eventloop
            cla(obj.image_axes);axis equal;colormap gray;
        end
        
        function run(obj)
            obj.start;
            % callback function
            function callback (obj)
                obj.drawImage(obj.microscope_handle.camera.capture);
                obj.microscope_handle.joystick.emitMotionEvents();
                obj.microscope_handle.joystick.emitActionEvents();
            end
            % turn on light
            obj.microscope_handle.switchLight('On');
            % run event loop
            obj.eventloop.run(@()callback(obj));
            % call call back function when finish
            obj.microscope_handle.switchLight('Off');
            % finish
            obj.finish;
        end
        
        % get event display for UI
        function dispstr=getEventDisplay(obj,eventstr)
            switch eventstr
                case 'DidStart'
                    dispstr = 'Stop Live';
                case 'DidFinish'
                    dispstr = 'Live';
                otherwise
                    dispstr=getEventDisplay@MicroscopeAction(obj,eventstr);
            end
        end
        
    end
    
    events
    end
    
end

