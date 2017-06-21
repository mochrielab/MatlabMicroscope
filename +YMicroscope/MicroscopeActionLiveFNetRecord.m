classdef MicroscopeActionLiveFNetRecord < YMicroscope.MicroscopeActionLiveFNet
    % live function of the microscope with FocusNet and record
    % inherited the class of action live FocusNet
    % will respond to events created by the joystick or keyboard
    % record at the same time
    %   Yao Zhao 06/21/2017
    
    properties (SetAccess = protected)
        
    end
    
    methods
        % constructor
        function obj=MicroscopeActionLiveFNetRecord...
                (microscope,image_axes,hist_axes)
            obj@YMicroscope.MicroscopeActionLiveFNet...
                (microscope,image_axes,hist_axes)
            obj.label = 'LiveFNetRecord';
        end
        
        % destructor
        function delete(obj)
            delete@YMicroscope.MicroscopeActionLiveFNet(obj);
        end
        
        % start live
        function start(obj)
            % call super
            start@YMicroscope.MicroscopeActionLiveFNet(obj);
            % create tiff
            obj.file_handle.fopen(obj.microscope_handle.camera.getTiffTag());
        end
        
        function runLoopCallBackFNet(obj)
            % call super
            img = runLoopCallBackFNet@YMicroscope.MicroscopeActionLiveFNet(obj);
            % save image
            obj.file_handle.fwrite(img)
        end
        
        function finish(obj)
            % call super
            finish@YMicroscope.MicroscopeActionLiveFNet(obj);
            % close TIFF
            obj.file_handle.fclose(obj.microscope_handle.getSettings);
        end
        
        % get event display for UI
        function dispstr=getEventDisplay(obj,eventstr)
            switch eventstr
                case 'DidStart'
                    dispstr = 'Stop FNet';
                case 'DidFinish'
                    dispstr = 'FNet Record';
                otherwise
                    dispstr=...
                        getEventDisplay@YMicroscope.MicroscopeActionLiveFNet(obj,eventstr);
            end
        end
    end
    
    events
    end
    
end

