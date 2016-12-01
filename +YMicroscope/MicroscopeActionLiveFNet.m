classdef MicroscopeActionLiveFNet < YMicroscope.MicroscopeActionLive
    % live function of the microscope with autofocusing using deep learning
    % inherited the class of action controller responder
    % will respond to events created by the joystick or keyboard
    %   Yao Zhao 11/16/2015
    
    properties (SetAccess = protected)
        
    end
    
    methods
        % constructor
        function obj=MicroscopeActionLiveFNet...
                (microscope,image_axes)
            obj@YMicroscope.MicroscopeActionLive('live',...
                microscope,image_axes,microscope.controller);
        end
        
        % destructor
        function delete(obj)
            delete@YMicroscope.MicroscopeActionLive(obj);
        end
        
        % start live
        function start(obj)
            % call super
            start@YMicroscope.MicroscopeActionLive(obj);
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
            obj.microscope_handle.setLight('always on');
            % run event loop
            obj.eventloop.run(@()callback(obj));
            % call call back function when finish
            obj.microscope_handle.setLight('off');
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
                    dispstr=...
                        getEventDisplay@YMicroscope.MicroscopeAction(obj,eventstr);
            end
        end
       
        
    end
    
    events
    end
    
end

