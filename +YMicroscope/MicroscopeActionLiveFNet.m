classdef MicroscopeActionLiveFNet < YMicroscope.MicroscopeActionLive
    % live function of the microscope with autofocusing using deep learning
    % inherited the class of action controller responder
    % will respond to events created by the joystick or keyboard
    %   Yao Zhao 11/16/2015
    
    properties (SetAccess = protected)
        fnet
        max
        min
    end
    
    methods
        % constructor
        function obj=MicroscopeActionLiveFNet...
                (microscope,image_axes)
            obj@YMicroscope.MicroscopeActionLive(...
                microscope,image_axes);
            obj.label = 'livefnet';
            obj.fnet = YMicroscope.FocusNet(fullfile('models', 'probnet12'), 16);
        end
        
        % destructor
        function delete(obj)
            delete@YMicroscope.MicroscopeActionLive(obj);
        end
        
        % start live
        function start(obj)
            % call super
            start@YMicroscope.MicroscopeActionLive(obj);
        end
        
        % run everything
        function run(obj)
            obj.start;
            % callback function

            function callback (obj)
                img = (obj.microscope_handle.camera.capture);
                obj.fnet.loadImages(img, obj.max, obj.min);
                obj.fnet.inference();
                obj.drawImage(img); hold on;
                obj.fnet.plot();
                obj.microscope_handle.controller.emitMotionEvents();
                obj.microscope_handle.controller.emitActionEvents();
                % stop if image closed
                if ~ishandle(obj.image_axes)
                    obj.stop();
                end
                % once in a while do autofocusing every 20 loops
                if mod(obj.eventloop.getLoopIndex, 20) == 0
                    
                end
            end
            % turn on light
            obj.microscope_handle.setLight('always on');
                        
            % loop through a small stack
            zoffset = obj.microscope_handle.zstage.zoffset;
            for idelta = linspace(-0.03, 0.03, 10)
                obj.microscope_handle.zstage.setZoffset(zoffset+idelta)
                imgtmp = (obj.microscope_handle.camera.capture);
                obj.max = max([obj.max, single(max(imgtmp(:)))]);
                obj.min = min([obj.max, single(min(imgtmp(:)))]);
                obj.drawImage(imgtmp);
            end
            obj.microscope_handle.zstage.setZoffset(zoffset)
            
            % run event loop
            obj.eventloop.run(@()callback(obj));
            % call call back function when finish
            obj.microscope_handle.setLight('off');
            % finish
            obj.finish;
        end
        
        % get event display for UI
        function dispstr=getEventDisplay(obj,eventstr)
            switch eventstr
                case 'DidStart'
                    dispstr = 'Stop LiveFocus';
                case 'DidFinish'
                    dispstr = 'LiveFocus';
                otherwise
                    dispstr=...
                        getEventDisplay@YMicroscope.MicroscopeAction(obj,eventstr);
            end
        end
        
        
    end
    
    events
    end
    
end

