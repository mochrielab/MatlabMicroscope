classdef MicroscopeActionLive < MicroscopeAction
    %basic class for microscope actions
    %   Yao Zhao 11/9/2015
    
    properties (SetAccess = protected)
        image_axes;
        eventloop
    end
    
    methods
        function obj = MicroscopeActionLive(microscope,image_axes)
            obj@MicroscopeAction(microscope);
            obj.label = 'live';
            obj.image_axes=image_axes;
            obj.eventloop=EventLoop(10);
        end
        
        function startAction(obj)
            % call super
            startAction@MicroscopeAction(obj);
            % start camera
            obj.microscope_handle.camera.prepareModeSnapshot();
            % notify event
            notify(obj,'DidStart');
            % create eventloop
            cla(obj.image_axes);axis equal;colormap gray;
            % callback function
            function callback (obj)
                cla(obj.image_axes);
                imagesc(obj.microscope_handle.camera.capture);
                obj.microscope_handle.joystick.emitMotionEvents();
                obj.microscope_handle.joystick.emitActionEvents();
            end
            % turn on light
            obj.microscope_handle.switchLight('On');
            % run event loop
            obj.eventloop.run(@()callback(obj));
            % call call back function when finish
            obj.microscope_handle.switchLight('Off');
            obj.finishAction;
        end
        
        function stopAction(obj)
            obj.eventloop.stop;
        end
        
        function finishAction(obj)
            finishAction@MicroscopeAction(obj);
            notify(obj,'DidFinish');
        end

    end
    
    events
    end
    
end

