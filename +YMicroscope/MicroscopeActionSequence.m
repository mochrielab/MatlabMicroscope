classdef (Abstract) MicroscopeActionSequence < YMicroscope.MicroscopeAction
    % basic class for microscope sequence actions
    %
    %   Yao Zhao 11/12/2015
    
    properties (SetAccess = protected)

    end
    
    methods
        % constructor
        function obj=MicroscopeActionSequence...
                (label,microscope,image_axes,hist_axes)
            obj@YMicroscope.MicroscopeAction(label,microscope,image_axes,hist_axes);
        end
        
        function start(obj)
            % for sequence data, check exposure first
            if ~obj.microscope_handle.trigger.isValidExposures()
                throw(MException('MicroscopeActionSequence:start',...
                    'check exposure failed, framerate and exposure doesnt match'));
            end
            % call super
            start@YMicroscope.MicroscopeAction(obj);
            % create tiff
            obj.file_handle.fopen(obj.microscope_handle.camera.getTiffTag());
            % prepare camera
            obj.microscope_handle.camera.prepareModeSequence();
            % turn on the light
            obj.microscope_handle.setLight('minimal exposure');
        end
       
        function finish(obj)
            % finish
            obj.microscope_handle.trigger.finish();
            obj.microscope_handle.camera.stopSequenceAcquisition();
            obj.file_handle.fclose(obj.microscope_handle.getSettings);
           
            % turn off the light
            obj.microscope_handle.setLight('off');
            % call super
            finish@YMicroscope.MicroscopeAction(obj);
        end
        
        function stop(obj)
            obj.microscope_handle.trigger.finish();
        end

    end
    
    events
    end
    
end

