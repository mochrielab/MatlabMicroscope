classdef Lightsource473nm < YMicroscope.Lightsource
    % class for 473nm laser, fluorescent illumination ... 01/23/17 -
    % starting
    
    properties (Access = protected)
        trigger
    end
    
    properties (Constant)
        color_options = {'all'}
    end
    
    methods
        
        function obj = Lightsource473nm(trigger,label)
            obj.trigger = trigger;
            obj.label=label;
            obj.setExposure(100);
            disp('473nm laser connected!')
        end
        
        function setExposure(obj,exposure)
            if exposure < 0
                exception=MException('Lightsource:NegativeExposure','negative exposure');
                throw(exception);
            else
                obj.exposure = exposure;
                notify(obj,'ExposureDidSet');
            end
        end
        
        function setIntensity(obj,intensity)
        end
        
        function setPower(obj,power)
        end
        
        function setColor(obj,color)
            if strcmp(color,'all')
            else
                exception=MException('Lightsource:UnsupportedColor',...
                    ['color ',color,' not supported']);
                throw(exception);
            end
        end
        
        
        function turnOn(obj)
            obj.trigger.setState('laser473',1);
            obj.ison=true;
        end
        
        function turnOff(obj)
            obj.trigger.setState('laser473',0);
            obj.ison=false;
        end
        
    end
    
end

