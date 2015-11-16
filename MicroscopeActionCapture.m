classdef MicroscopeActionCapture < MicroscopeAction 
    %basic class for microscope actions
    %   Yao Zhao 11/9/2015
    
    properties (SetAccess = protected)
    end
    
    methods
        
        function start(obj)
            % call super
            start@MicroscopeAction(obj);
            % create tiff
            obj.file_handle.fopen(obj.microscope_handle.camera.getSize);
            % start camera
            obj.microscope_handle.camera.prepareModeSnapshot();
        end
        
        function run(obj)
            obj.start;
            obj.microscope_handle.switchLight('on');
            img=obj.microscope_handle.camera.capture;
            obj.drawImage(img);
            obj.file_handle.fwrite(img);
            obj.microscope_handle.switchLight('off');
            pause(.2)
            obj.finish;
        end
        
        function finish(obj)
            obj.file_handle.fclose(obj.microscope_handle.getSettings);
            finish@MicroscopeAction(obj);
        end
        
        function stop(obj)
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

