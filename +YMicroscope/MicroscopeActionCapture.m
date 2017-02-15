classdef MicroscopeActionCapture < YMicroscope.MicroscopeAction
    % a simple class for single image capture and saving
    %   Yao Zhao 11/9/2015
    
    properties (SetAccess = protected)
        issaving
    end
    
    
    methods
        
        % constructor
        function obj=MicroscopeActionCapture(microscope,image_axes,hist_axes)
            obj@YMicroscope.MicroscopeAction('capture',...
                microscope,image_axes,hist_axes);
            obj.issaving = false;
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
                % set exposure
                obj.microscope_handle.camera.setExposure(...
                    obj.microscope_handle.lightsource.exposure);
            end
            if obj.issaving
                % create tiff
                obj.file_handle.fopen(obj.microscope_handle.camera.getTiffTag());
            end
        end
        
        % end acquisition
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
            %histogram
            if ishandle(obj.hist_axes)
                axes(obj.hist_axes);
                obj.drawHist(img);
            end
            % saving
            if obj.issaving
                obj.file_handle.fwrite(img);
            end
            % clean up
            obj.finish();
        end
        
        % end acquisition
        function finish(obj)
            if obj.issaving
                % close tiff
                obj.file_handle.fclose(obj.microscope_handle.getSettings);
            end
            % get status
            status = obj.microscope_handle.getStatus();
            if strcmp(status, 'capture')
                finish@YMicroscope.MicroscopeAction(obj);
            end
        end
        
        % set is saving option
        function setIssaving(obj, val)
            obj.issaving = val>0;
            notify(obj, 'IssavingDidSet');
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
                case 'IssavingDidSet'
                    dispstr=[];
                otherwise
                    warning(['no events has been set for: ',eventstr]);
                    dispstr=[];
            end
        end
        
    end
    
    events
        IssavingDidSet
    end
    
end

