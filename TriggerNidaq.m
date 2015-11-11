classdef TriggerNidaq < Trigger
    % trigger class for device synchronization
    %   Yao Zhao 11/10/2015

    properties (SetAccess = protected)
    end
    
    properties (Access = protected)
        zstage
        fluorescent
        brightfield
        camera
        lightsources
        channel_labels
    end
    
    methods
        function obj=TriggerNidaq()
            obj@Trigger();
            obj.clock=daq.createSession('ni');
            obj.clockrate=1000;
            obj.framerate=10;
            obj.zstage = obj.clock.addAnalogOutputChannel('Dev1',0,'Voltage');
            obj.zstage.Name = 'zstage';
%                 ch12 = obj.nidaq.addAnalogInputChannel('Dev1',0,'Voltage');
%                 ch12.Name = 'Z position (input)';
            obj.camera = obj.clock.addDigitalChannel('Dev1','Port0/Line0','OutputOnly');
            obj.camera.Name = 'camera';
            % fluorescence
            obj.brightfield=obj.clock.addDigitalChannel('Dev1','Port0/Line1','OutputOnly');
            obj.brightfield.Name = 'brightfield';
            obj.fluorescent=obj.clock.addDigitalChannel('Dev1','Port0/Line2','OutputOnly');
            obj.fluorescent.Name = 'fluorescent';
            obj.channel_labels={obj.clock.Channels.Name};
            % set output voltage zero
            obj.clock.outputSingleScan([0 0 0 0]);
            % set lightsources to none
            obj.setLightsources([]);
        end
        
        function setClockrate(obj,clockrate)
            obj.clock.Rate=clockrate;
            setClockrate@Trigger(clockrate);
        end
        
        function setFramerate(obj,framerate)
            
            setFramerate@Trigger(clockrate);
        end
        
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
        function setHighestFramerate(obj)
            obj.framerate = floor(1000/obj.getTotalExposure);
        end
        
        % the transfer time of the camera
        function deadtime=getDeadTime(obj)
            deadtime=5;
        end
        
        % get output data queue of a stack
        function queue=getOutputQueueStack(obj,zarray)
            numz=length(zarray);
            single_time=ceil(1000/obj.framerate);
            queue=zeros(obj.getNumChannels,numz*single_time);
            for i=1:numz
                single_time
                size(obj.getOutputQueueSingle(zarray(i)))
                queue(:,(i-1)*single_time+1:i*single_time)=...
                    obj.getOutputQueueSingle(zarray(i));
            end
        end
        
        % get output data queue
        function queue=getOutputQueueSingle(obj,zoffset)
            if obj.isValidExposures
                total_time=ceil(1000/obj.framerate);
                queue=zeros(obj.getNumChannels,total_time);
                queue(strcmp(obj.channel_labels,'zstage'),:)=zoffset;
                time_pointer=1;
                for i=1:length(obj.lightsources)
                    exposure=obj.lightsources(i).exposure;
                    queue(strcmp(obj.channel_labels,'camera')&...
                        strcmp(obj.channel_labels,obj.lightsources(i).label),...
                        time_pointer:time_pointer+exposure)=1;
                    time_pointer=time_pointer+exposure+obj.getDeadTime;
                end
            else
                throw(MException('Trigger:InvalidExposures',...
                    'invalid exposures'));
            end
        end
        
        function numcha = getNumChannels(obj)
            numcha = length(obj.clock.Channels);
        end
        
        function delete(obj)
        end
    end
    
    methods 
        function start(obj,outputdata)
            obj.clock.queueOutputData(outputdata)
            obj.nidaq.startBackground;
        end
        function finish(obj,zoffset)
            obj.clock.stop;
            resetarray=zeros(1,obj.getNumChannels);
            resetarray(strcmp(obj.channel_labels,'zstage'))=zoffset;
            obj.nidaq.outputSingleScan(resetarray); % reset starting position
        end
        
        function bool =isRunning(obj)
            bool=obj.clock.IsRunning;
        end
    end
    
    events
    end
    
end