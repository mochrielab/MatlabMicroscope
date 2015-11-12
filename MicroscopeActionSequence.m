classdef (Abstract) MicroscopeActionSequence < MicroscopeAction
    %basic class for microscope sequence actions
    %   Yao Zhao 11/12/2015
    
    properties (SetAccess = protected)

    end
    
    methods
        function obj = MicroscopeActionSequence(microscope,image_axes)
            obj@MicroscopeAction(microscope,image_axes);
            obj.label = 'sequence';
            obj.file_handle=TiffIO(microscope.datapath,obj.label);
        end
        
        function start(obj)
            % call super
            start@MicroscopeAction(obj);
            % create tiff
            obj.file_handle.fopen(obj.microscope_handle.camera.getSize);
            % prepare camera
            obj.microscope_handle.camera.prepareModeSequence();
        end
        
       
        function finish(obj)
            % finish
            obj.microscope_handle.trigger.finish(...
                obj.microscope_handle.zstage.zoffset);
            obj.microscope_handle.camera.stopSequenceAcquisition();
            obj.file_handle.fclose(obj.microscope_handle.getSettings);
            finish@MicroscopeAction(obj);
        end
        
        function stop(obj)
            obj.microscope_handle.trigger.finish(...
                obj.microscope_handle.zstage.zoffset);
        end

    end
    
    events
    end
    
end

