classdef MicroscopeActionCapture < MicroscopeAction
    %basic class for microscope actions
    %   Yao Zhao 11/9/2015
    
    properties (SetAccess = protected)
    end
    
    methods
        function obj = MicroscopeActionCapture(microscope,image_axes)
            obj@MicroscopeAction(microscope,image_axes);
            obj.label = 'capture';
        end
        
        function startAction(obj)
            % call super
            startAction@MicroscopeAction(obj);
            % start camera
            obj.microscope_handle.camera.prepareModeSnapshot();
            obj.microscope_handle.switchLight('on');
            % create tiff
            tif=TiffIO(obj.microscope_handle.datapath,'capture');
            tif.fopen(obj.microscope_handle.camera.getSize);
            img=obj.microscope_handle.camera.capture;
            pause(.1);
            if obj.has_ui
                cla(obj.image_axes);imagesc(img);
            end
            tif.fwrite(img);
            tif.fclose(obj.microscope_handle.getSettings);
            obj.microscope_handle.switchLight('off');
            % call finish function when finish
            obj.finishAction;
        end
        
        function stopAction(obj)
        end
        
        % get event display for ui
        function dispstr=getEventDisplay(obj,eventstr)
            switch eventstr
                case 'ObjectBeingDestroyed'
                    dispstr='default';
                case 'DidStart'
                    dispstr='Capturing';
                case 'DidFinish'
                    dispstr='Capture';
                otherwise
                    warning(['no events has been set for: ',eventstr]);
                    dispstr=[];
            end
        end

    end
    
    events
    end
    
end

