classdef MicroscopeActionLiveRecord < YMicroscope.MicroscopeActionLive
    % live function of the microscope and record
    % inherited the class of action live
    % will respond to events created by the joystick or keyboard
    % record at the same time
    %   Yao Zhao 06/21/2017
    
    properties (SetAccess = protected)
        
    end
    
    methods
        % constructor
        function obj=MicroscopeActionLiveRecord...
                (microscope,image_axes,hist_axes)
            obj@YMicroscope.MicroscopeActionLive(...
                microscope,image_axes,hist_axes);
            obj.label = 'LiveRecord';
        end
        
        % destructor
        function delete(obj)
            delete@YMicroscope.MicroscopeActionLive(obj);
        end
        
        % start live
        function start(obj)
            % call super
            start@YMicroscope.MicroscopeActionLive(obj);
            % create tiff
            obj.file_handle.fopen(obj.microscope_handle.camera.getTiffTag());
        end
        
        function runLoopCallback(obj)
            % call super
            img = runLoopCallback@YMicroscope.MicroscopeActionLive(obj);
            % save image
            obj.file_handle.fwrite(img)
        end
        
        function finish(obj)
            % call super
            finish@YMicroscope.MicroscopeActionLive(obj);
            % close TIFF
            obj.file_handle.fclose(obj.microscope_handle.getSettings);
        end
        
        % get event display for UI
        function dispstr=getEventDisplay(obj,eventstr)
            switch eventstr
                case 'DidStart'
                    dispstr = 'Stop Live';
                case 'DidFinish'
                    dispstr = 'Live Record';
                otherwise
                    dispstr=...
                        getEventDisplay@YMicroscope.MicroscopeAction(obj,eventstr);
            end
        end
    end
    
    events
    end
    
end

