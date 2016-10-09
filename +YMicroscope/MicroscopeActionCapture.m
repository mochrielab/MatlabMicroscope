classdef MicroscopeActionCapture < YMicroscope.MicroscopeAction
    % a simple class for single image capture and saving
    %   Yao Zhao 11/9/2015
    
    properties (SetAccess = protected)
        isSaving
    end
    
    methods
        
        % constructor
        function obj=MicroscopeActionCapture(microscope,image_axes)
            obj@YMicroscope.MicroscopeAction('capture',...
                microscope,image_axes);
            obj.isSaving = false;
        end
        
        % start action
        function start(obj)
            % get status
            status = obj.microscope_handle.getStatus();
            if strcmp(status, 'idle')
                % call super
                start@YMicroscope.MicroscopeAction(obj);
                % start camera
                obj.microscope_handle.camera.prepareModeSnapshot();
            end
            if obj.isSaving
                % create tiff
                obj.file_handle.fopen(obj.microscope_handle.camera.getTiffTag());
            end
        end
        
        % end acquisation
        function img = run(obj)
            % set up
            obj.start();
            % get status
            status = obj.microscope_handle.getStatus();
            if strcmp(status, 'capture')
                obj.microscope_handle.setLight('always on');
                img=obj.microscope_handle.camera.capture();
                display('capture a new image')
                if ishandle(obj.image_axes)
                    axes(obj.image_axes);
                    obj.drawImage(img);
                end
                obj.microscope_handle.setLight('off');
            else
                if ishandle(obj.image_axes)
                    img = getimage(obj.image_axes);
                    display('capture image on UI')
                else
                    img = obj.microscope_handle.camera.getLastImage();
                    display('capture image from last required')
                end
            end
            % saving
            if obj.isSaving
                obj.file_handle.fwrite(img);
            end
            % clean up
            obj.finish();
        end
        
        % end acquisition
        function finish(obj)
            if obj.isSaving
                % close tiff
                obj.file_handle.fclose(obj.microscope_handle.getSettings);
            end
            % get status
            status = obj.microscope_handle.getStatus();
            if strcmp(status, 'idle')
                finish@YMicroscope.MicroscopeAction(obj);
            end
        end
        
        % get is saving option
        function iss = getIsSaving(obj)
            iss = obj.isSaving;
        end
        % set is saving option
        function setIsSaving(obj, val)
            obj.isSaving = val>0;
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

