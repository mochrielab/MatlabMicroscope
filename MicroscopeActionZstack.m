classdef MicroscopeActionZstack < MicroscopeAction
    %zstack class for microscope actions
    %   Yao Zhao 11/10/2015
    
    properties (SetAccess = protected)

    end
    
    methods
        function obj = MicroscopeActionZstack(microscope,image_axes)
            obj@MicroscopeAction(microscope,image_axes);
            obj.label = 'zstack';
        end
        
        function startAction(obj)
            % call super
            startAction@MicroscopeAction(obj);
            % start camera
            obj.microscope_handle.camera.prepareModeSequence();
            % create tiff
            tif=TiffIO(obj.microscope_handle.datapath,obj.label);
            tif.fopen(obj.microscope_handle.camera.getSize);
            % run event loop
            obj.eventloop.run(@()callback(obj));
            
            tif.fwrite(img);
            tif.fclose(obj.microscope_handle.getSettings);
            
            
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

            % call call back function when finish
            obj.microscope_handle.switchLight('Off');
            obj.finishAction;
            
            % call finish function when finish
            obj.finishAction;
        end
        
        function stopAction(obj)
        end

    end
    
    events
    end
    
end

