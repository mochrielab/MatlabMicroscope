classdef (Abstract) MicroscopeActionMovieZstack < MicroscopeActionMovie
    % movie zstack class for microscope actions
    % take a movie of zstacks with the current light source
    % number of frames = movie cycles
    % meanwhile display pictures to the UI
    %   Yao Zhao 11/10/2015
    
    properties (SetAccess = protected)
    end
    
    methods
        
        % start movie acquisition
        function start(obj)
            % call super
            start@MicroscopeActionSequence(obj);
            % set light source
            obj.microscope_handle.trigger.setLightsources...
                (obj.microscope_handle.getLightsource);
            % start sequence
            obj.microscope_handle.camera.startSequenceAcquisition();
            %  set frame rate
            zarray=obj.microscope_handle.zstage.getZarray();
            zqueue=obj.microscope_handle.trigger.getOutputQueueStack(zarray);
            zoffset=obj.microscope_handle.zstage.zoffset;
            wqueue=obj.getOutputQueueWait(zoffset,obj.movieinterval);
            totalqueue=repmat(obj.moviecycles,1,[zqueue;wqueue]);
            obj.eventloop.setFramerate((size(wqueue,1)+size(zqueue,1))...
                *obj.microscope_handle.trigger.clockrate);
            % start nidaq in background
            obj.microscope_handle.trigger.start(totalqueue);
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

