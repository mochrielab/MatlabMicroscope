classdef MicroscopeActionSequenceZstack < YMicroscope.MicroscopeActionSequence
    %zstack class for microscope actions
    %   Yao Zhao 11/10/2015
    
    properties (SetAccess = protected)
        
    end
    
    properties (Access = private)
        display_interval = 3;
    end
    
    methods
        
        % constructor
        function obj=MicroscopeActionSequenceZstack...
                (microscope,image_axes,hist_axes)
            obj@YMicroscope.MicroscopeActionSequence('zstack',microscope,image_axes,hist_axes);
        end
        
        function start(obj)
            start@YMicroscope.MicroscopeActionSequence(obj);
            % set light source
            obj.microscope_handle.trigger.setLightsources...
                (obj.microscope_handle.getLightsource);
            % start sequence
            obj.microscope_handle.camera.startSequenceAcquisition();
            % start nidaq in background
            zarray=obj.microscope_handle.zstage.getZarray();
            outputstack = obj.microscope_handle.trigger.getOutputQueueStack(zarray);
            obj.microscope_handle.trigger.start(outputstack);
        end
        
        function run(obj)
            obj.start();
            % run event loop
            while obj.microscope_handle.trigger.isRunning
                obj.drawImage(obj.microscope_handle.camera.getLastImage);
                for i=1:obj.display_interval
                    img=obj.microscope_handle.camera.popNextImage;
                    if ~isempty(img)
                        obj.file_handle.fwrite(img)
                    end
                end
            end
            while ~isempty(img)
                img=obj.microscope_handle.camera.popNextImage;
                obj.file_handle.fwrite(img)
            end
            %finish
            obj.finish();
        end
        
        % get event display for UI
        function dispstr=getEventDisplay(obj,eventstr)
            switch eventstr
                case 'DidStart'
                    dispstr = 'Stop Zstack';
                case 'DidFinish'
                    dispstr = 'Zstack';
                otherwise
                    dispstr=getEventDisplay@YMicroscope.MicroscopeAction(obj,eventstr);
            end
        end
        
    end
    
    events
    end
    
end

