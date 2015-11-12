classdef MicroscopeActionZstack < MicroscopeActionSequence
    %zstack class for microscope actions
    %   Yao Zhao 11/10/2015
    
    properties (SetAccess = protected)

    end
    
    methods
        function obj = MicroscopeActionZstack(microscope,image_axes)
            obj@MicroscopeActionSequence(microscope,image_axes);
            obj.label = 'zstack';
            obj.file_handle=TiffIO(microscope.datapath,obj.label);
        end
        
        function start(obj)
            start@MicroscopeActionSequence(obj);
            % set light source
            obj.microscope_handle.trigger.setLightsources...
                (obj.microscope_handle.getLightsource);
            % start sequence
            obj.microscope_handle.camera.startSequenceAcquisition();
            % start nidaq in background
            zarray=obj.microscope_handle.zstage.getZarray();
            obj.microscope_handle.trigger.start(...
                obj.microscope_handle.trigger.getOutputQueueStack(zarray));
        end
        
        function run (obj)
            obj.start
            % run event loop
            while obj.microscope_handle.trigger.isRunning
                obj.drawImage(obj.microscope_handle.camera.getLastImage);
                for i=1:3
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
            obj.finish
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
    
    events
    end
    
end

