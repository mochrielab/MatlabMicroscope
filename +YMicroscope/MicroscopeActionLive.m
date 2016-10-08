classdef MicroscopeActionLive < YMicroscope.MicroscopeActionControllerResponder
    % live function of the microscope
    % inherited the class of action controller responder
    % will respond to events created by the joystick or keyboard
    %   Yao Zhao 11/16/2015
    
    properties (SetAccess = protected)

    end
    
    methods
        % constructor
        function obj=MicroscopeActionLive...
                (label,microscope,image_axes)
            obj@YMicroscope.MicroscopeActionControllerResponder(label,...
                microscope,image_axes,microscope.controller);
        end
        
        % start live
        function start(obj)
            if ~ishandle(obj.image_axes)
                throw(MException('MicroscopeActionLive:UINeed',...
                    'can''t run without UI'));
            end
            % call super
            start@YMicroscope.MicroscopeAction(obj);
            % start camera
            obj.microscope_handle.camera.prepareModeSnapshot();
            % clear image
            cla(obj.image_axes);axis equal;colormap gray;
        end
        
        % run everything
        function run(obj)
            obj.start;
            % callback function
            function callback (obj)
                obj.drawImage(obj.microscope_handle.camera.capture);
                obj.microscope_handle.controller.emitMotionEvents();
                obj.microscope_handle.controller.emitActionEvents();
                % stop if image closed
                if ~ishandle(obj.image_axes)
                    obj.stop();
                end
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

