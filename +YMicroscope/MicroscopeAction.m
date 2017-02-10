classdef (Abstract) MicroscopeAction < handle & matlab.mixin.Heterogeneous
    %basic class for microscope actions
    %   Yao Zhao 11/9/2015
    
    properties (SetAccess = protected)
        label;
    end
    
    properties (Access = protected)
        isrunning
        microscope_handle
        image_axes
        hist_axes
        eventloop
        file_handle
        histxmin
        histxmax
    end
  
    methods
        % constructor
        function obj = MicroscopeAction(label,microscope,image_axes,hist_axes)
            import YMicroscope.*
            obj.label=label;
            obj.microscope_handle=microscope;
            obj.isrunning = false;
            obj.image_axes=image_axes;
            obj.hist_axes = hist_axes;
            obj.eventloop=EventLoop(10);
            obj.file_handle=TiffIO(microscope.datapath,obj.label);
            obj.histxmin = obj.microscope_handle.histxmin;
            obj.histxmax = obj.microscope_handle.histxmax;
        end
        
        % start action
        % lock microscope and set is running to be true
        function start(obj)
            obj.microscope_handle.lock(obj);
            obj.isrunning = true;
            % notify event
            notify(obj,'DidStart');
        end
        
        % interrupt action
        function stop(obj)
            obj.eventloop.stop;
            notify(obj,'WillStop');
        end
        
        % finish action
        function finish(obj)
            obj.microscope_handle.unlock(obj);
            obj.isrunning = false;
            notify(obj,'DidFinish');
        end
        
        % draw image to ui
        function drawImage(obj,img)
            if ishandle(obj.image_axes)
                % there is a bad pixel in zyla camera
                if numel(img) == 5529600
                    img(5527206)= 0;
                end
                cla(obj.image_axes);
                axes(obj.image_axes); % IF I HAVE
                % MULTIPLE AXES IN MY GUI, I NEED TO EXPLICITLY SPECIFY
                % WHICH AXES TO USE BEFORE DRAWING AN IMAGE OR A HISTOGRAM.
                % SIMPLY TRY TO USE: IF ISHANDLE(OBJ.IMAGE_AXES).... ISN'T
                % SUFFICIENT. I THINK THAT THIS MAY BE BECAUSE THE HANDLE
                % IS TRUE, BUT IT IS ALSO TRUE THAT THE OBJ.HIST_AXES IS
                % TRUE. THIS MAKES IT NECESSARY FOR ME TO EXPLCIITLY
                % DISTINGUISH BETWEEN THE TWO AXES PRESENT IN THE UI!
                imagesc(img,[obj.histxmin obj.histxmax]); 
                axis equal; axis off;
            end
        end
        % draw histogram to ui
        function drawHist(obj,img) %,histflag)
            if ishandle(obj.hist_axes)
                cla(obj.hist_axes); 
                axes(obj.hist_axes);
                histogram(img); xlim([obj.histxmin obj.histxmax]);
                set(gca,'yticklabel',[]);
            end
        end
        
        % test if action is running
        function bool=isRunning(obj)
            bool=obj.isrunning;
        end
        
        % get event display for ui
        function dispstr=getEventDisplay(obj,eventstr)
            switch eventstr
                case 'ObjectBeingDestroyed'
                    dispstr='default';
                case 'DidStart'
                    dispstr='Started';
                case 'DidFinish'
                    dispstr='Ready';
                case 'WillStop'
                    dispstr='Stopping';
                otherwise
                    warning(['no events has been set for: ',eventstr]);
                    dispstr=[];
            end
        end
    end
    
    methods (Abstract)
        run(obj)
    end
    
    events
        DidStart
        DidFinish
        WillStop
    end
    
end

