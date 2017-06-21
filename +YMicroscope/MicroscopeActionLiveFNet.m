classdef MicroscopeActionLiveFNet < YMicroscope.MicroscopeActionLive
    % live function of the microscope with autofocusing using deep learning
    % inherited the class of action controller responder
    % will respond to events created by the joystick or keyboard
    %   Yao Zhao 11/16/2015
    
    properties (SetAccess = protected)
        fnet
        max
        min
        lockfocus
        focalplanecorrect
        focaldistavg
        batchsize
        modelname
    end
    
    methods
        % constructor
        function obj=MicroscopeActionLiveFNet...
                (microscope,image_axes,hist_axes)
            obj@YMicroscope.MicroscopeActionLive(...
                microscope,image_axes,hist_axes);
            obj.label = 'livefnet';
            obj.lockfocus = false;
            obj.focalplanecorrect = 0;
            obj.focaldistavg = 0;
            obj.modelname = 'probnet12';
            obj.batchsize = 16;
            obj.fnet = YMicroscope.FocusNet(...
                fullfile('models', obj.modelname), obj.batchsize);
        end
        
        function setBatchsize(obj, batchsize)
            if batchsize ~= 1 && batchsize ~= 4 && batchsize ~= 16
                throw(MException('MicroscopeAction:UnsupportedBatchsize',...
                    'use batchsize of 1, 4 or 16'))
            end
            obj.fnet = YMicroscope.FocusNet(...
                fullfile('models', obj.modelname), batchsize);
            obj.batchsize = batchsize;
        end
        
        function setLockfocus(obj, lock)
            obj.lockfocus = lock;
            notify(obj, 'LockfocusDidSet')
        end
        
        function setFocalplanecorrect(obj, correct)
            obj.focalplanecorrect = correct;
            notify(obj, 'FocalplanecorrectDidSet')
        end
        
        % destructor
        function delete(obj)
            delete@YMicroscope.MicroscopeActionLive(obj);
        end
        
        % start live
        function start(obj)
            % call super
            start@YMicroscope.MicroscopeActionLive(obj);
            roi = obj.microscope_handle.camera.roi;
            switch roi
                case '1024 x 1344'
                    obj.setBatchsize(16);
                case '512 x 512'
                    obj.setBatchsize(4);
                case '256 x 256'
                    obj.setBatchsize(1);
                otherwise
                    throw(MException('MicroscopeAction:UnsupportedBatchsize',...
                        ['can not find the corresponding batchsize to roi of ', roi]))
            end
        end
        
        % run everything
        function run(obj)
            obj.start;            
            % turn on light
            obj.microscope_handle.setLight('always on');
            
            % loop through a small stack
            zoffset = obj.microscope_handle.zstage.zoffset;
            for idelta = linspace(-0.06, 0.06, 21)
                obj.microscope_handle.zstage.setZoffset(zoffset+idelta)
                imgtmp = (obj.microscope_handle.camera.capture);
                obj.max = max([obj.max, single(max(imgtmp(:)))]);
                obj.min = min([obj.max, single(min(imgtmp(:)))]);
                obj.drawImageNoHist(imgtmp);
            end
            obj.microscope_handle.zstage.setZoffset(zoffset)
            
            % run event loop
            obj.eventloop.run(@()obj.runLoopCallBackFNet());
            % call call back function when finish
            obj.microscope_handle.setLight('off');
            % finish
            obj.finish;
        end
        
        
        function img = runLoopCallBackFNet(obj)
            img = (obj.microscope_handle.camera.capture);
            obj.fnet.loadImages(img, obj.max, obj.min);
            obj.fnet.inference();
            obj.drawImageNoHist(img); hold on;
            obj.fnet.plot();
            if obj.lockfocus
                dist = obj.fnet.getFocalDistance();
%                     obj.focaldistavg = obj.focaldistavg * 0.8 + dist * 0.2;
                display(['distance to focal plane: ', num2str(dist)]);
                obj.microscope_handle.zstage.move((dist - obj.focalplanecorrect)*.5);
            end
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
        LockfocusDidSet
        FocalplanecorrectDidSet
        BatchsizeDidSet
    end
    
end

