classdef MicroscopeActionCapture < YMicroscope.MicroscopeAction 
    % a simple class for single image capture and saving
    %   Yao Zhao 11/9/2015
    
    properties (SetAccess = protected)
    end
    
    methods
        
                % constructor
        function obj=MicroscopeActionCapture(label,microscope,image_axes)
            obj@YMicroscope.MicroscopeAction(label,...
                microscope,image_axes);
        end
        
        function start(obj)
            % call super
            start@YMicroscope.MicroscopeAction(obj);
            % create tiff
            obj.file_handle.fopen(obj.microscope_handle.camera.getSize);
            % start camera
            obj.microscope_handle.camera.prepareModeSnapshot();
        end
        
        function run(obj)
            obj.start();
            obj.microscope_handle.setLight('always on');
            img=obj.microscope_handle.camera.capture();
            obj.drawImage(img);
            obj.file_handle.fwrite(img);
            obj.microscope_handle.setLight('off');
            pause(.2)
            obj.finish;
        end
        
        function finish(obj)
            obj.file_handle.fclose(obj.microscope_handle.getSettings);
            finish@MicroscopeAction(obj);
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

