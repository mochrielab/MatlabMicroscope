classdef MicroscopeActionLive < YMicroscope.MicroscopeActionControllerResponder
    % live function of the microscope
    % inherited the class of action controller responder
    % will respond to events created by the joystick or keyboard
    %   Yao Zhao 11/16/2015
    
    properties (SetAccess = protected)
        
    end
    
    methods
        % constructor
        function obj=MicroscopeActionLive...
                (microscope,image_axes,hist_axes)
            obj@YMicroscope.MicroscopeActionControllerResponder('live',...
                microscope,image_axes,hist_axes,microscope.controller);
        end
        
        % destructor
        function delete(obj)
            delete@YMicroscope.MicroscopeActionControllerResponder(obj);
        end
        
        % start live
        function start(obj)
            if ~ishandle(obj.image_axes)
                throw(MException('MicroscopeActionLive:UINeed',...
                    'can''t run without UI'));
            end
            % call super
            start@YMicroscope.MicroscopeAction(obj);
            % start camera
            obj.microscope_handle.camera.prepareModeSnapshot();
        end
        
        % run everything
        function run(obj)
            obj.start;
            %addlistener to updateHist, callback=drawHist go to UIView
            % turn on light
            obj.microscope_handle.setLight('always on');
            % run event loop
            obj.eventloop.run(@()runLoopCallback(obj));
            % call call back function when finish
            obj.microscope_handle.setLight('off');
            % finish
            obj.finish;
        end
        
        function img = runLoopCallback(obj)
            % callback function
            img = obj.microscope_handle.camera.capture;
            if obj.microscope_handle.histIdx == 1
                obj.histxmin = min(img(:))-20;
                obj.histxmax = max(img(:))+20;
                obj.microscope_handle.setHistIdx(0);
            end
            obj.drawImage(img);
            obj.microscope_handle.controller.emitMotionEvents();
            obj.microscope_handle.controller.emitActionEvents();
            obj.drawHist(img); % 01/30/17 SEP
            % stop if image closed
            if ~ishandle(obj.image_axes)
                obj.stop();
            end
        end
        
        % get event display for UI
        function dispstr=getEventDisplay(obj,eventstr)
            switch eventstr
                case 'DidStart'
                    dispstr = 'Stop Live';
                case 'DidFinish'
                    dispstr = 'Live';
                otherwise
                    dispstr=...
                        getEventDisplay@YMicroscope.MicroscopeAction(obj,eventstr);
            end
        end
        
        
    end
    
    events
    end
    
end

