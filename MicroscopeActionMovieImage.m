classdef (Abstract) MicroscopeActionMovieImage < MicroscopeActionMovie
    % movie class for microscope actions
    % take a movie of single plane with the current light source
    % number of frames = movie cycles
    % frame interval = exposure + movie interval
    % meanwhile display pictures to the UI
    %   Yao Zhao 11/10/2015
    
    properties (Access = protected)
        oldframe
    end
    
    methods
        
        % start movie acquisition
        function start(obj)
            % call super
            start@MicroscopeActionMovie(obj);
            % set light source
            obj.microscope_handle.trigger.setLightsources...
                (obj.microscope_handle.getLightsource);
            % start sequence
            obj.microscope_handle.camera.startSequenceAcquisition();
            %  set frame rate
            zarray=zeros(1,obj.moviecycles)+obj.microscope_handle.zstage.zoffset;
            totalinterval=obj.microscope_handle.trigger.getTotalExposure+...
                obj.movieinterval;
            tmpframerate=1000/totalinterval;
            % save old framerate
            obj.oldframe=obj.microscope_handle.trigger.framerate;
            obj.microscope_handle.trigger.setFramerate(tmpframerate);
            obj.eventloop.setFramerate(tmpframerate);
            % start nidaq in background
            obj.microscope_handle.trigger.start(...
                obj.microscope_handle.trigger.getOutputQueueStack(zarray));
        end
        
        % finish movie acquisition
        function stop(obj)
            stop@MicroscopeActionMovie(obj);
            obj.microscope_handle.trigger.setFramerate(obj.oldframe);
        end
        
        % function run single loop
        function runSingleLoop(obj)
            if ~obj.microscope_handle.trigger.isRunning
                obj.eventloop.stop;
            end
            obj.drawImage(obj.microscope_handle.camera.getLastImage);
            for i=1:3
                img=obj.microscope_handle.camera.popNextImage;
                if ~isempty(img)
                    obj.file_handle.fwrite(img)
                end
            end
        end
                
        % get event display for UI
        function dispstr=getEventDisplay(obj,eventstr)
            switch eventstr
                case 'DidStart'
                    dispstr = 'Stop Sequence Movie';
                case 'DidFinish'
                    dispstr = 'Sequence Movie';
                otherwise
                    dispstr=getEventDisplay@MicroscopeAction(obj,eventstr);
            end
        end

    end

    
    events
    end
    
end

