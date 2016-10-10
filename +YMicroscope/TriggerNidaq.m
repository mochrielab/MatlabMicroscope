classdef TriggerNidaq < YMicroscope.Trigger
    % trigger class for device synchronization
    % use ni daq board to control all equipment
    %   Yao Zhao 11/10/2015

    properties (SetAccess = protected)
    end
    
    properties (Access = protected)
        niclock
        zstage
        fluorescent
        brightfield
        camera
        lightsources
    end
    
    methods
        function obj=TriggerNidaq()
            obj@YMicroscope.Trigger();
            obj.niclock=daq.createSession('ni');
            obj.clockrate=1000;
            obj.framerate=10;
            obj.zstage = obj.niclock.addAnalogOutputChannel('Dev1',0,'Voltage');
            obj.zstage.Name = 'zstage';
%                 ch12 = obj.nidaq.addAnalogInputChannel('Dev1',0,'Voltage');
%                 ch12.Name = 'Z position (input)';
            obj.camera = obj.niclock.addDigitalChannel('Dev1','Port0/Line0','OutputOnly');
            obj.camera.Name = 'camera';
            % brightfield source
            obj.brightfield=obj.niclock.addDigitalChannel('Dev1','Port0/Line1','OutputOnly');
            obj.brightfield.Name = 'brightfield';
            % fluorescent
            obj.fluorescent=obj.niclock.addDigitalChannel('Dev1','Port0/Line2','OutputOnly');
            obj.fluorescent.Name = 'fluorescent';
            % set output voltage zero
            obj.states = [0,0,0,0];
            obj.niclock.outputSingleScan(obj.states);
            % set lightsources to none
            obj.setLightsources([]);
            %
            display('ni daq session created')
        end        
        
        % get current states value
        function states = getStates(obj)
            states = obj.states;
        end
        
        % set states with label
        function setState(obj, label, value)
            % check if running
            if obj.isRunning()
                throw(MException('TriggerNidaq:setState',...
                    'cant set state while running'));
            end
            % find channel with label
            ind = find(strcmp(label, obj.getChannelLabels));
            if length(ind)==1
                % update value
                obj.states(ind) = value;
            else
                throw(MException('TriggerNidaq:setState',...
                    'label cant find'));
            end
            % output a new single scan
            obj.niclock.outputSingleScan(obj.states);
        end
        
        % set clock rate
        function setClockrate(obj,clockrate)
            % set ni clock rate
            obj.niclock.Rate=clockrate;
            setClockrate@YMicroscope.Trigger(obj,clockrate);
        end
        
        % set frame rate
        function setFramerate(obj,framerate)
            setFramerate@YMicroscope.Trigger(obj,framerate);
        end
        
        % select light sources
        function setLightsources(obj,lightsources)
            obj.lightsources=lightsources;
        end
        
        % check if exposure times are valid
        function bool=isValidExposures(obj)
           if obj.getTotalExposure < 1000/obj.framerate
                bool= true;
            else
                bool=false;
            end
        end
        
        % get total exposure time
        function total_exposures=getTotalExposure(obj)
            total_exposures=0;
            for i=1:length(obj.lightsources)
                total_exposures=total_exposures...
                +obj.lightsources(i).exposure+obj.getDeadTime;
            end

        end
    
        % get fastest image aquisition rate given exposures
        function framerate = getHighestFramerate(obj)
            framerate = floor(1000/obj.getTotalExposure);
        end
        
        % the transfer time of the camera
        function deadtime=getDeadTime(obj)
            deadtime=ceil(5*obj.clockrate/1000);
        end
        
        % get output data queue of a stack
        % at each z stack position, multiple image acquisitions
        function queue=getOutputQueueStack(obj,zarray)
            numz=length(zarray);
            single_time=ceil(1000/obj.framerate);
            queue=zeros(numz*single_time,obj.getNumChannels);
            for i=1:numz
                queue((i-1)*single_time+1:i*single_time,:)=...
                    obj.getOutputQueueSingle(zarray(i));
            end
        end
        
        % get output data queue of a waitingtime
        % zstack keep constant value
        function queue=getOutputQueueWait(obj,zvalue,waittime)
            numframes=waittime/(1000/obj.clockrate);
            queue=zeros(numframes,obj.getNumChannels);
            queue(:,1)=zvalue;
        end
        
        % get output data queue
        % a single frame queue with constant zoffset
        function queue=getOutputQueueSingle(obj,zoffset)
            if obj.isValidExposures
                total_time=ceil(1000/obj.framerate);
                queue=zeros(total_time,obj.getNumChannels);
                queue(:,strcmp(obj.getChannelLabels(),'zstage'))=zoffset;
                time_pointer=1;
                for i=1:length(obj.lightsources)
                    exposure=round(obj.lightsources(i).exposure...
                        /1000*obj.clockrate);
                    queue(time_pointer:time_pointer+exposure,...
                        strcmp(obj.getChannelLabels(),'camera')|...
                        strcmp(obj.getChannelLabels(),obj.lightsources(i).label))...
                        =1;
                    time_pointer=time_pointer+exposure+obj.getDeadTime;
                end
            else
                throw(MException('Trigger:InvalidExposures',...
                    ['invalid exposures']));
            end
        end
        
        % get number of channels
        function numcha = getNumChannels(obj)
            numcha = length(obj.niclock.Channels);
        end
        % get channel labels
        function labels = getChannelLabels(obj)
            labels={obj.niclock.Channels.Name};
        end
        
        function delete(obj)
            obj.finish();
        end
    end
    
    methods 
        
        % start sequnce
        function start(obj,outputdata)
            % queue data and start in background
            obj.niclock.queueOutputData(outputdata)
            obj.niclock.startBackground;
        end
        
        % finish sequence
        function finish(obj)
            % stop acquisition
            obj.niclock.stop;
            % recver to previous stage
            obj.niclock.outputSingleScan(obj.states);
        end
        
        % check if is running
        function bool =isRunning(obj)
            pause(.001) % give it time to update
            bool=obj.niclock.IsRunning;
            pause(.001)
        end

        % single trigger light always on or off
        function triggerLight(obj, on_or_off)
            if on_or_off == 1 || on_or_off ==0
                % only set the triggers for current lightsources
                for i=1:length(obj.lightsources)
                    obj.states(strcmp(obj.getChannelLabels(), ...
                        obj.lightsources(i).label))=on_or_off;
                end
                obj.niclock.outputSingleScan(obj.states);
            else
                throw(MException('TriggerNidaq:singleTrigger',...
                    'only accept on_or_off [0,1]'));
            end
        end        
    end
    
    events
    end
    
end