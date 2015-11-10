classdef MicroscopeActionCapture < MicroscopeAction
    %basic class for microscope actions
    %   Yao Zhao 11/9/2015
    
    properties (SetAccess = protected)
        image_axes;
    end
    
    methods
        function obj = MicroscopeActionCapture(microscope,image_axes)
            obj@MicroscopeAction(microscope);
            obj.label = 'capture';
            obj.image_axes=image_axes;
        end
        
        function startAction(obj)
            % call super
            startAction@MicroscopeAction(obj);
            % start camera
            obj.microscope_handle.camera.prepareModeSnapshot();
            obj.microscope_handle.switchLight('on');
            % notify event
            notify(obj,'DidStart');
            % create tiff
            tif=TiffIO(obj.microscope_handle.datapath,'capture');
            tif.fopen(obj.microscope_handle.camera.getSize);
            img=obj.microscope_handle.camera.capture;
            cla(obj.image_axes);imagesc(img);
            tif.fwrite(img);
            tif.fclose(obj.microscope_handle.getSettings);
            obj.microscope_handle.switchLight('off');
            % call finish function when finish
            obj.finishAction;
        end
        
        function stopAction(obj)
        end
        
        function finishAction(obj)
            finishAction@MicroscopeAction(obj);
            notify(obj,'DidFinish');
        end

    end
    
    events
    end
    
end

