classdef MicroscopeActionLiveFNetRecord < YMicroscope.MicroscopeActionLiveFNet
    % live function of the microscope with FocusNet and record
    % inherited the class of action live FocusNet
    % will respond to events created by the joystick or keyboard
    % record at the same time
    %   Yao Zhao 06/21/2017
    
    properties (SetAccess = protected)
        text_handle
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
            % create text
            [filepath, name, ~]= fileparts(obj.file_handle.getFullFileName());
            obj.text_handle = fopen(...
                fullfile(filepath, [name, '.csv']),'w');
            fprintf(obj.text_handle, 'time stamps,');
            fprintf(obj.text_handle, 'zoffset,');
            fprintf(obj.text_handle, 'means');
            for i = 1:obj.fnet.batchsize
                fprintf(obj.text_handle, ',');
            end
            fprintf(obj.text_handle, 'variance');
            for i = 1:obj.fnet.batchsize
                fprintf(obj.text_handle, ',');
            end
            fprintf(obj.text_handle, '\n');
        end
        
        function runLoopCallBackFNet(obj)
            % call super
            img = runLoopCallBackFNet@YMicroscope.MicroscopeActionLiveFNet(obj);
            % save image
            obj.file_handle.fwrite(img)
            % save text
            fprintf(obj.text_handle, '%f,', now);
            fprintf(obj.text_handle, '%1.5f,', obj.microscope_handle.zstage.zoffset);
            for m = obj.fnet.mean
                fprintf(obj.text_handle, '%2.5f,', m);
            end
            for v = obj.fnet.var
                fprintf(obj.text_handle, '%2.5f,', m);
            end
            fprintf(obj.text_handle, '\n');                        
        end
        
        function finish(obj)
            % call super
            finish@YMicroscope.MicroscopeActionLiveFNet(obj);
            % close TIFF
            obj.file_handle.fclose(obj.microscope_handle.getSettings);
            % close text
            fclose(obj.text_handle);
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

